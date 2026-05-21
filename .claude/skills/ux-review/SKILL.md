---
name: ux-review
description: "验证 UX 规格、HUD 设计或交互模式库的完整性、无障碍合规性、GDD 一致性以及实现就绪度。生成 APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED 判定，附具体缺口说明。"
argument-hint: "[文件路径 或 'all' 或 'hud' 或 'patterns']"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: sonnet
agent: ux-designer
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

## 概述

在 UX 设计文档进入实现管线之前验证其质量。在 `/team-ui` 管线中充当 UX 设计与视觉设计/实现之间的质量关卡。

**运行此 Skill：**
- 使用 `/ux-design` 完成 UX 规格后
- 在移交给 `ui-programmer` 或 `art-director` 之前
- 在预生产到生产的阶段关卡之前（该关卡要求关键屏幕具有已审查的 UX 规格）
- 在 UX 规格进行重大修改后

**判定级别：**
- **APPROVED** — 规格完整、一致且实现就绪
- **NEEDS REVISION** — 发现具体缺口；移交前修复但不需要完全重新设计
- **MAJOR REVISION NEEDED** — 范围、玩家需求或完整性方面存在根本问题；需要大量返工

---

## 第 1 阶段：解析参数

- **特定文件路径**（例如 `/ux-review design/ux/inventory.md`）：验证该文档
- **`all`**：找到 `design/ux/` 中的所有文件并逐一验证
- **`hud`**：专门验证 `design/ux/hud.md`
- **`patterns`**：专门验证 `design/ux/interaction-patterns.md`
- **无参数**：询问用户要验证哪个规格

对于 `all`，先输出摘要表（文件 | 判定 | 主要问题），然后对每个输出完整详情。

---

## 第 2 阶段：加载交叉引用上下文

验证任何规格前，加载：

1. **输入和平台配置**：读取 `.claude/docs/technical-preferences.md` 并提取 `## Input & Platform`。这是游戏支持哪些输入方法的权威来源 — 在第 3A 阶段驱动输入方法覆盖率检查时使用它，而非规格自己的头部字段。如果未配置，回退到规格头部字段。
2. `design/accessibility-requirements.md` 中承诺的无障碍等级（如果存在）
3. `design/ux/interaction-patterns.md` 中的交互模式库（如果存在）
4. 规格头部引用的 GDD（读取它们的 UI Requirements 部分）
5. `design/player-journey.md` 中的玩家旅程地图（如果存在）用于上下文到达验证

---

## 第 3A 阶段：UX 规格验证检查清单

对基于 `ux-spec.md` 的文档运行所有检查。

### 完整性（必需部分）

- [ ] 文档头部存在 Status、Author、Platform Target
- [ ] Purpose & Player Need — 有玩家视角的需求陈述（而非开发者视角）
- [ ] Player Context on Arrival — 描述了玩家的状态和先前活动
- [ ] Navigation Position — 显示了屏幕在层级中的位置
- [ ] Entry & Exit Points — 所有进入来源和退出目标已文档化
- [ ] Layout Specification — 区域已定义，组件清单表存在
- [ ] States & Variants — 至少文档化：加载中、空/有数据、错误状态
- [ ] Interaction Map — 覆盖所有目标输入方法（检查头部的平台目标）
- [ ] Data Requirements — 每个显示的数据元素都有来源系统和所有者
- [ ] Events Fired — 每个玩家动作都有对应的事件或 null 说明
- [ ] Transitions & Animations — 至少指定了进入/退出过渡
- [ ] Accessibility Requirements — 屏幕级无障碍需求存在
- [ ] Localization Considerations — 文本元素的最大字符数
- [ ] Acceptance Criteria — 至少 5 个具体可测试标准

### 质量检查

**玩家需求清晰度**
- [ ] 目的是从玩家视角而非系统/开发者视角编写的
- [ ] 到达时的玩家目标是明确的（"玩家到达时想要___"）
- [ ] 到达时的玩家上下文是具体的（不只是"他们打开了背包"）

**状态完整性**
- [ ] 错误状态已文档化（不仅仅是正常路径）
- [ ] 空状态已文档化（无数据场景）
- [ ] 如果屏幕获取异步数据，加载状态已文档化
- [ ] 任何有计时器或自动关闭的状态都文档化了持续时间

**输入方法覆盖率**
- [ ] 如果平台包含 PC：纯键盘导航已完全指定
- [ ] 如果平台包含主机/手柄：d-pad 导航和面部按钮映射已文档化
- [ ] 手柄上没有需要鼠标精度级别的交互
- [ ] 焦点顺序已定义（键盘的 Tab 顺序，手柄的 d-pad 顺序）

**数据架构**
- [ ] 没有数据元素将"UI"列为所有者（UI 不得拥有游戏状态）
- [ ] 所有实时数据指定了更新频率（不只是"实时"— 什么触发更新？）
- [ ] 所有数据元素指定了 null 处理（数据不可用时显示什么？）

**无障碍**
- [ ] 来自 `accessibility-requirements.md` 的无障碍等级已匹配或超越
- [ ] 如果是 Basic 等级：无仅靠颜色传达信息
- [ ] 如果是 Standard 等级及以上：焦点顺序已文档化，文本对比度比率已指定
- [ ] 如果是 Comprehensive 等级及以上：关键状态变更的屏幕阅读器播报
- [ ] 色盲检查：任何颜色编码元素都有非颜色的替代方案

