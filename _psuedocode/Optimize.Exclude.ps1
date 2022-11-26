# How to include or exclude Teams from antivirus or DLP applications \\
Add-MpPreference -ExclusionPath {
    "C:\Users\*\AppData\Local\Microsoft\Teams\current\teams.exe"
    "C:\Users\*\AppData\Local\Microsoft\Teams\update.exe"
    "C:\Users\*\AppData\Local\Microsoft\Teams\current\squirrel.exe"
}
