# 23.11.2022 Eike Doose / INTERNAL USER ONLY / do not disribute
# create ranndom password according to SDMS cloud security guideline
# rename the Administrator user
# https://www.active-directory-faq.de/2016/05/powershell-zufaelliges-passwort-nach-eigenen-vorgaben-generieren/
# =========================================================================================

################################################
## start transcript
################################################

$t=(get-date -format "yyyy-MM-dd_HH-mm-ss")
Start-Transcript -Path "c:\install\_Log-Install-Starke-DMS_02-$t.txt" 


################################################
## stop script on PowerShell error 
################################################

$ErrorActionPreference = "Stop"


<#
################################################
## detect Powershe version - minimum 7
################################################
If ($PSVersionTable.PSVersion.Major -lt 7) {
    Throw "PowerShell version 7 or higher is required."
}
Clear-Host []
#>


<################################################
## password generator
################################################>
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

$password = Scramble-String $password
#$ftppassword = Scramble-String $password

Clear-Host []
<#
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor red "##### will set a new admin password ####"
Write-Host -ForegroundColor red "##### and username for Adminstrator ####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "#####  the new password and admin   ####"
Write-Host -ForegroundColor red "#####     name will be saved      ######"
Write-Host -ForegroundColor red "##### on the desktop in the file    ####"
Write-Host -ForegroundColor red "#### >>> password_username.txt <<<  ####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "##### DELETE THIS FILE IMMEDIATELY #####"
Write-Host -ForegroundColor red "#####   WHEN SERVER IS SET UP     ######"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "########################################"
Write-Warning "This is a serious warning." -WarningAction Inquire
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "########################################"
#>
Clear-Host []

$NewPassword = convertto-securestring $password -asplaintext -force

Set-LocalUser -Name Administrator -Password $NewPassword –Verbose

# Clear-Host []

<#
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor red "##### NEW ADMIN PASSWORD WAS SET   #####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor Green "########################################"
Write-Host -ForegroundColor Green "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor Green "### the following new admin password ###"
Write-Host -ForegroundColor Green "##### will be set for Adminstrator #####"
Write-Host -ForegroundColor Green "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor CYAN "########################################"
Write-Host -ForegroundColor CYAN "############# NEW PASSWORD #############"
Write-Host -ForegroundColor white "###########" $password "###########"
Write-Host -ForegroundColor CYAN "########################################"
Write-Host -ForegroundColor CYAN "########################################"
Write-Host 
Write-Host 
Write-Warning "This is a serious warning." -WarningAction Inquire
#>

# Clear-Host []

Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor red "#####         ** NOW **            ######"
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor cyan "##### will change Admin username  ######"
Write-Host -ForegroundColor cyan "########################################"
Write-Host
Write-Host
Write-Host

pause

# Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
# rename "Administrator" to "GottliebKrause"
Rename-LocalUser -Name "Administrator"  -NewName "GottliebKrause"
Start-Sleep -s 1
wmic useraccount where "Name='GottliebKrause'" set PasswordExpires=false
#wmic useraccount where "Name='Administrator'" set PasswordExpires=false

pause

<#
Write-Host
Write-Host
Write-Host -ForegroundColor CYAN "########################################"
Write-Host -ForegroundColor CYAN "############ NEW Admin user ############"
Write-Host -ForegroundColor CYAN "###########  GottliebKrause  ###########"
Write-Host -ForegroundColor CYAN "############ NEW Admin user ############"
Write-Host -ForegroundColor CYAN "########################################"
Write-Host 
Write-Host 
Write-Host 
Get-LocalUser 
Write-Host
Write-Host
Write-Host
# Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
#>

<#
## /////////////////////////////////////////////
## create new FTP user
## /////////////////////////////////////////////
# https://www.server-world.info/en/note?os=Windows_Server_2019&p=initial_conf&f=1
New-LocalUser -Name "SDMSC1-99999" `
-FullName "Starke-DMS Cloud 1.0 FileXchange user" `
-Description "FTP user" `
-Password (ConvertTo-SecureString -AsPlainText $ftppassword -Force) `
-PasswordNeverExpires `
-AccountNeverExpires 

New-LocalGroup -Name "FTPGroup"

Add-LocalGroupMember -Group "FTPGroup" -Member "SDMSC1-99999" 
#>


## /////////////////////////////////////////////
## write new password and admin username to file
## /////////////////////////////////////////////
# 'New admin name and password',$t,'--------------------','new password',$Password,'--------------------','new admin user','"GottliebKrause"','--------------------','DELETE THIS FILE IMMEDIATELY','--------------------'  | out-file $env:USERPROFILE\Desktop\admin_password_username.txt

'New admin name and password', `
$t, `
'--------------------', `
'new password', `
$Password, `
'--------------------', `
'new admin user', `
'"GottliebKrause"', `
'--------------------', `
'DELETE THIS FILE IMMEDIATELY', `
'--------------------'  |  `
out-file $env:USERPROFILE\Desktop\admin_password_username.txt


Start-Sleep -s 1

stop-transcript
Clear-Host []

pause

Write-Host -ForegroundColor CYAN "########################################"
Write-Host -ForegroundColor CYAN "########################################"
Write-Host
Write-Host
Get-LocalUser Go*
Write-Host
Write-Host
Write-Host -ForegroundColor CYAN "########################################"
Write-Host -ForegroundColor CYAN "########################################"

Notepad $env:USERPROFILE\Desktop\admin_password_username.txt 

