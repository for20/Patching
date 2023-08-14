$zipFilePath = "C:\Users\Administrator\Documents\curl-8.2.1_5-win32-mingw.zip" Change as your own
$targetPath = "C:\Windows\System32\curl.exe"
$Temp = "C:\Windows\Temp"


# Take ownership
$owner = [System.Security.Principal.NTAccount]"Administrators"
$acl = Get-Acl $targetPath
$acl.SetOwner($owner)
Set-Acl -Path $targetPath -AclObject $acl

# Grant full control permissions to Administrators with proper inheritance flags
$administrators = [System.Security.Principal.NTAccount]"BUILTIN\Administrators"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($administrators, "FullControl", "Allow")
$acl.AddAccessRule($accessRule)
Set-Acl -Path $targetPath -AclObject $acl

# Create the destination directory if it doesn't exist
if (-not (Test-Path -Path $Temp)) {
    New-Item -Path $Temp -ItemType Directory
    Write-Host "Target directory created."
}

#extract
# Extract the archive
$extractedFolder = Join-Path -Path $Temp -ChildPath (Get-Date -Format "yyyyMMddHHmmss")
Expand-Archive -Path $zipFilePath -DestinationPath $extractedFolder -Force

# Determine the extracted folder name
$extractedDirectoryName = (Get-ChildItem -Path $extractedFolder -Directory).Name

# Copy curl.exe to the System32 directory
$sourceFilePath = Join-Path -Path $extractedFolder -ChildPath "$extractedDirectoryName\bin\curl.exe"
Copy-Item -Path $sourceFilePath -Destination $targetPath -Force
Write-Host "curl.exe copied to System32 directory"

# Change permissions to read and execute for administrators
$administrators = [System.Security.Principal.NTAccount]"BUILTIN\Administrators"
$ACL = Get-ACL -Path $targetPath
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($administrators,"ReadAndExecute","Allow")
$ACL.SetAccessRule($AccessRule)
$ACL | Set-Acl -Path $targetPath 
(Get-ACL -Path $targetPath).Access | Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -AutoSize


# Take ownership back to TrustedInstaller
$owner = [System.Security.Principal.NTAccount]"NT SERVICE\TrustedInstaller"
$acl = Get-Acl $targetPath
$acl.SetOwner($owner)
Set-Acl -Path $targetPath -AclObject $acl
C:\Windows\System32\curl.exe --version
