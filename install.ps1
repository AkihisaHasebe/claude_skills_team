# Install the /team skill set into ~/.claude.
# Existing files are backed up to ~/.claude/backups/team-<timestamp>/ before being overwritten.
#   powershell -ExecutionPolicy Bypass -File .\install.ps1
# (ASCII only: Windows PowerShell 5.1 misreads UTF-8 files without BOM.)
$ErrorActionPreference = "Stop"
$src = $PSScriptRoot
$dst = Join-Path $HOME ".claude"
$files = @("skills\team\SKILL.md", "agents\team-worker.md", "agents\team-reviewer.md")

$backup = Join-Path $dst ("backups\team-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
foreach ($f in $files) {
    $target = Join-Path $dst $f
    if (Test-Path $target) {
        $b = Join-Path $backup $f
        New-Item -ItemType Directory -Force (Split-Path $b) | Out-Null
        Copy-Item $target $b
    }
    New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
    Copy-Item (Join-Path $src $f) $target
    Write-Host "installed: $target"
}
if (Test-Path $backup) { Write-Host "backup: $backup" }
Write-Host "Restart Claude Code to use /team."
