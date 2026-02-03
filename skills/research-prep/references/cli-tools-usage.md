# CLI 工具使用指南

完整的命令行工具使用说明和技巧。

## 工具清单

| 工具 | 用途 | 依赖 |
|------|------|------|
| `github_search.sh` | GitHub 搜索 | `gh`, `jq` |
| `web_search.sh` | 网页搜索 | `curl`, `jq` |
| `stackoverflow_search.sh` | Stack Overflow 搜索 | `curl`, `jq` |
| `authority_scorer.py` | 资料评分 | Python 3 |
| `update_research.py` | 链接检查 | Python 3, `requests` |

## 详细使用说明

### 1. GitHub 搜索 (`github_search.sh`)

#### 搜索仓库

```bash
./scripts/github_search.sh repos "kubernetes gateway" --limit 10

# 输出示例
[
  {
    "fullName": "kubernetes-sigs/gateway-api",
    "description": "Repository for the next iteration of composite service...",
    "url": "https://github.com/kubernetes-sigs/gateway-api",
    "stargazersCount": 1234,
    "updatedAt": "2026-02-01T10:30:00Z"
  }
]
```

**常用选项**:
- `--limit N` - 限制结果数量（默认 10）
- `--sort stars|forks|updated` - 排序方式

#### 搜索代码

```bash
./scripts/github_search.sh code "Gateway API" --repo kubernetes/kubernetes

# 输出示例
[
  {
    "repository": {
      "fullName": "kubernetes/kubernetes"
    },
    "path": "staging/src/k8s.io/api/gateway/v1/types.go",
    "url": "https://github.com/kubernetes/kubernetes/blob/..."
  }
]
```

**技巧**:
- 使用 `--language go` 限定编程语言
- 使用 `path:examples/` 限定文件路径

#### 搜索 Issues

```bash
./scripts/github_search.sh issues "bug" --repo kubernetes/gateway-api --state closed

# 输出示例
[
  {
    "title": "Gateway timeout not working",
    "url": "https://github.com/kubernetes-sigs/gateway-api/issues/123",
    "state": "closed",
    "createdAt": "2025-12-01T10:00:00Z",
    "closedAt": "2025-12-05T15:30:00Z",
    "comments": 5
  }
]
```

**状态选项**:
- `--state open` - 未解决
- `--state closed` - 已解决

#### 获取 README

```bash
./scripts/github_search.sh readme kubernetes/gateway-api

# 输出：README 的完整 Markdown 内容
```

### 2. Web 搜索 (`web_search.sh`)

```bash
./scripts/web_search.sh "kubernetes gateway api tutorial" 10

# 输出示例（每行一个 URL）
https://kubernetes.io/docs/concepts/services-networking/gateway/
https://gateway-api.sigs.k8s.io/
https://github.com/kubernetes-sigs/gateway-api
...
```

**高级搜索语法**:

```bash
# 限定官方域名
./scripts/web_search.sh "site:kubernetes.io gateway" 10

# 多个域名
./scripts/web_search.sh "site:kubernetes.io OR site:gateway-api.sigs.k8s.io" 10

# 排除域名
./scripts/web_search.sh "gateway api -site:medium.com" 10

# 精确匹配
./scripts/web_search.sh '"gateway api" tutorial' 10

# 文件类型
./scripts/web_search.sh "gateway api filetype:pdf" 5
```

### 3. Stack Overflow 搜索 (`stackoverflow_search.sh`)

```bash
./scripts/stackoverflow_search.sh "kubernetes gateway timeout" 5

# 输出示例
Title: How to configure timeout in Kubernetes Gateway API?
URL: https://stackoverflow.com/questions/12345678
Score: 25 | Answers: 3
Tags: kubernetes, gateway-api, timeout
---
```

**带标签搜索**:

```bash
# 限定标签
./scripts/stackoverflow_search.sh "timeout" 10 kubernetes

# 查找多个标签（需手动修改脚本）
# 例如：kubernetes + gateway-api
```

