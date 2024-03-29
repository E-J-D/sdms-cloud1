# 25.11.2022 Eike Doose / INTERNAL USER ONLY / do not distribute
# Install-Starke-DMS_FTP.ps1 install IIS FTP 
# ===========================================

#  https://blog.eldernode.com/install-and-configure-ftp-server/
#  https://4sysops.com/archives/install-and-configure-an-ftp-server-with-powershell/

# Install the Windows feature for FTP
Install-WindowsFeature Web-Ftp-Server -IncludeAllSubFeature -IncludeManagementTools -Verbose
# Install-WindowsFeature Web-Server -IncludeAllSubFeature -IncludeManagementTools
Install-Module -Name IISAdministration -force

Import-Module ServerManager
Add-WindowsFeature Web-Scripting-Tools
import-module WebAdministration
dir iis:\AppPools

# https://blog.kmsigma.com/2016/02/25/removing-default-web-site-application-pool/
Remove-IISSite "Default Web Site" -Confirm:$False
Remove-WebAppPool -Name "DefaultAppPool" -Confirm:$false -Verbose

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
New-LocalUser -Name "SDMSC1-99999" `
-FullName "Starke-DMS Cloud 1.0 FileXchange user" `
-Description "FTP user" `
-Password (ConvertTo-SecureString -AsPlainText "Admin00!" -Force) `
-PasswordNeverExpires `
-AccountNeverExpires 

New-LocalGroup -Name "FTPGroup"

Add-LocalGroupMember -Group "FTPGroup" -Member "SDMSC1-99999" 

mkdir 'd:\dms-data\ftp-root\SDMSC1-FTPSite01' 
New-WebFtpSite -Name "SDMSC1-FTPSite01" -IPAddress "*" -Port 21 -PhysicalPath 'd:\dms-data\ftp-root\SDMSC1-FTPSite01'
Set-ItemProperty "IIS:\Sites\SDMSC1-FTPSite01" -Name physicalPath -Value 'd:\dms-data\ftp-root\SDMSC1-FTPSite01'




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

################################################################


#Creating new FTP site
$SiteName = "Starke-DMS Cloud 1.0 FileXchange"
$RootFolderpath = "d:\dms-data\ftp-root"
$PortNumber = 21
$FTPUserGroupName = "FTPuserGroup"
$FTPUserName = "FtpUser"
$FTPPassword = ConvertTo-SecureString "p@ssw0rd" -AsPlainText -Force

if (!(Test-Path $RootFolderpath)) {
    # if the folder doesn't exist
    New-Item -Path $RootFolderpath -ItemType Directory # create the folder
}

New-WebFtpSite -Name $SiteName -PhysicalPath $RootFolderpath -Port $PortNumber -Verbose -Force 

#Creating the local Windows group
if (!(Get-LocalGroup $FTPUserGroupName  -ErrorAction SilentlyContinue)) {
    #if the group doesn't exist
    New-LocalGroup -Name $FTPUserGroupName `
        -Description "Members of this group can connect to FTP server" #create the group
}

# Creating an FTP user
If (!(Get-LocalUser $FTPUserName -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name $FTPUserName -Password $FTPPassword `
        -Description "User account to access FTP server" `
        -UserMayNotChangePassword
} 

# Add the created FTP user to the group Demo FTP Users Group
Add-LocalGroupMember -Name $FTPUserGroupName -Member $FTPUserName -ErrorAction SilentlyContinue

# Enabling basic authentication on the FTP site
$param = @{
    Path    = 'IIS:\Sites\Demo FTP Site'
    Name    = 'ftpserver.security.authentication.basicauthentication.enabled'
    Value   = $true 
    Verbose = $True
}
Set-ItemProperty @param

# Adding authorization rule to allow FTP users 
# in the FTP group to access the FTP site
$param = @{
    PSPath   = 'IIS:\'
    Location = $SiteName 
    Filter   = '/system.ftpserver/security/authorization'
    Value    = @{ accesstype = 'Allow'; roles = $FTPUserGroupName; permissions = 1 } 
}

Add-WebConfiguration @param

# Changing SSL policy of the FTP site
'ftpServer.security.ssl.controlChannelPolicy', 'ftpServer.security.ssl.dataChannelPolicy' | 
ForEach-Object {
    Set-ItemProperty -Path "IIS:\Sites\Demo FTP Site" -Name $_ -Value $false
}

$ACLObject = Get-Acl -Path $RootFolderpath
$ACLObject.SetAccessRule(
    ( # Access rule object
        New-Object System.Security.AccessControl.FileSystemAccessRule(
            $FTPUserGroupName,
            'ReadAndExecute',
            'ContainerInherit,ObjectInherit',
            'None',
            'Allow'
        )
    )
)
Set-Acl -Path $RootFolderpath -AclObject $ACLObject

# Checking the NTFS permissions on the FTP root folder
Get-Acl -Path $RootFolderpath | ForEach-Object Access

# Test FTP Port and FTP access
Test-NetConnection -ComputerName localhost -Port 21

ftp localhost




Stop-Transcript