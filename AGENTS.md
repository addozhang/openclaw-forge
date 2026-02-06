# Agent Work Patterns

General workflows and best practices for all AI agents working on the openclaw-forge project.

## Git Workflow

### Commit Conventions

Use Conventional Commits format:

```bash
# Commit after completing each task
git add .
git commit -m "<type>(<scope>): <description>"

# Types:
# feat:     New feature
# fix:      Bug fix
# docs:     Documentation update
# chore:    Maintenance (cleanup, rename, etc.)
# refactor: Code refactoring
# test:     Test-related changes
# style:    Code formatting (no functional change)

# Scope:
# Skill name, agent name, or file name

# Examples:
git commit -m "feat(ralph-loop): add exec tool support with pty"
git commit -m "docs(google-tasks): update authentication guide"
git commit -m "chore: clean up temporary files"
```

### Push to GitHub

```bash
# Ensure on main branch
git push origin main
```

## Project Structure

```
openclaw-forge/
├── skills/              # OpenClaw skills
│   ├── google-tasks/   # Google Tasks API integration
│   ├── ralph-loop/     # Ralph Loop execution patterns
│   ├── mcp-builder/    # MCP server builder guide
│   ├── research-prep/  # Research workflow
│   ├── system-status/  # System monitoring
│   └── task-status/    # Task status reporter
├── agents/              # Autonomous agents
│   ├── daily-briefing/        # Daily briefing generator
│   └── obsidian-organizer/    # Obsidian note manager
├── README.md           # English documentation
├── README_zh.md        # Chinese documentation
├── AGENTS.md           # This file (agent work patterns)
├── CONTRIBUTING.md     # Contribution and skill development guidelines
└── LICENSE             # MIT License
```

## Testing Strategy

### Skill Testing

1. **Simple validation**: Check syntax and file structure
2. **Functional testing**: If skill includes scripts, run test commands
3. **Real-world scenario**: Use skill in actual project

### Agent Testing

For agent-executed skills (like ralph-loop):
- Have agent use skill to execute a simple task
- Verify exec/process tool calls are correct
- Check output and file modifications

## Project Maintenance

### Regular Cleanup Tasks

```bash
# Find temporary files
find . -name "CHANGES.md" -o -name "PAUSE.md" -o -name "*.bak"

# Remove temporary files
find . -name "CHANGES.md" -delete
find . -name "PAUSE.md" -delete
find . -name "*.bak" -delete
```

### Common Issues

**Q: Found sensitive files in commit?**

```bash
# 1. Remove from Git (keep local file)
git rm --cached path/to/sensitive-file

# 2. Add to .gitignore
echo "sensitive-file" >> .gitignore

# 3. Commit changes
git add .gitignore
git commit -m "chore: protect sensitive files"
git push
```

## Resource Links

- **OpenClaw Docs**: https://docs.openclaw.ai
- **Clawhub**: https://clawhub.com
- **GitHub Repository**: https://github.com/addozhang/openclaw-forge
- **Contributing Guide**: See [CONTRIBUTING.md](CONTRIBUTING.md) for skill development standards and publishing workflow

---

**Note**: This file is continuously updated. New patterns and best practices discovered during work should be added promptly.
