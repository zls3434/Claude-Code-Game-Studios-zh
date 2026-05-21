---
name: create-epics
description: "将系统索引中的所有 MVP 或垂直切片系统转换为 Epic，分解为故事，并与架构决策对齐。为生产做好准备。"
argument-hint: ""
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: opus
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Create Epics

将设计映射到可执行工作。读取系统索引中的所有已批准或已设计的系统，检查 ADR、控制清单和实体注册表，向用户提议 Epic 结构，并为每个 MVP 或垂直切片系统生成故事。

**前置条件：**
- 至少一个已批准的 GDD 存在于 `design/gdd/` 中
- `design/gdd/systems-index.md` 存在
- `docs/architecture/tr-registry.yaml` 存在（通过 `/architecture-review` 创建）
- **至少一个 ADR 必须处于 Accepted 状态**（在创建故事之前）

**输出：**
- `production/epics/EPIC-[slug].md` —— 一个 Epic 索引文件列出所有生成的 Epic 链接
- `production/epics/[epic-slug]/*.md` —— 每个 Epic 的单个故事文件
- `production/sprint-status.yaml` —— 在阶段 5 生成（如果用户批准）

---

## 阶段 1：收集所有输入

### 1a —— 检查前置条件

读取 `design/gdd/systems-index.md`。如果缺失：错误退出 —— "首先运行 `/map-systems`。"

从索引中，提取所有状态为 **Approved** 或 **Designed** 且优先级为 **MVP** 或 **垂直切片** 的系统列表。按依赖顺序排序（无依赖项的先）。如果该行没有优先级列，默认假定为 MVP。

如果索引包含 `Progress Tracker` 部分，提取以下计数：
- 状态列中所有 **Approved** 或 **Designed** 的系统

Glob `docs/architecture/adr-*.md`。读取每个 ADR 以收集：
- ADR ID、标题、状态（Proposed / Accepted / Superseded）
- `GDD Requirements Addressed` 列表（TR-ID 引用）
- `Implementation Guidelines` 部分

验证：是否至少有一个 ADR 处于 Accepted 状态？如果没有：警告 —— "尚未有 ADR 处于 Accepted 状态。故事在没有 Accepted ADR 的情况下无法正确生成——它们将缺少 `ADR Governing Implementation` 指南。先运行 `/architecture-decision` 至少接受一个 ADR，然后再运行 `/create-epics`。"

读取 `docs/architecture/control-manifest.md`（如果存在——通过 `/create-architecture` 创建）。如果缺失：警告 —— "控制清单未找到。故事将在没有层级特定规则的情况下生成——在 `/dev-story` 期间清单合规性将无法检查。"

读取 `docs/architecture/tr-registry.yaml`（如果缺失则错误退出）：
- 将 TR-ID 映射到需求文本和来源 GDD
- 这些将被嵌入到故事文件的 `TR-ID` 字段中

### 1b —— 为每个系统构建上下文包

对于每个范围内的系统，收集：

1. 来自系统索引的其 GDD 文件路径
2. 其 GDD 完整的 `## Acceptance Criteria` 部分（必需——故事从此派生）
3. 任何 `## Tuning Knobs` 部分（如果存在——用于 Config/Data 故事）
4. 任何 `## Dependencies` 部分（故事顺序依赖）
5. 任何 `## UI Requirements` 或 `## Visual/Audio Requirements` 部分（用于 UI 或 Visual/Feel 故事识别）
6. 控制清单中该层级的任何专门实现指南（如果清单存在）

对于每个系统，读取其 GDD 摘要部分（`## Overview`），并 Grep 搜索：
- `## Acceptance Criteria`（寻找 Given-When-Then 条目）
- `## Dependencies`
- `## Tuning Knobs`
- `## UI Requirements`
- `## Visual/Audio Requirements`

**关键：** 故事的验收标准必须镜像 GDD 中的验收标准——在编写故事时不对 GDD 进行重新解释。

---

## 阶段 2：故事设计对话

仅对 MVP/垂直切片系统，引导用户设计故事结构。

**对于每个系统：** 检查其 GDD 的 `## Acceptance Criteria` 部分中的 Given-When-Then 条目数量：
- 如果仅有 1-2 条标准，建议 1 个故事文件，并注意它的名称
- 如果有 3-5 条标准，可能适合 1-2 个故事，并在对话中讨论
- 如果有 5+ 条标准，建议 2-3 个故事按依赖关系拆分

**对于每个系统，询问：**
1. "系统 [名称] 有 [N] 条验收标准。我建议 [X] 个故事：[名称/描述]。可以吗？"
2. "每个故事是否有逻辑上的测试文件？（Logic 故事必须有自动化测试，Visual/Feel 故事可以稍后手动验证。）"

**对于每个被确认为单独故事的故事，确定故事类型：**

