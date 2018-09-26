
function Install-LibreOffice {
    param(
        [Parameter()]
        [switch]$Remove
    )

    if (-Not $Remove) {
        if (-Not (Test-Path "C:\Program Files\LibreOffice\")) {
            $startTime = Get-Date
            $url = "https://download.documentfoundation.org/libreoffice/stable/6.1.1/win/x86_64/LibreOffice_6.1.1_Win_x64.msi"
            $tempDir = "C:\Temp"
            $outputFile = "C:\Temp\LibreOffice_6.1.1_Win_x64.msi"

            if ( !(Test-Path $tempDir) ) {
                Write-Output "The temp directory doesn't exist. Creating $tempDir"
                New-Item -Path $tempDir -ItemType Directory
            }

            Push-Location $tempDir

            Write-Output "Downloading LibreOffice install executable from $url"
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($url, $outputFile)

            Pop-Location

            Write-Output "Running the installation executable $outputFile"
            try {
                Start-Process "msiexec.exe" $outputFile -ArgumentList "/qn ADDLOCAL=ALL CREATEDESKTOPLINK=0 REGISTER_ALL_SMO_TYPES=1 REMOVE=gm_o_Onlineupdate RebootYesNo=No" -wait
            } catch {
                throw "LibreOffice install failed when executing: $outputFile"
            }

            if (Test-Path "C:\Program Files\LibreOffice\program\swriter.exe") {
                Write-Output "LibreOffice Successfully installed!!!  Removing installation executable."
                Remove-Item $outputFile -Force
            }

            Write-Output "Time taken $((Get-Date).Subtract($startTime).Seconds) second(s)"

        } else {
            Write-Output "LibreOffice is already installed on this machine. Nothing to do."
        }
    } else {
        Write-Output "Starting to Uninstall LibreOffice..."
        $uninstallString = (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall |
            Get-ItemProperty |
            Where-Object { $_.DisplayName -match "LibreOffice" }).UninstallString
        try {
            Start-Process "$uninstallString /x /qn"
        } catch {
            throw "LibreOffice removal failed when executing: $uninstallString /x /qn"
        }

        Write-Output "Uninstallation of LibreOffice is complete." 
    }

}
