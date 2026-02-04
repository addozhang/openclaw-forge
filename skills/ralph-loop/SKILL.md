---
name: ralph-loop
description: Generate copy-paste bash scripts for Ralph Wiggum/AI agent loops (Codex, Claude Code, OpenCode, Goose). Use when asked for a "Ralph loop", "Ralph Wiggum loop", or an AI loop to plan/build code via PROMPT.md + AGENTS.md, SPECS, and IMPLEMENTATION_PLAN.md, including PLANNING vs BUILDING modes, backpressure, sandboxing, and completion conditions.
---

# Ralph Loop

## Overview
Generate a ready-to-run bash script that runs an AI coding CLI in a loop. Align with the Ralph playbook flow:

1) **Define requirements** → JTBD → topics of concern → `specs/*.md`
2) **PLANNING loop** → create/update `IMPLEMENTATION_PLAN.md` (no implementation)
3) **BUILDING loop** → implement tasks, run tests (backpressure), update plan, commit

The loop persists context via `PROMPT.md` + `AGENTS.md` (loaded every iteration) plus the on-disk plan/specs.

## TTY Requirements & Mode Selection

Some coding agents **require a real terminal (TTY)** to work properly:

### Interactive CLIs (require TTY)
- **OpenCode** (`opencode run`) - hangs without TTY
- **Codex** (`codex exec`) - interactive prompts
- **Claude Code** (`claude`) - progress bars
- **Pi** (`pi`) - interactive mode
- **Goose** (`goose run`) - interactive sessions

**Solution**: Use **exec + process mode** (recommended)

### Non-Interactive CLIs (pure background)
- Custom scripts with file-based I/O
- **aider** - reads from stdin/files
- Any CLI that doesn't need terminal

**Solution**: Use **simple loop mode** (legacy, still supported)

---

## Two Execution Modes

### Mode 1: exec + process (Recommended)

✅ **Proper TTY support**  
✅ **Background monitoring with OpenClaw process tools**  
✅ **Real-time logs and progress**  
✅ **Timeout handling**  
✅ **Parallel sessions support**  
✅ **Workdir isolation**

**When to use**: OpenCode, Codex, Claude Code, Pi, Goose

**How it works**:
```bash
# Start agent in background with TTY
SESSION_ID=$(openclaw exec \
  command:"opencode run --model $MODEL \"$(cat PROMPT.md)\"" \
  workdir:"$PWD" \
  background:true \
  yieldMs:60000)

# Monitor progress
openclaw process action:log sessionId:"$SESSION_ID"

# Check if done
openclaw process action:poll sessionId:"$SESSION_ID"

# Kill if needed
openclaw process action:kill sessionId:"$SESSION_ID"
```

### Mode 2: Simple Loop (Legacy)

⚠️ **No TTY support**  
✅ **File-based input/output**  
✅ **Works for traditional CLIs**

**When to use**: aider, custom scripts, any non-interactive CLI

**How it works**:
```bash
for i in $(seq 1 $MAX_ITERS); do
  $CLI_CMD "$(cat PROMPT.md)" | tee -a log.txt
done
```

---

## Workflow

### 1) Collect inputs (ask if missing)

#### Required
- **Goal / JTBD** (what outcome is needed)
- **CLI** (`codex`, `claude-code`, `opencode`, `goose`, `pi`, other)
- **Mode**: `PLANNING`, `BUILDING`, or `BOTH`
- **Max iterations** (default: PLANNING=5, BUILDING=10)

#### Auto-detect
- **Execution mode**: Check if CLI is in "Interactive" list → exec+process, else ask user
- **Model flag**: Extract from CLI requirements (e.g., `--model` for OpenCode/Codex)

#### Optional
- **Completion condition**
  - Plan sentinel (default: `STATUS: COMPLETE` in `IMPLEMENTATION_PLAN.md`)
  - Custom regex pattern
- **Sandbox choice** (`none` | `docker` | other) + **security posture**
- **Backpressure commands** (tests/lints/build) to embed in `AGENTS.md`
- **Auto-approve flags** (ask explicitly)
  - Codex: `--full-auto` or `--yolo`
  - Claude Code: `--dangerously-skip-permissions`
  - OpenCode: (no flag needed)
