<# SFStore\Resources.psd1 #>
ConvertFrom-StringData @'
    ResourcePropertyMismatch    = Expected store property '{0}' to be '{1}', actual '{2}'.
    AddingStore                 = Adding Citrix Storefront store '{0}'.
    UpdatingStoreAuthentication = Updating Citrix Storefront store authentication '{0}'.
    RemovingStore               = Removing Citrix Storefront store '{0}'.
    ResourceInDesiredState      = Citrix Storefront store '{0}' is in the desired state.
    ResourceNotInDesiredState   = Citrix Storefront store '{0}' is NOT in the desired state.
    CannotUpdatePropertyError   = Cannot update property '{0}'.
'@
