
#
# Disable users that are not in use for the past 90 days.
# 
# Uses SendGmailCmdlet to send email of disabled users.
#

Import-Module ActiveDirectory

$inactiveDays = 90
$neverLoggedInDays = 20
$disableDaysInactive=(Get-Date).AddDays(-($inactiveDays))
$disableDaysNeverLoggedIn=(Get-Date).AddDays(-($neverLoggedInDays))
$deletionMessage = "The following users have been disabled after not logging on for more than $inactiveDays days:`n"
$warningMessage = "The user's Gmail and 365 accounts have not been disabled  `nIf any user was wrongfully disabled, please add them to the group: Non Disabled users. "
$userBase = "OU=Users,DC=contoso,DC=com"
$disabledUsersOU = "OU=Disabled,OU=Users,DC=contoso,DC=com"



try
{
    #Get list of already disabled users
    $alreadyDisabled = Get-ADUser -SearchBase $disabledUsersOU  -Filter * -ErrorAction Stop

    # Identify and disable users who have not logged in for 90 days
    $disableUsers = Get-ADUser -SearchBase $userBase -Filter {Enabled -eq $TRUE} -Properties lastLogonDate, whenCreated, distinguishedName , ObjectGUID, Name, mail -ErrorAction Stop | Where-Object {($_.lastLogonDate -lt $disableDaysInactive) -and ($_.lastLogonDate -ne $null) -and ($_.ObjectGUID -notin $alreadyDisabled.ObjectGUID) }

    # Identify and disable users who have never logged in for more than 30 days after created
    $disableUnlogged = Get-ADUser -SearchBase $userBase -Filter {Enabled -eq $TRUE} -Properties lastLogonDate, whenCreated, distinguishedName , ObjectGUID, Name, mail -ErrorAction Stop | Where-Object {($_.whenCreated -lt $disableDaysNeverLoggedIn) -and (-not ($_.lastLogonDate -ne $NULL))  -and ($_.ObjectGUID -notin $alreadyDisabled.ObjectGUID) }
 
}
catch
{
     Write-EventLog -Source "DisableInactiveUsers" -EventId 1000 -LogName Application -Message "Unable to parse users to disable,`n$_ "
     exit
}


if(!([string]::IsNullOrEmpty($disableUsers)) -or !([string]::IsNullOrEmpty($disableUnlogged)))
{

    $arr = @()


    foreach($user in $disableUsers) {

        # Get user's name and mail
        $udata = $user | Select-Object Name , mail
        # Add to list of disabled users
        $arr += @("`t" + $udata.Name + "`n`t`t" + $udata.mail + "`n")

        #Disable account and write in eventlog
        Disable-ADAccount $user

        #Move the user to the Disabled users OU
        $userGUID = $user.ObjectGUID
        Move-ADObject -Identity $userGUID -TargetPath $disabledUsersOU


        Write-EventLog -Source "DisableInactiveUsers" -EventId 9090 -LogName Application -Message "Attempted to disable user $user because the last login was more than $neverLoggedInDays days ago."
    }


    foreach($user in $disableUnlogged) {

        # Get user's name and mail
        $udata = $user | Select-Object Name , mail
        # Add to list of disabled users
        $arr += @("`t" + $udata.Name + "`n`t`t" + $udata.mail + "`n")

        $userGUID = $user.ObjectGUID
        
        #Disable account and write in eventlog
        Disable-ADAccount $user

        #Move the user to the Disabled users OU
        Move-ADObject -Identity $userGUID -TargetPath $disabledUsersOU

        Write-EventLog -Source "DisableInactiveUsers" -EventId 9090 -LogName Application -Message "Attempted to disable user $user because they have never logged on in $inactiveDays days since user creation."
    }



    $infoToSend = ($deletionMessage, $arr, $warningMessage) | Out-String

    write-output $infoToSend

}

Write-EventLog -Source "DisableInactiveUsers" -EventId 9090 -LogName Application -Message "Script ended successfully!"