- **Workdir** (default: `$PWD`)
- **Timeout** (default: 3600s per iteration)

### 2) Phase 1 — Requirements → specs
If the user wants "full Ralph" (or unclear requirements), do this before the loop:
- Break the JTBD into **topics of concern** (1 topic = 1 spec file).
- For each topic, draft `specs/<topic>.md`.
- Use subagents to load URLs or existing docs into context for spec quality.
- Keep specs short and testable.

### 3) Phase 2/3 — PROMPT.md + AGENTS.md
- **Context loaded each iteration:** `PROMPT.md` + `AGENTS.md`.
- `AGENTS.md` should include:
  - project test commands (backpressure)
  - build/run instructions
  - any operational learnings
- `PROMPT.md` should reference:
  - `specs/*.md`
  - `IMPLEMENTATION_PLAN.md`
  - any relevant project files/dirs

### 4) Two prompt templates (PLANNING vs BUILDING)
Create **two prompts** and swap `PROMPT.md` based on mode.

**PLANNING prompt (no implementation):**
```
You are running a Ralph PLANNING loop for: <JTBD/GOAL>.

Read specs/* and the current codebase. Do a gap analysis and update IMPLEMENTATION_PLAN.md only.
Rules:
- Do NOT implement.
- Do NOT commit.
- Prioritize tasks and keep plan concise.
- If requirements are unclear, write clarifying questions into the plan.

Completion:
If the plan is complete, add line: STATUS: COMPLETE
```

**BUILDING prompt:**
```
You are running a Ralph BUILDING loop for: <JTBD/GOAL>.

Context:
- specs/*
- IMPLEMENTATION_PLAN.md
- AGENTS.md (tests/backpressure)

Tasks:
1) Pick the most important task from IMPLEMENTATION_PLAN.md.
2) Investigate relevant code (don't assume missing).
3) Implement.
4) Run the backpressure commands from AGENTS.md.
5) Update IMPLEMENTATION_PLAN.md (mark done + notes).
6) Update AGENTS.md if you learned new operational details.
7) Commit with a clear message.

Completion:
If all tasks are done, add line: STATUS: COMPLETE
```

### 5) Build the per-iteration command

#### Interactive CLIs (with flags)
- Codex: `codex exec <FLAGS> "$(cat PROMPT.md)"`
  - Requires git repo
  - Flags: `--full-auto`, `--yolo`, `--model <model>`
- Claude Code: `claude <FLAGS> "$(cat PROMPT.md)"`
  - Flags: `--dangerously-skip-permissions`
- OpenCode: `opencode run --model <MODEL> "$(cat PROMPT.md)"`
- Goose: `goose run "$(cat PROMPT.md)"`
- Pi: `pi --provider <PROVIDER> --model <MODEL> -p "$(cat PROMPT.md)"`

If the CLI is unknown, ask for the exact command to run each iteration.

---

## Script Templates

### Template 1: exec + process Mode (Recommended for Interactive CLIs)

