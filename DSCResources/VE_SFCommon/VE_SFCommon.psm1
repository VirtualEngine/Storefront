Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

#region Private Functions

function ImportSFModule {
<#
    .SYNOPSIS
        Imports a Storefront Powershell module/snapin and throws an error if it's not available.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IsSnapin
    )
    process {
        foreach ($moduleName in $Name) {
            if (-not (TestSFModule -Name $moduleName -IsSnapin:$IsSnapin)) {
                ThrowInvalidProgramException -ErrorId $Name -ErrorMessage $localizedData.StorefrontSDKNotFoundError;
            }
            elseif ($IsSnapin) {
                Add-PSSnapin -Name $moduleName -Verbose:$false;
            }
            else {
                Import-Module -Name $moduleName -Force -Global -Verbose:$false;
            }
        } #end foreach module
    } #end process
} #end function FindModule

function TestSFModule {
<#
    .SYNOPSIS
        Tests whether a Storefront Powershell module/snapin is available/registered.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IsSnapin
    )
    process {
        $isCompliant = $true;
        foreach ($moduleName in $Name) {
            if ($IsSnapin) {
                if (-not (Get-PSSnapin -Name $moduleName -Registered)) {
                    $isCompliant = $false;
                }
            }
            else {
                if (-not (Get-Module -Name $moduleName -ListAvailable)) {
                    $isCompliant = $false;
                }
            }
        } #end foreach module
        return $isCompliant;
    } #end process
} #end TestModule

function RemoveDuplicateArrayMembers {
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Members
    )
    process {
        $destIndex = 0;
        for([int] $sourceIndex = 0 ; $sourceIndex -lt $Members.Count; $sourceIndex++) {
            $matchFound = $false;
            for([int] $matchIndex = 0; $matchIndex -lt $destIndex; $matchIndex++) {
                if($Members[$sourceIndex] -eq $Members[$matchIndex]) {
                    # A duplicate is found. Discard the duplicate.
                    Write-Verbose -Message ($localizedData.RemovingDuplicateEntry -f $Members[$sourceIndex]);
                    $matchFound = $true;
                    continue;
                }
            }

            if(-not $matchFound) {
                $Members[$destIndex++] = $Members[$sourceIndex].ToLowerInvariant();
            }
        }

        # Create the output array.
        $destination = New-Object -TypeName System.String[] -ArgumentList $destIndex;

        # Copy only distinct elements from the original array to the destination array.
        [System.Array]::Copy($Members, $destination, $destIndex);

        return $destination;
    } #end process
} #end function RemoveDuplicateMembers

function TestStringArrayEqual {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Expected,

        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String[]] $Actual
    )
    process {
        $inDesiredState = $true;
        ## Got to compare the arrays contents
        foreach ($value in $Expected) {
            if ($value -notin $Actual) {
                $inDesiredState = $false;
                break;
            }
        }
        if ($null -eq $Actual) {
            ## $Expected cannot be $null so if $Actual is $null..
            $inDesiredState = $false;
        }
        else {
            foreach ($value in $Actual) {
                if ($Expected -notcontains $value) {
                    $inDesiredState = $false;
                    break;
                }
            }
        }
        return $inDesiredState;
    } #end process
} #end function TestArray

function GetStoreFarm {
<#
    .SYNOPSIS
        Returns Storefront farm by virtual path and farm name
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $StoreVirtualPath,

        [Parameter(Mandatory)]
        [System.String] $FarmName,

        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {
        $store = GetStoreService -VirtualPath $StoreVirtualPath -ThrowIfNull;
        return (Get-STFStoreFarm -StoreService $store -FarmName $FarmName -ErrorAction SilentlyContinue);
    } #end process
} #end function GetStoreFarm

function GetWebReceiverService {
<#
    .SYNOPSIS
        Returns Storefront WebReceiver store by virtual path and site Id (if supplied)
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {
        $getSTFWebReceiverServiceParams = @{
            VirtualPath = $VirtualPath;
        }
        if ($PSBoundParameters.ContainsKey('SiteId')) {
            $getSTFWebReceiverServiceParams['SiteId'] = $SiteId;
        }
        return (Get-STFWebReceiverService @getSTFWebReceiverServiceParams);
    } #end process
} #end function GetWebReceiverService

