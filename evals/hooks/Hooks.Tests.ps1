#Requires -Version 7
# Pester 5+ testy ochranných hooků. Spuštění: Invoke-Pester ./evals/hooks
# Každý test spustí hook jako samostatný proces se vstupem na stdin, stejně jako Claude Code.
# Konfigurace se bere z templates/ (uživatelská + projektová), HOME a CLAUDE_PROJECT_DIR jsou dočasné.

BeforeDiscovery {
    # -ForEach rozbalí do proměnných ($name, $expect, …) jen [hashtable], ne objekty z ConvertFrom-Json.
    function Read-Cases([string]$file) {
        $items = Get-Content (Join-Path $PSScriptRoot $file) -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($c in $items) {
            $h = [hashtable]@{ background = $false; reason = $null }
            foreach ($p in $c.PSObject.Properties) { $h[$p.Name] = $p.Value }
            $h
        }
    }
    $bashCases  = @(Read-Cases 'guard-bash.cases.json')
    $writeCases = @(Read-Cases 'guard-write.cases.json')
}

BeforeAll {
    $repo  = Resolve-Path (Join-Path $PSScriptRoot '../..')
    $hooks = Join-Path $repo 'plugin/hooks'

    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("hooks-" + [guid]::NewGuid())
    $fakeHome = Join-Path $tmp 'home'
    $project  = Join-Path $tmp 'project'
    New-Item -ItemType Directory -Force (Join-Path $fakeHome '.claude/hooks'), (Join-Path $project '.claude') | Out-Null
    Copy-Item (Join-Path $repo 'templates/hooks-config.user.example.json')    (Join-Path $fakeHome '.claude/hooks/hooks-config.json')
    Copy-Item (Join-Path $repo 'templates/hooks-config.project.example.json') (Join-Path $project '.claude/hooks-config.json')

    function Invoke-Hook([string]$script, [hashtable]$toolInput) {
        $json = @{ tool_input = $toolInput } | ConvertTo-Json -Compress
        $psi = [Diagnostics.ProcessStartInfo]::new((Get-Process -Id $PID).Path)
        foreach ($a in '-NoProfile', '-NonInteractive', '-File', (Join-Path $hooks $script)) { $psi.ArgumentList.Add($a) }
        $psi.RedirectStandardInput = $true
        $psi.RedirectStandardOutput = $true
        $psi.UseShellExecute = $false
        $psi.Environment['HOME'] = $fakeHome
        $psi.Environment['USERPROFILE'] = $fakeHome
        $psi.Environment['CLAUDE_PROJECT_DIR'] = $project
        $p = [Diagnostics.Process]::Start($psi)
        $p.StandardInput.Write($json); $p.StandardInput.Close()
        $out = $p.StandardOutput.ReadToEnd(); $p.WaitForExit()
        $p.ExitCode | Should -Be 0
        if ([string]::IsNullOrWhiteSpace($out)) { return $null }
        return ($out | ConvertFrom-Json).hookSpecificOutput
    }
}

AfterAll { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }

Describe 'guard-bash' {
    It '<name>' -ForEach $bashCases {
        $ti = @{ command = $command }
        if ($background) { $ti.run_in_background = $true }
        $r = Invoke-Hook 'guard-bash.ps1' $ti
        if ($expect -eq 'allow') { $r | Should -BeNullOrEmpty }
        else {
            $r.permissionDecision | Should -Be 'deny'
            if ($reason) { $r.permissionDecisionReason | Should -Match ([regex]::Escape($reason)) }
        }
    }
}

Describe 'guard-write' {
    It '<name>' -ForEach $writeCases {
        $r = Invoke-Hook 'guard-write.ps1' @{ file_path = $path }
        if ($expect -eq 'allow') { $r | Should -BeNullOrEmpty }
        else {
            $r.permissionDecision | Should -Be 'deny'
            if ($reason) { $r.permissionDecisionReason | Should -Match ([regex]::Escape($reason)) }
        }
    }
}
