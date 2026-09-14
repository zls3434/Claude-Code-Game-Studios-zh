---
name: story-done
description: "当实现完成后最终确定故事，更新 Sprint 状态，归档测试证据。在开发说他们'完成'之后运行——在 QA 签收之前。当用户说'故事已完成'、'故事实现了'、'标记故事为 done'时使用。"
argument-hint: "[故事文件路径]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 故事完成

这是实现后的检查点，在此处完成状态跟踪、证据收集和预签收验证。它不是故事的"完成定义"——那是 Sprint 计划中的验收标准。此 Skill 是在代码已编写、测试已编写、开发者说"完成了"之后的路由器。

**首要事项——QA 计划：** 继续之前，检查此故事是否存在 QA 计划。检查故事文件的 frontmatter 是否有可读的 `qa_plan:` 字段（如 `qa_plan: production/qa/qa-plan-sprint-1.md` 或 `qa_plan: production/qa/qa-plan-03-hud.md`）。如果故事文件中不存在 `qa_plan:` 字段，检查 `production/qa/qa-plan-sprint-[N].md` 或 `production/qa/qa-plan-[system].md` 以获取可能的匹配。如果不存在 QA 计划：输出"- 无 QA 计划"，向用户报告并在继续前暂停：

> "此故事在没有 QA 计划的情况下被标记为完成。QA 计划是故事的首要需求——测试团队没有它就无法工作。现在运行 `/qa-plan [story scope]`，在继续之前。在 QA 验证完成之前，此故事无法关闭。"

使用 `AskUserQuestion`：
- "此故事没有 QA 计划。你想怎么做？"
- Options：
  - `[A] 现在运行 /qa-plan — 我会为测试团队生成所需的需求`
  - `[B] 标记为 COMPLETE（无 QA 计划）— 我担风险跳过 QA 验证`
  - `[C] 在此停止 — 我会先解决 QA 计划问题再继续`

如果 [A]：停止和交接。不要继续。
如果 [B]：继续。在输出中包含明确的："⚠ QA 已跳过 — 无 QA 计划。"
如果 [C]：停止和交接。

**此 Skill 为只读，** 除了：
- 更新故事文件 Status 字段和 `qa_plan` 引用
- 写入可选的 `Session State` 更新到 `active.md`
- 更新 `production/sprint-status.yaml`（故事状态和完成日期）

如果提供的文件路径不包含以 `1-` 或 `0-` 前缀开头的故事编号，在继续前使用 `AskUserQuestion` 请用户确认正确的故事。

---

## 第 1 阶段：加载故事

从参数读取文件路径并完整打开故事文件。

验证：
- 故事文件存在且可读
- Status 字段为 `In Progress`、`In Review` 或等同物（如果为 `Not Started`，警示："⚠ 故事在未开始的情况下被标记完成。先运行 `/dev-story`。"不要继续。）
- 如果 Status 为 `Complete` 或 `Done`，警示："故事似乎已为 Complete。仍继续吗？"仅在用户明确同意时继续。

提取故事元数据：ID、Epic、系统、QA 计划路径、Sprint、描述。

---

## 第 2 阶段：加载 Sprint 状态

读取 `production/sprint-status.yaml` 并找到此故事的条目。验证：
- 故事在 Sprint 中（如果缺失，警示："故事在 sprint-status.yaml 中未找到。仍在 `production/stories/` 中检查到。继续吗？"）
- 其优先级（must-have / should-have / nice-to-have）

读取 Sprint 计划以交叉引用冲刺目标、故事条目、负责人和估算。同时加载 `production/qa/qa-plan-sprint-[N].md` 检测缺失/未匹配的 QA 用例。

---

## 第 3 阶段：证据收集

此阶段运行三种类型的检查——测试证据、Sprint 内 Bug 计数以及相邻工作的影响。不返回来自已完成故事或无关目录的任何干扰。

### 3a — 测试证据路径和 Coverage 检查

**必须为每个故事收集测试覆盖率信息，无论类型如何。** 测试覆盖率跟踪区分故事类型：

