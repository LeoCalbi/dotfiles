# ~/.local/share/chezmoi/home/.chezmoiscripts/run_once_1_system_setup.ps1
# ============================================================================

#------------------------------------------------------------------------------
#                       Custom Powershell Modules
#------------------------------------------------------------------------------

#Requires -RunAsAdministrator

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
