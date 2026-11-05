#Requires -Version 7
BeforeAll {
    $script:TestHooksRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../plugin/hooks'))
    . (Join-Path $PSScriptRoot 'support/Invoke-TestHook.ps1')
}

Describe 'Ochrany pri vadnem vstupu a konfiguraci' {
    BeforeEach {
        $fixture = New-HookFixture (Join-Path $TestDrive ([guid]::NewGuid().ToString('N')))
    }

    It '<hook> zamitne neplatny vstup <inputJson>' -ForEach @(
        @{ hook = 'guard-bash.ps1'; inputJson = '{' },
        @{ hook = 'guard-bash.ps1'; inputJson = '{}' },
        @{ hook = 'guard-write.ps1'; inputJson = '{' },
        @{ hook = 'guard-write.ps1'; inputJson = '{}' },
        @{ hook = 'guard-bash.ps1'; inputJson = '[{"tool_input":{"command":"git status"}}]' },
        @{ hook = 'guard-write.ps1'; inputJson = '[{"tool_input":{"file_path":"Order.cs"}}]' }
    ) {
        $result = Invoke-TestHook $hook $fixture -InputJson $inputJson
        $result.ExitCode | Should -Be 0
        ($result.Out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It '<hook> nepreskoci vadnou <scope> konfiguraci <config>' -ForEach @(
        foreach ($hook in 'guard-bash.ps1', 'guard-write.ps1') {
            foreach ($scope in 'user', 'project') {
                foreach ($config in '{', 'null', '[]', '[{}]', '42') { @{ hook = $hook; scope = $scope; config = $config } }
            }
        }
    ) {
        $cfgPath = if ($scope -eq 'user') { Join-Path $fixture.HomeDirectory '.claude/hooks/hooks-config.json' } else { Join-Path $fixture.Project '.claude/hooks-config.json' }
        $config | Set-Content -LiteralPath $cfgPath
        $result = Invoke-TestHook $hook $fixture -InputJson '{"tool_input":{"command":"git status","file_path":"Order.cs"}}'
        $result.ExitCode | Should -Be 0
        ($result.Out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It '<hook> zamitne vadny regex' -ForEach @(
        @{ hook = 'guard-bash.ps1'; config = '{"allowPatterns":["["]}' },
        @{ hook = 'guard-bash.ps1'; config = '{"allowPatterns":[".*"],"denyCommands":[{"pattern":"["}]}' },
        @{ hook = 'guard-write.ps1'; config = '{"protectedPaths":[{"pattern":"["}]}' }
    ) {
        $config | Set-Content (Join-Path $fixture.Project '.claude/hooks-config.json')
        $result = Invoke-TestHook $hook $fixture -InputJson '{"tool_input":{"command":"git status","file_path":"Order.cs"}}'
        $result.ExitCode | Should -Be 0
        ($result.Out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'normalizuje relativni cestu vuci cwd hooku' {
        '{"protectedPaths":[{"pattern":"/Migrations/"}]}' | Set-Content (Join-Path $fixture.Project '.claude/hooks-config.json')
        $payload = @{ cwd = Join-Path $fixture.Project 'Migrations'; tool_input = @{ file_path = '001.cs' } } | ConvertTo-Json
        $result = Invoke-TestHook 'guard-write.ps1' $fixture -InputJson $payload
        ($result.Out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }
}

Describe 'Build hook' {
    BeforeEach {
        $fixture = New-HookFixture (Join-Path $TestDrive ([guid]::NewGuid().ToString('N')))
        $cfgPath = Join-Path $fixture.Project '.claude/hooks-config.json'
    }

    It 'preskoci projekt bez konfigurace' {
        (Invoke-TestHook 'build-on-stop.ps1' $fixture).ExitCode | Should -Be 0
    }

    It 'preskoci projekt bez buildOnStop' {
        '{}' | Set-Content $cfgPath
        (Invoke-TestHook 'build-on-stop.ps1' $fixture).ExitCode | Should -Be 0
    }

    It 'zablokuje vadnou konfiguraci <config>' -ForEach @(
        @{ config = '{' }, @{ config = 'null' }, @{ config = '[]' }, @{ config = '[{}]' }, @{ config = '42' },
        @{ config = '{"buildOnStop":[]}' }, @{ config = '{"buildOnStop":null}' },
        @{ config = '{"buildOnStop":"dotnet build"}' }, @{ config = '{"buildOnStop":[""]}' },
        @{ config = '{"buildOnStop":["dotnet",42]}' }
    ) {
        $config | Set-Content $cfgPath
        $result = Invoke-TestHook 'build-on-stop.ps1' $fixture
        $result.ExitCode | Should -Be 2
        $result.Error | Should -Not -BeNullOrEmpty
    }

    It 'zablokuje neplatny vstup' {
        (Invoke-TestHook 'build-on-stop.ps1' $fixture -InputJson '{').ExitCode | Should -Be 2
    }

    It 'zablokuje chybejici program s vysvetlenim' {
        '{"buildOnStop":["govesoft-nonexistent-build-872364"]}' | Set-Content $cfgPath
        $result = Invoke-TestHook 'build-on-stop.ps1' $fixture
        $result.ExitCode | Should -Be 2
        $result.Error | Should -Match 'Build nelze spustit'
    }

    It 'preda argumenty a rozlisi uspesny a neuspesny build <buildExit>' -ForEach @(
        @{ buildExit = 0; hookExit = 0 }, @{ buildExit = 7; hookExit = 2 }
    ) {
        $builder = Join-Path $fixture.Project 'build with spaces.ps1'
        'param([string]$Value, [int]$BuildExit); Write-Output "argument=$Value"; exit $BuildExit' | Set-Content $builder
        @{ buildOnStop = @((Get-Process -Id $PID).Path, '-NoProfile', '-File', $builder, '-Value', 'two words', '-BuildExit', "$buildExit") } |
            ConvertTo-Json | Set-Content $cfgPath
        $result = Invoke-TestHook 'build-on-stop.ps1' $fixture
        $result.ExitCode | Should -Be $hookExit
        Get-Content (Join-Path $fixture.Project '.scratch/build-on-stop.log') -Raw | Should -Match 'argument=two words'
        if ($buildExit) { $result.Error | Should -Match 'argument=two words' }
    }

    It 'neopakuje build pri aktivnim stop hooku' {
        '{"buildOnStop":["govesoft-nonexistent-build-872364"]}' | Set-Content $cfgPath
        (Invoke-TestHook 'build-on-stop.ps1' $fixture -InputJson '{"stop_hook_active":true}').ExitCode | Should -Be 0
    }
}
