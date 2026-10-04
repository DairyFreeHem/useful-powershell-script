Import-Module Microsoft.Graph.Authentication
import-module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Users


connect-mgGraph -Scopes @("Group.ReadWrite.All", "User.Read.All")

$license_group_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$usrs = Get-MgGroupMember -GroupId $license_group_id -All

# Get A1 License
$A1PlusLicense = Get-MgSubscribedSku -All | Where-Object {($_.SkuPartNumber -in ( 'STANDARDWOFFPACK_IW_STUDENT'))}
$A1License = Get-MgSubscribedSku -All | Where-Object {($_.SkuPartNumber -in ( 'STANDARDWOFFPACK_STUDENT'))}

foreach ($usr in $usrs)
{
    Set-MgUserLicense -UserId $usr.Id -RemoveLicenses @($A1PlusLicense.SkuId) -AddLicenses @{}
    Set-MgUserLicense -UserId $usr.Id -RemoveLicenses @($A1License.SkuId) -AddLicenses @{}
}

Disconnect-MgGraph