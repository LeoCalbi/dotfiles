#------------------------------------------------------------------------------
#                       	Custom Powershell Modules
#------------------------------------------------------------------------------
#Requires -RunAsAdministrator

Write-Output "Upgrading Custom Powershell Modules..."
if (Get-Command "git") {
    $psmodules = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\custom-pwsh-modules\"
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
