---
name: dev-story
description: "读取故事文件并实现它。加载完整上下文（故事、GDD 需求、ADR 指南、控制清单），路由到正确的系统与引擎程序员 agent，实现代码和测试，并确认每条验收标准。核心实现 Skill——在 /story-readiness 之后、/code-review 和 /story-done 之前运行。"
argument-hint: "[故事路径]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, Task, AskUserQuestion
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Dev Story

本 Skill 连接了规划与代码。它完整读取故事文件，汇集
程序员所需的全部上下文，路由到正确的专家 agent，并
推动实现直至完成——包括编写测试。

**每个故事的循环：**
```
/qa-plan sprint            ← 在 Sprint 开始前定义测试需求
/story-readiness [路径]     ← 在开始前验证
/dev-story [路径]           ← 实现它（本 Skill）
/code-review [文件]         ← 审查它
/story-done [路径]          ← 验证并关闭它
```

**所有 Sprint 故事完成后：** 运行 `/team-qa sprint` 执行完整的 QA 循环，并在推进项目阶段前获取签核裁决。

**输出：** 位于项目 `src/` 和 `tests/` 目录的源代码 + 测试文件。

---

## 阶段 1：找到故事

**如果提供了路径**：直接读取该文件。

**如果无参数**：检查 `production/session-state/active.md` 中是否有当前活跃的
故事。如果找到，确认："正在继续处理 [故事标题]——是否正确？"
如果未找到，询问："我们要实现哪个故事？" 然后 Glob
`production/epics/**/*.md` 并列出 Status: Ready 的故事。

---

## 阶段 2：加载完整上下文

**在加载任何上下文之前，验证必需文件是否存在。** 从故事的 `ADR Governing Implementation` 字段提取 ADR 路径，然后检查：

| 文件 | 路径 | 如果缺失 |
|------|------|------------|
| TR 注册表 | `docs/architecture/tr-registry.yaml` | **停止** —— "在 `docs/architecture/tr-registry.yaml` 未找到 TR 注册表。运行 `/architecture-review` 从你的 GDD 和 ADR 中引导注册表。" |
| 管理层 ADR | 从故事的 ADR 字段提取的路径 | **停止** —— "未找到 ADR 文件 [路径]。运行 `/architecture-decision` 创建它，或更正故事 ADR 字段中的文件名。" |
| 控制清单 | `docs/architecture/control-manifest.md` | **警告并继续** —— "未找到控制清单——层级规则无法检查。运行 `/create-control-manifest`。" |

如果 TR 注册表或管理层 ADR 缺失，将会话状态中的故事状态设为 **BLOCKED**，且不生成任何程序员 agent。

同时读取以下所有内容——这些是独立的读取。在所有上下文加载完毕之前不要开始实现：

### 故事文件
提取并保留：
- **故事标题、ID、层级、类型**（逻辑 / 集成 / 视觉手感 / UI / 配置数据）
- **TR-ID** —— GDD 需求标识符
- **管理层 ADR** 引用
- 故事头部中嵌入的 **Manifest Version**
- **验收标准** —— 每个复选框条目，逐字复制
- **实现说明** —— 故事中的 ADR 指导部分
- **范围外** 边界
- **测试证据** —— 所需的测试文件路径
- **依赖项** —— 此故事开始前哪些必须为 DONE

### TR 注册表
读取 `docs/architecture/tr-registry.yaml`。查找故事的 TR-ID。
读取当前的 `requirement` 文本——这是 GDD 当前需求的唯一权威来源。
不要依赖故事文件中的任何内联文本（可能已过时）。

### 管理层 ADR
读取 `docs/architecture/[adr-file].md`。提取：
- 完整的 Decision 部分
- Implementation Guidelines 部分（这是程序员应遵循的）
- Engine Compatibility 部分（截止后 API、已知风险）
- ADR Dependencies 部分

### 控制清单
读取 `docs/architecture/control-manifest.md`。提取此故事层级的规则：
- 必需模式
- 禁止模式
- 性能护栏

检查：故事中嵌入的 Manifest Version 是否与当前清单头部日期一致？
如果不一致，在继续前使用 `AskUserQuestion`：
- 提示语："故事是基于清单 v[story-date] 编写的。当前清单是 v[current-date]。可能适用新规则。你想如何继续？"
- 选项：
  - `[A] 更新故事的清单版本，并以当前规则实现（推荐）`
  - `[B] 使用旧规则实现——我接受不合规的风险`
  - `[C] 在此停止——我想先审查清单差异`

