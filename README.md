# Ralph - Autonomous AI Agent Loop

Ralph is an autonomous coding agent that executes user stories from a PRD (Product Requirements Document) one at a time. Each iteration spawns a fresh Claude instance with clean context, working through tasks until all stories are complete.

## How It Works

Ralph follows a Test-Driven Development (TDD) approach:
1. Read the PRD and find the next incomplete story
2. Write tests first (red phase)
3. Implement to make tests pass (green phase)
4. Run quality checks (typecheck, lint, tests)
5. Commit the work and mark the story as complete
6. Repeat until all stories pass

Memory persists between iterations via:
- **git history** - code changes are committed
- **prd.json** - tracks which stories pass/fail
- **progress.txt** - logs learnings and patterns

## Workflow Overview

![Ralph Workflow Overview](ralph-overview.png)

### Step 1: Create a PRD with `/prd`

Run the `/prd` skill in Claude Code to generate a Product Requirements Document:

```
/prd add user authentication to the app
```

The skill will:
1. Ask 3-5 clarifying questions about your feature
2. Generate a structured PRD with user stories
3. Save it to `tasks/prd-[feature-name].md`

Each user story includes:
- Title and description
- Acceptance criteria (verifiable, not vague)
- Required quality checks (tests, typecheck, browser verification)

### Step 2: Convert to prd.json with `/ralph`

Run the `/ralph` skill to convert your PRD to Ralph's executable format:

```
/ralph
```

This reads your PRD and generates `prd.json` with:
- Project name and feature branch
- User stories ordered by dependency (schema → backend → UI)
- Each story sized to complete in one context window
- `passes: false` for all stories initially

**Critical constraint:** Stories must be small enough to complete in ONE Ralph iteration. If a story is too big, split it.

### Step 3: Run the Ralph Loop

You can run Ralph using either the bash script or the Go binary:

#### Option A: Go Binary (Recommended)

Install the Go binary:

```bash
./go-ralph.sh
```

This installs `ralph` to `~/.local/bin/`. Then run:

```bash
ralph                           # Default: 10 iterations, claude
ralph -max-iterations=5         # Custom iteration count
ralph -timeout=30m              # Add timeout for silent hangs
ralph -tool=opencode            # Use opencode instead of claude
```

#### Option B: Bash Script

```bash
./ralph.sh [max_iterations]
```

#### Why Use the Go Binary?

The Go version includes a **log watcher** that monitors for errors in real-time:

```
┌─────────────────┐         ┌──────────────────────┐
│ Claude process  │         │ Log watcher goroutine│
│                 │         │                      │
│ writes to log ──┼────────►│ reads log every 5s   │
│                 │         │ checks for errors    │
│                 │◄────────┼─ kills process if    │
│                 │  SIGKILL│   error detected     │
└─────────────────┘         └──────────────────────┘
```

**Benefits:**
- **Immediate error detection**: If Claude crashes with "No messages returned" or similar transient errors, the watcher detects it within 5 seconds and kills the hung process
- **Faster retries**: Instead of waiting for a process that emitted an error but didn't exit, Ralph kills it and retries immediately
- **Optional timeout**: Use `-timeout=30m` to kill sessions that hang silently (no output) after the specified duration
- **Same retry logic**: Still retries up to 3 times on transient errors, then moves to next iteration

**Detected transient errors:**
- `No messages returned`
- `ECONNRESET`, `ETIMEDOUT`
- `rate limit`
- HTTP `502`, `503`

Both versions will:
- Work through stories in priority order
- Retry on transient API errors (up to 3 retries)
- Archive previous runs when switching features
- Stop when all stories pass or max iterations reached

When all stories complete, you'll see:
```
Ralph completed all tasks!
```

## Checking Progress

Use the `/ralph-tasks-left` skill or run directly:

```bash
# Summary
jq '"\([.userStories[] | select(.passes == true)] | length) / \(.userStories | length) completed"' prd.json

# List remaining tasks
jq -r '.userStories[] | select(.passes == false) | "\(.id): \(.title)"' prd.json
```

## Setting Up Ralph in a New Project

