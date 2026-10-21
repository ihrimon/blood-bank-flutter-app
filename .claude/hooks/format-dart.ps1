# PostToolUse hook: run `dart format` on an edited .dart file.
# Silent no-op if dart is not installed or the file is generated.
$ErrorActionPreference = 'SilentlyContinue'

$data = [Console]::In.ReadToEnd() | ConvertFrom-Json
$path = $data.tool_input.file_path

if (-not $path -or -not $path.EndsWith('.dart')) { exit 0 }
if ($path -match '\.(g|freezed)\.dart$') { exit 0 }
if (-not (Get-Command dart -ErrorAction SilentlyContinue)) { exit 0 }

& dart format $path *> $null
exit 0
