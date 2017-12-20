@{
    ModuleVersion = '0.9.6';
    GUID = 'c35b6b1e-43af-4000-b157-34bc6e79d801';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) 2017 Virtual Engine Limited. All rights reserved.';
    Description = 'The Citrix Storefront DSC resources can automate the deployment and configuration of Citrix Storefront 3.5 (and later). These DSC resources are provided AS IS, and are not supported through any means.'
    PowerShellVersion = '4.0';
    CLRVersion = '4.0';
    DscResourcesToExport = @('SFAuthenticationService', 'SFAuthenticationServiceMethod', 'SFCluster', 'SFFeature',
                                'SFGateway', 'SFStore', 'SFStoreFarm', 'SFStoreWebReceiver', 'SFStoreRegisterGateway', 'SFSimpleDeployment');
    PrivateData = @{
        PSData = @{
            Tags = @('VirtualEngine','Citrix','Storefront','DSC');
            LicenseUri = 'https://github.com/VirtualEngine/Storefront/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/Storefront';
            IconUri = 'https://raw.githubusercontent.com/VirtualEngine/Storefront/master/CitrixReceiver.png';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
