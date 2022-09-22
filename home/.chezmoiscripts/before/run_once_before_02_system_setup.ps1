# ------------------------------------------------------------------------------
#                       Explorer, Taskbar, and System Tray
# ------------------------------------------------------------------------------

#Requires -RunAsAdministrator

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

# Enable Hyper-V for virtualization and Windows Subsystem for Linux
if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V).State -ne "Enabled") {
	Write-Output "Enabling Hyper-V features, remember to restart the system at the end of the procedure."
	Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
}
else {
	Write-Output "Hyper-V features already enabled, skipping."
}
