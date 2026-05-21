---
name: reverse-document
description: "从现有实现生成设计或架构文档。从代码/原型反向工作，以创建缺失的规划文档。"
argument-hint: "<类型> <路径>（例如 'design src/gameplay/combat' 或 'architecture src/core'）"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 反向文档生成

此 Skill 分析现有实现（代码、原型、系统）并生成相应的设计或架构文档。在以下情况使用：
- 你在编写功能时没有先写设计文档
- 你继承了一个没有文档的代码库
- 你原型化了一个机制，需要将其规范化
- 你需要记录现有代码背后的"为什么"

---

## 工作流程

## 第 1 阶段：解析参数

**格式**：`/reverse-document <类型> <路径>`

**类型选项**：
- `design` → 生成游戏设计文档（GDD 部分）
- `architecture` → 生成架构决策记录（ADR）
- `concept` → 从原型生成概念文档

**路径**：要分析的目录或文件
- `src/gameplay/combat/` → 所有与战斗相关的代码
- `src/core/event-system.cpp` → 特定文件
- `prototypes/stealth-mech/` → 原型目录

**示例**：
```bash
/reverse-document design src/gameplay/magic-system
/reverse-document architecture src/core/entity-component
/reverse-document concept prototypes/vehicle-combat
```

## 第 2 阶段：分析实现

**阅读并理解代码/原型**：

**对于设计文档（GDD）：**
- 识别机制、规则、公式
- 提取游戏数值（伤害、冷却时间、范围）
- 查找状态机、能力系统、进度系统
- 检测代码中处理的边缘情况
- 映射依赖关系（哪些系统交互？）

**对于架构文档（ADR）：**
- 识别模式（ECS、单例、观察者等）
- 理解技术决策（线程、序列化等）
- 映射依赖关系和耦合
- 评估性能特征
- 查找约束和权衡

**对于概念文档（原型分析）：**
- 识别核心机制
- 提取涌现玩法模式
- 记录什么有效 vs. 什么无效
- 查找技术可行性洞察
- 记录玩家幻想/感受

## 第 3 阶段：提出澄清问题

**不要**仅仅描述代码。**要询问**意图：

**设计问题**：
- "我看到一个 [resource] 系统在 [activity] 期间消耗。这是用于：
  - 节奏控制（防止滥用）？
  - 资源管理（策略深度）？
  - 还是其他？"
- "[mechanic] 似乎是核心。这是一个核心支柱，还是辅助功能？"
- "[value] 随 [factor] 指数级增长。是有意的设计，还是需要重新平衡？"

**架构问题**：
- "你正在使用服务定位器模式。选择它是为了：
  - 可测试性（模拟依赖）？
  - 解耦（减少硬引用）？
  - 还是继承自现有代码？"
- "我看到手动内存管理而不是智能指针。是性能要求，还是遗留代码？"

**概念问题**：
- "原型强调潜行而非战斗。这是预期的支柱吗？"
- "玩家似乎利用抓钩来提速。是特性还是 Bug？"

## 第 4 阶段：呈现发现

在起草文档之前，展示你发现了什么：

```
我已分析 [path]。以下是我的发现：

已实现的机制：
- [mechanic-a] 带有 [property]（例如时间窗口、冷却时间）
- [mechanic-b]（例如两个状态之间的交互）
- [resource] 系统（在 [action] 时消耗，在 [condition] 时恢复）
- [state] 系统（累积，触发 [effect]）

发现的公式：
- [Output] = [使用发现变量的公式]
- [Secondary output] = [公式]

意图不明确的领域：
1. [Resource] 系统 — 节奏控制还是资源管理？
2. [Mechanic] — 核心支柱还是辅助功能？
3. [Value] 增长 — 有意的设计还是需要调优？

在起草设计文档之前，你能澄清这些要点吗？
```

等待用户澄清意图后再起草。

## 第 5 阶段：使用模板起草文档

根据类型使用相应的模板：

| 类型 | 模板 | 输出路径 |
|------|----------|-------------|
| `design` | `templates/design-doc-from-implementation.md` | `design/gdd/[system-name].md` |
| `architecture` | `templates/architecture-doc-from-code.md` | `docs/architecture/[decision-name].md` |
| `concept` | `templates/concept-doc-from-prototype.md` | `prototypes/[name]/CONCEPT.md` 或 `design/concepts/[name].md` |

