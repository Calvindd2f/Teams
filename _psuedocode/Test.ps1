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

#Delete the HKEY_CURRENT_USER\Software\Microsoft\Office\Teams\PreventInstallationFromMsi registry value.
$users = (Get-ChildItem -path c:\users).name
foreach($user in $users)
 {
 reg load "hku\$user" "C:\Users\$user\NTUSER.DAT"
 # Do what you need with "hkey_users\$user" here which links to that user HKU
 # Example: reg add "hkey_users\$user\SOFTWARE\\Microsoft\Office\Teams\PreventInstallationFromMsi" /v "Yes" /t "REG_DWORD" /d "1" /f
            & "$env:windir\system32\reg.exe" DELETE HKEY_CURRENT_USER\Software\Microsoft\Office\Teams\PreventInstallationFromMsi /f
 &"$env:windir\system32\reg.exe" unload "hku\$user"
 }




. Redeploy Teams
<#
.SYNOPSIS

.DESCRIPTION
For some reason, I think that downloading the WebView2 Runtime prevent it occuring. Evergreen is the ideal scripting choice.
#>

$WV2 = 'https://go.microsoft.com/fwlink/p/?LinkId=2124703'

try
{
    IWR $WV2 -OutFile $env:TEMP\setup.exe
    if ([System.IO.File]::Exists($env:TEMP\setup.exe)) {
        Write-Host "Installing Microsoft Edge WebView2"
        
        $WebView2 = Start-Process $env:TEMP\setup.exe "-uninstall -s" -PassThru
        $WebView2.WaitForExit()
    }
    Write-Host "Success: Microsoft Edge WebView2 Installed"
    Remove-Item $env:TEMP\setup.exe
}
catch
{
    Write-Output "Uninstall failed with exception $_.exception.message"
    exit /b 1
}


<#
.SYNOPSIS
Preinstallation comment ; defaulting to 64-bit
.DESCRIPTION
-   The x86 architecture (32-bit or 64-bit) Teams supports is independent of other Office apps installed on a computer.
-   If you have 64-bit computers, we recommend installing the 64-bit Teams MSI even if the computer is running a 32-bit version of Office.
::  https://learn.microsoft.com/en-us/microsoftteams/msi-deployment

-   ’32-bit’
:   https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&managedInstaller=true&download=true

-   ’64-bit’
:   https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true
#>


function Install-Teams{
    param ( 
        [Parameter( Mandatory=$false,
            HelpMessage="fuck off")]
        [switch]$32)
        }
      
$86="https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&managedInstaller=true&download=true"
$64="https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"

try
{
    if ($32 -eq $false) 
    {
        Write-Host "Installing 64-bit Teams"
        Invoke-WebRequest $64 -OutFile $env:TEMP\Teams_windows_x64.msi -Wait
        $proc64 = msiexec /i Teams_windows_x64.msi OPTIONS="noAutoStart=true" ALLUSERS=1
        $proc64.WaitForExit()
        else 
        {
            Write-Host "Installing 32-bit Teams"
            Invoke-WebRequest $86 -OutFile $env:TEMP\Teams_windows_x86.msi -Wait
            $proc64 = msiexec /i Teams_windows_x64.msi OPTIONS="noAutoStart=true" ALLUSERS=1
            $proc64.WaitForExit()
        }
    }
}
catch
{
    Write-Output "Uninstall failed with exception $_.exception.message"
    exit /b 1
}
