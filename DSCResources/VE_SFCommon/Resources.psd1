<# SFCommon\Resources.psd1 #>
ConvertFrom-StringData @'
    StorefrontSDKNotFoundError                  = Citrix Storefront Powershell SDK/Snap-in was not found.
    InvalidStorefrontStoreError                 = Citrix Storefront store '{0}' was not found.
    InvalidStorefrontAuthenticationServiceError = Citrix Storefront authentication service '{0}' was not found.

    RemovingDuplicateEntry  = Removing duplicate '{0}' entry.
    StartingProcess         = Starting process '{0}' with arguments '{1}'.
    StartingProcessAs       = Starting process with user credential '{0}'.
    ProcessLaunched         = Process Id '{0}' launched.
    WaitingForProcessToExit = Waiting for process Id '{0}' to exit..
    ProcessExited           = Process Id '{0}' exited with code '{1}'.
'@
