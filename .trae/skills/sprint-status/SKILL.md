---
name: sprint-status
description: "快速 Sprint 状态检查。读取当前 Sprint 计划，扫描故事文件中的状态标记，生成包含燃尽评估和新兴风险的简洁进度快照。可在 Sprint 期间随时运行以快速了解情况。当用户询问'冲刺进度如何'、'sprint 更新'、'显示冲刺进度'时使用。"
argument-hint: "[冲刺编号 或 留空表示当前冲刺]"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: haiku
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Sprint 状态

这是一个快速情况感知检查，不是 Sprint 回顾。它读取当前 Sprint 计划和故事文件，扫描状态标记，生成 30 行以内的简洁快照。如需详细 Sprint 管理，请使用 `/sprint-plan update` 或 `/milestone-review`。

**此 Skill 为只读。** 它不提议任何更改，不请求写入文件，最多只给出一个具体建议。

---

## 1. 查找 Sprint

**参数:** `$ARGUMENTS[0]`（留空 = 使用当前 Sprint）

- 如果提供了参数（例如 `/sprint-status 3`），在 `production/sprints/` 中搜索匹配 `sprint-03.md`、`sprint-3.md` 或类似名称的文件。报告找到的文件。
- 如果未提供参数，查找 `production/sprints/` 中最近修改的文件，将其视为当前 Sprint。
- 如果 `production/sprints/` 不存在或为空，报告："未找到 Sprint 文件。使用 `/sprint-plan new` 开启一个 Sprint。"然后停止。

完整读取 Sprint 文件。提取：
- Sprint 编号和目标
- 开始日期和结束日期
- 所有故事或任务条目及其优先级（Must Have / Should Have / Nice to Have）、负责人和估算

---

## 2. 计算剩余天数

使用今天的日期和 Sprint 文件中的 Sprint 结束日期，计算：
- Sprint 总天数（结束日期减去开始日期）
- 已过天数
- 剩余天数
- 已消耗时间百分比

如果 Sprint 文件不包含明确日期，注明"Sprint 日期未找到 — 跳过燃尽评估。"

---

## 3. 扫描故事状态

**首先：检查 `production/sprint-status.yaml`。**

如果它存在，直接读取——它是权威的数据来源。从 `status` 字段中提取每个故事的状态。无需扫描 Markdown。使用其 `sprint`、`goal`、`start`、`end` 字段而非重新解析 Sprint 计划。

**如果 `sprint-status.yaml` 不存在**（旧版 Sprint 或首次设置），回退到 Markdown 扫描：

1. 如果条目引用了故事文件路径，检查该文件是否存在。读取文件并扫描状态标记：DONE、COMPLETE、IN PROGRESS、BLOCKED、NOT STARTED（不区分大小写）。
2. 如果条目没有文件路径（Sprint 计划中的内联任务），扫描 Sprint 计划本身以查找该条目旁边的状态标记。
3. 如果未找到状态标记，归类为 NOT STARTED。
4. 如果引用了文件但不存在，归类为 MISSING 并注明。

使用回退方案时，在输出底部添加注释："⚠ 未找到 `sprint-status.yaml` — 状态从 Markdown 推断。运行 `/sprint-plan update` 生成一个。"

可选（仅限快速检查——不要做深度扫描）：在 `src/` 中 grep 匹配故事系统 slug 的目录或文件名，以检查实现证据。这仅是提示，不是确定状态。

### 过期故事检测

收集所有故事的状态后，检查每个 IN PROGRESS 故事是否过期：

- 对于每个有引用文件的故事，读取文件并查找 frontmatter 或头部中的 `Last Updated:` 字段（例如 `Last Updated: 2026-04-01` 或 `updated: 2026-04-01`）。接受任何合理的日期字段名：`Last Updated`、`Updated`、`last-updated`、`updated_at`。
- 使用今天的日期计算自该日期以来的天数。
- 如果日期超过 4 天，将该故事标记为 **STALE**。（4 天阈值考虑了周末——上周五最后更新的故事在周三之前不会显示为过期。）
- 如果故事文件中未找到日期字段，注明"无时间戳 — 无法检查是否过期。"
- 如果故事没有引用文件（内联任务），注明"内联任务 — 无法检查是否过期。"

STALE 故事包含在输出表中，并归入"需要关注"部分（参见第 5 阶段输出格式）。

