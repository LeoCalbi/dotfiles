#------------------------------------------------------------------------------
#                       			Powershell Modules
#------------------------------------------------------------------------------
#Requires -RunAsAdministrator

Import-Module -Name "PackageManagement" -ErrorAction SilentlyContinue
Import-Module -Name "PowerShellGet" -ErrorAction SilentlyContinue

$InstalledModules = Get-InstalledModule -ErrorAction SilentlyContinue

foreach ($mod in $InstalledModules) {
    Update-Module -Name $mod.Name -Scope CurrentUser -AllowPrerelease
}

Remove-Variable -Name "InstalledModules"
