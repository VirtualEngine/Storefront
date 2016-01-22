Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Only applicable to v3.5 stores (if thinking about backward compatibility
        [Parameter(Mandatory)]
        [System.String] $AuthenticationServiceVirtualPath,

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $FriendlyName,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'

    )
    process {
        ImportSFModule -Name Citrix.Storefront.Stores;
        $store = GetStoreService @PSBoundParameters;
        $targetResource = @{
            VirtualPath = $store.VirtualPath;
            AuthenticationServiceVirtualPath = $store.AuthenticationServiceVirtualPath
            SiteId = $store.SiteId;
            FriendlyName = $store.FriendlyName;
            Ensure = if ($store) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Only applicable to v3.5 stores (if thinking about backward compatibility
        [Parameter(Mandatory)]
        [System.String] $AuthenticationServiceVirtualPath,

        [Parameter()]
        [System.UInt64] $SiteId = 1,

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
            $properties = @('VirtualPath','AuthenticationServiceVirtualPath','SiteId','FriendlyName');
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
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Only applicable to v3.5 stores (if thinking about backward compatibility
        [Parameter(Mandatory)]
        [System.String] $AuthenticationServiceVirtualPath,

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $FriendlyName,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ImportSFModule -Name Citrix.Storefront.Stores;
        $store = GetStoreService @PSBoundParameters;
        $authenticationService = GetAuthenticationService -VirtualPath $AuthenticationServiceVirtualPath;

        if ($Ensure -eq 'Absent') {
            if ($store) {
                ## Store exists, removing
                Write-Verbose -Message ($localizedData.RemovingStore -f $VirtualPath);
                [ref] $null = Remove-STFStoreService -StoreService $store -Force -Confirm:$false;
            }
        }
        elseif ($Ensure -eq 'Present') {
            if ($store) {
                ## Store already exists
                if ($FriendlyName -ne $store.FriendlyName) {
                    ## Cannot update friendly name
                    $errorMessage = $localizedData.CannotUpdatePropertyError -f 'FriendlyName';
                    ThrowInvalidOperationException -ErrorId ImmutableProperty -ErrorMessage $errorMessage;
                }
                if ($AuthenticationServiceVirtualPath -ne $authenticationService.VirtualPath) {
                    ## Update authentication
                    Write-Verbose -Message ($localizedData.UpdatingStoreAuthentication -f $AuthenticationServiceVirtualPath);
                    [ref] $null = Set-STFStoreService -StoreService $store -AuthenticationService $authenticationService -Force -Confirm:$false;
                }
            }
            else {
                Write-Verbose -Message ($localizedData.AddingStore -f $VirtualPath);
                $addSTFStoreServiceParams = @{
                    VirtualPath = $VirtualPath;
                    AuthenticationService = $authenticationService;
                }
                if ($PSBoundParameters.ContainsKey('SiteId')) {
                    $addSTFStoreServiceParams['SiteId'] = $SiteId;
                }
                if ($PSBoundParameters.ContainsKey('FriendlyName')) {
                    $addSTFStoreServiceParams['FriendlyName'] = $FriendlyName;
                }
                [ref] $null = Add-STFStoreService @addSTFStoreServiceParams;
            }
        }
    } #end process
} #end function Set-TargetResource
