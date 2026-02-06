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
├── AGENTS.md           # This file (agent guidelines)
├── CONTRIBUTING.md     # Contribution guidelines
└── LICENSE             # MIT License
```

## Skill Development Standards

### Required Files

Every skill directory must include:

1. **SKILL.md** - Core documentation
   - Frontmatter (name, description, version, keywords, license)
   - Overview
   - Usage instructions
   - Examples
   - Troubleshooting

2. **README.md** - GitHub display page
   - User-facing introduction
   - Quick Start
   - Installation
   - Configuration
   - Credits/Acknowledgments

3. **package.json** - Clawhub metadata
   ```json
   {
     "name": "@addozhang/skill-name",
     "version": "1.0.0",
     "description": "English description",
     "keywords": ["keyword1", "keyword2"],
     "author": "Addo Zhang",
     "license": "MIT",
     "repository": {
       "type": "git",
       "url": "https://github.com/addozhang/openclaw-forge.git",
       "directory": "skills/skill-name"
     },
     "openclaw": {
       "type": "skill",
       "category": "category-name"
     }
   }
   ```

4. **.gitignore** - Protect sensitive files
   ```
   # Credentials and tokens
   token.json
   credentials.json
   *.key
   *.pem
   
   # Temporary files
   *.log
   *.tmp
   *.bak
   *~
   
   # Agent temporary files
   CHANGES.md
   PAUSE.md
   CLAWHUB_CHECKLIST.md
   ```

### Optional Files

- **scripts/** - Executable scripts
- **references/** - Reference documentation
- **tests/** - Test files

### Files NOT to Commit

- ❌ Authentication tokens (token.json, credentials.json)
- ❌ Temporary files (CHANGES.md, PAUSE.md, CLAWHUB_CHECKLIST.md)
- ❌ Duplicate scripts (multiple language implementations of same function)
- ❌ Backup files (*.bak, *~, *.backup)

## Documentation Language Standards

- **Code, Docs, README**: English
- **Commit messages**: English
- **User interaction**: Based on user preference (set in USER.md)

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

## Common Issues

### Q: Found sensitive files in commit?

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

### Q: How to streamline long skill documentation?

Reference ralph-loop streamlining process:
- Remove duplicate examples (keep 1-2 core examples)
- Remove overly detailed implementation details
- Remove advanced/edge cases
- Remove FAQ (if Troubleshooting already covers)
- Goal: Keep core functionality clear and concise

## Project Maintenance

### Regular Checks

- Check for outdated skills
- Update dependencies and documentation
- Clean up temporary files

### Cleanup Commands

```bash
# Find temporary files
find . -name "CHANGES.md" -o -name "PAUSE.md" -o -name "*.bak"

# Batch delete
find . -name "CHANGES.md" -delete
find . -name "PAUSE.md" -delete
find . -name "*.bak" -delete
```

## Resource Links

- **OpenClaw Docs**: https://docs.openclaw.ai
- **Clawhub**: https://clawhub.com
- **GitHub Repository**: https://github.com/addozhang/openclaw-forge
- **Contributing Guide**: See [CONTRIBUTING.md](CONTRIBUTING.md) for publishing and contribution workflow

---

**Note**: This file is continuously updated. New patterns and best practices discovered during work should be added promptly.
