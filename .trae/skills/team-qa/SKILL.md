---
name: team-qa
description: "编排 QA 团队进行全面的 Sprint 质量验证：协调 qa-lead、qa-tester、bug-triage Agent 和 performance-analyst，对当前 Sprint 故事执行端到端 QA 流水线。"
argument-hint: "[sprint | quick | 故事文件路径] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

**参数检查。** 如果未提供参数，输出用法指导并退出：
> 用法：`/team-qa [sprint | quick | 故事文件路径]` — 对当前 Sprint（`sprint`）、上次冒烟失败的快速重新检查（`quick`），或单个故事文件进行 QA 验证。
然后立即停止，不生成任何子 Agent 或读取任何文件。

**qa-plan 检查。** Glob `production/qa/qa-plan-[sprint].md`（对于 sprint 模式）或读取故事文件检查 `qa_plan:` frontmatter 字段（对于故事模式）。如果不存在 QA 计划：报告"未找到 QA 计划。先运行 `/qa-plan sprint` 然后在 QA 可以在 [scope] 上开始之前。"然后停止。不开始 QA 工作。

当此 Skill 以有效参数调用时，通过结构化流水线编排 QA 团队。

**决策点：** 在每个阶段过渡时，使用 `AskUserQuestion` 将子 Agent 的提案作为可选项展示给用户。将 Agent 的完整分析写到对话中，然后用简洁的标签捕获决策。用户必须在进入下一阶段前批准。

## 第 0 阶段：解析审查模式

1. 如果传入 `--review [mode]` 参数，使用该模式。
2. 否则读取 `production/review-mode.txt` — 使用其中写入的内容。
3. 否则默认 `lean`。

