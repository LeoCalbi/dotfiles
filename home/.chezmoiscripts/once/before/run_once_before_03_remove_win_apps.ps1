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


# -----------------------------------------------------------------------------
#                          Default Windows Applications
# -----------------------------------------------------------------------------

#Requires -RunAsAdministrator

Write-Output "Configuring Default Windows Applications..."

$AppsToRemove = @(
	"*.AutodeskSketchBook",
	"*.DisneyMagicKingdoms",
	"*.Facebook",
	"*.MarchofEmpires",
	"*.SlingTV",
	"*.Twitter",
	"DolbyLaboratories.DolbyAccess",
	"Microsoft.3DBuilder",
	"Microsoft.BingFinance",
	"Microsoft.BingNews",
	"Microsoft.BingSports",
	"Microsoft.BingWeather",
	"Microsoft.GetStarted",
	"Microsoft.MixedReality.Portal",
	# "Microsoft.MSPaint",
	"Microsoft.Messaging",
	"Microsoft.MicrosoftOfficeHub",
	"Microsoft.MicrosoftSolitaireCollection",
	"Microsoft.MicrosoftStickyNotes",
	# "Microsoft.Office.OneNote",
	"Microsoft.Office.Sway",
	"Microsoft.OneConnect",
	"Microsoft.People",
	"Microsoft.Print3D",
	"Microsoft.SkypeApp",
	# "Microsoft.Windows.Photos",
	"Microsoft.WindowsAlarms",
	# "Microsoft.WindowsCommunicationsApps", # Mail and Calendar app
	"Microsoft.WindowsMaps",
	"Microsoft.WindowsFeedbackHub",
	# "Microsoft.WindowsPhone", # Your Phone
	# "Microsoft.WindowsSoundRecorder",
	"Microsoft.XboxApp",
	"Microsoft.ZuneMusic", # Groove
	"Microsoft.ZuneVideo",
	"SpotifyAB.SpotifyMusic",
	"king.com.BubbleWitch3Saga",
	"king.com.CandyCrushSodaSaga"
)

Uninstall-AppxPackages -Packages $AppsToRemove
Remove-Variable -Name "AppsToRemove"

# Uninstall unused Windows Features
$ToRemove = @(
	"WindowsMediaPlayer",
	"MSPaint",
	"Notepad",
	"WordPad"
)
$Capabilities = Get-WindowsCapability -Online | Where-Object "State" -EQ "Installed"
foreach ($rem in $ToRemove) {
	foreach ($cap in $Capabilities) {
		if ($cap.Name -like $rem) {
			Remove-WindowsCapability -Online $cap
			Write-Output "$rem is installed, removing."
		}
	}
}
Remove-Variable -Name "Capabilities"
Remove-Variable -Name "ToRemove"
# Prevent "Suggested Applications" from returning
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent")) { New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Type Folder | Out-Null }
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
