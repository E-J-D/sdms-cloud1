# 25.11.2022 Eike Doose / INTERNAL USER ONLY / do not distribute
# Install IIS-FTP Server and config
# ===========================================

Function Get-Timestamp
{
$n=Get-Date
#pad values with leading 0 if necessary
$mo=(($n.Month).ToString()).PadLeft(2,"0")
$dy=(($n.Day).ToString()).PadLeft(2,"0")
$yr=($n.Year).ToString()
$hr=(($n.hour).ToString()).PadLeft(2,"0")
$mn=(($n.Minute).ToString()).PadLeft(2,"0")
$sec=(($n.Second).ToString()).PadLeft(2,"0")

$result=$yr+"-"+$mo+"-"+$dy+"_"+$hr+"-"+$mn+"-"+$sec

return $result
}
$t=Get-TimeStamp

Start-Transcript -Path "c:\install\_Log-Install-Starke-DMS_FTP-$t.txt" 

#  https://blog.eldernode.com/install-and-configure-ftp-server/
#  https://4sysops.com/archives/install-and-configure-an-ftp-server-with-powershell/

$FTPsiteFull = "IIS:\Sites\SDMSC1-FTPSite01"
$FTPsiteShort = "SDMSC1-FTPSite01"
$FTPsitePath = "d:\dms-data\ftp-root\SDMSC1-FTPSite01"
$FTPuserName = "SDMSC1-99999"
$FTPUserPassword = ConvertTo-SecureString "Admin00!" -AsPlainText -Force
$FTPgroup = "FTPGroup"
$FTProotFolderpath = "d:\dms-data\ftp-root"

Install-WindowsFeature Web-Ftp-Server -IncludeAllSubFeature -IncludeManagementTools
Install-Module -Name IISAdministration -force

Import-Module ServerManager
Add-WindowsFeature Web-Scripting-Tools
import-module WebAdministration

# https://blog.kmsigma.com/2016/02/25/removing-default-web-site-application-pool/
Remove-IISSite "Default Web Site" -Confirm:$False
# Remove-WebAppPool -Name "DefaultAppPool" -Confirm:$false -Verbose

# https://www.server-world.info/en/note?os=Windows_Server_2019&p=ftp&f=2
Set-WebConfiguration "/system.ftpServer/firewallSupport" -PSPath "IIS:\" -Value @{lowDataChannelPort="60000";highDataChannelPort="60100";} 
Restart-Service ftpsvc 

New-NetFirewallRule `
-Name "FTP Server Port" `
-DisplayName "FTP Server Port" `
-Description 'Allow FTP Server Ports' `
-Profile Any `
-Direction Inbound `
-Action Allow `
-Protocol TCP `
-Program Any `
-LocalAddress Any `
-LocalPort 21,60000-60100 

####   https://techexpert.tips/de/powershell-de/powershell-ersetzen-von-text-in-einer-datei/

# moved to Install-Starke-DMS_02.ps1 / 26.11.2022
# https://www.server-world.info/en/note?os=Windows_Server_2019&p=initial_conf&f=1
New-LocalUser -Name $FTPuserName `
-FullName "Starke-DMS Cloud 1.0 FileXchange user" `
-Description "FTP user" `
-Password $FTPUserPassword `
-PasswordNeverExpires `
-AccountNeverExpires 

New-LocalGroup -Name $FTPgroup
Add-LocalGroupMember -Group $FTPgroup -Member $FTPuserName 

mkdir $FTPsitePath 
New-WebFtpSite -Name $FTPsiteShort -IPAddress "*" -Port 21
Set-ItemProperty $FTPsiteFull -Name physicalPath -Value $FTPsitePath
Set-ItemProperty $FTPsiteFull -Name ftpServer.security.ssl.controlChannelPolicy -Value "SslAllow" 
Set-ItemProperty $FTPsiteFull -Name ftpServer.security.ssl.dataChannelPolicy -Value "SslAllow" 
Set-ItemProperty $FTPsiteFull -Name ftpServer.security.authentication.basicAuthentication.enabled -Value $true 

Add-WebConfiguration "/system.ftpServer/security/authorization" -Location $FTPsiteShort -PSPath IIS:\ -Value @{accessType="Allow";roles=$FTPgroup;permissions="Read,Write"} 

icacls $FTPsitePath /grant "FTPGroup:(OI)(CI)(F)" 

Restart-WebItem -PSPath $FTPsiteFull 

Set-ItemProperty $FTPsiteFull -Name ftpServer.security.ssl.controlChannelPolicy -Value "SslAllow" 
Set-ItemProperty $FTPsiteFull -Name ftpServer.security.ssl.dataChannelPolicy -Value "SslAllow" 

# Set-ItemProperty $FTPsiteFull -Name ftpServer.security.ssl.controlChannelPolicy -Value "SslRequire" 
# Set-ItemProperty $FTPsiteFull -Name ftpServer.security.ssl.dataChannelPolicy -Value "SslRequire" 

Set-ItemProperty $FTPsiteFull -Name ftpServer.security.ssl.serverCertStoreName -Value "My" 
Set-ItemProperty $FTPsiteFull -Name ftpServer.security.ssl.serverCertHash -Value (Get-ChildItem -path cert:\LocalMachine\My | Where-Object -Property Subject -like "CN=*").Thumbprint

Remove-Item C:\inetpub\ -recurse

Stop-Transcript
