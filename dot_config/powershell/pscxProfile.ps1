# ~/.config/powershell/pscxProfile.ps1
# ============================================================================
# PSCX powershell Module custom settings.
#
# On Windows, this file will be linked over to
# `$Env:USERPROFILE\Documents\WindowsPowershell\pscxProfile.ps1` and
# `$Env:USERPROFILE\Documents\Powershell\pscxProfile.ps1`
# after `chezmoi apply` by the script `../run_after_link-external.ps1.tmpl`.

<#
	.SYNOPSIS
		PSCX module utily aliases.
	.DESCRIPTION
		PSCX module utily aliases.
	.NOTES
		Leonardo Calbi
	.LINK
		https://github.com/LeoCalbi/dotfiles
#>


# -----------------------------------------------------------------------------
#                    Powershell Community Extensions
# -----------------------------------------------------------------------------

#                               Notes
# -----------------------------------------------------------------------------
# Additional aliases for the PSCX utility functions

#                               Aliases
# -----------------------------------------------------------------------------
Set-Alias -Name "unzip" -Value Expand-PscxArchive -Description "Unzip file"
