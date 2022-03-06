#################################################
# Written by Jon Tally
#################################################

# Sets a var equal to the current computer name
$hostname = "$env:computername"

# Environmental variables
# Creates a string with the first letter of the first name and first three letters of the last jtal as an example from jon.tally
$User = ((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
$Separator = "."
$NameArray = $User.Split($Separator)
$FirstName = $NameArray[0]
$LastName = $NameArray[1]
$TrimmedFirstName = $FirstName.Substring(0,1)
$TrimmedLastName = $LastName.Substring(0,3)
$FormattedUser = ($TrimmedFirstName.TrimEnd(),$TrimmedLastName.TrimEnd()) -join ""

# Gathers the device serial number and creates a string and trims all the but last 4 characters
$Serialnumber = (Get-WmiObject -ClassName Win32_bios).Serialnumber
$Formattedserialnumber = $Serialnumber.Substring($Serialnumber.length -4, 4)

# Checks if the device is a laptop or not and sets a var device type
If((gwmi win32_computersystem -ea 0).pcsystemtype -ne 2)
{$DeviceType = "WD"}
Else
{$DeviceType = "WL"}

# Var to seperate the device type from the user and serial number
$NameSeparator = "-"

# Formatted computer name
$ComputerName = ($DeviceType.TrimEnd(),$NameSeparator,$FormattedUser.TrimEnd().ToUpper(),$Formattedserialnumber) -join ""

# Renames the computer with the environmental variable $ComputerName if the $ComputerName is 10 or 11
# (taking into account those with two letter last names) characters else exit with an error and do not rename

function WriteLog
{
    Param ([string]$LogString)
    $LogFile = "C:\$(Get-Content env:computername)_hostname.log"
    $DateTime = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    $LogMessage = "$Datetime $LogString"
    Add-content $LogFile -value $LogMessage
}
Try
{
if ( $hostname -eq $Computername )
    {
    WriteLog "Computer name equals script proposed change"
    Write-Host "Computer name equals script proposed change"
    }
else {
    ( $ComputerName.length -In 10..11 )
    WriteLog "Computer name changed via script"
    Rename-Computer -NewName $ComputerName
    Write-Host "Computer name changed via script, new name is $ComputerName" 
    }
}
catch
{
    WriteLog "Script Error, exit with failed status"
}