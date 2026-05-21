<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：ue-umg-specialist

## Agent 摘要
领域：Unreal Motion Graphics（UMG）— Widget Blueprint、Common UI、Slate 集成、UMG 性能、数据绑定。
不拥有：UX 流程设计（ux-designer）、视觉样式（art-director）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 UMG / Widget / Common UI / Slate）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对 UX 流程或视觉艺术拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "为 RPG 角色创建带有标签页的主菜单（背包、角色属性、设置）。"
**预期行为：**
- 生成 UMG Blueprint 布局设计：
  - 带有 `CommonActivatableWidgetStack`（或 `WidgetSwitcher`）的主容器用于标签切换
  - 每个标签页注册为 `CommonActivatableWidget`（InventoryWidget、StatsWidget、SettingsWidget）
  - 带有将输入路由到正确面板的逻辑的 Back button 处理
- 如果使用 Common UI，使用 `UCommonActivatableWidgetStack` 的推入/弹出激活 API
- 不设计视觉外观或 UX 流程 — 仅构建容器结构

### Case 2：领域外重定向
**输入：** "设计背包的 UX 流程 — 玩家装备物品 vs. 丢弃物品 — 以及物品交互菜单的外观。"
**预期行为：**
- 将 UX 流程设计重定向到 `ux-designer`
- 将视觉样式重定向到 `art-director`
- 不设计物品装扮或 UI 视觉效果
- 可备注将实现 ux-designer 和 art-director 指定的任何规范和资产

### Case 3：列表性能 — 大型物品列表
**输入：** "背包 UMG ListView 需要显示 200 个物品，界面会卡顿。"
**预期行为：**
- 诊断原因：`UListView` 不使用 `EntryWidgetPool` 进行元素复用，在大型列表中会导致性能问题
- 提供 `UTileView`（网格）或带池化的自定义 `UListView` 作为备选，但注明 UMG 大型列表存在固有性能问题
- 建议：将可见物品限制在 20-30 个，并添加搜索/过滤以避免渲染全部 200 个元素
- 不过度设计列表在 Blueprint 中放置 200+ 条目的复杂池化

### Case 4：输入导航 — 焦点陷阱
**输入：** "游戏手柄导航跳出设置面板进入背后运行的 gameplay HUD。"
**预期行为：**
- 识别缺少焦点隔离
- 在 Common UI 中，使用 `CommonActivatableWidget` 激活/停用时的焦点管理 API
- 设置面板激活时禁用 gameplay widget 输入
- 面板关闭时将焦点恢复到上一个聚焦元素
- 处理设置面板中的环形导航（焦点循环不退出到 gameplay）

### Case 5：上下文传递 — 游戏手柄模式
**输入：** 项目上下文：专为游戏手柄使用构建的游戏。请求："为带滚动列表的设置面板实现导航。"
**预期行为：**
- 使用所提供上下文：全游戏手柄导航，无鼠标备用
- 使用 Common UI 的导航提示（`CommonBoundActionBar` 或等效）指示按钮可用于将焦点移入/移出滚动列表
- 确保列表项正确可聚焦，带有视觉高亮状态
- 为向上/向下滚动设计显式导航路径，而非依赖意外游戏手柄行为

---

## 协议合规性

- [ ] 停留在声明领域内（UMG、Common UI、Slate 集成、数据绑定）
- [ ] 将 UX 流程重定向到 ux-designer
- [ ] 将视觉资产/样式重定向到 art-director
- [ ] 返回结构化 Widget Blueprint 布局和导航设计
- [ ] 使用适当的 UMG 容器（`CommonActivatableWidgetStack`、`WidgetSwitcher`、`ListView`）
- [ ] 为大型列表标记 UMG 性能限制（200+ 条目 = 需要搜索/过滤/池化）
- [ ] 根据提供的游戏手柄上下文设计焦点导航（非键鼠假设）

---

## 覆盖说明
- 主菜单结构（Case 1）应生成可扩展布局 — 新标签页无需修改容器即可添加
- UMG 列表性能（Case 3）确认 agent 知道 UMG 限制且不会过度设计池化
- 焦点陷阱（Case 4）是常见的 UE 可访问性 bug — 验证 agent 以可访问性为出发点处理游戏手柄导航