**GDD 一致性**
- [ ] 头部引用的每个 GDD UI Requirement 都在此规格中得到了满足
- [ ] 没有 UI 元素在没有对应 GDD 要求的情况下显示或修改游戏状态
- [ ] 此规格未遗漏任何 GDD UI Requirement（交叉检查引用的 GDD 部分）

**模式库一致性**
- [ ] 所有交互组件引用了模式库（或注明是新模式）
- [ ] 没有已在模式库中存在的模式行为被从头重新指定
- [ ] 此规格中发明的任何新模式已标记待添加到模式库

**本地化**
- [ ] 所有文本繁重的元素存在字符限制警告
- [ ] 任何对布局至关重要的文本已标记需容纳 40% 的扩展

**验收标准质量**
- [ ] 标准对未见过设计文档的 QA 测试者来说足够具体
- [ ] 存在性能标准（屏幕在 X 毫秒内打开）
- [ ] 存在分辨率标准
- [ ] 没有标准需要阅读另一个文档才能评估

---

## 第 3B 阶段：HUD 验证检查清单

对基于 `hud-design.md` 的文档运行所有检查。

### 完整性

- [ ] HUD Philosophy 已定义
- [ ] Information Architecture 表覆盖了 GDD 中所有有 UI Requirements 的系统
- [ ] Layout Zones 已定义并包含所有目标平台的安全区边距
- [ ] 每个 HUD 元素有完整规格（区域、可见性触发器、数据源、优先级）
- [ ] HUD States by Gameplay Context 至少覆盖：探索、战斗、对话/过场、暂停
- [ ] Visual Budget 已定义（最大同时元素数、最大屏幕百分比）
- [ ] Platform Adaptation 覆盖所有目标平台
- [ ] 存在玩家可调整元素的 Tuning Knobs

### 质量检查

- [ ] 没有 HUD 元素在没有可见性规则隐藏的情况下覆盖中心游戏区域
- [ ] 任何 GDD 中存在的每个信息项要么在 HUD 中，要么明确归类为"隐藏/按需"
- [ ] 所有颜色编码的 HUD 元素有色盲变体
- [ ] Feedback & Notification 部分的 HUD 元素定义了队列/优先级行为
- [ ] Visual Budget 合规：总同时元素数在预算范围内

### GDD 一致性

- [ ] `design/gdd/systems-index.md` 中 UI 类别的所有系统在 HUD 中都有表示（或有合理缺席理由）

---

## 第 3C 阶段：模式库验证检查清单

- [ ] 模式目录索引是最新的（匹配文档中的实际模式）
- [ ] 所有标准控件模式已指定：按钮变体、开关、滑块、下拉、列表、网格、模态、对话框、toast、tooltip、进度条、输入字段、标签栏、滚动
- [ ] 当前 UX 规格需要的所有游戏特定模式都存在
- [ ] 每个模式有：When to Use、When NOT to Use、完整状态规格、无障碍规格、实现说明
- [ ] Animation Standards 表存在
- [ ] Sound Standards 表存在
- [ ] 模式之间没有冲突行为（例如所有导航模式中"返回"行为一致）

---

## 第 4 阶段：输出判定

```markdown
## UX 审查：[文档名称]
**日期**：[日期]
**审查者**：ux-review skill
**文档**：[文件路径]
**平台目标**：[来自头部]
**无障碍等级**：[来自头部或 accessibility-requirements.md]

### 完整性：[X/Y 部分存在]
- [x] Purpose & Player Need
- [ ] States & Variants — MISSING：错误状态未文档化

### 质量问题：[N 个发现]
1. **[问题标题]** [BLOCKING / ADVISORY]
   - 问题是什么：[具体描述]
   - 所在位置：[部分名称]
   - 修复方案：[具体要采取的行动]

### GDD 一致性：[ALIGNED / GAPS FOUND]
- GDD [名称] UI Requirements — [X/Y 个需求已覆盖]
- 遗漏：[列出任何未覆盖的 GDD 需求]

### 无障碍：[COMPLIANT / GAPS / NON-COMPLIANT]
- 目标等级：[等级]
- [列出具体无障碍发现]

### 模式库：[CONSISTENT / INCONSISTENCIES FOUND]
- [发现]

### 判定：APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED
**阻塞问题**：[N] — 必须在实现前解决
**建议问题**：[N] — 推荐但非阻塞

[对于 APPROVED]：此规格已准备好移交给 `/team-ui` 第 2 阶段（视觉设计）。

[对于 NEEDS REVISION]：解决以上 [N] 个阻塞问题，然后重新运行 `/ux-review`。

[对于 MAJOR REVISION NEEDED]：该规格在 [区域] 存在根本性缺口。建议回到 `/ux-design` 返工 [部分]。
```

---

## 第 5 阶段：协作协议

此 Skill 为只读 — 绝不编辑或写入文件。仅报告发现。

交付判定后：
- 对于 **APPROVED**：建议运行 `/team-ui` 开始实现协调
- 对于 **NEEDS REVISION**：主动提供帮助修复具体缺口（"你希望我帮忙起草缺失的错误状态吗？"）— 但不要自动修复；等待用户指示
- 对于 **MAJOR REVISION NEEDED**：建议回到 `/ux-design` 处理需要返工的具体部分

绝不阻止用户继续 — 判定是建议性的。记录风险，呈现发现，让用户决定是否尽管有关切仍继续。选择以 NEEDS REVISION 状态继续的用户承担已文档化的风险。
