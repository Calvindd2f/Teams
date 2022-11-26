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
}
