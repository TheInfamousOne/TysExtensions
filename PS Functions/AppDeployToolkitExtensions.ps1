<#
.SYNOPSIS
	This script is a template that allows you to extend the toolkit with your own custom functions.
.DESCRIPTION
	The script is automatically dot-sourced by the AppDeployToolkitMain.ps1 script.
.NOTES
.LINK 
	http://psappdeploytoolkit.codeplex.com
#>
[CmdletBinding()]
Param (
)

##*===============================================
##* VARIABLE DECLARATION
##*===============================================

# Variables: Script
[string]$appDeployToolkitExtName = 'PSAppDeployToolkitExt'
[string]$appDeployExtScriptFriendlyName = 'App Deploy Toolkit Extensions'
[version]$appDeployExtScriptVersion = [version]'1.5.0'
[string]$appDeployExtScriptDate = '11/06/2014'
[hashtable]$appDeployExtScriptParameters = $PSBoundParameters

##*===============================================
##* FUNCTION LISTINGS
##*===============================================

# Your custom functions go here

Function Get-MSIProperty {
<#
.SYNOPSIS
    Retrieves the value of a property defined in target MSI file Property Table
.DESCRIPTION
    Specify the full path to the MSI and the property name that stores the value to retrieve. Function will return the value if property is found in the MSI.
.EXAMPLE
    Get-MSIProperty "C:\windows\installer\abc123.msi" "ProductCode"
    Returns the ProductCode value from abc123.msi file.
.EXAMPLE
    $MyProductCode = Get-MSIProperty "C:\windows\installer\abc123.msi" "ProductCode"
    Returns the ProductCode value from abc123.msi file and then stores it in $MyProductCode variable.
.PARAMETER MSIFileName
    The full path to the target MSI file.
.PARAMETER MSIPropertyName
    The name of the property to retrieve.
.NOTES
.LINK
    Http://psappdeploytoolkit.codeplex.com
#>
    Param(
        [Parameter(Mandatory = $true)]
        [string] $MSIFileName,
        [string] $MSIPropertyName
    )
    
    $WindowsInstaller = New-Object -com WindowsInstaller.Installer
    $Database = $WindowsInstaller.GetType().InvokeMember(“OpenDatabase”, “InvokeMethod”, $Null, $WindowsInstaller, @($MSIFileName,0))
    $View = $Database.GetType().InvokeMember(“OpenView”, “InvokeMethod”, $Null, $Database, (“SELECT * FROM Property”))
    $View.GetType().InvokeMember(“Execute”, “InvokeMethod”, $Null, $View, $Null) | Out-Null

    $Record = $View.GetType().InvokeMember(“Fetch”, “InvokeMethod”, $Null, $View, $Null)

    while($Record -ne $Null)
    {
        $PropertyName = $Record.GetType().InvokeMember(“StringData”, “GetProperty”, $Null, $Record, 1)
        if ($PropertyName -eq $MSIPropertyName)
        {
            $PropertyValue = $Record.GetType().InvokeMember(“StringData”, “GetProperty”, $Null, $Record, 2)
            $PropertyValue
        }
        $Record = $View.GetType().InvokeMember(“Fetch”, “InvokeMethod”, $Null, $View, $Null)
    }

    $View.GetType().InvokeMember(“Close”, “InvokeMethod”, $Null, $View, $Null) | Out-Null
}


