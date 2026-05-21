<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 示例会话：/gate-check 阶段转换 —— 系统设计 → 技术搭建

**上下文：** 独立开发者，第 5 周末。系统设计阶段感觉已完毕 —— 6 份 MVP GDD 已写，交叉审查完成，引擎已搭建。用户希望正式推进到技术搭建阶段。

**初始状态：**
- `production/stage.txt` —— 当前为 `systems-design`
- `design/gdd/systems-index.md` —— 列出了 6 个 MVP 系统，全部标记为 `Status: GDD Complete`
- `design/gdd/` —— 6 个 GDD 文件存在
- `design/gdd/gdd-cross-review-2026-03-10.md` —— 交叉审查报告，判定：CONCERNS（1 个低优先级记录）
- 引擎已配置（Godot 4.6，`/setup-engine` 已完成）

**会话时长：** 约 20 分钟
**轮次：** 7
**结果：** 门禁通过，`stage.txt` 更新为 `technical-setup`，清晰列出了接下来要做什么

---

## 第 1 轮：用户发起门禁检查

**用户：**
> /gate-check

## 第 2 轮：Agent 检测当前阶段并运行检查

**Agent（通过 /gate-check）：**
> 正在读取 `production/stage.txt` —— 当前阶段：**systems-design**
>
> 正在运行门禁：**系统设计 → 技术搭建**
>
> ---
> **所需产物清单：**
>
> | 产物 | 要求 | 状态 |
> |----------|-------------|--------|
> | `design/gdd/systems-index.md` | 存在，所有 MVP 系统已列出 | ✅ |
> | 逐系统 GDD | 所有 MVP 系统有 GDD | ✅（6/6） |
> | 每个 GDD 的 `/design-review` | 每个 GDD 已经过审查 | ✅（找到 6/6 条审查评论） |
> | 跨 GDD 审查报告 | `design/gdd/gdd-cross-review-*.md` 存在 | ✅ |
> | 交叉审查判定 | PASS 或 CONCERNS（非 FAIL） | ✅ CONCERNS |
> | 引擎已配置 | `production/stage.txt` 或 CLAUDE.md 引擎条目 | ✅ Godot 4.6 |
>
> ---
> **内容扫描：**
>
> 正在检查 GDD 完整性（每份 8 个必需节）……
>
> | GDD | 缺失节 |
> |-----|-----------------|
> | movement-system.md | 无 ✅ |
> | stamina-system.md | 无 ✅ |
> | combat-system.md | 无 ✅ |
> | inventory-system.md | 无 ✅ |
> | crafting-system.md | 无 ✅ |
> | exploration-system.md | 无 ✅ |
>
> ---
> **交叉审查关注点（来自 `gdd-cross-review-2026-03-10.md`）：**
>
> 1. ⚠️ 低 —— Crafting 和 inventory 各自独立定义了"物品堆叠大小"，且默认值不同（crafting：99，inventory：64）。应有一个系统作为权威；另一个引用它。非阻塞 —— 可在 ADR 中解决。
>
> ---
> **判定：PASS**
>
> 所有必需产物已存在。交叉审查关注点为低严重性，可在技术搭建期间通过 ADR 解决。这是此阶段的正常发现。
>
> **我可以将 `production/stage.txt` 推进到 `technical-setup` 吗？**

## 第 3 轮：用户确认

**用户：**
> 可以，推进它。

## 第 4 轮：Agent 更新阶段并呈现后续步骤

**Agent：**
> 已更新 `production/stage.txt` → `technical-setup`
>
> ---
> **你现在处于：技术搭建**
>
> 此阶段在正式编码开始前建立技术基础。你的目标是获得一份完整、已批准的架构，以便在预制作阶段编写的每个故事都有清晰、明确的技术指导。
>
> **此阶段必需的步骤（按顺序）：**
>
> 1. **`/create-architecture`** —— 编写主架构文档。涵盖系统分解、数据流、层次边界和模块职责。
>
> 2. **`/architecture-decision`（每个重要技术选择一份）** —— 至少包括：
>    - 渲染方案（2D 相机、视口等）
>    - 存档/读档策略
>    - 音频总线架构
>    - 交叉审查中的"物品堆叠大小权威"问题（crafting vs inventory）
>
> 3. **`/architecture-review`** —— 验证所有 ADR 的完整性、依赖排序和 GDD 可追溯性。生成 TR-registry。
>
> 4. **`/create-control-manifest`** —— 将已接受的 ADR 转换为平面程序员规则表。实现 Agent 在编码时将参考这些规则。
>
> 5. **`/gate-check`** —— 技术搭建 → 预制作门禁。要求：架构文档、所有 ADR 已接受、Control Manifest、依赖排序已解决。
>
> **可选的但建议：**
> - 如果你有任何打算继续使用的原型代码，运行 `/tech-debt` 扫描
> - 如果你尚未获取 Godot 4.6 API 快照，重新运行 `/setup-engine`
>
> **提示：** 从物品堆叠大小冲突的 `/architecture-decision` 开始。这是一个快速胜利，能在后续两个 ADR 中造成歧义之前关闭一个悬而未决的问题。

## 第 5 轮：用户询问交叉审查关注点

**用户：**
> 对于堆叠大小冲突的 ADR，我实际写什么？

## 第 6 轮：Agent 给出建议

**Agent：**
> ADR 的决策是：**哪个系统拥有规范的 `max_stack_size` 值？**
>
> 两个选项供考虑：
>
> **方案 A：Inventory 拥有它**
> - `ItemData` 资源（由 inventory 拥有）获得 `max_stack_size: int = 64`
> - Crafting 系统从 `ItemData` 读取，永远不设置自己的值
> - 优点：inventory 是所有物品属性的真实来源
> - 缺点：crafting 团队需要知道去查阅 inventory 数据
>
> **方案 B：Item 数据资源拥有它（共享资源）**
> - `ItemData.max_stack_size` 是两个系统的权威
> - crafting 和 inventory 都从 `ItemData` 导入
> - 优点：单一来源，crafting 和 inventory 模块之间无耦合
> - 缺点：共享数据层中多了一件事
>
> 大多数工作室在超过 2 个系统触及物品数据时会选择 B（共享资源）。但对于独立项目来说，两种方式都有效。
>
> 运行 `/architecture-decision`，它将引导你完成 ADR 格式，包括将此 ADR 链接回两个 GDD 的依赖节。

## 第 7 轮：用户收尾

**用户：**
> 明白了。我先从这个开始 `/architecture-decision`。

**Agent：**
> 好的起点。ADR 将记录决策、理由和它解决的 GDD 需求 —— 以便数月后你写代码时，理由被保留下来。
>
> 你的阶段门禁已记录。在技术搭建期间随时运行 `/help` 以查看你对照所需清单的当前进度。

---

## 本示例展示了什么

- **门禁检查是自动化的，而非手动的**：Agent 读取产物并检查它们 —— 用户不填写表单
- **CONCERNS ≠ FAIL**：交叉审查关注点是低严重性并通过了门禁。FAIL 则需要在推进前解决。
- **Stage.txt 是权威来源**：状态行、`/help` 和所有 skill 都从 `production/stage.txt` 读取 —— 在此处更新它会改变每个后续 skill 看到的内容
- **后续步骤是阶段特定的**：Agent 不给通用的"好运" —— 它专门为技术搭建提供有序的清单
- **门禁检查呈现延续性工作**：堆叠大小冲突是一个交叉审查记录；门禁检查确保它成为一个具体的 ADR 而不是被丢失
- **一次门禁一次推进**：用户明确确认了推进。门禁不会自动推进；需要人工确认。
