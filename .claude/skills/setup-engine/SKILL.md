---
name: setup-engine
description: "配置项目的游戏引擎和版本。在 CLAUDE.md 中锁定引擎，检测知识缺口，当版本超出 LLM 训练数据时通过 WebSearch 填充引擎参考文档。"
argument-hint: "[engine] | [engine version] | refresh | upgrade [old-version] [new-version] | 无参数表示引导式选择"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, WebFetch, Task, AskUserQuestion
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

当此 Skill 被调用时：

## 1. 解析参数

四种模式：

- **完整规格**：`/setup-engine godot 4.6` — 已提供引擎和版本
- **仅引擎**：`/setup-engine unity` — 已提供引擎，版本将查找
- **无参数**：`/setup-engine` — 完全引导模式（引擎推荐 + 版本）
- **刷新**：`/setup-engine refresh` — 更新参考文档（见第 10 节）
- **升级**：`/setup-engine upgrade [old-version] [new-version]` — 迁移到新引擎版本（见第 11 节）

---

## 2. 引导模式（无参数）

如果未指定引擎，运行交互式引擎选择流程：

### 检查现有游戏概念
- 读取 `design/gdd/game-concept.md`（如果存在）— 提取类型、范围、平台目标、美术风格、团队规模和 `/brainstorm` 的任何引擎推荐
- 如果不存在概念，通知用户：
  > "未找到游戏概念。考虑先运行 `/brainstorm` 来发现你想构建什么 — 它也会推荐一个引擎。或者告诉我你的游戏情况，我可以帮你选择。"

### 如果用户想不通过概念选择，按以下顺序询问：

**问题 1 — 先前经验**（始终首先通过 `AskUserQuestion` 询问此项）：
- Prompt："你之前使用过以下任何引擎吗？"
- Options：`Godot` / `Unity` / `Unreal Engine 5` / `多个 — 我会解释` / `都没有`
- 如果他们选择了特定引擎 → 推荐该引擎。先前经验胜过所有其他因素。与他们确认并跳过矩阵。
- 如果是"都没有"或"多个" → 继续下面的问题。

**问题 2-6 — 决策矩阵输入**（仅在无先前引擎经验时）：

**问题 2 — 目标平台**（始终第二个通过 `AskUserQuestion` 询问此项 — 平台在任何其他因素之前淘汰或强烈加权引擎）：
- Prompt："你们为这个游戏瞄准哪些平台？"
- Options：`PC (Steam / Epic)` / `Mobile (iOS / Android)` / `Console` / `Web / Browser` / `多平台`
- 直接输入推荐的平台规则：
  - Mobile → Unity 强烈优先；Unreal 不太适合；Godot 适合简单 Mobile
  - Console → Unity 或 Unreal；Godot 主机支持需要第三方发行商或大量额外工作
  - Web → Godot 干净地导出到 Web；Unity WebGL 可用；Unreal Web 支持较差
  - 仅 PC → 所有引擎可行；其他因素决定
  - 多平台 → Unity 在 PC/mobile/console 之间最具可移植性

1. **什么类型的游戏？**（2D、3D，还是两者？）
2. **主要输入方式？**（键鼠、手柄、触摸或混合？）
3. **团队规模和经验？**（独立初学者、独立有经验、小型团队？）
4. **有强烈的语言偏好吗？**（GDScript、C#、C++、可视化脚本？）
5. **引擎授权的预算？**（仅免费，还是商业授权可以？）

### 生成推荐

不要使用简单的评分矩阵来淘汰引擎。相反，根据以下诚实的权衡来推理用户的配置，然后呈现 1-2 个带有完整上下文的推荐。始终以用户选择结束 — 永远不要强制判定。

**引擎诚实权衡：**

**Godot 4**
- 真正优势：2D（同类最佳）、风格化/独立 3D、快速迭代、永久免费（MIT）、开源、最温和的学习曲线、最适合想要完全控制的独立开发者
- 实际局限：3D 生态相比 Unity/Unreal 较薄弱（针对 3D 特定问题的教程、资源、社区答案较少）；大型开放世界 3D 非常困难且在 Godot 中基本未经验证；主机导出需要第三方发行商或大量额外工作；较小的专业就业市场
- 授权实际情况：真正免费，永远无收入门槛。MIT 许可证意味着你拥有一切。
- 最适合：任何范围的 2D 游戏；风格化/氛围感 3D；有限的 3D 世界（非开放世界）；学习曲线重要的首个游戏项目；任何规模下预算是硬性限制的项目

