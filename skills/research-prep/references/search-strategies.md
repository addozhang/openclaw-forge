# 搜索策略详解

如何高效地使用 CLI 工具收集一手技术资料。

## 搜索顺序建议

按优先级执行搜索，避免信息过载：

### 第一轮：官方资源（必须）

1. **官方文档网站**
   ```bash
   # 限定官方域名搜索
   ./scripts/web_search.sh "site:kubernetes.io gateway api" 10
   ./scripts/web_search.sh "site:golang.org context package" 10
   ```

2. **官方 GitHub 仓库**
   ```bash
   # 搜索官方仓库
   ./scripts/github_search.sh repos "kubernetes gateway" --limit 5
   
   # 获取官方 README
   ./scripts/github_search.sh readme kubernetes/gateway-api
   ```

### 第二轮：代码示例（推荐）

3. **真实项目代码**
   ```bash
   # 搜索代码示例
   ./scripts/github_search.sh code "Gateway API" --repo kubernetes/gateway-api
   
   # 跨仓库代码搜索
   ./scripts/github_search.sh code "import gateway" --language go
   ```

4. **高星标项目**
   ```bash
   # 找知名项目的实现
   ./scripts/github_search.sh repos "service mesh" --limit 10 --sort stars
   ```

### 第三轮：技术讨论（可选）

5. **GitHub Issues/PRs**
   ```bash
   # 已关闭的 bug（学习坑点）
   ./scripts/github_search.sh issues "bug gateway" --repo kubernetes/gateway-api --state closed
   
   # 功能请求（了解演进方向）
   ./scripts/github_search.sh issues "enhancement" --repo istio/istio --state open
   ```

6. **Stack Overflow**
   ```bash
   # 实战问题
   ./scripts/stackoverflow_search.sh "kubernetes gateway timeout" 10 kubernetes
   ```

## 关键词策略

### 基础关键词

针对不同目标使用不同关键词：

| 目标 | 关键词模式 | 示例 |
|------|-----------|------|
| 概念理解 | `what is` `introduction` `overview` | "what is kubernetes gateway api" |
| 快速上手 | `getting started` `tutorial` `quickstart` | "gateway api getting started" |
| 深入原理 | `architecture` `design` `internals` | "gateway api design proposal" |
| 实战应用 | `example` `how to` `guide` | "how to configure gateway timeout" |
| 问题排查 | `troubleshooting` `debug` `error` | "gateway api connection refused" |
| 最佳实践 | `best practice` `production` `tips` | "gateway api production best practices" |

### 组合关键词

使用逻辑组合提高精确度：

```bash
# AND（空格默认）
./scripts/web_search.sh "kubernetes gateway tls"

# 排除不想要的
./scripts/web_search.sh "gateway api -nginx -traefik"  # 仅限官方实现

# 精确匹配（引号）
./scripts/web_search.sh '"gateway api" spec'
```

### 限定搜索范围

```bash
# 限定文件类型
./scripts/web_search.sh "gateway api filetype:pdf"

# 限定时间范围（DuckDuckGo 支持）
./scripts/web_search.sh "kubernetes 1.28 after:2024-01-01"

# 限定域名
./scripts/web_search.sh "site:kubernetes.io OR site:github.com/kubernetes gateway"
```

## GitHub 高级搜索技巧

### 仓库搜索

```bash
# 按主题过滤
./scripts/github_search.sh repos "topic:service-mesh topic:kubernetes" --limit 10

# 按语言过滤
./scripts/github_search.sh repos "gateway language:go" --limit 10

# 按星标和更新时间
./scripts/github_search.sh repos "api gateway stars:>1000 pushed:>2024-01-01"
```

### 代码搜索

```bash
# 限定文件路径
./scripts/github_search.sh code "Gateway path:examples/ language:yaml"

# 限定文件名
./scripts/github_search.sh code "apiVersion filename:gateway.yaml"

# 搜索函数定义
./scripts/github_search.sh code "func NewGateway language:go"
```

### Issues/PR 搜索

```bash
# 按标签过滤
./scripts/github_search.sh issues "label:bug label:priority/high" --repo kubernetes/kubernetes

# 按状态过滤
./scripts/github_search.sh issues "is:closed reason:completed gateway" --repo istio/istio

# 按作者过滤（找核心维护者的回答）
./scripts/github_search.sh issues "author:kubernetes-bot gateway"

# 按互动数
./scripts/github_search.sh issues "comments:>10 gateway api" --repo kubernetes/kubernetes
```

## Stack Overflow 策略

### 找高质量答案

```bash
# 高票问题
./scripts/stackoverflow_search.sh "kubernetes ingress vs gateway" 5

# 带官方标签
./scripts/stackoverflow_search.sh "timeout" 10 kubernetes

# 组合多个标签（修改脚本支持）
# 例如：kubernetes + networking + gateway-api
```

### 识别权威答案

