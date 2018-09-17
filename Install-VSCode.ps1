function Install-VSCode {
    param(
    )
    if (-Not (Test-Path "C:\Program Files\Microsoft VS Code\Code.exe")) {
        $startTime = Get-Date
        $url = "https://go.microsoft.com/fwlink/?Linkid=852157"
        $tempDir = "C:\Temp"
        $outputFile = "C:\Temp\VSCode.exe"

        if ( !(Test-Path $tempDir) ) {
            Write-Output "The temp directory doesn't exist. Creating $tempDir"
            New-Item -Path $tempDir -ItemType Directory
        }

        Push-Location $tempDir

        Write-Output "Downloading VSCode install executable from $url"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $outputFile)

        Pop-Location

        Write-Output "Running the installation executable $outputFile"
        try {
            Start-Process $outputFile -ArgumentList "/verysilent /norestart /MERGETASKS=!runcode" -wait
        } catch {
            Write-Warning "VSCode install failed when executing: $outputFile /VERYSILENT /MERGETASKS=!runcode"
        }

        if (Test-Path "C:\Program Files\Microsoft VS Code\Code.exe") {
            Write-Output "VSCode Successfully installed!!!  Removing installation executable."
            Remove-Item $outputFile -Force

            #Write-Verbose "Adding VSCode to the System level Path Environment Variable."
            #$oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
            #$newPath = "$oldPath;C:\Program Files\Microsoft VS Code\;"
            #Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
        }

        Write-Output "Time taken $((Get-Date).Subtract($startTime).Seconds) second(s)"

    } else {
        Write-Output "VSCode is already installed on this machine. Nothing to do."
    }

}