**Unity**
- 真正优势：中等范围 3D 和 Mobile 的行业标准；庞大的资源商店和教程生态；C# 是专业性语言；对独立开发者最好的主机认证支持；几乎所有类型的强大社区
- 实际局限：2023 年授权争议损害了信任（运行时费用被提出后又撤回 — 政策变更的风险仍然是真实的）；C# 初始曲线比 GDScript 陡峭；对于简单项目编辑器比 Godot 更重
- 授权实际情况：收入低于 $200K 且安装量低于 200K 时免费（Unity Personal/Plus）。仅在游戏真正成功时才会变得昂贵 — 大多数独立游戏永远不会触及此门槛。2023 年争议值得了解，但实际当前条款对大多数独立开发者是合理的。
- 最适合：Mobile 游戏；中等范围 3D；瞄准主机的游戏；有 C# 背景的开发者；需要大型资源商店的项目；2-5 人团队

**Unreal Engine 5**
- 真正优势：同类最佳的 3D 视觉效果（Lumen、Nanite、Chaos 物理）；AAA 和逼真 3D 的行业标准；大型开放世界支持成熟且经过生产验证；Blueprint 可视化脚本降低了 C++ 门槛；适合瞄准高端 PC 或主机的游戏
- 实际局限：最陡峭的学习曲线；最重的编辑器（编译慢、项目体积大）；对于风格化/2D/小范围游戏来说过度；C++ 真的很难；不适合 Mobile 或 Web；超过 $1M 总收入后收取 5% 版税
- 授权实际情况：5% 版税仅在每款产品超过 $1M 总收入后才适用。对于第一个游戏或任何未达到 $1M 的游戏来说，零成本。这个门槛足够高，以至于大多数独立开发者永远不会支付。
- 最适合：AAA 品质 3D；大型开放世界游戏；逼真视觉效果；有 C++ 经验或愿意使用 Blueprint 的开发者；瞄准高端 PC/主机且视觉逼真度是核心卖点的游戏

**类型特定指导**（将其纳入推荐考虑）：
- 任意风格的 2D → Godot 强烈推荐
- 风格化 / 氛围感 / 有限世界 3D → Godot 可行，Unity 是稳固替代
- 大型无缝开放世界 3D → Unity 或 Unreal；Godot 对此类项目未经生产验证
- 逼真 / AAA 品质 3D → Unreal
- Mobile 优先 → Unity 强烈推荐
- Console 优先 → Unity 或 Unreal；Godot 主机支持需要额外工作
- 恐怖 / 叙事 / 步行模拟 → 任意引擎；匹配美术风格和团队经验
- 动作 RPG / Soulslike → 3D 用 Unity 或 Unreal；社区支持和资源很重要
- 2D 平台游戏 → Godot
- 策略 / 俯视角 / RTS → Godot 或 Unity，取决于 2D 还是 3D

**推荐格式：**
1. 展示以用户特定因素为行的对比表
2. 给出带有诚实推理的主要推荐
3. 指出最佳替代方案及何时选择它
4. 明确声明："这是一个起点，不是定论 — 你随时可以迁移引擎，许多开发者在不同项目之间切换。"
5. 使用 `AskUserQuestion` 确认："这个推荐感觉对吗，还是你想探索不同的引擎？"
   - Options：`[主要引擎]（推荐）` / `[替代引擎]` / `[第三引擎]` / `进一步探索` / `自定义输入`

**如果用户选择"进一步探索"：**
使用 `AskUserQuestion` 提供概念特定的深入主题。始终从用户的实际概念生成选项 — 不要使用通用选项。至少始终包含：
- 主要引擎对此概念的具体局限（例如 "Godot 3D 对 [类型] 实际上能走多远？"）
- 替代引擎对此概念的具体权衡
- 语言选择对此概念技术挑战的影响
- 任何概念特定的技术关切（例如自适应音频、开放世界流式加载、多人网络代码）

