#Remove files older than 30 days from file

$currentDate = Get-Date
$cutoutDate = ($currentDate).AddDays(-30)
$path = 'D:\filepath'
$logPath = 'D:\logpath'
$toDelete = Get-ChildItem -Path $path -Recurse -Force | Where-Object {(!$_.PSIsContainer -and $_.CreationTime -lt $cutoutDate)} 
$toDelete += Get-ChildItem -Path $logPath | Where-Object {($_.CreationTime -lt $cutoutDate)} 

$toDelete | Remove-Item

#Create Logs folder
New-Item -Path $logPath -ItemType Directory 

$dateData = $currentDate.Day.ToString() + '-' + $currentDate.Month.ToString() + '-' + $currentDate.Year.ToString()
$toDelete | Out-File -FilePath "$logPath\$dateData.txt"