如果 [A]：在生成程序员之前，将故事文件的 `Manifest Version:` 字段编辑为当前清单日期。然后仔细阅读清单中的新规则。
如果 [B]：将故事文件的 `Manifest Version:` 字段编辑为当前清单日期，并在故事头部添加一行 `Manifest-Note: Proceeded with old manifest rules on [date] — non-compliance risk accepted.`。仍然读取清单中的新规则。将决策记录在阶段 6 摘要的"偏差"下。`/story-done` 将在其偏差部分包含 Manifest-Note 而无需重新检查过时性。
如果 [C]：停止。不生成任何 agent。让用户审查并重新运行 `/dev-story`。

### 依赖项验证

从故事文件中提取 **Dependencies** 列表后，逐一验证：

1. Glob `production/epics/**/*.md` 查找每个依赖故事文件。
2. 读取其 `Status:` 字段。
3. 如果任何依赖项的 Status 不是 `Complete` 或 `Done`：
   - 使用 `AskUserQuestion`：
     - 提示语："故事 '[当前故事]' 依赖于 '[依赖项标题]'，后者当前为 [status]，而非 Complete。你想如何继续？"
     - 选项：
       - `[A] 无论如何继续——我接受依赖风险`
       - `[B] 停止——我先完成该依赖项`
       - `[C] 依赖项已完成但状态未更新——将其标记为 Complete 后继续`
   - 如果 [B]：将会话状态中的故事状态设为 **BLOCKED** 并停止。不生成任何程序员 agent。
   - 如果 [C]：在继续前询问"我可以将 [依赖项路径] 的 Status 更新为 Complete 吗？"
   - 如果 [A]：在阶段 6 摘要的"偏差"下注明："Implemented with incomplete dependency: [dependency title] — [status]."

如果找不到依赖文件：警告"未找到依赖故事：[路径]。请验证路径或创建故事文件。"

---

### 引擎参考
读取 `.claude/docs/technical-preferences.md`：
- `Engine:` 值——决定使用哪些程序员 agent
- 命名约定（类名、文件名、信号/事件名）
- 性能预算（帧预算、内存上限）
- 禁止模式

### 标记故事为进行中

在生成任何 agent 之前静默更新两项：

1. **`production/sprint-status.yaml`**（如果存在）：找到与此故事文件路径匹配的条目，设置 `status: in_progress`。将顶层 `updated` 字段更新为今天的日期。如果文件不存在，静默跳过。

2. **故事文件本身**：将故事头部中的 `Last Updated:` 字段编辑为今天的日期（格式：`YYYY-MM-DD`）。如果故事头部中不存在该字段，在 `Status:` 行之后添加。这使得此故事的 Sprint 状态过时检测得以启用。

---

## 阶段 3：路由到正确的程序员

根据故事的 **Layer**、**Type** 和 **系统名称**，决定通过 Task 生成哪个专家。

**配置/数据故事——完全跳过 agent 生成：**
如果故事的 Type 是 `Config/Data`，不需要程序员 agent 或引擎专家。直接跳到阶段 4（配置/数据说明）。实现是数据文件编辑——不评估路由表，不使用引擎专家。

### 主要 agent 路由表

| 故事上下文 | 主要 agent |
|---|---|
| 基础层——任意类型 | `engine-programmer` |
| 任意层——Type: UI | `ui-programmer` |
| 任意层——Type: Visual/Feel | `gameplay-programmer`（实现） |
| 核心层或功能层——游戏机制 | `gameplay-programmer` |
| 核心层或功能层——AI 行为、寻路 | `ai-programmer` |
| 核心层或功能层——网络、复制 | `network-programmer` |
| 配置/数据——无代码 | 不需要 agent（见阶段 4 配置说明） |

### 引擎专家——代码故事的次要 agent，务必生成

读取 `.claude/docs/technical-preferences.md` 的 `Engine Specialists` 部分获取配置的主要专家。当故事涉及引擎特定 API、模式或 ADR 具有 HIGH 引擎风险时，与主要 agent 一起生成它们。

