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
