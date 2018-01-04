# Storefront #

## Included Resources ##

* SFSimpleDeployment
* SFAuthenticationService
* SFAuthenticationServiceMethod
* SFCluster
* SFFeature
* SFGateway
* SFStore
* SFStoreFarm
* SFStoreWebReceiver
* SFStoreRegisterGateway

## SFSimpleDeployment ##

Composite resource to deploy a simple Storefront configuration

### Syntax ###

```
SFSimpleDeployment [string] #ResourceName
{
    BaseUrl = [String]
    FarmName = [String]
    FarmType = [String] { XenApp | XenDesktop | VDIinaBox }
    Servers = [String[]]
    [ StoreVirtualPath = [String] ]
    [ AuthenticationVirtualPath = [String] ]
    [ Transport = [String] ] { HTTP | HTTPS }
    [ ServicePort = [UInt32] ]
}
```

### Properties ###

* **BaseUrl**: Storefront cluster/group base url, i.e. 'https://storefront.lab.local/'.
* **FarmName**: The name of the Citrix XenDesktop 7.x Site or XenApp 6.5 farm to add to the Storefront group.
* **FarmType**: The farm type.
* **Servers**: The Citrix XenDesktop site delivery controller(s) or XenApp zone collector(s) to connect to.
* **StoreVirtualPath**: The Citrix Storefront store virtual path.
  * If not specified, it defaults to '/Citrix/Store'.
* **AuthenticationVirtualPath**: The Citrix Storefront authentication service virtual path.
  * If not specified, it defaults to '/Citrix/Authentication'.
* **Transport**: The Citrix XenDesktop/XenApp XML service transport protocol.
  * If not specified, it defaults to HTTP.
* **ServicePort**: The Citrix XenDesktop/XenApp XML service TCP port.
  * If not specified, it defaults to 80 for HTTP.

## SFAuthenticationService ##

Adds an authentication service to a Citrix Storefront group/cluster.

### Syntax ###

```
SFAuthenticationService [string] #ResourceName
{
    VirtualPath = [string]
    [ SiteId = [UInt64] ]
    [ FriendlyName = [string] ]
    [ Ensure = [string] { Absent | Present } ]
}
```

### Properties ###

* **VirtualPath**: The Citrix Storefront authentication service virtual path.
* **SiteId**: Citrix Storefront site id.
  * If not specified, it defaults to '1'.
* **FriendlyName**: The friendly name of the Citrix Storefront authentication service.
* **Ensure**: Whether the Storefront authentication service should be added or removed.

## SFAuthenticationServiceMethod ##

Configures authentication methods available on an existing Citrix StoreFront store.

### Syntax ###

```
SFAuthenticationServiceMethod [string] #ResourceName
{
    VirtualPath = [string]
    [ AuthenticationMethods = [string[]] { Certificate | CitrixAGBasic | CitrixFederation | ExplicitForms | HttpBasic | IntegratedWindows } ]
    [ IncludeAuthenticationMethods = [string[]] { Certificate | CitrixAGBasic | CitrixFederation | ExplicitForms | Http | Basic | IntegratedWindows } ]
    [ ExcludeAuthenticationMethods = [string[]] { Certificate | CitrixAGBasic | CitrixFederation | ExplicitForms | Http | Basic | IntegratedWindows } ]
    [ Ensure = [string] { Absent | Present } ]
}
```

### Properties ###

* **VirtualPath**: The Citrix Storefront authentication service virtual path.
* **AuthenticationMethods**: Explicit authentication methods be made available.
* **IncludeAuthenticationMethods**: Authentication methods to be added, existing authentication methods will not be removed.
* **ExcludeAuthenticationMethods**: Authentication methods to be removed, existing authentication methods will not be removed.
* **Ensure**: Whether the Storefront authentication service method should be added or removed.

## SFCluster ##

Creates a Citrix Storefront group/cluster.

### Syntax ###

```
SFCluster [String] #ResourceName
{
    BaseUrl = [string]
    [ SiteId = [UInt64] ]
    [ Ensure = [string] { Absent | Present } ]
}
```

### Properties ###

* **BaseUrl**: Storefront cluster/group base url, i.e. 'https://storefront.lab.local/'.
* **SiteId**: Citrix Storefront site id.
  * If not specified, it defaults to '1'.
* **Ensure**: Whether the Storefront group/cluster is to be installed or not. Supported values are Present or Absent. If not specified, it defaults to Present.

## SFFeature ##

Installs Citrix StoreFront.

### Syntax ###

