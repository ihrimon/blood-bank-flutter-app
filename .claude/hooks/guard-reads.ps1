# PreToolUse hook (Read|Grep|Glob): keep big or personal docs out of context.
# - docs/PRD.md, docs/MVP.md: Read must pass a limit (Grep the heading first, then read that range).
# - docs/learning/, docs/ai-workflow.md: the user's own notes; ask the user before reading.
$ErrorActionPreference = 'SilentlyContinue'

$data = [Console]::In.ReadToEnd() | ConvertFrom-Json
$tool = $data.tool_name
$path = if ($data.tool_input.file_path) { $data.tool_input.file_path } else { $data.tool_input.path }
if (-not $path) { exit 0 }
$norm = $path -replace '\\', '/'

if ($norm -match '(^|/)docs/(learning(/|$)|ai-workflow\.md$)') {
    $out = @{
        hookSpecificOutput = @{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'ask'
            permissionDecisionReason = "$path is the user's personal notes. Read only if the user asked to work on it."
        }
    }
    Write-Output ($out | ConvertTo-Json -Compress -Depth 3)
    exit 0
}

if ($tool -eq 'Read' -and $norm -match '(^|/)docs/(PRD|MVP)\.md$' -and -not $data.tool_input.limit) {
    [Console]::Error.WriteLine("Blocked: don't read $path in full. Grep the section heading (e.g. '^### ' + Bangla section number) with -n, then Read with offset and limit.")
    exit 2
}
exit 0
