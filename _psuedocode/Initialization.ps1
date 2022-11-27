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


#Teams install path 
    {
        $TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
        $TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe')
    }


if ($TeamsUpdateExePath - ) {
    
}