```bash
#!/usr/bin/env bash
set -euo pipefail

# ========== Configuration ==========
CLI_CMD="opencode run"
MODEL="github-copilot/claude-opus-4.5"
CLI_FLAGS="--model $MODEL"
MODE="BOTH"  # PLANNING | BUILDING | BOTH
MAX_PLANNING_ITERS=5
MAX_BUILDING_ITERS=10
WORKDIR="${PWD}"
PLAN_SENTINEL='STATUS:\s*(PLANNING_)?COMPLETE'
TIMEOUT=3600  # seconds per iteration

# ========== Validation ==========
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Run this inside a git repo."
  exit 1
fi

mkdir -p .ralph
touch PROMPT.md AGENTS.md IMPLEMENTATION_PLAN.md

# ========== Helper Functions ==========
run_iteration() {
  local iter=$1
  local phase=$2
  local max_iters=$3
  
  echo ""
  echo "========================================="
  echo "=== $phase iteration $iter/$max_iters ==="
  echo "========================================="
  
  # Start agent in background with TTY support
  local cmd="$CLI_CMD $CLI_FLAGS \"\\$(cat PROMPT.md)\""
  echo "Command: $cmd"
  
  # Use openclaw exec for proper TTY + background
  local session_output=$(openclaw exec \
    command:"$cmd" \
    workdir:"$WORKDIR" \
    background:true \
    timeout:$TIMEOUT \
    yieldMs:60000 2>&1)
  
  # Extract session ID
  local session_id=$(echo "$session_output" | grep -oP 'sessionId:\s*\K\S+' | head -1)
  
  if [[ -z "$session_id" ]]; then
    echo "❌ Failed to start session. Output:"
    echo "$session_output"
    return 1
  fi
  
  echo "✅ Started session: $session_id"
  
  # Monitor until completion
  local elapsed=0
  local check_interval=10
  
  while [[ $elapsed -lt $TIMEOUT ]]; do
    sleep $check_interval
    elapsed=$((elapsed + check_interval))
    
    # Check process state
    local state=$(openclaw process action:poll sessionId:"$session_id" 2>/dev/null | jq -r '.state // "unknown"')
    
    echo "[$(date +%H:%M:%S)] State: $state (${elapsed}s elapsed)"
    
    if [[ "$state" == "exited" ]]; then
      echo "✅ Agent finished"
      break
    fi
    
    # Show recent output every 30s
    if (( elapsed % 30 == 0 )); then
      echo "--- Recent output ---"
      openclaw process action:log sessionId:"$session_id" offset:-10 2>/dev/null || true
      echo "---"
    fi
  done
  
  # Save full logs
  echo "Saving logs to .ralph/${phase}-iter-${iter}.log"
  openclaw process action:log sessionId:"$session_id" > ".ralph/${phase}-iter-${iter}.log" 2>&1 || true
  
  # Check completion condition
  if grep -Eq "$PLAN_SENTINEL" IMPLEMENTATION_PLAN.md 2>/dev/null; then
    echo "✅ Completion detected in IMPLEMENTATION_PLAN.md!"
    return 0
  fi
  
  return 1
}

# ========== Main Loop ==========
case "$MODE" in
  PLANNING)
    echo "Starting PLANNING mode..."
    cp PROMPT_PLANNING.md PROMPT.md
    for i in $(seq 1 $MAX_PLANNING_ITERS); do
      if run_iteration $i "PLANNING" $MAX_PLANNING_ITERS; then
        echo "✅ Planning complete!"
        exit 0
      fi
    done
    echo "❌ Planning: Max iterations reached"
    exit 1
    ;;
    
  BUILDING)
    echo "Starting BUILDING mode..."
    cp PROMPT_BUILDING.md PROMPT.md
    for i in $(seq 1 $MAX_BUILDING_ITERS); do
      if run_iteration $i "BUILDING" $MAX_BUILDING_ITERS; then
        echo "✅ Building complete!"
        exit 0
      fi
    done
    echo "❌ Building: Max iterations reached"
    exit 1
    ;;
    
  BOTH)
    echo "Starting BOTH mode (Planning → Building)..."
    
    # Phase 1: Planning
    echo ""
    echo "========================================"
    echo "=== PHASE 1: PLANNING ==="
    echo "========================================"
    cp PROMPT_PLANNING.md PROMPT.md
    for i in $(seq 1 $MAX_PLANNING_ITERS); do
      if run_iteration $i "PLANNING" $MAX_PLANNING_ITERS; then
        echo "✅ Planning phase complete!"
        break
      fi
      if [[ $i -eq $MAX_PLANNING_ITERS ]]; then
        echo "⚠️ Planning: Max iterations reached, proceeding to building anyway..."
      fi
    done
    
    # Phase 2: Building
    echo ""
    echo "========================================"
    echo "=== PHASE 2: BUILDING ==="
    echo "========================================"
    cp PROMPT_BUILDING.md PROMPT.md
    # Clear completion sentinel for building phase
    sed -i '/STATUS:.*COMPLETE/d' IMPLEMENTATION_PLAN.md 2>/dev/null || true
    
    for i in $(seq 1 $MAX_BUILDING_ITERS); do
      if run_iteration $i "BUILDING" $MAX_BUILDING_ITERS; then
        echo "✅ Building phase complete!"
        echo "🎉 All done!"
        exit 0
      fi
    done
    echo "❌ Building: Max iterations reached"
    exit 1
    ;;
    
  *)
    echo "❌ Invalid MODE: $MODE (must be PLANNING, BUILDING, or BOTH)"
    exit 1
    ;;
esac
```