function GetStoreService {
<#
    .SYNOPSIS
        Returns Storefront store by virtual path and site Id (if supplied)
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Store virtual path, e.g. /Citrix/Store
        [Parameter()]
        [System.String] $StoreVirtualPath,

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $ThrowIfNull,

        [Parameter(ValueFromRemainingArguments = $true)]
        $RemainingArguments

    )
    process {
        $getSTFStoreServiceParams = @{
            VirtualPath = $VirtualPath;
        }
        if ($PSBoundParameters.ContainsKey('StoreVirtualPath')) {
            ## Override the VirtualPath with the more explicit StoreVirtualPath
            $getSTFStoreServiceParams['VirtualPath'] = $StoreVirtualPath;
        }
        if ($PSBoundParameters.ContainsKey('SiteId')) {
            $getSTFStoreServiceParams['SiteId'] = $SiteId;
        }
        $store = Get-STFStoreService @getSTFStoreServiceParams;
        if ($ThrowIfNull -and ($null -eq $store)) {
            $errorMessage = $localizedData.InvalidStorefrontStoreError -f $getSTFStoreServiceParams.VirtualPath;
            ThrowOperationCanceledException -ErrorId InvalidStore -ErrorMessage $errorMessage;
        }
        return $store;
    } #end process
} #end function GetStoreService

function GetAuthenticationService {
<#
    .SYNOPSIS
    Returns Storefront authentication service by virtual path and site Id (if supplied)
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        [Parameter()]
        [System.UInt64] $SiteId = 1,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $ThrowIfNull,

        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {
        $getSTFAuthenticationServiceParams = @{
            VirtualPath = $VirtualPath;
        }
        if ($PSBoundParameters.ContainsKey('SiteId')) {
            $getSTFAuthenticationServiceParams['SiteId'] = $SiteId;
        }
        $authenticationService =Get-STFAuthenticationService @getSTFAuthenticationServiceParams;
        if ($ThrowIfNull -and ($null -eq $authenticationService)) {
            $errorMessage = $localizedData.InvalidStorefrontAuthenticationServiceError -f $VirtualPath;
            ThrowOperationCanceledException -ErrorId InvalidAuthenticationService -ErrorMessage $errorMessage;
        }
        return $authenticationService;
    } #end process
} #end function GetAuthenticationService

function GetAuthenticationServiceMethods {
<#
    .SYNOPSIS
    Returns Storefront authentication service methods by virtual path
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {
        $authenticationService = GetAuthenticationService -VirtualPath $VirtualPath -ThrowIfNull;
        $authenticationMethods = Get-STFAuthenticationServiceProtocol -AuthenticationService $authenticationService |
            Where-Object { $_.Enabled -eq $true } |
                Select-Object -ExpandProperty Name;
        return $authenticationMethods;
    } #end process
} #end function GetAuthenticationServiceMethods

function AddInvokeScriptBlockCredentials {
    <#
    .SYNOPSIS
        Adds the required Invoke-Command parameters for loopback processing with CredSSP.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $Hashtable,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential
    )
    process {
        $Hashtable['ComputerName'] = $env:COMPUTERNAME;
        $Hashtable['Credential'] = $Credential;
        $Hashtable['Authentication'] = 'Credssp';
    }
} #end function AddInvokeScriptBlockCredentials

function GetHostname {
    [CmdletBinding()]
    [OutputType([System.String])]
    param ( )
    process {
        $globalIpProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties();
        if ($globalIpProperties.DomainName) {
            return '{0}.{1}' -f $globalIpProperties.HostName, $globalIpProperties.DomainName;
        }
        else {
            return $globalIpProperties.HostName;
        }
    } #end process
} #end function GetHostname

function GetRegistryValue {
    <#
    .SYNOPSIS
        Returns a registry string value.
    .NOTES
        This is an internal function and shouldn't be called from outside.
        This function enables registry calls to be unit tested.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Registry key name/path to query.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('Path')]
        [System.String] $Key,

        # Registry value to return.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name
    )
    process {
        $itemProperty = Get-ItemProperty -Path $Key -Name $Name -ErrorAction SilentlyContinue;
        if ($itemProperty.$Name) {
            return $itemProperty.$Name;
        }
        return '';
    }
} #end function GetRegistryValue