```
SFFeature [String] #ResourceName
{
    Path = [string]
    [ DestinationPath = [string] ]
    [ WindowsClientPath = [string] ]
    [ MacClientPath = [string] ]
    [ Credential = [PSCredential] ]
    [ Ensure = [string]{ Absent | Present } ]
}
```

### Properties ###

* **Path**: Path to the Citrix Storefront installation executable.
* **DestinationPath**: Local path to install Citrix Storefront into to.
  * If not specified, Citrix Storefront is installed in the default location.
* **WindowsClientPath**: Copies Receiver for Windows installation file specified to the appropriate location in your StoreFront deployment.
* **WindowsClientPath**: Copies Receiver for Mac installation file specified to the appropriate location in your StoreFront deployment.
* **Credential**: Specifies optional credential of a user which has permissions to access the source installation file.
* **Ensure**: Whether the role is to be installed or not.
  * If not specified, it defaults to Present.

### Configuration ###

```
Configuration SFFeatureExample {
    Import-DscResource -ModuleName Storefront
    SFFeature 'InstallStoreFront' {
        Path = 'C:\Sources\CitrixStoreFront-x64.exe'
        Ensure = 'Present'
    }
}
```

## SFGateway ##

Adds a NetScaler Gateway to the Citrix StoreFront group/cluster.

### Syntax ###

```
SFGateway [String] #ResourceName
{
    Name = [string]
    Url = [string]
    LogonType = [string] { Domain | DomainAndRSA | GatewayKnows | None | RSA | SmartCard | SMS | UsedForHDXOnly }
    [ CallbackUrl = [string] ]
    [ RequestTicketTwoSTAs = [bool] ]
    [ SecureTicketAuthorityUrls = [string[]] ]
    [ SessionReliability = [bool] ]
    [ SmartCardFallbackLogonType = [string] { Domain | DomainAndRSA | GatewayKnows | None | RSA | SmartCard | SMS | UsedForHDXOnly } ]
    [ StasBypassDuration = [UInt32] ]
    [ StasUseLoadBalancing = [bool] ]
    [ SubnetIPAddress = [string] ]
    [ Ensure = [string] { Absent | Present } ]
}
```

### Properties ###

* **Name**: NetScaler gateway display name.
* **Url**: NetScaler gateway external Url.
* **LogonType**: Login type required and supported by the Gateway.
  * Valid values are: UsedForHDXOnly, Domain, RSA, DomainAndRSA, SMS, GatewayKnows, SmartCard, None.
* **CallbackUrl**: NetScaler gateway authentication NetScaler call-back Url.
   * The 'CallbackUrl' parameter has to include '/CitrixAuthService/AuthService.asmx', for example 'http://callback.domain.net/CitrixAuthService/AuthService.asmx'.
* **RequestTicketTwoSTAs**: Request STA tickets from two STA servers (requires two STA servers).
* **SecureTicketAuthorityUrls**: Secure Ticket Authority server Urls.
  * The 'SecureTicketAuthorityUrls' parameter should include '/scripts/ctxsta.dll', for example 'http://sta.domain.net/scripts/ctxsta.dll'.
* **SessionReliability**: Enable session reliability.
* **SmartCardFallbackLogonType**: Login type to use when SmartCard fails.
  * Valid values are: UsedForHDXOnly, Domain, RSA, DomainAndRSA, SMS, GatewayKnows, SmartCard, None.
* **StasBypassDuration**: Time before retrying a failed STA server (seconds).
* **StasUseLoadBalancing**: Load balance between the configured STA servers (requires two or more STA servers).
* **SubnetIPAddress**: NetScaler subnet IP address.
* **Ensure**: Whether the role is to be installed or not.
  * If not specified, it defaults to Present.

## SFStore ##

Adds a store to the Citrix StoreFront group/cluster.

### Syntax ###

```
SFStore [String] #ResourceName
{
    VirtualPath = [string]
    AuthenticationServiceVirtualPath = [string]
    [ SiteId = [UInt64] ]
    [ FriendlyName = [string] ]
    [ Ensure = [string] { Absent | Present } ]
}
```

### Properties ###

* **VirtualPath**: Citrix Storefront store virtual path, e.g. '/Citrix/Store'.
* **AuthenticationServiceVirtualPath**: Citrix Storefront store's authentication service virtual path.
* **SiteId**: Citrix Storefront store site id.
  * If not specified, it defaults to '1'.
* **FriendlyName**: Citrix Storefront store friendly name.
* **Ensure**: Whether the Citrix Storefront store should be added or removed.
  * If not specified, it defaults to Present.

## SFStoreFarm ##

