function Install-Steam {
    param(
    )
    if (-Not (Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam\")) {
        $startTime = Get-Date
        $url = "https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe"
        $tempDir = "C:\Temp"
        $outputFile = "C:\Temp\SteamSetup.exe"

        if ( !(Test-Path $tempDir) ) {
            Write-Output "The temp directory doesn't exist. Creating $tempDir"
            New-Item -Path $tempDir -ItemType Directory
        }

        Push-Location $tempDir

        Write-Output "Downloading Steam install executable from $url"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $outputFile)

        Pop-Location

        Write-Output "Running the installation executable $outputFile"
        try {
            & $outputFile /S
        } catch {
            Write-Warning "Steam install failed when executing: $outputFile /S"
        }

        if (Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam\") {
            Write-Output "Steam Successfully installed!!!  Removing installation executable."
            Remove-Item $outputFile -Force
        }

        Write-Output "Time taken $((Get-Date).Subtract($startTime).Seconds) second(s)"

    } else {
        Write-Output "Steam is already installed on this machine. Nothing to do."
    }

}

Install-Steam