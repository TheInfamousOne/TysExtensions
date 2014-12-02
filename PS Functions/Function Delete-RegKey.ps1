Function Delete-RegKey{

Param(
        [Parameter(Mandatory = $true)]
        [string] $RegFileName
    )

    <#
.SYNOPSIS
Deletes All RegKeys you have listed in  your .reg file.
.DESCRIPTION
Just copy the reg key into the SupportFiles directory in your project and enter the name of the reg file in you command.
.PARAMETER $RegFileName
The name of the reg file you created
.EXAMPLE
Delete-RegKey -RegFileName YourRegFileName.reg
.NOTES
v 0.5 Alpha  Ty Stallard & Kevin Doran  11/07/2014
#>


$LOGGEDONUSER = [Environment]::UserName
$profilenames = Get-ChildItem -Attributes d,h -Path c:\users -Name *
$PROFILEDIR = "C:\Users"
$exceptions = "Administrator", "Public", "All Users", "Default User", "desktop.ini", "pfuser" , "$LOGGEDONUSER"
$GetKey = test-path -Path $dirSupportFiles\$RegFileName



Write-Log -Message "|DELETE REG KEY ** START **| "
if ($GetKey -eq "True")
{
 if ($LOGGEDONUSER -eq "")
   {
    foreach ($profilename in $profilenames){
      if ($exceptions -contains $profilename){}
      else
      {
       Write-Log -Message "Info:Loading HKU\$PROFILENAME profile"
       reg LOAD HKU\"$PROFILENAME" "$PROFILEDIR\$PROFILENAME\NTUSER.DAT"
       (gc $dirSupportFiles\$RegFileName).Replace("HKEY_CURRENT_USER", "-HKEY_USERS\$PROFILENAME")|sc $dirSupportFiles\$RegFileName
       (gc $dirSupportFiles\$RegFileName).Replace("HKEY_LOCAL_MACHINE", "-HKEY_LOCAL_MACHINE")|sc $dirSupportFiles\$RegFileName
       Write-Log -Message "Info:Deleting Reg Keys for $PROFILENAME"
       reg import "$dirSupportFiles\$RegFileName"
       Write-Log -Message "Info:Unloading HKU\$PROFILENAME profile"
       reg unload HKU\"$PROFILENAME"
       (gc $dirSupportFiles\$RegFileName).Replace("-HKEY_USERS\$PROFILENAME", "HKEY_CURRENT_USER")|sc $dirSupportFiles\$RegFileName
       (gc $dirSupportFiles\$RegFileName).Replace("-HKEY_LOCAL_MACHINE", "HKEY_LOCAL_MACHINE")|sc $dirSupportFiles\$RegFileName      
      }    
    }   
 }
 else
  {
   Write-Log -Message "Info: Detected $LOGGEDONUSER currently logged in, importing HKCU registry key"
   (gc $dirSupportFiles\$RegFileName).Replace("HKEY_CURRENT_USER", "-HKEY_CURRENT_USER")|sc $dirSupportFiles\$RegFileName
   (gc $dirSupportFiles\$RegFileName).Replace("HKEY_LOCAL_MACHINE", "-HKEY_LOCAL_MACHINE")|sc $dirSupportFiles\$RegFileName
   Write-Log -Message "Info: Deleting Reg Key(s) for $LOGGEDONUSER"
   reg import "$dirSupportFiles\$RegFileName"
   (gc $dirSupportFiles\$RegFileName).Replace("-HKEY_CURRENT_USER", "HKEY_CURRENT_USER")|sc $dirSupportFiles\$RegFileName
   (gc $dirSupportFiles\$RegFileName).Replace("-HKEY_LOCAL_MACHINE", "HKEY_LOCAL_MACHINE")|sc $dirSupportFiles\$RegFileName 
   foreach ($profilename in $profilenames){
      if ($exceptions -contains $profilename){}
      else
      {
       Write-Log -Message "Info:Loading HKU\$PROFILENAME profile"
       reg LOAD HKU\"$PROFILENAME" "$PROFILEDIR\$PROFILENAME\NTUSER.DAT"
       (gc $dirSupportFiles\$RegFileName).Replace("HKEY_CURRENT_USER", "-HKEY_USERS\$PROFILENAME")|sc $dirSupportFiles\$RegFileName
       (gc $dirSupportFiles\$RegFileName).Replace("HKEY_LOCAL_MACHINE", "-HKEY_LOCAL_MACHINE")|sc $dirSupportFiles\$RegFileName
       Write-Log -Message "Info:Deleting Reg Keys for $PROFILENAME"
       reg import "$dirSupportFiles\$RegFileName"
       Write-Log -Message "Info:Unloading HKU\$PROFILENAME profile"
       reg unload HKU\"$PROFILENAME"
       (gc $dirSupportFiles\$RegFileName).Replace("-HKEY_USERS\$PROFILENAME", "HKEY_CURRENT_USER")|sc $dirSupportFiles\$RegFileName
       (gc $dirSupportFiles\$RegFileName).Replace("-HKEY_LOCAL_MACHINE", "HKEY_LOCAL_MACHINE")|sc $dirSupportFiles\$RegFileName      
       }      
      }    
    }    
  }
else
{
Write-Log -Message "Error: $RegFileName file is not found in the SupportFiles directory"    
}
Write-Log -Message "|DELETE REG KEY ** END **|"

}