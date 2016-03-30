configuration SFSimpleDeployment {
    param (
        ## Path to StoreFront installation executable
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Storefront base Uri, e.g. https://storefront.lab.local
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $BaseUrl,

        ## XenDesktop/XenApp farm/site to add to the deployment
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $FarmName,

        ## XenDesktop/XenApp farm/site type to add to the deployment
        [Parameter(Mandatory)] [ValidateSet('XenApp','XenDesktop','VDIinaBox')]
        [System.String] $FarmType,

        ## XenDesktop/XenApp farm/site controllers
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Servers,

        ## Storefront store virtual path
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $StoreVirtualPath = '/Citrix/Store',

        ## Storefront authentication service virtual path
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $AuthenticationVirtualPath = '/Citrix/Authentication',

        ## Xml service transport type
        [Parameter()] [ValidateSet('HTTP','HTTPS')]
        [System.String] $Transport = 'HTTP',

        ## Xml service port
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $ServicePort = (& { if ($Transport -eq 'HTTPS') { 443 } else { 80 } })
    )

    ## Avoid recursively loading the module!
    Import-DscResource -Name VE_SFFeature, VE_SFCluster, VE_SFAuthenticationService, VE_SFStore, VE_SFStoreWebReceiver, VE_SFStoreFarm;

    $prefix = $BaseUrl.Replace('/','').Replace(':','');

    SFFeature "$($prefix)Feature" {
        Path = $Path;
    }

    SFCluster "$($prefix)Group" {
        BaseUrl = $BaseUrl;
    }

    SFAuthenticationService "$($prefix)Authentication" {
        VirtualPath = $AuthenticationVirtualPath;
        DependsOn = "[SFCluster]$($prefix)Group";
    }

    SFStore "$($prefix)Store" {
        VirtualPath = $StoreVirtualPath;
        AuthenticationServiceVirtualPath = $AuthenticationVirtualPath;
        DependsOn = "[SFAuthenticationService]$($prefix)Authentication";
    }

    SFStoreWebReceiver "$($prefix)WebReceiver" {
        StoreVirtualPath = $StoreVirtualPath;
        DependsOn = "[SFStore]$($prefix)Store";
    }

    SFStoreFarm "$($prefix)Farm" {
        StoreVirtualPath = $StoreVirtualPath;
        FarmName = $FarmName;
        FarmType = $FarmType;
        Servers = $Servers;
        TransportType = $Transport;
        ServicePort = $ServicePort;
    }

}
