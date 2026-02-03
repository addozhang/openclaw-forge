---
name: research-prep
description: Collect and organize first-hand research materials for technical writing. Use when the user wants to gather official documentation, source code examples, GitHub issues, or original technical resources before writing. Outputs structured research files ready for the writing phase.
---

# Research Prep - 写作素材收集整理

专注于博客写作前的研究阶段，收集一手资料并整理成结构化素材库。

## 核心能力

### 1. 多源搜索一手资料
- **官方文档**: Web 搜索限定官方域名（site: 语法）
- **源码示例**: GitHub CLI (`gh`) 搜索真实项目代码、README
- **技术讨论**: GitHub Issues、Discussions、Pull Requests
- **Stack Overflow**: 高票问答和实战问题

### 2. 智能过滤与分类
- 识别一手资料 vs 二手资料
- 按权威性和相关性排序
- 自动去重和归类
- 提取关键信息摘要

### 3. 结构化输出
生成标准格式的研究素材文件，保存到 `~/my-obsidian-vault/个人/草稿/` 目录

## 使用流程

### 基本工作流

```
用户输入主题 → 多源搜索 → 过滤分类 → 提取关键信息 → 生成素材文件
```

### 快速开始

**场景1: 全新主题研究**
```
帮我收集 Kubernetes Gateway API 的资料
```

AI会：
1. 使用 `scripts/github_search.sh` 搜索 Kubernetes Gateway API 相关仓库
2. 使用 `scripts/web_search.sh` 查找官方文档（限定 kubernetes.io 域名）
3. 使用 `scripts/github_search.sh` 搜索相关 issues 和代码示例
4. 使用 `scripts/stackoverflow_search.sh` 查找高票问答
5. 过滤和分类资料（使用 `authority_scorer.py` 评分）
6. 生成结构化素材文件到 `~/my-obsidian-vault/个人/草稿/k8s-gateway-api.md`

**场景2: 深入特定方面**
```
继续收集 Gateway API 的安全实践相关资料
```

AI会：
1. 读取现有素材文件
2. 针对"安全实践"深入搜索
3. 追加新资料到现有文件

**场景3: 更新过期资料**
```
更新这篇素材中的官方文档链接
```

AI会：
1. 检查素材文件中的链接有效性
2. 搜索最新版本的文档
3. 更新失效链接

## 素材文件结构

每个研究素材文件遵循统一格式：

```markdown
# 研究素材：{主题}

**创建时间**: YYYY-MM-DD  
**最后更新**: YYYY-MM-DD  
**状态**: 收集中 | 已完成 | 已使用  
**相关博客**: [链接] (如果已写成博客)

---

## 📚 官方文档

### {文档标题}
- **来源**: {官方网站}
- **链接**: {URL}
- **版本**: {如适用}
- **关键要点**:
  - 要点1
  - 要点2

## 💻 源码示例

### {项目名称}
- **仓库**: {GitHub URL}
- **相关文件**: {文件路径}
- **代码片段**:
```language
// 关键代码
```
- **说明**: {为什么这个示例有价值}

## 💬 技术讨论

### {Issue/Discussion 标题}
- **类型**: Issue | Discussion | PR
- **链接**: {GitHub URL}
- **状态**: Open | Closed | Merged
- **核心观点**:
  - 观点1
  - 观点2

## 📝 官方博客/公告

### {文章标题}
- **来源**: {官方博客}
- **链接**: {URL}
- **发布日期**: YYYY-MM-DD
- **摘要**: {简短总结}

## 🔑 概念卡片

### {术语/概念}
- **定义**: {清晰定义}
- **来源**: {权威来源}
- **相关概念**: {关联术语}
- **使用场景**: {何时使用}

## 🎯 写作建议

基于收集的资料，建议的写作角度：
- 角度1
- 角度2

## 🔗 参考资源

其他有价值的资源：
- [资源名称](URL) - 简短说明

---

## 📊 素材统计

- 官方文档: X 篇
- 源码示例: X 个
- 技术讨论: X 条
- 官方博客: X 篇
- 概念卡片: X 个
```

