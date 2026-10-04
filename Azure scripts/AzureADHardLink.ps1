   
   #
   #    Hard link one user from DC to Azure AD 
   #
   
   function textColor($TColor)
    {
        process { Write-Host $_ -ForegroundColor $TColor }
    }
    try
    {
        $User = $args[0]

        #Get AD data about user
        $ADReg = Get-ADUser -Identity $User -Server "contoso.com" -Properties *

        #Get GUID from AD user
        $GUID = $ADReg.ObjectGUID;
        Write-Output "`nReceived GUID : $GUID.Guid  `n`n"
    }
    catch{
        #If user wasn't found in AD
        Write-Output "`tError parsing user from AD, `n`tmake sure Username is correct
        Exiting...." | textColor("Red")
        Exit
    }

    #Get UPN and replace AD suffix our with Azure AD suffix
    if($args[1] -ne $null)
    {
        #If UPN was passed as an argument   
        $UserPrincipalName = $args[1]
    }
    else
    {
        #Find user's AzureAD UPN by his AD UPN
        $UserPrincipalName = ($ADReg | Select-Object mail).mail
        $UserPrincipalName = $UserPrincipalName -replace '@contoso.com','@office.contoso.com'
    }

    Write-Output "Received UPN : $UserPrincipalName  `n"

    #Convert GUID into Base64
    $Base64GUID = [system.convert]::ToBase64String($GUID.ToByteArray())
    Write-Output "ImmutableId: $Base64GUID `n"

#Import Module
Import-Module AzureAD | Out-Null

#Check for AzureAD Session is still open
Function AzureADConnected {
    try
    {
        Get-AzureADTenantDetail -ErrorAction SilentlyContinue
    }
    catch
    {
        return $false
    }
    return $true
}

#Connect to AzureAD if not Connectet
if(AzureADConnected)
{
   Write-Output "Session already connected to Azure AD.`n" | textColor("Green")
}
else
{
    try
    {
        Write-Output "Connecting to Azure AD.`n"
        Connect-AzureAD -ErrorAction Stop
    }
    catch
    {
        Write-Output "`tCouldn't connect to Azure AD. `n`tMake sure you have a working internet connection,`n`tand that the credentials are correct. `n`tExiting... `n" | textColor("Red")
        exit   
    }
}
    


    try
    {
         #Check if user exists in AzureAD
         $azureUser =Get-AzureADUser -ObjectId $UserPrincipalName -ErrorAction stop 
         $userImmutableID = ($azureUser | Select-Object ImmutableId).ImmutableId
         if( $userImmutableID -ne $null)
         {
            while(1)
            {
                $confirmation = Read-Host "This user already contains an ImmutableID $userImmutableID , do you want to continue (Y\N)?"
                $confirmation = $confirmation.ToUpper()
                if($confirmation -eq 'Y' -or $confirmation -eq 'YES')
                {
                    break
                }
                if($confirmation -eq 'N' -or $confirmation -eq 'NO')
                {
                    Disconnect-AzureAD
                    Write-Output "`nDisconnecting from AzureAD `n"
                    Write-Host "`nGoodbye!"
                    exit
                }

            }
         }
         
    }
    catch
    {
        #If not, then exit
        Write-Output "`tUser $UserPrincipalName doesn't exist in Azure AD" | textColor("Red")
        Write-Output "`tDisconnecting from AzureAD `n`tExiting... `n" | textColor("Red")
        Disconnect-AzureAD
        exit 
    }

    #Set ImmutableId to AzureAD User
    Write-Output "Writing ImmutableID. `n"
    Set-AzureADUser -ObjectId $UserPrincipalName -ImmutableId $Base64GUID

    #Fin
    Write-Output "Disconnecting from AzureAD `n"
    Disconnect-AzureAD
    Write-Output "ImmutableID written successfully! `nExiting... `n" | textColor("Green")
