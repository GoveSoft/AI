#Requires -Version 7
BeforeAll {
    $script:TestHooksRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../plugin/hooks'))
    . (Join-Path $PSScriptRoot 'support/Invoke-TestHook.ps1')
}

Describe 'Bezpecny uklid procesu' {
    BeforeEach {
        $fixture = New-HookFixture (Join-Path $TestDrive ([guid]::NewGuid().ToString('N')))
        $wrapper = Join-Path $fixture.Root 'cleanup-fixture.ps1'
        Copy-Item (Join-Path $PSScriptRoot 'support/Cleanup-Fixture.ps1') $wrapper
        $procData = @([pscustomobject]@{
            ProcessId = 910001; ParentProcessId = 919999; Name = 'TestApp.exe'
            ExecutablePath = Join-Path $fixture.Project 'bin/TestApp.exe'
            CommandLine = 'test-app'; CreationDate = (Get-Date).AddMinutes(-60)
        })
        $cfgPath = Join-Path $fixture.Project '.claude/hooks-config.json'
    }

    It 'bez explicitniho boolean false nic neukonci: <config>' -ForEach @(
        @{ config = $null }, @{ config = '{}' }, @{ config = '{"cleanup":{"dryRun":true}}' },
        @{ config = '{"cleanup":{"dryRun":"false"}}' }, @{ config = '{"cleanup":{"dryRun":0}}' }
    ) {
        if ($null -ne $config) { $config | Set-Content $cfgPath }
        ConvertTo-Json -InputObject $procData | Set-Content (Join-Path $fixture.Root 'processes.json')
        $result = Invoke-TestHook 'cleanup.ps1' $fixture -EntryPoint $wrapper
        $result.ExitCode | Should -Be 0
        Join-Path $fixture.Root 'stops.log' | Should -Not -Exist
        Get-Content (Join-Path $fixture.Project '.scratch/cleanup.log') -Raw | Should -Match 'DRY-RUN would kill'
    }

    It 'bez konkretniho projektu ani necte procesy: <rootKind>' -ForEach @(
        @{ rootKind = 'missing' }, @{ rootKind = 'invalid' }, @{ rootKind = 'drive' }, @{ rootKind = 'file' }
    ) {
        ConvertTo-Json -InputObject $procData | Set-Content (Join-Path $fixture.Root 'processes.json')
        $projectPath = switch ($rootKind) {
            missing { '' }
            invalid { Join-Path $fixture.Root 'does-not-exist' }
            drive { [IO.Path]::GetPathRoot($fixture.Root) }
            file { Join-Path $fixture.Root 'processes.json' }
        }
        $result = Invoke-TestHook 'cleanup.ps1' $fixture -EntryPoint $wrapper -ProjectDirectory $projectPath
        $result.ExitCode | Should -Be 0
        Join-Path $fixture.Root 'queries.log' | Should -Not -Exist
        Join-Path $fixture.Root 'stops.log' | Should -Not -Exist
    }

    It 'pri vadnem JSONu neprovede uklid ani s ostrym uzivatelskym nastavenim' {
        '{"cleanup":{"dryRun":false}}' | Set-Content (Join-Path $fixture.HomeDirectory '.claude/hooks/hooks-config.json')
        '{' | Set-Content $cfgPath
        ConvertTo-Json -InputObject $procData | Set-Content (Join-Path $fixture.Root 'processes.json')
        $result = Invoke-TestHook 'cleanup.ps1' $fixture -EntryPoint $wrapper
        $result.ExitCode | Should -Be 0
        Join-Path $fixture.Root 'queries.log' | Should -Not -Exist
        Join-Path $fixture.Root 'stops.log' | Should -Not -Exist
    }

    It 'ukonci jen kandidata v povolenem rozsahu: <scenario>' -ForEach @(
        @{ scenario = 'old-project-app'; expectedStop = $true },
        @{ scenario = 'young-project-app'; expectedStop = $false },
        @{ scenario = 'sibling-app'; expectedStop = $false },
        @{ scenario = 'ide-child'; expectedStop = $false },
        @{ scenario = 'unrelated-scanner'; expectedStop = $false },
        @{ scenario = 'sibling-scanner'; expectedStop = $false },
        @{ scenario = 'project-orphan-scanner'; expectedStop = $true },
        @{ scenario = 'project-live-scanner'; expectedStop = $false },
        @{ scenario = 'project-runtime'; expectedStop = $true },
        @{ scenario = 'sibling-runtime'; expectedStop = $false },
        @{ scenario = 'project-local-scanner'; expectedStop = $true }
    ) {
        '{"cleanup":{"dryRun":false}}' | Set-Content $cfgPath
        switch ($scenario) {
            young-project-app { $procData[0].CreationDate = Get-Date }
            sibling-app { $procData[0].ExecutablePath = "$($fixture.Project)-other/bin/TestApp.exe" }
            ide-child {
                $procData[0].ParentProcessId = 910002
                $procData += [pscustomobject]@{ ProcessId = 910002; ParentProcessId = 919999; Name = 'Code.exe'; ExecutablePath = 'C:/tools/Code.exe'; CommandLine = ''; CreationDate = (Get-Date).AddMinutes(-60) }
            }
        }
        if ($scenario -match 'scanner$') {
            $procData[0].Name = 'grep.exe'
            $procData[0].ExecutablePath = 'C:/tools/grep.exe'
            $target = switch ($scenario) {
                unrelated-scanner { 'C:/unrelated' }
                sibling-scanner { "$($fixture.Project)-other" }
                default { $fixture.Project }
            }
            $procData[0].CommandLine = 'grep needle "' + $target + '"'
            if ($scenario -eq 'project-local-scanner') { $procData[0].ExecutablePath = Join-Path $fixture.Project 'tools/grep.exe' }
            if ($scenario -eq 'project-live-scanner') {
                $procData[0].ParentProcessId = 910002
                $procData += [pscustomobject]@{ ProcessId = 910002; ParentProcessId = 919999; Name = 'cmd.exe'; ExecutablePath = 'C:/Windows/cmd.exe'; CommandLine = ''; CreationDate = (Get-Date).AddMinutes(-60) }
            }
        }
        if ($scenario -match 'runtime$') {
            $procData[0].Name = 'dotnet.exe'
            $procData[0].ExecutablePath = 'C:/tools/dotnet.exe'
            $runtimeProject = if ($scenario -eq 'project-runtime') { $fixture.Project } else { "$($fixture.Project)-other" }
            $procData[0].CommandLine = 'dotnet exec "' + $runtimeProject + '/bin/TestApp.dll"'
        }
        ConvertTo-Json -InputObject $procData | Set-Content (Join-Path $fixture.Root 'processes.json')
        $result = Invoke-TestHook 'cleanup.ps1' $fixture -EntryPoint $wrapper
        $result.ExitCode | Should -Be 0
        if ($expectedStop) {
            @(Get-Content (Join-Path $fixture.Root 'stops.log')) | Should -Be @('910001')
        } else {
            Join-Path $fixture.Root 'stops.log' | Should -Not -Exist
        }
    }
}
