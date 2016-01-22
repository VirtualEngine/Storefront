$Global:DSCModuleName      = 'Storefront';
$Global:DSCResourceName    = 'VE_SFCommon';

#region HEADER
if ( (-not (Test-Path -Path '.\DSCResource.Tests\')) -or (-not (Test-Path -Path '.\DSCResource.Tests\TestHelper.psm1')) ) {
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git');
}
else {
    & git @('-C',(Join-Path -Path (Get-Location) -ChildPath '\DSCResource.Tests\'),'pull');
}
Import-Module .\DSCResource.Tests\TestHelper.psm1 -Force;
$TestEnvironment = Initialize-TestEnvironment -DSCModuleName $Global:DSCModuleName -DSCResourceName $Global:DSCResourceName -TestType Unit;
#endregion

# Begin Testing
try {

    #region Pester Tests

    InModuleScope $Global:DSCResourceName {

        Describe "$($global:DSCResourceName)\Get-TargetResource" {

        } #end describe Get-TargetResource

    } #end InModuleScope $DSCResourceName
    #endregion
}
finally {
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment;
    #endregion
}
