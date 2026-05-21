<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：unity-ui-specialist

## Agent 摘要
领域：Unity UI Toolkit（UXML/USS）、UGUI（Canvas）、数据绑定、运行时 UI 性能、UI 输入事件处理。
不拥有：UX 流程设计（ux-designer）、视觉艺术风格（art-director）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 UI Toolkit / UGUI / Canvas / 数据绑定）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对 UX 流程设计或视觉艺术方向拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "使用 Unity UI Toolkit 实现一个背包 UI 界面。"
**预期行为：**
- 生成定义背包面板结构的 UXML 文档（ListView、物品模板、详情面板）
- 生成背包布局和物品状态（默认、悬停、选中）的 USS 样式
- 提供通过 `INotifyValueChanged` 或 `IBindable` 将背包数据模型绑定到 UI 的 C# 代码
- 对可滚动物品列表使用带 `makeItem` / `bindItem` 回调的 `ListView`
- 不生成 UX 流程设计 — 根据提供的规范实现

### Case 2：领域外重定向
**输入：** "设计背包的 UX 流程 — 玩家装备物品 vs. 丢弃物品时会发生什么。"
**预期行为：**
- 不生成 UX 流程设计
- 明确声明交互流程设计属于 `ux-designer`
- 将请求重定向到 `ux-designer`
- 备注将实现 ux-designer 指定的任何流程

### Case 3：UI Toolkit 动态列表的数据绑定
**输入：** "背包列表需要在物品添加到玩家背包或从中移除时实时更新。"
**预期行为：**
- 生成带有绑定的 `ObservableList<T>` 或事件驱动刷新方法的 `ListView` 模式
- 在集合变更事件上使用 `ListView.Rebuild()` 或 `ListView.RefreshItems()`
- 注明大列表的性能考虑（通过 `makeItem`/`bindItem` 模式进行虚拟化）
- 不使用 `QuerySelector` 循环更新单个元素作为列表刷新策略 — 标记为性能反模式

### Case 4：Canvas 性能 — 过度绘制
**输入：** "主菜单 Canvas 导致 GPU overdraw 警告；有许多重叠的面板。"
**预期行为：**
- 识别 overdraw 原因：多个堆叠 Canvas、非活动时未裁剪的全屏覆盖面板
- 建议：
  - 为 world-space、screen-space-overlay 和 screen-space-camera 层分别使用 Canvas
  - 禁用/停用面板而非将 alpha 设置为 0（不可见的 alpha-0 面板仍然绘制）
  - Canvas Group + alpha 用于淡入淡出效果，而非单独 Image alpha
- 如果项目处于迁移状态，注明 UI Toolkit 替代方案

### Case 5：上下文传递 — Unity 版本
**输入：** 项目上下文：Unity 2022.3 LTS。请求："实现带有数据绑定的设置面板。"
**预期行为：**
- 使用 UI Toolkit 和 2022.3 LTS 版本的运行时绑定系统
- 注明 Unity 2022.3 引入了运行时数据绑定（相对于早期版本仅编辑器绑定）
- 不使用在 2022.3 中不可用的 Unity 6 增强绑定 API 功能
- 生成与所述 Unity 版本兼容的代码，附版本特定 API 注释

---

## 协议合规性

- [ ] 停留在声明领域内（UI Toolkit、UGUI、数据绑定、UI 性能）
- [ ] 将 UX 流程设计重定向到 ux-designer
- [ ] 返回结构化输出（UXML、USS、C# 绑定代码）
- [ ] 使用与项目 Unity 版本匹配的正确 UI 框架版本
- [ ] 将 Canvas overdraw 标记为性能反模式并提供具体修复
- [ ] 不使用 alpha-0 作为隐藏/显示模式 — 使用 SetActive() 或 VisualElement.style.display

---

## 覆盖说明
- 背包 UI（Case 1）应有 `production/qa/evidence/` 中的手动走查文档
- 动态列表绑定（Case 3）应有集成测试或自动化交互测试
- Canvas overdraw（Case 4）验证 agent 知道正确的 Unity UI 性能模式