| GDD 信号 | 故事类型 |
|----------|------------|
| GDD 中有核心规则/公式/状态转换 | Logic |
| GDD 中列出跨系统交互 | Integration |
| GDD 中有动画要求/手感目标 | Visual/Feel |
| GDD 中有 UI 或 HUD 要求 | UI |
| GDD 中有 1+ 个 Tuning Knobs/数据表 | Config/Data |

当一个系统有多种故事类型时，默认建议顺序为：
1. Logic 故事（核心——其他类型依赖于此）
2. Integration 故事（连接系统）
3. UI 故事（Logic + Integration 为 UI 提供数据）
4. Config/Data 故事（数据文件——可在任何时间完成）
5. Visual/Feel 故事（反馈层——Logic + UI 就绪后可调优）

使用 `AskUserQuestion` 让用户选择故事类型顺序：
- 标签页 "Story types" —— "系统 [名称] 有哪些类型的实现？"
  选项（`multiSelect: true`，以故事类型为标签，全部默认勾选）：
  `Logic` / `Integration` / `UI` / `Config/Data` / `Visual/Feel`

可单独取消选择任何类型（例如，如果系统没有 UI，取消选择）。依赖顺序仍然适用（Logic 排在第一）。

**验证已完成的故事：**

在得到用户对故事结构的确认后，Glob `production/epics/[epic-slug]/*.md` 查找可能已存在的任何故事文件（从之前 `/create-epics` 运行中）。如果发现任何现有故事有 `Status: Done` 或 `Status: Complete`：

1. 标记它们："[N] 个故事已存在并标记为 Done/Complete："
2. 呈现一个表格：`| 文件 | 状态 |`，每个文件一行
3. 使用 `AskUserQuestion` 询问是否应包含已有的故事（在最终输出中链接到它们，但不重新生成）。

如果用户回答 `No` —— 仅包含新故事或状态为非 Done/Complete 的故事。

---

## 阶段 3：生成故事文件

对于每个被确认为单独故事的故事：

### 3a —— 加载 ADR 上下文

**故事到 ADR 的映射**：每个故事文件在其 `Implementation Notes` 部分必须包含 `ADR Governing Implementation: [path]`。这是 `/dev-story` 用于加载相关 ADR 指南的指针。

映射规则不要求每个故事都唯一对应一个 ADR。多个故事可以共享同一个 ADR（当多个需求由同一个架构决策管理时），并且一个故事可以引用多个 ADR（当其涵盖同时在两个不同 ADR 中表达的需求时）。

**每个故事的实现上下文：**

1. 查找与每个 TR-ID 对应的相关 ADR。在 TR 注册表中 Grep 搜索 TR-ID 并记录负责治理的 ADR。
2. 对每个故事，收集：`ADR Governing Implementation: [路径]`，其中列出治理该故事需求的 ADR 文件。故事引用其 TR-ID 的所有 ADR。
3. 在每个 ADR 内，收集实现该故事所需的特定 Implementation Guidelines 部分和任何 ADR Dependencies。

**依赖关系设置：**
- 如果故事 A 的验收标准要求故事 B 的输出（"当库存系统发送 ItemCollected 事件..."）→ 故事 B 是上游
- 如果同一系统中故事 A 定义核心逻辑且故事 B 添加集成 → 故事 B 排在故事 A 之后，故事 A 排在故事 B 之前

将每个故事的 **Dependencies 字段** 填充为：此故事开始前必须完成的故事文件路径的逗号分隔列表。如果无依赖项，写入 `None`。

### 3b —— 使用模板编写故事

使用 `.claude/docs/templates/story.md`。

**对于每个故事文件：**
- **Status** → `Ready`（如果其所有 Dependencies 中列出的故事已完成）或 `Blocked`（如果任何依赖故事尚未 Done）
- **TR-ID** → 从注册表映射的 TR-ID（逗号分隔）
- **Layer** → 来自系统索引的层级
- **Manifest Version** → 控制清单头部 `Last Updated` 字段中的日期（`YYYY-MM-DD`）。如果控制清单不存在，写入 `N/A`。
- **Acceptance Criteria** → 镜像 GDD 验收标准。不重新措辞。每个 Given-When-Then 条目是子集中的一行。在 AC 之后添加一个 `Regression Risk` 部分，解释在此故事中修改的内容如果失败会破坏什么。格式：

  ```
  **回归风险**：[如果此故事失败，会破坏什么（例如，同一系统中的下游故事，标记为依赖它的故事）]
  ```

- **Test Evidence** → 如果故事为 Logic 或 Integration 类型：`tests/[unit|integration]/[system]_[feature]_test.[ext]`。如果故事为 Visual/Feel、UI 或 Config/Data 类型：`N/A — visual/feel story (or UI, Config/Data)`。
- **ADR Governing Implementation** → 治理此故事的 ADR 文件的逗号分隔列表
- **Implementation Notes** → 从 ADR Implementation Guidelines 部分提取
- **Out of Scope** → 明确禁止触及的内容：不相关的系统或层、不在故事 GDD 需求中的文件、其他故事范围内的文件、独立于故事类型的引擎或项目配置。

