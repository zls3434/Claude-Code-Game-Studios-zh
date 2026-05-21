<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：unity-specialist

## Agent 摘要
领域：Unity 特定架构模式、MonoBehaviour 与 DOTS 决策、子系统选择（Addressables、New Input System、UI Toolkit、Cinemachine 等）。
不拥有：语言特定的深度研究（委托给 unity-dots-specialist、unity-ui-specialist 等）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 Unity 模式 / MonoBehaviour / 子系统决策）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义确认子 specialist 路由表（DOTS、UI、Shader、Addressables）

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "应该使用 MonoBehaviour 还是 ScriptableObject 来存储敌人配置数据？"
**预期行为：**
- 生成模式决策树，涵盖：
  - MonoBehaviour：用于运行时行为，需要附加到 GameObject，具有 Update() 生命周期
  - ScriptableObject：用于纯数据/配置，作为资产存在，跨实例共享，无场景依赖
- 为敌人配置数据推荐 ScriptableObject（无状态、可复用、设计师友好）
- 注明 MonoBehaviour 可引用 ScriptableObject 用于运行时使用
- 提供 ScriptableObject 类定义的具体示例（不生成完整代码 — 转交 engine-programmer 或 gameplay-programmer 实现）

### Case 2：错误引擎重定向
**输入：** "为此敌人系统设置一个带有信号的 Node 场景树。"
**预期行为：**
- 不生成 Godot Node/signal 代码
- 识别这是 Godot 模式
- 声明在 Unity 中等效方案是 GameObject 层级 + UnityEvent 或 C# event
- 映射概念：Godot Node → Unity MonoBehaviour，Godot Signal → C# event / UnityEvent
- 在继续之前确认项目基于 Unity

### Case 3：Unity 版本 API 标记
**输入：** "使用新的 Unity 6 GPU resident drawer 进行批量渲染。"
**预期行为：**
- 识别 Unity 6 功能（GPU Resident Drawer）
- 标记该 API 在早期 Unity 版本中可能不可用
- 在提供实现指导之前询问或检查项目的 Unity 版本
- 指导对照官方 Unity 6 文档进行验证
- 不确认就不假设项目使用 Unity 6

### Case 4：DOTS 与 MonoBehaviour 冲突
**输入：** "战斗系统使用 MonoBehaviour 进行状态管理，但我们希望添加基于 DOTS 的弹丸系统。它们可以共存吗？"
**预期行为：**
- 识别这是混合架构场景
- 解释混合方法：MonoBehaviour 可通过 SystemAPI、IComponentData 和托管组件与 DOTS 交互
- 注明混合两种模式的性能和复杂度权衡
- 建议将架构决策升级到 `lead-programmer` 或 `technical-director`
- 将 DOTS 侧实现细节委托给 `unity-dots-specialist`

### Case 5：上下文传递 — Unity 版本
**输入：** 提供的项目上下文：Unity 2023.3 LTS。请求："为此项目配置 New Input System。"
**预期行为：**
- 应用 Unity 2023.3 LTS 上下文：使用 New Input System（com.unity.inputsystem）包
- 不生成旧版 Input Manager 代码（`Input.GetKeyDown()`、`Input.GetAxis()`）
- 注明任何 2023.3 特定的 Input System 行为或包版本约束
- 如果 Input System 与 DOTS 交互，引用项目版本以确认 Burst/Jobs 兼容性

---

## 协议合规性

- [ ] 停留在声明领域内（Unity 架构决策、模式选择、子系统路由）
- [ ] 将 Godot 模式重定向到适当的 Godot specialist 或标记为错误引擎
- [ ] 将 DOTS 实现重定向到 unity-dots-specialist
- [ ] 将 UI 实现重定向到 unity-ui-specialist
- [ ] 标记 Unity 版本限制的 API 并在建议之前要求版本确认
- [ ] 返回结构化模式决策指南，而非自由形式的意见

---

## 覆盖说明
- MonoBehaviour 与 ScriptableObject（Case 1）如导致项目级别决策，应记录为 ADR
- 版本标记（Case 3）确认 agent 不会在无上下文的情况下假设最新 Unity 版本
- DOTS 混合（Case 4）验证 agent 升级架构冲突而非单方面解决
