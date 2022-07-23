
<#
	.SYNOPSIS
		Script to link files/folders outside of ~/.config/* with their respective target.
	.DESCRIPTION
		Script to link files/folders outside of ~/.config/* with their respective target.
	.NOTES
		Leonardo Calbi
	.LINK
		https://github.com/LeoCalbi/dotfiles
#>
Import-Module -Name Microsoft.PowerShell.Utility
#------------------------------------------------------------------------------
#                       Functions
#------------------------------------------------------------------------------
Function Uninstall-AppxPackages {
    <#
	.SYNOPSIS
		Uninstall target AppxPackages for all users.
	.INPUTS
		System.String[]
	.OUTPUTS
		None
	.LINK
		Remove-AppxPackage, Remove-AppxProvisionedPackage
	#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String[]]$Packages
    )
    if ($PSVersionTable.PSVersion.Major -gt 5) {
        Import-Module Appx -UseWindowsPowerShell
    }
    else {
        Import-Module Appx
    }
    $InstalledAppxs = Get-AppxPackage -AllUsers
    $InstalledProviders = Get-AppxProvisionedPackage -Online
    foreach ($pack in $Packages) {
        foreach ($appx in $InstalledAppxs) {
            if ($appx.Name -like $pack) {
                Remove-AppxPackage -AllUsers -Package $appx.PackageFullName
                Write-Output "$pack installed, removing."
            }
        }
        foreach ($prov in $InstalledProviders) {
            if ($prov.DisplayName -like $pack) {
                Write-Output "$pack provider installed, removing."
                Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $prov.PackageName
            }
        }
    }
}
Function Set-SymLink {
    <#
	.SYNOPSIS
		Check target and create/update it using symlink to the source corresponding one.
	.INPUTS
		System.IO.FileSystemInfo
		System.String
	.OUTPUTS
		None
	.LINK
		New-Item
	#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$SrcPath,

        [Parameter(Mandatory = $true)]
        [String]$DstPath
    )
    $done = $false
    if (-not (Test-Path -Path $DstPath)) {
        Write-Output "$DstPath doesn't exist.";
    }
    else {
        $element = Get-Item -Path $DstPath
        Switch ($element.LinkType) {
            $null {
                if (Test-Path -Path $DstPath -PathType Container) {
                    Write-Output "$DstPath is a folder checking before transforming it into symlink.";
                    if ((Get-ChildItem -Path $DstPath | Measure-Object).Count -gt 0) {
                        Write-Warning "Folder is not empty, check the content and confirm deletion before creating symlink."
                        Write-Output (Get-ChildItem -Path $DstPath)
                        Remove-Item -Path $DstPath -Recurse -Confirm
                    }
                    else {
                        Write-Warning "Folder is empty, confirm deletion before creating symlink."
                        Remove-Item -Path $DstPath -Confirm
                    }
                }
                else {
                    Write-Warning "$DstPath is a file, check the content and confirm deletion before creating symlink.";
                    Remove-Item -Path $DstPath -Confirm
                }
                Break
            }
            "HardLink" {
                Write-Warning "$DstPath is a hardlink that targets $($element.Target) delete it to transform it into a symlink.";
                Remove-Item -Path $DstPath -Confirm
                Break
            }
            "Junction" {
                Write-Warning "$DstPath is a junction that targets $($element.Target) delete it to transform it into a symlink.";
                Remove-Item -Path $DstPath -Confirm
                Break
            }
            "SymbolicLink" {
                if ($element.Target -ne $SrcPath.FullName) {
                    Write-Warning "$DstPath is a symlink that targets $($element.Target) delete it to transform it into a correct symlink.";
                    Remove-Item -Path $DstPath -Confirm
                }
                else {
                    Write-Output "$DstPath is a symlink that target source $($element.Target), nothing to do."
                    $done = $true
                }
                Break
            }
            default {
                Write-Output $element.LinkType
                Write-Warning -Message "Type of $DstPath unknown.";
                Break
            }
        }
    }
    if (-not $done) {
        $skip = Test-Path $DstPath
        if (-not $skip) {
            Write-Output "Creating symlink.";
            New-Item -ItemType SymbolicLink -Path $DstPath -Value $SrcPath.FullName
            if ((Test-Path $SrcPath.FullName -PathType Container) -and ((Get-Item -Path $DstPath).Target -ne $SrcPath.FullName)) {
                Write-Error -Message "$($SrcPath.FullName) and $DstPath not corresponding, check for errors.";
            }
            elseif ((Test-Path $SrcPath.FullName -PathType Leaf) -and ((Get-FileHash $SrcPath.FullName).Hash -ne (Get-FileHash $DstPath).Hash)) {
                Write-Error -Message "$($SrcPath.FullName) and $DstPath not corresponding, check for errors.";
            }
            else {
                Write-Output "$DstPath updated succesfully."
            }
        }
        else {
            Write-Warning "$DstPath configuration skipped."
        }
    }
}
