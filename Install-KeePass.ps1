
function Install-KeePass {
    param()

    if (-Not (Test-Path "C:\Program Files (x86)\KeePass Password Safe 2\KeePass.exe")) {
        $startTime = Get-Date
        $url = "https://sourceforge.net/projects/keepass/files/KeePass%202.x/2.40/KeePass-2.40-Setup.exe/download"
        $tempDir = "C:\Temp"
        $outputFile = "C:\Temp\KeePass-2.40-Setup.exe"

        if ( !(Test-Path $tempDir) ) {
            Write-Output "The temp directory doesn't exist. Creating $tempDir"
            New-Item -Path $tempDir -ItemType Directory
        }

        Push-Location $tempDir

        Write-Output "Downloading KeePass install executable from $url"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $outputFile)

        Pop-Location

        Write-Output "Running the installation executable $outputFile"
        try {
            Start-Process $outputFile -ArgumentList "/VERYSILENT" -wait
        } catch {
            Write-Warning "KeePass install failed when executing: $outputFile /VERYSILENT"
        }

        if (Test-Path "C:\Program Files (x86)\KeePass Password Safe 2\KeePass.exe") {
            Write-Output "KeePass Successfully installed!!!  Removing installation executable."
            Remove-Item $outputFile -Force
        }

        Write-Output "Time taken $((Get-Date).Subtract($startTime).Seconds) second(s)"

    } else {
        Write-Output "KeePass is already installed on this machine. Nothing to do."
    }

}
