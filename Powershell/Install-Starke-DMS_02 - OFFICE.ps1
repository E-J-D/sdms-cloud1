# 22.11.2022 Eike Doose / INTERNAL USER ONLY / do not distribute
# ============================================================================
#
# -FTPserver
#  > specify the FTP server which will be used for downloading the software / e.g. -FTPserver 'ftp.get--it.de'
#
# -FTPuser
#  > name the FTP server user for logging into the FTP server / e.g. -FTPuser 'username'
# 
# -FTPpass
#  > password for logging into the FTP server / e.g. -FTPpass 'verysecretpassword'
#
# -customerno
#  > client customer number which is needed for naming the new server and the database creation / e.g. -customerno '23545'
#
# -LIZuser
#  > username for using the license server / e.g. -LIZuser 'username'
#
# -LIZpass
#  > password for logging into the license server / e.g. -FTPpass 'licenseuserpass'
#
# -LIZserver
#  > URL of the license server / e.g. -LIZserver 'license.starke.cloud'
#
# -LIZuid
#  > license UID to be downloaded / e.g. -LIZuid '{5C395FDC-6A94-32BE-BAD4-918D9B324AFG}'
#
# -LIZcustomerno
#  > license custom number to be downloaded / e.g. -LIZcustomerno '23545'
#  > not needed if LIZuid is given
#
# -LIZtargetdir
#  > directory to where the license file will be downloaded / e.g. -LIZtargetdir 'd:\dms-config' 
#
# -saPass
#  > sa password for the database / e.g. -saPass 'secretsapassword' 
#
#
# parameter sample

# 25.04.2022 Eike Test NFR // CLOUD1MASTER1 50999 {5F900818-7977-4134-A741-2022C8059A5C}
# .\Install-Starke-DMS_02.ps1 -FTPserver '192.168.120.11' -FTPuser 'get--IT' -FTPpass 'get--IT2022' -customerno '50999' -LIZuser 'dockersetup' -LIZpass 'S3VyendlaWwgUmV2aXZhbCBiZXdlaXNlbiE' -LIZserver 'https://starke-dms-license.azurewebsites.net' -LIZuid '{5F900818-7977-4134-A741-2022C8059A5C}' -LIZtargetdir 'd:\dms-config' -saPass 'saAdmin00!' 

# 25.04.2022 Eike Test NFR
# Test Kunde 01 / {BB2D87B2-812D-4C62-BA40-7944B941B086} Test Kunde 01 / KDNR 56999
# .\Install-Starke-DMS_02.ps1 -FTPserver '192.168.120.11' -FTPuser 'get--IT' -FTPpass 'get--IT2022' -customerno '56999' -LIZuser 'dockersetup' -LIZpass 'S3VyendlaWwgUmV2aXZhbCBiZXdlaXNlbiE' -LIZserver 'https://starke-dms-license.azurewebsites.net' -LIZuid '{BB2D87B2-812D-4C62-BA40-7944B941B086}' -LIZtargetdir 'd:\dms-config' -saPass 'saAdmin00!' 

# 25.04.2022 Eike Test NFR
# Test Kunde 02 / {7666BBC5-7C53-4B17-9444-1CB0B707AF5C} Test Kunde 02 / KDNR 57999
# .\Install-Starke-DMS_02.ps1 -FTPserver '192.168.120.11' -FTPuser 'get--IT' -FTPpass 'get--IT2022' -customerno '57999' -LIZuser 'dockersetup' -LIZpass 'S3VyendlaWwgUmV2aXZhbCBiZXdlaXNlbiE' -LIZserver 'https://starke-dms-license.azurewebsites.net' -LIZuid '{7666BBC5-7C53-4B17-9444-1CB0B707AF5C}' -LIZtargetdir 'd:\dms-config' -saPass 'saAdmin00!' 

# 15.11.2022 Eike Test PRODUKTIV
# Test Kunde 02 / {7666BBC5-7C53-4B17-9444-1CB0B707AF5C} Test Kunde 02 / KDNR 57999
# .\Install-Starke-DMS_02.ps1 -FTPserver '172.28.0.11' -FTPuser 'AUTOINSTALLER' -FTPpass 'wbutJzGFALFDrtmN' -customerno '57999' -LIZuser 'dockersetup' -LIZpass 'S3VyendlaWwgUmV2aXZhbCBiZXdlaXNlbiE' -LIZserver 'https://starke-dms-license.azurewebsites.net' -LIZuid '{7666BBC5-7C53-4B17-9444-1CB0B707AF5C}' -LIZtargetdir 'd:\dms-config' -saPass 'saAdmin00!' 

