# build-on-stop.ps1 — SubagentStop hook (registrovany s matcherem na vyvojare)
# Umisteni: ~/.claude/hooks/build-on-stop.ps1
#
# Po skonceni agenta spusti build projektu podle "buildOnStop" (pole: program + argumenty)
# v <projekt>/.claude/hooks-config.json. Projekt bez teto polozky se nebuildi.
# Build selze -> exit 2 a chyby na stderr: agent nesmi skoncit a dostane je k oprave.
# Druhe zastaveni (stop_hook_active) uz neblokuje.
# Jeden vynuceny pokus; dalsi overeni zajistuje tester.
# Existujici, ale vadna konfigurace blokuje dokonceni stejne jako neuspesny build.

$ErrorActionPreference = 'Stop'

function Block([string]$message) {
    [Console]::Error.WriteLine($message)
    exit 2
}

try {
    $in = [Console]::In.ReadToEnd() | ConvertFrom-Json -NoEnumerate
    if ($null -eq $in -or $in.GetType() -ne [System.Management.Automation.PSCustomObject]) { throw 'Vstup musi byt JSON objekt.' }
} catch {
    Block 'Neplatny vstup build hooku. Oprav vstup a znovu over build.'
}

if ($in.stop_hook_active) { exit 0 }

$root = $env:CLAUDE_PROJECT_DIR
if (-not $root) { exit 0 }

$cfgPath = Join-Path $root '.claude/hooks-config.json'
if (-not (Test-Path $cfgPath)) { exit 0 }
try {
    $cfg = Get-Content -LiteralPath $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json -NoEnumerate
    if ($null -eq $cfg -or $cfg.GetType() -ne [System.Management.Automation.PSCustomObject]) { throw 'Konfigurace musi byt JSON objekt.' }
} catch { Block "Neplatna konfigurace build hooku: $cfgPath. Oprav JSON pred dokoncenim ulohy." }
if ($cfg.PSObject.Properties.Name -notcontains 'buildOnStop') { exit 0 }

$cmd = $cfg.buildOnStop
if ($cmd -isnot [array] -or $cmd.Count -eq 0) {
    Block 'buildOnStop musi byt neprazdne pole retezcu: program a jeho argumenty.'
}
foreach ($part in $cmd) {
    if ($part -isnot [string]) { Block 'buildOnStop smi obsahovat jen retezce.' }
}
if ([string]::IsNullOrWhiteSpace($cmd[0])) { Block 'buildOnStop nema vyplneny program.' }
$exe = $cmd[0]
$cmdArgs = @($cmd | Select-Object -Skip 1)

$log = Join-Path $root '.scratch/build-on-stop.log'
try {
    New-Item -ItemType Directory -Force (Split-Path $log) | Out-Null
    Push-Location -LiteralPath $root
    try {
        # Relativni program se vyhledava v projektu. U funkce nebo cmdletu
        # by LASTEXITCODE neprokazoval uspech.
        $program = Get-Command -Name $exe -CommandType Application -ErrorAction Stop | Select-Object -First 1
        & $program.Source @cmdArgs *> $log
        $code = $LASTEXITCODE
    } finally {
        Pop-Location
    }
} catch {
    Block "Build nelze spustit: $($_.Exception.Message) (konfigurace $cfgPath, log $log)."
}

if ($code -eq 0) { exit 0 }

$errors = @(Select-String -LiteralPath $log -Pattern ': error ' |
    ForEach-Object { $_.Line.Trim() } |
    Select-Object -Unique -First 30)
# Vlastni skripty i jine nastroje nemusi pouzivat format MSBuild ': error '.
if ($errors.Count -eq 0) { $errors = @(Get-Content -LiteralPath $log -Tail 30) }

[Console]::Error.WriteLine("Build po tve praci selhal (exit $code, log $log). Oprav chyby a pak teprve odevzdej hlaseni:")
foreach ($e in $errors) { [Console]::Error.WriteLine($e) }
exit 2
