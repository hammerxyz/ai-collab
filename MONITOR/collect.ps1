# 中文说明：只读采集脚本，汇总各项目黑板 / 租约 / 心跳 / 证据 / 审计缺口，输出供 index.html 展示。

# AI-COLLAB Monitor Collector
# 只读扫描项目状态，输出到 PROJECTS/{project_id}/MONITOR/status.json
# 硬规则：禁止修改任何项目状态文件

param(
    [string]$ProjectId = "",
    [switch]$All = $false
)

$ErrorActionPreference = "Stop"
$aiCollabRoot = Split-Path -Parent $PSScriptRoot
$script:malformedInputs = 0

# --- Helper: Parse Markdown table rows ---
function Parse-MdTable($content, $headerPattern) {
    $lines = $content -split "`n"
    $inTable = $false
    $headers = @()
    $rows = @()
    foreach ($line in $lines) {
        if ($line -match '^\|(.+)\|$' -and $line -notmatch '^\|[\s-:|]+\|$') {
            $cells = ($line.Trim('|') -split '\|').Trim()
            if (-not $inTable) {
                $headers = $cells
                $inTable = $true
            } else {
                $obj = @{}
                for ($i = 0; $i -lt [Math]::Min($headers.Count, $cells.Count); $i++) {
                    $obj[$headers[$i]] = $cells[$i]
                }
                $rows += $obj
            }
        } elseif ($inTable -and $line -match '^\|[\s-:|]+\|$') {
            continue
        } elseif ($inTable -and $line -notmatch '^\|') {
            $inTable = $false
        }
    }
    return $rows
}

# --- Helper: Extract stage status from BLACKBOARD.md ---
function Get-StageStatus($blackboardContent) {
    $stages = @()
    $lines = $blackboardContent -split "`n"
    $currentStage = ""
    foreach ($line in $lines) {
        if ($line -match '^##\s+(.+)$') {
            $currentStage = $Matches[1].Trim()
        }
        if ($line -match '^\|\s*(.+?)\s*\|\s*(.+?)\s*\|' -and $currentStage) {
            $col1 = $Matches[1].Trim()
            $col2 = $Matches[2].Trim()
            if ($col2 -match 'completed|in.progress|pending|blocked|active') {
                $stages += @{
                    name   = $col1
                    status = $col2
                    group  = $currentStage
                }
            }
        }
    }
    return $stages
}

