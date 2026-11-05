# Izolovane podprocesy: hooky nesmi cist skutecnou konfiguraci vyvojare.
function New-HookFixture([string]$Root) {
    $fixture = [pscustomobject]@{
        Root = $Root
        HomeDirectory = Join-Path $Root 'home'
        Project = Join-Path $Root 'project'
    }
    New-Item -ItemType Directory -Force (Join-Path $fixture.HomeDirectory '.claude/hooks'), (Join-Path $fixture.Project '.claude') | Out-Null
    return $fixture
}

function Invoke-TestHook {
    param(
        [string]$Script,
        $Fixture,
        [string]$InputJson = '{}',
        [string]$EntryPoint,
        [string]$ProjectDirectory
    )
    if (-not $EntryPoint) { $EntryPoint = Join-Path $script:TestHooksRoot $Script }
    if (-not $PSBoundParameters.ContainsKey('ProjectDirectory')) { $ProjectDirectory = $Fixture.Project }
    $psi = [Diagnostics.ProcessStartInfo]::new((Get-Process -Id $PID).Path)
    foreach ($arg in '-NoProfile', '-NonInteractive', '-File', $EntryPoint) { $psi.ArgumentList.Add($arg) }
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.Environment['HOME'] = $Fixture.HomeDirectory
    $psi.Environment['USERPROFILE'] = $Fixture.HomeDirectory
    $psi.Environment['CLAUDE_PROJECT_DIR'] = $ProjectDirectory
    $psi.Environment['TEST_HOOK_PATH'] = Join-Path $script:TestHooksRoot $Script
    $proc = [Diagnostics.Process]::Start($psi)
    try {
        $proc.StandardInput.Write($InputJson)
        $proc.StandardInput.Close()
        $stdout = $proc.StandardOutput.ReadToEndAsync()
        $stderr = $proc.StandardError.ReadToEndAsync()
        if (-not $proc.WaitForExit(15000)) {
            $proc.Kill($true)
            throw "Hook $Script prekrocil 15 sekund."
        }
        return [pscustomobject]@{ ExitCode = $proc.ExitCode; Out = $stdout.GetAwaiter().GetResult(); Error = $stderr.GetAwaiter().GetResult() }
    } finally {
        $proc.Dispose()
    }
}
