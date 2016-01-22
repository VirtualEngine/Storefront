Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

$immutableProperties = @( # Properties that cannot be changed after creation
);

$mutableProperties = @( # Properties that can be successfully updated
    'FarmType',
    'BypassDuration',
    'MaxFailedServersPerRequest',
    'SSLRelaryServicePort',
    'RadeTicketTimeToLive',
    'TransportType',
    'AllFailedBypassDuration',
    'LoadBalance',
    'TicketTimeToLive',
    'ServicePort',
    'Servers'
);

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Store virtual directory, i.e. /Citrix/Store
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $StoreVirtualPath,

        ## Farm (display) name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $FarmName,

        ## Farm type
        [Parameter(Mandatory)] [ValidateSet('XenApp','XenDesktop','AppController','VDIinaBox')]
        [System.String] $FarmType,

        ## The hostnames or IP addresses of the xml services
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Servers,

        ## Xml service communication port, defaults to 443
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $ServicePort = 443,

        ## Xml service transport type
        [Parameter()] [ValidateSet('HTTP','HTTPS','SSL')]
        [System.String] $TransportType = 'HTTPS',

        ## Xml service communication port, defaults to 443
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $SSLRelayServicePort,

        ## Round robin load balance the xml service servers
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $LoadBalance = $true,

        ## Period of time to skip all xml service requests should all servers fail to respond
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $AllFailedBypassDuration,

        ## Period of time to skip a server when is fails to respond
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $BypassDuration,

        ## Period of time an ICA launch ticket is valid once requested on pre 7.0 XenApp and XenDesktop farms
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $TicketTimeToLive,

        ## Period of time a RADE launch ticket is valid once requested on pre 7.0 XenApp and XenDesktop farms
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $RadeTicketTimeToLive,

        ## Maximum number of servers within a single farm that can fail before aborting a request
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $MaxFailedServersPerRequest,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ImportSFModule -Name 'Citrix.StoreFront.Stores';
        $farm = GetStoreFarm @PSBoundParameters;
        $targetResource = @{
            StoreVirtualPath = $StoreVirtualPath;
            FarmName = $farm.FarmName;
            FarmType = $farm.FarmType;
            ServicePort = $farm.Port;
            SSLRelaryServicePort = $farm.SSLRelayPort;
            TransportType = $farm.TransportType;
            LoadBalance = $farm.LoadBalance;
            Servers = $farm.Servers;
            AllFailedBypassDuration = $farm.AllFailedBypassDuration;
            BypassDuration = $farm.BypassDuration;
            TicketTimeToLive = $farm.TicketTimeToLive;
            RadeTicketTimeToLive = $farm.RadeTicketTimeToLive;
            MaxFailedServersPerRequest = $farm.MaxFailedServersPerRequest;
            Ensure = if ($farm) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Store virtual directory, i.e. /Citrix/Store
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $StoreVirtualPath,

        ## Farm (display) name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $FarmName,

        ## Farm type
        [Parameter(Mandatory)] [ValidateSet('XenApp','XenDesktop','AppController','VDIinaBox')]
        [System.String] $FarmType,

        ## The hostnames or IP addresses of the xml services
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Servers,

        ## Xml service communication port, defaults to 443
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $ServicePort = 443,

        ## Xml service transport type
        [Parameter()] [ValidateSet('HTTP','HTTPS','SSL')]
        [System.String] $TransportType = 'HTTPS',

        ## Xml service communication port, defaults to 443
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $SSLRelayServicePort,

        ## Round robin load balance the xml service servers
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $LoadBalance = $true,

        ## Period of time to skip all xml service requests should all servers fail to respond
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $AllFailedBypassDuration,

        ## Period of time to skip a server when is fails to respond
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $BypassDuration,

        ## Period of time an ICA launch ticket is valid once requested on pre 7.0 XenApp and XenDesktop farms
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $TicketTimeToLive,

        ## Period of time a RADE launch ticket is valid once requested on pre 7.0 XenApp and XenDesktop farms
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $RadeTicketTimeToLive,

        ## Maximum number of servers within a single farm that can fail before aborting a request
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $MaxFailedServersPerRequest,

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
            Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $FarmName);
        }
        else {
            Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $FarmName);
        }
        return $inDesiredState;
    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        ## Store virtual directory, i.e. /Citrix/Store
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $StoreVirtualPath,

        ## Farm (display) name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $FarmName,

        ## Farm type
        [Parameter(Mandatory)] [ValidateSet('XenApp','XenDesktop','AppController','VDIinaBox')]
        [System.String] $FarmType,

        ## The hostnames or IP addresses of the xml services
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Servers,

        ## Xml service communication port, defaults to 443
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $ServicePort = 443,

        ## Xml service transport type
        [Parameter()] [ValidateSet('HTTP','HTTPS','SSL')]
        [System.String] $TransportType = 'HTTPS',

        ## The SSL Relay port
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $SSLRelayServicePort,

        ## Round robin load balance the xml service servers
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $LoadBalance = $true,

        ## Period of time to skip all xml service requests should all servers fail to respond
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $AllFailedBypassDuration,

        ## Period of time to skip a server when is fails to respond
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $BypassDuration,

        ## Period of time an ICA launch ticket is valid once requested on pre 7.0 XenApp and XenDesktop farms
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $TicketTimeToLive,

        ## Period of time a RADE launch ticket is valid once requested on pre 7.0 XenApp and XenDesktop farms
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $RadeTicketTimeToLive,

        ## Maximum number of servers within a single farm that can fail before aborting a request
        [Parameter()] [ValidateNotNull()]
        [System.UInt32] $MaxFailedServersPerRequest,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ImportSFModule -Name 'Citrix.Storefront.Stores';
        $store = GetStoreService -VirtualPath $StoreVirtualPath -ThrowIfNull;
        $farm = GetStoreFarm -StoreVirtualPath $StoreVirtualPath -FarmName $FarmName;

        if ($Ensure -eq 'Absent') {
            
            if ($farm) {
                ## Farm exists, removing
                Write-Verbose -Message ($localizedData.RemovingStoreFarm -f $FarmName);
                [ref] $null = Remove-STFStoreFarm -StoreService $store -FarmName $FarmName -Confirm:$false;
            }

        }
        elseif ($Ensure -eq 'Present') {
            
            
            if (-not $farm) {
                Write-Verbose -Message ($localizedData.AddStoreFarm -f $FarmName);
                $farm = Add-STFStoreFarm -StoreService $store -FarmName $FarmName -FarmType $FarmType -Servers $Servers -Confirm:$false;
            }

            $setSTFStoreFarmParams = @{
                StoreService = $store;
                FarmName = $FarmName;
            }

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
                    $setSTFStoreFarmParams[$property] = $propertyValue;
                }
            } #end foreach property

            Write-Verbose -Message ($localizedData.UpdatingStoreFarm -f $FarmName);
            [ref] $null = Set-STFStoreFarm @setSTFStoreFarmParams -Confirm:$false;
        
        }
    } #end process
} #end function Set-TargetResource

