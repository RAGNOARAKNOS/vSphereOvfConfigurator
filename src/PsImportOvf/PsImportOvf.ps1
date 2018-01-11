# Notes found at https://divyen.wordpress.com/2012/03/11/importingexporting-ova-in-vsphere-using-vmware-ovf-command-line-tool/
# Notes http://www.vmwarebits.com/content/import-and-export-virtual-machines-command-line-vmwares-ovf-tool#
# https://www.vmware.com/support/developer/PowerCLI/PowerCLI651/html/Import-VApp.html .

function Deploy-Ovfs 
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $credentialFileLoc,

        [Parameter(Mandatory=$true)]
        [string]
        $importFileLoc
    )
    
    $creds = Import-Csv $credentialFileLoc;
    $imports = Import-Csv $importFileLoc;

    foreach($cred in $creds)
    {
        Write-Host $cred.DataCentreName
    }

    foreach($import in $imports)
    {
        Write-Host "Deploying " $import.DestinationAppName "to" $import.DestinationDcName
    
        #Connect-VIServer -Server 
    }
}