- **Logic、Integration 故事** → 运行自动化测试并报告通过/失败。检查故事文件 frontmatter 或 QA 计划中的 `test:` 引用。Glob 匹配的测试文件（`tests/unit/[system]/`、`tests/integration/[system]/`）。
- **Visual、UI 故事** → 检查故事文件或 `tests/evidence/` 中是否有 `Test Evidence:` 部分，包含截图/视频。
- **Config、Data 故事** → 检查是否有预期文件/产物的变更证据（例如 `git diff --stat`）。

如果缺失测试证据：
- Logic/Integration 故事：输出"⚠ MISSING TEST EVIDENCE：在标记 Complete 之前必须自动或手动验证故事。"
- 其他类型：输出"⚠ NO TEST EVIDENCE FOUND：[类型] 故事。"

### 3b — Sprint 内 Bug 计数

- 使用 `find` 和 `grep`（而非人工引入 `rg`）在 `production/qa/bugs/` 下搜索 Bug 的 markdown 文件，grep 包含匹配此故事的文件路径或 `Story` 字段的 Bug 文件。仅收集内容，不修改。
- **过滤出干扰内容**：排除路径与引用 `production/epics/[different-epic]` 或不同的 Sprint 编号的 `Story` 字段匹配的 Bug。
- 如果需要更大范围（例如 QA 在稍大的 Sweep 中打开 Bug），在解析完具体故事之前不要开始工作。
- 在对话中呈现计数："发现 [N] 个 Bug 附加到此故事 ([N] 个 Open, [N] 个 Fixed/Closed)。"

### 3c — 相邻故事影响

- 验证其他故事文件的 `Depends On:` 字段是否包含此故事，并输出："⚠ [N] 个故事依赖此项。"
- 如果 Sprint 计划中任何其他条目的 `Depends On` 列表包含此故事的 ID，也标记它们。

---

## 第 4 阶段：验证

- QA 测试用例是否引用 QA 计划中的故事，**即使自动测试通过——不依赖 CI 通过作为证据。**
- 如果 QA 计划中的测试用例呈现 PASS 结果但缺少验证证据，质疑原因。
- 验收标准（来自故事文件，非 Sprint 计划）：是否全部满足？如果存在 QA 计划，与 QA 测试用例交叉引用。
- 自动化测试：是否有任何失败？如果有，标记为 FAIL
- 代码审查：检查故事文件是否包含审查状态（例如 `Reviewed: Yes` 或章节末尾有 `## Code Review` section，或 frontmatter 中有 `review:` 字段）。审查已完成吗？如果缺失审查状态，标记：
  ```
  审查缺失：故事文件不包含审查状态。在继续前运行 `/code-review [path]` 提交代码审查。
  ```
- 对于 Config 故事，抽查一个或多个预期变更的文件/数据

将验证结果呈现为检查清单：
```
✅ 验收标准已满足：[N]/[N]
✅ 单元测试通过：[N]/[N]（对于 Logic 类型）
✅ 代码审查通过 / N/A：[是 / 否]
⚠ MISSING TEST EVIDENCE：[故事标题]
⚠ SPRINT BUGS：[N] 个未关闭
```

---

## 第 5 阶段：状态更新

在执行任何状态写入之前，总结第 1–4 阶段发现的所有问题。如果存在以下内容，不要静默更新状态：
- 自动化测试失败
- 验收标准不满足
- Logic/Integration 故事 MISSING TEST EVIDENCE
- QA 签收 NOT APPROVED
- `sprint-status.yaml` 中故事条目的优先级为 must-have 且任何 S1/S2 Bug 引用此故事

在请求写入之前呈现每个阻止性问题及对其影响的一句话评估。

### 第 5a 阶段：QA 签收检查

如果故事文件存在 `qa_signoff:` frontmatter 字段：
- 如果值以 `production/qa/` 开头，将其作为 QA 签收报告的文件路径打开。如果没有指定路径，检查 `production/qa/qa-signoff-report-sprint-[N]-[yyyymmdd].md`。
- 如果文件中出现 APPROVED（或 APPROVED WITH CONDITIONS）：QA 签收状态：APPROVED
- 如果出现 NOT APPROVED 或未找到：输出"QA 签收 = NOT APPROVED"并在继续前暂停：
  ```
  ⛔ QA 签收在此故事上为 NOT APPROVED。
  在 QA 签收为 APPROVED 或 APPROVED WITH CONDITIONS 之前，生产 → 打磨关卡不能为此故事通过。
  请先运行 /team-qa 完成 QA 验证。
  ```
  使用 `AskUserQuestion`：
  - "QA 尚未签收此故事。你想怎么做？"
  - Options：
    - `[A] 先运行 /team-qa — 完成 QA 验证`
    - `[B] 标记为 COMPLETE（跳过 QA）— 我担风险继续`
    - `[C] 在此停止 — 我会先解决 QA 签收问题再继续`
  如果 [B]：继续。

