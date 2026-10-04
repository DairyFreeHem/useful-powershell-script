

    # 
    #   Helper function that hard links local Active Directory users
    #   to their Corresponding Azure AD users at bulk from a specified CSV
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

    #Check if CSV location was passed
    if($args[0] -eq $null)
    {
        Write-Output "No CSV inserted `nExiting..." | textColor("Red")
        exit
    }
    
    #try opening CSV
    try
    {
        $users = Import-Csv $args[0] -ErrorAction Stop
    }
    catch
    {
        Write-Output "Couldn't open CSV, make sure location is correct`n Exiting" | textColor("Red")
        exit
    }
    
        #Import Module
    Import-Module AzureAD | Out-Null

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
            Connect-AzureAD -ErrorAction silentlyContinue | Out-Null
            Write-Output "Processing..."
        }
        catch
        {
            Write-Output "`tCouldn't connect to Azure AD. `n`tMake sure you have a working internet connection,`n`tand that the credentials are correct. `n`tExiting... `n" | textColor("Red")
            Write-Output $_
            exit
        }
    }

    foreach( $user in $users)
    {
        $UserUPN = $user.AzureUPN
        if( $UserUPN -ge 0)
        {
            $UserGUID = [GUID]$user.objectGUID
            $UserGUIDConvert = [system.convert]::ToBase64String($UserGUID.ToByteArray())
            Set-AzureADUser -ObjectId $UserUPN -ImmutableId $UserGUIDConvert
            $user.ImmutableID = $UserGUIDConvert
        }
        
    }

    #Fin
    Write-Output "Disconnecting from AzureAD `n"
    Disconnect-AzureAD

    Write-Output "Exporting new data to AzureADExportedData.csv`n"
    $users | Export-Csv AzureADExportedData.csv -Encoding UTF8

    Write-Output "ImmutableID written successfully! `nExiting... `n" | textColor("Green")
