function "XBOX GAME BAR ISSUE"
{
<#
		This issue occurs because the Xbox Game Bar on Windows 10 is running in the background, and it remembers Teams as a game.
		Resolution
		To resolve this issue, use one of the following methods.
		Method 1: Disable Teams as a game

		Method 2: Disable Xbox Game Bar

		Select Start > Settings > Gaming > Xbox Game Bar
		Turn off Xbox Game Bar.
    #>
    write-host "removing gamebar"{
    Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage.
    }
}
