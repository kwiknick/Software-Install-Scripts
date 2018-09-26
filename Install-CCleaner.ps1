
function Install-CCleaner {
    param()

    if (-Not (Test-Path "C:\Program Files\CCleaner\ccleaner.exe")) {
        $startTime = Get-Date
        $url = "https://download.ccleaner.com/ccsetup546.exe"
        $tempDir = "C:\Temp"
        $outputFile = "C:\Temp\ccsetup.exe"

        if ( !(Test-Path $tempDir) ) {
            Write-Output "The temp directory doesn't exist. Creating $tempDir"
            New-Item -Path $tempDir -ItemType Directory
        }

        Push-Location $tempDir

        Write-Output "Downloading CCleaner install executable from $url"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $outputFile)

        Pop-Location

        Write-Output "Running the installation executable $outputFile"
        try {
            Start-Process $outputFile -ArgumentList "/S" -wait
        } catch {
            Write-Warning "CCleaner install failed when executing: $outputFile /S"
        }

        if (Test-Path "C:\Program Files\CCleaner\ccleaner.exe") {
            Write-Output "CCleaner Successfully installed!!!  Removing installation executable."
            Remove-Item $outputFile -Force
        }

        Write-Output "Time taken $((Get-Date).Subtract($startTime).Seconds) second(s)"

    } else {
        Write-Output "CCleaner is already installed on this machine. Nothing to do."
    }

}
