Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Citrix Storefront Authentication Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Citrix Storefront Site Id
        [Parameter()]
        [System.UInt64] $SiteId = 1,

        ## Authentication service friendly name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $FriendlyName,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'

    )
    process {
        ImportSFModule -Name Citrix.Storefront.Authentication;
        $authenticationService = GetAuthenticationService @PSBoundParameters;
        $targetResource = @{
            VirtualPath = $authenticationService.VirtualPath;
            SiteId = $authenticationService.SiteId;
            FriendlyName = $authenticationService.FriendlyName;
            Ensure = if ($authenticationService) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Citrix Storefront Authentication Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Citrix Storefront Site Id
        [Parameter()]
        [System.UInt64] $SiteId = 1,

        ## Authentication service friendly name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $FriendlyName,

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
            $properties = @('VirtualPath','SiteId','FriendlyName');
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
        ## Citrix Storefront Authentication Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Citrix Storefront Site Id
        [Parameter()]
        [System.UInt64] $SiteId = 1,

        ## Authentication service friendly name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $FriendlyName,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ImportSFModule -Name Citrix.Storefront.Authentication;
        $authenticationService = GetAuthenticationService @PSBoundParameters;

        if (-not $FriendlyName) {
            $FriendlyName = $VirtualPath.Trim('/').Split('/')[-1];
        }

        if ($Ensure -eq 'Absent') {
            if ($authenticationService) {
                ## Cluster exists, removing
                Write-Verbose -Message ($localizedData.RemovingAuthenticationSerivce -f $VirtualPath);
                [ref] $null = Remove-STFAuthenticationService -AuthenticationService $authenticationService -Confirm:$false;
            }
        }
        elseif ($Ensure -eq 'Present') {
            if ($authenticationService) {
                ## Authentication service already exists?!
            }
            else {
                Write-Verbose -Message ($localizedData.AddingAuthenticationService -f $VirtualPath);
                $addSTFAuthenticationServiceParams = @{
                    VirtualPath = $VirtualPath;
                }
                if ($PSBoundParameters.ContainsKey('SiteId')) {
                    $addSTFAuthenticationServiceParams['SiteId'] = $SiteId;
                }
                if ($PSBoundParameters.ContainsKey('FriendlyName')) {
                    $addSTFAuthenticationServiceParams['FriendlyName'] = $FriendlyName;
                }
                [ref] $null = Add-STFAuthenticationService @addSTFAuthenticationServiceParams;
            }
        }
    } #end process
} #end function Set-TargetResource
