# ~/.local/share/chezmoi/run_once_after_moduleps-installation.ps1
# ============================================================================
# Runs at the beginning of `chezmoi apply` initial setup and packages configuration.
#

#Requires -RunAsAdministrator
Import-Module -Name "PackageManagement" -ErrorAction SilentlyContinue
Import-Module -Name "PowerShellGet" -ErrorAction SilentlyContinue
. "$PSScriptRoot\management-functions.ps1"

#------------------------------------------------------------------------------
#                       Powershell Modules
#------------------------------------------------------------------------------
$Modules = [ordered]@{
    'FastPing'       = 0;
    'oh-my-posh'     = 0;
    'posh-git'       = 0;
    'posh-sshell'    = 0;
    'Pscx'           = 1 ;
    'PSReadLine'     = 1 ;
    'Recycle'        = 0;
    'Terminal-Icons' = 0;
    'ZLocation'      = 0;
}
if ((Get-Command "pwsh") -or (Get-Command "powershell")) {
    Write-Output "Configuring Powershell..."
    # Set strong cryptography on 64 bit .Net Framework (version 4 and above)
    if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -ErrorAction SilentlyContinue) -ne 1) {
        Write-Output "Setting strong cryptography on .Net Framework 64 bit."
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
    }
    # Set strong cryptography on 32 bit .Net Framework (version 4 and above)
    if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -ErrorAction SilentlyContinue) -ne 1) {
        Write-Output "Setting strong cryptography on .Net Framework 32 bit."
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
    }
    Write-Output "...Completed Powershell configuration..."

    Write-Output "Installing modules in Powershell..."
    # Ensure TLS1.2 is used because Powershell Gallery doesn't support anymore the older versions.
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ModulesDir = ($Env:PSModulePath | Split-String -Separator ";")[0]
    Write-Output "Installing Powershell Gallery Modules..."
    if (-not (Get-InstalledModule -Name PowerShellGet -ErrorAction SilentlyContinue)) {
        Write-Output "PowershellGet not installed, installing PowershellGet..."
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Name PowerShellGet -Scope CurrentUser -Force
        Save-Module -Name PackageManagement -Path $ModulesDir
    }
    foreach ($mod in $Modules.GetEnumerator()) {
        if (-not (Get-InstalledModule -Name $mod.Key -ErrorAction SilentlyContinue)) {
            Write-Output "Installing $($mod.Key) ..."
            if ($mod.Value -eq 0) {
                Install-Module -Name $mod.Key -Scope CurrentUser -Force
            }
            elseif ($mod.Value -eq 1) {
                Install-Module -Name $mod.Key -Scope CurrentUser -AllowPrerelease -Force
            }
        }
        else {
            Write-Output "$($mod.Key) already installed, skipping."
        }
    }

    Write-Output "...Completed installation of Powershell Gallery Modules"
}
else {
    Write-Warning "Powershell not found, skipping modules installation."
}
Remove-Variable -Name "Modules"
Write-Output "... Completed configuration of Powershell Modules."
