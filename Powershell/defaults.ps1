# Proper history etc
Import-Module PSReadLine

# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000;

Set-Alias -Name "trash" -Value Remove-ItemSafely -Description "Delete file"

Set-Alias -Name "~" -Value Set-LocationHome -Description "Goes to user home directory."

Set-Alias -Name "cd-" -Value Set-LocationLast -Description "Goes to last used directory."

Set-Alias -Name ".." -Value Set-LocationUp -Description "Goes up a directory."

Set-Alias -Name "..." -Value Set-LocationUp2 -Description "Goes up two directories."

Set-Alias -Name "...." -Value Set-LocationUp3 -Description "Goes up three directories."

Set-Alias -Name "....." -Value Set-LocationUp4 -Description "Goes up four directories."

Set-Alias -Name "......" -Value Set-LocationUp5 -Description "Goes up five directories."
function open($file) {
  invoke-item $file
}

function explorer {
  explorer.exe .
}

function edge {
  # Old Edge
  # start microsoft-edge:
  #
  # New Chromioum Edge
  & "${env:ProgramFiles(x86)}\Microsoft\Edge Dev\Application\msedge.exe"
}
function settings {
  start-process ms-settings:
}

# Oddly, Powershell doesn't have an inbuilt variable for the documents directory. So let's make one:
# From https://stackoverflow.com/questions/3492920/is-there-a-system-defined-environment-variable-for-documents-directory
$env:DOCUMENTS = [Environment]::GetFolderPath("mydocuments")

# PS comes preset with 'HKLM' and 'HKCU' drives but is missing HKCR
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null

# Truncate homedir to ~
#function limit-HomeDirectory($Path) {
#  $Path.Replace("$home", "~")
#}

# Must be called 'prompt' to be used by pwsh
# https://github.com/gummesson/kapow/blob/master/themes/bashlet.ps1

#function prompt {
#  $realLASTEXITCODE = $LASTEXITCODE
#  Write-Host $(limit-HomeDirectory("$pwd")) -ForegroundColor Yellow -NoNewline
#  Write-Host " $" -NoNewline
#  $global:LASTEXITCODE = $realLASTEXITCODE
#  Return " "
#}

# Make $lastObject save the last object output
# From http://get-powershell.com/post/2008/06/25/Stuffing-the-output-of-the-last-command-into-an-automatic-variable.aspx
function out-default {
  $input | Tee-Object -var global:lastobject | Microsoft.PowerShell.Core\out-default
}

#Unicode helper function
function U {
  param
  (
    [int] $Code
  )

  if ((0 -le $Code) -and ($Code -le 0xFFFF)) {
    return [char] $Code
  }

  if ((0x10000 -le $Code) -and ($Code -le 0x10FFFF)) {
    return [char]::ConvertFromUtf32($Code)
  }

  throw "Invalid character code $Code"
}

#Chocolatey Autocomplete
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

#Jump locations
Import-Module ZLocation

# If you prefer oh-my-posh
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme PowerLine
$DefaultUser = 'leoca'

function rename-extension($newExtension) {
  Rename-Item -NewName { [System.IO.Path]::ChangeExtension($_.Name, $newExtension) }
}