Function SCCM-CreateStatusMIF {
<#
.SYNOPSIS
    Creates status MIF file for SCCM inventory.
.DESCRIPTION
    Specify Application Name, Version, Success or Failure, and success message to be written to MIF file.
.EXAMPLE
    SCCM-CreateStatusMIF "Application Title" "1.0" "Success" "Success: Application Title 1.0 installation completed successfully."
    Creates status MIF file with these items.
.PARAMETER strAppName
    The name of the application being installed.
.PARAMETER strAppVersion
    The version of the application being installed.
.PARAMETER strResult
    Success or Failure
.PARAMETER strResultMessage
    Result summary message.
.NOTES
    Ver 1.0 - Corwin Oakman - 10/24/2014

#>
    Param(
        [Parameter(Mandatory = $true)]
        [string] $strAppName,
        [string] $strAppVer,
        [string] $strResult,
        [string] $strResultMessage
    )

    $strDateTime = Get-Date

    $intAppNameLoc = 20
    $intAppVerLoc = 28
    $intDateTimeLoc = 52
    $intResultLoc = 65
    $intResultMessageLoc = 73

    $strBaseMIF = @(
    "START COMPONENT",
    "NAME = ""WORKSTATION""",
    "  START GROUP",
    "    NAME = ""ComponentID""",
    "    ID = 1",
    "    CLASS = ""DMTF|ComponentID|1.0""",
    "    START ATTRIBUTE",
    "      NAME = ""Manufacturer""",
    "      ID = 1",
    "      ACCESS = READ-ONLY",
    "      STORAGE = SPECIFIC",
    "      TYPE = STRING(64)",
    "      VALUE = ""DEAP""",
    "    END ATTRIBUTE",
    "    START ATTRIBUTE",
    "      NAME = ""Product""",
    "      ID = 2",
    "      ACCESS = READ-ONLY",
    "      STORAGE = SPECIFIC",
    "      TYPE = STRING(64)",
    "      VALUE = ""$strAppName""",
    "    END ATTRIBUTE",
    "    START ATTRIBUTE",
    "      NAME = ""Version""",
    "      ID = 3",
    "      ACCESS = READ-ONLY",
    "      STORAGE = SPECIFIC",
    "      TYPE = STRING(64)",
    "      VALUE = ""$strAppVer""",
    "    END ATTRIBUTE",
    "    START ATTRIBUTE",
    "      NAME = ""Locale""",
    "      ID = 4",
    "      ACCESS = READ-ONLY",
    "      STORAGE = SPECIFIC",
    "      TYPE = STRING(16)",
    "      VALUE = ""ENU""",
    "    END ATTRIBUTE",
    "    START ATTRIBUTE",
    "      NAME = ""Serial Number""",
    "      ID = 5",
    "      ACCESS = READ-ONLY",
    "      STORAGE = SPECIFIC",
    "      TYPE = STRING(64)",
    "      VALUE = "" """,
    "    END ATTRIBUTE",
    "    START ATTRIBUTE",
    "      NAME = ""Installation""",
    "      ID = 6",
    "      ACCESS = READ-ONLY",
    "      STORAGE = SPECIFIC",
    "      TYPE = STRING(64)",
    "      VALUE = ""$strDateTime""",
    "    END ATTRIBUTE",
    "  END GROUP",
    "  START GROUP",
    "    NAME = ""InstallStatus""",
    "    ID = 2",
    "    CLASS = ""MICROSOFT|JOBSTATUS|1.0""",
    "    START ATTRIBUTE",
    "      NAME = ""Status""",
    "      ID = 1",
    "      ACCESS = READ-ONLY",
    "      STORAGE = SPECIFIC",
    "      TYPE = STRING(32)",
    "      VALUE = ""$strResult""",
    "    END ATTRIBUTE",
    "    START ATTRIBUTE",
    "      NAME = ""Description""",
    "      ID = 2",
    "      ACCESS = READ-ONLY",
    "      STORAGE = SPECIFIC",
    "      TYPE = STRING(128)",
    "      VALUE = ""$strResultMessage""",
    "    END ATTRIBUTE",
    "  END GROUP",
    "END COMPONENT"
    )

    Try
    {
        $objSMMCTSEnv = New-ObjectÂ -COMObjectÂ Microsoft.SMS.TSEnvironment
    }
    Catch
    {
        $strMIFName = "c:\windows\" + $strAppName + " " + $strAppVer + ".mif"
        $strBaseMIF | Out-File -FilePath "$strMIFName" -Force
    }

}


Function Inject-HKCURegKeys{

<#
.SYNOPSIS
Injects All HKCU RegKeys to all user profiles you have listed in your .reg file.
.DESCRIPTION
Just copy the reg key into the supportfiles folder and write the name of the reg file in you command.
.PARAMETER RegFileName
The name of the reg file you created
.EXAMPLE
Inject-HKCU -RegFileName YourRegFileName.reg
.NOTES
v 1.0 Alpha  Ty Stallard & Kevin Doran  11/12/2014
.LINK
    Http://psappdeploytoolkit.codeplex.com
#>

Param(
        [Parameter(Mandatory = $true)]
        [string] $RegFileName
    )


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


Function Delete-RegKey{

    <#
.SYNOPSIS
Deletes All RegKeys you have listed in  your .reg file.
.DESCRIPTION
Just copy the reg key you would like ot inject into the SupportFiles directory in your project and enter the name of the reg file in your RegFileName parameter.
.PARAMETER RegFileName
The name of the reg file you created
.EXAMPLE
Delete-RegKey -RegFileName YourRegFileName.reg
.NOTES
v 1.0 Alpha  Ty Stallard & Kevin Doran  11/12/2014
.LINK
    Http://psappdeploytoolkit.codeplex.com
#>

Param(
        [Parameter(Mandatory = $true)]
        [string] $RegFileName
    )


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

        foreach ($KeyValue in $HKCUValue)
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
                        foreach ($KeyValue in $HKCUValue)
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
                        foreach ($KeyValue in $HKCUValue)
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


Function CopyTo-ProfileAppData {

    <#
.SYNOPSIS
Copies any file(s) into the UserProfile\AppData\Roaming folder from the SupportFiles directory.
.DESCRIPTION
Just type in file names and vendor folder name in the parameter.
.EXAMPLE
CopyTo-RoamingProfiles -CopyArray "somefile.txt", "somefile.xlsx" -VendorFolder "Visual Cactus"
.EXAMPLE
This is an example if you needed to copy files into a nested folder inside the vendor folder.

Be sure you picked the correct folder you're copying into your AppData folder. There are usually three folders.
1.)Local
2.)LocalLow
3.)Roaming

