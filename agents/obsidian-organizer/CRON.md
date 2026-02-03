# Obsidian Organizer Agent - Cron 配置

## 定时任务

### 1. 每天早上 9:00 - 检查草稿并报告
```bash
openclaw cron add \
  --name "obsidian-morning-check" \
  --schedule "0 9 * * *" \
  --task "运行 Obsidian 草稿检查脚本，如果有需要关注的草稿，发送报告到 Telegram" \
  --command "/home/addo/.openclaw/workspace/agents/obsidian-organizer/scripts/check_drafts.sh"
```

### 2. 每周一 10:00 - 周报
```bash
openclaw cron add \
  --name "obsidian-weekly-report" \
  --schedule "0 10 * * 1" \
  --task "生成 Obsidian vault 周报：统计本周笔记活动、提醒旧草稿"
```

### 3. 每天晚上 21:00 - 自动提交
```bash
openclaw cron add \
  --name "obsidian-auto-commit" \
  --schedule "0 21 * * *" \
  --command "/home/addo/.openclaw/workspace/agents/obsidian-organizer/scripts/auto_commit.sh" \
  --task "自动提交 Obsidian vault 的变更到 GitHub"
```

## 手动触发命令

```bash
# 检查草稿
/home/addo/.openclaw/workspace/agents/obsidian-organizer/scripts/check_drafts.sh

# 手动提交
/home/addo/.openclaw/workspace/agents/obsidian-organizer/scripts/auto_commit.sh
```
