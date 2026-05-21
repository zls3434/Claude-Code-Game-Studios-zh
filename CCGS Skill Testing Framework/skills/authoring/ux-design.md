<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/ux-design

## Skill 摘要

`/ux-design` 是一个引导式的、逐节撰写的 UX 规格创作 skill。它为指定的屏幕或 HUD 元素产出用户流程图示（以文本描述）、交互状态定义、线框描述和可访问性注释。该 skill 遵循骨架优先模式：立即创建包含所有章节标题的文件，然后通过讨论逐一填充每个章节，并在用户批准后将每个章节写入磁盘。

该 skill 没有内联总监门禁 — `/ux-review` 是独立的审查步骤。每个章节需要询问"我可以将第 [N] 节写入 [文件路径] 吗？"。如果指定屏幕的 UX 规格已存在，该 skill 提供改造单个章节的选项而非替换。当所有章节写入后，裁决为 COMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 — 无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含逐节的"我可以将此写入吗？"用语
- [ ] 包含下一步交接（如 `/ux-review` 用于验证完成的规格）

---

## 总监门禁检查

无。`/ux-design` 没有内联总监门禁。`/ux-review` 是在此 skill 完成后调用的独立审查 skill。

---

## 测试用例

### 用例 1：理想路径 — 新建 HUD 规格，所有章节均已撰写并写入

**夹具：**
- `design/ux/` 中不存在 HUD UX 规格
- 引擎和渲染偏好已配置

**输入：** `/ux-design hud`

**预期行为：**
1. Skill 创建骨架文件 `design/ux/hud.md`，包含所有章节标题
2. Skill 讨论并起草每个章节：User Flows、Interaction States（normal/hover/focus/disabled）、Wireframe Description、Accessibility Notes
3. 每个章节起草完毕且用户确认后，skill 询问"我可以将第 [N] 节写入 `design/ux/hud.md` 吗？"
4. 每个章节依次在批准后写入
5. 所有章节写入后，裁决为 COMPLETE
6. Skill 建议运行 `/ux-review` 作为下一步

**断言：**
- [ ] 骨架文件最先创建（章节正文为空）
- [ ] 逐节询问"我可以将第 [N] 节写入吗？"（而非在末尾一次性批准）
- [ ] 所有必填章节均存在：User Flows、Interaction States、Wireframe Description、Accessibility Notes
- [ ] 末尾包含指向 `/ux-review` 的交接
- [ ] 裁决为 COMPLETE

---

### 用例 2：已有 UX 规格 — 改造：用户选择要更新的章节

**夹具：**
- `design/ux/hud.md` 已存在且所有章节已填充
- 用户只想更新 Accessibility Notes 章节

**输入：** `/ux-design hud`

**预期行为：**
1. Skill 读取现有 `design/ux/hud.md` 并检测所有章节已填充
2. Skill 报告："HUD 的 UX 规格已存在 — 提供改造选项"
3. Skill 列出所有章节并询问要更新哪个
4. 用户选择 Accessibility Notes
5. Skill 起草更新后的可访问性内容并询问"我可以将 Accessibility Notes 一节写入 `design/ux/hud.md` 吗？"
6. 仅该章节被更新；其他章节保持不变；裁决为 COMPLETE

**断言：**
- [ ] 检测到现有规格并提供改造选项
- [ ] 用户选择要更新的章节
- [ ] 仅所选章节被更新 — 其他章节不变
- [ ] 对更新的章节询问"我可以将此写入吗？"
- [ ] 裁决为 COMPLETE

---

### 用例 3：依赖缺口 — 规格引用了一个没有设计文档的系统

**夹具：**
- 用户正在为背包界面撰写 UX 规格
- `design/gdd/inventory.md` 不存在

**输入：** `/ux-design inventory-screen`

**预期行为：**
1. Skill 开始撰写背包界面 UX 规格
2. 在 User Flows 章节中，skill 尝试引用背包系统规则
3. Skill 检测到："未找到背包系统的 GDD — UX 规格存在依赖缺口（DEPENDENCY GAP）"
4. 依赖缺口在规格中被标记（内联注明："依赖缺口：背包 GDD"）
5. Skill 继续撰写，对缺失的规则使用占位注释
6. 裁决为 COMPLETE，附带关于依赖缺口的建议性说明

**断言：**
- [ ] 规格中出现缺失系统文档的 DEPENDENCY GAP 标签
- [ ] Skill 不会因缺失 GDD 而阻止 — 使用占位符继续
- [ ] 依赖缺口也在 skill 输出中注明（不仅限于文件内部）
- [ ] 交接同时建议 `/ux-review` 和撰写缺失的 GDD

---

### 用例 4：未提供参数 — 用法错误

**夹具：**
- skill 调用时未提供参数

**输入：** `/ux-design`

**预期行为：**
1. Skill 检测到未提供屏幕名称或参数
2. Skill 输出用法错误："需要屏幕名称。用法：`/ux-design [screen-name]`"
3. Skill 提供示例：`/ux-design hud`、`/ux-design main-menu`、`/ux-design inventory`
4. 不创建任何文件；不询问"我可以将此写入吗？"

**断言：**
- [ ] 用法错误被明确陈述
- [ ] 提供示例调用
- [ ] 不创建任何文件
- [ ] Skill 不会在无参数情况下尝试继续

---

### 用例 5：总监门禁检查 — 无门禁；ux-review 是独立的审查 skill

**夹具：**
- 提供了参数的新屏幕规格

**输入：** `/ux-design settings-menu`

**预期行为：**
1. Skill 撰写设置菜单 UX 规格的所有章节
2. 不会生成任何总监 Agent
3. 撰写过程中输出中不出现门禁 ID

**断言：**
- [ ] 在 ux-design 期间不会调用任何总监门禁
- [ ] 不出现门禁跳过消息
- [ ] 裁决为 COMPLETE，无需任何门禁检查

---

## 协议合规

- [ ] 在讨论内容之前创建包含所有章节标题的骨架文件
- [ ] 每次讨论并起草一个章节
- [ ] 每个章节批准后询问"我可以将第 [N] 节写入吗？"
- [ ] 检测到已有规格时提供改造路径
- [ ] 以指向 `/ux-review` 的交接结束
- [ ] 当所有章节写入后，裁决为 COMPLETE

---

## 覆盖说明

- 交互状态枚举（normal/hover/focus/disabled/error）是每个规格的核心要求；`/ux-review` skill 会检查完整性。
- 线框描述仅为文本形式（无图像）；图像引用可由设计师事后手动添加。
- 响应式布局问题（不同屏幕尺寸）被列为可选内容，不在此进行断言测试。
