# 📰 Daily Briefing Agent

每天早上 7:00 准时送达的信息简报。

## ✨ 功能

### 🌤️ 今日概览
- **日期与星期**: 完整日期信息
- **天气**: 广州实时天气（温度、湿度、风速）
- **今日任务**: Google Tasks 待办事项

### 🔥 技术资讯
- Hacker News 今日热门（Top 7-8）
- 自动过滤低分内容（< 50 points）
- 包含讨论热度（评论数）

## 📂 文件结构

```
agents/daily-briefing/
├── AGENT.md                    # Agent 定义
├── README.md                   # 本文件
└── scripts/
    ├── generate_briefing.sh   # 主脚本：生成完整简报
    └── get_hn_news.sh         # HN 资讯获取
```

## ⏰ 定时任务

**时间**: 每天早上 7:00（北京时间）
**渠道**: Telegram
**格式**: Markdown

## 🎯 简报示例

```markdown
# 📰 每日简报 - 2026年02月02日 星期一

## 🌤️ 今日概览

**天气 · 广州**
- Clear +15°C | 湿度: 51% | 风速: ↙12km/h

**📋 今日任务**
1. ⬜ 完成技术文章
2. ⬜ Review PR

## 🔥 技术资讯 (Hacker News)

1. **Nano-vLLM: How a vLLM-style inference engine works**
   🔗 https://neutree.ai/blog/nano-vllm-part-1
   📊 97 points | 💬 10 comments

2. **4x faster network file sync with rclone**
   🔗 https://www.jeffgeerling.com/...
   📊 65 points | 💬 19 comments

---
✨ Have a great day!
```

## 🛠️ 手动测试

```bash
# 生成今日简报
~/workspace/agents/daily-briefing/scripts/generate_briefing.sh

# 单独获取 HN 资讯
~/workspace/agents/daily-briefing/scripts/get_hn_news.sh
```

## 📊 配置

### 城市设置
- 当前: 广州
- 修改: 编辑 `generate_briefing.sh` 中的 `wttr.in/Guangzhou`

### HN 资讯数量
- 当前: 最多 8 条，分数 >= 50
- 修改: 编辑 `get_hn_news.sh` 中的 `COUNT` 和 `SCORE` 阈值

## 🔗 依赖

- curl - HTTP 请求
- jq - JSON 解析
- Google Tasks skill - 任务数据
- weather skill (wttr.in) - 天气数据

---

创建时间: 2026-02-02
版本: 1.0.0
