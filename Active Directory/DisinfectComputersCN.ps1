


$computersCN = "CN=Computers,DC=Contoso,DC=com"
$daysAlive = 7
$disableDaysAlive=[datetime]::Today.AddDays(-($daysAlive))

#get Computers
$computers = Get-ADComputer -Filter 'whenCreated -lt $disableDaysAlive -and Enabled -eq $true ' -Properties whenCreated -SearchBase $computersCN

#If any computers were found
if ($null -ne $computers)
{ 
    #Disable found Computers
    Disable-ADAccount $computers

    $deletionMessage = "The following computers have stayed in Contoso.com/Computers for more than $daysAlive days:`n"
    $computerList = $computers | Format-Table Name | Out-String
    $deletionMessage += $computerList

    $deletionMessage += "`nAnd have therefore been disabled."

}