**筛选技巧**:
- Score > 10：高质量问题
- Answers > 1：有讨论
- 绿色勾：已采纳答案

### 4. 权威性评分 (`authority_scorer.py`)

```bash
python3 scripts/authority_scorer.py \
  --url "https://kubernetes.io/docs/concepts/services-networking/gateway/" \
  --date "2025-12-15" \
  --type "api-reference"

# 输出示例
Authority Score: 98/100
Rating: ⭐⭐⭐⭐⭐

Breakdown:
  source_authority: 40
  timeliness: 30
  technical_depth: 18
  community_recognition: 10
```

**内容类型选项** (`--type`):
- `architecture` - 架构设计 (20分)
- `design` - 设计文档 (20分)
- `rfc` - RFC/规范 (20分)
- `api-reference` - API 文档 (18分)
- `implementation` - 实现细节 (15分)
- `source-code` - 源代码 (15分)
- `tutorial` - 教程 (10分)
- `guide` - 指南 (10分)
- `overview` - 概览 (5分)
- `introduction` - 介绍 (5分)

**批量评分**:

```bash
# 评估多个链接
while read url; do
  python3 scripts/authority_scorer.py --url "$url"
done < urls.txt
```

### 5. 链接检查 (`update_research.py`)

```bash
python3 scripts/update_research.py research/2026-02-02-k8s-gateway.md

# 输出示例
Checking links in: research/2026-02-02-k8s-gateway.md

Checking: https://kubernetes.io/docs/concepts/services-networking/gateway/ ✓
Checking: https://github.com/kubernetes-sigs/gateway-api ✓
Checking: https://old-domain.com/article → Redirected to: https://new-domain.com/article
Checking: https://broken-link.com ✗ (404)

============================================================
Summary:
  Total links: 15
  Valid: 13 ✓
  Invalid: 1 ✗
  Redirected: 1 →

Issues found:
  Line 45: BROKEN - https://broken-link.com
    Error: HTTP 404
  Line 67: REDIRECT
    Old: https://old-domain.com/article
    New: https://new-domain.com/article
```

**选项**:
- `--timeout N` - 设置超时（默认 5 秒）
- `--fix` - 自动修复（未实现，占位）

## 组合使用示例

### 完整的资料收集流程

```bash
#!/bin/bash
# 收集 Kubernetes Gateway API 资料

TOPIC="kubernetes gateway api"
OUTPUT_DIR="research"
DATE=$(date +%Y-%m-%d)
FILENAME="$OUTPUT_DIR/$DATE-k8s-gateway-api.md"

mkdir -p "$OUTPUT_DIR"

echo "# 研究素材：Kubernetes Gateway API" > "$FILENAME"
echo "" >> "$FILENAME"
echo "**创建时间**: $DATE" >> "$FILENAME"
echo "**状态**: 收集中" >> "$FILENAME"
echo "" >> "$FILENAME"

# 1. 搜索官方文档
echo "## 📚 官方文档" >> "$FILENAME"
echo "" >> "$FILENAME"
./scripts/web_search.sh "site:kubernetes.io gateway api" 5 | while read url; do
  score=$(python3 scripts/authority_scorer.py --url "$url" --type "api-reference" | grep "Total:" | awk '{print $2}')
  echo "- [$url]($url) - 评分: $score" >> "$FILENAME"
done

# 2. 搜索 GitHub 仓库
echo "" >> "$FILENAME"
echo "## 💻 官方仓库" >> "$FILENAME"
echo "" >> "$FILENAME"
./scripts/github_search.sh repos "$TOPIC" --limit 3 | jq -r '.[] | "- [\(.fullName)](\(.url)) - ⭐ \(.stargazersCount)"' >> "$FILENAME"

# 3. 搜索代码示例
echo "" >> "$FILENAME"
echo "## 💻 代码示例" >> "$FILENAME"
echo "" >> "$FILENAME"
./scripts/github_search.sh code "Gateway" --repo kubernetes-sigs/gateway-api | jq -r '.[] | "- [\(.path)](\(.url))"' | head -5 >> "$FILENAME"

# 4. 搜索高票问答
echo "" >> "$FILENAME"
echo "## 💬 Stack Overflow" >> "$FILENAME"
echo "" >> "$FILENAME"
./scripts/stackoverflow_search.sh "$TOPIC" 3 | grep "^Title:" | sed 's/Title: /- /' >> "$FILENAME"

echo "✅ 素材收集完成: $FILENAME"
```

