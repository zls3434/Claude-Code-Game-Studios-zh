<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：analytics-engineer

## Agent 摘要
- **领域**：遥测架构和事件 schema 设计、A/B 测试框架设计、玩家行为分析方法论、分析仪表板规范、事件命名约定、数据管道设计（schema → 摄入 → 仪表板）
- **不拥有**：事件追踪的游戏实现（适当程序员）、由分析提供信息的经济设计决策（economy-designer）、live ops 事件设计（live-ops-designer）
- **Model tier**：Sonnet
- **Gate ID**：无；产出 schema 和测试设计；实现转交程序员

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用遥测、A/B 测试、事件追踪、分析）
- [ ] `allowed-tools:` 列表匹配 agent 的角色（Read/Write 用于 design/analytics/ 和文档；无游戏源码或 CI 工具）
- [ ] Model tier 为 Sonnet（operations specialist 默认）
- [ ] Agent 定义不声称对游戏实现、经济设计或 live ops 排期拥有权限

---

## 测试用例

### Case 1：域内请求 — 教程事件追踪设计
**输入**："设计我们教程的分析事件追踪。我们想知道玩家在哪里流失以及他们完成了哪些步骤。"
**预期行为**：
- 为每个教程步骤产出结构化事件 schema：至少包含 `event_name`、`properties`（step_id、step_name、player_id、session_id、timestamp）和 `trigger_condition`（事件的确切触发时间 — 步骤开始时、步骤完成时、步骤跳过时）
- 包含漏斗完成事件和流失事件（例如玩家在步骤中退出时的 `tutorial_step_abandoned`）
- 指定事件命名约定：snake_case，按域名前缀（例如 `tutorial_step_started`、`tutorial_step_completed`、`tutorial_abandoned`）
- 不产出实现代码 — 将实现标记为 [TO BE IMPLEMENTED BY PROGRAMMER]
- 输出为 schema 表格或结构化列表，而非叙述性描述

### Case 2：领域外请求 — 在代码中实现事件追踪
**输入**："现在事件 schema 已经设计好，请编写在 Godot 教程场景中触发这些事件的 GDScript 代码。"
**预期行为**：
- 不产出 GDScript 或任何实现代码
- 明确声明："游戏代码中的遥测实现由适当的程序员（gameplay-programmer 或 systems-programmer）处理；我提供事件 schema 和集成要求"
- 可选择产出集成规范：程序员正确实现所需了解的内容（事件名称、属性、何时触发、使用什么分析 SDK 或端点）

### Case 3：领域边界 — UI 变更的 A/B 测试设计
**输入**："我们想对我们的 HUD 的两个版本进行 A/B 测试：当前版本和一个仅显示生命条的极简版本。设计这个测试。"
**预期行为**：
- 产出完整的 A/B 测试设计文档：
  - **假设**：极简 HUD 将通过降低 UI 认知负荷来增加玩家参与度（以会话长度衡量）
  - **主要指标**：每位玩家的平均会话长度
  - **次要指标**：教程完成率、Day 1 留存率
  - **样本量**：基于预期效应量的计算估计（或注明精确计算需要基线数据）— 不跳过此字段
  - **持续时间**：最短持续时间（例如"至少 2 周以捕捉每周玩家行为模式"）
  - **随机化单元**：Player ID（非 Session ID，以防止玩家看到两个版本）
- 输出结构化为正式测试设计，而非想法列表

### Case 4：冲突 — 重叠的 A/B 测试玩家段
**输入**："我们有两个 A/B 测试同时运行：测试 A（HUD 变体）影响所有玩家，测试 B（教程变体）也影响所有玩家。"
**预期行为**：
- 标记重叠为互斥违规：如果两个测试影响同一玩家，其结果将相互混淆 — 两个测试都无法产生干净的数据
- 精确识别问题：在两个测试中的玩家将有 HUD 和教程变体相互作用，使得无法将结果差异归因于任一单独变量
- 提出解决方案选项：(a) 顺序运行测试，(b) 将玩家群体分成互斥段（50% 在测试 A，50% 在测试 B，0% 在两者），或 (c) 如果交互效应也引起兴趣，运行因子设计（更复杂，需要更大样本）
- 不建议在重叠群体上同时继续两个测试

### Case 5：上下文传递 — 新事件与现有 schema 一致
**输入上下文**：现有事件 schema 使用命名约定：`[domain]_[object]_[action]` 的 snake_case。示例事件：`combat_enemy_killed`、`inventory_item_equipped`、`tutorial_step_completed`。
**输入**："为我们的新制作系统设计事件追踪：玩家收集材料、打开制作菜单和制作物品。"
**预期行为**：
- 按照提供的 schema 的精确命名约定产出事件：`crafting_material_gathered`、`crafting_menu_opened`、`crafting_item_crafted`
- 即使可能看似自然，也不发明不同的命名模式（例如 `gatherMaterial`、`craftingOpened`）
- 属性遵循与现有事件相同的结构：`player_id`、`session_id`、`timestamp` 作为标准字段；领域特定字段（material_type、item_id、crafting_time_seconds）作为附加属性
- 输出明确引用提供的命名约定为所遵循的标准

---

## 协议合规性

- [ ] 停留在声明领域内（事件 schema 设计、A/B 测试设计、分析方法论）
- [ ] 将实现请求重定向到适当程序员，附带集成规范而非代码
- [ ] 产出完整的 A/B 测试设计（假设、指标、样本量、持续时间、随机化单元）— 绝不部分
- [ ] 将重叠 A/B 测试中的互斥违规标记为数据质量阻塞
- [ ] 完全遵循提供的命名约定；不发明替代约定

---

## 覆盖说明
- Case 3（A/B 测试设计完整性）是质量 gate — 不完整的测试设计浪费实验预算
- Case 4（互斥性）是数据完整性测试 — 重叠测试产生不可用结果；必须捕获
- Case 5 是最重要的上下文感知测试；schema 间的命名约定漂移导致仪表板断裂
- 无自动化运行器；手动审查或通过 `/skill-test`
