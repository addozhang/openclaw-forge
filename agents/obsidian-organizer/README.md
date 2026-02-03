# 📚 Obsidian Organizer Agent

自动整理和维护你的 Obsidian vault 的智能助手。

## ✨ 功能

### 1. 📝 草稿管理
- 每天早上 9:00 检查草稿目录
- 识别超过 7 天未动的草稿
- 提醒需要处理的旧内容

### 2. 🔄 自动同步
- 每天晚上 21:00 自动提交变更到 GitHub
- 智能生成 commit 信息
- 避免手动 git 操作

### 3. 📊 周报统计
- 每周一 10:00 生成周报
- 统计本周笔记活动
- 提醒长期未处理的草稿

## 🗂️ 文件结构

```
agents/obsidian-organizer/
├── AGENT.md                    # Agent 定义和职责
├── CRON.md                     # Cron 配置说明
├── README.md                   # 本文件
└── scripts/
    ├── check_drafts.sh        # 草稿检查脚本
    └── auto_commit.sh         # 自动提交脚本
```

## 📅 定时任务

| 任务名 | 时间 | 功能 |
|--------|------|------|
| obsidian-morning-check | 每天 09:00 | 检查草稿并报告 |
| obsidian-auto-commit | 每天 21:00 | 自动提交到 GitHub |
| obsidian-weekly-report | 每周一 10:00 | 生成周报 |

*所有时间均为北京时间（Asia/Shanghai）*

## 🎯 当前状态

✅ **已创建的定时任务**:
- ✅ `obsidian-morning-check` - 下次运行: 明天 09:00
- ✅ `obsidian-auto-commit` - 下次运行: 今晚 21:00
- ✅ `obsidian-weekly-report` - 下次运行: 下周一 10:00

## 📝 最新草稿检查报告

$(date '+%Y-%m-%d %H:%M:%S')

- **总草稿数**: 12
- **最近 24 小时新增**: 12 个
- **需要关注的旧草稿**: 0

最新的草稿都是今天添加的，状态良好！✨

## 🛠️ 手动命令

```bash
# 立即检查草稿
~/workspace/agents/obsidian-organizer/scripts/check_drafts.sh

# 立即提交变更
~/workspace/agents/obsidian-organizer/scripts/auto_commit.sh

# 查看定时任务状态
openclaw cron list

# 手动运行某个任务
openclaw cron run obsidian-morning-check
```

## 🎨 自定义

你可以修改以下文件来调整行为：

- **检查规则**: 编辑 `scripts/check_drafts.sh` 中的天数阈值
- **提交策略**: 编辑 `scripts/auto_commit.sh` 的提交逻辑
- **定时时间**: 使用 `openclaw cron edit <job-name>` 修改时间

## 📖 相关文档

- [OpenClaw Cron 文档](https://docs.openclaw.ai/cli/cron)
- [Obsidian Skill](~/.npm-global/lib/node_modules/openclaw/skills/obsidian/)
- [主 Workspace](~/.openclaw/workspace/)

---

创建时间: 2026-02-02
版本: 1.0.0
