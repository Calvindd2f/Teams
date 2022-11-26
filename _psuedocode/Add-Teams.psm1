function Add-Teams
{
    $WV2 = 'https://go.microsoft.com/fwlink/p/?LinkId=2124703'
    $File = "setup.exe"
    try
    {
        IWR $WV2 -OutFile $env:TEMP\setup.exe -Wait
        if ([System.IO.File]::Exists($env:TEMP\$File)) 
        {
            Write-Host "Installing Microsoft Edge WebView2"
            $WebView2 = Start-Process $env:TEMP\$File "-uninstall -s" -PassThru
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
        }
    }
}
