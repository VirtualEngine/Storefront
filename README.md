Included Resources
==================
* SFCluster
* 

SFCluster
===========
Creates a Citrix Storefront group/cluster.
###Syntax
```
SFCluster [string]
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
* DeliveryGroup: The Citrix XenDesktop 7.x delivery group name to assign the access policy.
* AccessType: The access policy filter type.
* Enabled: Whether the access policy is enabled. If not specified, it defaults to True.
* AllowRestart: Whether users are permitted to restart desktop group machines. If not specified, it defaults to True.
* Name: Name of the access policy. If not specified, it defaults to DesktopGroup_Direct or DesktopGroup_AG.
* Description: Custom description assigned to the access policy rule.
* Protocol: Permitted protocols. If not specified, it defaults to both HDX and RDP.
* IncludeUsers: List of associated Active Directory user and groups assigned to the access policy.
* ExcludeUsers: List of associated Active Directory user and groups excluded from the access policy.
* Ensure: Whether the role is to be installed or not. Supported values are Present or Absent. If not specified, it defaults to Present.
* Credential: Specifies optional credential of a user which has permissions to access the source media and/or install/uninstall the specified role. __This property is required for Powershell 4.0.__

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
