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

---

## TTY Requirements

Some coding agents **require a real terminal (TTY)** to work properly and will hang without it:

**Interactive CLIs (need TTY)**:
- OpenCode, Codex, Claude Code, Pi, Goose

**Non-Interactive CLIs (file-based)**:
- aider, custom scripts

**Solution**: Use **exec + process mode** for interactive CLIs, or simple loop for file-based tools.

---

## Execution Modes

### exec + process (Recommended for Interactive CLIs)

Provides proper TTY support with background monitoring:

```bash
# Start agent with TTY
SESSION_ID=$(openclaw exec \
  command:"opencode run --model $MODEL \"$(cat PROMPT.md)\"" \
  workdir:"$PWD" \
  background:true \
  yieldMs:60000)

# Monitor progress
openclaw process action:log sessionId:"$SESSION_ID"
openclaw process action:poll sessionId:"$SESSION_ID"

# Kill if needed
openclaw process action:kill sessionId:"$SESSION_ID"
```

**Benefits**: TTY support, real-time logs, timeout handling, parallel sessions, workdir isolation

### Simple Loop (Minimal)

For quick iterations or non-interactive CLIs:

```bash
while :; do 
  cat PROMPT.md | opencode run --model $MODEL
done
```

**Use**: Quick tests, file-based CLIs. Stop with `Ctrl+C`.

---

## Workflow

### 1) Collect inputs

**Required**:
- Goal / JTBD
- CLI (`opencode`, `codex`, `claude`, `goose`, `pi`, other)
- Mode (`PLANNING`, `BUILDING`, or `BOTH`)
- Max iterations (default: PLANNING=5, BUILDING=10)

**Optional**:
- Completion sentinel (default: `STATUS: COMPLETE` in `IMPLEMENTATION_PLAN.md`)
- Workdir (default: `$PWD`)
- Timeout (default: 3600s per iteration)
- Sandbox choice
- Auto-approve flags (`--full-auto`, `--yolo`, `--dangerously-skip-permissions`)

**Auto-detect**:
- If CLI is in interactive list → use exec + process mode
- Extract model flag from CLI requirements

### 2) Requirements → specs (optional)

If requirements are unclear:
- Break JTBD into topics of concern
- Draft `specs/<topic>.md` for each
- Keep specs short and testable

### 3) PROMPT.md + AGENTS.md

**PROMPT.md** references:
- `specs/*.md`
- `IMPLEMENTATION_PLAN.md`
- Relevant project files

**AGENTS.md** includes:
- Test commands (backpressure)
- Build/run instructions
- Operational learnings

### 4) Prompt templates

**PLANNING prompt** (no implementation):
```
You are running a Ralph PLANNING loop for: <GOAL>.

Read specs/* and current codebase. Update IMPLEMENTATION_PLAN.md only.

Rules:
- Do NOT implement
- Do NOT commit
- Create prioritized task list
- If unclear, write questions

Completion:
If plan is ready, add: STATUS: PLANNING_COMPLETE
```

**BUILDING prompt**:
```
You are running a Ralph BUILDING loop for: <GOAL>.

Context: specs/*, IMPLEMENTATION_PLAN.md, AGENTS.md

Tasks:
1) Pick most important task
2) Investigate code
3) Implement
4) Run backpressure commands from AGENTS.md
5) Update IMPLEMENTATION_PLAN.md
6) Update AGENTS.md with learnings
7) Commit with clear message

Completion:
If all done, add: STATUS: COMPLETE
```

### 5) CLI commands

| CLI | Command Template |
|-----|------------------|
| **OpenCode** | `opencode run --model <MODEL> "$(cat PROMPT.md)"` |
| **Codex** | `codex exec <FLAGS> "$(cat PROMPT.md)"` (requires git) |
| **Claude Code** | `claude <FLAGS> "$(cat PROMPT.md)"` |
| **Pi** | `pi --provider <PROVIDER> --model <MODEL> -p "$(cat PROMPT.md)"` |
| **Goose** | `goose run "$(cat PROMPT.md)"` |

Common flags:
- Codex: `--full-auto`, `--yolo`, `--model <model>`
- Claude: `--dangerously-skip-permissions`

---

## Script Template: exec + process Mode

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
TIMEOUT=3600

# ========== Validation ==========
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Run inside a git repo"
  exit 1
fi

mkdir -p .ralph
touch PROMPT.md AGENTS.md IMPLEMENTATION_PLAN.md

