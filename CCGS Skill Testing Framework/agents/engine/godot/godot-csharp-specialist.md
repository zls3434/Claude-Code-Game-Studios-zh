<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：godot-csharp-specialist

## Agent 摘要
领域：Godot 4 中的 C# 模式、应用于 Godot 的 .NET 惯用法、[Export] attribute 用法、信号委托以及 async/await 模式。
不拥有：GDScript 代码（gdscript-specialist）、GDExtension C/C++ 绑定（gdextension-specialist）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 Godot 4 中的 C# / .NET 模式 / 信号委托）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对 GDScript 或 GDExtension 代码拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "创建一个带验证的敌人生命值导出属性，将其限制在 1 到 1000 之间。"
**预期行为：**
- 生成带 `[Export]` attribute 的 C# 属性
- 使用后备字段，属性 getter/setter 在 setter 中对值进行限制
- 不使用不带验证的原始 `[Export]` 公共字段
- 遵循 Godot 4 C# 命名约定（属性 PascalCase，字段前缀下划线 private）
- 按编码规范为属性包含 XML doc 注释

### Case 2：领域外请求 — 正确重定向
**输入：** "在 GDScript 中重写此敌人生命值系统。"
**预期行为：**
- 不生成 GDScript 代码
- 明确声明 GDScript 编写属于 `godot-gdscript-specialist`
- 将请求重定向到 `godot-gdscript-specialist`
- 可备注可描述 C# 接口以便 gdscript-specialist 知道预期 API 形态

### Case 3：异步信号等待
**输入：** "在转换游戏状态之前使用 C# async 等待动画完成。"
**预期行为：**
- 生成正确的 `async Task` 模式，使用 `ToSignal()` 等待 Godot 信号
- 使用 `await ToSignal(animationPlayer, AnimationPlayer.SignalName.AnimationFinished)`
- 不使用 `Thread.Sleep()` 或 `Task.Delay()` 作为轮询替代
- 注明调用方法必须为 `async`，且 fire-and-forget `async void` 仅对事件处理器可接受
- 处理动画可能无法触发时的取消或超时

### Case 4：线程模型冲突
**输入：** "此 C# 代码从后台 Task 线程访问 Godot Node 以更新其位置。"
**预期行为：**
- 标记为竞态条件风险：Godot 节点非线程安全，必须仅从主线程访问
- 不批准或实现多线程节点访问模式
- 提供正确模式：使用 `CallDeferred()`、`Callable.From().CallDeferred()`，或通过线程安全队列编排回主线程
- 解释 Godot 主线程要求与 .NET 线程无关类型之间的区别

### Case 5：上下文传递 — Godot 4.6 API 正确性
**输入：** 引擎版本上下文：Godot 4.6。请求："使用新的类型化信号委托模式连接信号。"
**预期行为：**
- 使用 Godot 4 C# 中引入的类型化委托模式（类型化信号上的 `+=` 运算符）生成 C# 信号连接
- 检查 4.6 上下文以确认 4.4、4.5 或 4.6 中信号委托 API 无破坏性变更
- 不使用旧的基于字符串的 `Connect("signal_name", callable)` 模式（在 Godot 4 C# 中已弃用）
- 生成与项目 VERSION.md 中记录的固定版本 4.6 兼容的代码

---

## 协议合规性

- [ ] 停留在声明领域内（Godot 4 中的 C# — 模式、导出、信号、async）
- [ ] 将 GDScript 请求重定向到 godot-gdscript-specialist
- [ ] 将 GDExtension 请求重定向到 godot-gdextension-specialist
- [ ] 返回遵循 Godot 4 约定的 C# 代码（非 Unity MonoBehaviour 模式）
- [ ] 标记多线程 Godot 节点访问为不安全并提供正确模式
- [ ] 使用类型化信号委托 — 不使用已弃用的基于字符串的 Connect() 调用
- [ ] 在生成代码之前检查引擎版本参考中的 API 变更

---

## 覆盖说明
- 带验证的导出属性（Case 1）应有单元测试验证 clamp 行为
- 线程冲突（Case 4）为安全关键：agent 必须无需提示识别并修复此问题
- 异步信号（Case 3）验证 agent 在 Godot 单线程约束内正确应用 .NET 惯用法
