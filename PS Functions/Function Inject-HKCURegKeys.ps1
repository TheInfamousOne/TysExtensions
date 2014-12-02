Function Inject-HKCURegKeys{

Param(
        [Parameter(Mandatory = $true)]
        [string] $RegFileName
    )

<#
.SYNOPSIS
Injects All HKCU RegKeys to all user profiles you have listed in your .reg file.
.DESCRIPTION
Just copy the reg key into the supportfiles folder and write the name of the reg file in you command.
.PARAMETER $RegFileName
The name of the reg file you created
.EXAMPLE
Inject-HKCU -RegFileName YourRegFileName.reg
.NOTES
v 0.5 Alpha  Ty Stallard & Kevin Doran  11/07/2014
#>


$LOGGEDONUSER = [Environment]::UserName
$profilenames = Get-ChildItem -Attributes d,h -Path c:\users -Name *
$PROFILEDIR = "C:\Users"
$exceptions = "Administrator", "Public", "All Users", "Default User", "desktop.ini", "pfuser" , "$LOGGEDONUSER"
$GetKey = test-path -Path $dirSupportFiles\$RegFileName
$UninstallCopyPath = "C:\WsMgmt\Logs\Uninstall\$appName $appVersion\SupportFiles"




Write-Log -Message "|HKCU INJECTION| *** START *** "
Write-Log -Message "Copying SupportFiles to the $UninstallCopyPath folder"
New-Folder "$UninstallFolder\SupportFiles" -ContinueOnError $true
Copy-File -Path $dirSupportFiles\$RegFileName -Destination $UninstallCopyPath\$RegFileName
if ($GetKey -eq "True")
{
 if ($LOGGEDONUSER -eq "")
   {
    foreach ($profilename in $profilenames){
      if ($exceptions -contains $profilename){}
      else
      {
       Write-Log -Message "Info:Loading Registry Hive for HKU machine profile $PROFILENAME"
       reg LOAD HKU\"$PROFILENAME" "$PROFILEDIR\$PROFILENAME\NTUSER.DAT"
       (gc $dirSupportFiles\$RegFileName).Replace("HKEY_CURRENT_USER", "HKEY_USERS\$PROFILENAME")|sc $dirSupportFiles\$RegFileName
       Write-Log -Message "Info:Importing HKCU keys for $PROFILENAME"
       reg import "$dirSupportFiles\$RegFileName"
       reg unload HKU\"$PROFILENAME"
       (gc $dirSupportFiles\$RegFileName).Replace("HKEY_USERS\$PROFILENAME", "HKEY_CURRENT_USER")|sc $dirSupportFiles\$RegFileName      
      }    
    }   
 }
 else
  {
   Write-Log -Message "Info: Detected $LOGGEDONUSER currently logged in, importing HKCU registry key"
   reg import "$dirSupportFiles\$RegFileName"
   foreach ($profilename in $profilenames){
      if ($exceptions -contains $profilename){}
      else
      {
       Write-Log -Message "Info:Loading Registry Hive for HKU machine profile $PROFILENAME"
       reg LOAD HKU\"$PROFILENAME" "$PROFILEDIR\$PROFILENAME\NTUSER.DAT"
       (gc $dirSupportFiles\$RegFileName).Replace("HKEY_CURRENT_USER", "HKEY_USERS\$PROFILENAME")|sc $dirSupportFiles\$RegFileName
       Write-Log -Message "Info:Importing HKCU keys for $PROFILENAME"
       reg import "$dirSupportFiles\$RegFileName"
       reg unload HKU\"$PROFILENAME"
       (gc $dirSupportFiles\$RegFileName).Replace("HKEY_USERS\$PROFILENAME", "HKEY_CURRENT_USER")|sc $dirSupportFiles\$RegFileName      
       }      
      }    
    }    
  }
else
{
Write-Log -Message "Error: $RegFileName file is not found in the SupportFiles directory"    
}
Write-Log -Message "|HKCU INJECTION| *** END ***"



}