### Template 2: Simple Loop Mode (Legacy, for Non-Interactive CLIs)

```bash
#!/usr/bin/env bash
set -euo pipefail

# ========== Configuration ==========
CLI_CMD="aider"  # or any non-interactive CLI
CLI_FLAGS=""
PROMISE=""  # optional: phrase to detect in logs
MAX_ITERS=10
PLAN_SENTINEL='STATUS: COMPLETE'
TEST_CMD=""  # optional: test command to run

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Run this inside a git repo."
  exit 1
fi

touch PROMPT.md AGENTS.md IMPLEMENTATION_PLAN.md
LOG_FILE=".ralph/ralph.log"
mkdir -p .ralph

# ========== Main Loop ==========
for i in $(seq 1 "$MAX_ITERS"); do
  echo -e "\n=== Ralph iteration $i/$MAX_ITERS ===" | tee -a "$LOG_FILE"

  $CLI_CMD $CLI_FLAGS "$(cat PROMPT.md)" 2>&1 | tee -a "$LOG_FILE"

  if [[ -n "${TEST_CMD}" ]]; then
    echo "Running tests: $TEST_CMD" | tee -a "$LOG_FILE"
    bash -lc "$TEST_CMD" 2>&1 | tee -a "$LOG_FILE"
  fi

  if [[ -n "${PROMISE}" ]] && grep -Fq "$PROMISE" "$LOG_FILE"; then
    echo "✅ Promise phrase detected. Stopping." | tee -a "$LOG_FILE"
    exit 0
  fi
  
  if grep -Eq "$PLAN_SENTINEL" IMPLEMENTATION_PLAN.md 2>/dev/null; then
    echo "✅ Completion detected. Stopping." | tee -a "$LOG_FILE"
    exit 0
  fi

done

echo "❌ Max iterations reached without completion." | tee -a "$LOG_FILE"
exit 1
```

### Minimal Loop (Geoff Style)

For quick iterations without any controls:

```bash
# PLANNING
while :; do cat PROMPT_PLANNING.md | opencode run --model github-copilot/claude-opus-4.5; done

# BUILDING
while :; do cat PROMPT_BUILDING.md | opencode run --model github-copilot/claude-opus-4.5; done
```

**⚠️ Warning**: No completion detection, no timeout, no logs. Use `Ctrl+C` to stop manually.

---

## Completion Detection (Improved)

### Flexible Regex Pattern

**Problem**: Original regex was too strict:
```bash
# ❌ Too strict (exact match only)
grep -Fq "STATUS: PLANNING_COMPLETE" IMPLEMENTATION_PLAN.md
```

**Solution**: Flexible regex supports multiple formats:
```bash
# ✅ Flexible (handles variations)
grep -Eq "STATUS:?\s*(PLANNING_)?COMPLETE" IMPLEMENTATION_PLAN.md
```

**Matches**:
- `STATUS: COMPLETE`
- `STATUS:COMPLETE`
- `STATUS: PLANNING_COMPLETE`
- `STATUS:PLANNING_COMPLETE`
- `## Status: PLANNING_COMPLETE`

---

## Real-World Examples

### Example 1: OpenCode + BOTH Mode (Nexus MCP Server)

**Request**:
> Create a Ralph loop for OpenCode, BOTH mode, building a Nexus MCP server with HTTP streaming transport

**Generated Script**:
```bash
#!/usr/bin/env bash
CLI_CMD="opencode run"
MODEL="github-copilot/claude-opus-4.5"
CLI_FLAGS="--model $MODEL"
MODE="BOTH"
MAX_PLANNING_ITERS=5
MAX_BUILDING_ITERS=10

# ... (uses exec + process template)
```

**Result**:
- ✅ Planning: 3 minutes (1 iteration)
- ✅ Building: 27 minutes (1 iteration)
- ✅ 17 tasks implemented
- ✅ 26 tests passing
- ✅ Auto-commit with proper messages

### Example 2: Codex Batch PR Reviews (Parallel)