**故事命名规则：**
- 文件名遵循系统 slug，然后是故事类型或特性 slug：`[system]-[type]-[feature-slug].md`
- 故事标题简短描述性：例如，"服务定位器：场景注册"，于系统内部的顺序

仅将故事文件写入 `production/epics/[epic-slug]/` 目录。**在生成所有故事文件前不要询问写入审批**——阶段 6 一次性处理批量写入审批。

对于每个生成的故事，构建一个摘要行以供阶段 6 审批使用：
`| [title].md | [type] | [TR-IDs] | [ADR files] | [dependency story filenames] | Ready/Blocked |`

---

## 阶段 4：生成 Epic 索引

在生成所有故事后，创建 `production/epics/EPIC-[slug].md`：

```markdown
# Epic：[slug] 的故事

> **最后更新**：[日期]
> **Epic 状态**：[Planning / In Progress / Complete]
> **来源系统**：[来自系统索引的系统数]
> **生成的故事**：[计数]

## 故事列表

| # | 故事文件 | 标题 | 类型 | TR-ID | 状态 |
|---|----------|-------|------|-------|--------|
| 1 | [filename] | [title] | [type] | [TR-IDs] | [Ready / Blocked] |
...
```

如果正在进行多次 `/create-epics` 运行且 Epic 索引文件已存在：
- 读取它
- 在表格末尾追加新条目
- 更新 `Last Updated` 日期和故事计数
- 不要覆盖已有的故事条目

---

## 阶段 5：生成 Sprint 状态文件（带审批）

Present the summary after the batch write approval in Phase 6.

Generate `production/sprint-status.yaml` if it does not exist:

```yaml
# Sprint Status —— automatically generated by /create-epics
# Manual edits will be overwritten on next /create-epics run
updated: [date]
active_sprint: null
sprint_history: []
stories: []
```

1. Glob `production/sprint-status.yaml` 查看文件是否已存在。
2. **如果不存在**：在获得用户批准后使用 **Write** 工具创建。
3. **如果已存在**：读取现有文件，清空 `stories` 列表（保持 `active_sprint` 和 `sprint_history` 不变），然后用为当前生成的所有故事生成的新 `stories` 条目替换。追加故事时不要重复已有条目。

对于每个故事，默认设置为：`sprint: unassigned`、`status: ready` 和空故事点。`/sprint-plan` 将很快更新这些值。

---

## 阶段 6：批量写入审批

在阶段 3 生成所有故事文件后，一次性向用户呈现所有内容以进行写入审批。不要单独询问每个故事文件。

在对话中呈现摘要：

```
## 准备生成的 Epic

Epic：[slug]
系统数：[N]
总故事数：[N]

| 故事文件 | 类型 | TR-ID | ADR | 依赖项 | 状态 |
|----------|------|-------|-----|------------|--------|
[为每个故事使用阶段 3 的行]

追加 [N] 个故事到 production/epics/[slug]/。
追加到 EPIC-[slug].md 索引。
[如果 sprint-status.yaml 尚不存在，创建它。]
```

然后使用 `AskUserQuestion`：
- 提示语："我可以写入 [N] 个故事文件到 `production/epics/[slug]/` 并更新索引吗？"
- 选项：`[A] 是——写入所有 [N] 个故事和索引` / `[B] 先向我展示故事 [story-name] 的完整草稿` / `[C] 否`

如果用户拒绝：判定：**阻塞** —— 用户拒绝写入。在此停止。

---

## 阶段 7：结束

在写入后，呈现摘要：

> "Epic [slug] 已准备就绪：[N] 个故事已写入 `production/epics/[slug]/`。"
> "开始实现前，在每个故事上运行 `/story-readiness`。"

然后使用 `AskUserQuestion` 进入下一步：
- 提示语："Epic 已准备就绪。你想开始实现吗？"
- 选项：
  - `[A] 运行 /story-readiness [first-story] 验证故事准备就绪`（选择依赖项已就绪的第一个故事）
  - `[B] 运行 /create-epics 处理下一个系统组`
  - `[C] 运行 /sprint-plan 将故事分配到 Sprint`
  - `[D] 在此停止`

---

## 协作协议

- 不要假设故事结构——在生成之前向用户讨论每个系统的故事数量和类型
- ADR 治理是每个故事层面的——每个故事文件必须引用其管理层 ADR
- 故事验收标准必须镜像 GDD 验收标准——不重新措辞，不重新解释
- 自动序列化故事——依赖故事排在依赖项故事之后
- 生成不创建阻塞的故事——如果依赖项未完成将 Status 设为 Blocked
- 批量写入审批——阶段 6 一次性审批所有故事文件
