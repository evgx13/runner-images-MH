function Get-PostgreSQLTable
{
    $pgService = Get-CimInstance Win32_Service -Filter "Name LIKE 'postgresql-%'"
    $pgPath = $pgService.PathName
    $pgRoot = $pgPath.split('"')[1].replace("\bin\pg_ctl.exe", "")
    $env:Path += ";${env:PGBIN}"
    $pgVersion = (postgres --version).split()[2].Trim()

    return @(
        [PSCustomObject]@{ Property = "ServiceName"; Value = $pgService.Name },
        [PSCustomObject]@{ Property = "Version"; Value = $pgVersion },
        [PSCustomObject]@{ Property = "ServiceStatus"; Value = $pgService.State },
        [PSCustomObject]@{ Property = "ServiceStartType"; Value = $pgService.StartMode },
        [PSCustomObject]@{ Property = "EnvironmentVariables"; Value = "`PGBIN=$env:PGBIN` <br> `PGDATA=$env:PGDATA` <br> `PGROOT=$env:PGROOT` " },
        [PSCustomObject]@{ Property = "Path"; Value = $pgRoot },
        [PSCustomObject]@{ Property = "UserName"; Value = $env:PGUSER },
        [PSCustomObject]@{ Property = "Password"; Value = $env:PGPASSWORD }
    )
}

function Get-MongoDBTable {
    $serviceName = "MongoDB"
    $mongoService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

    # Choose command based on Windows version (example logic)
    if (Test-IsWin25) {
        $command = "mongod"
    }
    else {
        $command = "mongosh"
    }

    $version = $null
    $cmdPath = Get-Command -Name $command -ErrorAction SilentlyContinue
    if ($cmdPath) {
        $versionOutput = & $command --version 2>&1
        $pattern = '\d+\.\d+\.\d+'
        $match = ($versionOutput | Select-String -Pattern $pattern -AllMatches |
                  ForEach-Object { $_.Matches } | ForEach-Object { $_.Value })
        if ($match) {
            $version = $match[0]
        }
    }

    return [PSCustomObject]@{
        Version          = $version
        ServiceName      = $serviceName
        ServiceStatus    = if ($mongoService) { $mongoService.Status } else { "NotInstalled" }
        ServiceStartType = if ($mongoService) { $mongoService.StartType } else { "NotInstalled" }
    }
}
