<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 示例会话：/adopt — 棕地项目上手

**上下文：** 开发者在发现本 Agent 系统之前已经开发了 3 个月的游戏。他们有代码、一些设计文档和粗略笔记 —— 但格式都不符合各 skill 使用的标准。

**初始状态：**
- `src/gameplay/` — 约 4000 行 Godot 4.6 GDScript 代码
- `design/` — 3 个包含粗略设计笔记的 markdown 文件（非 GDD 模板格式）
- 没有 `design/gdd/` 目录
- 没有 `docs/architecture/` 目录
- 没有 `production/` 目录
- 没有 `design/gdd/systems-index.md`
- CLAUDE.md 存在（引擎已配置：Godot 4.6）

**会话时长：** 约 30 分钟
**轮次：** 8
**结果：** 编写了采纳计划，最紧急的缺口（缺少系统索引）立即修复

---

## 第 1 轮：用户调用 /adopt

**用户：**
> /adopt

## 第 2 轮：Agent 检测项目状态

**Agent（technical-director，通过 /adopt，上下文：fork）：**
> 正在运行棕地审计……
>
> **阶段 1：项目状态检测**
>
> | 产物类别 | 找到 | 备注 |
> |------------------|-------|-------|
> | 引擎配置 | ✅ | CLAUDE.md 中配置了 Godot 4.6 |
> | 源代码 | ✅ | `src/gameplay/` 中约 4000 行 |
> | 设计文档 | ⚠️ | `design/` 中有 3 个文件，非 GDD 格式 |
> | 架构文档 | ❌ | 缺少 `docs/architecture/` |
> | 系统索引 | ❌ | 缺少 `design/gdd/systems-index.md` |
> | 制作跟踪 | ❌ | 缺少 `production/` 目录 |
> | sprint/故事文件 | ❌ | 无 |
>
> **阶段 2：格式审计（现有文件）**
>
> 正在检查 3 个设计文件的内部结构……
>
> *`design/combat-notes.md`：*
> - 包含非正式笔记，缺少 GDD 模板各节
> - 包含：一些规则描述、一个伤害公式、粗略的平衡数值
> - 缺少 GDD 模板中的：概述、玩家幻想、边界情况、依赖、可调参数、验收标准（8 节中缺 6 节）
>
> *`design/crafting-ideas.md`：*
> - 头脑风暴式笔记，无结构
> - 无公式，无验收标准
> - 代表早期概念思维 —— 作为 GDD 的输入有价值，但还不是 GDD
>
> *`design/inventory.md`：*
> - 最接近 GDD —— 有概述和规则两节
> - 缺少：玩家幻想、公式、边界情况、可调参数、验收标准（8 节中缺 5 节）
>
> **阶段 3：缺口分类**
>
> | 缺口 | 严重性 | 原因 |
> |-----|----------|--------|
> | 无系统索引 | 阻塞 | `/design-system`、`/create-stories`、`/gate-check` 都需要它 |
> | GDD 文件非模板格式 | 高 | skill 无法从格式不正确的 GDD 中引用 TR-ID |
> | 无架构文档 | 高 | 无法运行 `/architecture-review` 或 `/create-control-manifest` |
> | 无制作跟踪 | 中 | sprint 和故事 skill 无法工作，但制作阶段之前还不需要 |
> | `design/crafting-ideas.md` — 早期 GDD 内容 | 低 | 作为输入有价值；在阻塞任何工作前需要完整 GDD 编写 |

## 第 3 轮：Agent 呈现迁移计划

**Agent：**
> **阶段 4：迁移计划**
>
> 7 个有序步骤，将你的项目带入完全对齐状态。绝不覆盖你现有的内容 —— 每个步骤只填补缺口。
>
> | # | 步骤 | Skill | 优先级 | 备注 |
> |---|------|-------|----------|-------|
> | 1 | 创建 `design/gdd/systems-index.md` | `/map-systems` 或 `/adopt` 内联 | 阻塞 | 解锁所有下游 skill |
> | 2 | 改造 `design/inventory.md` → GDD 格式 | `/design-system retrofit design/inventory.md` | 高 | 添加 5 个缺失节，保留你现有内容 |
> | 3 | 改造 `design/combat-notes.md` → GDD 格式 | `/design-system retrofit design/combat-notes.md` | 高 | 添加 6 个缺失节 |
> | 4 | 转换 `design/crafting-ideas.md` → 完整 GDD | `/design-system crafting`（全新编写，使用 idea 作为输入） | 中 | 非改造 —— 太非正式而无法改造 |
> | 5 | 从现有代码创建架构 ADR | `/reverse-document` + `/architecture-decision` | 高 | 捕获代码中已做出的决策 |
> | 6 | 创建主架构文档 | `/create-architecture` | 高 | 在 ADR 之后 |
> | 7 | 设置制作跟踪 | `/sprint-plan new` | 中 | 在架构阶段之后 |
>
> **重要：** 步骤 1 必须在任何其他步骤之前完成。其余步骤可以并行或根据你的优先级重新排序。
>
> 我可以将此计划写入 `docs/adoption-plan-2026-03-12.md` 吗？

