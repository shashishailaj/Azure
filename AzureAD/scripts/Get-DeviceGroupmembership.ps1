Work In progress 
=============================
#####################################################################################################################################################
# Date     :- October 21 , 2021
# License  :- MIT License
# Audience :- For Azure Community 
# Author   :- Anurag Sharma , Shashi Shailaj
# Pre-req  :- This script uses client credentials oAuth flow and requires you to register an app . 
#            and grant the following application permissions on Microsoft Graph API and consent to them . 
#          - Microsoft Graph
#           - Directory.Read.All
#           - AuditLog.Read.All
# Limitations :- Not suitable for extremely large organisations with more than 100000 active users. 
#                Script would need to be modified for that use case to consider paging the output received at every call as it would be very large.
#                You would need to use $top $skip $skiptoken etc. for the same. Please see https://docs.microsoft.com/en-us/graph/query-parameters for deatils. 
######################################################################################################################################################



Get-AzureADGroupMember -ObjectId ced2a638-f649-4c6e-b581-a57f5b231ace | where-Object {$_.ObjectType -eq "Device"} 
Get-AzureADDevice -ObjectId 412fb047-4877-4ed3-8a28-c49242b9918d | Get-AzureADUserMembership | fl
Get-AzureADGroup -ObjectId ced2a638-f649-4c6e-b581-a57f5b231ace | fl
Get-AzureADDevice -SearchString user@domain.com | Get-AzureADUserMembership | % {Get-AzureADObjectByObjectId -ObjectId $_.ObjectId | select DisplayName,ObjectType,ObjectId,DeviceId} | ft

Connect-AzureAD
Param($DevObjId)
$check=(Get-AzureADGroupmember -objectId $DevObjId).Displayname
If($check -contains 'ATLASDC1'){Get-AzureADGroup -objectId $DevObjId}
Import-Csv -path  C:\temp\devicegroup.csv | foreach {C:\Users\Administrator\Desktop\check.ps1 -ObjectId $_.objectId}




Using Microsoft Grpah Module 

Install-Module -Name Microsoft.Graph
Connect-Graph -Scopes "User.Read.All", "Group.ReadWrite.All", "Device.Read.All"
$DeviceGroupMembership = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/devices/<deviceid>/memberOf"
$DeviceGroupData.value.displayName


Credits - https://stackoverflow.com/questions/57251857/azure-active-directory-how-to-check-device-membership

Get-AzureADGroup -All 1 | ? {"COMPUTER_DISPLAY_NAME" -in (Get-AzureADGroupMember -ObjectId $_.ObjectId).DisplayName} -Filter groupTypes/any(c:c+ne+'Unified')

function Get-AzureADDeviceMembership{
    [CmdletBinding()]
    Param(
        [string]$ComputerDisplayname,
        [switch]$UseCache
    )
    if(-not $Global:AzureAdGroupsWithMembers -or -not $UseCache){
        write-host "refreshing cache"
        $Global:AzureAdGroupsWithMembers = Get-AzureADGroup -All 1 | % {
            $members = Get-AzureADGroupMember -ObjectId $_.ObjectId
            $_ | Add-Member -MemberType NoteProperty -Name Members -Value $members
            $_
        }
    }
    $Global:AzureAdGroupsWithMembers | % {
        if($ComputerDisplayname -in ($_.Members | select -ExpandProperty DisplayName)){
            $_
        }
    } | select -Unique
}

Connect-AzureAD    
Get-AzureADDeviceMembership -ComputerDisplayname "COMPUTER_DISPLAY_NAME" -UseCache


-Filter groupTypes/any(c:c+ne+'Unified')
