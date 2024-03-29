<# 07.06.2023 Eike Doose / INTERNAL USER ONLY / do not distribute
Install-Starke-DMS_02.ps1 installs with PWSH7 all of the hot stuff
============================================================================ #>

#######################################
## import parameter
#######################################

$configpath = 'c:\install\'
$configfile = 'Install-Starke-DMS_CONFIG.psd1'
$LIZtargetdir = 'd:\dms-config\'
$var = Import-LocalizedData -BaseDirectory $configpath -FileName $configfile

$FTPserver = $var.FTPserver
$FTPuser = $var.FTPuser
$FTPpass = $var.FTPpass
$LIZuser = $var.LIZuser
$LIZpass = $var.LIZpass
$LIZserver = $var.LIZserver
$saPass = $var.saPass
$customerno = $var.customerno
$LIZuid = $var.LIZuid
$UPDATE = $var.UPDATE
$FTP = $var.FTP
$FTPbasic = $var.FTP
$SSH = $var.SSH
$POWERSHELL7 = $var.POWERSHELL7
$ADMINUPDATE = $var.ADMINUPDATE
$PassAutoLogon = $var.PassAutoLogon
$MAILPASS = $var.MAILPASS
$ConsultantMailAddress = $var.ConsultantMailAddress
$Resellerclient = $var.Resellerclient
$DEVRUN = $var.DEVRUN

Clear-Host []


################################################
## delete my own task from task scheduler
################################################

Unregister-ScheduledTask -TaskName "run Install-Starke-DMS_02.ps1 at logon" -Confirm:$false


#######################################
## generate timestamp
#######################################

$t=(get-date -format "yyyy-MM-dd_HH-mm-ss")
Start-Sleep -s 1


################################################
## start logging 
################################################

Start-Transcript -Path "c:\install\_Log-Install-Starke-DMS_02-$t.txt" 
Start-Sleep -s 3


################################################
## stop script on PowerShell error 
################################################

# $ErrorActionPreference = "Stop"


################################################
## detect Powershell version - minimum 7
################################################
If ($PSVersionTable.PSVersion.Major -lt 7) {
    Throw "PowerShell version 7 or higher is required."
}
Clear-Host []


################################################
## functions for the script
################################################