用户可以选择多个主题。在返回引擎确认问题之前，深入回答每个选定的主题。

---

## 3. 查找当前版本

一旦选定引擎：

- 如果提供了版本，使用它
- 如果未提供版本，使用 WebSearch 找到最新的稳定版本：
  - 搜索：`"[engine] latest stable version [current year]"`
  - 与用户确认："最新的稳定 [engine] 是 [version]。使用这个吗？"

---

## 4. 更新 CLAUDE.md 技术栈

### 语言选择（仅限 Godot）

如果选择了 Godot，在展示建议的技术栈**之前**询问用户要使用哪种语言：

> "Godot 支持两种主要语言：
>
>   **A) GDScript** — 类 Python、Godot 原生、迭代最快。最适合初学者、独立开发者和来自 Python 或 Lua 的团队。
>   **B) C#** — .NET 8+、Unity 开发者熟悉、更强的 IDE 工具（Rider / Visual Studio）、在重型逻辑上有轻微性能优势。
>   **C) 两者** — GDScript 用于玩法/UI 脚本，C# 用于性能关键系统。高级设置 — 需要 .NET SDK 与 Godot 同时使用。
>
> 此项目主要使用哪种？"

记录选择。它决定了 CLAUDE.md 模板、命名规范、专家路由以及整个项目中代码文件生成哪个 Agent。

---

读取 `CLAUDE.md` 并向用户展示建议的技术栈变更。
询问："我可以将这些引擎设置写入 `CLAUDE.md` 吗？"

在确认之前等待，然后再做任何编辑。

更新技术栈部分，将 `[CHOOSE]` 占位符替换为实际值：

**对于 Godot** — 使用匹配上述所选语言的模板。见本 Skill 底部的**附录 A** 获取全部三种变体（GDScript、C#、Both）。

**对于 Unity：**
```markdown
- **Engine**: Unity [version]
- **Language**: C#
- **Build System**: Unity Build Pipeline
- **Asset Pipeline**: Unity Asset Import Pipeline + Addressables
```

**对于 Unreal：**
```markdown
- **Engine**: Unreal Engine [version]
- **Language**: C++ (primary), Blueprint (gameplay prototyping)
- **Build System**: Unreal Build Tool (UBT)
- **Asset Pipeline**: Unreal Content Pipeline
```

---

## 5. 填充技术偏好

更新 CLAUDE.md 后，使用引擎相应的默认值创建或更新 `.claude/docs/technical-preferences.md`。先读取现有模板，然后填写：

### 引擎与语言部分
- 从步骤 4 做出的引擎选择填充

### 命名规范（引擎默认值）

**对于 Godot** — 见**附录 A** 获取 GDScript、C# 和 Both 变体。

**对于 Unity（C#）：**
- 类：PascalCase（例如 `PlayerController`）
- 公共字段/属性：PascalCase（例如 `MoveSpeed`）
- 私有字段：_camelCase（例如 `_moveSpeed`）
- 方法：PascalCase（例如 `TakeDamage()`）
- 文件：PascalCase 匹配类（例如 `PlayerController.cs`）
- 常量：PascalCase 或 UPPER_SNAKE_CASE

**对于 Unreal（C++）：**
- 类：前缀 PascalCase（Actor 用 `A`，UObject 用 `U`，结构体用 `F`）
- 变量：PascalCase（例如 `MoveSpeed`）
- 函数：PascalCase（例如 `TakeDamage()`）
- 布尔值：`b` 前缀（例如 `bIsAlive`）
- 文件：匹配类名不带前缀（例如 `PlayerController.h`）

### 输入与平台部分

使用第 2 节收集的答案（或从游戏概念中提取）填充 `## Input & Platform`。使用以下映射推导值：

| 目标平台 | 手柄支持 | 触摸支持 |
|-----------------|-----------------|---------------|
| 仅 PC | 部分（推荐） | 无 |
| Console | 完整 | 无 |
| Mobile | 无 | 完整 |
| PC + Console | 完整 | 无 |
| PC + Mobile | 部分 | 完整 |
| Web | 部分 | 部分 |

