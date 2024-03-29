# 01.04.2022 Eike Doose / licenced for commerical use only - do not distribute
# ============================================================================
#
cls

Write-Host -ForegroundColor Yellow "#########################################"
Write-Host -ForegroundColor Yellow "Starke-DMS® and ABBYY will be uninstalled"
Write-Host -ForegroundColor Yellow "#########################################"

for ($i = 100; $i -gt 10; $i-- )
{
    Write-Progress -Activity "Countdown" -Status "$i%" -PercentComplete $i
    Start-Sleep -Milliseconds 25
}
cls
Write-Host -ForegroundColor Red "##########################################"
Write-Host -ForegroundColor Red "to cancel press STRG+C - otherwise any key"
Write-Host -ForegroundColor Red "##########################################"

pause

# uninstall DMS services
;Start-Process -Wait -FilePath 'sc.exe' -ArgumentList /delete -PassThru

cls
# uninstall ABBYY silent
Start-Process -Wait -FilePath 'C:\Program Files (x86)\StarkeDMS\uninstabbyy.exe' -ArgumentList /S -PassThru

# wait for the Starke-DMS® uninstaller to be finished
Wait-Process -Name uninstabbyy*
Start-Sleep -s 5

# uninstall Starke-DMS® silent
Start-Process -Wait -FilePath 'C:\Program Files (x86)\StarkeDMS\uninst.exe' -ArgumentList /S -PassThru

# wait for the Starke-DMS® uninstaller to be finished
Wait-Process -Name uninst*
Start-Sleep -s 5

# message when everything is done
Write-Host -ForegroundColor Yellow "################################################"
Write-Host -ForegroundColor Green  "#############  Everything done  ################"
Write-Host -ForegroundColor Green  "###  Thank you for using www.Starke-DMS.com  ###"
Write-Host -ForegroundColor Yellow "################################################"
