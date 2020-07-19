# BolgerUtils Module

Provides helper PowerShell functions.

Intended to be used with PowerShell Core:

https://github.com/PowerShell/PowerShell

Create a folder called **bolger-utils** within your PowerShell Modules directory and clone this repository within it.

The Modules directory is normally located at:

`%homepath%\Documents\PowerShell\Modules`

Include this import into your PowerShell profile:

```powershell
Import-Module -DisableNameChecking bolger-utils
```

See here to create / find your profile:

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles

## Enable Bash-Style Tab Completion in PowerShell

```powershell
# https://stackoverflow.com/questions/8264655/how-to-make-powershell-tab-completion-work-like-bash
Set-PSReadlineKeyHandler -Key Tab -Function Complete
```

## Disable PowerShell Beep

```powershell
# https://superuser.com/questions/1113429/disable-powershell-beep-on-backspace
Set-PSReadlineOption -BellStyle None
```
