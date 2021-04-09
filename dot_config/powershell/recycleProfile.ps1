# ~/.config/powershell/recycleProfile.ps1
# ============================================================================
# Recycle powershell Module custom aliases.
#
# On Windows, this file will be linked over to
# `$Env:USERPROFILE\Documents\WindowsPowershell\recycleProfile.ps1`
# `$Env:USERPROFILE\Documents\Powershell\recycleProfile.ps1`
# after `chezmoi apply` by the script `../run_after_link-external.ps1.tmpl`.

<#
	.SYNOPSIS
		Recycle module utily aliases.
	.DESCRIPTION
		Recycle module utily aliases.
	.NOTES
		Leonardo Calbi
	.LINK
		https://github.com/LeoCalbi/dotfiles
#>


# -----------------------------------------------------------------------------
#                              Recycle
# -----------------------------------------------------------------------------

#                               Notes
# -----------------------------------------------------------------------------
# Override default Remove-Item aliases to use Remove-ItemSafely to avoid losing
# files and directories.
#                               Aliases
# -----------------------------------------------------------------------------
Set-Alias -Name "trash" -Value Remove-ItemSafely -Description "Delete file"

Set-Alias -Name "del" -Value Remove-ItemSafely -Description "Delete file" -Option AllScope

Set-Alias -Name "erase" -Value Remove-ItemSafely -Description "Delete file" -Option AllScope

Set-Alias -Name "rd" -Value Remove-ItemSafely -Description "Delete file" -Option AllScope

#Set-Alias -Name "ri" -Value Remove-ItemSafely -Description "Delete file"

Set-Alias -Name "rm" -Value Remove-ItemSafely -Description "Delete file" -Option AllScope

Set-Alias -Name "rmdir" -Value Remove-ItemSafely -Description "Delete file" -Option AllScope
