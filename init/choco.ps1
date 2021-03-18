Set-ExecutionPolicy Unrestricted

#Java Virtual Machine
choco install jre
choco install jdk
choco install javaruntime

#User programs
choco install adobereader
choco install googlechrome
choco install vlc
#choco install calibre
choco install sublimetext3
#choco install steam
choco install google-backup-and-sync
choco install chrome-remote-desktop-host
choco install pdf24
choco install geforce-game-ready-driver
choco install bittorrent
choco install teamviewer
choco install whatsapp
choco install telegram
choco install spotify
choco install peazip


#Easy Life Programs
choco install everything
choco install wox -i
choco install quicklook
choco install edgedeflector
choco install powertoys

#Developer stuff
choco install vscode
choco install powershell
choco install pwsh
choco install git
choco install gh
choco install curl
choco install nuget.commandline
choco install nvm.portable
choco install ruby
choco install speccy
choco install microsoft-windows-terminal

#Node installation
nvm install latest

#Powershell Modules install
Set-PSRepository -name PSGallery -InstallationPolicy Trusted
Install-Module Pscx -Scope CurrentUser
Install-Module -Name Recycle -Scope CurrentUser
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