**草稿结构**：
- 捕获**现有内容**（机制、模式、实现）
- 记录**存在原因**（与用户澄清的意图）
- 识别**缺失内容**（未处理的边缘情况、设计中的缺口）
- 标记**后续工作**（平衡调优、缺失功能）

## 第 6 阶段：展示草稿并请求批准

**协作协议**：
```
我已根据你的代码和澄清起草了 [system-name] 设计文档。

[展示关键部分：概述、机制、公式、设计意图]

我添加的内容：
- 根据你的澄清，将 [mechanic] 记录为"[intent]"
- 添加了代码中不存在的边缘情况（例如，[resource] 在 [action] 中途归零怎么办？）
- 标记了平衡问题：[scaling type] 增长在 [boundary condition]

标记为未完成的部分：
- "[System] 与 [other-system] 的交互"（尚未完全实现）
- "[Variant or feature]"（目前仅实现了 [subset]）

我可以将此写入 design/gdd/[system-name].md 吗？
```

等待批准。用户可能在写入前要求修改。

## 第 7 阶段：写入文档及元数据

获得批准后，写入带有特殊标记的文件：

```markdown
---
status: reverse-documented
source: [path/]
date: [today]
verified-by: [User name]
---

# [System Name] 设计

> **注意**：本文档是从现有实现反向工程得来。
> 它记录了当前行为和已澄清的设计意图。在某些实现
> 不完整或意图不明确的地方，部分内容可能不完整。

[文档其余部分...]
```

## 第 8 阶段：标记后续工作

写入后，建议后续步骤：

```
✅ 已写入 design/gdd/combat-system.md

建议的后续工作：
1. 对战斗公式运行 /balance-check（指数增长问题）
2. 为耐力系统架构决策创建 ADR
3. 实现缺失的边缘情况：
   - 连招中途耐力耗尽的行为
   - 闪避过程中的受击状态
4. 实现武器变体时扩展设计文档

现在你想处理其中任何一项吗？
```

---

## 模板选择逻辑

| 如果分析... | 使用模板... | 因为... |
|----------------|-----------------|------------|
| `src/gameplay/*` | design-doc-from-implementation.md | 游戏机制 → GDD |
| `src/core/*`、`src/ai/*` | architecture-doc-from-code.md | 核心系统 → ADR |
| `prototypes/*` | concept-doc-from-prototype.md | 实验 → 概念文档 |
| `src/networking/*` | architecture-doc-from-code.md | 技术系统 → ADR |
| `src/ui/*` | design-doc-from-implementation.md | UI/UX → 设计规格 |

---

## 示例会话：反向文档一个系统

```
用户：/reverse-document design src/gameplay/[system]

Agent：我将分析你的 [system] 实现来创建设计文档。
       [读取代码，发现机制、公式]

Agent：我已分析 src/gameplay/[system]/。以下是我的发现：
       [展示机制、公式、不明确领域]

       在起草之前，你能澄清：
       1. [Resource] 系统的意图？
       2. [mechanic] 是核心支柱吗？
       3. [Value] 增长 — 有意的还是需要调优？

用户：1. [Resource] 用于节奏控制，防止 [unwanted behavior]
      2. [mechanic] 是核心 — 我想要 [design intent]
      3. 是的，指数增长太多了，应该是线性的

Agent：完美，这明确了愿景。让我起草设计文档。
       [展示带有澄清意图的草稿]

       我可以将此写入 design/gdd/[system-name].md 吗？

用户：是的，写入。

Agent：✅ 已写入 design/gdd/[system-name].md
       ✅ 标记为 [REVERSE-DOCUMENTED]
       ✅ 标记 [value] 增长需重新平衡

       下一步：
       - 将 [formula] 更新为 [corrected scaling]
       - 运行 /balance-check 验证 [curve]
       - 在 game-pillars.md 中将 [mechanic] 记录为核心支柱
```

---

## 协作协议

此 Skill 遵循协作设计原则：

1. **先分析**：阅读代码，理解实现
2. **询问意图**：询问"为什么"，而不仅仅是"是什么"
3. **呈现发现**：展示发现，突出不明确领域
4. **用户澄清**：区分意图与意外
5. **起草文档**：基于现实 + 意图创建文档
6. **展示草稿**：展示关键部分，解释添加内容
7. **获得批准**："我可以写入 [filepath] 吗？"获得批准：判定：**COMPLETE** — 文档已生成。被拒绝：判定：**BLOCKED** — 用户拒绝写入。
8. **标记后续**：建议相关工作，不自动执行

**绝不假设意图。在记录"为什么"之前始终先询问。**