对于**主要输入**，使用游戏类型的主导输入方式：
- 瞄准 Console 的动作/RPG/平台游戏 → 手柄
- 策略/点击/RTS → 键鼠
- Mobile 游戏 → 触摸
- 跨平台 → 询问用户

展示推导的值并请用户在写入前确认或调整。

示例填充部分：
```markdown
## Input & Platform
- **Target Platforms**: PC, Console
- **Input Methods**: Keyboard/Mouse, Gamepad
- **Primary Input**: Gamepad
- **Gamepad Support**: Full
- **Touch Support**: None
- **Platform Notes**: All UI must support d-pad navigation. No hover-only interactions.
```

### 其余部分
- **Performance Budgets**：使用 `AskUserQuestion`：
  - Prompt："我应该现在设置默认性能预算，还是留到以后？"
  - Options：`[A] 现在设置默认值（60fps、16.6ms 帧预算、引擎相应的 Draw Call 限制）` / `[B] 保留为 [TO BE CONFIGURED] — 我知道目标硬件后再设置`
  - 如果 [A]：使用建议的默认值填充。如果 [B]：保留占位符。
- **Testing**：建议引擎相应的测试框架（Godot 用 GUT、Unity 用 NUnit 等）— 添加前询问。
- **Forbidden Patterns**：保留为占位符 — 不要预填充。
- **Allowed Libraries**：保留为占位符 — 不要预填充项目当前不需要的依赖项。仅当正在积极集成时才在此添加库，不进行推测性添加。

> **防护栏**：绝不向 Allowed Libraries 添加推测性依赖。例如，除非 Steam 集成在本会话中积极开始，否则不要添加 GodotSteam。游戏上线后的集成应在该工作开始时添加到 Allowed Libraries，而非在引擎设置时。

### 引擎专家路由

同时用所选引擎的正确路由填充 `technical-preferences.md` 中的 `## Engine Specialists` 部分：

**对于 Godot** — 见**附录 A** 获取匹配所选语言的路由表。

**对于 Unity：**
```markdown
## Engine Specialists
- **Primary**: unity-specialist
- **Language/Code Specialist**: unity-specialist (C# review — primary covers it)
- **Shader Specialist**: unity-shader-specialist (Shader Graph, HLSL, URP/HDRP materials)
- **UI Specialist**: unity-ui-specialist (UI Toolkit UXML/USS, UGUI Canvas, runtime UI)
- **Additional Specialists**: unity-dots-specialist (ECS, Jobs system, Burst compiler), unity-addressables-specialist (asset loading, memory management, content catalogs)
- **Routing Notes**: Invoke primary for architecture and general C# code review. Invoke DOTS specialist for any ECS/Jobs/Burst code. Invoke shader specialist for rendering and visual effects. Invoke UI specialist for all interface implementation. Invoke Addressables specialist for asset management systems.

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.cs files) | unity-specialist |
| Shader / material files (.shader, .shadergraph, .mat) | unity-shader-specialist |
| UI / screen files (.uxml, .uss, Canvas prefabs) | unity-ui-specialist |
| Scene / prefab / level files (.unity, .prefab) | unity-specialist |
| Native extension / plugin files (.dll, native plugins) | unity-specialist |
| General architecture review | unity-specialist |
```

**对于 Unreal：**
```markdown
## Engine Specialists
- **Primary**: unreal-specialist
- **Language/Code Specialist**: ue-blueprint-specialist (Blueprint graphs) or unreal-specialist (C++)
- **Shader Specialist**: unreal-specialist (no dedicated shader specialist — primary covers materials)
- **UI Specialist**: ue-umg-specialist (UMG widgets, CommonUI, input routing, widget styling)
- **Additional Specialists**: ue-gas-specialist (Gameplay Ability System, attributes, gameplay effects), ue-replication-specialist (property replication, RPCs, client prediction, netcode)
- **Routing Notes**: Invoke primary for C++ architecture and broad engine decisions. Invoke Blueprint specialist for Blueprint graph architecture and BP/C++ boundary design. Invoke GAS specialist for all ability and attribute code. Invoke replication specialist for any multiplayer or networked systems. Invoke UMG specialist for all UI implementation.

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.cpp, .h files) | unreal-specialist |
| Shader / material files (.usf, .ush, Material assets) | unreal-specialist |
| UI / screen files (.umg, UMG Widget Blueprints) | ue-umg-specialist |
| Scene / prefab / level files (.umap, .uasset) | unreal-specialist |
| Native extension / plugin files (Plugin .uplugin, modules) | unreal-specialist |
| Blueprint graphs (.uasset BP classes) | ue-blueprint-specialist |
| General architecture review | unreal-specialist |
```