Stack Overflow 结果中注意：
- ✅ 绿色勾（已采纳）
- ✅ 高评分（Score > 10）
- ✅ 回答者声望（Reputation > 1000）
- ✅ 代码示例完整

## 过滤与去重策略

### 自动过滤

收集资料后，使用 `authority_scorer.py` 自动评分：

```bash
# 评估每个链接
for url in $(cat urls.txt); do
    python3 scripts/authority_scorer.py --url "$url"
done | sort -t':' -k2 -rn  # 按分数排序
```

### 手动去重

常见重复情况：
1. **相同内容不同 URL**：保留官方域名
2. **新旧版本文档**：保留最新版本，标注旧版本号
3. **转载文章**：保留原始来源

### 质量筛选标准

**必须包含**（⭐⭐⭐⭐+）：
- 官方文档
- 官方 GitHub 仓库/README
- RFC/规范文档

**推荐包含**（⭐⭐⭐+）：
- 官方博客
- 知名项目示例
- 高票 Stack Overflow

**可选包含**（⭐⭐+）：
- 技术大厂博客
- 有代码示例的教程

**避免**（⭐-）：
- 营销软文
- 过时内容（>2年且无版本标注）
- 明显错误的内容

## 特定场景策略

### 场景 1：全新技术研究

目标：快速建立全局认知

```bash
# 1. 官方概览
./scripts/web_search.sh "site:项目官网 overview" 5

# 2. 官方 README
./scripts/github_search.sh readme 组织/项目

# 3. Getting Started
./scripts/web_search.sh "site:项目官网 getting started" 3

# 4. 设计文档
./scripts/github_search.sh issues "design proposal" --repo 组织/项目
```

### 场景 2：对比分析

目标：收集多个技术的权威资料进行对比

```bash
# 分别搜索每个技术
for tech in "技术A" "技术B" "技术C"; do
    echo "=== $tech ==="
    ./scripts/web_search.sh "site:官网 $tech vs" 5
    ./scripts/stackoverflow_search.sh "$tech comparison" 5
done

# 专门找对比文章
./scripts/web_search.sh "技术A vs 技术B official" 10
```

### 场景 3：问题排查

目标：找到问题根因和解决方案

```bash
# 1. 搜索错误信息
./scripts/web_search.sh "\"exact error message\""

# 2. GitHub issues
./scripts/github_search.sh issues "exact error message" --repo 相关项目

# 3. Stack Overflow
./scripts/stackoverflow_search.sh "error message" 10 相关标签

# 4. 查看 changelog（可能是已知 bug）
./scripts/github_search.sh code "CHANGELOG path:/" --repo 组织/项目
```

### 场景 4：最佳实践

目标：收集生产环境经验

```bash
# 官方最佳实践
./scripts/web_search.sh "site:kubernetes.io best practices production" 10

# 大厂技术博客
./scripts/web_search.sh "kubernetes production site:cloud.google.com OR site:aws.amazon.com" 10

# 高票经验分享
./scripts/stackoverflow_search.sh "production tips" 5 kubernetes
```

## 效率提升技巧

### 1. 批量搜索脚本

创建一个任务列表，批量执行：

```bash
# tasks.txt
repos kubernetes gateway
web site:kubernetes.io gateway api
stackoverflow kubernetes gateway 5
```

### 2. 结果缓存

保存搜索结果避免重复请求：

```bash
# 缓存 GitHub 搜索结果
./scripts/github_search.sh repos "kubernetes" > cache/repos-kubernetes.json
```

### 3. 并行搜索

对于独立的搜索任务，可以并行执行：

```bash
# 并行搜索多个来源
{
    ./scripts/web_search.sh "kubernetes gateway" > web-results.txt &
    ./scripts/github_search.sh repos "kubernetes gateway" > gh-results.json &
    ./scripts/stackoverflow_search.sh "kubernetes gateway" 10 > so-results.txt &
}
wait
```

## 常见陷阱

### 陷阱 1：过度依赖二手资料

❌ 搜索 "kubernetes gateway tutorial"（大量教程博客）  
✅ 搜索 "site:kubernetes.io gateway" + GitHub 官方仓库

### 陷阱 2：忽略版本信息

❌ 直接使用搜索到的第一篇文章  
✅ 检查文章日期，确认技术版本

### 陷阱 3：信息过载

❌ 收集 100+ 篇资料  
✅ 严格过滤，保留 20-30 篇高权威资料

### 陷阱 4：缺乏验证

❌ 相信所有搜索结果  
✅ 交叉验证，以官方文档为准

## 总结

**高效搜索的黄金法则**：
1. **官方优先** - 从官方文档和仓库开始
2. **分层收集** - 先概览，再深入，最后补充
3. **质量over数量** - 20篇精选 > 100篇泛泛
4. **验证来源** - 使用 authority_scorer.py 评分
5. **标注版本** - 记录技术版本和文档日期
6. **实战导向** - 优先选择有代码示例的资料

遵循这些策略，可以在 30 分钟内完成一个技术主题的全面资料收集。
