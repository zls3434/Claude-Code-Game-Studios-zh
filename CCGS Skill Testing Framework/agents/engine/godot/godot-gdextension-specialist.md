<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：godot-gdextension-specialist

## Agent 摘要
领域：GDExtension API、godot-cpp C++ 绑定、godot-rust 绑定、原生库集成、原生性能优化。
不拥有：GDScript 代码（gdscript-specialist）、shader 代码（godot-shader-specialist）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 GDExtension / godot-cpp / 原生绑定）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对 GDScript 或 shader 编写拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "通过 GDExtension 将 C++ 刚体物理模拟库暴露给 GDScript。"
**预期行为：**
- 使用 godot-cpp 生成 GDExtension 绑定模式：
  - 继承自 `godot::Object` 或适当的 Godot 基类的 Class
  - `GDCLASS` 宏注册
  - 实现将物理 API 暴露给 GDScript 的 `_bind_methods()`
  - `GDExtension` 入口点（`gdextension_init`）设置
- 注明所需的 `.gdextension` manifest 文件格式
- 不生成 GDScript 使用代码（属于 gdscript-specialist）

### Case 2：领域外重定向
**输入：** "编写调用 Case 1 中物理模拟的 GDScript。"
**预期行为：**
- 不生成 GDScript 代码
- 明确声明 GDScript 编写属于 `godot-gdscript-specialist`
- 重定向到 `godot-gdscript-specialist`
- 可描述 GDScript 应调用的 API 表面（方法名、参数类型）作为交接规范

### Case 3：ABI 兼容性风险 — 小版本更新
**输入：** "我们从 Godot 4.5 升级到 4.6。现有的 GDExtension 还能工作吗？"
**预期行为：**
- 标记 ABI 兼容性问题：GDExtension 二进制文件可能在小版本之间不 ABI 兼容
- 指导检查 4.5→4.6 迁移指南中的 GDExtension API 变更
- 建议针对 4.6 godot-cpp 头文件重新编译扩展，而非假设二进制兼容性
- 注明 `.gdextension` manifest 可能需要更新 `compatibility_minimum` 版本
- 提供重新编译 checklist

### Case 4：内存管理 — Godot 对象的 RAII
**输入：** "应如何管理在 C++ GDExtension 代码中创建的 Godot 对象的生命周期？"
**预期行为：**
- 对 GDExtension 中的 Godot 对象生成基于 RAII 的生命周期模式：
  - `Ref<T>` 用于引用计数对象（Ref 离开作用域时自动释放）
  - `memnew()` / `memdelete()` 用于非引用计数对象
  - 警告：不要对 Godot 对象使用 `new`/`delete` — 未定义行为
- 注明对象所有权规则：谁负责释放添加到场景树的节点
- 提供管理在 C++ 中创建的 `CollisionShape3D` 的具体示例

### Case 5：上下文传递 — Godot 4.6 GDExtension API 检查
**输入：** 引擎版本上下文：Godot 4.6（从 4.5 升级）。请求："检查是否有任何 GDExtension API 从 4.5 变更到 4.6。"
**预期行为：**
- 引用 VERSION.md 验证来源列表中的 4.5→4.6 迁移指南
- 报告 4.6 版本中任何已记录的 GDExtension API 变更
- 如果 4.6 中 GDExtension 没有记录的破坏性变更，明确声明并注明需对照官方 changelog 验证
- 标记 Windows 上的 D3D12 默认（4.6 变更）可能与 GDExtension 渲染代码相关
- 提供升级后需验证的 checklist

---

## 协议合规性

- [ ] 停留在声明领域内（GDExtension、godot-cpp、godot-rust、原生绑定）
- [ ] 将 GDScript 编写重定向到 godot-gdscript-specialist
- [ ] 将 shader 编写重定向到 godot-shader-specialist
- [ ] 返回结构化输出（绑定模式、RAII 示例、ABI checklist）
- [ ] 标记小版本升级时的 ABI 兼容性风险 — 绝不假设二进制兼容性
- [ ] 使用 Godot 特定内存管理（`memnew`/`memdelete`、`Ref<T>`）而非原始 C++ new/delete
- [ ] 在确认兼容性之前检查引擎版本参考中的 GDExtension API 变更

---

## 覆盖说明
- 绑定模式（Case 1）应包含验证扩展加载且方法可从 GDScript 调用的冒烟测试
- ABI 风险（Case 3）是关键升级路径 — agent 不得批准发布未经验证的扩展二进制文件
- 内存管理（Case 4）验证 agent 应用 Godot 特定模式，而非通用 C++ RAII
