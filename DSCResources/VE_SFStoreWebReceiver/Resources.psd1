<# SFStoreWebReceiver\Resources.psd1 #>
ConvertFrom-StringData @'
    ResourcePropertyMismatch    = Expected store farm property '{0}' to be '{1}', actual '{2}'.
    UpdatingResourceProperty    = Updating store farm '{0}' property to '{1}'.
    AddingStoreFarm             = Adding Citrix Storefront store farm '{0}'.
    UpdatingStoreFarm           = Updating Citrx Storefront store farm '{0}'.
    RemovingStoreFarm           = Removing Citrix Storefront store farm '{0}'.
    ResourceInDesiredState      = Citrix Storefront store farm '{0}' is in the desired state.
    ResourceNotInDesiredState   = Citrix Storefront store farm '{0}' is NOT in the desired state.
    CannotUpdatePropertyError   = Cannot update property '{0}'.
'@
