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
# Credits  :- Russ Maxwell <https://blog.russmax.com/powershell-using-datatables/>
######################################################################################################################################################

Connect-Graph -Scopes "User.Read.All", "Group.ReadWrite.All", "Device.Read.All"
$AllDevice = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/devices/"
$devicecount = $AllDevice.value.Count
$graphurl = "https://graph.microsoft.com/v1.0/devices/"


$tempTable = New-Object System.Data.DataTable
   
$col1 = New-Object System.Data.DataColumn("Device Object Id")
$col2 = New-Object System.Data.DataColumn("Device Name")
$col3 = New-Object System.Data.DataColumn("Group Names")
           

$tempTable.columns.Add($col1)
$tempTable.columns.Add($col2)
$tempTable.columns.Add($col3)

$tempTable.Columns.Count

for ($i = 0;$i -le $devicecount - 1; $i += 1)
{
$row = $tempTable.NewRow()

$url = -join($graphurl,$AllDevice.value[$i].id,"/memberOf")
$DeviceGroupMember = Invoke-GraphRequest -Uri $url
if($DeviceGroupMember.value.displayName)
{
$row["Device Object Id"] = $AllDevice.value[0].id
$row["Device Name"] = $AllDevice.value[0].displayName
$displayGrpcount = $DeviceGroupMember.value.displayName.Count

if($displayGrpcount -eq 1)
{
$row["Group Names"] = $DeviceGroupMember.value.displayName

}
else
{
$GroupName = ""
for ($j = 0;$j -le $displayGrpcount - 1; $j += 1)
{
$GroupName = -join($GroupName , $DeviceGroupMember.value.displayName[$j] ,"; ")
}
$row["Group Names"] = $GroupName

}

}
$tempTable.rows.Add($row)

$tempTable | export-csv -Path .\so.csv -NoTypeInformation
}

