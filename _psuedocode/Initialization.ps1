function Initialization
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
