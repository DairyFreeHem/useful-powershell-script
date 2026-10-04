
#
# Test to see which computers have MS Office 2016 or older installed
# Store the data into a CSV
#


$location = 'C:\output.txt' 
try {
    #Get all apps with the name Microsoft Office
    $oldOffice = Get-WmiObject win32_product -ErrorAction Stop| where{($_.Name -like "Microsoft Office*")}
    #Did we find any Office products?
    $hasOldOffice = ($oldOffice.Count -gt 0)
    #Get User's IP Address
    $IPAddr = (Get-NetIPAddress -ErrorAction Stop | Where-Object {($_.IPAddress -like "10.X.X.X*" )}).IPAddress
    #Import CSV of all affeted users
    $Output = Import-Csv "$location\AffectedUsers.csv" -ErrorAction Stop
    #Is the user already in the CSV?
    $containUser = ($Output | Where-Object {($_.IP -contains $IPAddr)})
    $compName = $env:COMPUTERNAME
}
catch
{
    exit
}

#If user has an old office version and isn't in the CSV,
#then add them to the CSV
if ($hasOldOffice -eq $true) {
    if ($null -eq $containUser) {
        "$compName , $IPAddr, $hasOldOffice" | Add-Content "$location\AffectedUsers.csv"
    }
}
#If user doesn't have an old office version and is in the CSV,
#then remove them from the CSV
elseif ($null -ne $containUser) {
       $Output | Where-Object {($_.IP -notcontains "$IPAddr")} | Export-Csv .\AffectedUsers.csv -NoTypeInformation
}


