# Agent Work Patterns

通用的工作流程和最佳实践，适用于所有 AI agents 在 openclaw-forge 项目中工作。

## Git Workflow

### 提交规范

使用 Conventional Commits 格式：

```bash
# 完成任务后立即提交
git add .
git commit -m "<type>(<scope>): <description>"

# Type 类型：
# feat:     新功能
# fix:      修复 bug
# docs:     文档更新
# chore:    杂务（清理、重命名等）
# refactor: 重构
# test:     测试相关
# style:    代码格式（不影响功能）

# Scope 范围：
# skill 名称、agent 名称或文件名

# 示例：
git commit -m "feat(ralph-loop): add exec tool support with pty"
git commit -m "docs(google-tasks): update authentication guide"
git commit -m "chore: clean up temporary files"
```

### 推送到 GitHub

```bash
# 确保在 main 分支
git push origin main
```

## 项目结构

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
├── README.md           # English docs
├── README_zh.md        # 中文文档
└── AGENTS.md           # 本文件（agent 工作指南）
```

## Skill 开发规范

### 必需文件

每个 skill 目录必须包含：

1. **SKILL.md** - 核心文档
   - Frontmatter (name, description, version, keywords, license)
   - Overview
   - Usage instructions
   - Examples
   - Troubleshooting

2. **README.md** - GitHub 展示页
   - 面向用户的介绍
   - Quick Start
   - Installation
   - Configuration
   - Credits/Acknowledgments

3. **package.json** - Clawhub 元数据
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

4. **.gitignore** - 保护敏感文件
   ```
   # 凭证和令牌
   token.json
   credentials.json
   *.key
   *.pem
   
   # 临时文件
   *.log
   *.tmp
   *.bak
   *~
   
   # Agent 临时文件
   CHANGES.md
   PAUSE.md
   CLAWHUB_CHECKLIST.md
   ```

### 可选文件

- **scripts/** - 可执行脚本
- **references/** - 参考文档
- **tests/** - 测试文件

### 不应提交的文件

- ❌ 认证令牌 (token.json, credentials.json)
- ❌ 临时文件 (CHANGES.md, PAUSE.md, CLAWHUB_CHECKLIST.md)
- ❌ 重复的脚本 (多个语言实现同一功能)
- ❌ Backup 文件 (*.bak, *~, *.backup)

## 文档语言规范

- **代码、文档、README**：英文
- **AGENTS.md、内部注释**：中文（团队沟通）
- **Commit messages**：英文
- **用户交互**：根据用户偏好（User.md 中设置）

## 发布到 Clawhub

### 发布前检查清单

1. ✅ 所有必需文件已创建
2. ✅ SKILL.md 英文完整
3. ✅ README.md 包含 Quick Start
4. ✅ package.json 元数据正确
5. ✅ .gitignore 保护敏感文件
6. ✅ 敏感文件未提交到 Git
7. ✅ 已提交并推送到 GitHub
8. ✅ 测试功能正常（如可行）

### 发布命令

```bash
# 1. 确保在 skill 目录
cd ~/openclaw-forge/skills/skill-name

# 2. 验证文件
ls -la  # 检查是否有临时文件
cat package.json  # 验证元数据

# 3. 发布到 Clawhub
clawhub publish

# 4. 验证发布
clawhub search skill-name
```

## Clawhub 常用命令

```bash
# 登录
clawhub login

# 搜索 skill
clawhub search <query>

# 查看已发布的 skills
clawhub list

# 更新已发布的 skill
cd skills/skill-name
clawhub publish  # 自动识别版本更新

# 安装 skill
clawhub install <skill-id>
```

## 测试策略

### Skill 测试

1. **简单验证**：检查语法和文件结构
2. **功能测试**：如果 skill 包含脚本，运行测试命令
3. **真实场景**：在实际项目中使用 skill

### Agent 测试

对于 agent 执行的 skill（如 ralph-loop）：
- 让 agent 使用 skill 执行一个简单任务
- 验证 exec/process tool 调用正确
- 检查输出和文件修改

## 常见问题

### Q: 提交时发现有敏感文件怎么办？

```bash
# 1. 从 Git 中移除（保留本地文件）
git rm --cached path/to/sensitive-file

# 2. 添加到 .gitignore
echo "sensitive-file" >> .gitignore

# 3. 提交更改
git add .gitignore
git commit -m "chore: protect sensitive files"
git push
```

### Q: 如何更新已发布的 skill？

```bash
# 1. 更新版本号
# 编辑 package.json 和 SKILL.md frontmatter 中的 version

# 2. 提交更改
git add .
git commit -m "feat(skill-name): description of changes"
git push

# 3. 重新发布
cd skills/skill-name
clawhub publish
```

### Q: Skill 文档太长怎么精简？

参考 ralph-loop 的精简过程：
- 删除重复的例子（保留 1-2 个核心示例）
- 删除过于详细的实现细节
- 删除高级/边缘用例
- 删除 FAQ（如果 Troubleshooting 已覆盖）
- 目标：保持核心功能说明清晰简洁

## 项目维护

### 定期检查

- 检查是否有过期的 skills
- 更新依赖和文档
- 清理临时文件

### 清理命令

```bash
# 查找临时文件
find . -name "CHANGES.md" -o -name "PAUSE.md" -o -name "*.bak"

# 批量删除
find . -name "CHANGES.md" -delete
find . -name "PAUSE.md" -delete
find . -name "*.bak" -delete
```

## 资源链接

- **OpenClaw 文档**: https://docs.openclaw.ai
- **Clawhub**: https://clawhub.com
- **GitHub 仓库**: https://github.com/addozhang/openclaw-forge
- **已发布的 Skills**:
  - google-tasks: https://clawhub.com/skills/google-tasks
  - (其他 skills 发布后在此添加)

---

**Note**: 本文件持续更新。Agent 在工作中发现的新模式和最佳实践应及时添加。
