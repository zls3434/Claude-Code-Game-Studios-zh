<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：ue-blueprint-specialist

## Agent 摘要
领域：Blueprint 脚本、Blueprint Function Libraries、Blueprint Macro Libraries、Blueprint Native Events、Blueprint 接口、Blueprint 性能优化（本机化）。
不拥有：C++ 实现（ue-specialist / gameplay-programmer）、GAS（ue-gas-specialist）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 Blueprint 脚本 / Function Libraries / 接口 / 性能）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对 C++ 或 GAS 实现拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "使用 Blueprint 接口为敌人创建可交互系统。"
**预期行为：**
- 生成：
  - 带 `Interact(Instigator)` 函数的 `BPI_Interactable` Blueprint 接口
  - actor Blueprint 中的 `Event Interact` 实现设置
  - 检测重叠 actor 并检查其是否实现 `BPI_Interactable` 的 trace/overlap 系统
- 使用 Blueprint 接口而非 `Cast To` 链 — 标记 cast-to 链为反模式
- 注明 Blueprint 接口不能有函数实现 — 仅声明；每个 actor 必须实现自己的
- 说明类型安全方法（`Does Implement Interface` 节点 + `Interact` 消息节点）

### Case 2：领域外重定向
**输入：** "用 C++ 编写同样的交互系统，以获得更好的性能。"
**预期行为：**
- 不生成 C++ 代码
- 明确声明 C++ 实现属于 `ue-specialist` 或 `gameplay-programmer`
- 同意 C++ 版本将更快，但将其编程转交给适当的 specialist
- 可描述 Blueprint 版本如何设计以便在 C++ 中具有 `UFUNCTION(BlueprintNativeEvent)` 的等效行为

### Case 3：Nativization 准备就绪
**输入：** "我们的 Blueprint 项目性能不够；启用 nativization。"
**预期行为：**
- 解释 nativization 在 UE5 中已正式弃用；推荐替代方案：
  - 将性能关键 Blueprint 迁移到 C++ 基类，派生 BP 带有本机事件
  - 使用 Blueprint Native Events 用于需要设计者覆盖的本机化接缝
- 使用 `UFUNCTION(BlueprintNativeEvent)` 生成性能关键函数的迁移计划
- 说明 nativization 不能魔法般修复所有性能问题 — 仅是将 BP VM 开销转换为 C++

### Case 4：大数组性能 — 无 foreach 循环
**输入：** "此 Blueprint 函数每帧迭代一个包含 500 个物品的 Inventory Array；它导致卡顿。"
**预期行为：**
- 识别 Blueprint 在紧密循环中性能不佳 — 应避免逐物品 Blueprint 循环
- 提供 C++ 迁移建议（`gameplay-programmer`）用于循环，带有 Blueprint 可调用包装器
- 或者建议设计变更：使用 Set/Map（`TSet`/`TMap`）进行查找，而非逐物品扫描
- 不尝试优化创建可读写组件的 Blueprint 循环 — 这是徒劳的

### Case 5：上下文传递 — UI 上的 Blueprint
**输入：** 项目上下文：使用 Common UI 插件的 UMG UI 项目。请求："在 Blueprint 中实现设置下拉菜单。"
**预期行为：**
- 识别 Common UI 上下文并将其纳入设计：
  - 使用 `CommonActivatableWidget` 作为设置面板基类（而非原始 `UUserWidget`）
  - 使用 `CommonButtonBase` 和 `CommonTextBlock` 用于样式一致性
  - 将数值保持的字段绑定到 Blueprint 事件（设置更改时响应）
- 不使用不与 Common UI 集成的原始 UMG Slate 调用

---

## 协议合规性

- [ ] 停留在声明领域内（Blueprint 脚本、函数库、接口、性能）
- [ ] 将 C++ 重定向到 ue-specialist 或 gameplay-programmer
- [ ] 将 GAS 请求重定向到 ue-gas-specialist
- [ ] 返回结构化 Blueprint 设计（接口定义、事件图设置、数据流）
- [ ] 将 cast-to 链标记为反模式（使用接口代替）
- [ ] 推荐通过本机事件将紧密循环迁移到 C++，而非 nativization
- [ ] 生成与项目 UI 框架（Common UI vs. 纯 UMG）一致的 UI Blueprint 设计

---

## 覆盖说明
- 交互接口（Case 1）应生成可扩展设计 — 新 interatable 类型必须无需修改 trace 系统即可添加
- Nativization 弃用（Case 3）确认 agent 知道 UE5 生命周期变更
- 大数组性能（Case 4）验证 agent 不会费心优化 Blueprint 循环 — 会转交给 C++