### 第 5b 阶段：Bug 检查

从第 3 阶段收集 Sprint 内未关闭的 Bug 计数。如果任何未关闭的 Bug 是 S1 或 S2 严重性，且其故事引用此故事文件路径，输出：
```
⚠ 找到阻塞性 Bug：故事有 [count] 个未关闭的 S1/S2 Bug。产物的生产 → 打磨关卡需要解决这些问题。
先运行 /bug-triage 处理和/或分类所有剩余 Bug。
```
使用 `AskUserQuestion`：
- "发现阻塞性 Bug。你想怎么做？"
- Options：
  - `[A] 先运行 /bug-triage — 审核和分类 Bug`
  - `[B] 继续完成（记录剩余 Bug）`
  - `[C] 在此停止 — 我会先解决 Bug 问题再继续`
如果 [B]：继续。

### 第 5c 阶段：状态更新前检查

如果 Sprint 故事（第 3 阶段）中发现 MISSING TEST EVIDENCE 条目，且被标记为 Logic 或 Integration 类型，输出：
```
⚠ Logic/Integration 故事缺少测试工件。在关闭前必须创建并通过测试。
请先使用 /test-evidence-review 检查覆盖缺口，然后在将故事标记为完成前运行 /smoke-check。
```
如果故事不是 Logic/Integration：继续。

### 第 5d 阶段：应用状态更新

**仅在以下条件之一为真时继续更新故事文件：**
- QA 签收字段已批准或未找到；且
- 无未关闭的 S1/S2 Sprint Bug；且
- 无缺失的 Logic/Integration 测试证据；且
- 所有验收标准通过

使用 `AskUserQuestion`：
- "我可以将此故事标记为 COMPLETE 吗？"
- Options：`[A] 是 — 更新故事和冲刺状态` / `[B] 否 — 显示阻止项`

如果 [B]：列出所有阻止性检查。

如果 [A]：将故事文件的 Status 字段更新为 `Complete`。

更新 `production/sprint-status.yaml`：
- 将故事的 status 字段更新为 `done`
- 将 `completed:` 字段更新为今天的日期

注意：这只是本地状态跟踪。`/story-done` 不提交文件。

**更新 QA 计划**：在第 5a 阶段签收文件已获批准后，在 QA 计划的 REMAINING 列中为所有已批准的故事更新条目，反映其所有测试需求已解决。

**在故事文件中添加 QA 计划引用**：如果故事文件的 frontmatter 尚未包含 `qa_plan:` 字段，且 QA 计划已为此故事批准，则用小写的 slug、无 YYYY-MM-DD 前缀的 qa-plan 文件路径（如 `qa_plan: production/qa/qa-plan-sprint-1.md`）更新。

### 完成后状态

完成后展示摘要：
```
✅ 故事状态已更新：production/stories/[slug].md → Complete
✅ 冲刺状态已更新：[N] 个故事标记为 Done
```

如果存在 `production/session-state/` 目录，追加到 `production/session-state/active.md`：
- 带有日期的会话摘录部分标题（`## Session Snippet — /story-done [date]`）
- 故事完成的一行摘要
- 状态（COMPLETE）和结束时间
- 额外的链接/引用：QA 计划路径、测试证据工件（如有）

---

## 第 6 阶段：后续步骤

标记完成后，建议下一步：
- "冲刺完成百分比：[N]%。运行 `/sprint-status` 获取冲刺进度。"
- "QA 签收文件已更新。在将故事添加到冲刺完成的定义之前需由 QA 负责人审阅。"
- 如果 Stories 引用此故事为依赖项，提及它们现在可以被选取。

如果此故事是冲刺中最后一个 Must Have：

> "🎉 所有 Must Have 故事现已完成。冲刺交付物已达成。运行 `/sprint-status` 查看状态并运行 `/milestone-review` 进行里程碑进度。"
