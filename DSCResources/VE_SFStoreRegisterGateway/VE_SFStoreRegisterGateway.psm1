$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;

## Import the SFCommon library functions
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'VE_SFCommon') -Force;

## Dot source all (nested) .ps1 files in the folder, excluding Pester tests
Get-ChildItem -Path $moduleRoot -Include *.ps1 -Recurse |
    ForEach-Object {
        Write-Verbose ('Dot sourcing ''{0}''.' -f $_.FullName);
        . $_.FullName;
    }

Export-ModuleMember -Function *-TargetResource;
