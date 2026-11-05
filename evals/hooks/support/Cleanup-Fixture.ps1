# Pouze testovaci data. Zadny dotaz na skutecne procesy ani jejich ukoncovani.
$global:CleanupFixtureProcesses = @(Get-Content (Join-Path $PSScriptRoot 'processes.json') -Raw | ConvertFrom-Json)
foreach ($process in $global:CleanupFixtureProcesses) { $process.CreationDate = [datetime]$process.CreationDate }

function Get-CimInstance {
    param([string]$ClassName, [string]$Filter)
    'query' | Add-Content (Join-Path $PSScriptRoot 'queries.log')
    if ($Filter -match '^ProcessId=(\d+)$') {
        return $global:CleanupFixtureProcesses | Where-Object ProcessId -EQ ([int]$Matches[1])
    }
    return $global:CleanupFixtureProcesses
}

function Stop-Process {
    param([int]$Id, [switch]$Force)
    $Id | Add-Content (Join-Path $PSScriptRoot 'stops.log')
}

& $env:TEST_HOOK_PATH
