
# Add JDK 1.8 to the global environment path

$jdkPath = 'C:\Program Files\Java\jdk1.8.0_211\bin'
$pat = $env:Path | Out-File 'C:\Path.txt' -Encoding utf8

if(-not($pat -like "*Java\jdk1.8*"))
{
    [System.Environment]::SetEnvironmentVariable('PATH',($pat + $jdkPath),[System.EnvironmentVariableTarget]::Machine)
}
