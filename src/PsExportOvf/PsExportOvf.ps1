function Export-VM
{
    #derived from http://geekafterfive.com/2011/10/07/powers-combined-powercli-and-ovftool/

    param
    (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)] $vm,
        [parameter(Mandatory=$true)][String] $destination
    )

    $ovftoolpaths = ("C:\Program Files (x86)\VMware\VMware OVF Tool\ovftool.exe","C:\Program Files\VMware\VMware OVF Tool\ovftool.exe")
    $ovftool = ''

    foreach ($ovftoolpath in $ovftoolpaths)
    {
        if(test-path $ovftoolpath)
        {
            $ovftool = $ovftoolpath
        }
    }
    if (!$ovftool)
    {
        write-host -ForegroundColor red "ERROR: OVFtool not found in it's standard path."
        write-host -ForegroundColor red "Edit the path variable or download ovftool here: http://www.vmware.com/support/developer/ovf/"
    }
    else
    {
        $moref = $vm.extensiondata.moref.value
        $session = Get-View -Id SessionManager
        $ticket = $session.AcquireCloneTicket()
        & $ovftool "--I:sourceSessionTicket=$($ticket)" "vi://$($defaultviserver.name)?moref=vim.VirtualMachine:$($moref)" "$($destination)$($vm.name).ovf"
    }
}

# PowerCLI Export-VApp can be used for vApps
$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path
Write-Host $scriptPath;
$imports = Import-Csv ..\..\tests\Examples\TestDataWorkbook-1_AppExports.csv;

foreach($item in $imports)
{
    Write-Host $item.SourceAppName;
}
#Import-Csv $MyInvocation.MyCommand.PSPath + 