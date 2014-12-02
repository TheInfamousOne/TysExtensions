Function Set-RegistryPermission {
<# 
.SYNOPSIS
Set registry permissions on any key 
.DESCRIPTION
This fuction will set permissions on a registry key. You just need to add the correct paramters
.EXAMPLE
Set-RegistryPermission -KeyPath "HKLM:\SOFTWARE\KeyOfYourChoice" -GroupName "Users" -PermType "FullControl"
.EXAMPLE
You can use the 'Convert-RegistryPath' to help convert "HKEY_LOCAL_MACHINE\SOFTWARE\KeyOfYourChoice" to "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\KeyOfYOurChoice" so it's compatible with built in PowerShell Cmdlets.
$ConvertMyKey = Convert-RegistryPath -Key "HKEY_LOCAL_MACHINE\SOFTWARE\KeyOfYOurChoice"
Set-RegistryPermission -KeyPath $ConvertMyKey -GroupName "Users" -PermType "FullControl"
.PARAMETER KeyPath
Path to key you want to set the permissions on. e.g. "HKLM:\Software\RegKeyOfYourChoice"
.PARAMETER GroupName
Name of the group you want to set the permissions on. e.g. "Users" or "Administrators" etc..
.PARAMETER PermType
The type of permission you want to set. e.g. "FullControl" or "ReadKey" or "ReadPermissions"
.NOTES
Version 1.0 Ty Stallard
.LINK
Http://psappdeploytoolkit.codeplex.com
#>

    Param(
        [Parameter(Mandatory = $true)]
        [String]$KeyPath,
        [String]$GroupName,
        [String]$PermType
        )

$acl= get-acl -path $KeyPath
$inherit = [system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit"
$propagation = [system.security.accesscontrol.PropagationFlags]"None"
$rule=new-object system.security.accesscontrol.registryaccessrule "$Groupname","$PermType",$inherit,$propagation,"Allow"
$acl.setaccessrule($rule)
$acl|set-acl
}