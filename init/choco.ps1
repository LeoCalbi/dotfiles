Set-ExecutionPolicy Unrestricted

#Fake jre - jdk installations for dependencies, I use openjdk
choco install jre8 -n
choco pin add -n=jre8
choco install jdk8 -n
choco pin add -n=jdk8
choco install javaruntime -n
choco pin add -n=javaruntime

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
choco install utorrent
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

#Developer stuff
choco install vscode
choco install powershell
choco install powershell-core
choco install git.install
choco install openjdk
choco install python -m
choco install python --version=3.7.5 -m
choco install ant -i
choco install curl
choco install nuget.commandline
choco install nvm.portable
choco install ruby
#choco install vim
choco install webpi
#choco install eclipse
choco install speccy
choco install powertoys
choco install microsoft-windows-terminal

#Node installation
nvm install latest

npm install -g windows-build-tools


#Powershell 6 modules install
Set-PSRepository -name PSGallery -InstallationPolicy Trusted
Install-Module Pscx -Scope CurrentUser
Install-Module -Name Recycle -Scope CurrentUser
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
