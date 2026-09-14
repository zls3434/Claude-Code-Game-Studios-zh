---
name: sprint-plan
description: "基于当前里程碑、已完成工作和可用产能，生成新的 Sprint 计划或更新已有计划。从生产文档和设计待办列表中提取上下文。"
argument-hint: "[new|update|status] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
context: |
  !ls production/sprints/ 2>/dev/null
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

## 第 0 阶段：解析参数

提取模式参数（`new`、`update` 或 `status`）并解析审查模式（一次，存储以供此次运行中的所有关卡生成使用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认 `lean`

完整检查模式见 `.claude/docs/director-gates.md`。

**审查模式检查**（在关卡运行之前）：
- 读取 `production/review-mode.txt`（如果存在）。使用该模式。
- 如果文件不存在且这是 `new` Sprint：使用 `AskUserQuestion`：
  - Prompt："未设置审查模式。你希望此 Sprint 采用哪种审查深度？"
  - Options：
    - `[A] full — 生成所有主管和牵头关卡`
    - `[B] lean — 跳过非阶段关卡的主管审查（推荐大多数 Sprint 使用）`
    - `[C] solo — 跳过所有关卡生成`
  - 选择后：将所选模式写入 `production/review-mode.txt`。提示："审查模式已设置为 [mode] 并保存至 production/review-mode.txt。"
- 如果文件不存在且这不是 `new` Sprint（例如更新已有 Sprint）：默认静默使用 `lean`。

---

## 第 1 阶段：收集上下文

1. **读取当前里程碑**：来自 `production/milestones/`。

2. **读取上一个 Sprint**（如有）：来自 `production/sprints/`，以了解速度和遗留项。

3. **扫描设计文档**：在 `design/gdd/` 中查找标记为可开始实现的功能。

4. **检查风险登记册**：位于 `production/risk-register/`。

---

## 第 2 阶段：生成输出

对于 `new`：

**生成 Sprint 计划**，遵循以下格式并呈现给用户。尚不询问写入 — 制作人可行性关卡（第 4 阶段）先运行，可能需要修改后再写入文件。

```markdown
# Sprint [N] — [开始日期] 至 [结束日期]

## Sprint 目标
[一句话描述此 Sprint 对里程碑的贡献]

## 产能
- 总天数：[X]
- 缓冲（20%）：[Y 天预留给计划外工作]
- 可用天数：[Z 天]

## 任务

### Must Have（关键路径）
| ID | 任务 | Agent/负责人 | 预估天数 | 依赖 | 验收标准 |
|----|------|-------------|-----------|-------------|-------------------|

### Should Have
| ID | 任务 | Agent/负责人 | 预估天数 | 依赖 | 验收标准 |
|----|------|-------------|-----------|-------------|-------------------|

### Nice to Have
| ID | 任务 | Agent/负责人 | 预估天数 | 依赖 | 验收标准 |
|----|------|-------------|-----------|-------------|-------------------|

## 来自上期 Sprint 的遗留项
| 任务 | 原因 | 新估算 |
|------|--------|-------------|

## 风险
| 风险 | 概率 | 影响 | 缓解措施 |
|------|------------|--------|------------|

## 外部因素依赖
- [列出任何外部依赖]

## 本 Sprint 完成的定义
- [ ] 所有 Must Have 任务已完成
- [ ] 所有任务通过验收标准
- [ ] QA 计划存在（`production/qa/qa-plan-sprint-[N].md`）
- [ ] 所有 Logic/Integration 故事有通过的单元/集成测试
- [ ] 冒烟检查通过（`/smoke-check sprint`）
- [ ] QA 签收报告：APPROVED 或 APPROVED WITH CONDITIONS（`/team-qa sprint`）
- [ ] 交付的功能中无 S1 或 S2 Bug
- [ ] 任何偏差的设计文档已更新
- [ ] 代码已审查并合并
```

对于 `update`：

**更新已有 Sprint 计划**：

