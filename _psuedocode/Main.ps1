function Install-Teams
{
        {<#
              .SYNOPSIS
              Preinstallation comment ; defaulting to 64-bit
              .DESCRIPTION
              -   The x86 architecture (32-bit or 64-bit) Teams supports is independent of other Office apps installed on a computer.
              -   If you have 64-bit computers, we recommend installing the 64-bit Teams MSI even if the computer is running a 32-bit version of Office.
              :: https://learn.microsoft.com/en-us/microsoftteams/msi-deployment
              -   '32-bit'
              :   https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&managedInstaller=true download=true
              -   '64-bit'
              :   https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true
         #>}
}       


 
$URL32='https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&managedInstaller=true&download=true'
$URL64='https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true'
$T32 = 'Teams_windows_x86'
$T64 = 'Teams_windows_x64'
$WV2 = 'https://go.microsoft.com/fwlink/p/?LinkId=2124703'
$WebView2 = 'setup.exe'


#Install WebView2 Driver for Teams ; it no longer uses electron.
Invoke-WebRequest $WV2 -OutFile $env:TEMP\setup.exe -Wait

Write-Verbose -Message 'Installing Microsoft Edge WebView2'
$WebView2 = Start-Process $env:TEMP\$WebView2 '-uninstall -s' -PassThru
$WebView2.WaitForExit()

Write-Verbose -Message 'Success: Microsoft Edge WebView2 Installed'
Remove-Item $env:TEMP\setup.exe

catch [Exception] {
  Write-Output ('Uninstall failed with exception {0}.exception.message' -f $_)
  exit /b 1
  }
  



#Download
if ($32bit)  
{
  Write-Verbose 'Downloading 32-bit , bad idea.'
  $webclient = New-Object System.Net.WebClient
  $file = ($env:temp, ('{0}' -f $T32) -f $T32)
  $webclient.DownloadFile($URL32,('{0}' -f $file)) 
}

else {
  Write-Verbose 'Downloading Teams.'
  $webclient = New-Object System.Net.WebClient
  $file = ($env:temp, ('{0}' -f $T64))
  $webclient.DownloadFile($URL64,('{0}' -f $file)-f $file)
  }


#Install
if ($file -match $T32) { 
  Write-Verbose 'Installing Teams 32-bit.'
  $proc32 = & "$env:windir\system32\msiexec.exe" /i $file OPTIONS="noAutoStart=true" ALLUSERS=1
  $proc32.WaitForExit()
  }
else {
  Write-Verbose 'Downloading Teams 64-bit.'
  $proc64 = & "$env:windir\system32\msiexec.exe" /i $file OPTIONS="noAutoStart=true" ALLUSERS=1
  $proc64.WaitForExit()
  }


Write-Output 'Install Complete ; continuing for other optimizations'


# Exclude Teams from antivirus or DLP applications.

Add-MpPreference -ExclusionPath {
    'C:\Users\*\AppData\Local\Microsoft\Teams\current\teams.exe'
    'C:\Users\*\AppData\Local\Microsoft\Teams\update.exe'
    'C:\Users\*\AppData\Local\Microsoft\Teams\current\squirrel.exe'
    }
    


# Disable Xbox Game Bar
Write-Verbose -Message 'Removing Gamebar'


# Creates firewall rules for Teams.
$users = Get-ChildItem (Join-Path -Path $env:SystemDrive -ChildPath 'Users') -Exclude 'Public', 'ADMINI~*'
if ($null -ne $users) {
  foreach ($user in $users) {
    $progPath = Join-Path -Path $user.FullName -ChildPath 'AppData\Local\Microsoft\Teams\Current\Teams.exe'
    if (Test-Path $progPath) {
      if (-not (Get-NetFirewallApplicationFilter -Program $progPath -ErrorAction SilentlyContinue)) {
        $ruleName = ('Teams.exe for user{0}' -f $user.Name).Name
        'UDP', 'TCP' | ForEach-Object { New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Profile Domain -Program $progPath -Action Allow -Protocol $_ }
        Clear-Variable ruleName
        }
        Clear-Variable progPath
        }
    }
}


function Nuke-Teams 
{  <#
        .SYNOPSIS
        This script uninstalls the Teams app and removes the Teams directory for a user.
        .DESCRIPTIOjN
        Use this script to remove and clear the Teams app from a computer. Run this PowerShell script for each user profile in which Teams was installed on the computer. After you run this script for all user profiles, redeploy Teams.
        #>

  #Path to Nuke 
  {
    $TeamsPath = [IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [IO.Path]::Combine($TeamsPath, 'Update.exe') 
  }
  try 
  {
    if ([IO.File]::Exists($TeamsUpdateExePath)) 
      { Write-Verbose -Message 'Uninstalling Teams process'
        # Uninstall app
        $proc = Start-Process $TeamsUpdateExePath '-uninstall -s' -PassThru
        $proc.WaitForExit()
        }
    Write-Verbose -Message 'Deleting Teams directory'
    Remove-Item -path $TeamsPath -recurse
    }
  catch
    {
      Write-Output "Uninstall failed with exception $_.exception.message"
      exit /b 1
      }
      }




Write-Output 'Teams Uninstalled 
 Removing artifacts'
#Delete the HKEY_CURRENT_USER\Software\Microsoft\Office\Teams\PreventInstallationFromMsi registry value.
    $users = (Get-ChildItem -path c:\users).name
    foreach($user in $users)
    {
        & "$env:windir\system32\reg.exe" load "hku\$user" "C:\Users\$user\NTUSER.DAT"
        # Do what you need with "hkey_users\$user" here which links to that user HKU
        & "$env:windir\system32\reg.exe" DELETE HKEY_CURRENT_USER\Software\Microsoft\Office\Teams\PreventInstallationFromMsi /f
        &"$env:windir\system32\reg.exe" unload "hku\$user"
    }


Write-Output 'Teams Cleared'


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
        $TeamsPath = [IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
        $TeamsUpdateExePath = [IO.Path]::Combine($TeamsPath, 'Update.exe')
    }

    #CheckPath
    if ($TeamsUpdateExePath -and $TeamsPath -eq $true ) 
    { 
        Write-Verbose -Message 'Stopping Teams'
        Get-Process -Name Teams | Stop-Process -Force
        Clear-Host
        Write-Verbose -Message 'Teams Stopped, please wait...'
        Clear-Host
        Write-Verbose -Message 'Nuking Teams, please wait...'
        Nuke-Teams -Wait
        Write-Verbose -Message 'Nuked proceeding with reinstall + optimizations...'
        Add-Teams -Wait
    } 
    else 
    { 
        Write-Verbose -Message "No Install detected , proceeding with install + optimizations...."
        Add-Teams -Wait
    }
}

Start-Initialization

# SIG # Begin signature block
# MIID4QYJKoZIhvcNAQcCoIID0jCCA84CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUb76vdzEejLGya6+NhGJ0zOZD
# Dy6gggH/MIIB+zCCAWSgAwIBAgIQLuaXxFn1/pxIZhFVWOKtzzANBgkqhkiG9w0B
# AQUFADAYMRYwFAYDVQQDDA1DYWx2aW4gQmVyZ2luMB4XDTIyMTEyNDIzNTUyMloX
# DTI2MTEyNDAwMDAwMFowGDEWMBQGA1UEAwwNQ2FsdmluIEJlcmdpbjCBnzANBgkq
# hkiG9w0BAQEFAAOBjQAwgYkCgYEA0CJQbA8DCnj0Yx3hJmIpe7bFiPLwQcHDDhv8
# Y+hfylUaNN9klScDUUn4ltQJiGNQKMo0sPNtY9yPnKn47AcUSPYdBTXZ1UxiPy5j
# 6NWHuwb2uUdhk1ikS/jLavOeU/By18EvqPAssgrv0KOVpaT8Ybc4LI29TMi5GIAc
# lMEPUQUCAwEAAaNGMEQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFM57
# oB96pRHrL3MoOVlUoZ4qlFiQMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQUF
# AAOBgQAMVjR7o8/FNhchjFQtNHwnvdYKTDveukc76CoMhpZ6HfHmku1OjskhElvo
# LNU80cDp1ffuBxt6Rc7Res08ucT/tfABkKgcxTKLJeqUU5dJF6HddZPYpjXiiYxL
# AOb6pt2A0MzsSHNChGgC4kY3JROYey77BaZz1LEDQ2yJuvzbwzGCAUwwggFIAgEB
# MCwwGDEWMBQGA1UEAwwNQ2FsdmluIEJlcmdpbgIQLuaXxFn1/pxIZhFVWOKtzzAJ
# BgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAj
# BgkqhkiG9w0BCQQxFgQUKolX3ux1dVPvLQ+Z8RVKVOswJk8wDQYJKoZIhvcNAQEB
# BQAEgYDLj8y+1Z6HK0vM2dQ94Ow40xvuRrPg27eS7Okxh5qd0bwRL6p1avtD3AEW
# i9mytsc/+Iwvhfo3eFkcMWp0ruPz/Mq39LfiPaL7VqHtLEENzM2Yp2t7kSmj8Ea7
# RigFm21O2JhgACVM8MKyIIRG9wehE+cKekADM00gbVlCqck1wQ==
# SIG # End signature block
