Included Resources
==================
* SFSimpleDeployment
* SFAuthenticationService
* SFAuthenticationServiceMethod
* SFCluster
* SFFeature
* SFGateway
* SFStore
* SFStoreFarm
* SFStoreWebReceiver

SFSimpleDeployment
==================
Composite resource to deploy a simple StoreFront configuration
###Syntax
```
SFSimpleDeployment [string] #ResourceName
{
    BaseUrl = [String]
    FarmName = [String]
    FarmType = [String]
    Servers = [String[]]
    [ StoreVirtualPath = [String] ]
    [ AuthenticationVirtualPath = [String] ]
    [ Transport = [String] ]
    [ ServicePort = [UInt32] ]
}
```

SFAuthenticationService
=======================
Adds an authentication service to a Citrix StoreFront group/cluster.
###Syntax
```
SFAuthenticationService [string] #ResourceName
{
    VirtualPath = [string]
    [ DependsOn = [string[]] ]
    [ Ensure = [string] { Absent | Present }  ]
    [ FriendlyName = [string] ]
    [ SiteId = [UInt64] ]
}
```

SFAuthenticationServiceMethod
=============================
Configures authentication methods available on an existing Citrix StoreFront store.
###Syntax
```
SFAuthenticationServiceMethod [string] #ResourceName
{
    VirtualPath = [string]
    [ AuthenticationMethods = [string[]] { Certificate | CitrixAGBasic | CitrixFederation | ExplicitForms | HttpBasic | IntegratedWindows } ]
    [ DependsOn = [string[]] ]
    [ Ensure = [string] { Absent | Present }  ]
    [ ExcludeAuthenticationMethods = [string[]] { Certificate | CitrixAGBasic | CitrixFederation | ExplicitForms | Http | Basic | IntegratedWindows } ]
    [ IncludeAuthenticationMethods = [string[]] { Certificate | CitrixAGBasic | CitrixFederation | ExplicitForms | Http | Basic | IntegratedWindows } ]
}
```

SFCluster
===========
Creates a Citrix Storefront group/cluster.
###Syntax
```
SFCluster [string] #ResourceName
{
    DeliveryGroup = [string]
    AccessType = [string] { AccessGateway | Direct }
    [Enabled = [bool]]
    [AllowRestart = [bool]]
    [Name = [string]]
    [Description = [string]]
    [Protocol = [string[]] { HDX | RDP }
    [IncludeUsers = [string[]]
    [ExcludeUsers = [string[]]
    [Ensure = [string]] { Present | Absent }
    [Credential = [PSCredential]]
}
```
###Properties
* **DeliveryGroup**: The Citrix XenDesktop 7.x delivery group name to assign the access policy.
* **AccessType**: The access policy filter type.
* **Enabled**: Whether the access policy is enabled. If not specified, it defaults to True.
* **AllowRestart**: Whether users are permitted to restart desktop group machines. If not specified, it defaults to True.
* **Name**: Name of the access policy. If not specified, it defaults to DesktopGroup_Direct or DesktopGroup_AG.
* **Description**: Custom description assigned to the access policy rule.
* **Protocol**: Permitted protocols. If not specified, it defaults to both HDX and RDP.
* **IncludeUsers**: List of associated Active Directory user and groups assigned to the access policy.
* **ExcludeUsers**: List of associated Active Directory user and groups excluded from the access policy.
* **Ensure**: Whether the role is to be installed or not. Supported values are Present or Absent. If not specified, it defaults to Present.
* **Credential**: Specifies optional credential of a user which has permissions to access the source media and/or install/uninstall the specified role. __This property is required for Powershell 4.0.__

###Configuration
```
Configuration XD7AccessPolicyExample {
    Import-DscResource -ModuleName CitrixXenDesktop7
    XD7AccessPolicy XD7MyDesktopGroupAccessPolicy {
        DeliveryGroup = 'My Desktop Group'
        AccessType = 'AccessGateway'
        Enabled = $true
        AllowRestart = $true
        Protocol = 'HDX'
        IncludeUsers = @('DOMAIN\GroupA','DOMAIN\GroupB')
        Ensure = 'Present'
    }
}
```