1. 从 `production/sprints/` 读取最近的 Sprint 计划。
2. 呈现来自 `production/sprint-status.yaml` 的当前故事列表及其当前状态。
3. 询问用户要更改什么：新增、移除、重新排序或重新估算故事。使用 `AskUserQuestion` 收集变更。
4. 应用变更并重新呈现完整的修订后计划供审查。
5. 对修订后的计划重新运行制作人可行性关卡（第 4 阶段）。
6. 写入更新后的 Markdown 计划和 yaml（与 `new` 模式使用相同的审批方式）。

注意：`update` 模式不重置故事状态。已标记为 `in-progress` 或 `done` 的故事保持其状态。只有 `backlog` 和 `ready-for-dev` 的故事可以自由移除或重新排列。

对于 `status`：

**生成状态报告**：

```markdown
# Sprint [N] 状态 — [日期]

## 进度：[X/Y 任务完成]（[Z]%）

### 已完成
| 任务 | 完成者 | 备注 |
|------|-------------|-------|

### 进行中
| 任务 | 负责人 | 完成 % | 阻塞项 |
|------|-------|--------|----------|

### 未开始
| 任务 | 负责人 | 存在风险？ | 备注 |
|------|-------|----------|-------|

### 已阻塞
| 任务 | 阻塞项 | 阻塞项负责人 | 预期时间 |
|------|---------|-----------------|-----|

## 燃尽评估
[正常 / 落后 / 领先]
[如果落后：正在裁剪或延期什么]

## 新兴风险
- [本 Sprint 发现的任何新风险]
```

---

## 第 3 阶段：准备 Sprint 状态文件

生成新 Sprint 计划后，同时准备 `production/sprint-status.yaml` 内容。这是故事状态的机器可读真实来源 — 由 `/sprint-status`、`/story-done` 和 `/help` 读取，无需 Markdown 解析。

**尚不写入 yaml** — 将其保留在上下文中。制作人可行性关卡（第 4 阶段）可能会修改故事列表。两个文件将在第 4 阶段之后一次性写入审批。

格式：

```yaml
# 由 /sprint-plan 自动生成。由 /story-done 和 /dev-story 更新。
# 请勿手动编辑 — 使用 /story-done 更新故事状态。
#
# 状态值映射（yaml ↔ 故事文件 Status 字段）：
#   backlog        ↔  Not Started
#   ready-for-dev  ↔  Ready
#   in-progress    ↔  In Progress
#   review         ↔  In Review
#   done           ↔  Complete
#   blocked        ↔  Blocked

sprint: [N]
goal: "[Sprint 目标]"
start: "[YYYY-MM-DD]"
end: "[YYYY-MM-DD]"
generated: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"

stories:
  - id: "[epic-story，例如 1-1]"
    name: "[故事名称]"
    file: "[production/stories/path.md]"
    priority: must-have        # must-have | should-have | nice-to-have
    status: ready-for-dev      # backlog | ready-for-dev | in-progress | review | done | blocked
    owner: ""
    estimate_days: 0
    blocker: ""
    completed: ""
```

根据 Sprint 计划的任务表初始化每个故事：
- Must Have 任务 → `priority: must-have`，`status: ready-for-dev`
- Should Have 任务 → `priority: should-have`，`status: backlog`
- Nice to Have 任务 → `priority: nice-to-have`，`status: backlog`

对于 `update`：读取已有的 `sprint-status.yaml`，保留未变更故事的状态，添加新故事，移除被删除的故事。

---

## 第 4 阶段：制作人可行性关卡

**审查模式检查** — 在生成 PR-SPRINT 之前应用：
- `solo` → 跳过。注明："PR-SPRINT 已跳过 — Solo 模式。"继续到第 5 阶段（QA 计划关卡）。
- `lean` → 跳过（非 PHASE-GATE）。注明："PR-SPRINT 已跳过 — Lean 模式。"继续到第 5 阶段（QA 计划关卡）。
- `full` → 正常生成。

在最终确定 Sprint 计划之前，通过 Task 使用关卡 **PR-SPRINT**（`.claude/docs/director-gates.md`）生成 `producer`。

传递：建议的故事列表（标题、估算、依赖）、以小时/天为单位的团队总产能、来自上期 Sprint 的任何遗留项、里程碑约束和截止日期。

呈现制作人的评估。

