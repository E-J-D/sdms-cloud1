# 23.11.2022 Eike Doose / INTERNAL USER ONLY / do not disribute
# create ranndom password according to SDMS cloud security guideline
# rename the Administrator user
# https://www.active-directory-faq.de/2016/05/powershell-zufaelliges-passwort-nach-eigenen-vorgaben-generieren/
# =========================================================================================

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

$result=$yr+$mo+$dy+$hr+$mn+$sec

return $result
}
$t=Get-TimeStamp

#$dt=get-date -Format "yyyy-MM-dd"
#$time=get-time
Start-Transcript -Path "c:\install\_Log03-$t.txt" 
#start-transcript c:\Install\_Log.txt

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

# Write-Host $password

$password = Scramble-String $password

Clear-Host []

Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor red "##### will set a new admin password ####"
Write-Host -ForegroundColor red "##### and username for Adminstrator ####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "##### THESE HAVE TO BE WRITTEN DOWN ####"
Write-Host -ForegroundColor red "#####     IN THE DOCUMENTATION    ######"
Write-Host -ForegroundColor red "##### ! THESE WILL NOT BE SAVED !   ####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "########################################"
Write-Warning "This is a serious warning." -WarningAction Inquire
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "########################################"

Clear-Host []

Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor red "#####            AGAIN            ######"
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor cyan "##### will set a new admin password ####"
Write-Host -ForegroundColor cyan "##### and username for Adminstrator ####"
Write-Host -ForegroundColor cyan "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "##### THESE HAVE TO BE WRITTEN DOWN ####"
Write-Host -ForegroundColor red "#####     IN THE DOCUMENTATION    ######"
Write-Host -ForegroundColor red "##### ! THESE WILL NOT BE SAVED !   ####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "#####     CONFIRMATION 1 of 3      #####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 1st" 
Write-Host
Write-Host
Write-Host -ForegroundColor yellow "########################################"
Write-Host -ForegroundColor yellow "#####     CONFIRMATION 2 of 3      #####"
Write-Host -ForegroundColor yellow "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 2nd" 
Write-Host
Write-Host
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "#####     CONFIRMATION 3 of 3      #####"
Write-Host -ForegroundColor cyan "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 3rd" 

Clear-Host []

Write-Host -ForegroundColor Green "########################################"
Write-Host -ForegroundColor Green "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor Green "### the following new admin password ###"
Write-Host -ForegroundColor Green "##### will be set for Adminstrator #####"
Write-Host -ForegroundColor Green "########################################"
Write-Host -ForegroundColor WHITE "###########" $password "###########"
Write-Host -ForegroundColor Green "########################################"
Write-Host -ForegroundColor Green "########################################"
Write-Host 
Write-Host 
Write-Host 

$NewPassword = convertto-securestring $password -asplaintext -force

Set-LocalUser -Name Administrator -Password $NewPassword –Verbose

Clear-Host []


Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor red "##### NEW ADMIN PASSWORD WAS SET   #####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "#####  THIS HAS TO BE WRITTEN DOWN #####"
Write-Host -ForegroundColor red "#####     IN THE DOCUMENTATION    ######"
Write-Host -ForegroundColor red "#####   ! IT WILL NOT BE SAVED !   #####"
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
Write-Host 
Write-Warning "This is a serious warning." -WarningAction Inquire
Write-Host 
Write-Host 
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor red  "####          ONCE AGAIN            ####"
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor cyan "##### has set a new admin password #####"
Write-Host -ForegroundColor white "#####         WRITE IT DOWN        #####"
Write-Host -ForegroundColor cyan "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "#####     CONFIRMATION 1 of 3      #####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 1st" 
Write-Host
Write-Host
Write-Host -ForegroundColor yellow "########################################"
Write-Host -ForegroundColor yellow "#####     CONFIRMATION 2 of 3      #####"
Write-Host -ForegroundColor yellow "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 2nd" 
Write-Host
Write-Host
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "#####     CONFIRMATION 3 of 3      #####"
Write-Host -ForegroundColor cyan "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 3rd" 

Clear-Host []

Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor red "#####         ** NOW **            ######"
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor cyan "##### will change Admin username  ######"
Write-Host -ForegroundColor cyan "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "#####        WRITE THIS DOWN       #####"
Write-Host -ForegroundColor red "#####     IN THE DOCUMENTATION    ######"
Write-Host -ForegroundColor red "#####   ! IT WILL NOT BE SAVED !   #####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "#####     CONFIRMATION 1 of 3      #####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 1st" 
Write-Host
Write-Host
Write-Host -ForegroundColor yellow "########################################"
Write-Host -ForegroundColor yellow "#####     CONFIRMATION 2 of 3      #####"
Write-Host -ForegroundColor yellow "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 2nd" 
Write-Host
Write-Host
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "#####     CONFIRMATION 3 of 3      #####"
Write-Host -ForegroundColor cyan "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 3rd" 

Clear-Host []
Write-Host
Write-Host
Write-Host
# Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
# rename "Administrator" to "GottliebKrause"
Rename-LocalUser -Name "Administrator"  -NewName "GottliebKrause"
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
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 3rd" 


stop-transcript
Clear-Host []
Get-LocalUser Go*

Write-Host
Write-Host
Write-Host -ForegroundColor CYAN "########################################"
Write-Host -ForegroundColor CYAN "########################################"
Write-Host -ForegroundColor white "############ SERVER RESTART ############"
Write-Host -ForegroundColor CYAN "########################################"
Write-Host -ForegroundColor CYAN "########################################"
Write-Host 
Write-Host 
Write-Host
Write-Host
Write-Host -ForegroundColor red "########################################"
Write-Host -ForegroundColor red "#####     CONFIRMATION 1 of 3      #####"
Write-Host -ForegroundColor red "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 1st" 
Write-Host
Write-Host
Write-Host -ForegroundColor yellow "########################################"
Write-Host -ForegroundColor yellow "#####     CONFIRMATION 2 of 3      #####"
Write-Host -ForegroundColor yellow "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 2nd" 
Write-Host
Write-Host
Write-Host -ForegroundColor cyan "########################################"
Write-Host -ForegroundColor cyan "#####     CONFIRMATION 3 of 3      #####"
Write-Host -ForegroundColor cyan "########################################"
Write-Host
Write-Host
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 3rd" 

Restart-computer -force