# --- Collect for a single project ---
function Collect-Project($projectId) {
    $projectDir = Join-Path $aiCollabRoot "PROJECTS\$projectId"
    if (-not (Test-Path $projectDir)) {
        Write-Warning "Project directory not found: $projectDir"
        return
    }

    Write-Host "Collecting status for project: $projectId"

    $status = @{
        project_id    = $projectId
        generated_at  = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
        current_stage = ""
        stages        = @()
        envelopes     = @()
        evidence_summary = @{
            total       = 0
            pass        = 0
            conditional = 0
            fail        = 0
            blocked     = 0
            security    = 0
        }
        audit_count   = 0
        active_claims = @()
        actors        = @()
        malformed_inputs = $script:malformedInputs
    }

    # --- PROJECT.md ---
    $projectMd = Join-Path $projectDir "PROJECT.md"
    if (Test-Path $projectMd) {
        $content = Get-Content $projectMd -Raw -Encoding UTF8
        if ($content -match 'project_name:\s*(.+)') { $status.project_name = $Matches[1].Trim() }
        if ($content -match 'current_stage:\s*(.+)') { $status.current_stage = $Matches[1].Trim() }
        # fallback: extract from markdown
        if (-not $status.project_name -and $content -match '#\s+(.+)') { $status.project_name = $Matches[1].Trim() }
    }

    # --- BLACKBOARD.md ---
    $blackboardMd = Join-Path $projectDir "BLACKBOARD.md"
    if (Test-Path $blackboardMd) {
        $content = Get-Content $blackboardMd -Raw -Encoding UTF8
        $status.stages = Get-StageStatus $content
    }
    # Safety: ensure stages is never null
    if ($null -eq $status.stages) {
        $status.stages = @()
    }

    # --- HANDOFF/ envelopes ---
    $handoffDir = Join-Path $projectDir "HANDOFF"
    if (Test-Path $handoffDir) {
        $envelopes = Get-ChildItem $handoffDir -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }
        foreach ($env in $envelopes) {
            $content = Get-Content $env.FullName -Raw -Encoding UTF8
            $envObj = @{
                envelope_id = $env.BaseName
                from        = ""
                to          = ""
                action      = ""
                status      = ""
                timestamp   = ""
            }
            if ($content -match 'action:\s*(\S+)') { $envObj.action = $Matches[1] }
            if ($content -match 'from:\s*(\S+)') { $envObj.from = $Matches[1] }
            if ($content -match 'to:\s*(.+)') { $envObj.to = $Matches[1].Trim() }
            if ($content -match 'current:\s*(\S+)') { $envObj.status = $Matches[1] }
            if ($content -match 'created_at:\s*(\S+)') { $envObj.timestamp = $Matches[1] }
            $status.envelopes += $envObj
        }
    }

    # --- EVIDENCE/ ---
    $evidenceDir = Join-Path $projectDir "EVIDENCE"
    if (Test-Path $evidenceDir) {
        $evidenceFiles = Get-ChildItem $evidenceDir -Filter "*.json" | Where-Object { $_.Name -ne "README.md" }
        $status.evidence_summary.total = $evidenceFiles.Count
        foreach ($ef in $evidenceFiles) {
            try {
                $json = Get-Content $ef.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
                $verdict = if ($json.verdict) { $json.verdict } elseif ($json.PSObject.Properties['verdict']) { $json.verdict } else { "UNKNOWN" }
                switch ($verdict) {
                    "PASS" { $status.evidence_summary.pass++ }
                    "CONDITIONAL" { $status.evidence_summary.conditional++ }
                    "FAIL" { $status.evidence_summary.fail++ }
                    "BLOCKED" { $status.evidence_summary.blocked++ }
                    "SECURITY" { $status.evidence_summary.security++ }
                }
            } catch {
                $script:malformedInputs++
                Write-Warning "Skipping malformed evidence: $($ef.FullName)"
            }
        }
    }

    # --- AUDIT/ ---
    $auditDir = Join-Path $projectDir "AUDIT"
    if (Test-Path $auditDir) {
        $status.audit_count = (Get-ChildItem $auditDir -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }).Count
    }

    # --- CLAIMS/ ---
    $claimsDir = Join-Path $projectDir "CLAIMS"
    if (Test-Path $claimsDir) {
        $claimFiles = Get-ChildItem $claimsDir -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }
        foreach ($cf in $claimFiles) {
            $content = Get-Content $cf.FullName -Raw -Encoding UTF8
            if ($content -match 'status:\s*Active') {
                $claim = @{
                    claim_id   = $cf.BaseName
                    actor_id   = ""
                    action     = ""
                    expires_at = ""
                }
                if ($content -match 'actor_id:\s*(\S+)') { $claim.actor_id = $Matches[1] }
                if ($content -match 'action:\s*(\S+)') { $claim.action = $Matches[1] }
                if ($content -match 'expires_at:\s*(\S+)') { $claim.expires_at = $Matches[1] }
                $status.active_claims += $claim
            }
        }
    }

    # --- HEARTBEAT/ ---
    $heartbeatDir = Join-Path $projectDir "HEARTBEAT"
    if (Test-Path $heartbeatDir) {
        $hbFiles = Get-ChildItem $heartbeatDir -Filter "*.json"
        foreach ($hf in $hbFiles) {
            try {
                $json = Get-Content $hf.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
                $status.actors += @{
                    actor_id  = $json.actor_id
                    role      = $json.role
                    status    = $json.status
                    last_seen = $json.last_seen
                }
            } catch {
                $script:malformedInputs++
                Write-Warning "Skipping malformed heartbeat: $($hf.FullName)"
            }
        }
    }

    # --- Write output to project-level MONITOR/ ---
    $monitorDir = Join-Path $projectDir "MONITOR"
    if (-not (Test-Path $monitorDir)) {
        New-Item -ItemType Directory -Path $monitorDir -Force | Out-Null
    }
    $outputPath = Join-Path $monitorDir "status.json"
    $status | ConvertTo-Json -Depth 10 | Set-Content $outputPath -Encoding UTF8
    Write-Host "  -> Written: $outputPath"
}

