---
name: create-architecture
description: "从完成的 GDD 和引擎参考生成或填充主架构蓝图（architecture.md）。定义层级模型、层规则、场景结构、数据流和集成点。还生成建立架构治理所需的必需 ADR 列表。"
argument-hint: "[--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: opus
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 创建架构

本 Skill 生成技术设计的主蓝图——架构文档。它从
已批准的 GDD（状态：Approved 或 Designed）中提取材料，验证其
与引擎参考的一致性，并生成必需 ADR 的排序列表。
它是将设计转化为可执行架构的桥梁。

**前置条件：**
- `.claude/docs/technical-preferences.md` 必须在 `Engine:` 下有配置的引擎名（不是 `[TO BE CONFIGURED]`）
- `design/gdd/systems-index.md` 必须存在（通过 `/map-systems` 创建）
- 至少一个 GDD 必须存在（任何状态均可——只要有材料可以分析）

**输出：**
- `docs/architecture/architecture.md`（主蓝图）
- 必需 ADR 列表（带有建议标题的排序列表——不创建文件）

**何时运行：**
- 在 `/setup-engine` 之后
- 在艺术宝典完成后（艺术方向告知技术决策）
- 在有足够 GDD 可用以了解系统交互时
- 在 `/architecture-decision` 之前（蓝图告知需要哪些决策）

---

## 阶段 0：解析参数

解析审核模式（仅一次，本次运行中的所有 gate 生成均使用该值）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

完整检查模式参见 `.claude/docs/director-gates.md`。

---

## 阶段 1：加载所有输入

### 必需读取

| 文件 | 用途 | 如果缺失？ |
|------|---------|------------|
| `.claude/docs/technical-preferences.md` | 引擎名、性能预算、命名约定 | 错误退出——在架构之前运行 `/setup-engine` |
| `design/gdd/systems-index.md` | 系统列表、分类、依赖关系 | 错误退出——"运行 `/map-systems` 首先映射你的系统" |
| `docs/engine-reference/[engine]/VERSION.md` | 引擎约束、截止后功能 | 错误退出——"运行 `/setup-engine` 首先配置引擎参考" |
| `docs/engine-reference/[engine]/modules/*.md` | 引擎模块与设计系统匹配 | 如果缺失则警告但继续 |
| `design/gdd/game-concept.md` | 游戏支柱、平台（如已声明）、MDA 目标 | 如果缺失则警告但继续 |

### GDD 加载策略

1. **摘要扫描优先**。对所有 GDD 全文 Grep 搜索 `## Summary` 部分。
   仅完整读取匹配系统索引中 Foundation / Core / Engine 层分类的 GDD。
   对于纯 Feature 层的 GDD，摘要通常足够。

2. **依赖图**。从系统索引构建依赖图——
   每个系统的上游和下游依赖是什么。

3. **实体注册表**。读取 `design/registry/entities.yaml`（如果存在）。提取：
   - 实体计数和类别
   - 数据大小暗示（例如，'N 个实体类型 × M 个数据字段'）
   - 公式计数和变量复杂度
   - 这些告知数据模式设计和性能预算分配

4. **报告**。"已加载 [N] 个 GDD（[X] 个完整读取，[Y] 个摘要），已注册 [Z] 个实体，引擎：[名称 + 版本]"

---

## 阶段 2：架构设计 —— 游戏蓝图

以对话方式协作定义架构，对不可协商的约束和
可供选择的选项加以区分。

### 2a——预验证约束（简报中标记，而非提问）

这些是技术的给定项——在开始设计对话前向用户呈现它们
作为前提背景：

- **来自引擎参考的约束**：来自 VERSION.md 的模块结构
- **来自技术偏好的约束**：性能预算、命名约定、禁止模式
- **来自 GDD 的约束**：跨系统通信需求、数据持久化需求、
  平台特定功能需求

### 2b —— 层级模型与层规则

**GDD 告知架构，而非定义架构。**

系统索引分类系统，但架构层级模型由**架构师**（此 Skill）定义，基于：
- 引擎的模块边界（例如，Unreal 的 GAS 影响层级决策）
- 性能预算
- 设计模式和团队结构
- 系统索引中的依赖关系

典型的 4 层模型：
```
Foundation     ← 场景总线、输入、音频、存档系统（引擎内建 + 核心服务）
Core           ← 物理、碰撞、数据脚本对象（引擎 + 自定义抽象）
Feature        ← 游戏特定的玩法逻辑（自定义代码）
Presentation   ← UI、HUD、反馈、视效（玩家看到的内容）
```

系统索引中的每个系统都分配到一层。有些系统可能跨越层级
（例如，"UI"可能同时存在于 Core 和 Presentation 中）。

层规则是不可协商的约束——它们防止架构腐烂。

**Pattern 1（自动应用，不提问）：** Foundation → Core → Feature → Presentation 的依赖方向。永远不反向。

