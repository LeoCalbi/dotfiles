

#Requires -RunAsAdministrator

# Create missing $IsWindows if running Powershell 5 or below.
if (!(Test-Path variable:global:IsWindows)) {
    Set-Variable "IsWindows" -Scope "Global" -Value ([System.Environment]::OSVersion.Platform -eq "Win32NT")
}

# ------------------------------------------------------------------------------
#                       Explorer, Taskbar, and System Tray
# ------------------------------------------------------------------------------
Write-Host "Configuring Explorer, Taskbar, and System Tray..."

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
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1

# Explorer: Show file extensions by default: Show Extensions: 0, Hide Extensions: 1
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# Explorer: Avoid creating Thumbs.db files on network volumes
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableThumbnailsOnNetworkFolders" 1

# ------------------------------------------------------------------------------
#                       System tweaks
# ------------------------------------------------------------------------------

# Enable LongPaths support for file paths above 260 characters.
# See https://social.msdn.microsoft.com/Forums/en-US/fc85630e-5684-4df6-ad2f-5a128de3deef
if ($IsWindows) {
    $property = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'
    $name = 'LongPathsEnabled'
    if ((Get-ItemPropertyValue $property -Name $name) -ne 0) {
        Write-Host "LongPaths support already enabled, skipping." -ForegroundColor $ColorInfo
    }
    else {
        Write-Host "Enabling LongPaths support for file paths above 260 characters." -ForegroundColor $ColorInfo
        Set-ItemProperty $property -Name $name -Value 1
        $count++
    }
}


#------------------------------------------------------------------------------
#                       Chocolatey and choco packages
#------------------------------------------------------------------------------

# Install Chocolatey on the local machine if not already present
if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey not installed, installing chocolatey...";
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-WebRequest -Uri https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
}

#TODO

#------------------------------------------------------------------------------
#                       Powershell Modules
#------------------------------------------------------------------------------

#TODO