# --- Main ---
if ($All) {
    $indexMd = Join-Path $aiCollabRoot "PROJECTS\INDEX.md"
    if (Test-Path $indexMd) {
        $content = Get-Content $indexMd -Raw -Encoding UTF8
        $rows = Parse-MdTable $content
        foreach ($row in $rows) {
            $projId = if ($row['project_id']) { $row['project_id'] } elseif ($row['Project ID']) { $row['Project ID'] } else { "" }
            # Strip Markdown code-span backticks (e.g. `example-project-xxx` → example-project-xxx)
            $projId = $projId -replace '^`|`$', ''
            if ($projId -and $projId -ne "---" -and $projId -ne "project_id") {
                Collect-Project $projId
            }
        }
    } else {
        # Fallback: scan PROJECTS/ directories
        $projectsDir = Join-Path $aiCollabRoot "PROJECTS"
        Get-ChildItem $projectsDir -Directory | ForEach-Object {
            $projId = $_.Name
            if ($projId -ne "_TEMPLATE" -and $projId -ne "_DASHBOARD" -and (Test-Path (Join-Path $_.FullName "PROJECT.md"))) {
                Collect-Project $projId
            }
        }
    }
} elseif ($ProjectId) {
    Collect-Project $ProjectId
} else {
    # Default: collect for all projects
    Write-Host "No project specified. Use -ProjectId <id> or -All. Collecting all..."
    $projectsDir = Join-Path $aiCollabRoot "PROJECTS"
    Get-ChildItem $projectsDir -Directory | ForEach-Object {
        $projId = $_.Name
        if ($projId -ne "_TEMPLATE" -and $projId -ne "_DASHBOARD" -and (Test-Path (Join-Path $_.FullName "PROJECT.md"))) {
            Collect-Project $projId
        }
    }
}

Write-Host "Collection complete."

# --- Generate status_data.js for file:// protocol support ---
$allStatus = @{ generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK"); projects = @() }
$projectsDir = Join-Path $aiCollabRoot "PROJECTS"
Get-ChildItem $projectsDir -Directory | ForEach-Object {
    $projId = $_.Name
    $statusFile = Join-Path $_.FullName "MONITOR\status.json"
    if (Test-Path $statusFile) {
        try {
            $json = Get-Content $statusFile -Raw -Encoding UTF8 | ConvertFrom-Json
            $allStatus.projects += $json
        } catch {
            $script:malformedInputs++
            Write-Warning "Skipping malformed status JSON: $statusFile"
        }
    }
}
$jsContent = "// Auto-generated by collect.ps1 — do not edit manually`nwindow.STATUS_DATA = " + ($allStatus | ConvertTo-Json -Depth 10) + ";"
$jsPath = Join-Path $PSScriptRoot "status_data.js"
$jsContent | Set-Content $jsPath -Encoding UTF8
Write-Host "  -> Written: $jsPath (for file:// protocol)"

# Exit non-zero if any malformed inputs were encountered
if ($script:malformedInputs -gt 0) {
    Write-Warning "Collection completed with $($script:malformedInputs) malformed input(s) — some data may be incomplete."
    exit 1
}
