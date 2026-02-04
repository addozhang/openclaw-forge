#!/bin/bash
# 获取 Hacker News 热门内容

set -e

# 获取今日热门故事 ID
echo "# 🔥 Hacker News 今日热门" >&2
echo "" >&2

TOP_STORIES=$(curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" | jq -r '.[:30][]')

COUNT=0
for story_id in $TOP_STORIES; do
    if [ $COUNT -ge 20 ]; then
        break
    fi
    
    # 获取故事详情
    STORY=$(curl -s "https://hacker-news.firebaseio.com/v0/item/${story_id}.json")
    
    TITLE=$(echo "$STORY" | jq -r '.title // "无标题"')
    URL=$(echo "$STORY" | jq -r '.url // ""')
    SCORE=$(echo "$STORY" | jq -r '.score // 0')
    COMMENTS=$(echo "$STORY" | jq -r '.descendants // 0')
    
    # 如果没有外部链接，使用 HN 讨论页
    if [ -z "$URL" ] || [ "$URL" = "null" ]; then
        URL="https://news.ycombinator.com/item?id=${story_id}"
    fi
    
    # 过滤掉分数太低的
    if [ "$SCORE" -lt 50 ]; then
        continue
    fi
    
    COUNT=$((COUNT + 1))
    
    echo "${COUNT}. **${TITLE}**"
    echo "   🔗 ${URL}"
    echo "   📊 ${SCORE} points | 💬 ${COMMENTS} comments"
    echo ""
done

if [ $COUNT -eq 0 ]; then
    echo "暂无热门技术资讯"
fi
