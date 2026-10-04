
# Simple script to output user data to txt file

$now =  Get-Date

$output = "$($now.ToString()) -  USER:$(whoami)  COMPUTER:$($env:COMPUTERNAME)"

$output >> "C:\out\txtfile.txt"