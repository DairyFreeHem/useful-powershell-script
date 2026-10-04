
#
# Set 7zip as the default program for the 7z file extention
#

$chocopath = "C:\ProgramData\chocolatey\choco.exe"

if (!(Test-Path $chocopath)) {
    try {
        #Install chocolatey
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) -ErrorAction Stop
    }
    catch {
        Exit-PSSession
    }
}

$allapps = C:\ProgramData\chocolatey\choco.exe list -lo

$isInstalled = $false
foreach ($app in $allapps)
{
    if ($app -like "7zip.install*") {
        $isInstalled = $true
        break
    }
}

if (!($isInstalled)) {
    C:\ProgramData\chocolatey\choco.exe install 7zip.install -Force
}
reg import '\\c-dan\install\7z\7zipreg.reg'