### 协作步骤
将填写好的偏好展示给用户。对于 Godot，包含所选语言并注明完整命名规范和路由表的位置：
> "以下是 [engine] 的默认技术偏好（[如果 Godot，注明语言]）。命名规范和专家路由在本 Skill 的附录 A 中 — 我将应用 [GDScript/C#/Both] 变体。想自定义其中任何一项，还是应该保存默认值？"

对于所有其他引擎，直接呈现默认值而不引用附录。

在写入文件前等待批准。

---

## 6. 确定知识缺口

检查引擎版本是否可能超出 LLM 的训练数据。

**已知大致覆盖范围**（随模型变化而更新）：
- LLM 知识截止日期：**2025 年 5 月**
- Godot：训练数据可能覆盖至约 4.3
- Unity：训练数据可能覆盖至约 2023.x / 早期 6000.x
- Unreal：训练数据可能覆盖至约 5.3 / 早期 5.4

将用户选择的版本与这些基准比较：

- **在训练数据内** → `LOW RISK` — 参考文档可选但建议
- **接近边缘** → `MEDIUM RISK` — 推荐参考文档
- **超出训练数据** → `HIGH RISK` — 必须有参考文档

告知用户他们属于哪个类别及原因。

---

## 7. 填充引擎参考文档

### 如果在训练数据内（LOW RISK）：

创建最小化的 `docs/engine-reference/<engine>/VERSION.md`：

```markdown
# [Engine] — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | [version] |
| **Project Pinned** | [today's date] |
| **LLM Knowledge Cutoff** | May 2025 |
| **Risk Level** | LOW — version is within LLM training data |

## Note

This engine version is within the LLM's training data. Engine reference
docs are optional but can be added later if agents suggest incorrect APIs.

Run `/setup-engine refresh` to populate full reference docs at any time.
```

不要创建 breaking-changes.md、deprecated-apis.md 等 — 它们会增加上下文成本而价值最小。

### 如果超出训练数据（MEDIUM 或 HIGH RISK）：

通过搜索网络创建完整的参考文档集：

1. **搜索官方迁移/升级指南**：
   - `"[engine] [old version] to [new version] migration guide"`
   - `"[engine] [version] breaking changes"`
   - `"[engine] [version] changelog"`
   - `"[engine] [version] deprecated API"`

2. **从官方文档提取：**
   - 从训练截止到当前每个版本之间的重大变更
   - 已弃用的 API 及其替代
   - 新功能和最佳实践

询问："我可以在 `docs/engine-reference/<engine>/` 下创建引擎参考文档吗？"

在写入任何文件前等待确认。

3. **创建完整的参考目录**：
   ```
   docs/engine-reference/<engine>/
   ├── VERSION.md              # 版本锁定 + 知识缺口分析
   ├── breaking-changes.md     # 逐版本重大变更
   ├── deprecated-apis.md      # "不要用 X → 用 Y"表格
   ├── current-best-practices.md  # 自训练截止以来的新实践
   └── modules/                # 各子系统参考（按需创建）
   ```

4. **填充每个文件**：使用来自网络搜索的真实数据，遵循已有参考文档中建立的格式。每个文件必须有"Last verified: [date]"头部。

5. **对于模块文件**：仅为发生过重大变更的子系统创建模块。不要创建空或最小化的模块文件。

---

## 8. 更新 CLAUDE.md 导入

询问："我可以更新 `CLAUDE.md` 中的 `@` 导入以指向新的引擎参考吗？"

等待确认，然后更新"Engine Version Reference"下的 `@` 导入以指向正确的引擎：

```markdown
## Engine Version Reference

@docs/engine-reference/<engine>/VERSION.md
```

如果之前的导入指向不同的引擎（例如从 Godot 切换到 Unity），更新它。

---

## 9. 更新 Agent 指令