Adds a XenApp/XenDesktop farm/site to an existing Citrix StoreFront store.

### Syntax ###

```
SFStoreFarm [String] #ResourceName
{
    StoreVirtualPath = [string]
    FarmName = [string]
    FarmType = [string] { AppController | VDIinaBox | XenApp | XenDesktop }
    Servers = [string[]]
    [ AllFailedBypassDuration = [UInt32] ]
    [ BypassDuration = [UInt32] ]
    [ LoadBalance = [bool] ]
    [ MaxFailedServersPerRequest = [UInt32] ]
    [ RadeTicketTimeToLive = [UInt32] ]
    [ ServicePort = [UInt32] ]
    [ SSLRelayServicePort = [UInt32] ]
    [ TicketTimeToLive = [UInt32] ]
    [ TransportType = [string] { HTTP | HTTPS | SSL } ]
    [ Ensure = [string] { Absent | Present } ]
}
```

### Properties ###

* **StoreVirtualPath**: Store virtual directory to add the farm to, e.g. '/Citrix/Store'.
* **FarmName**: Citrix XenDesktop/XenApp farm (display) name.
* **FarmType**: Citrix XenDesktop/XenApp farm type.
  * Valid values are: XenApp, XenDesktop, AppController, VDIinaBox.
* **Servers**: The Citrix XenDesktop site delivery controller(s) or XenApp zone collector(s) to connect to.
* **AllFailedBypassDuration**: Period of time to skip all xml service requests should all servers fail to respond.
* **BypassDuration**: Period of time to skip a server when is fails to respond.
* **LoadBalance**: Round robin load balance the xml service servers.
* **MaxFailedServersPerRequest**: Maximum number of servers within a single farm that can fail before aborting a request.
* **RadeTicketTimeToLive**: Period of time a RADE launch ticket is valid once requested on pre 7.0 XenApp and XenDesktop farms.
* **ServicePort**: Xml service communication port.
  * If not specified, defaults to 443.
* **SSLRelayServicePort**: Xml service communication port.
  * If not specified, defaults to 443.
* **TicketTimeToLive**: Period of time an ICA launch ticket is valid once requested on pre 7.0 XenApp and XenDesktop farms.
* **TransportType**: Xml service transport type.
  * Valid values are: HTTP, HTTPS, SSL.
* **Ensure**: Whether the Citrix Storefront farm should be added or removed.
  * If not specified, it defaults to Present.

## SFStoreWebReceiver ##

Adds a Web Receiver site to an existing Citrix StoreFront store.

### Syntax ###

```
SFStoreWebReceiver [String] #ResourceName
{
    StoreVirtualPath = [string]
    [ VirtualPath = [string] ]
    [ SiteId = [UInt64] ]
    [ ClassicReceiver = [bool] ]
    [ Ensure = [string] { Absent | Present } ]
}
```

### Properties ###

* **StoreVirtualPath**: Store virtual directory to add Receiver for Web, e.g. '/Citrix/Store'.
* **VirtualPath**: Receiver for Web virtual path, e.g. '/Citrix/StoreWeb'.
  * If not specified, it defaults to (StoreVirtualPath)Web.
* **SiteId**: Citrix Storefront site id.
  * If not specified, it defaults to '1'.
* **ClassicReceiver**: Enable the classic (green bubble) Receiver for Web experience.
* **Ensure**: Whether the Citrix Storefront Receiver for Web should be added or removed.
  * If not specified, it defaults to Present.

## SFStoreRegisterGateway ##

Register a Netscaler Gateway with an existing Citrix StoreFront store for use when users access StoreFront from the internet.

### Syntax ###

```
SFStoreRegisterGateway [String] #ResourceName
{
    StoreVirtualPath = [string]
    Gateway = [string]
    [ SiteId = [UInt16] ]
    [ DefaultGateway = [bool] ]
    [ UseFullVpn = [bool] ]
    [ Ensure = [string] { Absent | Present } ]
}
```

### Properties ###

* **StoreVirtualPath**: Store virtual directory to register Netscaler Gateway with.
* **Gateway**: Netscaler Gateway name to register.
* **SiteId**: Citrix Storefront site id.
  * If not specified, it defaults to '1'.
* **DefaultGateway**: Use this Gateway as the default if more than one is defined ?
  * If not specified, it defaults to '$true'.
* **UseFullVpn**: Use full VPN access when accessing the Store through this Gateway ?
  * If not specified, it defaults to '$false'.
* **Ensure**: Whether the Netscaler Gateway should be registered or unregistered from the store.
  * If not specified, it defaults to Present.
