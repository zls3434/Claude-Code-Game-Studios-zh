---
name: team-narrative
description: "编排叙事团队：协调 narrative-director、writer、world-builder 和 level-designer 来创建 cohesive 的故事内容、世界传说和叙事驱动的关卡设计。"
argument-hint: "[叙事内容描述] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion, TodoWrite
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

如果未提供参数，输出用法指导并退出而不生成任何 Agent：
> 用法：`/team-narrative [叙事内容描述]` — 描述要处理的故事内容、场景或叙事区域（例如 `boss encounter cutscene`、`faction intro dialogue`、`tutorial narrative`）。不要在此使用 `AskUserQuestion`；直接输出指导。

当此 Skill 以参数调用时，通过结构化流水线编排叙事团队。

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
- **narrative-director** — 故事弧、角色设计、对话策略、叙事愿景
- **writer** — 对话写作、传说条目、物品描述、游戏内文本
- **world-builder** — 世界规则、阵营设计、历史、地理、环境叙事
- **art-director** — 角色视觉设计、环境视觉叙事、过场/影视基调
- **level-designer** — 服务于叙事的关卡布局、节奏、环境叙事节拍
- **localization-lead** — 本地化就绪 — 标记不可本地化的字符串、文化假设和 i18n 缺口

## 如何委托

使用 Task 工具将每个团队成员作为子 Agent 生成：
- `subagent_type: narrative-director` — 故事弧、角色设计、叙事愿景
- `subagent_type: writer` — 对话写作、传说条目、游戏内文本
- `subagent_type: world-builder` — 世界规则、阵营设计、历史、地理
- `subagent_type: art-director` — 角色视觉档案、环境视觉叙事、影视基调
- `subagent_type: level-designer` — 服务于叙事的关卡布局、节奏
- `subagent_type: localization-lead` — 本地化就绪 — 标记不可本地化的字符串、文化假设和 i18n 缺口

始终向每个 Agent 的提示提供完整上下文（叙事简报、传说依赖、角色档案）。在流水线允许的地方并行启动独立 Agent（例如第 2 阶段 Agent 可以同时运行）。

## 流水线

### 第 1 阶段：叙事方向
委托给 **narrative-director**：
- 定义此内容的叙事目的：它服务于哪个故事节拍？
- 识别涉及的角色、他们的动机以及这如何契合整体弧线
- 设定情感基调和节奏目标
- 指定任何传说依赖或此内容引入的新传说
- 输出：附故事需求的叙事简报

### 第 2 阶段：世界基础（并行）
并行委托 — 在等待任何结果之前同时发出所有三个 Task 调用：
- **world-builder**：创建或更新与此内容相关的阵营、地点和历史的传说条目。对照现有传说进行交叉引用以检查矛盾。为新条目设定正典级别。
- **writer**：使用角色语音档案起草角色对话。确保所有行不超过 120 个字符，使用命名占位符替代变量，并做好本地化准备。
- **art-director**：为出现在此内容中的关键角色定义角色视觉设计方向（剪影、视觉原型、区分特征）。为每个关键空间指定环境视觉叙事元素（道具构成、光照说明、空间布局）。为任何过场动画或脚本序列定义色调调色板和影视方向。

### 第 3 阶段：关卡叙事整合
委托给 **level-designer**：
- 审查叙事简报和传说基础
- 在关卡中设计环境叙事元素
- 放置叙事触发器、对话区域和发现点
- 确保节奏同时服务于玩法和故事

### 第 4 阶段：审查与一致性
委托给 **narrative-director**：
- 对照角色语音档案审查所有对话
- 在新旧条目之间验证传说一致性
- 确认叙事节奏与关卡设计对齐
- 检查所有谜团都有文档化的"真实答案"

### 第 5 阶段：打磨（并行）
并行委托：
- **writer**：最终自查 — 验证没有行超过对话框约束，所有文本使用字符串键（非原始字符串），占位符变量名一致
- **localization-lead**：验证 i18n 合规 — 检查字符串键命名规范，标记任何带有硬编码格式、在翻译中无法存活的字符串，为扩展语言（德语/芬兰语通常多 30%）确认字符限制余量，确认文本中没有需要区域特定变体的文化假设
- **world-builder**：最终确定所有新传说条目的正典级别

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

所有文件写入（叙事文档、对话文件、传说条目）都委托给通过 Task 生成的子 Agent。每个子 Agent 强制执行"我可以写入 [path] 吗？"协议。此编排器不直接写入文件。

## 输出

一份摘要报告，涵盖：叙事简报状态、创建/更新的传说条目、编写的对话行、关卡叙事整合点、一致性审查结果以及任何未解决的矛盾。

判定：**COMPLETE** — 叙事内容已交付。

如果流水线因未解决的依赖而停止（例如传说矛盾或缺失的必要条件未被用户解决）：

判定：**BLOCKED** — [原因]

## 后续步骤

- 对叙事文档运行 `/design-review` 进行一致性验证。
- 对话最终确定后运行 `/localize extract` 提取新字符串进行翻译。
- 运行 `/dev-story` 在引擎中实现对话触发器和叙事事件。
