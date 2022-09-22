#------------------------------------------------------------------------------
#                       			Chocolatey packages
#------------------------------------------------------------------------------
#Requires -RunAsAdministrator

Write-Output "Upgrading Chocolatey packages..."
if (Get-Command "choco") {
    Start-Process -Wait -FilePath cmd -Verb RunAs -ArgumentList "/c choco upgrade all"
}
else {
    Write-Warning "...Chocolatey not found, skipping upgrade."
}
Write-Output "...Chocolatey packages upgrade completed"
