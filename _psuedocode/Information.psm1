
https://learn.microsoft.com/en-us/microsoftteams/msi-deployment
#The x86 architecture (32-bit or 64-bit) Teams supports is independent of other Office apps installed on a computer.
#If you have 64-bit computers, we recommend installing the 64-bit Teams MSI even if the computer is running a 32-bit version of Office.




#’32-bit’
msiexec /i Teams_windows.msi /qn ALLUSERS=1
https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&managedInstaller=true&download=true



#’64-bit’
msiexec /i Teams_windows_x64.msi /qn ALLUSERS=1
https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true





\\ donotdelete \
%SystemDrive%\Program Files (x86)\Teams Installer


\\installdir \

%LocalAppData%\Microsoft\Teams




// cleanup and redeploment

Uninstall the Teams app installed for every user profile. For more information, see Uninstall Microsoft Teams.

Delete the directory recursively under %LocalAppData%\Microsoft\Teams\ for each user profile.

Delete the HKEY_CURRENT_USER\Software\Microsoft\Office\Teams\PreventInstallationFromMsi registry value for each user profile.

Redeploy the MSI file to that particular computer.



PowerShell script sample - Teams deployment clean up

<#
.SYNOPSIS
This script uninstalls the Teams app and removes the Teams directory for a user.
.DESCRIPTION
Use this script to remove and clear the Teams app from a computer. Run this PowerShell script for each user profile in which Teams was installed on the computer. After you run this script for all user profiles, redeploy Teams.
#>

$TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
$TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe')

try
{
    if ([System.IO.File]::Exists($TeamsUpdateExePath)) {
        Write-Host "Uninstalling Teams process"

        # Uninstall app
        $proc = Start-Process $TeamsUpdateExePath "-uninstall -s" -PassThru
        $proc.WaitForExit()
    }
    Write-Host "Deleting Teams directory"
    Remove-Item –path $TeamsPath -recurse
}
catch
{
    Write-Output "Uninstall failed with exception $_.exception.message"
    exit /b 1
}
You can also use our Teams deployment clean up script to complete steps 1 and 2.





//  Disable auto launch {after setup} for the MSI installer /

For the 32-bit version:
	msiexec /i Teams_windows_x64.msi OPTIONS="noAutoStart=true" ALLUSERS=1

msiexec /i Teams_windows.msi OPTIONS="noAutoStart=true" ALLUSERS=1
	msiexec /i Teams_windows_x64.msi OPTIONS="noAutoStart=true" ALLUSERS=1

Sample script - Microsoft Teams firewall PowerShell script

<#
.SYNOPSIS
   Creates firewall rules for Teams.
.DESCRIPTION
   (c) Microsoft Corporation 2018. All rights reserved. Script provided as-is without any warranty of any kind. Use it freely at your own risks.
   Must be run with elevated permissions. Can be run as a GPO Computer Startup script, or as a Scheduled Task with elevated permissions.
   The script will create a new inbound firewall rule for each user folder found in c:\users.
   Requires PowerShell 3.0.
#>

#Requires -Version 3

$users = Get-ChildItem (Join-Path -Path $env:SystemDrive -ChildPath 'Users') -Exclude 'Public', 'ADMINI~*'
if ($null -ne $users) {
    foreach ($user in $users) {
        $progPath = Join-Path -Path $user.FullName -ChildPath "AppData\Local\Microsoft\Teams\Current\Teams.exe"
        if (Test-Path $progPath) {
            if (-not (Get-NetFirewallApplicationFilter -Program $progPath -ErrorAction SilentlyContinue)) {
                $ruleName = "Teams.exe for user $($user.Name)"
                "UDP", "TCP" | ForEach-Object { New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Profile Domain -Program $progPath -Action Allow -Protocol $_ }
                Clear-Variable ruleName
            }
        }
        Clear-Variable progPath
    }
}



'// How to include or exclude Teams from antivirus or DLP applications /

Add-MpPreference -ExclusionPath {

    "C:\Users\*\AppData\Local\Microsoft\Teams\current\teams.exe"
    "C:\Users\*\AppData\Local\Microsoft\Teams\update.exe"
    "C:\Users\*\AppData\Local\Microsoft\Teams\current\squirrel.exe"
}



//  Clear Teams cache in Windows  /

If Teams is still running, right-click the Teams icon in the taskbar, and then select Quit.
Open the Run dialog box by pressing the Windows logo key  +R.
In the Run dialog box, enter %appdata%\Microsoft\Teams, and then select OK.
Delete all files and folders in the %appdata%\Microsoft\Teams directory.
Restart Teams.



//  Teams performance is affected if it''s remembered as a game by Xbox Game Bar   /

This issue occurs because the Xbox Game Bar on Windows 10 is running in the background, and it remembers Teams as a game.

Resolution
To resolve this issue, use one of the following methods.

Method 1: Disable Teams as a game
    

Method 2: Disable Xbox Game Bar

    #Select Start > Settings > Gaming > Xbox Game Bar
    #Turn off Xbox Game Bar.    {
    Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage.
}
'

//  User information isn''t updated in Microsoft Teams /
 <#  
    User information isn''t updated in Microsoft Teams
        Article
        09/19/2022
        2 minutes to read
        5 contributors
        Applies to:
        Microsoft Teams
        After user attributes are updated in Microsoft Teams, users continue to see the old information in the Teams client. User attributes include information such as display name, telephone number, manager, and profile photo.

    This behavior is by design.

    Teams has a caching scheme that is designed for capacity and performance optimization. The Teams service caches general user information for up to three days. The Teams client also caches general user information locally. Some data, such as display name and telephone number, can be cached up to 28 days in the client. Profile photos can be cached up to 60 days.
    
    To clear the cache and receive updated information, sign out of Teams, and then sign back in. Or, manually clear Teams cache.
    
        #>  
