Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Citrix Storefront Store Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $StoreVirtualPath,


        ## Citrix Storefront Store Service IIS Site Id
        [Parameter()] [ValidateNotNull()]
        [System.UInt16] $SiteId = 1,


        ## Netscaler Gateway to register
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Gateway,


        ## Use this Gateway as the default if more than one is defined
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $DefaultGateway = $true,


        ## Use full VPN access when accessing the Store through this Gateway
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $UseFullVpn = $false,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    
    process {

        ImportSFModule -Name 'Citrix.StoreFront.Stores';

        $storeService = Get-STFStoreService -VirtualPath $StoreVirtualPath;
        $storeGatewayList = Get-STFStoreRegisteredGateway -StoreService $storeService

        #Initialize target resource to absen by default
        $targetResource = @{
            VirtualPath = $StoreVirtualPath;
            SiteId = $SiteId;
            Gateway = $null;
            DefaultGateway = $null;
            UseFullVpn = $nll;
            Ensure = 'Absent';
        }

        #Parse each registered Gateway to check is the desired gateway is already registered
        foreach ($storeGateway in $storeGatewayList) {
            if($storeGateway.Name -eq $Gateway) {
                if($storeGateway.RemoteAccessType -eq 'StoresOnly') {
                    $FullVpn = $false;
                }
                elseif($storeGateway.RemoteAccessType -eq 'FullVPN') {
                    $FullVpn = $true;
                }

                $targetResource = @{
                    VirtualPath = $StoreVirtualPath;
                    SiteId = $SiteId;
                    Gateway = $storeGateway.Name;
                    DefaultGateway = $storeGateway.Default;
                    UseFullVpn = $FullVpn;
                    Ensure = 'Present';
                }
            }
        }

        return $targetResource;

    } #end process
} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Citrix Storefront Store Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $StoreVirtualPath,


        ## Citrix Storefront Store Service IIS Site Id
        [Parameter()] [ValidateNotNull()]
        [System.UInt16] $SiteId = 1,


        ## Netscaler Gateway to register
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Gateway,


        ## Use this Gateway as the default if more than one is defined
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $DefaultGateway = $true,


        ## Use full VPN access when accessing the Store through this Gateway
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $UseFullVpn = $false,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        
        $targetResource = Get-TargetResource @PSBoundParameters;

        if ($Ensure -ne $targetResource.Ensure) {
            Write-Verbose -Message ($localizedData.ResourcePropertyMismatch -f 'Ensure', $Ensure, $targetResource.Ensure);
            $inDesiredState = $false;
        }

        ## Only check all remaing properties if we're setting
        if ($Ensure -eq 'Present') {
            if(($targetResource.Gateway -eq $Gateway) -and  ($targetResource.DefaultGateway -eq $DefaultGateway) -and  ($targetResource.UseFullVpn -eq $UseFullVpn)) {
                    $inDesiredState = $true;
            }
            else {
                $inDesiredState = $false;
            }
        }

        if ($inDesiredState) {

            Write-Verbose ($localizedData.ResourceInDesiredState);
            return $true;
        }
        else {

            Write-Verbose ($localizedData.ResourceNotInDesiredState);
            return $false;
        }

    } #end process
} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]

    param (
        ## Citrix Storefront Store Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $StoreVirtualPath,


        ## Citrix Storefront Store Service IIS Site Id
        [Parameter()] [ValidateNotNull()]
        [System.UInt16] $SiteId = 1,


        ## Netscaler Gateway to register
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Gateway,


        ## Use this Gateway as the default if more than one is defined
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $DefaultGateway = $true,


        ## Use full VPN access when accessing the Store through this Gateway
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $UseFullVpn = $false,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    
    process {

        ImportSFModule -Name 'Citrix.StoreFront.Stores';
        ImportSFModule -Name Citrix.Storefront.Authentication;

        Write-Verbose ($localizedData.UpdatingStoreRegisteredGateway -f $StoreVirtualPath);

        $targetResource = Get-TargetResource @PSBoundParameters;
        
        #Get the store and gateway objects from Storefront
        $GatewayObject = Get-STFRoamingGateway -Name $Gateway;
        $storeService = Get-STFStoreService -VirtualPath $StoreVirtualPath;

        #
        if ($Ensure -eq 'Absent') {
            if($targetResource.Gateway -eq $Gateway) {
                ## Netscaler Gateway registered to store, removing
                [ref] $null = Unregister-STFStoreGateway -Gateway $GatewayObject -StoreService $storeService;
            }
        }
        elseif ($Ensure -eq 'Present') {
            #The CitrixAGBasic authentication protocol is used when accessing StoreFront remotely through a Citrix NetScaler Gateway
            $AuthenticationService = Get-STFAuthenticationService -VirtualPath $storeService.AuthenticationServiceVirtualPath;
            [ref] $null = Add-STFAuthenticationServiceProtocol -AuthenticationService $authenticationService -Name 'CitrixAGBasic';

            if($DefaultGateway -and $UseFullVpn) {
                [ref] $null = Register-STFStoreGateway -Gateway $GatewayObject -StoreService $storeService -DefaultGateway -UseFullVpn; 
            }
            elseif($DefaultGateway -and (-Not $UseFullVpn)) {
                [ref] $null = Register-STFStoreGateway -Gateway $GatewayObject -StoreService $storeService -DefaultGateway;
            }
            elseif((-Not $DefaultGateway) -and $UseFullVpn) {
                [ref] $null = Register-STFStoreGateway -Gateway $GatewayObject -StoreService $storeService -UseFullVpn;
            }
            else {
                [ref] $null = Register-STFStoreGateway -Gateway $GatewayObject -StoreService $storeService;
            }
        }
        
    } #end process
} #end function Set-TargetResource