模式：
- `full` — 按描述生成所有主管和牵头关卡
- `lean` — 跳过主管关卡，除非它们是 PHASE-GATE 类型（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo` — 完全跳过所有主管关卡生成；在没有任何 Agent 关卡的情况下运行 Skill

存储解析后的模式以供所有后续阶段使用。

## 团队组成
- **qa-lead** — QA 策略、待办事项优先级、签收决策
- **qa-tester** — 测试执行、Bug 报告、测试证据
- **bug-triage Agent** — 自动 Bug 分类和优先级排序（用于分诊传入 Bug 的 `/skill`）
- **performance-analyst** — 性能验证和帧预算检查

## 如何委托

使用 Task 工具将每个团队成员作为子 Agent 生成：
- `subagent_type: qa-lead` — QA 策略、待办事项优先级、签收
- `subagent_type: qa-tester` — 测试执行、Bug 报告
- `subagent_type: performance-analyst` — 性能验证

始终向每个 Agent 的提示提供完整上下文（故事文件内容、QA 计划路径、QA 测试用例、测试基础设施配置、已知 Bug 列表）。在流水线允许的地方并行启动独立 Agent（例如第 2 阶段和第 3 阶段 Agent 可以同时运行）。

## 流水线

### 第 1 阶段：测试规划
委托给 **qa-lead**：
- 为 Sprint 或故事建立 QA 测试范围
- 识别被测试系统之间任何跨故事测试依赖
- 将测试用例分配优先级：关键路径、边缘情况、回归
- **审查 QA 测试用例**：对于 QA 计划中的每个测试用例，检查其是否有效且范围适当 — 不要仅仅依赖 CI 通过作为证据。如果测试用例缺失或不足，补充或纠正它。
- 为故事验证定义冒烟测试子集（用于第 4 阶段和第 5 阶段的快速重检查）
- 输出：QA 测试计划及按测试者分的测试分配

### 第 2 阶段：自动化测试执行 + 性能（并行）
委托给 **performance-analyst**：
- 如果被测试功能是可配置的，对照性能预算进行基准测试
- 检查重载下的帧预算和内存使用
- 识别与功能实现相关的任何性能退化
- 输出：附通过与/未通过指标的性能验证报告

并行委托给 **qa-tester**：
- 运行所有可用且范围内的自动化测试套件
- 报告结果：通过/失败，并附证据
- 识别任何测试基础设施问题
- 输出：自动化测试结果

**如果性能预算未配置**（检查 `.claude/docs/technical-preferences.md` Performance Budgets）：

- 目标 FPS：[未配置 / 数值]
- 帧预算：[未配置 / 数值]
- 内存上限：[未配置 / 数值]

如果未配置，记录："性能预算未在 `.claude/docs/technical-preferences.md` 中设置。性能分析将检查退化但无法对硬性预算进行基准测试。"

### 第 3 阶段：手动验证（qa-tester）
委托给 **qa-tester**：
- 执行 QA 测试计划中的关键路径测试用例
- 文档化通过/失败，并附证据（截图、日志、复现步骤）
- 创建/更新 Bug 报告
- 验证验收标准（来自故事文件）
- 输出：手动测试结果及证据

**QA 测试用例：** qa-tester 必须将测试计划中的测试用例作为验证的起点，而不是推测测试。在第 1 阶段审查每个测试用例后（通过 qa-lead），qa-tester 在相关处执行它们。

### 第 4 阶段：Bug 分类
委托给 **qa-lead**：
- 审查在第 3 阶段发现的所有新 Bug
- 与现有已知 Bug 合并去重
- 分配严重性等级（S1–S4）和优先级
- 将 S1 项升级给 producer
- 输出：分类后的 Bug 报告

### 第 5 阶段：签收
委托给 **qa-lead**：
- 基于验收标准通过率、Bug 严重性和测试覆盖率进行签收评估
- **始终将签收作为 QA 签收报告写入** `production/qa/qa-signoff-report-sprint-[N]-[yyyymmdd].md`（对于故事模式，如果故事有多个 Sprint 上下文，sprint 编号可从故事文件 frontmatter 推导，否则使用故事 slug）
- 团队 QA 报告必须：
  - 显示发现的总 Bug 数，按严重性分布
  - 列出所有 S1 和 S2 Bug（严重性、状态、相关故事）
  - 如果被测试的故事在报告日期 2 天前最后更新，在"风险"下注明数据滞后
  - 排除除正在审查的故事范围外的任何工作的重复项
- qa-lead 在判定完成前必须检查"可签收"Bug 的状态。bug-triage 工具的输出可用于此目的，但不是替代。
- 在签收报告之外输出一个摘要判定：
  - **APPROVED** — 所有关键标准已满足；无未解决的高严重性问题
  - **APPROVED WITH CONDITIONS** — 已知低严重性问题未阻止上传；条件已记录
  - **NOT APPROVED** — 阻塞性问题未解决或验收标准不满足

## 输出

QA 验证报告，包含：
- 测试覆盖率摘要
- 自动化测试结果
- 性能验证指标
- 手动验证结果，附证据
- Bug 分类报告
- 签收判定及条件（如有）

## 错误恢复协议

如果任何生成的 Agent（通过 Task）返回 BLOCKED、出错或无法完成：

1. **立即呈现**：在继续到依赖阶段之前报告"[AgentName]：BLOCKED — [reason]"
2. **评估依赖**：检查被阻塞 Agent 的输出是否被后续阶段所需。如果是，未经用户输入不得继续超过该依赖点。
3. **提供选项** 通过 AskUserQuestion 并提供选择：
   - 跳过此 Agent 并在最终报告中注明缺口
   - 以更窄范围重试
   - 在此停止并先解决阻塞项
4. **始终生成部分报告** — 输出已完成的内容。不要因为一个 Agent 阻塞就丢弃工作。

常见阻塞项：
- 输入文件缺失（故事未找到、GDD 缺失）→ 重定向到创建它的 Skill
- ADR 状态为 Proposed → 不要实现；先运行 `/architecture-decision`
- 范围太大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事之间的指令冲突 → 呈现冲突，不要猜测

## 文件写入协议

所有文件写入（测试计划、测试结果、Bug 报告、签收报告）都委托给通过 Task 生成的子 Agent。每个子 Agent 强制执行"我可以写入 [path] 吗？"协议。此编排器不直接写入文件。

## 后续步骤

- 如果 NOT APPROVED：解决条件，重新运行 `/smoke-check`，然后重新运行 `/team-qa [scope]`
- 如果 APPROVED WITH CONDITIONS：在下一个 Sprint 中排期修复条件
- 如果 APPROVED：将故事标记为 DONE（`/story-done`）
- 如果 APPROVED：运行 `/gate-check` 获取 QA 级别的关卡判定