SFFeature
=========
Installs Citrix StoreFront.
###Syntax
```
SFFeature [string] #ResourceName
{
    Path = [string]
    [DestinationPath = [string]]
    [WindowsClientPath = [string]]
    [MacClientPath = [string]]
    [Ensure = [string]] { Present | Absent }
    [Credential = [PSCredential]]
}
```
###Properties
* **Path**: Path to the Citrix StoreFront installation executable.
* **DestinationPath**: Local path to install Citrix StoreFront into to.
 * If not specified, Citrix StoreFront is installed in the default location.
* **WindowsClientPath**: Copies Receiver for Windows installation file specified to the appropriate location in your StoreFront deployment.
* **WindowsClientPath**: Copies Receiver for Mac installation file specified to the appropriate location in your StoreFront deployment.
* **Ensure**: Whether the role is to be installed or not.
 * If not specified, it defaults to Present.
* **Credential**: Specifies optional credential of a user which has permissions to access the source installation file.

###Configuration
```
Configuration SFFeatureExample {
    Import-DscResource -ModuleName Storefront
    SFFeature 'InstallStoreFront' {
        Path = 'C:\Sources\CitrixStoreFront-x64.exe'
        Ensure = 'Present'
    }
}
```

SFGateway
=========
Adds a NetScaler Gateway to the Citrix StoreFront group/cluster.
###Syntax
```
SFGateway [string] #ResourceName
{
    LogonType = [string] { Domain | DomainAndRSA | GatewayKnows | None | RSA | SmartCard | SMS | UsedForHDXOnly }
    Name = [string]
    Url = [string]
    [ CallbackUrl = [string] ]
    [ DependsOn = [string[]] ]
    [ Ensure = [string] { Absent | Present } ]
    [ RequestTicketTwoSTAs = [bool] ]
    [ SecureTicketAuthorityUrls = [string[]] ]
    [ SessionReliability = [bool] ]
    [ SmartCardFallbackLogonType = [string] { Domain | DomainAndRSA | GatewayKnows | None | RSA | SmartCard | SMS | UsedForHDXOnly } ]
    [ StasBypassDuration = [UInt32] ]
    [ StasUseLoadBalancing = [bool] ]
    [ SubnetIPAddress = [string] ]
}
```

SFStore
=======
Adds a store to the Citrix StoreFront group/cluster.
###Syntax
```
SFStore [string] #ResourceName
{
    AuthenticationServiceVirtualPath = [string]
    VirtualPath = [string]
    [ DependsOn = [string[]] ]
    [ Ensure = [string] { Absent | Present } ]
    [ FriendlyName = [string] ]
    [ SiteId = [UInt64] ]
}
```

SFStoreFarm
===========
Adds a XenApp/XenDesktop farm/site to an existing Citrix StoreFront store.
###Syntax
```
SFStoreFarm [string] #ResourceName
{
    FarmName = [string]
    FarmType = [string] { AppController | VDIinaBox | XenApp | XenDesktop }
    Servers = [string[]]
    StoreVirtualPath = [string]
    [ AllFailedBypassDuration = [UInt32] ]
    [ BypassDuration = [UInt32] ]
    [ DependsOn = [string[]] ]
    [ Ensure = [string] { Absent | Present } ]
    [ LoadBalance = [bool] ]
    [ MaxFailedServersPerRequest = [UInt32] ]
    [ RadeTicketTimeToLive = [UInt32] ]
    [ ServicePort = [UInt32] ]
    [ SSLRelayServicePort = [UInt32] ]
    [ TicketTimeToLive = [UInt32] ]
    [ TransportType = [string] { HTTP | HTTPS | SSL } ]
}
```

SFStoreWebReceiver
==================
Adds a Web Receiver site to an existing Citrix StoreFront store.
###Syntax
```
SFStoreWebReceiver [string] #ResourceName
{
    StoreVirtualPath = [string]
    [ ClassicReceiver = [bool] ]
    [ DependsOn = [string[]] ]
    [ Ensure = [string] { Absent | Present } ]
    [ SiteId = [UInt64] ]
    [ VirtualPath = [string] ]
}
```
