#!/bin/bash
# 生成每日简报

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色定义
DATE_STR=$(date '+%Y年%m月%d日')
WEEKDAY=$(date '+%A' | sed 's/Monday/星期一/;s/Tuesday/星期二/;s/Wednesday/星期三/;s/Thursday/星期四/;s/Friday/星期五/;s/Saturday/星期六/;s/Sunday/星期日/')

echo "# 📰 每日简报 - ${DATE_STR} ${WEEKDAY}"
echo ""

# ===== 今日概览 =====
echo "## 🌤️ 今日概览"
echo ""

# 天气信息（广州）
echo "**天气 · 广州**"
WEATHER_JSON=$(curl -s "wttr.in/Guangzhou?format=j1" 2>/dev/null)

if [ -n "$WEATHER_JSON" ]; then
    CONDITION_EN=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherDesc[0].value')
    TEMP=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].temp_C')
    MIN_TEMP=$(echo "$WEATHER_JSON" | jq -r '.weather[0].mintempC')
    MAX_TEMP=$(echo "$WEATHER_JSON" | jq -r '.weather[0].maxtempC')
    
    # 天气状况翻译
    case "$CONDITION_EN" in
        "Clear"|"Sunny") CONDITION="晴朗" ;;
        "Partly cloudy"|"Partly Cloudy") CONDITION="多云" ;;
        "Cloudy") CONDITION="阴天" ;;
        "Overcast") CONDITION="阴沉" ;;
        "Mist"|"Fog") CONDITION="雾" ;;
        "Light rain"|"Patchy rain possible") CONDITION="小雨" ;;
        "Moderate rain") CONDITION="中雨" ;;
        "Heavy rain") CONDITION="大雨" ;;
        "Light snow") CONDITION="小雪" ;;
        "Moderate snow") CONDITION="中雪" ;;
        "Heavy snow") CONDITION="大雪" ;;
        "Thundery outbreaks possible") CONDITION="可能有雷暴" ;;
        *) CONDITION="$CONDITION_EN" ;;
    esac
    
    echo "- ${CONDITION} ${TEMP}°C | 今日: ${MIN_TEMP}°C - ${MAX_TEMP}°C"
else
    echo "- 天气信息获取失败"
fi
echo ""

# Google Tasks
echo "**📋 今日任务**"
TASKS_OUTPUT=$("$HOME/.openclaw/workspace/skills/google-tasks/scripts/get_tasks.sh" 2>/dev/null)

if [ -n "$TASKS_OUTPUT" ]; then
    # 提取未完成的任务
    INCOMPLETE_TASKS=$(echo "$TASKS_OUTPUT" | grep -A 100 "未完成" | grep "^[0-9]" | head -5)
    if [ -n "$INCOMPLETE_TASKS" ]; then
        echo "$INCOMPLETE_TASKS"
    else
        echo "- ✅ 没有待办任务，轻松的一天！"
    fi
else
    echo "- 📝 任务列表为空"
fi
echo ""

# ===== 技术资讯 =====
echo "## 🔥 技术资讯 (Hacker News)"
echo ""

"${SCRIPT_DIR}/get_hn_news.sh" 2>/dev/null

echo ""
echo "---"
echo "✨ Have a great day!"