| 引擎 | 可用的专家 agent |
|--------|----------------------------|
| Godot 4 | `godot-specialist`、`godot-gdscript-specialist`、`godot-shader-specialist` |
| Unity | `unity-specialist`、`unity-ui-specialist`、`unity-shader-specialist` |
| Unreal Engine | `unreal-specialist`、`ue-gas-specialist`、`ue-blueprint-specialist`、`ue-umg-specialist`、`ue-replication-specialist` |

**当引擎风险为 HIGH 时**（来自 ADR 或 VERSION.md）：对于非引擎相关故事也务必生成引擎专家。HIGH 风险意味着 ADR 记录了对截止后引擎 API 的假设，需要专家验证。

---

## 阶段 4：实现

通过 Task 生成选定的程序员 agent(s)，附带完整上下文包：

向 agent 简要说明文件路径和针对性读取指令——不要将文档内容序列化到 Task 提示词中。agent 直接读取其所需内容：

1. **故事文件**：`[story-path]` —— 完整读取
2. **GDD 需求**：在 `docs/architecture/tr-registry.yaml` 中查找 TR-ID `[TR-XXX-NNN]` —— 将 `requirement` 字段作为唯一权威来源
3. **ADR**：`docs/architecture/[adr-file].md` —— 仅读取 **Decision** 和 **Implementation Guidelines** 部分
4. **控制清单**：`docs/architecture/control-manifest.md` —— 仅读取 **[layer]** 层规则
5. **引擎偏好**：`.claude/docs/technical-preferences.md` —— 读取命名约定和性能预算
6. **测试文件路径**：`[来自故事 Test Evidence 部分的路径]` —— 此文件必须在实现过程中创建
7. **测试需求**（仅逻辑和集成故事）：测试文件必须创建在 `[来自故事 Test Evidence 部分的路径]`。与实现同时编写测试——不要延后。没有此文件，故事无法通过 `/story-done` 关闭。每条验收标准必须至少有一个测试函数覆盖。测试文件命名：`[system]_[feature]_test.[ext]`。函数命名：`test_[scenario]_[expected_outcome]`。不使用随机种子、不依赖时间的断言、无外部 I/O。
8. **明确指令**：遵循 ADR 指南实现此故事，尊重清单规则，保持在故事的范围外边界之内。编写干净、有文档注释的公共 API。

Agent 应：
- 在 `src/` 中按照 ADR 指南创建或修改文件
- 遵守控制清单中的所有必需和禁止模式
- 保持在故事的范围外边界之内（不触碰不相关文件）
- 编写干净、有文档注释的公共 API

### 配置/数据故事（不需要 agent）

对于 Type: Config/Data 的故事，不需要程序员 agent。实现是编辑数据文件。读取故事的验收标准并直接在数据文件中进行指定变更。注明哪些值被更改以及从什么改为什么。

### 视觉/手感故事

生成 `gameplay-programmer` 来实现代码/动画调用。请注意，视觉/手感验收标准无法自动验证——"感觉对吗？"的检查在 `/story-done` 中通过手动确认进行。

---

## 阶段 5：测试证据需求

测试需求已包含在阶段 4 程序员 agent 简要说明中（第 7 项）。本阶段总结每种故事类型所需的证据——在收集阶段 6 摘要时使用。

| 故事类型 | 所需证据 | 备注 |
|---|---|---|
| **逻辑** | 自动单元测试，位于故事 Test Evidence 部分指定的路径 | 阻塞——已包含在阶段 4 agent 简要说明中 |
| **集成** | 集成测试 或 记录的试玩记录 | 阻塞——已包含在阶段 4 agent 简要说明中 |
| **视觉/手感** | 位于 `production/qa/evidence/[slug]-evidence.md` 的证据文档 | 建议——在阶段 6 摘要中注明 |
| **UI** | 手动走查文档或交互测试 | 建议——在阶段 6 摘要中注明 |
| **配置/数据** | 无——冒烟检查即作为证据 | 不适用 |

对于视觉/手感和 UI 故事，在阶段 6 摘要中包含："在故事可完全关闭之前，需要在 `production/qa/evidence/[slug]-evidence.md` 中提供手动证据。"

---

## 阶段 6：收集与总结

在程序员 agent(s) 完成后，收集：

- 创建或修改的文件（含路径）
- 创建的测试文件（路径和编写的测试函数数量）
- 任何偏离故事范围外边界的项（标记这些）
- Agent 提出的任何问题或阻塞项
- 专家标记的任何引擎特定风险

