#------------------------------------------------------------------------------
#                       Powershell Modules
#------------------------------------------------------------------------------
#Requires -RunAsAdministrator

$Modules = [ordered]@{
    'FastPing'       = 1;
    'posh-git'       = 1;
    'posh-sshell'    = 1;
    'Pscx'           = 1 ;
    'PSReadLine'     = 1 ;
    'PSWindowsUpdate'= 1 ;
    'Recycle'        = 1;
    'Terminal-Icons' = 1;
    'ZLocation'      = 1;
}
Write-Output "Installing modules in Powershell..."

# Ensure TLS1.2 is used because Powershell Gallery doesn't support anymore the older versions.
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ModulesDir = ($Env:PSModulePath | Split-String -Separator ";")[0]

if (-not (Get-InstalledModule -Name PowerShellGet -ErrorAction SilentlyContinue)) {
    Write-Output "PowershellGet not installed, installing PowershellGet..."
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name "PowerShellGet" -Scope CurrentUser -Force
    Save-Module -Name "PackageManagement" -Path $ModulesDir
}

Import-Module -Name "PackageManagement" -ErrorAction SilentlyContinue
Import-Module -Name "PowerShellGet" -ErrorAction SilentlyContinue

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

Remove-Variable -Name "Modules"
Write-Output "...Completed installation of Powershell Gallery Modules"
