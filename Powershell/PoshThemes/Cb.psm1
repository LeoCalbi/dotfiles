#requires -Version 2 -Modules posh-git

function Write-Theme {

    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $lastColor = $sl.Colors.PromptBackgroundColor

    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $sFailed = "$($sl.PromptSymbols.FailedCommandSymbol) "
    }

    #check for elevated prompt
    If (Test-Administrator) {
        $sAdmin = "$($sl.PromptSymbols.ElevatedSymbol) "
    }


    $user = $sl.CurrentUser
    $computer = [System.Environment]::MachineName
    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    if (Test-VirtualEnv) {
        $spreVenv = "$($sl.PromptSymbols.SegmentForwardSymbol) "
        $sVenv = "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) "
        $spostVenv = "$($sl.PromptSymbols.SegmentForwardSymbol) "
    }
    else {
        $spostVenv = "$($sl.PromptSymbols.SegmentForwardSymbol) "
    }

    # Writes the drive portion
    $path = (Get-FullPath -dir $pwd).Replace('\', ' ' + [char]::ConvertFromUtf32(0xE0B1) + ' ') + ' '
    $prompt += Write-Prompt -Object $path -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $lastColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor
    }

    if ($with) {
        $spreWith = $sl.PromptSymbols.SegmentForwardSymbol
        $sWith = " $($with.ToUpper()) "
    }

    $sTime = " [$(Get-Date -Format HH:mm:ss)] "

    If ($sl.DoubleCommandLine) {
        $prompt += Set-Newline
    }

    $rightprompt = "$sFailed$sWith$sVenv$sAdmin$sTime"
    $prompt += Set-CursorForRightBlockWrite -textLength $rightPrompt.Length
    $prompt += Write-Prompt $sFailed -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    $prompt += Write-Prompt $spreWith -ForegroundColor $lastColor -BackgroundColor $sl.Colors.WithBackgroundColor
    $prompt += Write-Prompt $sWith -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    $lastColor = $sl.Colors.WithBackgroundColor
    $prompt += Write-Prompt $sAdmin -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    $prompt += Write-Prompt $spreVenv -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
    $prompt += Write-Prompt $sVenv -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
    $prompt += Write-Prompt $spostVenv -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    $prompt += Write-Prompt $sTime -ForegroundColor $sl.colors.TimestampForegroundColor



    # Writes the postfix to the prompt
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.Colors.SessionInfoBackgroundColor = [ConsoleColor]::DarkGray
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::DarkGray
$sl.Colors.WithForegroundColor = [ConsoleColor]::White
$sl.Colors.WithBackgroundColor = [ConsoleColor]::DarkRed
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
$sl.Colors.TimestampForegroundColor = [ConsoleColor]::DarkCyan
$sl | Add-Member -NotePropertyName DoubleCommandLine -NotePropertyValue 0
