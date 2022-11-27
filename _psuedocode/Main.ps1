function Install-Teams 
{  
    {
        <#
        .SYNOPSIS
        Preinstallation comment ; defaulting to 64-bit
        .DESCRIPTION
        -   The x86 architecture (32-bit or 64-bit) Teams supports is independent of other Office apps installed on a computer.
        -   If you have 64-bit computers, we recommend installing the 64-bit Teams MSI even if the computer is running a 32-bit version of Office.
        :: https://learn.microsoft.com/en-us/microsoftteams/msi-deployment
         -   ’32-bit’
         :   https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&managedInstaller=true&download=true
         -   ’64-bit’
         :   https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true
         #>
     }
     
     [CmdletBinding()] Param(

        [Parameter(Position = 0, Mandatory = $False)]
        [Switch]
        $32bit =  https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&managedInstaller=true&download=true

        [Parameter(Position = 1, Mandatory = $False)]
        [Switch]
        $null = "echo nothing"
        )
    
    $URL32="https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&managedInstaller=true&download=true"
    $URL64="https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
    $T32 = "Teams_windows_x86"
    $T64 = "Teams_windows_x64"
    $WV2 = 'https://go.microsoft.com/fwlink/p/?LinkId=2124703'
    $WebView2 = "setup.exe"


    "Install WebView2 Driver for Teams ; it no longer uses electron."
    {
        IWR $WV2 -OutFile $env:TEMP\setup.exe -Wait {
            if ([System.IO.File]::Exists($env:TEMP\$WebView2)) {
                Write-Host "Installing Microsoft Edge WebView2"
                $WebView2 = Start-Process $env:TEMP\$WebView2 "-uninstall -s" -PassThru
                $WebView2.WaitForExit()
            }
            Write-Host "Success: Microsoft Edge WebView2 Installed"
            Remove-Item $env:TEMP\setup.exe
        }
        catch [Exception]
        {
            Write-Output "Uninstall failed with exception $_.exception.message"
            exit /b 1
        }
    }



    "Download"
    {
        if ($32bit)
        {
             Write-Verbose "Downloading 32-bit , bad idea."
             $webclient = New-Object System.Net.WebClient
              $file = "$env:temp\$T32"
              $webclient.DownloadFile($URL32,"$file")
          }
          else {
            Write-Verbose "Downloading Teams."
            $webclient = New-Object System.Net.WebClient
            $file = "$env:temp\$T64"
            $webclient.DownloadFile($URL64,"$file")
        }
    }


    "Install"
    if ($file -match $T32
    { 
        Write-Verbose "Installing Teams 32-bit."
        $proc32 = msiexec /i $file OPTIONS="noAutoStart=true" ALLUSERS=1
        $proc32.WaitForExit()
    }
    else 
    {
        Write-Verbose "Downloading Teams 64-bit."
        $proc64 = msiexec /i $file OPTIONS="noAutoStart=true" ALLUSERS=1
        $proc64.WaitForExit()
    }

    
    
    Write-Output "Install Complete ; continuing for other optimizations"

    

    # Exclude Teams from antivirus or DLP applications.
    {
        Add-MpPreference -ExclusionPath {
            "C:\Users\*\AppData\Local\Microsoft\Teams\current\teams.exe"
            "C:\Users\*\AppData\Local\Microsoft\Teams\update.exe"
            "C:\Users\*\AppData\Local\Microsoft\Teams\current\squirrel.exe"
        }
    }

    

    # Disable Xbox Game Bar
    {
        write-host "Removing Gamebar"
        {
            Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage
        }
    }

    


    # Creates firewall rules for Teams.
    {
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
    }
}


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


function Start-Initialization 
{
    {
        <#
        .SYNOPSIS
        Checks if currently installed.
        .DESCRIPTION
        This checks if teams is installed or not. It uninstalls and cleans if it detects Teams. It skips straight to download if not installed.
        #>
    }

    #Teams install path. 
    {
        $TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
        $TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe')
    }

    #CheckPath
    if ($TeamsUpdateExePath -and $TeamsPath -eq $true ) 
    { 
        Write-Host "Stopping Teams" -ForegroundColor Yellow
        Get-Process -ProcessName Teams | Stop-Process -Force
        Clear
        Write-Host "Teams Stopped, please wait..." -ForegroundColor Green
        Clear
        Write-Host "Nuking Teams, please wait..." -ForegroundColor Green
        Nuke-Teams -Wait
        Write-Host "Nuked ; proceeding with reinstall + optimizations..." -ForegroundColor Green
        Add-Teams -Wait
    } 
    else 
    { 
        Write-Host "No Install detected , proceeding with install + optimizations..." -ForegroundColor Green
        Add-Teams -Wait
    }
}

Start-Initialization
