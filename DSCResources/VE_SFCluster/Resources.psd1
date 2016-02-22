<# SFCluster\Resources.psd1 #>
ConvertFrom-StringData @'
    StorefrontSDKNotFoundError   = Citrix Storefront Powershell SDK/Snap-in was not found.
    ClusterPropertyMismatch      = Expected cluster property '{0}' to be '{1}', actual '{2}'.
    AddingStorefrontCluster      = Adding Citrix Storefront cluster '{0}'.
    RemovingStorefrontCluster    = Removing Citrix Storefront cluster '{0}'.
    UpdatingStorefrontClusterUrl = Updating Citrix Storefront cluster Url '{0}'.
    ResourceInDesiredState       = Citrix Storefront cluster '{0}' is in the desired state.
    ResourceNotInDesiredState    = Citrix Storefront cluster '{0}' is NOT in the desired state.
'@
