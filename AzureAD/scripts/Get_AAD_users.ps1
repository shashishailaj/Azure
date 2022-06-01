#####################################################################################################################################################
# Date     :- June 1 , 2022
# License  :- MIT License
# Audience :- For Azure Community 
# Author   :- Shashi Shailaj
# Pre-req  :- NA 
# Limitations :- NA
######################################################################################################################################################

Connect-AzureAD -TenantId $tenantid 
$tenantid = '9fc589e6-xxxx-xxxx-xxxx-0b88b6b17d5e' 
$path = 'c:\temp'
$TenantName = Get-AzureADTenantDetail
$allUsers = Get-AzureADUser -All $true
$Users.Count
$userInfo = @()
$uid = 0
for($x = 0; $x -le $Users.Count; $x++) 
{
    # Just writes status
    Write-Progress -Id 0 -Activity "Retrieving User " -Status "$uid of $($Users.Count)" 
    $Userinfo += ($allUsers)[$i] | Select-Object -Property *
    $uid++
}
Write-Progress -Id 0 -Activity " " -Status " " -Completed
$userInfo | Select DisplayName, AccountEnabled, JobTitle, Mobile, UserPrincipalName, UserType | Format-Table
$userInfo | Select DisplayName, AccountEnabled, UserPrincipalName, UserType | Export-Csv -Path $path + "\AADusers.csv" -NoTypeInformation
