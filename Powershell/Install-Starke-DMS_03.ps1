# 23.11.2022 Eike Doose / INTERNAL USER ONLY / do not distribute
# create ranndom password according to SDMS cloud security guideline
# https://www.active-directory-faq.de/2016/05/powershell-zufaelliges-passwort-nach-eigenen-vorgaben-generieren/
# =========================================================================================


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

Write-Warning "This is only a test warning." -WarningAction Inquire
WARNING: This is only a test warning.
Confirm
Continue with this operation?
 [Y] Yes  [N] No [?] Help (default is "N"):
 
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 1st" 
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 2nd" 
Read-Host -Prompt "Press any key to continue or CTRL+C to quit - 3rd" 

Clear-Host []

Write-Host -ForegroundColor Green "########################################"
Write-Host -ForegroundColor Green "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor Green "### the following new admin password ###"
Write-Host -ForegroundColor Green "##### will be set for Adminstrator #####"
Write-Host -ForegroundColor Green "########################################"
Write-Host -ForegroundColor red   "###########" $password "###########"
Write-Host -ForegroundColor Green "########################################"
Write-Host -ForegroundColor Green "########################################"
Write-Host 
Write-Host 
Write-Host 

$NewPassword = convertto-securestring $password -asplaintext -force

Set-LocalUser -Name Administrator -Password $NewPassword –Verbose

Clear-Host []




Write-Host -ForegroundColor Green "########################################"
Write-Host -ForegroundColor Green "##### Starke-DMS® cloud installer ######"
Write-Host -ForegroundColor Green "### the following new admin password ###"
Write-Host -ForegroundColor Green "##### will be set for Adminstrator #####"
Write-Host -ForegroundColor Green "########################################"
Write-Host -ForegroundColor red   "###########" $password "###########"
Write-Host -ForegroundColor Green "########################################"
Write-Host -ForegroundColor Green "########################################"
Write-Host 
Write-Host 
Write-Host 



# rename "Administrator" to "GottliebKrause"
# Rename-LocalUser -Name "Administrator"  -NewName "GottliebKrause"
# Get-LocalUser 

