<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：godot-gdscript-specialist

## Agent 摘要
领域：GDScript 静态类型、GDScript 设计模式、信号架构、协程/await 模式、GDScript 性能。
不拥有：shader 代码（godot-shader-specialist）、GDExtension 绑定（godot-gdextension-specialist）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 GDScript / 静态类型 / 信号 / 协程）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对 shader 代码或 GDExtension 拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "审查此 GDScript 文件的类型注解覆盖率。"
**预期行为：**
- 读取提供的 GDScript 文件
- 标记每个缺少静态类型注解的变量、参数和返回类型
- 产出逐行发现列表：`var speed = 5.0` → `var speed: float = 5.0`
- 注明 Godot 4 中静态类型的性能和工具优势
- 不重写整个文件 — 产出发现列表供开发者应用

### Case 2：领域外请求 — 正确重定向
**输入：** "编写一个顶点 shader 在世界空间中扭曲网格。"
**预期行为：**
- 不在 GDScript 或 Godot shading language 中生成 shader 代码
- 明确声明 shader 编写属于 `godot-shader-specialist`
- 将请求重定向到 `godot-shader-specialist`
- 可备注 GDScript 方面（向 shader 传递 uniform、设置 shader 参数）在其领域内

### Case 3：使用协程的异步加载
**输入：** "异步加载一个场景并在完成之前等待，然后再生成它。"
**预期行为：**
- 对于 Godot 4，使用 `await` + `ResourceLoader.load_threaded_request` 模式
- 全程使用静态类型（`var scene: PackedScene`）
- 使用 `ResourceLoader.load_threaded_get_status()` 处理完成检查
- 注明加载失败的错误处理
- 不使用已弃用的 Godot 3 `yield()` 语法

### Case 4：性能问题 — 类型化数组推荐
**输入：** "实体更新循环很慢；它每帧迭代一个包含 1000 个节点的无类型 Array。"
**预期行为：**
- 识别无类型 `Array` 在 GDScript 中放弃了编译器优化
- 建议转换为类型化数组（`Array[Node]` 或具体类型）以启用 JIT 提示
- 注明如果仍不够，升级热路径以进行 C# 迁移推荐
- 产出类型化数组重构作为即时修复
- 不建议在没有性能分析证据的情况下将整个代码库迁移到 C#

### Case 5：上下文传递 — Godot 4.6 与截止后功能
**输入：** 提供的引擎版本上下文：Godot 4.6。请求："使用 @abstract 为所有敌人类型创建抽象基类。"
**预期行为：**
- 识别 `@abstract` 是 Godot 4.5+ 功能（截止后）
- 在输出中注明：功能在 4.5 中引入，已对照 VERSION.md 迁移说明验证
- 使用 `@abstract` 按迁移说明中记录的正确语法生成 GDScript 类
- 因截止后状态，标记输出需对照官方 4.5 发布说明进行验证
- 对抽象类中的所有方法签名使用静态类型

---

## 协议合规性

- [ ] 停留在声明领域内（GDScript — 类型、模式、信号、协程、性能）
- [ ] 将 shader 请求重定向到 godot-shader-specialist
- [ ] 将 GDExtension 请求重定向到 godot-gdextension-specialist
- [ ] 返回带有完整静态类型的结构化 GDScript 输出
- [ ] 仅使用 Godot 4 API — 不使用已弃用的 Godot 3 模式（yield、字符串 connect 等）
- [ ] 标记截止后功能（4.4、4.5、4.6）并标记为需要文档验证

---

## 覆盖说明
- 类型注解审查（Case 1）输出适合作为代码审查 checklist
- 异步加载（Case 3）应生成可在 `tests/unit/` 中通过单元测试验证的可测试代码
- 截止后 @abstract（Case 5）确认 agent 标记版本不确定性，而非静默使用未验证的 API