**Pattern 2（自动应用，不提问）：** 层内通信模式。
Foundation 层：本地通信（直接函数调用 / 信号单例）。
Core 和 Feature 层：通过 Foundation 层定义的总线的事件驱动跨系统通信。
Presentation 层：通过 Foundation 总线订阅状态变更。

**Pattern 3（自动应用，不提问）：** 性能护栏：
每位层级别的最大函数参数数量，
每个实体每帧的最大计算预算是多少。

这产生"层规则清单"——将通知 Stage 3b 清单生成的内容。

在定义层级分配后使用 `AskUserQuestion`：
- 提示语："层级分配完成。这 4 层及每层的系统符合你对架构的理解吗？"
- 选项：`[A] Yes —— 这些是正确的层 / [B] 调整一个系统的层 / [C] 调整层级边界 / 名称`

### 2c —— 数据流与场景结构

**这是与引擎特定架构师协商的协作环节。**

如果尚未配置引擎专家子 agent 类型，读取
`.claude/docs/technical-preferences.md` → `Engine Specialists` 部分。

如果尚未配置引擎特定子 agent，跳过 Task 委派并直接询问用户。

否则，提取引擎参考中已配置的主要架构师代理并生成一个 Task：

提供：
- 层级分配结果
- 设计系统的数据依赖（来自系统索引）
- 引擎模块
- 性能预算
- 从实体注册表提取的数据流模式

要解决的问题：

**数据所有权：** 哪个层/系统拥有每个主要的数据片段？谁可以
读取它，谁可以修改它？此系统使用哪个引擎存储模式（Resources vs.
Singletons vs. Scenes）？

**订阅：** 哪些系统订阅其他系统的变更？总线使用
引擎的原生信号系统还是自定义实现？

**加载与卸载：** 游戏状态转换期间，数据和系统如何加载
和卸载？场景结构是否支持系统索引中定义的
依赖关系？

**类型化事件模式：** 事件总线上的每个信号是否使用引擎特定的
类型化载荷？还是原始数据？利用引擎的变体/动态
类型系统还是静态类型接口？

**性能影响：** 每个设计决策如何影响性能？最繁忙路径
的调用次数估算是多少？

将架构师代理的输出呈现给用户，然后继续
以下内容。

使用 `AskUserQuestion` 处理所有设计决策点：
- 提示语："我对数据流设计的建议已准备就绪。继续进行场景结构吗？"
- 选项："Yes, proceed" / "I have a question about [topic]" / "I want a different approach"

### 2d —— 架构统一

在完稿前通过生成 `creative-director` 进行支柱对齐检查：
- 游戏支柱全文
- 来自 game-concept.md 的 MDA 目标文本
- 关键数据流决策

提问："这个架构在结构上是否服务于游戏支柱？是否有任何层级、
数据所有权或通信模式的选择与支柱的体验意图相反？"

如果 creative-director 标记了冲突，在询问用户如何处理冲突后
最终确定之前处理它。

---

## 阶段 3：生成必需 ADR 列表

架构蓝图确定后，生成建立架构治理所需的
必需 ADR 列表。

### 阶段 3a —— 识别 ADR 需求

对于每个需求，建议标题并固定域。按以下方式排序：

**基础层 ADR（首先创建——所有其他 ADR 依赖于此）：**
- 事件/信号架构 —— 跨系统通信的运作方式
- 场景结构/生命周期 —— 游戏状态的加载卸载方式
- 数据持久化/存档系统 —— 数据在会话间如何保存
- 服务定位器 / 依赖注入模式

**核心层 ADR（依赖基础层）：**
- 物理/碰撞检测架构
- 输入系统架构
- 音频系统集成

**关注点分离（横向 ADR——询问用户）：**

向用户呈现并逐项询问。使用 `AskUserQuestion`：
- 提示语："游戏有特定的 [系统名称] 吗？是否需要专用的 ADR？"
  - 这些回答 yes/no —— 如果 no 则跳过，如果 yes 则包含该 ADR

按顺序询问以下类别。对于每个类别，引用相关 GDD 计数，以便用户知道
该决策覆盖了多少个故事：

**选项 1 / 2（按顺序检查）：**
1. 多人游戏/网络架构 —— 如果系统索引中有任何多人游戏系统 → 自动包含，无需询问。
   否则："你的游戏有网络/多人游戏功能吗？" [任何多人系统都需询问]
2. AI / 行为系统 —— "[N] 个 AI 相关 GDD。此决策覆盖 [M] 个故事。需要专用 AI 架构 ADR 吗？"
3. 自定义物理/移动 —— "[N] 个移动/物理 GDD。需要专用物理架构 ADR 吗？"
4. 库存/物品系统 —— "[N] 个库存/物品 GDD。需要专用物品系统 ADR 吗？"
5. 对话/任务系统 —— "[N] 个对话/任务 GDD。需要专用对话/任务架构 ADR 吗？"
6. 程序化生成 —— "[N] 个程序化/生成 GDD。需要专用程序化生成 ADR 吗？"
7. 性能/分析 —— "你需要性能预算/分析 ADR 吗？"
8. 本地化 —— "你需要本地化/国际化 ADR 吗？"

