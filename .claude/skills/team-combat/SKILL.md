---
name: team-combat
description: "编排战斗团队：协调 game-designer、gameplay-programmer、ai-programmer、technical-artist、sound-designer 和 qa-tester，端到端地设计、实现和验证一个战斗功能。"
argument-hint: "[战斗功能描述] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

**参数检查：** 如果未提供战斗功能描述，输出：
> "用法：`/team-combat [战斗功能描述]` — 提供要设计和实现的战斗功能的描述（例如 `melee parry system`、`ranged weapon spread`）。"
然后立即停止，不生成任何子 Agent 或读取任何文件。

当此 Skill 以有效参数调用时，通过结构化流水线编排战斗团队。

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
- **game-designer** — 设计机制，定义公式和边缘情况
- **gameplay-programmer** — 实现核心玩法代码
- **ai-programmer** — 实现 NPC/敌人 AI 行为
- **technical-artist** — 创建 VFX、着色器效果和视觉反馈
- **sound-designer** — 定义音频事件、撞击声和环境战斗音频
- **engine specialist**（主要）— 验证架构和实现模式对引擎而言是否地道（从 `.claude/docs/technical-preferences.md` Engine Specialists 部分读取）
- **qa-tester** — 编写测试用例并验证实现

## 如何委托

使用 Task 工具将每个团队成员作为子 Agent 生成：
- `subagent_type: game-designer` — 设计机制，定义公式和边缘情况
- `subagent_type: gameplay-programmer` — 实现核心玩法代码
- `subagent_type: ai-programmer` — 实现 NPC/敌人 AI 行为
- `subagent_type: technical-artist` — 创建 VFX、着色器效果、视觉反馈
- `subagent_type: sound-designer` — 定义音频事件、撞击声、环境音频
- `subagent_type: [primary engine specialist]` — 架构和实现的引擎惯用法验证
- `subagent_type: qa-tester` — 编写测试用例并验证实现

始终向每个 Agent 的提示提供完整上下文（设计文档路径、相关代码文件、约束）。在流水线允许的地方并行启动独立 Agent（例如第 3 阶段 Agent 可以同时运行）。

## 流水线

### 第 1 阶段：设计
委托给 **game-designer**：
- 在 `design/gdd/` 中创建或更新设计文档，涵盖：机制概述、玩家幻想、详细规则、带变量定义的公式、边缘情况、依赖、带安全范围的调优旋钮以及验收标准
- 输出：完成的设计文档

### 第 2 阶段：架构
委托给 **gameplay-programmer**（如果涉及 AI，则加上 **ai-programmer**）：
- 审查设计文档
- 设计代码架构：类结构、接口、数据流
- 识别与现有系统的集成点
- 输出：附文件列表和接口定义的架构草图

然后生成 **primary engine specialist** 来验证提议的架构：
- 类/节点/组件结构对固定版本的引擎是否地道？（例如 Godot 节点层级、Unity MonoBehaviour vs DOTS、Unreal Actor/Component 设计）
- 是否应使用引擎原生系统而非自定义实现？
- 任何提议的 API 在固定引擎版本中是否已弃用或已变更？
- 输出：引擎架构说明 — 在第 3 阶段开始前纳入架构

使用 `AskUserQuestion`：
- Prompt："架构草图已完成。批准以继续进行并行实现。"
- Options：
  - `[A] 继续 — 生成实现 Agent（gameplay-programmer、ai-programmer、technical-artist、sound-designer）`
  - `[B] 先修改架构 — 我会描述需要变更的内容`
  - `[C] 在此停止 — 我稍后继续`

仅在用户选择 [A] 时才生成实现 Agent。

### 第 3 阶段：实现（尽可能并行）
并行委托：
- **gameplay-programmer**：实现核心战斗机制代码
- **ai-programmer**：实现 AI 行为（如果功能涉及 NPC 反应）
- **technical-artist**：创建 VFX 和着色器效果
- **sound-designer**：定义音频事件列表和混音说明

### 第 4 阶段：集成
- 将玩法代码、AI、VFX 和音频连接在一起
- 确保所有调优旋钮都已暴露且为数据驱动
- 验证功能与现有战斗系统协同工作

### 第 5 阶段：验证
委托给 **qa-tester**：
- 从验收标准编写测试用例
- 测试设计文档中记录的所有边缘情况
- 验证性能影响在预算范围内
- 为发现的任何问题提交 Bug 报告

### 第 6 阶段：签收
- 收集所有团队成员的结果
- 报告功能状态：COMPLETE / NEEDS WORK / BLOCKED
- 列出任何未决问题及其指派负责人

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

所有文件写入（设计文档、实现文件、测试用例）都委托给通过 Task 生成的子 Agent。每个子 Agent 强制执行"我可以写入 [path] 吗？"协议。此编排器不直接写入文件。

## 输出

一份摘要报告，涵盖：设计完成状态、各团队成员的实现状态、测试结果以及任何未决问题。

判定：**COMPLETE** — 战斗功能已设计、实现和验证。
判定：**BLOCKED** — 一个或多个阶段无法完成；已生成部分报告并列出未解决项。

## 后续步骤

- 对已实现的战斗代码运行 `/code-review` 再关闭故事。
- 运行 `/balance-check` 验证战斗公式和调优值。
- 如果需要 VFX、音频或性能打磨，运行 `/team-polish`。