# ========== Helper: Run Iteration ==========
run_iteration() {
  local iter=$1 phase=$2 max_iters=$3
  
  echo "=== $phase iteration $iter/$max_iters ==="
  
  # Start agent with TTY
  local cmd="$CLI_CMD $CLI_FLAGS \"\\$(cat PROMPT.md)\""
  local session_output=$(openclaw exec \
    command:"$cmd" \
    workdir:"$WORKDIR" \
    background:true \
    timeout:$TIMEOUT \
    yieldMs:60000 2>&1)
  
  local session_id=$(echo "$session_output" | grep -oP 'sessionId:\s*\K\S+' | head -1)
  
  if [[ -z "$session_id" ]]; then
    echo "❌ Failed to start session"
    return 1
  fi
  
  echo "✅ Session: $session_id"
  
  # Monitor until completion
  local elapsed=0
  while [[ $elapsed -lt $TIMEOUT ]]; do
    sleep 10
    elapsed=$((elapsed + 10))
    
    local state=$(openclaw process action:poll sessionId:"$session_id" 2>/dev/null | jq -r '.state // "unknown"')
    echo "[${elapsed}s] State: $state"
    
    if [[ "$state" == "exited" ]]; then
      echo "✅ Agent finished"
      break
    fi
    
    # Show recent output every 30s
    if (( elapsed % 30 == 0 )); then
      openclaw process action:log sessionId:"$session_id" offset:-10 2>/dev/null || true
    fi
  done
  
  # Save logs
  openclaw process action:log sessionId:"$session_id" > ".ralph/${phase}-iter-${iter}.log" 2>&1 || true
  
  # Check completion
  if grep -Eq "$PLAN_SENTINEL" IMPLEMENTATION_PLAN.md 2>/dev/null; then
    echo "✅ Completion detected!"
    return 0
  fi
  
  return 1
}

# ========== Main Loop ==========
case "$MODE" in
  PLANNING)
    cp PROMPT_PLANNING.md PROMPT.md
    for i in $(seq 1 $MAX_PLANNING_ITERS); do
      run_iteration $i "PLANNING" $MAX_PLANNING_ITERS && exit 0
    done
    echo "❌ Max planning iterations reached"
    exit 1
    ;;
    
  BUILDING)
    cp PROMPT_BUILDING.md PROMPT.md
    for i in $(seq 1 $MAX_BUILDING_ITERS); do
      run_iteration $i "BUILDING" $MAX_BUILDING_ITERS && exit 0
    done
    echo "❌ Max building iterations reached"
    exit 1
    ;;
    
  BOTH)
    # Planning phase
    cp PROMPT_PLANNING.md PROMPT.md
    for i in $(seq 1 $MAX_PLANNING_ITERS); do
      run_iteration $i "PLANNING" $MAX_PLANNING_ITERS && break
      [[ $i -eq $MAX_PLANNING_ITERS ]] && echo "⚠️ Planning incomplete, proceeding..."
    done
    
    # Building phase
    cp PROMPT_BUILDING.md PROMPT.md
    sed -i '/STATUS:.*COMPLETE/d' IMPLEMENTATION_PLAN.md 2>/dev/null || true
    
    for i in $(seq 1 $MAX_BUILDING_ITERS); do
      run_iteration $i "BUILDING" $MAX_BUILDING_ITERS && exit 0
    done
    echo "❌ Max building iterations reached"
    exit 1
    ;;
esac
```

**Usage**:
1. Save as `ralph-loop.sh`
2. Adjust configuration variables
3. Run: `./ralph-loop.sh`

---

## Completion Detection

Use flexible regex to match variations:

```bash
grep -Eq "STATUS:?\s*(PLANNING_)?COMPLETE" IMPLEMENTATION_PLAN.md
```

**Matches**:
- `STATUS: COMPLETE`
- `STATUS:COMPLETE`
- `STATUS: PLANNING_COMPLETE`
- `## Status: PLANNING_COMPLETE`

---

## Safety & Guardrails

### Auto-Approve Flags (Risky!)
- Codex: `--full-auto` (sandboxed, auto-approves) or `--yolo` (no sandbox!)
- Claude: `--dangerously-skip-permissions`
- **Recommendation**: Use sandbox (docker/e2b/fly) with limited credentials

### Escape Hatches
- Stop: `Ctrl+C`
- Kill session: `openclaw process action:kill sessionId:XXX`
- Revert: `git reset --hard HEAD~N`

### Best Practices
1. **Start small**: Test with 1-2 iterations first
2. **Workdir isolation**: Prevent reading unrelated files
3. **Set timeouts**: Default 1 hour may not suit all tasks
4. **Monitor actively**: Check logs, don't kill prematurely
5. **Requirements first**: Clear specs before building
6. **Backpressure early**: Add tests from the start

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| OpenCode hangs | Use exec + process mode (needs TTY) |
| Session won't start | Check CLI path, git repo, command syntax |
| Completion not detected | Verify sentinel format, use flexible regex |
| Process times out | Increase timeout or simplify task |
| Parallel conflicts | Use git worktrees for isolation |