# 22.11.2022 Eike Test VMware Testumgebung lokal
# Test Kunde 02 / {7666BBC5-7C53-4B17-9444-1CB0B707AF5C} Test Kunde 02 / KDNR 57999
# .\Install-Starke-DMS_02.ps1 -FTPserver '192.168.224.188' -FTPuser 'hausmeister' -FTPpass 'hausmeister' -customerno '57999' -LIZuser 'dockersetup' -LIZpass 'S3VyendlaWwgUmV2aXZhbCBiZXdlaXNlbiE' -LIZserver 'https://starke-dms-license.azurewebsites.net' -LIZuid '{7666BBC5-7C53-4B17-9444-1CB0B707AF5C}' -LIZtargetdir 'd:\dms-config' -saPass 'saAdmin00!' 



param (
	[string]$FTPserver = '172.28.0.11',
	[Parameter(Mandatory=$true)][string]$FTPuser,
	[Parameter(Mandatory=$true)][string]$FTPpass,
	[Parameter(Mandatory=$true)][string]$customerno,
	[Parameter(Mandatory=$true)][string]$LIZuser,
	[Parameter(Mandatory=$true)][string]$LIZpass,
	[string]$LIZserver = 'https://starke-dms-license.azurewebsites.net',
	[Parameter(Mandatory=$true)][string]$LIZuid,
	[string]$LIZtargetdir = 'd:\dms-config',
	[string]$LIZcustomerno,
	[Parameter(Mandatory=$true)][string]$saPass
)

# ============================================================================

################################################
## stop script on PowerShell error 
################################################
$ErrorActionPreference = "Stop"

################################################
## detect Powershe version - minimum 7
################################################
If ($PSVersionTable.PSVersion.Major -lt 7) {
    Throw "PowerShell version 7 or higher is required."
}
Clear-Host []

################################################
## intro and countdown
################################################

Write-Host -ForegroundColor Yellow "#######################################"
Write-Host -ForegroundColor Yellow "### Starke-DMS® unattended OFFICE install ####"
Write-Host -ForegroundColor Yellow "#######################################"
Start-Sleep -s 2
Clear-Host []



################################################
## Download section
################################################

Write-Host -ForegroundColor Green "##########################################"
Write-Host -ForegroundColor Green "######### downloading software ###########"
Write-Host -ForegroundColor Green "##########################################"


# download the Office installer
curl.exe ftp://""$FTPuser":"$FTPpass"@"$FTPserver"/SW_DVD5_Office_2016_64Bit_German_MLF_X20-42484.ISO" --ssl-reqd -k --output C:\install\StarkeDMS-latest\SW_DVD5_Office_2016_64Bit_German_MLF_X20-42484.ISO --create-dirs


################################################
## ISO mounten
################################################

Write-Host -ForegroundColor Green "##########################################"
Write-Host -ForegroundColor Green "########## mounting office ISO ###########"
Write-Host -ForegroundColor Green "##########################################"

Mount-DiskImage -ImagePath "C:\install\StarkeDMS-latest\SW_DVD5_Office_2016_64Bit_German_MLF_X20-42484.ISO"

Write-Host -ForegroundColor Green "##########################################"
Write-Host -ForegroundColor Green "########### software unzipped ############"
Write-Host -ForegroundColor Green "##########################################"
Start-Sleep -s 2
# Clear-Host []


################################################
## install office
################################################


# run the Microsoft Visual C++ 2015-2019 Redistributable (x64, x86) installer in silent mode
Write-Host -ForegroundColor Green "###################################################"
Write-Host -ForegroundColor Green "# installing Microsoft Visual C++ Redistributable #"
Write-Host -ForegroundColor Green "###################################################"

# Start-Process -Wait -FilePath 'C:\install\StarkeDMS-latest\VC_redist.x64.exe' -ArgumentList "/install /quiet /norestart"

Write-Host -ForegroundColor Yellow "#############################################"
Write-Host -ForegroundColor Green  "#### Microsoft Visual C++ Redistributable ###"
Write-Host -ForegroundColor Yellow "#############################################"
Write-Host 
Write-Host  
# Start-Sleep -s 2
# Clear-Host []
