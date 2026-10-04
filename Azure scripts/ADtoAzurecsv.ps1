
    # 
    #   Helper function that hard links local Active Directory users
    #   to their Corresponding Azure AD users
    #   
    #   Azure AD module is needed from the Azure ad connect install location
    #   ADDS module is needed, found in any AD server / when installing RSAT tools ( https://www.microsoft.com/en-us/download/details.aspx?id=45520 )
    #


    #Change output text's color
    function textColor($TColor)
    {
        process { Write-Host $_ -ForegroundColor $TColor }
    }

    #Check for AzureAD Session is still open
    Function AzureADConnected 
    {
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

    Function pullUserData($query)
    {
        try
        {
            $userData = Get-AzureADUser -SearchString $query -ErrorAction SilentlyContinue
        }
        catch
        {
            return null;
        }
        return $userData
    }

    try
    {
        #Get all users with a valid UPN 
        $Users = Get-ADUser -SearchBase "OU=Users,DC=Contoso,DC=com" -Filter "UserPrincipalName -gt 1" -Properties *  | Select-Object Name, UserPrincipalName,mail, ObjectGUID, AzureUPN, ImmutableID
    }
    catch{
        #If user wasn't found in AD
        Write-Output "`tError parsing users from AD, `n`
        Exiting...." | textColor("Red")
        Write-Output $_
        Exit
    }

    #Import Module
    Import-Module AzureAD | Out-Null

    #Connect to AzureAD if not Connected
    if(AzureADConnected)
    {
        Write-Output "Session already connected to Azure AD.`n" | textColor("Green")
    }
    else
    {
        try
        {
            Write-Output "Connecting to Azure AD.`n"
            Connect-AzureAD -ErrorAction Stop | Out-Null
            Write-Output "Processing..."
        }
        catch
        {
            Write-Output "`tCouldn't connect to Azure AD. `n`tMake sure you have a working internet connection,`n`tand that the credentials are correct. `n`tExiting... `n" | textColor("Red")
            Write-Output $_
            exit   
        }
    }



    foreach ($user in $users) 
    {
        #Get UPN and replace AD suffix our with Azure AD suffix
        $UserPrincipalName = ($user | Select-Object mail).mail
        $UserPrincipalName = $UserPrincipalName -replace '@contoso.com','@office.contoso.com'
        $user.AzureUPN = "";
        $User.ImmutableID = "";


        try
        {
            $azureUser = Get-AzureADUser -ObjectId $UserPrincipalName -ErrorAction SilentlyContinue
        }
        catch
        {
            $azureUser = $null
        }
        
        if ($azureUser -eq $null)
        {
            $azureNickname = ($user | Select-Object name).name
            $azureUser = pullUserData($azureNickname)
        }

        if($azureUser -ne $null)
        {
            $userImmutableID = ($azureUser | Select-Object ImmutableId).ImmutableId 
            $user.AzureUPN = $UserPrincipalName
            $user.ImmutableID = $userImmutableID
        }
    }

    #Export everything to a CSV
    #at UTF8 encoding for Hebrew support
    $users | Export-Csv ADUserstoAzure.csv -Encoding UTF8

    Write-Output "Closing AzureAD..."
    Disconnect-AzureAD

    Write-Output "Finished!" | textColor("Green")