### Option 1: Use the `/setup-ralph` skill

In your target project directory, run:

```
/setup-ralph
```

This copies the core Ralph files:
- `AGENTS.md` - Agent configuration
- `prompt.md` - Instructions for each Ralph iteration
- `ralph.sh` - The execution loop

Files are automatically added to `.git/info/exclude` to stay local.

### Option 2: Manual setup

```bash
cp ~/Projects/my-ralph-template/AGENTS.md .
cp ~/Projects/my-ralph-template/prompt.md .
cp ~/Projects/my-ralph-template/ralph.sh .
```

## Installing the Claude Code Skills

Ralph uses Claude Code skills to streamline the workflow. Install them by copying the skill folders to your Claude Code skills directory.

### Skill Location

Claude Code loads skills from `~/.claude/skills/`. Each skill is a folder containing a `SKILL.md` file.

### Installing Skills

Copy the skills from this template:

```bash
# Create skills directory if it doesn't exist
mkdir -p ~/.claude/skills

# Copy Ralph skills
cp -r ~/Projects/my-ralph-template/skills/prd ~/.claude/skills/
cp -r ~/Projects/my-ralph-template/skills/ralph ~/.claude/skills/
cp -r ~/Projects/my-ralph-template/skills/ralph-tasks-left ~/.claude/skills/
cp -r ~/Projects/my-ralph-template/skills/setup-ralph ~/.claude/skills/
```

### Verify Installation

Restart Claude Code and check that skills are available. You can invoke them with:
- `/prd` - Create a PRD for a new feature
- `/ralph` - Convert a PRD to prd.json format
- `/ralph-tasks-left` - Check task completion progress
- `/setup-ralph` - Initialize Ralph in a project

## Skill Reference

| Skill | Purpose | Trigger phrases |
|-------|---------|-----------------|
| `/prd` | Generate a Product Requirements Document | "create a prd", "plan this feature", "spec out" |
| `/ralph` | Convert PRD to prd.json format | "convert this prd", "ralph json", "create prd.json" |
| `/ralph-tasks-left` | Check task progress | "how many tasks left", "ralph progress", "tasks remaining" |
| `/setup-ralph` | Initialize Ralph in a project | "setup ralph", "init ralph", "add ralph template" |

## Key Files

| File | Description |
|------|-------------|
| `ralph.sh` | Bash loop that spawns Claude instances |
| `cmd/ralph/main.go` | Go implementation with log watcher |
| `go-ralph.sh` | Installer for Go binary |
| `prompt.md` | Instructions given to each iteration |
| `prd.json` | Task list with completion status |
| `progress.txt` | Log of completed work and learned patterns |
| `AGENTS.md` | Project-specific agent configuration |

## Writing Good User Stories

Stories must be:

1. **Small enough** - Completable in one context window
2. **Ordered by dependency** - Schema before backend, backend before UI
3. **Verifiable** - Acceptance criteria can be checked, not vague

**Good criteria:**
- "Add `status` column to tasks table with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"
- "Typecheck passes"

**Bad criteria:**
- "Works correctly"
- "Good UX"
- "Handles edge cases"

## Experimental: Flowchart

The `flowchart/` directory contains an interactive React Flow diagram explaining how Ralph works. This is experimental and not part of the main workflow.

```bash
cd flowchart && npm run dev
```

## Troubleshooting

### Ralph exits with transient errors
The script automatically retries up to 3 times on API errors (rate limits, timeouts, etc.). If retries are exhausted, it moves to the next iteration.

### Stories are too big
If Ralph runs out of context before completing a story, split it into smaller pieces. Rule of thumb: if you can't describe the change in 2-3 sentences, it's too big.

### prd.json from a different feature
Ralph automatically archives the previous `prd.json` and `progress.txt` when switching to a new feature branch. Archives are stored in `archive/YYYY-MM-DD-feature-name/`.

## Requirements

- [Claude Code](https://claude.com/claude-code) CLI installed
- `jq` for JSON parsing (used by progress checking)
- Bash shell
- Go 1.21+ (optional, for Go binary with log watcher)
