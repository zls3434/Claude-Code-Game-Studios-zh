---
name: team-audio
description: "编排音频团队：audio-director + sound-designer + technical-artist + gameplay-programmer 实现从方向到实现的完整音频管线。"
argument-hint: "[要设计音频的功能或区域] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

如果未提供参数，输出用法指导并退出而不生成任何 Agent：
> 用法：`/team-audio [功能或区域]` — 指定要设计音频的功能或区域（例如 `combat`、`main menu`、`forest biome`、`boss encounter`）。不要在此使用 `AskUserQuestion`；直接输出指导。

当此 Skill 以参数调用时，通过结构化流水线编排音频团队。

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

1. **读取参数** 获取目标功能或区域（例如 `combat`、`main menu`、`forest biome`、`boss encounter`）。

2. **收集上下文**：
   - 读取 `design/gdd/` 中该功能的相关设计文档
   - 读取 `design/gdd/sound-bible.md`（如果存在）
   - 读取 `assets/audio/` 中现有的音频资产列表
   - 读取此区域任何已有的声音设计文档

## 如何委托

使用 Task 工具将每个团队成员作为子 Agent 生成：
- `subagent_type: audio-director` — 声音身份、情感基调、音频调色板
- `subagent_type: sound-designer` — SFX 规格、音频事件、混音组
- `subagent_type: technical-artist` — 音频中间件、总线结构、内存预算
- `subagent_type: [primary engine specialist]` — 验证引擎的音频集成模式
- `subagent_type: gameplay-programmer` — 音频管理器、玩法触发器、自适应音乐

始终向每个 Agent 的提示提供完整上下文（功能描述、现有音频资产、设计文档引用）。

3. **按顺序编排音频团队**：

### 步骤 1：音频方向（audio-director）
生成 `audio-director` Agent 来：
- 为此功能/区域定义声音身份
- 指定情感基调和音频调色板
- 设定音乐方向（自适应层、分段、过渡）
- 定义音频优先级和混音目标
- 建立任何自适应音频规则（战斗强度、探索、紧张）

### 步骤 2：声音设计和音频无障碍（并行）
生成 `sound-designer` Agent 来：
- 为每个音频事件创建详细的 SFX 规格
- 定义声音类别（环境、UI、玩法、音乐、对话）
- 指定每个声音的参数（音量范围、音调变化、衰减）
- 规划附触发条件的音频事件列表
- 定义混音组和闪避规则

并行生成 `accessibility-specialist` Agent 来：
- 识别哪些音频事件携带关键玩法信息（受到伤害、附近有敌人、目标完成）并需要为听力障碍玩家提供视觉替代方案
- 指定字幕需求：哪些音频事件需要字幕、文本格式、屏幕持续时间
- 检查没有任何玩法状态仅通过音频传达（所有都必须有视觉回退）
- 审查音频事件列表中任何可能对听觉敏感玩家造成问题的项（高频警报、突然的大声事件）
- 输出：集成到音频事件规格中的音频无障碍需求列表

### 步骤 3：技术实现（并行）
生成 `technical-artist` Agent 来：
- 设计音频中间件集成（Wwise/FMOD/原生）
- 定义音频总线结构和路由
- 指定各平台音频资产的内存预算
- 规划流式与预加载资产策略
- 设计任何音频反应式视觉效果

并行生成 **primary engine specialist**（来自 `.claude/docs/technical-preferences.md` Engine Specialists）来验证集成方法：
- 提议的音频中间件集成对引擎是否地道？（例如 Godot 内置 AudioStreamPlayer vs FMOD、Unity Audio Mixer vs Wwise、Unreal MetaSounds vs FMOD）
- 是否应使用任何引擎特定的音频节点/组件模式？
- 固定引擎版本中有任何已知的音频系统变更会影响集成计划？
- 输出：与 technical-artist 计划合并的引擎音频集成说明

如果未配置引擎，跳过专家生成。

### 步骤 4：代码集成（gameplay-programmer）
生成 `gameplay-programmer` Agent 来：
- 实现音频管理器系统或审查已有的
- 将音频事件连接到玩法触发器
- 实现自适应音乐系统（如果已指定）
- 设置音频遮挡/混响区域
- 为音频事件触发器编写单元测试

4. **编译音频设计文档**，合并所有团队输出。

5. **保存到** `design/audio/audio-[feature].md`。

   注意：如果 `design/audio/` 不存在，编写文档的子 Agent 应创建它（目录将在文件写入时自动创建）。

6. **输出摘要**，包含：音频事件计数、预估资产数量、实现任务以及团队成员之间的任何未决问题。

判定：**COMPLETE** — 音频设计文档已生成且团队流水线已完成。

如果流水线因未解决的依赖而停止（例如关键无障碍缺口或缺失的 GDD 未被用户解决）：

判定：**BLOCKED** — [原因]

## 文件写入协议

所有文件写入（音频设计文档、SFX 规格、实现文件）都委托给通过 Task 生成的子 Agent。每个子 Agent 强制执行"我可以写入 [path] 吗？"协议。此编排器不直接写入文件。

## 后续步骤

- 在实现开始前与 audio-director 审查音频设计文档。
- 设计获批后使用 `/dev-story` 实现音频管理器和事件系统。
- 音频资产创建后运行 `/asset-audit` 验证命名和格式合规。

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
