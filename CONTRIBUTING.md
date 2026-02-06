# Contributing to OpenClaw Forge

Thank you for your interest in contributing! This guide will help you get started.

## 📋 Prerequisites

- Basic understanding of OpenClaw skills and agents
- Git and GitHub account
- [Clawhub CLI](https://clawhub.com) installed (for publishing skills)

## 🚀 Quick Start

1. **Fork and Clone**
   ```bash
   git clone https://github.com/addozhang/openclaw-forge.git
   cd openclaw-forge
   ```

2. **Create Your Skill/Agent**
   ```bash
   # For skills
   mkdir -p skills/your-skill-name
   cd skills/your-skill-name
   
   # For agents
   mkdir -p agents/your-agent-name
   cd agents/your-agent-name
   ```

3. **Follow the Structure**
   - See [AGENTS.md](AGENTS.md) for detailed guidelines
   - Check existing skills for examples

## 📁 Required Files for Skills

Every skill must include:

1. **SKILL.md** - Main documentation
   - Frontmatter with metadata
   - Clear usage instructions
   - Examples
   
2. **README.md** - GitHub display page
   - Quick start guide
   - Installation instructions
   
3. **package.json** - Clawhub metadata
   ```json
   {
     "name": "@addozhang/skill-name",
     "version": "1.0.0",
     "description": "Clear description in English",
     "keywords": ["keyword1", "keyword2"],
     "author": "Your Name",
     "license": "MIT"
   }
   ```

4. **.gitignore** - Protect sensitive files
   - Credentials (token.json, credentials.json)
   - Temporary files

## 🎯 Contribution Guidelines

### Code Style
- **Documentation**: English
- **Code**: Clear, well-commented
- **Commit messages**: Conventional Commits format
  ```
  feat(skill-name): add new feature
  fix(skill-name): fix bug
  docs(skill-name): update documentation
  ```

### Pull Request Process

1. **Create a Branch**
   ```bash
   git checkout -b feat/your-feature-name
   ```

2. **Make Changes**
   - Follow the project structure
   - Update documentation
   - Test your changes

3. **Commit**
   ```bash
   git add .
   git commit -m "feat(skill-name): description"
   ```

4. **Push and Create PR**
   ```bash
   git push origin feat/your-feature-name
   ```
   - Go to GitHub and create a Pull Request
   - Describe your changes clearly
   - Link any related issues

### PR Checklist

- [ ] All required files included (SKILL.md, README.md, package.json)
- [ ] Documentation in English
- [ ] No sensitive files (credentials, tokens)
- [ ] Code tested (if applicable)
- [ ] Commit messages follow Conventional Commits
- [ ] README.md includes Quick Start section
- [ ] Credits/acknowledgments included (if derived work)

## 🧪 Testing

### Manual Testing
1. Test skill functionality
2. Verify documentation clarity
3. Check for sensitive file leaks

### Automated Tests
- GitHub Actions will run on PR submission
- Ensures basic file structure compliance

## 📝 Documentation Standards

### SKILL.md Structure
```markdown
---
name: skill-name
description: Brief description
version: 1.0.0
keywords: [keyword1, keyword2]
license: MIT
---

# Skill Name

## Overview
Brief introduction

## Usage
How to use

## Examples
Practical examples

## Troubleshooting
Common issues
```

### README.md Structure
```markdown
# Skill Name

Brief description

## Quick Start

Simple usage example

## Installation

Setup instructions

## Configuration

Configuration options

## Credits

Acknowledgments
```

## 🎨 Skill Categories

Choose appropriate category for your skill:
- **automation** - Task automation
- **integration** - External service integration
- **development** - Development tools
- **productivity** - Productivity enhancement
- **monitoring** - System/service monitoring
- **communication** - Messaging/notification

## ⚠️ Security

### Never Commit
- API keys
- OAuth tokens (token.json, credentials.json)
- Private keys (.key, .pem)
- Environment files (.env)

### Use .gitignore
Every skill should have `.gitignore` protecting:
```
token.json
credentials.json
*.key
*.pem
.env
*.log
*.bak
```

## 📦 Publishing to Clawhub

After PR is merged:

1. **Test Locally**
   ```bash
   cd skills/your-skill-name
   clawhub publish --dry-run
   ```

2. **Publish**
   ```bash
   clawhub publish
   ```

3. **Update Project README**
   - Add your skill to the list

## 🆘 Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/addozhang/openclaw-forge/discussions)
- **Bugs**: Open a [GitHub Issue](https://github.com/addozhang/openclaw-forge/issues)
- **OpenClaw Docs**: https://docs.openclaw.ai
- **Clawhub**: https://clawhub.com

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Acknowledgments

Thank you for contributing to OpenClaw Forge! Your skills help make AI assistants more capable and useful.

---

**Note**: This is a living document. Suggestions for improvement are welcome!