**Request**:
> Review PRs #86, #87, #95 in parallel using Codex

**Generated Script**:
```bash
#!/usr/bin/env bash
# Fetch all PR refs
git fetch origin '+refs/pull/*/head:refs/remotes/origin/pr/*'

# Launch parallel reviews
for pr in 86 87 95; do
  PROMPT="Review PR #$pr using git diff origin/main...origin/pr/$pr"
  
  SESSION_ID=$(openclaw exec \
    command:"codex exec --full-auto \"$PROMPT\"" \
    workdir:"$PWD" \
    background:true)
  
  echo "PR #$pr: session $SESSION_ID"
done

# Monitor all sessions
openclaw process action:list

# Post results to GitHub (manually after review)
```

**Result**:
- ✅ 3 PRs reviewed in parallel
- ✅ Each session isolated
- ✅ No branch conflicts

### Example 3: Pi with Custom Provider

**Request**:
> Use Pi with OpenAI GPT-4o-mini to refactor code

**Generated Script**:
```bash
CLI_CMD="pi"
CLI_FLAGS="--provider openai --model gpt-4o-mini -p"
MODE="BUILDING"
MAX_BUILDING_ITERS=5

# ... (uses exec + process template with Pi-specific flags)
```

---

## Safety & Sandbox Guidance

### Auto-Approve Flags (Dangerous!)

Running with auto-approve flags implies **trust + risk**:

- **Codex**: `--full-auto` (sandboxed but auto-approves), `--yolo` (NO sandbox, NO approvals)
- **Claude Code**: `--dangerously-skip-permissions`
- **OpenCode**: (no special flag, always prompts)

### Recommended Sandbox Options

1. **Docker**: Run inside container with limited privileges
2. **E2B**: Ephemeral sandboxed environments
3. **Fly.io**: Isolated VMs
4. **Git worktrees**: Isolated branches (doesn't protect filesystem)

### Escape Hatches

- **Stop loop**: `Ctrl+C`
- **Kill session**: `openclaw process action:kill sessionId:XXX`
- **Revert changes**: `git reset --hard HEAD~N`
- **Cleanup**: `rm -rf .ralph/`

---

## Guardrails

1. **Requirements first**: If requirements are unclear, insist on specs before BUILDING
2. **Plan validation**: If the plan looks stale/wrong, regenerate it (PLANNING loop)
3. **Backpressure**: If backpressure commands are missing, ask for them and add to `AGENTS.md`
4. **Workdir isolation**: Always use `workdir:` to prevent agents reading unrelated files
5. **Timeout limits**: Set reasonable timeouts (default 1 hour per iteration)
6. **Monitor don't interfere**: Use `process:log` to check progress, don't kill prematurely

---

## Troubleshooting

### OpenCode hangs in simple loop mode
**Problem**: OpenCode requires TTY, hangs in background without it  
**Solution**: Use exec + process mode instead

### Session not starting
**Problem**: `openclaw exec` fails with no session ID  
**Solution**: Check command syntax, ensure CLI is in PATH, verify git repo exists

### Completion not detected
**Problem**: Loop continues even after task is done  
**Solution**: Check `IMPLEMENTATION_PLAN.md` for exact sentinel format, use flexible regex

### Process times out
**Problem**: Agent stuck, times out after 1 hour  
**Solution**: Check logs in `.ralph/`, increase timeout, or simplify task

### Multiple sessions conflict
**Problem**: Parallel sessions modify same files  
**Solution**: Use git worktrees for true isolation

---

## Tips & Best Practices

1. **Start small**: Test with 1-2 iterations before running full loop
2. **Check logs**: Review `.ralph/*.log` files after each iteration
3. **Incremental commits**: Each iteration should commit changes
4. **Clear prompts**: Be specific in PROMPT.md about what to implement
5. **Backpressure early**: Add tests from the start, not at the end
6. **Monitor actively**: Check `openclaw process action:list` periodically
7. **Use worktrees for parallel work**: Avoid file conflicts
8. **Set realistic timeouts**: Some tasks take longer than 1 hour
9. **Version control everything**: Commit specs, prompts, plans
10. **Learn from logs**: Update AGENTS.md with operational learnings
