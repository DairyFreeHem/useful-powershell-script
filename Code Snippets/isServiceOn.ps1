# Check if service is on and turn it on

param (
    [string]$ServiceNamePrefix
)

$arrService = Get-Service $ServiceNamePrefix

foreach ($service in $arrService) {
    if ($service -ne 'Running')
    {
        Start-Service $ServiceName
    }
}