如果 UNREALISTIC：修改故事选择（将故事延期至 Should Have 或 Nice to Have），在请求写入批准之前重新呈现更新后的计划。

如果 CONCERNS，使用 `AskUserQuestion`：
- Prompt："制作人对本 Sprint 计划标记了关切。你想如何继续？"
- Options：
  - `[A] 按计划继续 — 我接受风险`
  - `[B] 调整范围 — 延期一些 Should Have 故事`
  - `[C] 延长 Sprint 工期`

如果 [A]：继续到写入批准。
如果 [B]：修改故事列表，重新呈现更新后的计划，然后继续到写入批准。
如果 [C]：调整 Sprint 日期和产能，重新呈现更新后的计划，然后继续到写入批准。

处理完制作人的判定后，询问："我可以将 Sprint 计划写入 `production/sprints/sprint-[N].md` 和 `production/sprint-status.yaml` 吗？"如果同意，写入两个文件（按需创建目录）。判定：**COMPLETE** — Sprint 计划和状态文件已创建。如果拒绝：判定：**BLOCKED** — 用户拒绝写入。

写入后，添加：

> **范围检查：** 如果此 Sprint 包含超出原始 Epic 范围的故事，在实现开始前运行 `/scope-check [epic]` 检测范围蔓延。

---

## 第 5 阶段：QA 计划关卡

在关闭 Sprint 计划之前，检查此 Sprint 是否存在 QA 计划。

使用 `Glob` 查找 `production/qa/qa-plan-sprint-[N].md` 或 `production/qa/` 中任何引用此 Sprint 编号的文件。

**如果找到 QA 计划**：在 Sprint 计划输出中注明 — "QA Plan: `[path]`" — 然后继续。

**如果不存在 QA 计划**：不要静默继续。显式呈现：

> "此 Sprint 没有 QA 计划。没有 QA 计划的 Sprint 计划意味着测试需求未定义 — 开发者无法从 QA 角度知道'完成'是什么样子，没有它 Sprint 也无法通过 Production → Polish 关卡。
>
> 现在运行 `/qa-plan sprint`，在开始任何实现之前。它只需一次会话即可生成每个故事所需的测试用例需求。"

使用 `AskUserQuestion`：
- Prompt："未找到此 Sprint 的 QA 计划。你想如何继续？"
- Options：
  - `[A] 现在运行 /qa-plan sprint — 我会在开始实现前执行（推荐）`
  - `[B] 暂时跳过 — 我理解 QA 签收将在 Production → Polish 关卡处被阻塞`

如果 [A]：以"Sprint 计划已写入。接下来运行 `/qa-plan sprint` — 然后开始实现。"结束。
如果 [B]：向 Sprint 计划文档添加警告块：

```markdown
> ⚠️ **无 QA 计划**：此 Sprint 在未创建 QA 计划的情况下开始。在最后一个故事实现前运行 `/qa-plan sprint`。Production → Polish 关卡需要 QA 签收报告，而后者需要 QA 计划。
```

---

## 第 6 阶段：后续步骤

Sprint 计划写入且 QA 计划状态解决后：

- `/qa-plan sprint` — **实现开始前必需** — 定义每个故事的测试用例，确保开发者针对 QA 规格而非空白实现
- `/story-readiness [story-file]` — 在开始故事前验证其准备就绪
- `/dev-story [story-file]` — 开始实现第一个故事
- `/sprint-status` — Sprint 中期检查进度
- `/scope-check [epic]` — 在实现开始前验证无范围蔓延

**审查模式配置：** 所有主管关卡（制作人可行性、QA 审查、代码审查）均遵守项目审查模式。审查模式在第 0 阶段文件不存在时设置（对于 `new` Sprint），或可通过参数 `--review full|lean|solo` 在每次运行时覆盖。文件 `production/review-mode.txt` 包含以下之一：
- `lean` — 跳过自动化主管关卡（文件缺失时的默认值 — 独立开发者最快）
- `full` — 运行所有主管关卡作为生成的子 Agent
- `solo` — 无条件跳过所有关卡（单人开发者，无审查）

此文件由 `/sprint-plan`、`/story-readiness`、`/story-done` 和其他 Skill 在启动时读取。
