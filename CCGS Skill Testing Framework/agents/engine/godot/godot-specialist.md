<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：godot-specialist

## Agent 摘要
领域：Godot 特定模式、节点/场景架构、信号、资源、以及 GDScript 与 C# 与 GDExtension 的决策。
不拥有：用特定语言编写实际代码（委托给语言子 specialist）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 Godot 架构 / 节点模式 / 引擎决策）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义引用 `docs/engine-reference/godot/VERSION.md` 作为权威 API 来源

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "在 Godot 中应该使用信号还是直接方法调用？"
**预期行为：**
- 产出带有原理说明的模式决策指南：
  - 信号：解耦通信、父对子无感知、事件驱动的 UI 更新、一对多通知
  - 直接调用：调用方需要返回值的紧耦合系统，或性能关键的热路径
- 提供每种模式在项目上下文中的具体示例
- 不生成两种模式的原始代码 — 将实现转交 gdscript-specialist 或 csharp-specialist
- 注明"无向上信号"约定（子节点不直接调用父节点方法 — 改用信号）

### Case 2：错误引擎重定向
**输入：** "编写一个 MonoBehaviour，在 Start() 中运行并订阅 UnityEvent。"
**预期行为：**
- 不生成 Unity MonoBehaviour 代码
- 明确指出这是一个 Unity 模式，而非 Godot 模式
- 提供 Godot 等效方案：使用 `_ready()` 而非 `Start()` 的 Node 脚本，使用 Godot 信号而非 UnityEvent
- 确认项目基于 Godot 并重定向概念映射

### Case 3：截止后 API 风险
**输入：** "使用新的 Godot 4.5 @abstract 注解来定义抽象基类。"
**预期行为：**
- 识别 `@abstract` 是截止后功能（在 Godot 4.5 中引入，在 LLM 知识截止之后）
- 标记版本风险：LLM 对此注解的知识可能不完整或不正确
- 指导用户对照 `docs/engine-reference/godot/VERSION.md` 和官方 4.5 迁移指南进行验证
- 基于版本参考中的迁移说明提供尽力而为的指导，同时明确标记为未验证

### Case 4：热路径的语言选择
**输入：** "物理查询循环每帧对 500 个对象运行。应该用 GDScript 还是 C# 实现？"
**预期行为：**
- 提供平衡的分析：
  - GDScript：更简单，团队熟悉，但紧密循环较慢
  - C#：CPU 密集型循环更快，需要 .NET runtime，团队需要 C# 知识
- 不单方面做出最终决定
- 将决策转交 `lead-programmer`，附上分析作为输入
- 注明 GDExtension（C++）是极端性能情况下的第三种选择，如果 C# 不够则建议升级

### Case 5：上下文传递 — 引擎版本 4.6
**输入：** 提供的引擎版本上下文：Godot 4.6，Jolt 为默认物理引擎。请求："为玩家角色设置 RigidBody3D。"
**预期行为：**
- 读取 4.6 上下文并应用 Jolt 默认知识（来自 VERSION.md 迁移说明）
- 推荐与 Jolt 兼容的 RigidBody3D 配置选择（例如，注明在 Jolt 下行为不同的 GodotPhysics 特定设置）
- 引用 4.6 迁移说明中关于 Jolt 成为默认引擎的内容，而非仅依赖 LLM 训练数据
- 标记任何在 GodotPhysics 和 Jolt 之间行为变化的 RigidBody3D 属性

---

## 协议合规性

- [ ] 停留在声明领域内（Godot 架构决策、节点/场景模式、语言选择）
- [ ] 将语言特定实现重定向到 godot-gdscript-specialist 或 godot-csharp-specialist
- [ ] 返回结构化发现（决策树、带原理的模式推荐）
- [ ] 将 `docs/engine-reference/godot/VERSION.md` 视为优于 LLM 训练数据的权威来源
- [ ] 标记截止后 API 使用（4.4、4.5、4.6）并要求验证
- [ ] 当存在权衡时将语言选择决策转交 lead-programmer

---

## 覆盖说明
- 信号与直接调用指南（Case 1）应写入 `docs/architecture/` 作为可复用模式文档
- 截止后标记（Case 3）确认 agent 不会自信使用无法验证的 API
- 引擎版本案例（Case 5）验证 agent 应用版本参考中的迁移说明，而非假设
