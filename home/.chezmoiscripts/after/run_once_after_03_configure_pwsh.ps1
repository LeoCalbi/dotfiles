#------------------------------------------------------------------------------
#                       Powershell Configuration
#------------------------------------------------------------------------------
#Requires -RunAsAdministrator

Write-Output "Configuring Powershell..."
# Set strong cryptography on 64 bit .Net Framework (version 4 and above)
if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -ErrorAction SilentlyContinue) -ne 1) {
    Write-Output "Setting strong cryptography on .Net Framework 64 bit."
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
}
# Set strong cryptography on 32 bit .Net Framework (version 4 and above)
if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -ErrorAction SilentlyContinue) -ne 1) {
    Write-Output "Setting strong cryptography on .Net Framework 32 bit."
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
}
Write-Output "...Completed Powershell configuration..."
