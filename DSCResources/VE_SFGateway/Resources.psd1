<# SFGateway\Resources.psd1 #>
ConvertFrom-StringData @'
    ResourcePropertyMismatch    = Expected gateway property '{0}' to be '{1}', actual '{2}'.
    UpdatingResourceProperty    = Updating gateway '{0}' property to '{1}'.
    AddingGateway               = Adding Citrix Storefront gateway '{0}'.
    UpdatingGateway             = Updating Citrix Storefront gateway '{0}'.
    RemovingGateway             = Removing Citrix Storefront gateway '{0}'.
    ResourceInDesiredState      = Citrix Storefront gateway '{0}' is in the desired state.
    ResourceNotInDesiredState   = Citrix Storefront gateway '{0}' is NOT in the desired state.
    CannotUpdatePropertyError   = Cannot update property '{0}'.
'@
