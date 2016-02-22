Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

$immutableProperties = @( # Properties that cannot be changed after creation
);

$mutableProperties = @( # Properties that can be successfully updated
    'LogonType',
    'SmartCardFallbackLogonType',
    'CallbackUrl',
    'SessionReliability',
    'RequestTicketTwoStas',
    'StasUseLoadBalancing',
    'StasBypassDuration',
    'SubnetIPAddress',
    'SecureTicketAuthorityUrls'
);

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## The NetScaler gateway display name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## The NetScaler gateway Url
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Url,

        ## The login type required and supported by the Gateway
        [Parameter(Mandatory)] [ValidateSet('UsedForHDXOnly','Domain','RSA','DomainAndRSA','SMS','GatewayKnows','SmartCard','None')]
        [System.String] $LogonType,

        ## The login type to use when SmartCard fails
        [Parameter()] [ValidateSet('UsedForHDXOnly','Domain','RSA','DomainAndRSA','SMS','GatewayKnows','SmartCard','None')]
        [System.String] $SmartCardFallbackLogonType,

        ## The NetScaler gateway authentication NetScaler call-back Url
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $CallbackUrl,

        ## Enable session reliability
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $SessionReliability,

        ## Request STA tickets from two STA servers (Requires two STA servers)
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $RequestTicketTwoSTAs,

        ## IP address
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $SubnetIPAddress,

        ## Secure Ticket Authority server Urls
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $SecureTicketAuthorityUrls,

        ## Load balance between the configured STA servers (requires two or more STA servers)
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $StasUseLoadBalancing,

        ## Time before retrying a failed STA server (seconds)
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $StasBypassDuration,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ImportSFModule -Name 'Citrix.StoreFront.Roaming';
        $gateway = Get-STFRoamingGateway -Name $Name;
        $targetResource = @{
            Name = $Name;
            Url = $gateway.Location;
            LogonType = $gateway.Logon;
            SmartCardFallbackLogonType = $gateway.SmartCardFallback;
            CallbackUrl = $gateway.CallbackUrl;
            SessionReliability = $gateway.SessionReliability;
            RequestTicketTwoStas = $gateway.RequestTicketTwoStas;
            StasUseLoadBalancing = $gateway.StasUseLoadBalancing;
            StasBypassDuration = $gateway.StasBypassDuration.TotalSeconds;
            SubnetIPAddress = $gateway.IpAddress;
            SecureTicketAuthorityUrls = @($gateway.SecureTicketAuthorityUrls.AbsoluteUri);
            Ensure = if ($gateway) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## The NetScaler gateway display name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## The NetScaler gateway Url
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Url,

        ## The login type required and supported by the Gateway
        [Parameter(Mandatory)] [ValidateSet('UsedForHDXOnly','Domain','RSA','DomainAndRSA','SMS','GatewayKnows','SmartCard','None')]
        [System.String] $LogonType,

        ## The login type to use when SmartCard fails
        [Parameter()] [ValidateSet('UsedForHDXOnly','Domain','RSA','DomainAndRSA','SMS','GatewayKnows','SmartCard','None')]
        [System.String] $SmartCardFallbackLogonType,

        ## The NetScaler gateway authentication NetScaler call-back Url
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $CallbackUrl,

        ## Enable session reliability
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $SessionReliability,

        ## Request STA tickets from two STA servers (Requires two STA servers)
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $RequestTicketTwoSTAs,

        ## IP address
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $SubnetIPAddress,

        ## Secure Ticket Authority server Urls
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $SecureTicketAuthorityUrls,

        ## Load balance between the configured STA servers (requires two or more STA servers)
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $StasUseLoadBalancing,

        ## Time before retrying a failed STA server (seconds)
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $StasBypassDuration,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        $targetResource = Get-TargetResource @PSBoundParameters;
        $inDesiredState = $true;

        if ($Ensure -ne $targetResource.Ensure) {
            Write-Verbose -Message ($localizedData.ResourcePropertyMismatch -f 'Ensure', $Ensure, $targetResource.Ensure);
            $inDesiredState = $false;
        }

        ## Only check all remaing properties if we're setting
        if ($Ensure -eq 'Present') {

            ## Throw if we have immutable properties
            foreach ($property in $immutableProperties) {
                if ($PSBoundParameters.ContainsKey($property)) {
                    $propertyValue = (Get-Variable -Name $property).Value;
                    if ($targetResource.$property -ne $propertyValue) {
                        $errorMessage = $localizedData.CannotUpdatePropertyError -f $property;
                        ThrowInvalidOperationException -ErrorId 'ImmutableProperty' -ErrorMessage $errorMessage;
                    }  
                } #end if is PSBoundParameter
            } #end foreach immutable property

            foreach ($property in $mutableProperties) {
                if ($PSBoundParameters.ContainsKey($property)) {
                    
                    $propertyValue = (Get-Variable -Name $property).Value;
                    if ($propertyValue -is [System.String[]]) {
                        ## We have to treat string[] differently
                        if (-not (TestStringArrayEqual -Expected $propertyValue -Actual $targetResource.$property)) {
                            $message = $localizedData.ResourcePropertyMismatch -f $property, ($propertyValue -join ','), ($targetResource.$property -join ',');
                            Write-Verbose -Message $message;
                            $inDesiredState = $false;
                        }
                    } #end if string[]
                    else {
                        if ($targetResource.$property -ne $propertyValue) {
                            $message = $localizedData.ResourcePropertyMismatch -f $property, $propertyValue, $targetResource.$property;
                            Write-Verbose -Message $message;
                            $inDesiredState = $false;
                        }
                    } #end if not string[]
                    
                } #end if is PSBoundParameter
            } #end foreach property
        } #end if ensure is present

        if ($inDesiredState) {
            Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $Name);
        }
        else {
            Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $Name);
        }
        return $inDesiredState;
    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        ## The NetScaler gateway display name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## The NetScaler gateway Url
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Url,

        ## The login type required and supported by the Gateway
        [Parameter(Mandatory)] [ValidateSet('UsedForHDXOnly','Domain','RSA','DomainAndRSA','SMS','GatewayKnows','SmartCard','None')]
        [System.String] $LogonType,

        ## The login type to use when SmartCard fails
        [Parameter()] [ValidateSet('UsedForHDXOnly','Domain','RSA','DomainAndRSA','SMS','GatewayKnows','SmartCard','None')]
        [System.String] $SmartCardFallbackLogonType,

        ## The NetScaler gateway authentication NetScaler call-back Url
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $CallbackUrl,

        ## Enable session reliability
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $SessionReliability,

        ## Request STA tickets from two STA servers (Requires two STA servers)
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $RequestTicketTwoSTAs,

        ## IP address
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $SubnetIPAddress,

        ## Secure Ticket Authority server Urls
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $SecureTicketAuthorityUrls,

        ## Load balance between the configured STA servers (requires two or more STA servers)
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $StasUseLoadBalancing,

        ## Time before retrying a failed STA server (seconds)
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $StasBypassDuration,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ImportSFModule -Name 'Citrix.Storefront.Roaming';
        $gateway = Get-STFRoamingGateway -Name $Name;
        
        if ($Ensure -eq 'Absent') {
            if ($gateway) {
                ## Gateway exists, removing
                Write-Verbose -Message ($localizedData.RemovingGateway -f $Name);
                [ref] $null = Remove-STFRoamingGateway -Name $Name -Confirm:$false;
            }
        }
        elseif ($Ensure -eq 'Present') {

            if (-not $gateway) {
                $stfRoamingGatewayParams = @{
                    Name= $Name;
                    LogonType = $LogonType;
                    GatewayUrl = $Url;
                }

                Write-Verbose -Message ($localizedData.AddingGateway -f $Name);
                [ref] $null = Add-STFRoamingGateway @stfRoamingGatewayParams;
                $gateway = Get-STFRoamingGateway -Name $Name;
            }
            
            $stfRoamingGatewayParams = @{};
            foreach ($property in $mutableProperties) {
                if ($PSBoundParameters.ContainsKey($property)) {
                    $propertyValue = (Get-Variable -Name $property).Value;
                    if ($propertyValue -is [System.String[]]) {
                        $message = $localizedData.UpdatingResourceProperty -f $property, ($propertyValue -join ',');
                    }
                    else {
                        $message = $localizedData.UpdatingResourceProperty -f $property, $propertyValue;
                    }
                    Write-Verbose -Message $message;
                    $stfRoamingGatewayParams[$property] = $propertyValue;
                }
            } #end foreach property

            Write-Verbose -Message ($localizedData.UpdatingGateway -f $Name);
            [ref] $null = Set-STFRoamingGateway -Gateway $gateway -GatewayUrl $Url @stfRoamingGatewayParams -Confirm:$false;
        }
    } #end process
} #end function Set-TargetResource
