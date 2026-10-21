# PreToolUse hook (Edit|Write|MultiEdit): block changes to committed Supabase migrations.
# New or not-yet-committed migration files can still be edited.
$ErrorActionPreference = 'SilentlyContinue'

$data = [Console]::In.ReadToEnd() | ConvertFrom-Json
$path = $data.tool_input.file_path
if (-not $path) { exit 0 }

$norm = $path -replace '\\', '/'
if ($norm -notmatch '/supabase/migrations/[^/]+\.sql$') { exit 0 }
if (-not (Test-Path -LiteralPath $path)) { exit 0 }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { exit 0 }

Push-Location (Split-Path -Parent $path)
$lastCommit = git log -1 --format=%H -- (Split-Path -Leaf $path) 2>$null
Pop-Location

if ($lastCommit) {
    [Console]::Error.WriteLine("Blocked: $path is a committed migration and must not change. Create a new migration instead (use /new-migration).")
    exit 2
}
exit 0
