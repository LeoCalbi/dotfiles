<#
    .SYNOPSIS
        Profile File
    .DESCRIPTION
        Profile File
    .NOTES
        Leonardo Calbi
	.LINK
        https://github.com/LeoCalbi
#>


# -----------------------------------------------------------------------------
#                              User Profile
# -----------------------------------------------------------------------------

#                              Notes
# -----------------------------------------------------------------------------

#                              Modules Import
# -----------------------------------------------------------------------------

Import-Module -Name "PSReadline"
# Utility functions
Import-Module -Name "Pscx" -arg @{TextEditor = "code.cmd" }
# Custom GitStatusCache Module
Import-Module -Name "GitStatusCachePoshClient"
# Git modules
Import-Module -Name "posh-git"
# SSH connection module - SSH connections folder ~/.ssh/config
Import-Module -Name "posh-sshell"
# ZLocation
Import-Module -Name "ZLocation"
# Set Oh-My-Posh v3 Theme
Import-Module -Name "oh-my-posh"

Import-Module -Name "Terminal-Icons"

Import-Module -Name "FastPing"

# Custom ScreenFetch Module
Import-Module -Name "Screenfetch"

# Custom utility functions
Import-Module -Name "MyUtilities"


#                              Shell config
# -----------------------------------------------------------------------------
# PS comes preset with 'HKLM' and 'HKCU' drives but is missing HKCR
New-PSDrive -Name HKCR -Description "HKEY Classes Root" -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null

$PSThemesFolder = "$PSScriptRoot\PoshThemes"
$CurrentTheme = "cb"
Set-PoshPrompt -Theme "$PSThemesFolder\$CurrentTheme.omp.json"
Add-PathVariable -Value $PSScriptRoot -Name Path
Add-PathVariable -Value $PSScriptRoot -Name PSProfileDir
Add-PathVariable -Value ([Environment]::GetFolderPath("MyDocuments")) -Name Documents

$PSDefaultParameterValues = @{
	"Out-File:Encoding"     = "utf8"
	'Format-Table:AutoSize' = $true
	'Get-Help:ShowWindow'   = $false
}
[console]::OutputEncoding = [Text.Utf8Encoding]::new()

#                              Apps Import
# -----------------------------------------------------------------------------
$AppDir = "Apps"
$Apps = (
	"WhoIs\1.21",
	"OoklaSpeedtest\1.0.0"
);
foreach ($app in $Apps) {
	if (Test-Path("$PSScriptRoot\$AppDir\$app")) {
		Add-PathVariable -Value "$PSScriptRoot\$AppDir\$app" -Name Path
	}
	else {
		Write-Error "$AppDir\$app not found."
	}
}

#                              Scripts Import
# -----------------------------------------------------------------------------
$scripts = $null;
foreach ($script in $scripts) {
	if (Test-Path("$PSScriptRoot\$script")) {
		Unblock-File -Path "$PSScriptRoot\$script"
		. "$PSScriptRoot\$script"
	}
	else {
		Write-Error "$PSScriptRoot\$script not found."
	}
}

#                              Module Profiles
# -----------------------------------------------------------------------------

#region psreadline initialize
$PSReadlineProfile = "psreadlineProfile.ps1"
if (Test-Path("$PSScriptRoot\$PSReadlineProfile")) {
	Unblock-File -Path "$PSScriptRoot\$PSReadlineProfile"
	. "$PSScriptRoot\$PSReadlineProfile"
}
else {
	Write-Error "$PSScriptRoot\$PSReadlineProfile not found."
}
#endregion

#region pscx initialize
$PSCXProfile = "pscxProfile.ps1"
if (Test-Path("$PSScriptRoot\$PSCXProfile")) {
	Unblock-File -Path "$PSScriptRoot\$PSCXProfile"
	. "$PSScriptRoot\$PSCXProfile"
}
else {
	Write-Error "$PSScriptRoot\$PSCXProfile not found."
}
#endregion

#region recycle initialize
$RecycleProfile = "recycleProfile.ps1"
if (Test-Path("$PSScriptRoot\$RecycleProfile")) {
	Unblock-File -Path "$PSScriptRoot\$RecycleProfile"
	. "$PSScriptRoot\$RecycleProfile"
}
else {
	Write-Error "$PSScriptRoot\$RecycleProfile not found."
}
#endregion

#                              Conda init
# -----------------------------------------------------------------------------
#region conda initialize
$CondaDir = "$ENV:ChocolateyToolsLocation\Anaconda3\Scripts\conda.exe"
# !! Contents within this block are managed by 'conda init' !!
if (Test-Path($CondaDir)) {
	(& $CondaDir "shell.powershell" "hook") | Out-String | Invoke-Expression
}
else {
	Write-Error "$CondaDir not found."
}
#endregion

#                              Chocolatey autocomplete
# -----------------------------------------------------------------------------

#region chocolatey initialize
$ChocolateyProfile = "$ENV:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}
else {
	Write-Error "$ChocolateyProfile not found."
}
#endregion

#                              Chezmoi autocomplete
# -----------------------------------------------------------------------------

#region chezmoi initialize
$ChezmoiProfile = "chezmoiAutocomplete.ps1"
if (Test-Path("$PSScriptRoot\$ChezmoiProfile")) {
	Unblock-File -Path "$PSScriptRoot\$ChezmoiProfile"
	. "$PSScriptRoot\$ChezmoiProfile"
}
else {
	Write-Error "$PSScriptRoot\$ChezmoiProfile not found."
}
#endregion

# Move to Home directory if in System32
if ($PWD -eq "C:\Windows\System32") {
	Set-Location $HOME
}
# Screenfetch

#								Powershell reload function
# -----------------------------------------------------------------------------
Set-Alias -Name "reloadpwsh" -Value Update-PowershellProfile -Description "Reload Powershell Profile"

function Update-PowershellProfile {
	<#
    .SYNOPSIS
        Reload the powershell profile.
    .INPUTS
        None
    .OUTPUTS
        None
    .LINK
        pwsh
    #>
	[CmdletBinding()]
	param()
	. $PROFILE
}