如果其中任何一项为 yes → 包含基础层和核心层列表中对应的 ADR。

**表现层 ADR（最后创建）：**
- UI / HUD 架构
- 反馈系统（音频/视觉反馈策略）

**必需 ADR 完整列表：**

对于每个条目：
```
### 层名称：[ADR 标题]
域：[物理/渲染/UI/等]
优先级：[立即/近期/稍后]
覆盖的故事数：[来自系统索引的 N——基础为 0]
建议：[一行描述为什么需要以及涵盖什么范围]
```

总计："[N] 个必需 ADR： [X] 个基础层，[Y] 个核心层，[Z] 个横向，[W] 个表现层"

---

## 阶段 3b：生成控制清单

输出 `docs/architecture/control-manifest.md`。

清单从完成的架构定义生成，并在 `/dev-story` 阶段 2 实施期间
检查。

清单在最后更新头部包含该架构文档的提交日期。
这使故事文件能够在实现期间检测其记录的清单版本
是否已过时。

清单结构（参见 `.claude/docs/templates/control-manifest.md`）：

```markdown
# 控制清单

最后更新：[日期]（来自此架构文档最后一次提交的提交日期）
架构来源：docs/architecture/architecture.md 的此提交

## 清单版本

清单版本为此文档头部中 `Last Updated:` 字段的YYYY-MM-DD值。
此值必须与 `docs/architecture/architecture.md` 的最近提交日期匹配。

---

## 层规则

对于每个架构层：

### 层级名称
- **角色**：[该层做什么]
- **必需模式**：[该层必须使用的模式]
- **禁止模式**：[该层绝对不能做的]
- **性能护栏**：[该层的限制]
- **引擎规则**：[引擎/平台特定规则]
- **文件组织**：[该层代码存放位置]
```

清单是**衍生品**——架构文档的提交日期是权威的。
不要生成单独的"清单版本号"——仅使用架构的 git 提交日期。

**生成清单后**：静默追加清单头部的 `Last Updated` 字段到
`production/session-state/active.md`：

    ## 会话提取 —— /create-architecture [日期]
    - 清单已生成：docs/architecture/control-manifest.md（版本：[YYYY-MM-DD]）

确认："控制清单已写入 `docs/architecture/control-manifest.md`。"

---

## 阶段 3c：生成架构门签核

**审核模式检查** —— 在生成 TD-ARCH-BLUEPRINT 之前应用：
- `solo` → 跳过。注明："TD-ARCH-BLUEPRINT 已跳过——单人模式。" 继续阶段 4。
- `lean` → 跳过（不是 PHASE-GATE）。注明："TD-ARCH-BLUEPRINT 已跳过——精简模式。" 继续阶段 4。
- `full` → 正常生成。

**架构蓝图定稿后**，使用 gate **TD-ARCH-BLUEPRINT**（`.claude/docs/director-gates.md`）生成 `technical-director`：

传入：架构文档内容、GDD 摘要、系统索引。

将裁决记录在架构文档的头部：
`> **技术指导审查 (TD-ARCH-BLUEPRINT)**：APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date]`

---

## 阶段 4：产生蓝图文档

将完成的架构组装到 `docs/architecture/architecture.md`。在询问写入审批前，
在对话中内联呈现。

使用 `.claude/docs/templates/architecture.md`。

**切勿在没有用户审批的情况下写入文件。**

写入后，呈现摘要：

> 架构蓝图已写入 `docs/architecture/architecture.md`。
> **[N] 个必需 ADR**： [计数]
> **下一步**：从最高优先级的 ADR 开始运行 `/architecture-decision [标题]`。
> 优先级顺序：Foundation → Core → Feature → Presentation。
> 每个 ADR 编写完成后，重新运行 `/architecture-review` 以验证架构覆盖度。

---

## 阶段 5：结束下一步

使用 `AskUserQuestion`：
- 提示语："架构蓝图和控制清单已完成。你想接下来做什么？"
- 选项：
  - `[A] 从最高优先级开始运行 /architecture-decision（推荐）`
  - `[B] 运行 /architecture-review 验证覆盖度`
  - `[C] 运行 /gate-check pre-production`
  - `[D] 在此停止`

---

## 协作协议

- 架构是协商的，而不是宣布的——在做出技术选择前提出设计问题；使用子 agent 进行引擎特定协商
- 当架构决策影响设计时呈现设计回环——如果架构选择使 GDD 需求不可能实现或成本过高，明确标记
- 控制清单是实时治理——它告诉每个故事在实现期间允许什么和禁止什么
- 在完稿前始终呈现草案
- 始终获得写入审批——在用户说 yes 之前不要写入文件
