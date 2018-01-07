Function ExportWSToCSV ($excelFileName, $csvLoc)
{
    #$excelFile = "C:\ExcelFiles\" + $excelFileName + ".xlsx"
    $excelFile = $csvLoc + $excelFileName + ".xlsx"
    $E = New-Object -ComObject Excel.Application
    $E.Visible = $false
    $E.DisplayAlerts = $false
    $wb = $E.Workbooks.Open($excelFile)
    foreach ($ws in $wb.Worksheets)
    {
        $n = $excelFileName + "_" + $ws.Name
        $ws.SaveAs($csvLoc + $n + ".csv", 6)
    }
    $E.Quit()
}

ExportWSToCSV -excelFileName "TestDataWorkbook-1" -csvLoc "C:\Users\LBowman\Source\Repos\vSphereOvfConfigurator\tests\Examples\"

# Based from https://www.mssqltips.com/sqlservertip/3223/extract-and-convert-all-excel-worksheets-into-csv-files-using-powershell/