#####################################################################################################################################################
# Date     :- February 26 , 2021
# License  :- MIT License
# Audience :- For Azure Community 
# Author   :- Shashi Shailaj
# Pre-req  :- This script uses client credentials oAuth flow and requires you to register an app . 
#            and grant the following application permissions on Microsoft Graph API and consent to them . 
#          - Microsoft Graph
#           - Directory.Read.All
#           - AuditLog.Read.All
# Limitations :- Not suitable for extremely large organisations with more than 100000 active users. 
#                Script would need to be modified for that use case to consider paging the output received at every call as it would be very large. 
######################################################################################################################################################
    
    $ClientID       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"     # You need to register this using app registration section on the Azure AD portal. 
    $ClientSecret   = "_xxxxxxxx_xxxxxxxxxxxxx._xxxxxxx~"        # The client secret generated for the above application ID 
    $loginURL       = "https://login.microsoftonline.com/"
    $tName          = "xxxxxxxx.onmicrosoft.com"                 # Your tenant name , for example :- contoso.onmicrosoft.com
    $res            = "https://graph.microsoft.com/"
    $Logfile        = "./azure.log"                              # Just for debugging purposes 
     
      
    Function LogWrite
    {
       Param ([string]$logstring)
       Add-content $Logfile -value ((get-date).toString() + " " + $logstring)
    }
    $fromdate= "{0:s}" -f (get-date).AddHours(-12).ToUniversalTime() + "Z"
    $filedate= "{0:s}" -f (get-date).AddHours(0).AddSeconds(-(get-date).Second).ToUniversalTime() + "Z"
    $filedate=$filedate.Replace(':', '-')
    $todate= "{0:s}" -f (get-date).ToUniversalTime() + "Z"
    $body = @{grant_type="client_credentials";resource=$res;client_id=$ClientID;client_secret=$ClientSecret}
    $oauth = Invoke-RestMethod -Method Post -Uri $loginURL/$tName/oauth2/token?api-version=1.0 -Body $body
    $url = "https://graph.microsoft.com/v1.0/auditLogs/signIns?$filter=start/dateTime ge $fromDate and end/dateTime le $toDate"
   Do{
    if ($oauth.access_token -ne $null) 
    {
        $headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
        LogWrite("Fetching data using Uri: $url. from: $fromdate, to:$todate")
        $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $url)
        $json = $myReport.Content | convertfrom-json
        $output2 = $json.value | Export-Csv ./json-$filedate.csv -NoTypeInformation -Append  # output of json 
        $json.value |  Select-Object -Property @{Name = "Directory Event id"; Expression ={ $_.id}},correlationId,@{Name = "Timestamp"; Expression ={ $_.createdDateTime}},@{Name = "User"; Expression ={ $_.userDisplayName}},@{Name = "UPN"; Expression ={ $_.userPrincipalName}},@{Name = "UserID"; Expression ={ $_.userId}},@{Name = "AAD Internal App"; Expression ={ $_.appDisplayName}},@{Name = "Application ID"; Expression ={ $_.appid}},@{Name = "Ip Address"; Expression ={ $_.ipAddress}},@{Name = "City"; Expression ={ $_.location.city}},@{Name = "State"; Expression ={ $_.location.state}},@{Name = "Country"; Expression ={ $_.location.countryOrRegion}},@{Name = " Applied CA policies"; Expression ={ $_.appliedConditionalAccessPolicies}},@{Name = "User-side App"; Expression ={ $_.clientAppUsed}},@{Name = "Resrouce Called"; Expression ={ $_.resourceDisplayName}},@{Name = "Resrouce Id"; Expression ={ $_.resourceId}},@{Name = "Error Code"; Expression ={ $_.status.errorCode}},@{Name = "Failure Reason"; Expression ={ $_.status.failureReason}},@{Name = "Failure Details"; Expression ={ $_.status.additionalDetails}},@{Name = "Device ID"; Expression ={ $_.deviceDetail.deviceId}},@{Name = "Device Name"; Expression ={ $_.deviceDetail.displayName}},@{Name = "OS Name"; Expression ={ $_.deviceDetail.operatingSystem}},@{Name = "Browser"; Expression ={ $_.deviceDetail.browser}},@{Name = "Intune Compliance"; Expression ={ $_.deviceDetail.isCompliant}},@{Name = "Intune Managed"; Expression ={ $_.deviceDetail.isManaged}},@{Name = "Device Trust Type"; Expression ={ $_.deviceDetail.trustType}} | Export-Csv ./Audit-$filedate.csv -NoTypeInformation -Append
        $url = ($myReport.Content | ConvertFrom-Json).'@odata.nextLink'
        LogWrite("New URL: $url")
    }
    else {
        LogWrite("ERROR: No Access Token. trying to get new access_token")
            $oauth = Invoke-RestMethod -Method Post -Uri $loginURL/$tName/oauth2/token?api-version=1.0 -Body $body
            LogWrite("token: $oauth")
        }
    }
While($url -ne $null) 
 

 
