Function Delete-RegKeyValue {

    <#
.SYNOPSIS
Deletes Reg Key Values you want specifically deleted.
.DESCRIPTION
Just type in the path and the name of the string, dword you would like to delete.
.PARAMETER HKCUPath
The HKEY_CURRENT_USER path to the key where the key value resides.
.PARAMETER HKCUValue
The name of the value you want specifically deleted. It can be a string name or a dword name etc.
This can also be an array of key values as long as it's in the same key path. See Example Below.
.EXAMPLE
Delete-RegKeyValue -HKCUPath Software\Logitech\Info -HKCUValue "OS", "SetPoint6Version", "Default"
.NOTES
v 1.0 Ty Stallard & Kevin Doran  11/12/2014
.LINK
    Http://psappdeploytoolkit.codeplex.com

#>

Param(
        [Parameter(Mandatory = $true)]
        [string] $HKCUPath,
        [string[]] $HKCUValue
    )

$LOGGEDONUSER = [Environment]::UserName
$profilenames = Get-ChildItem -Attributes d,h -Path c:\users -Name *
$PROFILEDIR = "C:\Users"
$exceptions = "Administrator", "Public", "All Users", "Default User", "Desktop.ini", "pfuser" , "$LOGGEDONUSER"
$GetKeyValue = Get-RegistryKey -Key HKCU\$HKCUPath -Value $KeyValue
$IsValueNull = [string]::IsNullOrEmpty($GetKeyValue)




Write-Log -Message "|HKCU VALUE DELETION|*** START ***"
if ($LOGGEDONUSER -ne "")
{
 Write-Log -Message "Info:$LOGGEDONUSER is currently logged into the machine"   

        foreach ($KeyValue in $HKCUValues)
        {
        Write-Log -Message "$KeyValue"
                if ($IsValueNull -eq "True")
                {
                Write-Log -Message "Info:REGISTRY PATH [HKCU\$HKCUPath] <$HKCUValue> WAS NOT FOUND for $PROFILENAME"    
                }
                else
                {
                Write-Log -Message "Deleting HKCU\$HKCUPath <$KeyValue>"
                reg delete HKCU\$HKCUPath /v $KeyValue /f   
                }   
         }
        foreach ($PROFILENAME in $PROFILENAMES)
        {
                if ($EXCEPTIONS -contains $PROFILENAME){}

                else
                {
                 Write-Log -Message "Info:Loading HKCU hive for $PROFILENAME"
                 reg LOAD HKU\"$PROFILENAME" "$PROFILEDIR\$PROFILENAME\NTUSER.DAT"
                 $GetKeyValue1 = Get-RegistryKey -Key HKU\$PROFILENAME\$HKCUPath -Value $KeyValue
                 $IsValueNull1 = [string]::IsNullOrEmpty($GetKeyValue1)
                        foreach ($KeyValue in $HKCUValues)
                        {
                            if ($IsValueNull1 -eq "TRUE")
                            {
                            Write-Log -Message "Info:REGISTRY PATH [HKCU\$HKCUPath] <$KeyValue> WAS NOT FOUND for $PROFILENAME"   
                            }
                            else
                            {
                            Write-Log -Message "Info:Deleting Registry Key Value from [HKCU\$PROFILENAME\$HKCUPath] <$KeyValue>"
                            reg delete HKU\$PROFILENAME\$HKCUPath /v $KeyValue /f    
                            }           
                        } 
                 Write-Log -Message "Info:Unloading Registry Hive for HKU machine profile $PROFILENAME"  
                 reg unload HKU\"$PROFILENAME"                               
                }
           }
}


else
{
  foreach ($PROFILENAME in $PROFILENAMES)
        {
                if ($EXCEPTIONS -contains $PROFILENAME){}

                else
                {
                 Write-Log -Message "Info:Loading HKCU hive for $PROFILENAME"
                 reg LOAD HKU\"$PROFILENAME" "$PROFILEDIR\$PROFILENAME\NTUSER.DAT"
                 $GetKeyValue1 = Get-RegistryKey -Key HKU\$PROFILENAME\$HKCUPath -Value $KeyValue
                 $IsValueNull1 = [string]::IsNullOrEmpty($GetKeyValue1)
                        foreach ($KeyValue in $HKCUValues)
                        {
                            if ($IsValueNull1 -eq "TRUE")
                            {
                            Write-Log -Message "Info:REGISTRY PATH [HKCU\$HKCUPath] <$KeyValue> WAS NOT FOUND for $PROFILENAME"   
                            }
                            else
                            {
                            Write-Log -Message "Info:Deleting Registry Key Value from [HKCU\$PROFILENAME\$HKCUPath] <$KeyValue>"
                            reg delete HKU\$PROFILENAME\$HKCUPath /v $KeyValue /f    
                            }           
                        } 
                 Write-Log -Message "Info:Unloading Registry Hive for HKU machine profile $PROFILENAME"  
                 reg unload HKU\"$PROFILENAME"                               
                }
           }  
}
}