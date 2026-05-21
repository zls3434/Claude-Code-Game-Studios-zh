<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：ui-programmer

## Agent 摘要
领域：UI 代码实现、UI 布局/动态面板、HUD 系统、UI 交互、UI 动画集成
不拥有：UX 流程设计 (ux-designer)、视觉设计 (art-director)、gameplay 系统 (gameplay-programmer)
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（UI 实现、HUD、布局）
- [ ] `allowed-tools:` 列表匹配 agent 角色（UI 系统读写，Bash — 如必要）
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对 UX 流程或视觉设计拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "使用控制器的按钮提示实现 HUD 生命条 + 消耗品栏。数字血量和响应式布局。"
**预期行为：**
- 产出 HUD 代码实现：
  - 当前 HP / 最大 HP 文本标签（左对齐）
  - 生命条填充受数字血量影响
  - 消耗品栏水平排列，响应式间距
  - 按钮提示图标 + 文本堆叠
- 使用引擎的 UI 布局系统（如有引擎支持，用容器/锚点）
- 不设计 UX 流程 — 仅 UI 屏幕

### Case 2：领域外请求 — 适当重定向
**输入：** "设计 HUD 的 UX 流程 — 玩家应如何访问背包、地图和设置。"
**预期行为：**
- 重定向到 ux-designer
- 不设计 UX 流程

### Case 3：UI 动画 — 生命条响应
**输入：** "生命条从 100 变为 50 时，应该在 0.5s 内平滑动画下降，显示消耗闪光。"
**预期行为：**
- 实现生命条动画：
  - 血量变化时 0.5s 平滑过渡（使用 tween 或动画曲线）
  - 一次性闪光：下降时，条变为红色闪烁，然后恢复正常颜色
  - 处理多次伤害（重置动画时间线）
- 不改变底层血量系统 — 仅 UI 表示

### Case 4：响应式布局 — 多种屏幕尺寸
**输入：** "HUD 必须在 16:9、21:9 和 4:3 宽高比上正确缩放。放在 safe area 内。"
**预期行为：**
- 实施响应式布局系统：
  - 使用比例锚点（非固定像素位置）
  - 根据屏幕百分比缩放
  - 对过宽的宽高比应用最大宽度
  - 保持 safe area 内的重要 UI 元素

### Case 5：上下文传递 — 引擎 UI 系统
**输入上下文：** 引擎为 Godot。UI 使用 Control 节点 + Container 系统。可用控件：HBoxContainer、VBoxContainer、TextureRect、Label、ProgressBar。
**输入：** "使用提供的引擎系统实现上述 HUD。"
**预期行为：**
- 使用引擎特定 API：`HBoxContainer` 用于消耗品栏，`ProgressBar` 用于血条，`Label` 用于 HP 文本
- 使用 `anchor_right`/`anchor_left` 和 `margin` 用于响应式布局
- 使用 `Tween` 节点用于动画
- 产出场景树结构（YAML 或 Markdown 格式），而非纯代码

---

## 协议合规性

- [ ] 停留在声明领域内（UI 实现、布局、动画）
- [ ] 将 UX 流程请求重定向到 ux-designer
- [ ] 将视觉资产请求重定向到 art-director
- [ ] 使用引擎上下文中的特定 UI 系统
- [ ] 在 safe area 内实现响应式布局

---

## 覆盖说明
- Case 4（响应式布局）是最量化测试 — 多种宽高比测试
- Case 5 要求引擎上下文在运行前可用；是上下文测试中最重要的
- 无自动化运行器；手动审查或通过 `/skill-test`
