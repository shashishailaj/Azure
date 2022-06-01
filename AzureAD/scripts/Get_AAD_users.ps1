#####################################################################################################################################################
# Date     :- June 1 , 2022
# License  :- MIT License
# Audience :- For Azure Community 
# Author   :- Shashi Shailaj
# Pre-req  :- NA 
# Limitations :- NA
######################################################################################################################################################


$tid = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' 
Connect-AzureAD -TenantId $tid
$allUsers = Get-AzureADUser -All $true
$allUsers.Count
$userInfo = @()
$uid = 0
for($x = 0; $x -le $allUsers.Count; $x++) 
{
    Write-Progress -Id 0 -Activity "Retrieving User " -Status "$uid of $($allUsers.Count)" 
    $userInfo += ($allUsers)[$x] | Select-Object -Property *
    $uid++
}
Write-Progress -Id 0 -Activity " " -Status " " -Completed
$userInfo | Select DisplayName, AccountEnabled, UserPrincipalName| Format-Table
$userInfo | Select DisplayName, AccountEnabled, UserPrincipalName| Export-Csv -Path ./AADusers.csv -NoTypeInformation -Append
