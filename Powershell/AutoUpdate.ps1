# 31.03.2022 Eike Doose
#	Windows Updates with PowerShell
# http://woshub.com/pswindowsupdate-module/
# https://www.itechtics.com/run-windows-update-cmd/

# Install PSWindowsUpdate Modul for PowerShell
Write-Host 
Write-Host -ForegroundColor Yellow "################################################"
Write-Host -ForegroundColor Yellow "# Install PSWindowsUpdate Modul for PowerShell #"
Write-Host -ForegroundColor Yellow "################################################"
Write-Host
pause
Install-Module -Name PSWindowsUpdate -Force

# Install all pending Updates and restart without asking
Write-Host 
Write-Host -ForegroundColor Yellow "##########################################################"
Write-Host -ForegroundColor Yellow "# Install all pending Updates and restart without asking #"
Write-Host -ForegroundColor Yellow "##########################################################"
Write-Host
pause
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
