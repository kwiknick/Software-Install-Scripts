$siteName = 'ChocolateyServer'
$appPoolName = 'ChocolateyServerAppPool'
$sitePath = 'c:\tools\chocolatey.server'
$timeSpan = New-TimeSpan -Days 0 -Hours 0 -Minutes 0 -Seconds 0
$header = "[Install-ChocolateyServer]"

function Add-Acl {
    [CmdletBinding()]
    Param (
        [string]$Path,
        [System.Security.AccessControl.FileSystemAccessRule]$AceObject
    )

    Write-Verbose "$header Retrieving existing ACL from $Path"
    $objACL = Get-ACL -Path $Path
    $objACL.AddAccessRule($AceObject)
    Write-Verbose "$header Setting ACL on $Path"
    Set-ACL -Path $Path -AclObject $objACL
}

function New-AclObject {
    [CmdletBinding()]
    Param (
        [string]$SamAccountName,
        [System.Security.AccessControl.FileSystemRights]$Permission,
        [System.Security.AccessControl.AccessControlType]$AccessControl = 'Allow',
        [System.Security.AccessControl.InheritanceFlags]$Inheritance = 'None',
        [System.Security.AccessControl.PropagationFlags]$Propagation = 'None'
    )

    Write-Verbose "$header Creating a new ACL Object for $SamAccountName with Permission: $Permission"
    New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule($SamAccountName, $Permission, $Inheritance, $Propagation, $AccessControl)
    Write-Verbose "$header Finished creating ACL Object for $SamAccountName"
}

Write-Output "$header Checking if Chocolatey is installed."
if ($null -eq (Get-Command -Name 'choco.exe' -ErrorAction SilentlyContinue)) {
    Write-Warning "$header Chocolatey not installed. Cannot install standard packages. Exiting..."
    Exit 1
}
Write-Output "$header Chocolatey is installed, continuing chocolatey server installation."

Write-Output "$header Installing Chocolatey.Server prerequisites, IIS-WebServer and IIS-ASPNET45"
choco install IIS-WebServer --source windowsfeatures | Out-Null     # --no-progress doesn't seem to be working so I temporarily added Out-Null
choco install IIS-ASPNET45 --source windowsfeatures | Out-Null      # --no-progress doesn't seem to be working so I temporarily added Out-Null

Write-Output "$header Installing Chocolatey.Server"
choco upgrade chocolatey.server -y

# Step by step instructions here https://chocolatey.org/docs/how-to-set-up-chocolatey-server#setup-normally
Write-Output "$header Importing the WebAdministration module."
Import-Module WebAdministration -ErrorAction Stop
# Disable or remove the Default website
Get-Website -Name 'Default Web Site' | Stop-Website
Set-ItemProperty "IIS:\Sites\Default Web Site" serverAutoStart False    # disables website

Write-Output "$header Setting up AppPool $appPoolName for the Chocolatey Server to use."
if(Test-Path "IIS:\AppPools\$appPoolName") {
    Write-Warning "$header AppPool $appPoolName already exists. Skipping creation."
}
else {
    New-WebAppPool -Name $appPoolName -Force
}

Set-ItemProperty "IIS:\AppPools\$appPoolName" enable32BitAppOnWin64 True       # Ensure 32-bit is enabled
Set-ItemProperty "IIS:\AppPools\$appPoolName" managedRuntimeVersion v4.0       # managed runtime version is v4.0
Set-ItemProperty "IIS:\AppPools\$appPoolName" managedPipelineMode Integrated   # Ensure it is "Integrated" and not "Classic"
Set-ItemProperty "IIS:\AppPools\$appPoolName" startMode AlwaysRunning
Set-ItemProperty "IIS:\AppPools\$appPoolName" recycling.periodicRestart.time $timeSpan
Set-ItemProperty "IIS:\AppPools\$appPoolName" processModel.idleTimeout $timeSpan
Restart-WebAppPool -Name $appPoolName   # likely not needed ... but just in case

Write-Output "$header Setting up Chocolatey Server to be served up by IIS and configured to use the newly created AppPool."
if (Get-Website -Name $siteName) {
    Write-Warning "$header Website $siteName already exists. Skipping creation."
}
else {
    New-Website -Name $siteName -ApplicationPool $appPoolName -PhysicalPath $sitePath
}
Set-ItemProperty "IIS:\Sites\$siteName" applicationDefaults.preloadEnabled True

Write-Verbose "$header Adding permissions to $sitePath"
'IIS_IUSRS', 'IUSR', "IIS APPPOOL\$appPoolName" | ForEach-Object {
    $obj = New-AclObject -SamAccountName $_ -Permission 'ReadAndExecute' -Inheritance 'ContainerInherit','ObjectInherit'
    Add-Acl -Path $sitePath -AceObject $obj
}

Write-Verbose "$header Adding permissions to the App_Data subfolder: $appdataPath"
$appdataPath = Join-Path -Path $sitePath -ChildPath 'App_Data'
'IIS_IUSRS', "IIS APPPOOL\$appPoolName" | ForEach-Object {
    $obj = New-AclObject -SamAccountName $_ -Permission 'Modify' -Inheritance 'ContainerInherit', 'ObjectInherit'
    Add-Acl -Path $appdataPath -AceObject $obj
}