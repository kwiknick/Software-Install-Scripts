# https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&rel=15

function Install-VisualStudio {
    param(
        [Parameter()]
        [switch]$Remove
    )

    $startTime = Get-Date

    if (-Not $Remove) {
        if (-Not (Test-Path "C:\Program Files\VisualStudio\")) {
            $url = "https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&rel=15"
            $tempDir = "C:\Temp"
            $outputFile = "C:\Temp\VisualStudio2017.msi"

            if ( !(Test-Path $tempDir) ) {
                Write-Output "The temp directory doesn't exist. Creating $tempDir"
                New-Item -Path $tempDir -ItemType Directory
            }

            Push-Location $tempDir

            Write-Output "Downloading VisualStudio install executable from $url"
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($url, $outputFile)

            Pop-Location

            Write-Output "Running the installation executable $outputFile"
            try {
                Start-Process "msiexec.exe" -ArgumentList "/I $outputFile /qn ADDLOCAL=ALL CREATEDESKTOPLINK=0 REGISTER_ALL_SMO_TYPES=1 REMOVE=gm_o_Onlineupdate RebootYesNo=No" -wait
            } catch {
                throw "VisualStudio install failed when executing: $outputFile"
            }

            if (Test-Path "C:\Program Files\VisualStudio\program\swriter.exe") {
                Write-Output "VisualStudio Successfully installed!!!  Removing installation executable."
                Remove-Item $outputFile -Force
            }

            Write-Output "Time taken $((Get-Date).Subtract($startTime).Seconds) second(s)"

        } else {
            Write-Output "VisualStudio is already installed on this machine. Nothing to do."
        }
    } else {
        Write-Output "Starting to Uninstall VisualStudio..."
        $visualStudioInstallGuid = (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall |
            Get-ItemProperty |
            Where-Object { $_.DisplayName -match "VisualStudio" }).PSChildName
        try {
            Start-Process "msiexec.exe" -ArgumentList "/x $visualStudioInstallGuid /qn RebootYesNo=No" -Wait
        } catch {
            throw "VisualStudio removal failed when executing: $visualStudioInstallGuid /x /qn RebootYesNo=No"
        }

        Write-Output "Uninstallation of VisualStudio is complete."
        Write-Output "Time taken $((Get-Date).Subtract($startTime).Seconds) second(s)"
    }

}
