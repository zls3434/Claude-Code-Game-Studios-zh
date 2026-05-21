---
name: team-ui
description: "编排 UI 团队完成完整 UX 管线：从 UX 规格创作到视觉设计、实现、审查和打磨。集成 /ux-design、/ux-review 和工作室 UX 模板。"
argument-hint: "[UI 功能描述] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

当此 Skill 被调用时，通过结构化流水线编排 UI 团队。

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

**主管关卡跳过规则**：在生成 creative-director、art-director 或任何其他 Tier 1/2 主管进行审查（在 PHASE-GATE 触发器之外）之前，应用解析后的模式：如果是 solo 模式则跳过；如果是 lean 模式且这不是 PHASE-GATE 则跳过。

## 团队组成
- **ux-designer** — 用户流程、线框图、无障碍、输入处理
- **ui-programmer** — UI 框架、屏幕、小组件、数据绑定、实现
- **art-director** — 视觉风格、布局打磨、与美术圣经的一致性
- **engine UI specialist** — 根据引擎特定最佳实践验证 UI 实现模式（从 `.claude/docs/technical-preferences.md` Engine Specialists → UI Specialist 读取）
- **accessibility-specialist** — 在第 4 阶段审计无障碍合规

**本流水线使用的模板：**
- `ux-spec.md` — 标准屏幕/流程 UX 规格
- `hud-design.md` — HUD 特定 UX 规格
- `interaction-pattern-library.md` — 可复用的交互模式
- `accessibility-requirements.md` — 承诺的无障碍等级和需求

## 如何委托

使用 Task 工具将每个团队成员作为子 Agent 生成：
- `subagent_type: ux-designer` — 用户流程、线框图、无障碍、输入处理
- `subagent_type: ui-programmer` — UI 框架、屏幕、小组件、数据绑定
- `subagent_type: art-director` — 视觉风格、布局打磨、美术圣经一致性
- `subagent_type: [UI engine specialist]` — 引擎特定 UI 模式验证（例如 unity-ui-specialist、ue-umg-specialist、godot-specialist）
- `subagent_type: accessibility-specialist` — 无障碍合规审计

始终向每个 Agent 的提示提供完整上下文（功能需求、已有 UI 模式、平台目标）。在流水线允许的地方并行启动独立 Agent（例如第 4 阶段的审查 Agent 可以同时运行）。

## 流水线

### 第 1a 阶段：上下文收集

在设计任何内容之前，读取并综合：
- `design/gdd/game-concept.md` — 平台目标和目标受众
- `design/player-journey.md` — 玩家到达此屏幕时的状态和上下文
- 与此功能相关的所有 GDD UI 需求部分
- `design/ux/interaction-patterns.md` — 已有的模式，供复用（而非重新发明）
- `design/accessibility-requirements.md` — 承诺的无障碍等级（例如基本、增强、完整）

**如果 `design/ux/interaction-patterns.md` 不存在**，立即呈现缺口：
> "interaction-patterns.md 不存在 — 没有可复用的已有模式。"

然后使用 `AskUserQuestion` 提供选项：
- (a) 先运行 `/ux-design patterns` 建立模式库，然后继续
- (b) 在没有模式库的情况下继续 — ui-programmer 将所有创建的模式视为新模式，并在完成时将每个添加到新的 `design/ux/interaction-patterns.md`

不要仅从功能名称或 GDD 发明或假设模式。如果用户选择 (b)，在第 3 阶段明确指示 ui-programmer 将所有模式视为新模式并在实现完成时将其记录在 `design/ux/interaction-patterns.md` 中。在最终摘要报告中注明模式库状态（已创建 / 缺失 / 已更新）。

将上下文综合为 ux-designer 的简报：玩家在做什么、他们需要什么、有哪些约束适用、哪些已有模式是相关的。

### 第 1b 阶段：UX 规格创作

调用 `/ux-design [feature name]` Skill 或直接委托 ux-designer 按 `ux-spec.md` 模板生成 `design/ux/[feature-name].md`。

如果设计 HUD，使用 `hud-design.md` 模板而非 `ux-spec.md`。

> **特殊情况说明：**
> - 对于 HUD 设计，使用 `argument: hud` 调用 `/ux-design`（如 `/ux-design hud`）。
> - 对于交互模式库，在项目开始时运行一次 `/ux-design patterns`，并在后续阶段引入新模式时更新它。

输出：`design/ux/[feature-name].md` 包含所有必需的规格部分。

### 第 1c 阶段：UX 审查

规格完成后，调用 `/ux-review design/ux/[feature-name].md`。

**关卡**：在判定为 APPROVED 之前不要继续第 2 阶段。如果判定为 NEEDS REVISION，ux-designer 必须解决标记的问题并重新运行审查。用户可以明确接受 NEEDS REVISION 风险并继续，但这必须是一个有意识的决定 — 在询问是否继续之前通过 `AskUserQuestion` 呈现具体关切。

