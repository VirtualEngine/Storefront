Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function ValidateParameters {
    [CmdletBinding()]
    param (
        ## Citrix Storefront Authentication Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Explicit authentication methods available
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $AuthenticationMethods,

        ## Included authentication methods, other existing methods will not be removed
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $IncludeAuthenticationMethods,

        ## Excluded authentication methods, other existing methods will not be removed
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $ExcludeAuthenticationMethods,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    if ($PSBoundParameters.ContainsKey('AuthenticationMethods')) {
        if ($AuthenticationMethods -notcontains 'CitrixFederation') {
            Write-Warning -Message ($localizedData.DefaultPropertyMissingWarning -f 'AuthenticationMethods', 'CitrixFederation');
        }
        ## Cannot have Explicit and Include
        if($PSBoundParameters.ContainsKey('IncludeAuthenticationMethods') -or $PSBoundParameters.ContainsKey('ExcludeAuthenticationMethods')) {
            $errorMessage = $localizedData.MethodsIncludeAndExcludeError -f 'AuthenticationMethods','IncludeAuthenticationMethods','ExcludeAuthenticationMethods';
            ThrowInvalidArgumentError -ErrorId 'MethodsPlusIncludeOrExcludeConflict' -ErrorMessage $errorMessage;
        }
        if ($AuthenticationMethods.Length -eq 0) {
            $errorMessage = $localizedData.MethodsIsNullError -f 'AuthenticationMethods','IncludeAuthenticationMethods','ExcludeAuthenticationMethods';
            ThrowInvalidArgumentError -ErrorId 'MethodsIsNullError' -ErrorMessage $errorMessage;
        }
    }

    if ($PSBoundParameters.ContainsKey('IncludeAuthenticationMethods')) {
        $IncludeAuthenticationMethods = [System.String[]] @(RemoveDuplicateArrayMembers -Members $IncludeAuthenticationMethods);
    }

    if ($PSBoundParameters.ContainsKey('ExcludeAuthenticationMethods')) {
        $ExcludeAuthenticationMethods = [System.String[]] @(RemoveDuplicateArrayMembers -Members $ExcludeAuthenticationMethods);
    }

    if (($PSBoundParameters.ContainsKey('IncludeAuthenticationMethods')) -and ($PSBoundParameters.ContainsKey('ExcludeAuthenticationMethods'))) {
        if (($IncludeAuthenticationMethods.Length -eq 0) -and ($ExcludeAuthenticationMethods.Length -eq 0)) {
            $errorMessage = $localizedData.IncludeAndExcludeAreEmptyError -f 'IncludeAuthenticationMethods', 'ExcludeAuthenticationMethods';
            ThrowInvalidArgumentError -ErrorId 'EmptyIncludeAndExclude' -ErrorMessage $errorMessage;
        }
        # Both IncludeAuthenticationMethods and ExcludeAuthenticationMethods were provided. Check if they have duplicates.
        foreach ($method in $IncludeAuthenticationMethods) {
            if ($ExcludeAuthenticationMethods -contains $method) {
                $errorMessage = $localizedData.IncludeAndExcludeConflictError -f $method, 'IncludeAuthenticationMethods', 'ExcludeAuthenticationMethods';
                ThrowInvalidArgumentError -ErrorId 'IncludeAndExcludeConflictError' -ErrorMessage $errorMessage;
            }
        }
    }

} #end function ValidateParameters

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Citrix Storefront Authentication Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Explicit authentication methods available
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $AuthenticationMethods,

        ## Included authentication methods, other existing methods will not be removed
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $IncludeAuthenticationMethods,

        ## Excluded authentication methods, other existing methods will not be removed
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $ExcludeAuthenticationMethods,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ImportSFModule -Name Citrix.Storefront.Authentication;
        $authenticationServiceMethods = GetAuthenticationServiceMethods -VirtualPath $VirtualPath;
        $targetResource = @{
            VirtualPath = $VirtualPath;
            AuthenticationMethods = $authenticationServiceMethods;
            Ensure = if ($authenticationServiceMethods) { 'Present' } else { 'Absent' };
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Citrix Storefront Authentication Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Explicit authentication methods available
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $AuthenticationMethods,

        ## Included authentication methods, other existing methods will not be removed
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $IncludeAuthenticationMethods,

        ## Excluded authentication methods, other existing methods will not be removed
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $ExcludeAuthenticationMethods,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ValidateParameters @PSBoundParameters;
        $targetResource = Get-TargetResource @PSBoundParameters;
        $inDesiredState = $true;

        if ($Ensure -ne $targetResource.Ensure) {
            Write-Verbose -Message ($localizedData.ResourcePropertyMismatch -f 'Ensure', $Ensure, $targetResource.Ensure);
            $inDesiredState = $false;
        }

        ## Only check all remaing properties if we're setting
        if ($Ensure -eq 'Present') {
            if ($PSBoundParameters.ContainsKey('AuthenticationMethods')) {
                if (-not (TestStringArrayEqual -Expected $AuthenticationMethods -Actual $targetResource.AuthenticationMethods)) {
                    $authenticationMethodsString = $AuthenticationMethods -join ',';
                    $actualAuthenticationMethodsString = $targetResource.AuthenticationMethods -join ',';
                    Write-Verbose -Message ($localizedData.ResourcePropertyMismatch -f $VirtualPath, $authenticationMethodsString, $actualAuthenticationMethodsString);
                    $inDesiredState = $false;
                }
            }
            if ($PSBoundParameters.ContainsKey('IncludeAuthenticationMethods')) {
                foreach ($method in $IncludeAuthenticationMethods) {
                    if ($targetResource.AuthenticationMethods -notcontains $method) {
                        Write-Verbose -Message ($localizedData.ResourcePropertyMismatch -f 'IncludeAuthenticationMethods', $method, '');
                        $inDesiredState = $false;
                    }
                }
            }
            if ($PSBoundParameters.ContainsKey('ExcludeAuthenticationMethods')) {
                foreach ($method in $ExcludeAuthenticationMethods) {
                    if ($targetResource.AuthenticationMethods -contains $method) {
                        Write-Verbose -Message ($localizedData.ResourcePropertyMismatch -f 'ExcludeAuthenticationMethods', '', $method);
                        $inDesiredState = $false;
                    }
                }
            }
        } #end if ensure is present

        if ($inDesiredState) {
            Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $VirtualPath);
        }
        else {
            Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $VirtualPath);
        }
        return $inDesiredState;
    } #end process
} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    param (
        ## Citrix Storefront Authentication Service IIS Virtual Path
        [Parameter(Mandatory)]
        [System.String] $VirtualPath,

        ## Explicit authentication methods available
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $AuthenticationMethods,

        ## Included authentication methods, other existing methods will not be removed
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $IncludeAuthenticationMethods,

        ## Excluded authentication methods, other existing methods will not be removed
        [Parameter()] [ValidateSet('IntegratedWindows','HttpBasic','ExplicitForms','CitrixFederation','CitrixAGBasic','Certificate')]
        [System.String[]] $ExcludeAuthenticationMethods,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        ValidateParameters @PSBoundParameters;
        ImportSFModule -Name Citrix.Storefront.Authentication;
        $authenticationServiceMethods = GetAuthenticationServiceMethods -VirtualPath $VirtualPath;
        $authenticationService = GetAuthenticationService @PSBoundParameters -ThrowIfNull;

        if ($Ensure -eq 'Absent') {
            if ($authenticationServiceMethods) {
                foreach ($method in $authenticationServiceMethods) {
                    Write-Verbose -Message ($localizedData.RemovingAuthenticationMethod -f $method);
                    [ref] $null = Remove-STFAuthenticationServiceProtocol -AuthenticationService $authenticationService -Name $method;
                }
            }
        }
        elseif ($Ensure -eq 'Present') {
            
            if ($PSBoundParameters.ContainsKey('AuthenticationMethods')) {
                ## Convert explicit methods to include
                $IncludeAuthenticationMethods = $AuthenticationMethods;
                ## Exlcude all current methods that are not specified
                foreach ($method in $authenticationServiceMethods) {
                    if ($IncludeAuthenticationMethods -notcontains $method) {
                        if (-not $ExcludeAuthenticationMethods) {
                            $ExcludeAuthenticationMethods = @();
                        }
                        $ExcludeAuthenticationMethods += $method;
                    }
                }
            }

            foreach ($method in $IncludeAuthenticationMethods) {
                Write-Verbose -Message ($localizedData.AddingAuthenticationMethod -f $method);
                [ref] $null = Add-STFAuthenticationServiceProtocol -AuthenticationService $authenticationService -Name $method;
            }

            foreach ($method in $ExcludeAuthenticationMethods) {
                Write-Verbose -Message ($localizedData.RemovingAuthenticationMethod -f $method);
                [ref] $null = Remove-STFAuthenticationServiceProtocol -AuthenticationService $authenticationService -Name $method -Confirm:$false;
            }
        }
    } #end process
} #end function Set-TargetResource
