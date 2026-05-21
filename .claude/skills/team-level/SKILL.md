---
name: team-level
description: "编排关卡设计团队：level-designer + narrative-director + world-builder + art-director + systems-designer + qa-tester 进行完整的区域/关卡创作。"
argument-hint: "[关卡名称或要设计的区域] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

当此 Skill 被调用时：

**决策点：** 在每个步骤过渡时，使用 `AskUserQuestion` 将子 Agent 的提案作为可选项展示给用户。将 Agent 的完整分析写到对话中，然后用简洁的标签捕获决策。用户必须在进入下一步前批准。

## 第 0 阶段：解析审查模式

1. 如果传入 `--review [mode]` 参数，使用该模式。
2. 否则读取 `production/review-mode.txt` — 使用其中写入的内容。
3. 否则默认 `lean`。

模式：
- `full` — 按描述生成所有主管和牵头关卡
- `lean` — 跳过主管关卡，除非它们是 PHASE-GATE 类型（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo` — 完全跳过所有主管关卡生成；在没有任何 Agent 关卡的情况下运行 Skill

存储解析后的模式以供所有后续阶段使用。

1. **读取参数** 获取目标关卡或区域（例如 `tutorial`、`forest dungeon`、`hub town`、`final boss arena`）。

2. **收集上下文**：
   - 读取 `design/gdd/game-concept.md` 的游戏概念
   - 读取 `design/gdd/game-pillars.md` 的游戏支柱
   - 读取 `design/levels/` 中现有的关卡文档
   - 读取 `design/narrative/` 中相关的叙事文档
   - 读取该区域/阵营的世界构建文档

## 如何委托

使用 Task 工具将每个团队成员作为子 Agent 生成：
- `subagent_type: narrative-director` — 叙事目的、角色、情感弧线
- `subagent_type: world-builder` — 传说上下文、环境叙事、世界规则
- `subagent_type: level-designer` — 空间布局、节奏、遭遇、导航
- `subagent_type: systems-designer` — 敌人组合、掉落表、难度平衡
- `subagent_type: art-director` — 视觉主题、调色板、光照、资产需求
- `subagent_type: accessibility-specialist` — 导航清晰度、色盲安全、认知负荷
- `subagent_type: qa-tester` — 测试用例、边界测试、试玩检查清单

始终向每个 Agent 的提示提供完整上下文（游戏概念、支柱、已有关卡文档、叙事文档）。

3. **按顺序编排关卡设计团队**：

### 步骤 1：叙事 + 视觉方向（narrative-director + world-builder + art-director，并行）

同时生成所有三个 Agent — 在等待任何结果之前发出所有三个 Task 调用。

生成 `narrative-director` Agent 来：
- 定义此区域的叙事目的（这里发生什么故事节拍？）
- 识别关键角色、对话触发器和传说元素
- 指定情感弧线（玩家进入时、期间、离开时应有什么感受？）

生成 `world-builder` Agent 来：
- 提供区域的传说上下文（历史、阵营存在、生态）
- 定义环境叙事机会
- 指定影响此区域玩法的任何世界规则

生成 `art-director` Agent 来：
- 为此区域建立视觉主题目标 — 这些是布局的**输入**，而非布局的输出
- 定义此区域的色温和光照氛围（与邻近区域有何不同？）
- 指定形状语言方向（棱角要塞？有机洞穴？残破的宏伟？）
- 命名将引导玩家的主要视觉地标
- 读取 `design/art/art-bible.md`（如果存在）— 将所有方向锚定在已建立的美术圣经中

**步骤 1 中 art-director 的视觉目标必须作为显式约束传递给步骤 2 的 level-designer。** 布局决策在视觉方向之内进行，而非在之前进行。

**关卡**：使用 `AskUserQuestion` 呈现所有三个步骤 1 输出（叙事简报、传说基础、视觉方向目标）并在继续步骤 2 之前确认。

### 步骤 2：布局和遭遇设计（level-designer）
以完整的步骤 1 输出作为上下文生成 `level-designer` Agent：
- 叙事简报（来自 narrative-director）
- 传说基础（来自 world-builder）
- **视觉方向目标（来自 art-director）** — 布局必须在这些目标内工作，而非与之矛盾

level-designer 应：
- 设计空间布局（关键路径、可选路径、秘密）— 确保主要路线与步骤 1 的视觉地标目标对齐
- 定义节奏曲线（紧张峰值、休息区域、探索区域）— 与 narrative-director 的情感弧线协调
- 放置带难度递进的遭遇
- 设计环境谜题或导航挑战
- 定义用于导航的兴趣点和地标 — 这些必须匹配 art-director 指定的视觉地标
- 指定入口/出口点及与邻近区域的连接

**邻近区域依赖检查**：布局生成后，检查 `design/levels/` 中 level-designer 引用的每个邻近区域。如果任何引用区域的 `.md` 文件不存在，呈现缺口：
> "关卡引用 [area-name] 作为邻近区域，但 `design/levels/[area-name].md` 不存在。"

使用 `AskUserQuestion` 提供选项：
- (a) 继续使用占位符引用 — 在关卡文档中将连接标记为 UNRESOLVED，并在摘要报告的开放跨关卡依赖部分列出
- (b) 暂停并先运行 `/team-level [area-name]` 建立该区域

不要为缺失的邻近区域发明内容。

**关卡**：使用 `AskUserQuestion` 呈现步骤 2 布局（包括任何未解决的邻近区域依赖）并在继续步骤 3 之前确认。

### 步骤 3：系统集成（systems-designer）
生成 `systems-designer` Agent 来：
- 指定敌人组合和遭遇公式
- 定义掉落表和奖励放置
- 平衡相对于预期玩家等级/装备的难度
- 设计任何区域特定机制或环境危险
- 指定资源分布（生命拾取、存档点、商店）

**关卡**：使用 `AskUserQuestion` 呈现步骤 3 输出并在继续步骤 4 之前确认。

### 步骤 4：生产概念 + 无障碍（art-director + accessibility-specialist，并行）

**注意**：art-director 的方向通道（视觉主题、颜色目标、氛围）在步骤 1 中已完成。此通道是位置特定的生产概念 — 给定最终布局，每个具体空间看起来是什么样？

以步骤 2 的最终布局生成 `art-director` Agent：
- 为关键空间生成位置特定的概念规格（入口、关键遭遇区域、地标、出口）
- 指定哪些美术资产是此区域独有的 vs. 从全局池共享的
- 为每个关键空间定义视线和光照设置（这些现在是布局驱动的，而非方向性的）
- 指定此区域布局特定的 VFX 需求（天气体积、粒子、大气效果）
- 标记任何布局创建的与步骤 1 目标产生视觉方向冲突的位置 — 将这些呈现为生产风险

并行生成 `accessibility-specialist` Agent 来：
- 审查关卡布局的导航清晰度（玩家能否在不依赖颜色单独导航的情况下定位自己？）
- 检查关键路径指路牌在颜色之外使用了形状/图标/声音提示
- 审查任何谜题机制的认知负荷 — 标记任何需要同时持有超过 3 个状态的内容
- 检查关键玩法区域对色盲玩家是否有足够的对比度
- 输出：附严重性（BLOCKING / RECOMMENDED / NICE TO HAVE）的无障碍关切列表

在继续之前等待两个 Agent 都返回。

**关卡**：使用 `AskUserQuestion` 呈现两个步骤 4 结果。如果 accessibility-specialist 返回了任何 BLOCKING 关切，突出显示它们并提供：
- (a) 返回 level-designer 和 art-director 重新设计标记的元素，然后再进入步骤 5
- (b) 记录为已知无障碍缺口并继续步骤 5，关切显式记录在最终报告中

在用户确认任何 BLOCKING 无障碍关切之前不要继续步骤 5。

### 步骤 5：QA 规划（qa-tester）
生成 `qa-tester` Agent 来：
- 编写关键路径的测试用例
- 识别边界和边缘情况（序列破坏、软锁）
- 创建区域的试玩检查清单
- 定义关卡完成的验收标准

4. **编译关卡设计文档**，将所有团队输出合并为关卡设计模板格式。

收集所有子 Agent 输出后，通过 Task 生成 `level-designer` 来编译并写入最终文档：
- 传递：所有子 Agent 输出（原文）、关卡简报、游戏支柱、相关 GDD 部分
- 告知 level-designer：编译为关卡设计文档格式，然后在写入前请求用户批准（"我可以将编译后的关卡设计写入 design/levels/[level-name].md 吗？"）
- 编排器不直接为最终文档调用 Write。

5. **保存到** `design/levels/[level-name].md`（由 level-designer 子 Agent 在用户批准后处理 — 见上文）。

6. **输出摘要**，包含：区域概述、遭遇数、预估资产清单、叙事节拍、任何跨团队依赖或未决问题、开放跨关卡依赖（已引用但尚未设计的邻近区域，每个标记为 UNRESOLVED），以及无障碍关切及其解决状态。

## 文件写入协议

所有文件写入（关卡设计文档、叙事文档、测试检查清单）都委托给通过 Task 生成的子 Agent。每个子 Agent 强制执行"我可以写入 [path] 吗？"协议。此编排器不直接写入文件。

判定：**COMPLETE** — 关卡设计文档已生成且所有团队输出已编译。
判定：**BLOCKED** — 一个或多个 Agent 阻塞；已生成部分报告并列出未解决项。

## 后续步骤

- 对完成的关卡设计文档运行 `/design-review design/levels/[level-name].md` 进行验证。
- 设计获批后运行 `/dev-story` 实现关卡内容。
- 运行 `/qa-plan` 为此关卡生成 QA 测试计划。

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