**过期故事升级**：如果有任何 IN PROGRESS 故事被标记为 STALE（4 天以上无进展），燃尽判定至少升级为 **At Risk**——即使完成百分比在正常的 On Track 范围内。记录此升级原因："At Risk — [N] 个故事 [N] 天无进展。"

---

## 4. 燃尽评估

计算：
- 已完成任务（DONE 或 COMPLETE）
- 进行中任务（IN PROGRESS）
- 被阻塞任务（BLOCKED）
- 未开始任务（NOT STARTED 或 MISSING）
- 完成百分比：(已完成 / 总数) * 100

通过比较完成百分比与时间消耗百分比来评估燃尽：

- **On Track**：完成百分比在时间消耗百分比的 10 个百分点以内或领先
- **At Risk**：完成百分比落后时间消耗百分比 10-25 个百分点
- **Behind**：完成百分比落后时间消耗百分比超过 25 个百分点

如果日期不可用，跳过燃尽评估并报告"On Track / At Risk / Behind：未知 — 未找到 Sprint 日期。"

---

## 5. 输出

保持输出简洁。故事状态表是必需的——不要截断它。目标在 50 行以内；如果未发现值得注意的内容，省略新兴风险部分。使用以下格式：

```markdown
## Sprint [N] 状态 — [今天的日期]
**Sprint 目标**：[来自 Sprint 计划]
**剩余天数**：[N] / [总数]（[% 时间消耗]）

### 进度：[已完成/总数] 任务（[%]）

| 故事 / 任务          | 优先级     | 状态         | 负责人    | 阻塞原因         |
|----------------------|------------|-------------|-----------|------------------|
| [标题]               | Must Have  | DONE        | [负责人]  |                  |
| [标题]               | Must Have  | IN PROGRESS | [负责人]  |                  |
| [标题]               | Must Have  | BLOCKED     | [负责人]  | [简要原因]       |
| [标题]               | Should Have| NOT STARTED | [负责人]  |                  |

### 需要关注
| 故事 / 任务          | 状态         | 最后更新        | 过期天数    | 备注                    |
|----------------------|-------------|----------------|------------|-------------------------|
| [标题]               | IN PROGRESS | [日期或 N/A]   | [N 天]     | [STALE / 无时间戳 — 无法检查是否过期 / 内联任务 — 无法检查是否过期] |

*（如果没有 IN PROGRESS 故事过期或存在时间戳问题，则完全省略此部分。）*

### 燃尽：[On Track / At Risk / Behind]
[1-2 句话。如果 behind：哪些 Must Have 存在风险。如果 on track：确认并注明团队可以拉入的任何 Should Have。]

### 存在风险的 Must-Have
[列出剩余 Sprint 时间不足 40% 时处于 BLOCKED 或 NOT STARTED 状态的任何 Must Have 故事。如果没有，写"无。"]

### 新兴风险
[从故事扫描中可见的任何风险：丢失文件、级联阻塞、无负责人的故事。如果没有，写"未发现。"]

### 建议
[一个具体行动，或"Sprint 进度正常 — 无需操作。"]
```

---

## 6. 快速升级规则

在输出之前应用这些规则，如果触发，将标志放在输出的**顶部**（状态表上方）：

**严重标志** — 如果 Must Have 故事处于 BLOCKED 或 NOT STARTED 状态且 Sprint 时间剩余不到 40%：

```
SPRINT 存在风险：[N] 个 Must Have 故事未完成，Sprint 剩余 [X]% 时间。建议使用 `/sprint-plan update` 重新规划。
```

**完成标志** — 如果所有 Must Have 故事都是 DONE：

```
所有 Must Have 已完成。团队可以从 Should Have 待办列表中拉取。
```

**缺失故事标志** — 如果有任何引用的故事文件不存在：

```
注意：Sprint 计划中引用的 [N] 个故事文件丢失。运行 `/story-readiness sprint` 验证故事文件覆盖率。
```

---

## 协作协议

此 Skill 为只读。它报告从磁盘文件观察到的实际情况。

- 它不更新 Sprint 计划
- 它不更改故事状态
- 它不建议削减范围（这是 `/sprint-plan update` 的职责）
- 它每次运行最多给出一个建议

如需特定故事的更多详情，用户可以阅读故事文件本身或运行 `/story-readiness [path]`。

如需 Sprint 重新规划，使用 `/sprint-plan update`。
如需 Sprint 结束回顾，使用 `/retrospective`。
