Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Path to Storefront installation executable
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        
        ## Installation directory path
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,
        
        ## Path to Windows Citrix Receiver .exe file
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $WindowsClientPath,
        
        ## Path to Mac Citrix Receiver .dmg file
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $MacClientPath,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',
        
        [Parameter()] [AllowNull()]
        [System.Management.Automation.PSCredential] $Credential
    )
    process {
        $sfRole = GetSFRole;
        $targetResource = @{
            Path = $Path;
            Ensure = if (TestSFRole) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Path to Storefront installation executable
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        
        ## Installation directory path
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,
        
        ## Path to Windows Citrix Receiver .exe file
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $WindowsClientPath,
        
        ## Path to Mac Citrix Receiver .dmg file
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $MacClientPath,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',
        
        [Parameter()] [AllowNull()]
        [System.Management.Automation.PSCredential] $Credential
    )
    process {
        
        $targetResource = Get-TargetResource @PSBoundParameters;
        $inDesiredState = ($Ensure -eq $targetResource.Ensure);
        if ($inDesiredState) {
            Write-Verbose ($LocalizedData.ResourceInDesiredState -f $Path);
            return $true;
        }
        else {
            Write-Verbose ($LocalizedData.ResourceNotInDesiredState -f $Path);
            return $false;
        }
        
    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        ## Path to Storefront installation executable
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        
        ## Installation directory path
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,
        
        ## Path to Windows Citrix Receiver .exe file
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $WindowsClientPath,
        
        ## Path to Mac Citrix Receiver .dmg file
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $MacClientPath,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',
        
        [Parameter()] [AllowNull()]
        [System.Management.Automation.PSCredential] $Credential
    )
    begin {
        if (-not (Test-Path -Path $Path -PathType Leaf)) {
            throw ($localizedData.InvalidSourcePathError -f $Path);
        }
    }
    process {
        $startWaitProcessParams = @{
            Credential = $Credential;
        }
        
        if ($Ensure -eq 'Present') {
            $installFileItem = Get-Item -Path $Path;
            Write-Verbose ($LocalizedData.InstallingStorefront -f $installFileItem.Name);
            $startWaitProcessParams['FilePath'] = $installFileItem.FullName;
            $startWaitProcessParams['ArgumentList'] = ResolveSFSetupArguments @PSBoundParameters;
        }
        elseif ($Ensure -eq 'Absent') {
            $uninstallPath = ResolveSFSetupArguments @PSBoundParameters;
            $uninstallFileItem = Get-Item -Path $uninstallPath;
            $startWaitProcessParams['FilePath'] = $uninstallPath;
            Write-Verbose ($LocalizedData.UninstallingStorefront -f $uninstallFileItem.Name);
            $startWaitProcessParams['ArgumentList'] = @('-silent');
        }
        
        $exitCode = StartWaitProcess @startWaitProcessParams;
        # Check for reboot
        if ($exitCode -eq 3010) {
            $global:DSCMachineStatus = 1;
        }
        
    } #end process
} #end function Set-TargetResource

#region PrivateFunctions

function TestSFRole {
    <#
    .SYNOPSIS
        Tests whether a Citrix Storefront role is installed.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ( )
    process {
        if (GetSFRole) {
            return $true;
        }
        return $false;
    } #end process
} #end function TestSFRole

function GetSFRole {
    <#
    .SYNOPSIS
        Returns installed Citrix Storefront role.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param ( )
    process {
        $installedProducts = Get-ItemProperty 'HKLM:\SOFTWARE\Classes\Installer\Products\*' -ErrorAction SilentlyContinue |
            Where-Object { $_.ProductName -like '*Citrix*' -and $_.ProductName -notlike '*snap-in' } |
                Select-Object -ExpandProperty ProductName;
        $role = $installedProducts -match 'Citrix Storefront';
        if ([System.String]::IsNullOrEmpty($role)) {
            return $false;   
        }
        else {
            return $role;
        }
    } #end process
} #end functoin GetSFRole

function ResolveSFSetupArguments {
    <#
    .SYNOPSIS
        Resolve the installation arguments for Storefront.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        ## Path to Storefront installation executable
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        
        ## Installation directory path
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,
        
        ## Path to Windows Citrix Receiver .exe file
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $WindowsClientPath,
        
        ## Path to Mac Citrix Receiver .dmg file
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $MacClientPath,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',
        
        [Parameter()] [AllowNull()]
        [System.Management.Automation.PSCredential] $Credential
    )
    process {
        $arguments = New-Object -TypeName System.Collections.ArrayList -ArgumentList @();
        
        if ($Ensure -eq 'Present') {
            
            [ref] $null = $arguments.Add('-silent');
            if ($PSBoundParameters.ContainsKey('DestinationPath')) {
                $arguments.AddRange(@('-INSTALLDIR', '"$DestinationPath"')); 
            }
            if ($PSBoundParameters.ContainsKey('WindowsClientPath')) {
                $arguments.AddRange(@('-WINDOWS_CLIENT', "`"$WindowsClientPath`"")); 
            }
            if ($PSBoundParameters.ContainsKey('MacClientPath')) {
                $arguments.AddRange(@('-MAC_CLIENT', "`"$MacClientPath`"")); 
            }
            
        } #end if install
        elseif ($Ensure -eq 'Absent') {
            
            $uninstallString = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -eq 'Citrix StoreFront' -and (-not [System.String]::IsNullOrEmpty($_.InstallLocation)) } |
                    Select-Object -ExpandProperty UninstallString;
            [ref] $null = $arguments.Add($uninstallString);
        }
        
        return [System.String]::Join(' ', $arguments.ToArray());
    } #end process
} #end function ResolveXDSetupArguments

#endregion PrivateFunctions