**用户：**
> 可以。写吧。

**Agent 写入采纳计划。**

## 第 4 轮：Agent 提议修复最紧急的缺口

**Agent：**
> 阻塞性缺口是缺少 `design/gdd/systems-index.md`。
>
> 我现在可以通过读取你现有的代码和设计文档来推断你已构建的系统，从而立即创建一个。这比从头运行 `/map-systems` 更快 —— 我会基于已存在的内容填充它，然后你确认或调整。
>
> 你想让我现在做吗？

**用户：**
> 可以，做吧。

## 第 5 轮：Agent 读取代码库并起草系统索引

**Agent：**
> 正在读取 `src/gameplay/` 以推断系统……
>
> 在代码中发现了这些系统边界：
>
> - `src/gameplay/combat/` — 伤害计算、命中检测、状态效果
> - `src/gameplay/inventory/` — 物品管理、重量、堆叠
> - `src/gameplay/crafting/` — 配方查找、结果生成（引用 inventory）
> - `src/gameplay/movement/` — CharacterBody2D、地形修正器（被 combat 引用用于站位）
> - `src/gameplay/ui/` — HUD、背包界面、对话框
> - `src/gameplay/world/` — 瓦片地图、地形类型、区块加载
>
> **系统索引草案：**
>
> | 系统 | 类别 | 优先级 | 依赖 | GDD 状态 |
> |--------|----------|----------|--------------|------------|
> | 移动 | 基础 | MVP | 无 | ❌ 缺失 |
> | 世界/地形 | 基础 | MVP | 移动 | ❌ 缺失 |
> | 战斗 | 核心 | MVP | 移动 | ⚠️ 需要改造 |
> | 背包 | 核心 | MVP | 无 | ⚠️ 需要改造 |
> | 合成 | 功能 | MVP | 背包 | ❌ 仅有早期文档 |
> | UI / HUD | 表现 | MVP | 战斗、背包、移动 | ❌ 缺失 |
>
> 这样对吗？有没有我遗漏或分类错误的？

**用户：**
> 看起来对了。添加一个耐力系统 —— 它在 combat/ 里，但应该是一个独立的系统。

**Agent：**
> 已将 Stamina 添加为核心 / MVP 系统：
>
> | 耐力 | 核心 | MVP | 移动、战斗 | ❌ 缺失 |
>
> 已更新依赖：移动依赖耐力（移动会消耗它）。
>
> 我可以将此写入 `design/gdd/systems-index.md` 吗？

## 第 6 轮：用户批准

**用户：**
> 可以

**Agent 写入 `design/gdd/systems-index.md`。**

## 第 7 轮：Agent 展示现在解锁了什么

**Agent：**
> 已创建 `design/gdd/systems-index.md`。
>
> **阻塞性缺口已解决。** 以下 skill 现在可以运行：
>
> - ✅ `/design-system [名称]` —— 为任意系统提供引导式 GDD 编写
> - ✅ `/design-system retrofit [路径]` —— 填补现有文档中缺失的节
> - ✅ `/gate-check` —— 现在有了可供验证的系统索引
> - ✅ `/help` —— 现在可以显示正确的阶段工作流
>
> **建议的后续步骤（来自采纳计划）：**
>
> 1. 运行 `/design-system retrofit design/inventory.md` —— 你现有最完整的文档，最容易见效
> 2. 运行 `/design-system retrofit design/combat-notes.md`
> 3. 运行 `/design-system crafting` —— 使用你的 idea 文件作为输入编写合成 GDD
>
> 这 3 步完成后，你将拥有 7 个系统中 5 个的完整 GDD。然后在架构工作前运行 `/review-all-gdds` 来捕获跨系统一致性问题的。

## 第 8 轮：用户确认计划

**用户：**
> 完美。我先从背包改造开始。

**Agent：**
> 运行：
> ```
> /design-system retrofit design/inventory.md
> ```
>
> 该 skill 会检测你现有的概述和规则两节，向你展示 8 节中缺少哪些，并仅对缺口运行逐节循环。你现有的内容不会被触及。

---

## 本示例展示了什么

- **格式审计，而非存在性审计**：`/adopt` 不仅检查文件是否存在 —— 它检查文件的内部结构是否与各 skill 的预期匹配。一个名为 `gdd.md` 但没有模板各节的文件被标记为缺口。
- **迁移，而非替换**：现有内容永远不会被覆盖。计划只填补缺口。
- **阻塞性缺口优先呈现**：缺少的系统索引被识别为阻塞性，因为它阻止了大多数 skill 的正常运作。
- **紧急缺口的内联创建**：Agent 不仅报告缺口，还在同一次会话中提供立即修复。
- **从代码中推断**：系统索引从代码库结构中引导生成，而非从零写起 —— 棕地代码本就包含答案。
- **改造 vs. 全新编写**：`/design-system retrofit` 处理已有但不完整的文档；完整 `/design-system` 处理全新的文档。采纳计划区分了每种文件适用哪个。
- **上下文：fork**：`/adopt` 在分叉上下文中运行，避免用大量跨代码库的文件读取污染主会话。
