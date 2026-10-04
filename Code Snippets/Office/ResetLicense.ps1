function PrintLicensesInformation
{

	$licensePath = "${env:LOCALAPPDATA}\Microsoft\Office\Licenses"

	$licenseFiles = $null
	If (Test-Path $licensePath)
	{
		$licenseFiles = Get-ChildItem -Path $licensePath -Recurse -File
	}

	If ($licenseFiles.length -Eq 0)
	{
		Write-Host "License deleted"
		Return
	}

    else {
        Write-Output "ERROR!!!!! licenses still exists" 
    }

}

PrintLicensesInformation
$licenseFiles = Get-ChildItem -Path "${env:LOCALAPPDATA}\Microsoft\Office\Licenses" -Recurse -File

If ($licenseFiles.length -Eq 0)
{
    Write-Host "No licenses found."
    Return
}

$licenseFiles | ForEach-Object `
{
    Remove-Item -Path $_.FullName
}


PrintLicensesInformation