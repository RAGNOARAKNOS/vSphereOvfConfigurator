#Some notes http://www.lukaslundell.com/2013/06/modifying-vapp-properties-with-powershell-and-powercli/
# and https://github.com/lamw/vghetto-scripts/blob/master/powershell/VMOvfProperty.ps1
function Set-VmOvfProps  
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $credentialFileLoc, 

        [Parameter(Mandatory=$true)]
        [string]
        $vmOvfPropertiesLoc
    )
    
    #Load data from config files
    $creds = Import-Csv $credentialFileLoc;
    $vmOvfProps = Import-Csv $vmOvfPropertiesLoc;
    
    # Get unique list of DCs
    $vmDcs = $vmOvfProps | Select-Object -ExpandProperty DataCentreName | Get-Unique;
    Write-Host "D"$vmDcs;
    
    # Iterate thru each DC
    foreach($datacentre in $vmDcs)
    {
        # Get connection details for DC
        $connDetails = $creds | Where-Object -Property DataCentreName -eq $datacentre;
        write-host "C"$connDetails;

        #Connect to DC API
        $session = Connect-VIServer `
            -Server $connDetails.DataCentreAddress `
            -User $connDetails.Username `
            -Password $connDetails.Password;

        # Get list of VMs for this DC
        $vms = $vmOvfProps | Where-Object -Property DataCentreName -eq $datacentre | Select-Object -ExpandProperty VmName | Get-Unique;
        Write-Host "V"$vms;

        foreach($vm in $vms)
        {
            # Generate an OVF props hash table for the VM
            Write-Host "Identified VM"$vm;
            $perVmProps = $vmOvfProps | Where-Object -Property VmName -eq $vm;

            Write-Host "P"$perVmProps;
            $ovfTable = @{};

            foreach($ovfProp in $perVmProps)
            {
                $ovfTable.Add($ovfProp.Prop, $ovfProp.Value);
            }

            Write-Host "HK"$ovfTable.Keys;
            Write-Host "HV"$ovfTable.Values;

            #Apply VM props for VMs in that DC
            Set-VmOvfProperty -VM (Get-VM $vm) -ovfChanges $ovfTable;
        }

        # Disconnect from DC Api
        Disconnect-VIServer $session;
    }
}

function Set-VmOvfProperty 
{
    Param(
        # Virtual Machine
        [Parameter(Mandatory=$true)]
        $VM,

        # OVF parameters hash table
        [Parameter(Mandatory=$true)]
        $ovfChanges
    )
    
    # Get the current set of OVF properties
    $VmOvfProperties = $VM.ExtensionData.config.VAppConfig.Property;

    # Create a VMware update spec
    $updateSpec = New-Object VMware.Vim.VirtualMachineConfigSpec;
    $updateSpec.VAppConfig = New-Object VMware.Vim.VmConfigSpec;
    $propertySpec = New-Object VMware.Vim.VAppPropertySpec[]($ovfChanges.Count);

    # generate an empty property list (lazy delete hack...work on this lewis)
    $emptySpec = New-Object VMware.Vim.VAppPropertySpec[](0);

    $updateSpec.VAppConfig.Property = $emptySpec;

    Write-host "Emptying VM properties for " $VM.Name;
    $updateTask = $VM.ExtensionData.ReconfigVM_Task($updateSpec);
    $taskTracker = Get-Task -Id ("Task-$($updateTask.value)");
    $taskTracker | Wait-Task; 
    Write-host "Empty";

    # Generate new OVF properties set
    foreach($ovfProp in $ovfChanges)
    {
        $tmp = New-Object VMware.Vim.VAppPropertySpec;
        $tmp.Operation = "Add";
        $tmp.Info = New-Object VMware.Vim.VAppPropertyInfo;
        $tmp.Info.Key = $ovfProp.Key;
        $tmp.Info.Value = $ovfProp.Value;
        $propertySpec+=($tmp);
    }

    # apply the properties to the update spec
    $updateSpec.VAppConfig.Property = $propertySpec;

    # Execute the update task, and wait for completion
    Write-host "Updating VM properties for " $VM.Name;
    $updateTask = $VM.ExtensionData.ReconfigVM_Task($updateSpec);
    $taskTracker = Get-Task -Id ("Task-$($updateTask.value)");
    $taskTracker | Wait-Task; 
}

function Set-AppOvfProps
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $credentialFileLoc,

        [Parameter(Mandatory=$true)]
        [string]
        $appOvfPropertiesLoc
    )

    # Load data from config files
    $creds = Import-Csv $credentialFileLoc;
    $appOvfProps = Import-Csv $appOvfPropertiesLoc;

    foreach($appOvfProp in $appOvfProps)
    {
        # Get VCSA login
        $credential = $creds | Where-Object { $_.DataCentreName -eq $import.DataCentreName }

        # Connect to VCSA
        $vcsa = Connect-VIServer `
            -Server $credential.DataCentreAddress `
            -User $credential.Username `
            -Password $credential.Password;

        Set-AppOvfProp -appName $appOvfProp.AppName `
            -prop $appOvfProp.Prop `
            -value $appOvfProp.Value;

        # Disconnect to VCSA
        Disconnect-VIServer -Server $vcsa -Force; 
    }
}

function Set-AppOvfProp
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $appName,

        [Parameter(Mandatory=$true)]
        [string]
        $prop,

        [Parameter(Mandatory=$true)]
        [string]
        $value
    )

    # Get the vApp from the API
    $app = Get-VApp -Name $appName;

    # Extract the existing OVF Props
    $extantAppOvfProps = $app.ExtensionData.VAppConfig.Property;
    
    # Build a new vApp config spec
    $spec = New-Object VMware.Vim.VAppConfigSpec;

    # Build a vapp property container spec
    $propSpec = New-Object VMware.Vim.VAppPropertySpec;
    
    # Determine if the property already exists
    $extantAppOvfProp = $extantAppOvfProps | Where-Object { $_.Label -match $prop };
    
    if ($extantAppOvfProp.Count -gt 0) 
    {
        # Its an existing prop so edit it
        $extantAppOvfProp.Value = $value;

        $propSpec.Operation = "edit";
        $propSpec.Info = $extantAppOvfProp;
    }
    else 
    {
        # Its a new prop so add it
        $propSpec.Operation = "add";

        $newProp = New-Object VMware.Vim.VAppPropertyInfo;
        $newProp.Info.Key = $prop;
        $newProp.Info.Value = $value;
        
        $propSpec.Info = $newProp;
    }

    $spec.Property += $propSpec;
    ($app | Get-View).UpdateVAppConfig($spec);
}