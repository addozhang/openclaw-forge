#!/bin/bash
# Git 自动提交脚本

VAULT_PATH="$HOME/my-obsidian-vault"

cd "$VAULT_PATH" || exit 1

# 检查是否有变更
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ 没有需要提交的变更"
    exit 0
fi

# 显示变更
echo "📝 发现以下变更:"
git status --short

# 添加所有变更
git add -A

# 生成提交信息
CHANGED_FILES=$(git diff --cached --name-only | wc -l)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

git commit -m "Auto sync - $TIMESTAMP ($CHANGED_FILES files)"

# 推送到远程
echo "🔄 推送到 GitHub..."
git push

echo "✅ 同步完成！"
