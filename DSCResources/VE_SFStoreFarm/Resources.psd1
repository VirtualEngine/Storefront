<# SFStoreFarm\Resources.psd1 #>
ConvertFrom-StringData @'
    ResourcePropertyMismatch    = Expected web receiver property '{0}' to be '{1}', actual '{2}'.
    UpdatingResourceProperty    = Updating web receiver '{0}' property to '{1}'.
    AddingWebReceiver           = Adding Citrix Storefront web receiver '{0}'.
    RemovingWebRecevier         = Removing Citrix Storefront web receiver '{0}'.
    ResourceInDesiredState      = Citrix Storefront web receiver '{0}' is in the desired state.
    ResourceNotInDesiredState   = Citrix Storefront web recevier '{0}' is NOT in the desired state.
    CannotUpdatePropertyError   = Cannot update property '{0}'.
'@