## 搜索策略

### 官方文档搜索 (Context7)

**目标**: 获取最权威的技术说明

```
搜索模式:
- "{技术名称} official documentation"
- "{技术名称} getting started"
- "{技术名称} API reference"
- "{技术名称} best practices"
```

**筛选标准**:
- ✅ 官方文档网站
- ✅ 版本化文档
- ❌ 第三方教程
- ❌ 博客文章

### 源码搜索 (GitHub)

**目标**: 找到真实的生产级代码示例

```
搜索策略:
- 仓库搜索: "topic:{技术名称} stars:>100"
- 代码搜索: "{关键API} language:{语言} path:{路径模式}"
- Issues搜索: "is:issue label:{标签} state:closed"
```

**筛选标准**:
- ✅ 官方仓库
- ✅ 知名开源项目
- ✅ 完整可运行示例
- ❌ 未维护的旧项目
- ❌ Demo/测试代码

### 官方博客搜索 (Brave Search)

**目标**: 获取官方的最佳实践和案例研究

```
搜索策略:
- "site:官方域名 {技术名称} {主题}"
- "{技术名称} official blog {关键词}"
- "{技术名称} announcement {版本号}"
```

**筛选标准**:
- ✅ 官方技术博客
- ✅ 官方更新公告
- ✅ 官方案例研究
- ❌ 第三方转载
- ❌ 营销软文

## 资料质量评估

### 一手资料识别

**一手资料**（优先）:
- 官方文档、规范、RFC
- 源代码、配置文件
- 官方博客、公告
- 官方 GitHub Issues/PRs
- 官方示例项目

**二手资料**（谨慎使用）:
- 技术博客（非官方）
- 教程、课程
- Stack Overflow
- 技术媒体文章

### 权威性评分

参考 [`scripts/authority_scorer.py`](scripts/authority_scorer.py) 自动评估资料权威性。

评分维度：
- 来源官方性 (40%)
- 内容时效性 (30%)
- 技术深度 (20%)
- 社区认可度 (10%)

## 素材管理

### 文件命名规范

文件保存在 Obsidian 草稿目录：`~/my-obsidian-vault/个人/草稿/`

命名格式：`{topic-slug}.md` 或 `YYYY-MM-DD-{topic-slug}.md`

示例:
- `~/my-obsidian-vault/个人/草稿/k8s-gateway-api.md`
- `~/my-obsidian-vault/个人/草稿/2026-02-03-grpc-vs-rest.md`

### 状态标记

素材文件头部的状态字段：

- **收集中**: 正在添加资料
- **已完成**: 资料收集完成，待写作
- **已使用**: 已基于此素材写成博客
- **已归档**: 资料过期或不再使用

### 更新策略

参考 [`scripts/update_research.py`](scripts/update_research.py) 自动更新素材文件。

```bash
# 检查链接有效性
python3 scripts/update_research.py ~/my-obsidian-vault/个人/草稿/topic.md
```

定期检查：
- 链接有效性（自动识别 404、重定向）
- 文档版本更新
- 新增官方资源

## CLI 工具使用

所有搜索功能通过命令行工具实现，无需 MCP servers。

### GitHub 搜索（`scripts/github_search.sh`）

```bash
# 搜索仓库
./scripts/github_search.sh repos "kubernetes gateway" --limit 10

# 搜索代码
./scripts/github_search.sh code "Gateway API" --repo kubernetes/kubernetes

# 搜索 Issues
./scripts/github_search.sh issues "bug" --repo istio/istio --state closed

# 获取 README
./scripts/github_search.sh readme kubernetes/gateway-api
```

**输出**: JSON 格式，包含仓库信息、星标数、更新时间等。

### Web 搜索（`scripts/web_search.sh`）

```bash
# 搜索网页（DuckDuckGo）
./scripts/web_search.sh "kubernetes gateway api official" 10
```

**输出**: URL 列表（每行一个）。

**技巧**: 使用 `site:` 限定官方域名：
```bash
./scripts/web_search.sh "site:kubernetes.io gateway api"
```

### Stack Overflow 搜索（`scripts/stackoverflow_search.sh`）

