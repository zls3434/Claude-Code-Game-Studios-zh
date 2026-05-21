<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：unreal-specialist

## Agent 摘要
领域：Unreal Engine 特定架构模式、UE5 子系统选择、C++ 与 Blueprint 决策、插件评估、构建系统。
不拥有：特定于领域的深度研究（委托给 ue-gas-specialist、ue-replication-specialist 等）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 UE 模式 / C++ 与 BP 决策 / 子系统 / 插件）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义确认子 specialist 路由表（GAS、Replication、UMG、Blueprint）

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "应该使用 Sparse Class Data 还是原始 UPROPERTY 进行角色配置？"
**预期行为：**
- 生成模式决策指南，涵盖：
  - `UPROPERTY`：简单，适合小配置，无需额外类
  - Sparse Class Data：在 BP 中减少属性列表膨胀，更好地大规模组织大量角色的配置
- 说明具体权衡（迭代时间、内存、BP 节点图复杂度）
- 不做出最终设计决策 — 将选择连同利弊呈现给 `lead-programmer`

### Case 2：错误引擎重定向
**输入：** "在基于信号的场景中为角色设置 RigidBody3D。"
**预期行为：**
- 不生成 Godot 特定的节点或信号代码
- 识别这是 Godot 模式
- 提供 UE 等效方案：
  - `RigidBody3D` → `UPrimitiveComponent` + 模拟启用
  - Godot 信号 → UE Delegates / Events
- 映射概念并重定向为 Unreal 习惯用法

### Case 3：UE 版本标记 — Nanite/Fracture
**输入：** "为可破坏岩石使用 Nanite 和 Chaos Fracture。"
**预期行为：**
- 识别 Nanite 和 Fracture 的互操作性约束（截至 UE 5.3/5.4，Nanite 网格不支持 Chaos Destruction / Fracture）
- 标记此组合的兼容性问题
- 建议替代方案：对不可破坏岩石使用 Nanite，对可破坏岩石使用非 Nanite LOD 网格
- 确认具体 UE 版本，因为互操作性因版本而异

### Case 4：C++ 与 Blueprint 冲突
**输入：** "gameplay 团队希望用 Blueprint 做所有事；引擎程序员坚持使用 C++ 基类。"
**预期行为：**
- 识别哲学分歧而非技术问题
- 解释传统 UE 最佳实践：
  - C++ 用于基类、核心逻辑、系统级代码
  - Blueprint 用于派生类、设计师迭代、事件绑定、UI 逻辑
- 建议升级到 `lead-programmer` 或 `technical-director` 进行政策决策
- 不发布政策命令 — 提供基于证据的推荐

### Case 5：上下文传递 — UE 版本
**输入：** 项目上下文：Unreal Engine 5.4。请求："推荐用于运行时角色换装的插件。"
**预期行为：**
- 建议对照 UE 5.4 插件兼容性检查插件
- 推荐与 UE 5.4 兼容的插件（例如 Mutable、内置 UAnimInstance 换装系统）
- 注明特定插件版本要求或 Epic launcher marketplace 兼容性约束
- 使用 UE 5.4 的增强输入系统进行输入绑定（非 5.4 之前的 DefaultInput.ini 方法）

---

## 协议合规性

- [ ] 停留在声明领域内（UE 架构决策、C++ vs BP、子系统、插件）
- [ ] 将 GAS 实现重定向到 ue-gas-specialist
- [ ] 将 Replication 重定向到 ue-replication-specialist
- [ ] 将 Blueprint 实现重定向到 ue-blueprint-specialist
- [ ] 标记引擎版本特定的兼容性问题（Nanite + Chaos Fracture 互操作）
- [ ] 返回结构化决策指南，而非规定性命令

---

## 覆盖说明
- Sparse Class Data（Case 1）应记录为项目范围决策的 ADR
- Nanite/Chaos（Case 3）验证 agent 知道重要的 UE 特定互操作性约束
- C++ vs BP（Case 4）验证 agent 升级政策冲突，而非单方面规定