呈现简洁的实现摘要：

```
## 实现完成：[故事标题]

**更改的文件**：
- `src/[path]` —— 创建 / 修改（[简要描述]）
- `tests/[path]` —— 测试文件（[N] 个测试函数）

**已覆盖的验收标准**：
- [x] [标准] —— 在 [file:function] 中实现
- [x] [标准] —— 由测试 [test_name] 覆盖
- [ ] [标准] —— 延迟：需要试玩（视觉/手感）

**范围偏差**：[无] 或 [列出超出故事边界触碰的文件]
**已标记的引擎风险**：[无] 或 [专家发现]
**阻塞项**：[无] 或 [描述]

**在运行 `/story-done` 之前：** 本地运行你的测试套件并确认你编写的测试通过。`/story-done` 会自动重新运行它们，但如果在彼处发现测试失败，意味着需要回到实现上下文。

准备运行：`/code-review [file1] [file2]`，然后 `/story-done [story-path]`
```

---

## 阶段 7：更新会话状态

静默追加到 `production/session-state/active.md`：

```
## 会话提取 —— /dev-story [日期]
- 故事：[story-path] —— [故事标题]
- 更改的文件：[逗号分隔列表]
- 测试已编写：[路径，或 "无——视觉/手感/配置故事"]
- 阻塞项：[无，或描述]
- 下一步：/code-review [files] 然后 /story-done [story-path]
```

如果 `active.md` 不存在则创建它。确认："会话状态已更新。"

---

## 错误恢复协议

如果任何生成的 agent（通过 Task）返回 BLOCKED、错误或无法完成：

1. **立即呈现**：在继续到依赖阶段之前向用户报告 "[AgentName]：BLOCKED —— [原因]"
2. **评估依赖关系**：检查被阻塞 agent 的输出是否为后续阶段所需。如果是，未经用户输入不得越过该依赖点。
3. **提供选项**，通过 AskUserQuestion 提供三个选择：
   - 跳过此 agent 并在最终报告中注明缺口
   - 以更窄范围重试
   - 在此停止并首先解决阻塞问题
4. **始终生成部分报告**——输出任何已完成的内容。永远不要因为一个 agent 阻塞而丢弃已完成的工作。

常见阻塞项：
- 输入文件缺失（故事未找到，GDD 不存在）→ 重定向到创建它的 Skill
- ADR 状态为 Proposed → 不要实现；先运行 `/architecture-decision`
- 范围过大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事之间的冲突指令 → 呈现冲突，不要猜测
- 清单版本不匹配 → 向用户展示差异，询问是使用旧规则继续还是首先更新故事

## 协作协议

- **文件写入被委派**——所有源代码、测试文件和证据文档由通过 Task 生成的子 agent 编写。每个子 agent 单独执行"我可以写入 [path] 吗？"协议。此编排器不直接写入文件。
- **先加载再实现**——在所有上下文（故事、TR-ID、ADR、清单、引擎偏好）加载完毕之前不要开始编码。不完整的上下文会产生偏离设计的代码。
- **ADR 就是法律**——实现必须遵循 ADR 的 Implementation Guidelines。如果指南与看起来"更好"的方式冲突，在摘要中标记，而不是静默偏离。
- **保持在范围内**——范围外部分是一份契约。如果实现故事需要触及范围外文件，停止并呈现："实现 [标准] 需要修改 [文件]，而它在范围外。我是继续还是创建一个单独的故事？"
- **逻辑/集成故事的测试不可省略**——没有测试文件存在就不要将实现标记为完成
- **视觉/手感标准是延迟而非跳过**——在摘要中将其标记为 DEFERRED；它们将在 `/story-done` 中手动验证
- **大型结构决策前先询问**——如果故事需要 ADR 未覆盖的架构模式，在实现前呈现："ADR 未指定如何处理 [情况]。我的计划是 [X]。继续吗？"

---

## 推荐的下一步

- 运行 `/code-review [file1] [file2]` 在关闭故事前审查实现
- 运行 `/story-done [story-path]` 验证验收标准并将故事标记为完成
- 所有 Sprint 故事完成后：在推进项目阶段之前，运行 `/team-qa sprint` 进行完整的 QA 循环
