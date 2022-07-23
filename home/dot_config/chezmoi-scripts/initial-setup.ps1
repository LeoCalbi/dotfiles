# ~/.local/share/chezmoi/initial-setup.ps1
# ============================================================================
# Runs before `chezmoi apply` initial setup and packages configuration.
#
# This script set up windows settings, install essential packages and powershell modules on Windows.

#------------------------------------------------------------------------------
# Initial System setup configuration (Systems, chocolatey packages, ps Modules)
#------------------------------------------------------------------------------

#Requires -RunAsAdministrator

. "$PSScriptRoot\management-functions.ps1"

Write-Output "Starting system Configuration"
# ------------------------------------------------------------------------------
#                       Explorer, Taskbar, and System Tray
# ------------------------------------------------------------------------------
Write-Output "Configuring Explorer, Taskbar, and System Tray..."

# Ensure necessary registry paths
if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
	New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Type Folder | Out-Null
}
if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState")) {
	New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Type Folder | Out-Null
}
if (-not (Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search")) {
	New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Type Folder | Out-Null
}

# Explorer: Show hidden files by default: Show Files: 1, Hide Files: 2
if ((Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced").Hidden -ne 1) {
	Write-Output "Enabling explorer to show hidden files by default."
	Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1
}
else {
	Write-Output "Explorer already set to show hidden files by default, skipping."
}

# Explorer: Show file extensions by default: Show Extensions: 0, Hide Extensions: 1
if ((Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced").HideFileExt -ne 0) {
	Write-Output "Enabling explorer to show extensions by default."
	Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0
}
else {
	Write-Output "Explorer already set to show extensions by default, skipping."
}

# Explorer: Avoid creating Thumbs.db files on network volumes
if ((Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced").HideFileExt -ne 0) {
	Write-Output "Setting system to not create 'Thumbs.db files on network volumes."
	Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableThumbnailsOnNetworkFolders" 1
}
else {
	Write-Output "System already set to not create 'Thumbs.db files on network volumes, skipping."
}

Write-Output "Completed configuration of Explorer, Taskbar, and System Tray"
# ------------------------------------------------------------------------------
#                       LongPaths
# ------------------------------------------------------------------------------
Write-Output "Enabling LongPaths..."
# Enable LongPaths support for file paths above 260 characters.
# See https://social.msdn.microsoft.com/Forums/en-US/fc85630e-5684-4df6-ad2f-5a128de3deef
$property = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'
$name = 'LongPathsEnabled'
if ((Get-ItemPropertyValue $property -Name $name) -ne 0) {
	Write-Output "LongPaths support already enabled, skipping."
}
else {
	Write-Output "Enabling LongPaths support for file paths above 260 characters."
	Set-ItemProperty $property -Name $name -Value 1
	$count++
}

Write-Output "...Completed enabling of LongPaths"
# -----------------------------------------------------------------------------
#                          Default Windows Applications
# -----------------------------------------------------------------------------
Write-Output "Configuring Default Windows Applications..."

$AppsToRemove = @(
	"*.AutodeskSketchBook",
	"*.DisneyMagicKingdoms",
	"*.Facebook",
	"*.MarchofEmpires",
	"*.SlingTV",
	"*.Twitter",
	"DolbyLaboratories.DolbyAccess",
	"Microsoft.3DBuilder",
	"Microsoft.BingFinance",
	"Microsoft.BingNews",
	"Microsoft.BingSports",
	"Microsoft.BingWeather",
	"Microsoft.GetStarted",
	"Microsoft.MixedReality.Portal",
	# "Microsoft.MSPaint",
	"Microsoft.Messaging",
	"Microsoft.MicrosoftOfficeHub",
	"Microsoft.MicrosoftSolitaireCollection",
	"Microsoft.MicrosoftStickyNotes",
	# "Microsoft.Office.OneNote",
	"Microsoft.Office.Sway",
	"Microsoft.OneConnect",
	"Microsoft.People",
	"Microsoft.Print3D",
	"Microsoft.SkypeApp",
	# "Microsoft.Windows.Photos",
	"Microsoft.WindowsAlarms",
	# "Microsoft.WindowsCommunicationsApps", # Mail and Calendar app
	"Microsoft.WindowsMaps",
	"Microsoft.WindowsFeedbackHub",
	# "Microsoft.WindowsPhone", # Your Phone
	# "Microsoft.WindowsSoundRecorder",
	"Microsoft.XboxApp",
	"Microsoft.ZuneMusic", # Groove
	"Microsoft.ZuneVideo",
	"SpotifyAB.SpotifyMusic",
	"king.com.BubbleWitch3Saga",
	"king.com.CandyCrushSodaSaga"
)

Uninstall-AppxPackages -Packages $AppsToRemove
Remove-Variable -Name "AppsToRemove"

# Uninstall unused Windows Features
$ToRemove = @(
	"WindowsMediaPlayer",
	"MSPaint",
	"Notepad",
	"WordPad"
)
$Capabilities = Get-WindowsCapability -Online | Where-Object "State" -EQ "Installed"
foreach ($rem in $ToRemove) {
	foreach ($cap in $Capabilities) {
		if ($cap.Name -like $rem) {
			Remove-WindowsCapability -Online $cap
			Write-Output "$rem is installed, removing."
		}
	}
}
Remove-Variable -Name "Capabilities"
Remove-Variable -Name "ToRemove"
# Prevent "Suggested Applications" from returning
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent")) { New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Type Folder | Out-Null }
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1

# Enable Hyper-V for virtualization and Windows Subsystem for Linux
if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V).State -ne "Enabled") {
	Write-Output "Enabling Hyper-V features, remember to restart the system at the end of the procedure."
	Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
}
else {
	Write-Output "Hyper-V features already enabled, skipping."
}


Write-Output "...Completed configuration of Default Windows Applications"
#------------------------------------------------------------------------------
#                       			Chocolatey
#------------------------------------------------------------------------------
Write-Output "Configuring Chocolatey Package Manager..."
# -- Install Chocolatey on the local machine if not already present
if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
	Write-Output "Chocolatey not installed, installing chocolatey..."
	Set-ExecutionPolicy Bypass -Scope Process -Force
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
	Invoke-WebRequest -Uri https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
}

# -- Set up chocolatey configuration and features
Update-SessionEnvironment
# Default global confirmation
choco feature enable --name='allowGlobalConfirmation' --limitoutput
# Remember install argument for upgrades, usefull for `choco upgrade all`
choco feature enable --name='useRememberedArgumentsForUpgrades' --limitoutput
# Move chocolatey cache out of $TEMP for better management
choco config set --name='cacheLocation' --value='C:\ProgramData\choco-cache' --limitoutput
# Set higher command Execution timeout (4 hours)
choco config set --name='commandExecutionTimeoutSeconds' --value='14400' --limitoutput
# Change default C:\Tools\ Chocolatey tools Location to a custom one if needed
# {{ if .use_custom_choco_tools }} # {{ .choco_tools}}
$ChocolateyToolsLocation = "D:\Tools\"
Write-Output "Updating Enviroment Variable ChocolateyToolsLocation: $Env:ChocolateyToolsLocation -> $ChocolateyToolsLocation"
# {{ end }}
[Environment]::SetEnvironmentVariable("ChocolateyToolsLocation", $ChocolateyToolsLocation, [System.EnvironmentVariableTarget]::User)
Remove-Variable -Name "ChocolateyToolsLocation"
Write-Output "...Completed configuration of Chocolatey Package Manager"
#------------------------------------------------------------------------------
#                       	Chocolatey Packages
#------------------------------------------------------------------------------
Write-Output "Configuring Packages from Chocolatey..."
$PackagesToInstall = [ordered]@{
	# Terminals
	'powershell'                 = '';
	'pwsh'                       = ' --install-arguments= ''"REGISTER_MANIFEST=1"''';
	'microsoft-windows-terminal' = '';
	# Terminal utilies
	'curl'                       = '';
	'ffmpeg'                     = '';
	'nuget.commandline'          = '';
	'nvm'                        = '';
	'openssh'                    = ' --params= ''"/PathSpecsToProbeForShellEXEString:$Env:ProgramFiles\PowerShell\*\Powershell.exe; $Env:WinDir\System32\WindowsPowershell\v1.0\powershell.exe"''';
	'openssl'                    = '';
	'wget'                       = '';
	'micro'                      = '';
	# Git and Github
	'gh'                         = '';
	'git'                        = ' --params= ''"/GitOnlyOnPath /WindowsTerminal /NoShellIntegration"''';
	'gnupg'                      = '';
	# Java
	'jdk8'                       = ' --params= ''"both= true source= false"''';
	'jre8'                       = '';
	# Python
	'anaconda3'                  = ' --params=''"/ AddToPath"''';
	# IDE
	'vscode'                     = ' --params=''"/ NoDesktopIcon"''';
	'sublimetext3'               = '';
	# FTP Client
	'filezilla'                  = '';
	# DotfileManager
	'chezmoi'                    = '';
	# Meta packages
	'choco-cleaner'              = '';
	'choco-package-list-backup'  = ' --params=''"/ NORUN:TRUE"''';
	'chocolateygui'              = ' --params=''"/ ShowConsoleOutput = $true / DefaultToDarkMode = $true / Global"''';
	# PDF Viewer
	'adobereader'                = ' --params=''"/ NoUpdates"''';
	# Browser
	'googlechrome'               = '';
	# Google drive for desktop
	'google-drive-file-stream'   = '';
	# Archiver utility
	'peazip'                     = '';
	# Communication
	'discord'                    = '';
	'telegram'                   = '';
	'whatsapp'                   = '';
	# Ease of life
	'powertoys'                  = '';
	'eartrumpet'                 = '';
	'f.lux'                      = '';
	'speccy'                     = '';
	# 'everything' =' --params=''"/efu-association /run-on-system-startup /start-menu-shortcuts"''';
	# 'wox' = '';
	# PDF printer and editor
	'pdf24'                      = ' --params=''"/ Basic"''';
	# Media Player
	'vlc'                        = '';
	'spotify'                    = '';
	# Image Editor
	'paint.net'                  = '';
	# Password Manager
	'bitwarden'                  = '';
	'bitwarden-cli'              = '';
	# Remote access
	'chrome-remote-desktop-host' = '';
	'teamviewer'                 = '';
	# Torrent Client
	'qbittorrent'                = '';
}
$InstalledPackages = choco list -l -r --id-only
foreach ($pack in $PackagesToInstall.GetEnumerator()) {
	if (-not ($InstalledPackages -contains $pack.Key)) {
		choco install $pack.Key $pack.Value
	}
	else {
		Write-Output "$PackageName already installed, skipping."
	}
}
# Make sure that all the additions to the System Variables and the enviroment are available
Update-SessionEnvironment

Write-Output "... Completed configuration of Packages from Chocolatey"

#------------------------------------------------------------------------------
#                       Custom Powershell Modules
#------------------------------------------------------------------------------
Write-Output "Downloading Custom built PowerShell Modules from https://github.com/LeoCalbi/..."
if (Get-Command "git") {

	$UserModuleFolder = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\powershell\Modules"

	$MyUtilities = [PSCustomObject]@{
		Name  = "MyUtilities"
		Local = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\custom-psmodules\MyUtilities\"
		Repo  = "https://github.com/LeoCalbi/MyUtilities.git"
	}
	$GitStatusCachePoshClient = [PSCustomObject]@{
		Name  = "GitStatusCachePoshClient"
		Local = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\custom-psmodules\GitStatusCachePoshClient\"
		Repo  = "https://github.com/LeoCalbi/GitStatusCachePoshClient.git"
	}
	$ScreenFetch = [PSCustomObject]@{
		Name  = "ScreenFetch"
		Local = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\custom-psmodules\ScreenFetch\"
		Repo  = "https://github.com/LeoCalbi/ScreenFetch.git"
	}
	$modules = $MyUtilities, $GitStatusCachePoshClient, $ScreenFetch

	foreach ($m in $modules) {
		if (Test-Path $m.Local) {
			Write-Warning -Message "$($m.Name) folder already found. Skipping $($m.Name) installation.";
			git fetch
			git pull
		}
		else {
			Write-Output "Starting $($m.Name) installation..."
			git clone $m.Repo $m.Local
		}
		$mod = Get-Item -Path (Join-Path -Path $m.Local -ChildPath $m.Name)
		$dest = Join-Path -Path $UserModuleFolder -ChildPath $m.Name
		Set-SymLink -SrcPath $mod -DstPath $dest
		Write-Output "...$($m.Name) configuration completed."
	}
}
else {
	Write-Error "Git not found unable to install Custom Built Modules, skipping them."
}
Write-Output "...Completed installation of  Custom built PowerShell Modules"

# {{- end }}
