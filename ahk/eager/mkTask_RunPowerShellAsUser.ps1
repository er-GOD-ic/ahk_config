$action = New-ScheduledTaskAction -Execute "powershell.exe" -WorkingDirectory $env:USERPROFILE
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd

Register-ScheduledTask -TaskName "RunPowerShellAsUser" -Action $action -Principal $principal -Settings $settings