CopyTo-RoamingProfiles -CopyArray "somefile.txt", "somefile.xlsx" -VendorFolder "Roaming\Visual Cactus\Config\XML"

.PARAMETER CopyArray
The name of the files you want to copy form the SupportFiles directory.
.PARAMETER VendorFolder
The name of the vendor folder you want to copy to inside the Profile\AppData\ folder
.NOTES
v 1.0 Ty Stallard & Kevin Doran  11/12/2014
.LINK
    Http://psappdeploytoolkit.codeplex.com
#>

Param(
        [Parameter(Mandatory = $true)]
        [string[]] $CopyArray,
        [string] $VendorFolder
    ) 


$profilenames = Get-ChildItem -Attributes d,h -Path c:\users -Name *
$PROFILEDIR = "C:\Users"
$AppDataExceptions = "Administrator", "Public", "All Users", "Defualt User", "Desktop.ini", "pfuser"



Write-Log -Message "|COPY TO APPDATA PROFILE|*** START ***"
foreach ($profilename in $profilenames) {
If ($AppDataExceptions -contains $profilename)
{}
    Else{
         Write-Log -Message "Info:Copying $FilesToCopy to the $PROFILEDIR\$PROFILENAME\AppData\$VendorFolder directory"
         New-Item -ItemType directory -Path "$PROFILEDIR\$PROFILENAME\AppData\$VendorFolder"
         foreach ($FileItem in $CopyArray)
         {
         Copy-File -Path $dirSupportFiles\$FileItem -Destination "$PROFILEDIR\$PROFILENAME\AppData\$VendorFolder"   
         }
         
         }
        
}
Write-Log -Message "|COPY TO APPDATA PROFILE |*** END ***"
}

Function Set-FolderPermission {

<# 
.SYNOPSIS
Set Folder and file permissions 
.DESCRIPTION
This fuction will set permissions on a folder, file or registry key. You just need to add the correct paramters
.EXAMPLE
Set-FolderPermission -Folder "C:\Path\To\YourFolder" -GroupName "Users" -PermType "Modify"
.PARAMETER Folder
This will be just the path to your folder you want to set the permissions on. e.g. "C:\Test\SomeFolder"
.PARAMETER GroupName
This is the name of the group to set the permissioms for. e.g. "Users", "Administrators" etc.
.PARAMETER PermType 
The types of permissions you want to set.  e.g. "Modify", "FullControl", "Read", Write" etc.
.NOTES
Version 1.0 Ty Stallard
.LINK
Http://psappdeploytoolkit.codeplex.com
#>

Param(
        [Parameter(Mandatory = $true)]
        [string]$Folder,
        [string]$GroupName,
        [string]$PermType
    ) 

Write-Log -Message "|SET FOLDER PERMISSIONS| *** START *** "
Write-Log -Message "Setting $PermType permissions for $GroupName on $Folder"
$Acl = Get-Acl $Folder
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule($GroupName, $PermType, "ContainerInherit, ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl "$Folder" $Acl
Write-Log -Message "|SET FOLDER PERMISSIONS| *** END *** "
}

Function Set-FilePermission {

<#
 
.SYNOPSIS
Set Folder and file permissions 
.DESCRIPTION
This fuction will set permissions on a folder, file or registry key. You just need to add the correct paramters
.EXAMPLE
Set-FolderPermission -PathToFile "C:\Path\To\YourFile" -GroupName "Users" -PermType "Modify"
.PARAMETER PathToFile
The path to the file you want to set the permissions on. e.g. "C:\Program Files\SomeFolder"
.PARAMETER GroupName
This is the name of the group to set the permissioms for. e.g. "Users", "Administrators" etc.
.PARAMETER PermType 
This is the types of permissions you want to set. e.g. "Modify" or "FullControl" or "Read" or "Write" or "Read, Write".  etc...
.NOTES
Version 1.0 Ty Stallard
.LINK
Http://psappdeploytoolkit.codeplex.com
#>

Param(
        [Parameter(Mandatory = $true)]
        [string]$PathToFile,
        [string]$GroupName,
        [string]$PermType
    ) 

Write-Log -Message "|SET FILE PERMISSIONS| *** START *** "
Write-Log -Message "Setting $PermType permissions for $GroupName on $PathToFile"
$Acl = Get-Acl $PathToFile
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule($GroupName, $PermType, "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl "$PathToFile" $Acl
Write-Log -Message "|SET FILE PERMISSIONS| *** END *** "
}

##*===============================================
##* END FUNCTION LISTINGS
##*===============================================

##*===============================================
##* SCRIPT BODY
##*===============================================

If ($scriptParentPath) {
	Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] dot-source invoked by [$(((Get-Variable -Name MyInvocation).Value).ScriptName)]" -Source $appDeployToolkitExtName
}
Else {
	Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] invoked directly" -Source $appDeployToolkitExtName
}

##*===============================================
##* END SCRIPT BODY
##*===============================================