```bash
# 搜索问题
./scripts/stackoverflow_search.sh "kubernetes gateway" 5

# 带标签搜索
./scripts/stackoverflow_search.sh "gateway api" 5 kubernetes
```

**输出**: 问题标题、URL、评分、回答数、标签。

### 权威性评分（`scripts/authority_scorer.py`）

```bash
# 评估单个链接
python3 scripts/authority_scorer.py --url "https://kubernetes.io/docs/concepts/services-networking/gateway/" --date "2025-12-15" --type "api-reference"
```

**输出**: 总分（0-100）+ 评级星标 + 详细分数。

## 工作模式

### 模式1: 快速收集

适用于新主题的初步研究。

1. 广泛搜索各个来源
2. 快速过滤明显不相关的资料
3. 生成初版素材文件
4. 标记状态为"收集中"

### 模式2: 深度挖掘

适用于特定方面的深入研究。

1. 基于已有素材文件
2. 针对特定子主题深入搜索
3. 追加高质量资料
4. 完善概念卡片

### 模式3: 质量提升

适用于准备写作前的最后整理。

1. 检查所有链接有效性
2. 补充缺失的关键资料
3. 完善摘要和要点
4. 添加写作建议
5. 标记状态为"已完成"

## 与 Writing Skill 配合

研究素材文件是 Writing Skill 的输入：

**Research Prep 输出** → **Writing Skill 输入**

```
~/my-obsidian-vault/个人/草稿/topic.md
    ↓
Writing Skill 读取素材
    ↓
生成大纲（基于一手资料）
    ↓
完善文章内容
```

**协作流程**:

1. 用户: "收集 X 技术的资料"
2. Research Prep: 生成 `~/my-obsidian-vault/个人/草稿/x.md`
3. 用户: "基于这个素材写博客"
4. Writing Skill: 读取素材 → 生成大纲 → 完成文章

## 最佳实践

### 收集阶段

1. **广度优先**: 先覆盖主要来源，再深入细节
2. **权威优先**: 官方文档 > 知名项目 > 技术博客
3. **版本注意**: 标记文档/代码的版本信息
4. **及时归纳**: 搜索时同步整理关键要点

### 整理阶段

1. **结构清晰**: 严格遵循素材文件模板
2. **摘要精炼**: 每条资料附简短摘要
3. **去重合并**: 相似内容合并，保留最权威的
4. **标记来源**: 每条资料必须有清晰来源链接

### 质量控制

1. **一手为主**: 80%以上应为一手资料
2. **时效性**: 优先选择最新版本的资料
3. **可验证**: 所有链接必须可访问
4. **相关性**: 每条资料都应与主题直接相关

## 常见问题

**Q: 如何判断是一手还是二手资料？**
A: 一手资料来自技术的创造者/维护者；二手资料是他人的转述或解读。

**Q: 搜索不到官方文档怎么办？**
A: 先用 Web Search 限定官方域名（`site:官方域名`），再尝试直接访问项目官网。

**Q: 资料太多怎么办？**
A: 按权威性评分排序，只保留前20-30条最有价值的。

**Q: 如何处理版本不一致？**
A: 优先使用最新稳定版本的资料，旧版本标注版本号供参考。

**Q: 素材文件何时算"完成"？**
A: 当包含足够的官方文档、3-5个代码示例、重要技术讨论，且概念卡片完整时。

## 技巧提示

- 💡 说 "收集 X 技术的资料" 启动完整研究流程
- 💡 说 "深入收集 X 方面的资料" 针对性补充
- 💡 说 "检查这个素材文件的链接" 维护资料质量
- 💡 说 "基于这个素材写博客" 无缝切换到 Writing Skill
- 💡 定期运行 `scripts/update_research.py` 保持资料新鲜度

## 参考资料

- [权威性评分算法](references/authority-scoring.md) - 资料评分标准和算法
- [搜索策略详解](references/search-strategies.md) - 高效搜索技巧和策略
- [CLI 工具使用指南](references/cli-tools-usage.md) - 完整的命令行工具使用说明
