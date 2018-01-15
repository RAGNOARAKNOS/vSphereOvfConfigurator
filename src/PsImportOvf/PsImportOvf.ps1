# Notes found at https://divyen.wordpress.com/2012/03/11/importingexporting-ova-in-vsphere-using-vmware-ovf-command-line-tool/
# Notes http://www.vmwarebits.com/content/import-and-export-virtual-machines-command-line-vmwares-ovf-tool#
# https://www.vmware.com/support/developer/PowerCLI/PowerCLI651/html/Import-VApp.html .
# https://kb.vmware.com/s/article/1038709

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

    # Load data from config files
    $creds = Import-Csv $credentialFileLoc;
    $imports = Import-Csv $importFileLoc;

    # Iterate through the config file
    foreach($import in $imports)
    {
        Write-Host "Deploying " $import.DestinationAppName "to" $import.DestinationDcName
        
        # Get the VCSA login
        $credential = $creds | Where-Object { $_.DataCentreName -eq $import.DestinationDcName }

        # Connect to the vcenter
        Write-Host $credential;
        $vcsa = Connect-VIServer `
            -Server $credential.DataCentreAddress `
            -User $credential.Username `
            -Password $credential.Password;

        # Get the target location
        if ($import.DestinationClusterName -ne "") 
        {
            # Deploying to a cluster
            $targetCluster = Get-Cluster -Name $import.DestinationClusterName;

            # Get any (available) host within that cluster
            $targetHost = targetCluster | Get-VMHost | Where-Object { $_.ConnectionState -eq "Connected" } | Get-Random;
        }
        else 
        {
            #Deploying directly to a host
            $targetHost = Get-VMHost -Name $import.DestinationHostName;
        } 

        # Get the target datastore
        $ds = Get-Datastore -Name $import.DestinationDatastore;

        # Determine the appropriate disk provisioning
        if ($import.ThickProvision -eq "Yes") 
        {
            $diskProvision = "EagerZeroedThick";
        }
        else 
        {
            $diskProvision = "Thin";
        }

        # Deploy the vApp
        Import-VApp -Source $import.SourceFullPath `
            -Name $import.DestinationAppName `
            -VMHost $targetHost `
            -Datastore $ds `
            -DiskStorageFormat $diskProvision `
            -Force:$true 

        # Disconnect from VCSA
        Disconnect-VIServer -Server $vcsa -Force; 
    }
}