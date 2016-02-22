<# SFAuthenticationServiceMethod\Resources.psd1 #>
ConvertFrom-StringData @'
    ResourcePropertyMismatch       = Expected authentication method property '{0}' to be '{1}', actual '{2}'.
    AddingAuthenticationMethod     = Adding Citrix Storefront authentication method '{0}'.
    RemovingAuthenticationMethod   = Removing Citrix Storefront authentication methods '{0}'.
    ResourceInDesiredState         = Citrix Storefront authentication methods '{0}' are in the desired state.
    ResourceNotInDesiredState      = Citrix Storefront authentication methods '{0}' are NOT in the desired state.

    DefaultPropertyMissingWarning  = Default property '{0}' value '{1}' is missing. Ensure this is expected behaviour.

    MethodsIncludeAndExcludeError  = The '{0}' and '{1}' and/or '{2}' parameters conflict. The '{0}' parameter should not be used in any combination with the '{1}' and '{2}' parameters.
    MethodsIsNullError             = The AuthenticationMethods parameter value is null. The '{0}' parameter must be provided if neither '{1}' nor '{2}' is provided.
    MethodsIsEmptyError            = The AuthenticationMethods parameter is empty.  At least one authentication method must be provided.
    IncludeAndExcludeConflictError = The authentication method '{0}' is included in both '{1}' and '{2}' parameter values. The same method must not be included in both '{1}' and '{2}' parameter values.
    IncludeAndExcludeAreEmptyError = The '{0}' and '{1}' parameters are either both null or empty.  At least one method must be specified in one of these parameters.
'@
