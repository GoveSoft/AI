# guard-write.ps1 — PreToolUse hook pro Write/Edit/NotebookEdit
# Umisteni: ~/.claude/hooks/guard-write.ps1
#
# Zamitne zapis do chranenych cest. Pravidla jsou v "protectedPaths"
# (pattern = regex nad cestou s '/', message = duvod a spravna nahrada)
# v ~/.claude/hooks/hooks-config.json a <projekt>/.claude/hooks-config.json.
# Exit kod je vzdy 0 — zamitnuti se predava JSONem.

$ErrorActionPreference = 'Stop'

function Deny([string]$msg) {
    @{
        hookSpecificOutput = @{
            hookEventName = 'PreToolUse'
            permissionDecision = 'deny'
            permissionDecisionReason = $msg
        }
    } | ConvertTo-Json -Depth 5 -Compress
    exit 0
}

try {
    $in = [Console]::In.ReadToEnd() | ConvertFrom-Json -NoEnumerate
    if ($null -eq $in -or $in.GetType() -ne [System.Management.Automation.PSCustomObject]) { throw 'Vstup musi byt JSON objekt.' }
} catch {
    Deny 'Neplatny JSON vstup hooku. Zapis nebyl povolen.'
}

$path = $in.tool_input.file_path
if (-not $path) { $path = $in.tool_input.notebook_path }
if ([string]::IsNullOrWhiteSpace($path)) { Deny 'Chybi cesta souboru. Zapis nebyl povolen.' }
try {
    $base = if ($in.cwd) { $in.cwd } elseif ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
    $path = [IO.Path]::GetFullPath($path, $base) -replace '\\', '/'
} catch {
    Deny 'Cestu souboru nelze vyhodnotit. Zapis nebyl povolen.'
}

$configs = @(Join-Path $HOME '.claude/hooks/hooks-config.json')
if ($env:CLAUDE_PROJECT_DIR) { $configs += Join-Path $env:CLAUDE_PROJECT_DIR '.claude/hooks-config.json' }

foreach ($c in $configs) {
    if (-not (Test-Path $c)) { continue }
    try {
        $cfg = Get-Content -LiteralPath $c -Raw -Encoding UTF8 | ConvertFrom-Json -NoEnumerate
        if ($null -eq $cfg -or $cfg.GetType() -ne [System.Management.Automation.PSCustomObject]) { throw 'Konfigurace musi byt JSON objekt.' }
    } catch { Deny "Neplatna konfigurace hooku: $c. Oprav ji pred dalsim zapisem." }
    if ($cfg.PSObject.Properties.Name -notcontains 'protectedPaths') { continue }

    foreach ($r in @($cfg.protectedPaths)) {
        try { $matchesPath = $r.pattern -and ($path -match $r.pattern) }
        catch { Deny "Neplatny regularni vyraz v konfiguraci: $c." }
        if ($matchesPath) {
            $msg = if ($r.message) { $r.message } else { "Chranena cesta ($($r.pattern))." }
            @{
                hookSpecificOutput = @{
                    hookEventName            = 'PreToolUse'
                    permissionDecision       = 'deny'
                    permissionDecisionReason = $msg
                }
            } | ConvertTo-Json -Depth 5 -Compress
            exit 0
        }
    }
}

exit 0
