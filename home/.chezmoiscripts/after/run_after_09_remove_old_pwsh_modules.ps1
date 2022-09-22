#------------------------------------------------------------------------------
#                       	 Powershell Modules
#------------------------------------------------------------------------------

#Requires -RunAsAdministrator

Write-Output "Removing old Powershell Modules..."
if ((Get-Module -Name MyUtilities)) {
    Import-Module MyUtilities
    Uninstall-AllOldVersionsAllModules
    Write-Output "...Old Powershell Modules removed"
} else {
    Write-Warning "MyUtilities module not found, skipping uninstalling old versions of modules."
}