### 定期更新检查

```bash
#!/bin/bash
# 检查所有研究文件的链接有效性

for file in research/*.md; do
  echo "Checking: $file"
  python3 scripts/update_research.py "$file"
  echo ""
done
```

## 故障排查

### GitHub CLI 认证问题

```bash
# 检查认证状态
gh auth status

# 重新登录
gh auth login
```

### 搜索结果为空

可能原因：
1. **API 限制**: GitHub API 有速率限制
   - 解决：等待一段时间或使用认证 token
2. **关键词太具体**: 尝试更通用的关键词
3. **网络问题**: 检查网络连接

### Python 依赖缺失

```bash
# 安装 requests 库（用于 update_research.py）
pip3 install requests

# 或使用系统包管理器
sudo apt install python3-requests  # Debian/Ubuntu
```

### Web 搜索失败

DuckDuckGo 可能会限制爬虫。备选方案：

```bash
# 方案1：添加延迟
for query in "query1" "query2"; do
  ./scripts/web_search.sh "$query" 10
  sleep 2  # 等待2秒
done

# 方案2：使用 googler（需要安装）
googler --json "kubernetes gateway" | jq -r '.[].url'
```

## 性能优化

### 缓存搜索结果

```bash
# 缓存 GitHub 搜索结果
CACHE_DIR=".cache"
mkdir -p "$CACHE_DIR"

# 检查缓存
CACHE_FILE="$CACHE_DIR/repos-kubernetes.json"
if [ ! -f "$CACHE_FILE" ] || [ $(find "$CACHE_FILE" -mmin +60) ]; then
  # 缓存不存在或超过60分钟，重新搜索
  ./scripts/github_search.sh repos "kubernetes" > "$CACHE_FILE"
fi

# 使用缓存
cat "$CACHE_FILE" | jq '.'
```

### 并行搜索

```bash
# 并行执行多个搜索任务
{
  ./scripts/web_search.sh "kubernetes gateway" > web.txt &
  ./scripts/github_search.sh repos "kubernetes gateway" > gh.json &
  ./scripts/stackoverflow_search.sh "kubernetes gateway" 10 > so.txt &
}
wait
```

## 扩展和定制

### 添加新的搜索源

创建自己的搜索脚本：

```bash
#!/bin/bash
# custom_search.sh - 自定义搜索源

QUERY="$1"

# 例如：搜索 arXiv 论文
curl -s "http://export.arxiv.org/api/query?search_query=all:$QUERY&max_results=10" | \
  grep -oP '<title>\K[^<]+' | tail -n +2
```

### 修改评分算法

编辑 `scripts/authority_scorer.py`，调整权重：

```python
# 例如：提高时效性权重
def calculate_total_score(url, date_str=None, content_type='guide', stars=0):
    source_score = score_source_authority(url)
    time_score = score_timeliness(date_str) * 1.5  # 提高权重
    # ...
```

## 总结

**常用命令速查**:

```bash
# GitHub 搜索
./scripts/github_search.sh repos "topic" --limit 10
./scripts/github_search.sh code "keyword" --repo owner/repo
./scripts/github_search.sh issues "bug" --repo owner/repo

# Web 搜索
./scripts/web_search.sh "site:official.com keyword" 10

# Stack Overflow
./scripts/stackoverflow_search.sh "question" 5 tag

# 评分
python3 scripts/authority_scorer.py --url "..." --type "..."

# 检查链接
python3 scripts/update_research.py research/file.md
```

遇到问题时，先检查工具依赖是否安装完整（`gh`, `curl`, `jq`, Python 3）。
