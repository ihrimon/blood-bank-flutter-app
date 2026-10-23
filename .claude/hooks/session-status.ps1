# SessionStart hook (startup|resume|clear|compact): inject docs/STATUS.md so sessions start without a Read call.
$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$root = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
$status = Join-Path $root 'docs/STATUS.md'
if (-not (Test-Path -LiteralPath $status)) { exit 0 }

Write-Output 'docs/STATUS.md (auto-injected by SessionStart hook; no need to Read it again):'
Write-Output (Get-Content -LiteralPath $status -Raw -Encoding UTF8)
exit 0