function PrintJobToDo($PrintJobToDoValue){
Write-Host @("`n`r `n`r
-------------------------------------------------------------------
  ____  _             _              ____  __  __ ____             
 / ___|| |_ __ _ _ __| | _____      |  _ \|  \/  / ___|            
 \___ \| __/ _´ | ´__| |/ / _ \     | | | | |\/| \___ \            
  ___) | || (_| | |  |   <  __/_____| |_| | |  | |___) |           
 |____/ \__\__,_|_|  |_|\_\___|     |____/|_|  |_|____/            
   ____ _                 _   ___           _        _ _           
  / ___| | ___  _   _  __| | |_ _|_ __  ___| |_ __ _| | | ___ _ __ 
 | |   | |/ _ \| | | |/ _´ |  | || ´_ \/ __| __/ _´ | | |/ _ \ ´__|
 | |___| | (_) | |_| | (_| |  | || | | \__ \ || (_| | | |  __/ |   
  \____|_|\___/ \__,_|\__,_| |___|_| |_|___/\__\__,_|_|_|\___|_|   
                                                                   
-------------------------------------------------------------------

==> $PrintJobToDoValue

-------------------------------------------------------------------`n`r `n`r
") -ForegroundColor Yellow
}

function PrintJobDone($PrintJobDoneValue){
Write-Host @("`n`r `n`r
-------------------------------------------------------------------
  ____  _             _              ____  __  __ ____             
 / ___|| |_ __ _ _ __| | _____      |  _ \|  \/  / ___|            
 \___ \| __/ _´ | ´__| |/ / _ \     | | | | |\/| \___ \            
  ___) | || (_| | |  |   <  __/_____| |_| | |  | |___) |           
 |____/ \__\__,_|_|  |_|\_\___|     |____/|_|  |_|____/            
   ____ _                 _   ___           _        _ _           
  / ___| | ___  _   _  __| | |_ _|_ __  ___| |_ __ _| | | ___ _ __ 
 | |   | |/ _ \| | | |/ _´ |  | || ´_ \/ __| __/ _´ | | |/ _ \ ´__|
 | |___| | (_) | |_| | (_| |  | || | | \__ \ || (_| | | |  __/ |   
  \____|_|\___/ \__,_|\__,_| |___|_| |_|___/\__\__,_|_|_|\___|_|   
                                                                   
-------------------------------------------------------------------

==> $PrintJobDoneValue

-------------------------------------------------------------------`n`r `n`r
") -ForegroundColor Green
}

function PrintJobError($PrintJobErrorValue){
Write-Host @("`n`r `n`r
-------------------------------------------------------------------
  ____  _             _              ____  __  __ ____             
 / ___|| |_ __ _ _ __| | _____      |  _ \|  \/  / ___|            
 \___ \| __/ _´ | ´__| |/ / _ \     | | | | |\/| \___ \            
  ___) | || (_| | |  |   <  __/_____| |_| | |  | |___) |           
 |____/ \__\__,_|_|  |_|\_\___|     |____/|_|  |_|____/            
   ____ _                 _   ___           _        _ _           
  / ___| | ___  _   _  __| | |_ _|_ __  ___| |_ __ _| | | ___ _ __ 
 | |   | |/ _ \| | | |/ _´ |  | || ´_ \/ __| __/ _´ | | |/ _ \ ´__|
 | |___| | (_) | |_| | (_| |  | || | | \__ \ || (_| | | |  __/ |   
  \____|_|\___/ \__,_|\__,_| |___|_| |_|___/\__\__,_|_|_|\___|_|   
                                                                   
-------------------------------------------------------------------

==> $PrintJobErrorValue

-------------------------------------------------------------------`n`r `n`r
") -ForegroundColor Red
}


################################################
## intro and countdown
################################################

Clear-Host []
PrintJobToDo "Starke-DMS® unattended install part 3 of 3"
Start-Sleep -s 3
Clear-Host []


#######################################
## password generator
#######################################

function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}

function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}

$password = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 5 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 4 -characters '1234567890'
$password += Get-RandomCharacters -length 2 -characters '!"§$%&/()=?}][{@#*+'


################################################
## Download section
################################################

PrintJobToDo "downloading the stuff"

# define download files
$files_OFF1			= "SW_DVD5_Office_2016_64Bit_German_MLF_X20-42484.ISO"
$files_OFF2			= "SW_DVD5_Office_2016_64Bit_German_MLF_X20-42484_template.MSP"
$files_OFF3			= "SW_DVD5_Office_2016_64Bit_German_MLF_X20-42484_template.xml"
$files_MC 			= "mcwin32-build226-setup.exe"
$files_SDMS 		= "StarkeDMSlatest.zip"
$files_SQLEXPR		= "SQLEXPRADV_x64_DEU.exe"
$files_SQLEXPRI		= "SQLEXPRADV_x64_DEU.ini"
$files_SSMS			= "SSMS-Setup-ENU.exe"
$files_ABBYY		= "ABBYYlatest.zip"
$files_BACKUP		= "Agent-Windows-x64-9-21-1018.exe"
$files_msoledbsql	= "msoledbsql_18.6.3_x64.msi"
$files_msodbcsql17	= "msodbcsql17.msi"
$files_MsSqlCmd		= "MsSqlCmdLnUtils.msi"
$files_VC_redist1	= "VC_redist.x64.exe"
$files_VC_redist2	= "VC_redist.x86.exe"
$files_WebApache	= "WebApache.zip"
$files_DB			= "SQL-DB-CLOUD1MASTER1.bak"

# Create an array of files
$files = @($files_OFF1, $files_OFF2, $files_OFF3, $files_MC, $files_SDMS, $files_SQLEXPR, $files_SQLEXPRI, $files_SSMS, $files_ABBYY, $files_BACKUP, $files_msoledbsql, $files_msodbcsql17, $files_MsSqlCmd, $files_VC_redist1, $files_VC_redist2, $files_WebApache, $files_DB)

# Perform iteration to download the files to server
if($DEVRUN -eq "no"){
	foreach ($i in $files) {
		curl.exe ftp://""$FTPuser":"$FTPpass"@"$FTPserver"/"$i"" --ssl-reqd -k --output C:\install\StarkeDMS-latest\$i --create-dirs
	}
	# download predefined installer registry keys
	curl.exe "https://raw.githubusercontent.com/E-J-D/sdms-cloud1/main/Powershell/Install-Starke-DMS_setup.reg" --output C:\install\StarkeDMS-latest\StarkeDMS-setup.reg --create-dirs
	curl.exe "https://raw.githubusercontent.com/E-J-D/sdms-cloud1/main/Powershell/Install-ABBYY_setup.reg" --output C:\install\StarkeDMS-latest\ABBYY-setup.reg --create-dirs
	
	PrintJobDone "download finished"
	Start-Sleep -s 1
	Clear-Host []
}else {
	# even if it's a DEVRUN predefined installer registry keys have to be downloaded
	curl.exe "https://raw.githubusercontent.com/E-J-D/sdms-cloud1/main/Powershell/Install-Starke-DMS_setup.reg" --output C:\install\StarkeDMS-latest\StarkeDMS-setup.reg --create-dirs
	curl.exe "https://raw.githubusercontent.com/E-J-D/sdms-cloud1/main/Powershell/Install-ABBYY_setup.reg" --output C:\install\StarkeDMS-latest\ABBYY-setup.reg --create-dirs
	PrintJobError "DEVRUN - only reg files downloaded"
	Start-Sleep -s 3
}


################################################
## unzip 
################################################

PrintJobToDo "unzipping archives"

# expand the Starke-DMS ZIP
Expand-Archive -LiteralPath C:\install\StarkeDMS-latest\StarkeDMSlatest.zip -DestinationPath C:\install\StarkeDMS-latest

# expand the sql express setup
Start-Process -wait C:\install\StarkeDMS-latest\SQLEXPRADV_x64_DEU.exe -ArgumentList "/q /x:C:\install\StarkeDMS-latest\SQL"

# expand the ABBYY ZIP
Expand-Archive -LiteralPath C:\install\StarkeDMS-latest\ABBYYlatest.zip -DestinationPath C:\install\StarkeDMS-latest

# expand the WebApache ZIP
Expand-Archive -LiteralPath C:\install\StarkeDMS-latest\WebApache.zip -DestinationPath d:\tools


# delete the downloaded ZIPs
Remove-Item C:\install\StarkeDMS-latest\StarkeDMSlatest.zip
Remove-Item C:\install\StarkeDMS-latest\ABBYYlatest.zip
Remove-Item C:\install\StarkeDMS-latest\WebApache.zip

# rename the downloaded installer to *latest
Get-ChildItem -Path C:\install\StarkeDMS-latest\* -Include StarkeDMS*.exe | Rename-Item -NewName StarkeDMS-latest.exe
Get-ChildItem -Path C:\install\StarkeDMS-latest\* -Include ABBYY*.exe | Rename-Item -NewName ABBYY-latest.exe

PrintJobDone "archives unzipped"
Start-Sleep -s 2
Clear-Host []


################################################
## import predefined registry keys
################################################

PrintJobToDo "importing reg keys"
reg import C:\install\StarkeDMS-latest\StarkeDMS-setup.reg /reg:64
reg import C:\install\StarkeDMS-latest\ABBYY-setup.reg /reg:64
PrintJobDone "reg keys imported"
Start-Sleep -s 2
Clear-Host []


################################################
## install all the stuff
################################################

## /////////////////////////////////////////////
## run the Microsoft Visual C++ 2015-2019 Redistributable (x64, x86) installer in silent mode
## /////////////////////////////////////////////
PrintJobToDo "installing Microsoft Visual C++ Redistributable"
Start-Process -Wait -FilePath 'C:\install\StarkeDMS-latest\VC_redist.x64.exe' -ArgumentList "/install /quiet /norestart"
Start-Sleep -s 2
Start-Process -Wait -FilePath 'C:\install\StarkeDMS-latest\VC_redist.x86.exe' -ArgumentList "/install /quiet /norestart"
PrintJobDone "Microsoft Visual C++ Redistributable installed"
Start-Sleep -s 2
Clear-Host []

## /////////////////////////////////////////////
## run the MC installer in silent mode
## /////////////////////////////////////////////
PrintJobToDo "installing MC"
Start-Process -Wait -FilePath 'C:\install\StarkeDMS-latest\mcwin32-build226-setup.exe' -ArgumentList "/VERYSILENT /NORESTART"
PrintJobDone "MC installed"
Start-Sleep -s 2
Clear-Host []

## /////////////////////////////////////////////
## run the Starke-DMS installer in silent mode and wait 3sec
## /////////////////////////////////////////////
PrintJobToDo "installing Starke-DMS®"
Start-Process -Wait -FilePath 'C:\install\StarkeDMS-latest\StarkeDMS-latest.exe' -ArgumentList /S -PassThru
Start-Sleep -s 3

New-NetFirewallRule `
	-Name "Starke-DMS Server Port" `
	-DisplayName "Starke-DMS Server Port" `
	-Description 'Allow Starke-DMS Server Port' `
	-Profile Any `
	-Direction Inbound `
	-Action Allow `
	-Protocol TCP `
	-Program Any `
	-LocalAddress Any `
	-LocalPort 27244

# copy all config sample files to DMS-config folder
Copy-Item -Path "C:\Program Files (x86)\StarkeDMS\config_new\*" -Destination "D:\dms-config" -Recurse

PrintJobDone "Starke-DMS® installed"
Start-Sleep -s 2
Clear-Host []

## /////////////////////////////////////////////
# run the ABBYY installer in silent mode and wait 3sec
## /////////////////////////////////////////////
PrintJobToDo "installing StarkeAbbyy engine"
Start-Process -Wait -FilePath 'C:\install\StarkeDMS-latest\ABBYY-latest.exe' -ArgumentList /S -PassThru
Start-Sleep -s 3
PrintJobDone "Abbyy engine installed"
Start-Sleep -s 2
Clear-Host []


## /////////////////////////////////////////////
## run the terra backup agent installer in silent mode and wait 3sec
# https://wiki.terracloud.de/index.php/Backup#Installation_.C3.BCber_das_Setup
# 15.11.2022 Eike Doose: silent installer does not work. Agent has to be installed manually.
## /////////////////////////////////////////////
# PrintJobToDo "installing terra backup agent"
#Start-Process -Wait -FilePath 'C:\install\StarkeDMS-latest\Agent-Windows-x64-9-21-1018.exe' -ArgumentList "/s /v ""REGISTERWITHWEBCC=True AMPNWADDRESS=backup.terracloud.de AMPUSERNAME=backupkunde@firmaXYZ.de AMPPASSWORD=password FEATUREVOLUMEIMAGE=ON /qn"""
#Start-Sleep -s 3
#PrintJobDone "terra backup engine installed"
#Start-Sleep -s 2
#Clear-Host [] 

## /////////////////////////////////////////////
## run the sql express installer in silent mode and wait 3sec
## /////////////////////////////////////////////
PrintJobToDo "installing SQL DB engine"
Start-Process -Wait -FilePath 'C:\install\StarkeDMS-latest\SQL\setup.exe' -ArgumentList "/ConfigurationFile=C:\install\StarkeDMS-latest\SQLEXPRADV_x64_DEU.ini /SAPWD=$saPass"
Start-Sleep -s 3
PrintJobDone "SQL DB engine installed"
Start-Sleep -s 2
Clear-Host []


## /////////////////////////////////////////////
## install sql powershell util
## /////////////////////////////////////////////
PrintJobToDo "installing sqlserver powershell tools"
Install-Module -Name NuGet -force
#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name SqlServer -force
PrintJobDone "sqlserver powershell tools installed"
Start-Sleep -s 2
Clear-Host []

## /////////////////////////////////////////////
## install MSOLE DB driver
## not necessary if sql express is already installed 
## /////////////////////////////////////////////
# PrintJobToDo "installing MSOLEDBSQL"
# Start-Process -wait C:\install\StarkeDMS-latest\msoledbsql_18.6.3_x64.msi -ArgumentList "IACCEPTMSOLEDBSQLLICENSETERMS=YES /qn"
# PrintJobDone "MSOLEDBSQL installed"


## /////////////////////////////////////////////
## install MS ODBC SQL17 driver
## not necessary if sql express is already installed
## /////////////////////////////////////////////
# PrintJobToDo "installing MSODBCSQL18"
##Start-Process -wait C:\install\StarkeDMS-latest\msodbcsql17.msi -ArgumentList "IACCEPTMSODBCSQLLICENSETERMS=YES /qn"
# PrintJobDone "MSODBCSQL18 installed"
 

## /////////////////////////////////////////////
## install SSMS
## /////////////////////////////////////////////
PrintJobToDo "installing SSMS SQL Server Management Studio"
Start-Process -Wait -FilePath c:\install\StarkeDMS-latest\SSMS-Setup-ENU.exe -ArgumentList "/install /quiet /norestart"
PrintJobDone "SSMS SQL Server Management Studio installed"
Start-Sleep -s 2
Clear-Host []

## /////////////////////////////////////////////
## install MS SQL Utils (SQLCMD.exe) toolset
## ???? not necessary if ssms is already installed
## /////////////////////////////////////////////
PrintJobToDo "installing MS SQL cli utils"
Start-Process -wait C:\install\StarkeDMS-latest\MsSqlCmdLnUtils.msi -ArgumentList "IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES /qn"
PrintJobDone "MS SQL cli utils installed"
Start-Sleep -s 2
Clear-Host []


## /////////////////////////////////////////////
## install Microsoft Office
## /////////////////////////////////////////////

## ISO mount
## /////////////////////////////////////////////
PrintJobToDo "mounting office ISO"
Mount-DiskImage -ImagePath "C:\install\StarkeDMS-latest\SW_DVD5_Office_2016_64Bit_German_MLF_X20-42484.ISO"
PrintJobDone "office iso mounted"
Start-Sleep -s 2
#Clear-Host []

# run the Office installer in silent mode
PrintJobToDo "installing Microsoft Office 2016 (S+R Settings)"
Start-Process -Wait -FilePath 'f:\setup.exe' -ArgumentList "/adminfile C:\install\StarkeDMS-latest\SW_DVD5_Office_2016_64Bit_German_MLF_X20-42484_template.msp"
PrintJobDone "Microsoft Office 2016 S+R  installed "
Start-Sleep -s 2
#Clear-Host []

## ISO unmount
## /////////////////////////////////////////////
PrintJobToDo "unmounting office ISO"
DisMount-DiskImage -ImagePath "C:\install\StarkeDMS-latest\SW_DVD5_Office_2016_64Bit_German_MLF_X20-42484.ISO"
PrintJobDone "office iso unmounted"
Start-Sleep -s 2
# Clear-Host []

## activate with terra cloud VL
## /////////////////////////////////////////////
if($DEVRUN -eq "no"){
	PrintJobToDo "office volume licensing"
	Start-Process -Wait -FilePath 'slmgr' -ArgumentList "//b /skms 185.35.12.116:1688"
	Start-Sleep -s 2
	start-process "cscript.exe" -Argumentlist '"C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act' -wait
	PrintJobDone "office licensed"
	Start-Sleep -s 2
	Clear-Host []
}else {
	PrintJobError "DEVRUN - office was not activated"
	Start-Sleep -s 3
}

# message when everything is done
PrintJobDone "all components installed"
Start-Sleep -s 3


################################################
## Starke-DMS license download
################################################
Clear-Host []
PrintJobToDo "downloading Stark-DMS license"
Start-Sleep -s 2

# content of ""Install-Starke-DMS_license.ps1"" pasted here
# 05.04.2022 Boris Brixel

if (($LIZuid -eq '') -And ($LIZcustomerno -eq '')) {
	"UID oder Kundennummer übergeben"
	Return
}

$licensefile = '.\get-dms-license.zip'
$licensedir = '.\get-dms-license'
if (Test-Path -Path $licensefile -PathType Leaf) {
	Remove-Item -LiteralPath $licensefile
}
if (Test-Path -Path $licensedir) {
	Remove-Item -LiteralPath $licensedir -Force -Recurse
}

$credentials = @{
    username = $LIZuser
    password = $LIZpass
}
$response = Invoke-WebRequest -Uri "$LIZserver/license/login" -Body $credentials -Method Get -SkipHttpErrorCheck -SessionVariable session

if ($response.StatusCode -eq 200) {
	"Anmeldung erfolgreich."

	if ($LIZuid -eq '') {
		# UID anhand von Kundennummer ermitteln
		$parameters = @{
			customerno = $LIZcustomerno # '50999'
		}
		$response = Invoke-WebRequest -Uri "$LIZserver/license/list" -Body $parameters -Method Get -SkipHttpErrorCheck -WebSession $session
		if ($response.StatusCode -eq 200) {
			$json = $response.Content | ConvertFrom-Json
			$count = $json.count
			if ($count -eq 1) {
				$LIZuid = $json[0].uid
				"UID: $LIZuid"
			} elseif ($count -eq 0) {
				"Keine Lizenz gefunden."
			} else {
				"$count Lizenzen gefunden. Geben Sie eine eindeutige Kundennummer oder eine UID an."
			}
		} else {
			"Fehler beim Suchen der Lizenz-UID: $response"
		}
	}
	
	if ($LIZuid -ne '') {
		$parameters = @{
			uid = $LIZuid
		}
		$response = Invoke-WebRequest -Uri "$LIZserver/license/export" -Body $parameters -OutFile $licensefile -PassThru -Method Get -SkipHttpErrorCheck -WebSession $session

		if ($response.StatusCode -eq 200) {
			"Lizenz heruntergeladen."
		} else {
			"Fehler beim Herunterladen der Lizenz: $response"
			if (Test-Path -Path $licensefile -PathType Leaf) {
				Remove-Item -LiteralPath $licensefile
			}
		}
	}

	$response = Invoke-WebRequest -Uri "$LIZserver/license/logout" -Method Get -SkipHttpErrorCheck -WebSession $session
} else {
	"Fehler beim Anmelden: $response"
}
if (Test-Path -Path $licensefile -PathType Leaf) {
	Expand-Archive -LiteralPath $licensefile -DestinationPath $licensedir
	if (Test-Path -Path "$licensedir\APLizenz.liz" -PathType Leaf) {
		"Lizenzdateien entpackt."
		if (-Not (Test-Path -Path $LIZtargetdir)) {
			$dummy = New-Item $LIZtargetdir -ItemType Directory
		}
		Copy-Item -Path "$licensedir\*" -Destination "$LIZtargetdir\" -Recurse
	} else {
		"APLizenz.liz nicht gefunden."
	}
	Remove-Item -LiteralPath $licensefile
	Remove-Item -LiteralPath $licensedir -Force -Recurse
}

PrintJobDone "Starke-DMS license downloaded"
Start-Sleep -s 2
Clear-Host []


################################################
## Starke-DMS SQL DB config
################################################

# create DMSServer.ini
PrintJobToDo "creating d:\dms-config\DMSServer.ini"
Start-Sleep -s 1
'[DB]', `
'ConnectionString=Provider=MSOLEDBSQL;SERVER=localhost\SDMSCLOUD1;DATABASE=CLOUD1MASTER1', `
'[Network]', `
'Port=27244', `
'[Lizenz]', `
'File=APLizenz.liz' | `
out-file d:\dms-config\DMSServer.ini
PrintJobDone "d:\dms-config\DMSServer.ini created"
Start-Sleep -s 2
# pause
Clear-Host []

# create initial DB
Start-Sleep -s 1
Clear-Host []
PrintJobToDo "creating initial DB"
Start-Sleep -s 10
Start-Process -wait -filepath "C:\Program Files (x86)\StarkeDMS\win64\DMSServer.exe"  -ArgumentList "-AdminPwd $saPass -cli -dbupdate -configpath $LIZtargetdir"
PrintJobDone "initial DB created"
Start-Sleep -s 2
# pause
Clear-Host []

# restore the rempate DB
PrintJobToDo "template DB will be restored"
Start-Sleep -s 1
cd "D:\dms-data\sql\Client SDK\ODBC\170\Tools\Binn\"
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "RESTORE DATABASE [CLOUD1MASTER1] FROM  DISK = N'C:\install\StarkeDMS-latest\SQL-DB-CLOUD1MASTER1.bak' WITH  FILE = 1,  MOVE N'CLOUD1MASTER1_Pri' TO N'D:\dms-data\sql\MSSQL15.SDMSCLOUD1\MSSQL\DATA\CLOUD1MASTER1_Pri.mdf',  MOVE N'CLOUD1MASTER1_Dat' TO N'D:\dms-data\sql\MSSQL15.SDMSCLOUD1\MSSQL\DATA\CLOUD1MASTER1_Dat.ndf',  MOVE N'CLOUD1MASTER1_txt' TO N'D:\dms-data\sql\MSSQL15.SDMSCLOUD1\MSSQL\DATA\CLOUD1MASTER1_Txt.ndf',  MOVE N'CLOUD1MASTER1_Log' TO N'D:\dms-data\sql\MSSQL15.SDMSCLOUD1\MSSQL\DATA\CLOUD1MASTER1_Log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5;"

# rename DB to DB$customerno
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "ALTER DATABASE CLOUD1MASTER1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;"
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "ALTER DATABASE CLOUD1MASTER1 MODIFY FILE (NAME=N'CLOUD1MASTER1_Pri', NEWNAME=N'$customerno-pri');"
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "ALTER DATABASE CLOUD1MASTER1 MODIFY FILE (NAME=N'CLOUD1MASTER1_Log', NEWNAME=N'$customerno-log');"
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "ALTER DATABASE CLOUD1MASTER1 MODIFY FILE (NAME=N'CLOUD1MASTER1_Dat', NEWNAME=N'$customerno-dat');"
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "ALTER DATABASE CLOUD1MASTER1 MODIFY FILE (NAME=N'CLOUD1MASTER1_Txt', NEWNAME=N'$customerno-txt');"
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "ALTER DATABASE CLOUD1MASTER1 MODIFY FILEGROUP [CLOUD1MASTER1_Dat] NAME = [$customerno-dat]"
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "ALTER DATABASE CLOUD1MASTER1 MODIFY FILEGROUP [CLOUD1MASTER1_txt] NAME = [$customerno-txt]"
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "EXEC master.dbo.sp_detach_db @dbname = N'CLOUD1MASTER1'"
# rename DB files 
Get-ChildItem D:\dms-data\sql\MSSQL15.SDMSCLOUD1\MSSQL\DATA\CLOUD1MASTER1* | Rename-Item -NewName { $_.Name -replace '_','-' }
Get-ChildItem D:\dms-data\sql\MSSQL15.SDMSCLOUD1\MSSQL\DATA\CLOUD1MASTER1* | Rename-Item -NewName { $_.Name -replace 'CLOUD1MASTER1',$customerno }
# create renamed DB
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "CREATE DATABASE CLOUD1MASTER1 ON ( FILENAME = N'D:\dms-data\sql\MSSQL15.SDMSCLOUD1\MSSQL\DATA\$customerno-pri.mdf' ), ( FILENAME = N'D:\dms-data\sql\MSSQL15.SDMSCLOUD1\MSSQL\DATA\$customerno-log.ldf' ), ( FILENAME = N'D:\dms-data\sql\MSSQL15.SDMSCLOUD1\MSSQL\DATA\$customerno-dat.ndf' ), ( FILENAME = N'D:\dms-data\sql\MSSQL15.SDMSCLOUD1\MSSQL\DATA\$customerno-txt.ndf' ) FOR ATTACH;"
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "ALTER DATABASE CLOUD1MASTER1 SET MULTI_USER;"
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -P $saPass -Q "ALTER DATABASE CLOUD1MASTER1 MODIFY NAME = [$customerno];"

PrintJobDone "template DB restored"
Start-Sleep -s 2
# pause
Clear-Host []


# change DB in DMSServer.ini to new DB name
PrintJobToDo "changing DB name in d:\dms-config\DMSServer.ini"
'[DB]', `
"ConnectionString=Provider=MSOLEDBSQL;SERVER=localhost\SDMSCLOUD1;DATABASE=$customerno", `
'[Network]', `
'Port=27244', `
'[Lizenz]', ` 
'File=APLizenz.liz' | out-file d:\dms-config\DMSServer.ini
PrintJobDone "changing DB name in d:\dms-config\DMSServer.ini finished"
Start-Sleep -s 2
# pause
Clear-Host []


#########################################################
# pasted from Install-Starke-DMS_DBfixLic.ps1 ###########
#########################################################
PrintJobToDo "fix DB to new customer (fixLic)"
Start-Sleep -s 1
# pause 

cd "D:\dms-data\sql\Client SDK\ODBC\170\Tools\Binn\"

$sqlquery = 'SELECT name FROM ArchivPlus.versions WHERE description LIKE ""Datenbank Kundenindividuelle Struktur"";'
$olduid = .\SQLCMD.EXE -S localhost\SDMSCLOUD1 -d $customerno -Q "$sqlquery" -U 'sa' -P $saPass -h -1
$olduid = ($olduid -split '\r\n')[0]
$olduid = $olduid.Trim()
if ($olduid -match '\{.+\}') {
	$olduid = $Matches.0
	Write-Host Alte UID: $olduid
	$file = Get-Childitem –Path "$LIZtargetdir" -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'Version(\{.+\})\.dat' }
	if (("$file" -ne '') -And ("$Matches.1" -ne '')) {
		$newuid = $Matches.1
		Write-Host Neue UID: $newuid
		$sqlupdate = "UPDATE ArchivPlus.versions SET name = """"db$newuid"""" WHERE name = """"db$olduid"""";"
		#Write-Host $sqlupdate
#		$updateresult = .\SQLCMD.EXE -S "$sqlserver" -d "$database" -Q "$sqlupdate" -U "$username" -P "$password" -h -1
		$updateresult = .\SQLCMD.EXE -S localhost\SDMSCLOUD1 -d $customerno -Q "$sqlupdate" -U 'sa' -P  $saPass -h -1
		$updateresult = $updateresult.Trim()
		Write-Host $updateresult
	} else {
		Write-Host Neue UID nicht gefunden.
	}
} else {
	Write-Host Alte UID nicht gefunden.
}

PrintJobDone "fix DB to new customer (fixLic) done"
Start-Sleep -s 2
# pause
Clear-Host []


#########################################################
# END pasted from Install-Starke-DMS_DBfixLic.ps1 #######
#########################################################
Start-Sleep -s 2
Clear-Host []
PrintJobToDo "restore template DB and fix to new customer "

# update system DB user
.\sqlcmd -S localhost\SDMSCLOUD1 -U SA -d $customerno -P $saPass -Q "ALTER USER ArchivPlus WITH LOGIN = ArchivPlus;"

# check and upgrade DB if necessary
Start-Process -wait -filepath "C:\Program Files (x86)\StarkeDMS\win64\DMSServer.exe"  -ArgumentList "-AdminPwd $saPass -cli -dbupdate -configpath $LIZtargetdir"

PrintJobDone "template DB restored and fixed to new customer - COMPLETE"
Start-Sleep -s 2
# pause
Clear-Host []


################################################
## Starke-DMS services config
## https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-service?view=powershell-7.2
################################################

#####################################################################################
# DMS Server service install and start - 01
# ------------------------------------
PrintJobToDo "DMS Server service will be installed"
Start-Sleep -s 5

$params = @{
  Name = "DMS_01_Server"
  BinaryPathName = 'C:\Program Files (x86)\StarkeDMS\win64\DMSServerSvc.exe /name "DMS_01_Server" /ini DMSServer.ini /configpath "d:\dms-config"'
  StartupType = "AutomaticDelayedStart"
  Description = "Starke-DMS Server"
}
New-Service @params

Start-Sleep -s 1
Start-Service -Name "DMS_01_Server"
Start-Sleep -s 3

PrintJobDone "DMS Server service installed "
Start-Sleep -s 2
Clear-Host []

#####################################################################################
# DMS LicenseManager service install and start - 02
# --------------------------------------------
PrintJobToDo "DMS LicenseManager service will be installed"

#'[DB]','ConnectionString=Provider=MSOLEDBSQL;SERVER=localhost\SDMSCLOUD1;DATABASE=$customerno,'[Network]','Port=27244','[Lizenz]','File=APLizenz.liz' | out-file d:\dms-config\DMSLicenseManager.ini
'[Service]','User=system','Password=xgq}bNGQ!ZePgfje','Server=localhost','Port=27244' | out-file d:\dms-config\DMSLicenseManager.ini

$params = @{
  Name = "DMS_02_LicenseManager"
  BinaryPathName = 'C:\Program Files (x86)\StarkeDMS\win64\DMSLizenzmanagerSvc.exe /name "DMS_02_LicenseManager" /Ini "DMSLicenseManager.ini" /ConfigPath "D:\dms-config"'
  StartupType = "AutomaticDelayedStart"
  Description = "Starke-DMS License Manager"
  DependsOn = "DMS_01_Server"
}
New-Service @params

Start-Sleep -s 1
Start-Service -Name "DMS_02_LicenseManager"
Start-Sleep -s 3

PrintJobDone "DMS LicenseManager service installed "
Start-Sleep -s 2
Clear-Host []


#####################################################################################
#DMS FileExport service install and start - 03
#----------------------------------

#PrintJobToDo "DMS FileExport service will be installed"

######################################
# tbd - FileExport.ini der get--IT2022
#[Service]
#Server=localhost
#Port=27244
#User=import
#Password=
#Debug=0

#PasswordAES=1:x40abI48LkuhGownfvQOdw==
#[AR-Export]
#Active=1
#OutFile=C:\Temp\Export\%idx:0%.csv
#DocFile=C:\Temp\Export\%idx:0%
#DecimalSeparator=,
#ThousandSeparator=.
#WaitForJob=
#OutFileEncoding=

#[AR-Export.Search]
#100:=:Eingangs-Rechnung
#10000:=:Xony AG

#[AR-Export.Header]
#Interne Belegnummer;Lieferantenname;Lieferantennummer;Belegnummer;Belegdatum;Bestellnummer;FiBu-Status;Gesamtsumme netto;MwSt;Gesamtsumme brutto
#[AR-Export.Body]
#%idx:70%;%idx:10000%;%idx:10001%;%idx:10002%;%idx:10015%;%idx:10004%;%idx:10011%;%idx:10008%;%idx:10009%;%idx:10010%
#[AR-Export.Footer]
#[AR-Export.Update]
######################################

## Write-Host -ForegroundColor Yellow "######### press ENTER to continue ##########"

## press ENTER to continue
##[Console]::ReadKey()

######################################
#'[Service]','User=system','Password=system','Server=localhost','Port=27244' | out-file d:\dms-config\DMSfileExport.ini

#$params = @{
#  Name = "DMS_03_FileExport"
#  BinaryPathName = 'C:\Program Files (x86)\StarkeDMS\win64\DMSFileExportSvc.exe /name "DMS_03_FileExport" /Ini "DMSfileExport.ini" /ConfigPath "D:\dms-config"'
#  StartupType = "AutomaticDelayedStart"
#  Description = "Starke-DMS FileExport"
#  DependsOn = "DMS_01_Server"
#}
#New-Service @params

#Start-Sleep -s 1
#Start-Service -Name "DMS_03_FileExport"
#Start-Sleep -s 3

#PrintJobDone "DMS FileExport service installed"
#Start-Sleep -s 2
#Clear-Host []


#####################################################################################
# DMS FileImport service install and start - 04
# ----------------------------------
PrintJobToDo "DMS FileImport service will be installed"

'[Global]', `
'Debug=0', '', `
'[Service]', `
'Server=localhost', `
'Port=27244', `
'User=system', `
'Password=xgq}bNGQ!ZePgfje', '', `
'[Main]', `
'DMSImport_Posteingang=DMSImport_Posteingang', '', `
'[DMSImport_Posteingang]', `
'Type=ANYFILE', 
'intervall=1', `
';starttime=06:00:00', `
';endtime=19:00:00', `
';days=mo,tu,we,th,fr,sa,su', `
';PLEASE CHANGE SOURCEPATH to DESIRED FOLDER', `
'SourcePath=D:\dms-data\file-exchange', `
'SourcePathSubDirs=Yes', `
'ArchivFileMask=*.pdf', `
'Product=DMS', `
'Mandator=0001', `
';Doctype=nicht zugeordnet', `
'SortBy=date', `
'PageNumberCharCount=0', `
"onSuccess=move:'D:\dms-data\file-exchange\_FileImportSuccess\%var:FileName%'", `
"onError=move:'D:\dms-data\file-exchange\_FileImportError\%var:FileName%'" | `
out-file d:\dms-config\DMSFileImport.ini -Encoding utf8

$params = @{
  Name = "DMS_04_FileImport"
  BinaryPathName = 'C:\Program Files (x86)\StarkeDMS\DMSFileImportSvc.exe /name "DMS_04_FileImport" /Ini "DMSFileImport.ini" /ConfigPath "D:\dms-config"'
  StartupType = "AutomaticDelayedStart"
  Description = "Starke-DMS FileImport"
  DependsOn = "DMS_01_Server"
}
New-Service @params

Start-Sleep -s 1
Start-Service -Name "DMS_04_FileImport"
Start-Sleep -s 3

PrintJobDone "DMS FileImport service installed "
Start-Sleep -s 2
Clear-Host []


#####################################################################################
# DMS IndexAgent service install and start - 05
# ----------------------------------
#PrintJobToDo "DMS IndexAgent service will be installed"


#####################################################################################
# DMS LookupImport service install and start - 06
# ----------------------------------
#PrintJobToDo "DMS LookupImport service will be installed"


#####################################################################################
# DMS MailImport service install and start - 07
# ----------------------------------
#PrintJobToDo "DMS MailImport service will be installed"


#####################################################################################
# DMS PDFConv service install and start - 08
# ----------------------------------
#PrintJobToDo "DMS PDFConverter service will be installed"


#####################################################################################
# DMS ServerOCR service install and start - 09
# ----------------------------------
PrintJobToDo "DMS ServerOCR service will be installed"

'[AbbyyEngine]', `
'Path=C:\Program Files (x86)\StarkeDMS\AbbyyEngine', `
'Mode=Balanced', `
'LimitCreationDate=', `
'RecognizeDocuments=1', `
'RecognizeAttachments=1', `
'RecognizeEMails=1', '', `
'[Process]', `
'Priority=1', '', `
'[Service]', `
'Type=ANYFILE', 
'intervall=15', `
';StartTime=06:00:00', `
';EndTime=19:00:00', `
';days=mo,tu,we,th,fr,sa,su', `
'Server=localhost', `
'Port=27244', `
'User=system', `
'Password=xgq}bNGQ!ZePgfje' | `
out-file d:\dms-config\DMSServerOCR.ini -Encoding utf8

$params = @{
  Name = "DMS_09_ServerOCR"
  BinaryPathName = 'C:\Program Files (x86)\StarkeDMS\DMSServerOCRSvc.exe /name "DMS_09_ServerOCR" /Ini "DMSServerOCR.ini" /ConfigPath "D:\dms-config"'
  StartupType = "AutomaticDelayedStart"
  Description = "Starke-DMS ServerOCR"
  DependsOn = "DMS_01_Server"
}
New-Service @params

Start-Sleep -s 1
Start-Service -Name "DMS_09_ServerOCR"
Start-Sleep -s 3

PrintJobDone "DMS ServerOCR service installed "
Start-Sleep -s 2
Clear-Host []


#####################################################################################
# DMS ServerRecognition service install and start - 10
# ----------------------------------
#PrintJobToDo "DMS ServerRecognition service will be installed"


#####################################################################################
# DMS WebApache service install and start - 11
# ----------------------------------
PrintJobToDo "DMS WebApache service will be installed"

'[DMSServer]','Server=localhost','Port=27244','[SSL]','Use=False' | out-file d:\dms-config\DMSWebServer.ini

Start-Process -Wait -FilePath 'd:\Tools\Apache24\bin\httpd.exe' -ArgumentList '-k install -n "DMS_11_WebApache" -f "d:\Tools\Apache24\conf\httpd.conf"'

Start-Sleep -s 1
Start-Service -Name "DMS_11_WebApache"
Start-Sleep -s 3

# create firewall rule to accept port 80 for WebApache
New-NetFirewallRule `
-Name "Starke-DMS HTTP Server" `
-DisplayName "Starke-DMS HTTP Server" `
-Description 'Allow Starke-DMS HTTP Server' `
-Profile Any `
-Direction Inbound `
-Action Allow `
-Protocol TCP `
-Program Any `
-LocalAddress Any `
-LocalPort 80 

Start-Sleep -s 2

PrintJobDone "DMS WebApache service installed"
Start-Sleep -s 2
Clear-Host []


#####################################################################################
# DMS xyz service install and start
# ----------------------------------
#PrintJobToDo "DMS XYZ service will be installed"

#PrintJobDone "DMS XYZ service installed"


################################################
## cleaning up
################################################
PrintJobToDo "install complete - cleaning up"
Start-Sleep -s 5

# delete DMS setup.exe 
# Remove-Item "C:\Program Files (x86)\StarkeDMS\setup\setup.exe"
# Remove-Item C:\install\ -Recurse -Force -Confirm:$false
Remove-Item C:\install\StarkeDMS-latest -Recurse -Force -Confirm:$false
# '[Info]','setup.exe was deleted after autoinstall' | out-file "C:\Program Files (x86)\StarkeDMS\setup\info.txt"
Clear-RecycleBin -Force
# PrintJobDone "C:\Program Files (x86)\StarkeDMS\setup\setup.exe deleted"
Start-Sleep -s 2
#New-Item -Path "c:\" -Name "install" -ItemType "directory"
Start-Sleep -s 2
'[Info]','everything in subfolder StarkeDMS-latest was deleted after autoinstall' | out-file "C:\install\info.txt"
PrintJobDone "C:\install\StarkeDMS-latest deleted"
Start-Sleep -s 2

# temporarely
# 15.11.2022 Eike Doose - download the terra backup agent due to need for manually install
# download the terra backup installer
# curl.exe ftp://""$FTPuser":"$FTPpass"@"$FTPserver"/Agent-Windows-x64-9-21-1018.exe" --ssl-reqd -k --output C:\install\Agent-Windows-x64-9-21-1018.exe --create-dirs


################################################
## create sql backup job
################################################
PrintJobToDo "SQL backup job will be created"

'rem this file was created by the Starke-DMS® cloud installer', `
'rem Eike Doose 16.12.2022', '', `
'SQLCMD.exe -S SDMSC1-KDNR\SDMSCLOUD1 -U sa -P saAdmin00! -i "D:\dms-data\backup\sql\backup-SQLExpress.sql" -o "D:\dms-data\backup\sql\backup-SQLExpress.txt"', `
'echo %DATE%', `
'echo %TIME%', `
'set datetimef=%date:~-4%_%date:~3,2%_%date:~0,2%__%time:~0,2%_%time:~3,2%_%time:~6,2%', `
'echo %datetimef%', `
'd:', `
'cd "d:\dms-data\backup\sql"', `
'rename CLOUD1-DB.bak CLOUD1-DB_%datetimef%.bak', `
'forfiles /p "d:\dms-data\backup\sql" /m *.bak /d -14 /c "cmd /c del @path"' | `
out-file d:\dms-data\backup\sql\backup-SQLExpress.bat -Encoding utf8
(Get-Content -Path 'd:\dms-data\backup\sql\backup-SQLExpress.bat') -replace 'KDNR',($customerno) | Set-Content -Path d:\dms-data\backup\sql\backup-SQLExpress.bat

"BACKUP DATABASE [KDNR] TO  DISK = N'D:\dms-data\backup\sql\CLOUD1-DB.bak' WITH NOFORMAT, INIT,  NAME = N'CLOUD1MASTER-complete db backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10", '', `
'GO' | `
out-file d:\dms-data\backup\sql\backup-SQLExpress.sql -Encoding utf8
(Get-Content -Path 'd:\dms-data\backup\sql\backup-SQLExpress.sql') -replace 'KDNR',($customerno) | Set-Content -Path d:\dms-data\backup\sql\backup-SQLExpress.sql


################################################
## create the windows task for MSSQL Express backup
################################################

[string]$TaskName = "SQL DB daily backup"
[string]$TaskDescription = "This task will run daily at 0:30 am / task created by Starke-DMS® cloud installer"
[string]$TaskDir = "\Starke-DMS®"
$TaskAusloeser = New-ScheduledTaskTrigger -Daily -DaysInterval 1 -At 00:30
$TaskAktion = New-ScheduledTaskAction -Execute "D:\dms-data\backup\sql\backup-SQLExpress.bat"
$TaskEinstellungen = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries
$TaskBenutzer = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest            
if (Get-ScheduledTask $TaskName -ErrorAction SilentlyContinue) {Unregister-ScheduledTask $TaskName}            
Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskDir -Action $TaskAktion -Trigger $TaskAusloeser -Principal $TaskBenutzer -Settings $TaskEinstellungen -Description $TaskDescription

PrintJobDone "SQL backup job created"
Start-Sleep -s 3


################################################
## delete emergency admin user for rollout
################################################

PrintJobToDo "delete EmergencyAdmin"
Remove-LocalUser -Name "EmergencyAdmin" -Confirm:$false
PrintJobDone "EmergencyAdmin deleted"
Start-Sleep -s 3


################################################
## disable Adminstrator auto logon
################################################

$UserAutoLogon = 'sjuperuser'
$PassAutoLogon = 'blabla'
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "0" -Type String 
Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$UserAutoLogon" -type String 
Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$PassAutoLogon" -type String


################################################
## change admin name und password
################################################
PrintJobToDo "change Admin to GottliebKrause"

if($ADMINUPDATE -eq "yes"){
	$newadminpass = Scramble-String $password
	$NewAdminPassword = convertto-securestring $newadminpass -asplaintext -force
	Set-LocalUser -Name Administrator -Password $NewAdminPassword –Verbose

	Rename-LocalUser -Name "Administrator"  -NewName "GottliebKrause"
	wmic useraccount where "Name='GottliebKrause'" set PasswordExpires=false

	'-------------------------------------------------------------------', `
	'  ____  _             _              ____  __  __ ____             ', `
	' / ___|| |_ __ _ _ __| | _____      |  _ \|  \/  / ___|            ', `
	' \___ \| __/ _` | ´__| |/ / _ \_____| | | | |\/| \___ \            ', `
	'  ___) | || (_| | |  |   <  __/_____| |_| | |  | |___) |           ', `
	' |____/ \__\__,_|_|  |_|\_\___|     |____/|_|  |_|____/            ', `
	'   ____ _                 _   ___           _        _ _           ', `
	'  / ___| | ___  _   _  __| | |_ _|_ __  ___| |_ __ _| | | ___ _ __ ', `
	' | |   | |/ _ \| | | |/ _` |  | || ´_ \/ __| __/ _` | | |/ _ \ ´__|', `
	' | |___| | (_) | |_| | (_| |  | || | | \__ \ || (_| | | |  __/ |   ', `
	'  \____|_|\___/ \__,_|\__,_| |___|_| |_|___/\__\__,_|_|_|\___|_|   ', `
	'                                                                   ', `
	'-------------------------------------------------------------------', `
	'New Administrator name and password', `
	'-------------------------------------------------------------------', `
	'Host: '+$ENV:COMPUTERNAME, `
	'-------------------------------------------------------------------', `
	'Date: '+(get-date -format "yyyy-MM-dd HH:mm:ss"), `
	'-------------------------------------------------------------------', `
	'new admin account name:', `
	'"GottliebKrause"', `
	'-------------------------------------------------------------------', `
	'new password:', `
	$newadminpass, `
	'-------------------------------------------------------------------', `
	'-------------------------------------------------------------------', `
	'DELETE THIS FILE IMMEDIATELY AFTER SAVING THE DATA', `
	'-------------------------------------------------------------------', `
	'-------------------------------------------------------------------'  | `
	out-file $env:USERPROFILE\Desktop\admin_password_username.txt

	PrintJobDone "Admin changed to GottliebKrause"

}else {
	PrintJobError "NO admin name and password change"
	Start-Sleep -s 5
}


################################################
## send e-mail to technical consultant
################################################

if($DEVRUN -eq "no"){
	PrintJobToDo "send notification e-mail"
	$mailpw = ConvertTo-SecureString -String $MAILPASS -AsPlainText -Force
	$mailcred = New-Object System.Management.Automation.PSCredential "noreply@starke-dms.cloud", $mailpw
	$mailbody = "all scripts are done"
	$mailsubject = "SDMS-C1-CloudInstaller notification / customer $customerno / credentials attached / all scripts are done"
	#$mailattachment = "$env:USERPROFILE\Desktop\*.txt"
	Get-ChildItem -Path "$env:USERPROFILE\Desktop\*.txt" | Send-MailMessage -Credential $mailcred -to $ConsultantMailAddress -from noreply@starke-dms.cloud -SMTPServer 'smtp.strato.com' -Port 587 -usessl -Subject $mailsubject -body $mailbody
	PrintJobDone "notification e-mail sent"

}else {
	PrintJobError "NO notification e-mail sent"
	Start-Sleep -s 3
}


################################################
## stop transcripting
################################################

    stop-transcript
    # stop-transcript / Transcript is broken if OS update installs e.g. PowerShell engine update - because of this the transcript stops before updating
    Clear-Host []


################################################
## install updates
################################################

if($UPDATE -eq "yes"){
	PrintJobToDo "Install PSWindowsUpdate modul for PowerShell"
	# https://petri.com/how-to-manage-windows-update-using-powershell/
	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
	Start-Sleep -s 5
	Install-Module -Name PSWindowsUpdate -Force
	Start-Sleep -s 3
	Get-Command -Module PSWindowsUpdate
	Start-Sleep -s 3
	PrintJobDone "PSWindowsUpdate modul for PowerShell installed"
	Start-Sleep -s 2
	Clear-Host []
	PrintJobToDo "Install all pending updates"
	Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot
	Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
	PrintJobDone "all updates installed"
	Start-Sleep -s 3

}else {
	PrintJobError "Windows updates not installed"
	Start-Sleep -s 5
}


################################################
## open the *password_username.txt files
################################################

Notepad $env:USERPROFILE\Desktop\ftp_password_username.txt 

if($ADMINUPDATE -eq "yes"){
	Notepad $env:USERPROFILE\Desktop\admin_password_username.txt 
}elseif($Resellerclient -eq "yes"){
	Notepad $env:USERPROFILE\Desktop\reseller_admin_password_username.txt 
}elseif($SSH -eq "yes"){
	Notepad $env:USERPROFILE\Desktop\ssh_password_username.txt 
}

################################################
## finished
################################################

Clear-Host []
PrintJobDone "all installer scripts are done - please write down the passwords and restart the computer"
