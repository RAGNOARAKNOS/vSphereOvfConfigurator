#Some notes http://www.lukaslundell.com/2013/06/modifying-vapp-properties-with-powershell-and-powercli/
# and https://github.com/lamw/vghetto-scripts/blob/master/powershell/VMOvfProperty.ps1
function Set-VmOvfProps  
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $credentialFileLoc
    )
    
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