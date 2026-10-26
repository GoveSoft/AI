#Requires -Version 7
# Kontroly repozitáře, spouští je CI i vývojář lokálně: pwsh -File scripts/Validate-Repo.ps1
#  1. JSON soubory jsou platné
#  2. relativní odkazy v Markdownu vedou na existující soubor
#  3. agenti, příkazy a skilly mají frontmatter s povinnými poli
#  4. verze pluginu je semver a má záznam v CHANGELOG.md

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$errors = [Collections.Generic.List[string]]::new()
function Rel([string]$p) { [IO.Path]::GetRelativePath($root, $p) -replace '\\', '/' }

# 1) JSON
Get-ChildItem $root -Recurse -File -Filter *.json -Force |
    Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' } |
    ForEach-Object {
        try { Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null }
        catch { $errors.Add("JSON: $(Rel $_.FullName): $($_.Exception.Message)") }
    }

# 2) odkazy v Markdownu (mimo bloky kódu)
Get-ChildItem $root -Recurse -File -Filter *.md -Force |
    Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' } |
    ForEach-Object {
        $file = $_
        $text = Get-Content $file.FullName -Raw -Encoding UTF8
        $text = [regex]::Replace($text, '(?s)```.*?```', '')
        $text = [regex]::Replace($text, '`[^`\n]*`', '')
        foreach ($m in [regex]::Matches($text, '\]\(([^)\s]+)\)')) {
            $target = $m.Groups[1].Value
            if ($target -match '^(https?:|mailto:|#)') { continue }
            $target = ($target -split '#')[0]
            if (-not $target) { continue }
            $full = Join-Path $file.DirectoryName ([Uri]::UnescapeDataString($target))
            if (-not (Test-Path $full)) { $errors.Add("Odkaz: $(Rel $file.FullName) -> $target") }
        }
    }

# 3) frontmatter
function Get-Frontmatter([string]$path) {
    $lines = Get-Content $path -Encoding UTF8
    if ($lines.Count -lt 3 -or $lines[0] -ne '---') { return $null }
    $end = [Array]::IndexOf($lines, '---', 1)
    if ($end -lt 0) { return $null }
    $fm = @{}
    foreach ($l in $lines[1..($end - 1)]) {
        if ($l -match '^([\w-]+):\s*(.*)$') { $fm[$Matches[1]] = $Matches[2] }
    }
    return $fm
}
$required = @{
    'plugin/agents'   = @('name', 'description', 'tools')
    'plugin/commands' = @('description')
    'plugin/skills'   = @('name', 'description')
}
foreach ($dir in $required.Keys) {
    $filter = if ($dir -eq 'plugin/skills') { 'SKILL.md' } else { '*.md' }
    Get-ChildItem (Join-Path $root $dir) -Recurse -File -Filter $filter | ForEach-Object {
        $fm = Get-Frontmatter $_.FullName
        if (-not $fm) { $errors.Add("Frontmatter chybí: $(Rel $_.FullName)"); return }
        foreach ($k in $required[$dir]) {
            if (-not $fm[$k]) { $errors.Add("Frontmatter: $(Rel $_.FullName) nemá '$k'") }
        }
        if ($dir -eq 'plugin/agents' -and $fm['name'] -ne $_.BaseName) {
            $errors.Add("Agent: $(Rel $_.FullName) má name '$($fm['name'])', čeká se '$($_.BaseName)'")
        }
    }
}

# 4) verze pluginu
$plugin = Get-Content (Join-Path $root 'plugin/.claude-plugin/plugin.json') -Raw | ConvertFrom-Json
if ($plugin.version -notmatch '^\d+\.\d+\.\d+$') { $errors.Add("plugin.json: verze '$($plugin.version)' není semver") }
$changelog = Get-Content (Join-Path $root 'CHANGELOG.md') -Raw -Encoding UTF8
if ($changelog -notmatch "## \[$([regex]::Escape($plugin.version))\]") {
    $errors.Add("CHANGELOG.md nemá sekci pro verzi $($plugin.version)")
}

if ($errors.Count) {
    $errors | ForEach-Object { Write-Host "✗ $_" }
    Write-Host "$($errors.Count) chyb."
    exit 1
}
Write-Host '✓ Repozitář je v pořádku.'
