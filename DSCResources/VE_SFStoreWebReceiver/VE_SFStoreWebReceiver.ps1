Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Store virtual path, e.g. /Citrix/Store
        [Parameter(Mandatory)]
        [System.String] $StoreVirtualPath,

        ## Receiver for Web virtual path, e.g. /Citrix/StoreWeb
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $VirtualPath = ('{0}Web' -f $StoreVirtualPath.TrimEnd('/')),

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter()]
        [System.Boolean] $ClassicReceiver,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ImportSFModule -Name 'Citrix.StoreFront.Stores','Citrix.StoreFront.WebReceiver';
        $webReceiver = GetWebReceiverService -VirtualPath $VirtualPath -SiteId $SiteId;
        $targetResource = @{
            VirtualPath = $webReceiver.VirtualPath
            StoreVirtualPath = $webReceiver.StoreServiceVirtualPath;
            ClassicReceiver = $webReceiver.WebReceiver.ClassicReceiverExperience;
            SiteId = $webReceiver.SiteId;
            Ensure = if ($webReceiver) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Store virtual path, e.g. /Citrix/Store
        [Parameter(Mandatory)]
        [System.String] $StoreVirtualPath,

        ## Receiver for Web virtual path, e.g. /Citrix/StoreWeb
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $VirtualPath = ('{0}Web' -f $StoreVirtualPath.TrimEnd('/')),

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter()]
        [System.Boolean] $ClassicReceiver,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        $targetResource = Get-TargetResource @PSBoundParameters;
        $inDesiredState = $true;

        if ($Ensure -ne $targetResource.Ensure) {
            Write-Verbose -Message ($localizedData.ResourcePropertyMismatch -f 'Ensure', $Ensure, $targetResource.Ensure);
            $inDesiredState = $false;
        }

        ## Only check all remaing properties if we're setting
        if ($Ensure -eq 'Present') {
            $properties = @('VirtualPath','StoreServiceVirtualPath','SiteId','ClassicReceiver');
            foreach ($property in $properties) {
                if ($PSBoundParameters.ContainsKey($property)) {
                    $propertyValue = (Get-Variable -Name $property).Value;
                    if ($targetResource.$property -ne $propertyValue) {
                        $message = $localizedData.ResourcePropertyMismatch -f $property, $propertyValue, $targetResource.$property;
                        Write-Verbose -Message $message;
                        $inDesiredState = $false;
                    }
                } #end if PSBoundParameter
            } #end foreach property
        } #end if ensure is present

        if ($inDesiredState) {
            Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $VirtualPath);
        }
        else {
            Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $VirtualPath);
        }
        return $inDesiredState;
    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        ## Store virtual path, e.g. /Citrix/Store
        [Parameter(Mandatory)]
        [System.String] $StoreVirtualPath,

        ## Receiver for Web virtual path, e.g. /Citrix/StoreWeb
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $VirtualPath = ('{0}Web' -f $StoreVirtualPath.TrimEnd('/')),

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter()]
        [System.Boolean] $ClassicReceiver,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ImportSFModule -Name 'Citrix.Storefront.Stores','Citrix.StoreFront.WebReceiver';
        $webReceiver = GetWebReceiverService -VirtualPath $VirtualPath -SiteId $SiteId;

        if ($Ensure -eq 'Absent') {
            if ($webReceiver) {
                ## Store exists, removing
                Write-Verbose -Message ($localizedData.RemovingReceiverWeb -f $VirtualPath);
                [ref] $null = Remove-STFWebReceiverService -WebReceiverService $webReceiver -Confirm:$false;
            }
        }
        elseif ($Ensure -eq 'Present') {
            if ($webReceiver) {
                if ($ClassicReceiver -ne $webReceiver.WebReceiver.ClassicReceiverExperience) {
                    Write-Verbose ($localizedData.UpdatingResourceProperty -f 'ClassicReceiver', $ClassicReceiver);
                    [ref] $null = Set-STFWebReceiverService -WebReceiverService $webReceiver -ClassicReceiverExperience $ClassicReceiver;
                }
            }
            else {
                Write-Verbose -Message ($localizedData.AddingWebReceiver -f $VirtualPath);
                $addSTFWebReceiverServiceParams = @{
                    VirtualPath = $VirtualPath;
                    StoreService = GetStoreService -VirtualPath $StoreVirtualPath -SiteId $SiteId;
                    ClassicReceiverExperience = $ClassicReceiver;
                }
                if ($PSBoundParameters.ContainsKey('SiteId')) {
                    $addSTFWebReceiverServiceParams['SiteId'] = $SiteId;
                }
                [ref] $null = Add-STFWebReceiverService @addSTFWebReceiverServiceParams;
            }
        }
    } #end process
} #end function Set-TargetResource