### 第 2 阶段：视觉设计

委托给 **art-director**：
- 审查完整的 UX 规格（流程、线框图、交互模式、无障碍说明）— 不仅仅是线框图图片
- 应用来自美术圣经的视觉处理：颜色、排版、间距、动画风格
- 检查视觉设计是否保持无障碍合规：验证颜色对比度，并确认颜色绝不是状态的唯一指示器（形状、文本或图标必须加强它）
- 指定美术管线所需的所有资产需求：指定尺寸的图标、背景纹理、字体、装饰元素 — 带精确尺寸和格式要求
- 确保与已有实现的 UI 屏幕一致
- 输出：附风格说明和资产清单的视觉设计规格

### 第 3 阶段：实现

在实现开始前，生成 **engine UI specialist**（来自 `.claude/docs/technical-preferences.md` Engine Specialists → UI Specialist）审查 UX 规格和视觉设计规格，获取引擎特定实现指导：
- 此屏幕应使用哪种引擎 UI 框架？（例如 Unity 中 UI Toolkit vs UGUI、Godot 中 Control 节点 vs CanvasLayer、Unreal 中 UMG vs CommonUI）
- 对于提议的布局或交互模式，是否有任何引擎特定的陷阱？
- 推荐的引擎小组件/节点结构？
- 输出：在 ui-programmer 开始之前交付给它的引擎 UI 实现说明

如果未配置引擎，跳过此步骤。

委托给 **ui-programmer**：
- 按照 UX 规格和视觉设计规格实现 UI
- **使用 `design/ux/interaction-patterns.md` 中的模式** — 不要重新发明已指定的模式。如果某个模式几乎合适但需要修改，注明偏差并标记供 ux-designer 审查。
- **UI 绝不以任何方式拥有或修改游戏状态** — 仅显示；为所有玩家动作发出事件
- 所有文本通过本地化系统 — 不硬编码面向玩家的字符串
- 支持两种输入方式（键鼠和手柄）
- 按 `design/accessibility-requirements.md` 中承诺的无障碍等级实现无障碍功能
- 连接数据绑定到游戏状态
- **如果在实现过程中创建了任何新的交互模式**（即模式库中还没有的内容），在标记实现完成之前将其添加到 `design/ux/interaction-patterns.md`
- 输出：实现的 UI 功能

### 第 4 阶段：审查（并行）

并行委托：
- **ux-designer**：验证实现与线框图和交互规格匹配。测试纯键盘和纯手柄导航。检查无障碍功能正确运行。
- **art-director**：验证视觉与美术圣经的一致性。在最低和最高支持分辨率下检查。
- **accessibility-specialist**：对照 `design/accessibility-requirements.md` 中记录的无障碍承诺等级验证合规。将任何违规标记为阻塞项。

所有三个审查流必须在继续第 5 阶段之前报告完毕。

### 第 5 阶段：打磨

- 处理所有审查反馈
- 验证动画可跳过且尊重玩家的减少动效偏好
- 确认 UI 音效通过音频事件系统触发（无直接音频调用）
- 在所有支持的分辨率和宽高比下测试
- **验证 `design/ux/interaction-patterns.md` 是最新的** — 如果在此功能的实现过程中引入了任何新模式，确认它们已添加到库中
- **确认所有 HUD 元素尊重 `design/ux/hud.md` 中定义的视觉预算**（元素计数、屏幕区域分配、最大不透明度值）

## 快速参考 — 何时使用哪个 Skill

- `/ux-design` — 从头创作屏幕、流程或 HUD 的新 UX 规格
- `/ux-review` — 在实现前验证已完成的 UX 规格
- `/team-ui [feature]` — 从概念到打磨的完整管线（内部调用 `/ux-design` 和 `/ux-review`）
- `/quick-design` — 不需要全新完整 UX 规格的小型 UI 变更

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

所有文件写入（UX 规格、交互模式库更新、实现文件）都委托给子 Agent 和子 Skill（`/ux-design`、`ui-programmer`）。每个都强制执行"我可以写入 [path] 吗？"协议。此编排器不直接写入文件。

## 输出

一份摘要报告，涵盖：UX 规格状态、UX 审查判定、视觉设计状态、实现状态、无障碍合规、输入方式支持、交互模式库更新状态以及任何未解决问题。

判定：**COMPLETE** — UI 功能已完成完整管线（UX 规格 → 视觉 → 实现 → 审查 → 打磨）。
判定：**BLOCKED** — 管线已停止；在停止前呈现阻塞项及其所在阶段。

## 后续步骤

- 在最终规格尚未批准时运行 `/ux-review`。
- 在关闭故事前对 UI 实现运行 `/code-review`。
- 如果需要视觉或音频打磨通道，运行 `/team-polish`。
