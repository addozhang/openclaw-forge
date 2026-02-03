#!/bin/bash
# Obsidian Organizer - 草稿检查脚本

VAULT_PATH="$HOME/my-obsidian-vault"
DRAFT_PATH="$VAULT_PATH/个人/草稿"
NOTES_PATH="$VAULT_PATH/笔记"

# 获取当前时间戳
NOW=$(date +%s)
SEVEN_DAYS_AGO=$((NOW - 7 * 24 * 3600))
THIRTY_DAYS_AGO=$((NOW - 30 * 24 * 3600))

echo "# 📚 Obsidian 草稿检查报告"
echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 统计草稿
TOTAL_DRAFTS=$(find "$DRAFT_PATH" -name "*.md" -type f 2>/dev/null | wc -l)
echo "## 📊 总览"
echo "- 总草稿数: $TOTAL_DRAFTS"
echo ""

# 检查旧草稿
echo "## ⏰ 待处理草稿"
echo ""

OLD_DRAFTS_7=0
OLD_DRAFTS_30=0

while IFS= read -r file; do
    if [ -f "$file" ]; then
        FILE_TIME=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
        FILE_NAME=$(basename "$file")
        DAYS_OLD=$(( (NOW - FILE_TIME) / 86400 ))
        
        if [ "$FILE_TIME" -lt "$THIRTY_DAYS_AGO" ]; then
            echo "⚠️ **$FILE_NAME** - 已经 $DAYS_OLD 天未修改 (需要关注!)"
            OLD_DRAFTS_30=$((OLD_DRAFTS_30 + 1))
        elif [ "$FILE_TIME" -lt "$SEVEN_DAYS_AGO" ]; then
            echo "📌 **$FILE_NAME** - 已经 $DAYS_OLD 天未修改"
            OLD_DRAFTS_7=$((OLD_DRAFTS_7 + 1))
        fi
    fi
done < <(find "$DRAFT_PATH" -name "*.md" -type f 2>/dev/null)

if [ "$OLD_DRAFTS_7" -eq 0 ] && [ "$OLD_DRAFTS_30" -eq 0 ]; then
    echo "✅ 没有旧草稿需要处理"
fi

echo ""
echo "## 📈 统计"
echo "- 7天以上未动: $OLD_DRAFTS_7"
echo "- 30天以上未动: $OLD_DRAFTS_30"
echo ""

# 检查最近新增的草稿
echo "## 🆕 最近 24 小时新增"
YESTERDAY=$((NOW - 24 * 3600))
NEW_COUNT=0

while IFS= read -r file; do
    if [ -f "$file" ]; then
        FILE_TIME=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
        if [ "$FILE_TIME" -gt "$YESTERDAY" ]; then
            FILE_NAME=$(basename "$file")
            echo "- $FILE_NAME"
            NEW_COUNT=$((NEW_COUNT + 1))
        fi
    fi
done < <(find "$DRAFT_PATH" -name "*.md" -type f 2>/dev/null)

if [ "$NEW_COUNT" -eq 0 ]; then
    echo "无新增草稿"
fi
