
#
# Write output when a new user event is detected in Mars DC
# Event Log
#

$EventId = 4724,4720,4726,4722
$getEvent = Get-WinEvent -MaxEvents 1  -FilterHashTable @{Logname = "Security" ; ID = $EventId}
$Message = $getEvent.Message
$EventID = $getEvent.Id
$Source = $getEvent.ProviderName

$gmailPath = "$env:SYSVOL_PATH\scripts\Modules\SendGmailCmdlet.dll"

try
{
    Import-Module $gmailPath -ErrorAction Stop
}
catch
{ 
     exit
}


$Body = "EventID: $EventID`nSource: $Source`nMessage: $Message"

Write-Output $Body