在编辑任何内容之前先询问："我可以向引擎专家 Agent 文件添加 Version Awareness 部分吗？"

对于所选引擎的专家 Agent，验证它们是否有"Version Awareness"部分。如果没有，遵循现有 Godot 专家 Agent 中的模式添加一个。

该部分应指示 Agent：
1. 读取 `docs/engine-reference/<engine>/VERSION.md`
2. 在建议代码前检查已弃用的 API
3. 检查相关版本过渡的重大变更
4. 使用 WebSearch 验证不确定的 API

---

## 10. 刷新子命令

如果以 `/setup-engine refresh` 调用：

1. 读取现有的 `docs/engine-reference/<engine>/VERSION.md` 获取当前引擎和版本
2. 使用 WebSearch 检查：
   - 自上次验证以来的新引擎版本
   - 更新的迁移指南
   - 新弃用的 API
3. 用新发现更新所有参考文档
4. 在所有修改的文件上更新"Last verified"日期
5. 报告变更内容

---

## 11. 升级子命令

如果以 `/setup-engine upgrade [old-version] [new-version]` 调用：

### 步骤 1 — 读取当前版本状态

读取 `docs/engine-reference/<engine>/VERSION.md` 确认当前锁定的版本、风险级别和任何已记录的迁移说明 URL。如果 `old-version` 未作为参数提供，使用此文件中的锁定版本。

### 步骤 2 — 获取迁移指南

使用 WebSearch 和 WebFetch 定位 `old-version` 和 `new-version` 之间的官方迁移指南：

- 搜索：`"[engine] [old-version] to [new-version] migration guide"`
- 搜索：`"[engine] [new-version] breaking changes changelog"`
- 如果 VERSION.md 中已记录迁移指南 URL 则获取该 URL，或使用搜索找到的 URL。

提取：重命名的 API、移除的 API、更改的默认值、行为变更和任何"必须迁移"的项目。

### 步骤 3 — 升级前审计

扫描 `src/` 中使用了已知在目标版本中已弃用或改变的 API 的代码：

- 使用 Grep 搜索从迁移指南中提取的已弃用 API 名称（例如旧函数名、移除的节点类型、更改的属性名）
- 列出每个匹配的文件及找到的特定 API 引用

将审计结果展示为表格：

```
Pre-Upgrade Audit: [engine] [old-version] → [new-version]
==========================================================

Files requiring changes:
  File                              | Deprecated API Found       | Effort
  --------------------------------- | -------------------------- | ------
  src/gameplay/player_movement.gd   | old_api_name               | Low
  src/ui/hud.gd                     | removed_node_type          | Medium

Breaking changes to watch for:
  - [change description from migration guide]
  - [change description from migration guide]

Recommended migration order (dependency-sorted):
  1. [system/layer with fewest dependencies first]
  2. [next system]
  ...
```

如果在 `src/` 中未找到已弃用的 API，报告："在 src/ 中未找到已弃用的 API 使用 — 升级可能是低风险的。"

### 步骤 4 — 在更新前确认

在进行任何更改前询问用户：

> "升级前审计完成。发现 [N] 个文件使用了已弃用的 API。
> 继续将 VERSION.md 升级到 [new-version] 吗？
> （这将更新锁定版本并添加迁移说明 — 它不会更改任何源文件。源文件迁移可手动或通过故事完成。）"

在继续前等待明确确认。

### 步骤 5 — 更新 VERSION.md

确认后：

1. 更新 `docs/engine-reference/<engine>/VERSION.md`：
   - `Engine Version` → `[new-version]`
   - `Project Pinned` → 今天的日期
   - `Last Docs Verified` → 今天的日期
   - 如果新版本超出 LLM 知识截止日期，重新评估并更新 `Risk Level` 和 `Post-Cutoff Version Timeline` 表
   - 添加 `## Migration Notes — [old-version] → [new-version]` 部分，包含：迁移指南 URL、关键重大变更、本项目中发现的已弃用 API、以及审计中的推荐迁移顺序

2. 如果引擎参考目录中存在 `breaking-changes.md` 或 `deprecated-apis.md`，将新版本的变更追加到这些文件。

### 步骤 6 — 升级后提醒

更新 VERSION.md 后，输出：

