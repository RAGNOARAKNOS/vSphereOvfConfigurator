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
        $credentialFileLoc
    )
}