function StartWaitProcess {
    <#
    .SYNOPSIS
        Starts and waits for a process to exit.
    .NOTES
        This is an internal function and shouldn't be called from outside.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Int32])]
    param (
        # Path to process to start.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $FilePath,

        # Arguments (if any) to apply to the process.
        [Parameter()]
        [AllowNull()]
        [System.String[]] $ArgumentList,

        # Credential to start the process as.
        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential] $Credential,

        # Working directory
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $WorkingDirectory = (Split-Path -Path $FilePath -Parent)
    )
    process {
        $startProcessParams = @{
            FilePath = $FilePath;
            WorkingDirectory = $WorkingDirectory;
            NoNewWindow = $true;
            PassThru = $true;
        };
        $displayParams = '<None>';
        if ($ArgumentList) {
            $displayParams = [System.String]::Join(' ', $ArgumentList);
            $startProcessParams['ArgumentList'] = $ArgumentList;
        }
        Write-Verbose ($localizedData.StartingProcess -f $FilePath, $displayParams);
        if ($Credential) {
            Write-Verbose ($localizedData.StartingProcessAs -f $Credential.UserName);
            $startProcessParams['Credential'] = $Credential;
        }
        if ($PSCmdlet.ShouldProcess($FilePath, 'Start Process')) {
            $process = Start-Process @startProcessParams -ErrorAction Stop;
        }
        if ($PSCmdlet.ShouldProcess($FilePath, 'Wait Process')) {
            Write-Verbose ($localizedData.ProcessLaunched -f $process.Id);
            Write-Verbose ($localizedData.WaitingForProcessToExit -f $process.Id);
            $process.WaitForExit();
            $exitCode = [System.Convert]::ToInt32($process.ExitCode);
            Write-Verbose ($localizedData.ProcessExited -f $process.Id, $exitCode);
        }
        return $exitCode;
    } #end process
} #end function StartWaitProcess



function ThrowInvalidArgumentError {
    <#
    .SYNOPSIS
        Throws terminating error of category InvalidArgument with specified errorId and errorMessage.
    #>
    param(
        [Parameter(Mandatory)]
        [System.String] $ErrorId,

        [Parameter(Mandatory)]
        [System.String] $ErrorMessage
    )
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument;
    $exception = New-Object -TypeName 'System.ArgumentException' -ArgumentList $ErrorMessage;
    $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList $exception, $ErrorId, $errorCategory, $null;
    throw $errorRecord;
} #end function ThrowInvalidArgumentError

function ThrowInvalidOperationException {
    <#
    .SYNOPSIS
        Throws terminating error of category InvalidOperation with specified errorId and errorMessage.
    #>
    param(
        [Parameter(Mandatory)]
        [System.String] $ErrorId,

        [Parameter(Mandatory)]
        [System.String] $ErrorMessage
    )
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation;
    $exception = New-Object -TypeName 'System.InvalidOperationException' -ArgumentList $ErrorMessage;
    $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList $exception, $ErrorId, $errorCategory, $null;
    throw $errorRecord;
} #end function ThrowInvalidOperationException

function ThrowInvalidProgramException {
    <#
    .SYNOPSIS
        Throws terminating error of category NotInstalled with specified errorId and errorMessage.
    #>
    param(
        [Parameter(Mandatory)]
        [System.String] $ErrorId,

        [Parameter(Mandatory)]
        [System.String] $ErrorMessage
    )
    $errorCategory = [System.Management.Automation.ErrorCategory]::NotInstalled;
    $exception = New-Object -TypeName 'System.InvalidProgramException' -ArgumentList $ErrorMessage;
    $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList $exception, $ErrorId, $errorCategory, $null;
    throw $errorRecord;
} #end function ThrowInvalidProgramException

function ThrowOperationCanceledException {
    <#
    .SYNOPSIS
        Throws terminating error of category InvalidOperation with specified errorId and errorMessage.
    #>
    param(
        [Parameter(Mandatory)]
        [System.String] $ErrorId,

        [Parameter(Mandatory)]
        [System.String] $ErrorMessage
    )
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation;
    $exception = New-Object -TypeName 'System.OperationCanceledException' -ArgumentList $ErrorMessage;
    $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList $exception, $ErrorId, $errorCategory, $null;
    throw $errorRecord;
} #end function ThrowOperationCanceledException

#endregion Private Functions