```
VERSION.md 已更新：[engine] [old-version] → [new-version]

后续步骤：
1. 迁移上述列出的 [N] 个文件中已弃用的 API 使用
2. 升级实际引擎二进制文件后运行 /setup-engine refresh 验证是否有遗漏的新弃用项
3. 运行 /architecture-review — 引擎升级可能使引用特定 API 或引擎功能的 ADR 失效
4. 如果有 ADR 失效，运行 /propagate-design-change 更新下游故事
```

---

## 12. 输出摘要

设置完成后，输出：

```
引擎设置完成
=====================
引擎：            [name] [version]
语言：            [GDScript | C# | GDScript + C# | C# | C++ + Blueprint]
知识风险：        [LOW/MEDIUM/HIGH]
参考文档：        [已创建/已跳过]
CLAUDE.md：       [已更新]
技术偏好：        [已创建/已更新]
Agent 配置：      [已验证]

后续步骤：
1. 审查 docs/engine-reference/<engine>/VERSION.md
2. [如果来自 /brainstorm] 运行 /map-systems 将概念分解为独立系统
3. [如果来自 /brainstorm] 运行 /design-system 编写各个系统的 GDD（引导式、逐节进行）
4. [如果来自 /brainstorm] 运行 /prototype [core-mechanic] 在编写 GDD 前验证核心想法
5. [如果是全新开始] 运行 /brainstorm 发现你的游戏概念
6. 创建你的第一个里程碑：/sprint-plan new
```

---

判定：**COMPLETE** — 引擎已配置且参考文档已填充。

## 防护栏

- 绝不猜测引擎版本 — 始终通过 WebSearch 或用户确认验证
- 绝不未经询问覆盖已有的参考文档 — 追加或更新
- 如果参考文档已为不同的引擎存在，替换前询问
- 在进行 CLAUDE.md 编辑前始终向用户展示即将更改的内容
- 如果 WebSearch 返回模糊结果，向用户展示并让其决定
- 当用户选择了 **GDScript**：从附录 A1 精确复制 GDScript CLAUDE.md 模板。绝不向 Language 字段添加"C++ via GDExtension"。GDScript 项目可能使用 GDExtension，但它不是主要项目语言。路由表中的 `godot-gdextension-specialist` 在需要原生扩展时可用 — 它不会使 C++ 成为项目语言。

---

## 附录 A — Godot 语言配置

所有 Godot 特定的语言相关配置变体。引用自第 4 节和第 5 节 — 仅在 Godot 是所选引擎时相关。使用匹配第 4 节所选语言的子部分。

---

### A1. CLAUDE.md 技术栈模板

**GDScript：**
```markdown
- **Engine**: Godot [version]
- **Language**: GDScript
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline
```

> **防护栏**：使用此 GDScript 模板时，Language 字段应精确写为"`GDScript`" — 不添加任何其他内容。不要追加"C++ via GDExtension"或任何其他语言。下面的 C# 模板包含 GDExtension 是因为 C# 项目通常包装原生代码；GDScript 项目不这样做。

**C#：**
```markdown
- **Engine**: Godot [version]
- **Language**: C# (.NET 8+, primary), C++ via GDExtension (native plugins only)
- **Build System**: .NET SDK + Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline
```

**Both — GDScript + C#：**
```markdown
- **Engine**: Godot [version]
- **Language**: GDScript (gameplay/UI scripting), C# (performance-critical systems), C++ via GDExtension (native only)
- **Build System**: .NET SDK + Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline
```

---

### A2. 命名规范

**GDScript：**
- 类：PascalCase（例如 `PlayerController`）
- 变量/函数：snake_case（例如 `move_speed`）
- 信号：snake_case 过去式（例如 `health_changed`）
- 文件：snake_case 匹配类（例如 `player_controller.gd`）
- 场景：PascalCase 匹配根节点（例如 `PlayerController.tscn`）
- 常量：UPPER_SNAKE_CASE（例如 `MAX_HEALTH`）

