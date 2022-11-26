function Nuke-Teams
{
    {
        <#
        .SYNOPSIS
        This script uninstalls the Teams app and removes the Teams directory for a user.
        .DESCRIPTION
        Use this script to remove and clear the Teams app from a computer. Run this PowerShell script for each user profile in which Teams was installed on the computer. After you run this script for all user profiles, redeploy Teams.
        #>
    }
    #Path to Nuke 
    {
        $TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
        $TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe'
    }
    try
    {
        if ([System.IO.File]::Exists($TeamsUpdateExePath)) {
            Write-Host "Uninstalling Teams process"
            # Uninstall app
            $p
            $proc.WaitForExit()roc = Start-Process $TeamsUpdateExePath "-uninstall -s" -PassThru
        }
        Write-Host "Deleting Teams directory"
        Remove-Item –path $TeamsPath -recurse
        }
        catch
        {
            Write-Output "Uninstall failed with exception $_.exception.message"
            exit /b 1
        }
    }
    Write-Output "Teams Uninstalled ; Removing artifacts"

    #Delete the HKEY_CURRENT_USER\Software\Microsoft\Office\Teams\PreventInstallationFromMsi registry value.
    $users = (Get-ChildItem -path c:\users).name
    foreach($user in $users)
    {
        reg load "hku\$user" "C:\Users\$user\NTUSER.DAT"
        # Do what you need with "hkey_users\$user" here which links to that user HKU
        & "$env:windir\system32\reg.exe" DELETE HKEY_CURRENT_USER\Software\Microsoft\Office\Teams\PreventInstallationFromMsi /f
        &"$env:windir\system32\reg.exe" unload "hku\$user"
    }
    Write-Output "Teams Cleared"
}
