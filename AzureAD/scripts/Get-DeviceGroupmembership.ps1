Work In progress 
=============================




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
$DeviceGroupData = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/devices/<deviceid>/memberOf"
$DeviceGroupData.value.displayName
