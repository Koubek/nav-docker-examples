param (
    [String]$ServerInstance="NAV", 
    [String]$permissionSetId = 'SUPER', 
    [String]$groupIdentity = "[TO-DO:Put your default distribution group if you want]"
)

Write-Host "INSTANCE NAME:" $ServerInstance
if ($ServerInstance -eq "") {
    Write-Host "Instance has not been specified. Exiting."
    Exit
}
Write-Host "PERMISSIONS:" $permissionSetId
if ($permissionSetId -eq "") {
    Write-Host "Permission set ID has not been specified. Exiting."
    Exit
}
Write-Host "AD GROUP IDENTITY:" $groupIdentity
if ($groupIdentity -eq "") {
    Write-Host "Group Identity has not been specified. Exiting."
    Exit
}

# Get users based on the AD security group:
$usersToAdd = Get-ADGroupMember -Identity $groupIdentity

# Create NAV users:
foreach ($userToAdd in $usersToAdd) {

    Write-Verbose "`n === Adding $($userToAdd.Name) === "

    if (-not (Get-NAVServerUser -ServerInstance $ServerInstance | Where-Object WindowsSecurityID -eq $userToAdd.SID)) {
        New-NAVServerUser -ServerInstance $ServerInstance -Sid $userToAdd.SID -FullName $userToAdd.Name
    } else {
        Write-Warning "User $($userToAdd.Name) already exists."
    }
    if (-not(Get-NAVServerUserPermissionSet -ServerInstance $ServerInstance -Sid $userToAdd.SID -PermissionSetId $PermissionSetId)) {
        New-NAVServerUserPermissionSet -ServerInstance $ServerInstance -PermissionSetId $PermissionSetId -Sid $userToAdd.SID
    } else {
        Write-Warning "Permissionset $($PermissionSetId) already assigned to user $($userToAdd.Name)."
    }
}
