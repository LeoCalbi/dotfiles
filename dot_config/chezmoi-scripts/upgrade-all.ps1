# ~/.local/share/chezmoi/upgrade-all.ps1
# ============================================================================
# Runs after `chezmoi apply` to upgrade modules, packages installed by chezmoi.
#
# This script upgrades chocolatey packages, and powershell modules on Windows.

#------------------------------------------------------------------------------
#         Upgrade All (Chocolatey packages and Powershell Modules)
#------------------------------------------------------------------------------

#Requires -RunAsAdministrator
Write-Output "Starting Upgrade All Script"

#------------------------------------------------------------------------------
#                       			Chocolatey packages
#------------------------------------------------------------------------------
Write-Output "Upgrading Chocolatey packages..."
if (Get-Command "choco") {
    Start-Process -Wait -FilePath cmd -Verb RunAs -ArgumentList "/c choco upgrade all"
}
else {
    Write-Warning "Chocolatey installation not found, skipping upgrade."
}
Write-Output "...Chocolatey packages upgrade completed"
#------------------------------------------------------------------------------
#                       			Powershell Modules
#------------------------------------------------------------------------------
Write-Output "Upgrading Powershell Modules..."
if ((Get-Command "pwsh") -or (Get-Command "powershell")) {
    if (Get-Command "git") {
        $psmodules = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\custom-psmodules\"
        if (Test-Path -Path $psmodules) {
            Write-Output "Upgrading custom Powershell modules..."
            $repos = Get-ChildItem -Path $psmodules -Directory
            foreach ($r in $repos) {
                if (Test-Path -Path (Join-Path -Path $r.FullName -ChildPath ".git")) {
                    Write-Output "Upgrading $($r.Name)"
                    git -C $r.FullName fetch
                    git -C $r.FullName pull
                }
                else {
                    Write-Warning "$($r.FullName) not a git repository, skipping."
                }
            }
            Write-Output "...Custom Powershell modules upgrade completed"
        }
        else {
            Write-Output "No custom Powershell modules found."
        }
    }
    else {
        Write-Warning "Git not found unable to upgrade Custom Modules, skipping them."
    }
    Write-Output "Upgrading Powershell Modules..."
    Update-Module -Scope CurrentUser
    # Remove old unused version of modules Requires MyUtilities sub-module `modules`
    if ((Get-Module -Name MyUtilities)) {
        Import-Module MyUtilities
        Uninstall-AllOldVersionsAllModules
    }
}
else {
    Write-Warning "Powershell installation not found, skipping upgrade."
}

Write-Output "...Powershell Modules upgrade completed"