**C#：**
- 类：PascalCase（`PlayerController`）— 也必须是 `partial`
- 公共属性/字段：PascalCase（`MoveSpeed`、`JumpVelocity`）
- 私有字段：`_camelCase`（`_currentHealth`、`_isGrounded`）
- 方法：PascalCase（`TakeDamage()`、`GetCurrentHealth()`）
- Signal 委托：PascalCase + `EventHandler` 后缀（`HealthChangedEventHandler`）
- 文件：PascalCase 匹配类（`PlayerController.cs`）
- 场景：PascalCase 匹配根节点（`PlayerController.tscn`）
- 常量：PascalCase（`MaxHealth`、`DefaultMoveSpeed`）

**Both — GDScript + C#：**
对 `.gd` 文件使用 GDScript 规范，对 `.cs` 文件使用 C# 规范。混合语言文件不存在 — 边界是按文件划分的。当不确定新系统应使用哪种语言时，询问用户并在 `technical-preferences.md` 中记录决策。

---

### A3. 引擎专家路由

**GDScript：**
```markdown
## Engine Specialists
- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-gdscript-specialist (all .gd files)
- **Shader Specialist**: godot-shader-specialist (.gdshader files, VisualShader resources)
- **UI Specialist**: godot-specialist (no dedicated UI specialist — primary covers all UI)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **Routing Notes**: Invoke primary for architecture decisions, ADR validation, and cross-cutting code review. Invoke GDScript specialist for code quality, signal architecture, static typing enforcement, and GDScript idioms. Invoke shader specialist for material design and shader code. Invoke GDExtension specialist only when native extensions are involved.

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.gd files) | godot-gdscript-specialist |
| Shader / material files (.gdshader, VisualShader) | godot-shader-specialist |
| UI / screen files (Control nodes, CanvasLayer) | godot-specialist |
| Scene / prefab / level files (.tscn, .tres) | godot-specialist |
| Native extension / plugin files (.gdextension, C++) | godot-gdextension-specialist |
| General architecture review | godot-specialist |
```

**C#：**
```markdown
## Engine Specialists
- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-csharp-specialist (all .cs files)
- **Shader Specialist**: godot-shader-specialist (.gdshader files, VisualShader resources)
- **UI Specialist**: godot-specialist (no dedicated UI specialist — primary covers all UI)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **Routing Notes**: Invoke primary for architecture decisions, ADR validation, and cross-cutting code review. Invoke C# specialist for code quality, [Signal] delegate patterns, [Export] attributes, .csproj management, and C#-specific Godot idioms. Invoke shader specialist for material design and shader code. Invoke GDExtension specialist only when native C++ plugins are involved.

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.cs files) | godot-csharp-specialist |
| Shader / material files (.gdshader, VisualShader) | godot-shader-specialist |
| UI / screen files (Control nodes, CanvasLayer) | godot-specialist |
| Scene / prefab / level files (.tscn, .tres) | godot-specialist |
| Project config (.csproj, NuGet) | godot-csharp-specialist |
| Native extension / plugin files (.gdextension, C++) | godot-gdextension-specialist |
| General architecture review | godot-specialist |
```

**Both — GDScript + C#：**
```markdown
## Engine Specialists
- **Primary**: godot-specialist
- **GDScript Specialist**: godot-gdscript-specialist (.gd files — gameplay/UI scripts)
- **C# Specialist**: godot-csharp-specialist (.cs files — performance-critical systems)
- **Shader Specialist**: godot-shader-specialist (.gdshader files, VisualShader resources)
- **UI Specialist**: godot-specialist (no dedicated UI specialist — primary covers all UI)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **Routing Notes**: Invoke primary for cross-language architecture decisions and which systems belong in which language. Invoke GDScript specialist for .gd files. Invoke C# specialist for .cs files and .csproj management. Prefer signals over direct cross-language method calls at the boundary.

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.gd files) | godot-gdscript-specialist |
| Game code (.cs files) | godot-csharp-specialist |
| Cross-language boundary decisions | godot-specialist |
| Shader / material files (.gdshader, VisualShader) | godot-shader-specialist |
| UI / screen files (Control nodes, CanvasLayer) | godot-specialist |
| Scene / prefab / level files (.tscn, .tres) | godot-specialist |
| Project config (.csproj, NuGet) | godot-csharp-specialist |
| Native extension / plugin files (.gdextension, C++) | godot-gdextension-specialist |
| General architecture review | godot-specialist |
```
