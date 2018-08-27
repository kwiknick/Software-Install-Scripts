function Install-Git {
    param(
    )
    $gitExePath = "C:\Program Files\Git\bin\git.exe"

    #Added TLS negotiation Fork jmangan68
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

    foreach ($asset in (Invoke-RestMethod https://api.github.com/repos/git-for-windows/git/releases/latest).assets)
    {
        if ($asset.name -match 'Git-\d*\.\d*\.\d*.\d*-64-bit\.exe')
        {
            $dlurl = $asset.browser_download_url
            $newver = $asset.name
        }
    }

    try
    {
        $ProgressPreference = 'SilentlyContinue'

        if (!(Test-Path $gitExePath))
        {
            Write-Host "`nDownloading latest stable git..." -ForegroundColor Yellow
            Remove-Item -Force $env:TEMP\git-stable.exe -ErrorAction SilentlyContinue
            Invoke-WebRequest -Uri $dlurl -OutFile $env:TEMP\git-stable.exe

            Write-Host "`nInstalling git..." -ForegroundColor Yellow
            Start-Process -Wait $env:TEMP\git-stable.exe -ArgumentList /silent
        }
        else
        {
            $updateneeded = $false
            Write-Host "`ngit is already installed. Check if possible update..." -ForegroundColor Yellow
            (git version) -match "(\d*\.\d*\.\d*)" | Out-Null
            $installedversion = $matches[0].split('.')
            $newver -match "(\d*\.\d*\.\d*)" | Out-Null
            $newversion = $matches[0].split('.')

            if (($newversion[0] -gt $installedversion[0]) -or ($newversion[0] -eq $installedversion[0] -and $newversion[1] -gt $installedversion[1]) -or ($newversion[0] -eq $installedversion[0] -and $newversion[1] -eq $installedversion[1] -and $newversion[2] -gt $installedversion[2]))
            {
                $updateneeded = $true
            }

            if ($updateneeded)
            {

                Write-Host "`nUpdate available. Downloading latest stable git..." -ForegroundColor Yellow
                Remove-Item -Force $env:TEMP\git-stable.exe -ErrorAction SilentlyContinue
                Invoke-WebRequest -Uri $dlurl -OutFile $env:TEMP\git-stable.exe

                Write-Host "`nInstalling update..." -ForegroundColor Yellow
                $sshagentrunning = get-process ssh-agent -ErrorAction SilentlyContinue
                if ($sshagentrunning)
                {
                    Write-Host "`nKilling ssh-agent..." -ForegroundColor Yellow
                    Stop-Process $sshagentrunning.Id
                }

                Start-Process -Wait $env:TEMP\git-stable.exe -ArgumentList /silent
            }
            else
            {
                Write-Host "`nNo update available. Already running latest version..." -ForegroundColor Yellow
            }

        }
        Write-Host "`nInstallation complete!`n`n" -ForegroundColor Green
    }
    finally
    {
        $ProgressPreference = 'Continue'
    }

}

Install-Git