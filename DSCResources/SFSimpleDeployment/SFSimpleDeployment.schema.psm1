configuration SFSimpleDeployment {
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $BaseUrl,

        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $FarmName,

        [Parameter(Mandatory)] [ValidateSet('XenApp','XenDesktop','VDIinaBox')]
        [System.String] $FarmType,

        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Servers,

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $StoreVirtualPath = '/Citrix/Store',

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $AuthenticationVirtualPath = '/Citrix/Authentication',

        [Parameter()] [ValidateSet('HTTP','HTTPS')]
        [System.String] $Transport = 'HTTP',
        
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $ServicePort = (& { if ($Transport -eq 'HTTPS') { 443 } else { 80 } })
    )

    ## Avoid recursively loading the module!
    Import-DscResource -Name VE_SFCluster, VE_SFAuthenticationService, VE_SFStore, VE_SFStoreWebReceiver, VE_SFStoreFarm;

    $preffix = $BaseUrl.Replace('/','').Replace(':','');
    
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
