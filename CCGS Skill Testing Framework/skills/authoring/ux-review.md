<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/ux-review

## Skill 摘要

`/ux-review` 根据可访问性和交互标准验证现有的 UX 规格或 HUD 设计文档。它检查必填章节（User Flows、Interaction States、Wireframe Description、Accessibility Notes）、交互状态定义的完整性（hover、focus、disabled、error）、可访问性合规（键盘导航、颜色对比度注释、屏幕阅读器考量），以及与美术圣经或设计系统的一致性（如果这些文档存在）。

该 skill 是只读的 — 不产出任何文件写入。裁决：APPROVED（所有检查通过）、NEEDS REVISION（发现可修复的问题）或 MAJOR REVISION NEEDED（结构性或可访问性失败）。无总监门禁适用 — `/ux-review` 本身就是 UX 规格的审查门禁。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 — 无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含裁决关键词：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 不包含"我可以将此写入吗？"用语（skill 是只读的）
- [ ] 包含下一步交接（如返回 `/ux-design` 修订，或继续实施）

---

## 总监门禁检查

无。`/ux-review` 本身就是 UX 规格的审查门禁。此 skill 内不会调用额外的总监门禁。

---

## 测试用例

### 用例 1：理想路径 — 包含所有必填章节的完整 UX 规格，APPROVED

**夹具：**
- `design/ux/hud.md` 存在且所有必填章节已填充：
  - User Flows：完整的玩家流程图示
  - Interaction States：normal、hover、focus、disabled、error 均已定义
  - Wireframe Description：布局已描述
  - Accessibility Notes：键盘导航、对比度比率、屏幕阅读器注释

**输入：** `/ux-review hud`

**预期行为：**
1. Skill 读取 `design/ux/hud.md`
2. Skill 检查所有 4 个必填章节 — 全部存在且非空
3. Skill 检查交互状态 — 所有 5 个状态均已定义
4. Skill 检查可访问性注释 — 键盘、对比度和屏幕阅读器已涵盖
5. Skill 输出：所有通过检查的清单
6. 裁决为 APPROVED

**断言：**
- [ ] 所有 4 个必填章节均已检查
- [ ] 验证所有 5 个交互状态均已存在
- [ ] 裁决为 APPROVED
- [ ] 不写入任何文件

---

### 用例 2：缺失可访问性章节 — NEEDS REVISION

**夹具：**
- `design/ux/hud.md` 存在，但 Accessibility Notes 章节为空
- 所有其他章节已完全填充

**输入：** `/ux-review hud`

**预期行为：**
1. Skill 读取文件并检查所有章节
2. Accessibility Notes 章节为空 — 检查失败
3. Skill 输出："NEEDS REVISION — Accessibility Notes 章节为空"
4. Skill 列出需要添加的具体项目：键盘导航、颜色对比度比率、屏幕阅读器标签
5. 裁决为 NEEDS REVISION
6. 交接建议返回 `/ux-design hud` 填充该章节

**断言：**
- [ ] 返回 NEEDS REVISION 裁决（而非 APPROVED 或 MAJOR REVISION NEEDED）
- [ ] 列出具体的缺失内容项
- [ ] 交接指向 `/ux-design hud` 进行修订
- [ ] 不写入任何文件

---

### 用例 3：交互状态不完整 — NEEDS REVISION

**夹具：**
- `design/ux/settings-menu.md` 存在
- Interaction States 章节仅定义了：normal 和 hover
- 缺失：focus、disabled、error 状态

**输入：** `/ux-review settings-menu`

**预期行为：**
1. Skill 读取文件并检查交互状态
2. 5 个必填状态中仅 2 个已定义
3. Skill 报告："NEEDS REVISION — 交互状态不完整：缺失 focus、disabled、error"
4. 裁决为 NEEDS REVISION，并明确指出缺失的具体状态

**断言：**
- [ ] 返回 NEEDS REVISION 裁决
- [ ] 输出中明确指出全部 3 个缺失的状态
- [ ] Skill 不会对可修复的缺口返回 MAJOR REVISION NEEDED
- [ ] 交接建议返回 `/ux-design settings-menu`

---

### 用例 4：文件未找到 — 错误与补救建议

**夹具：**
- `design/ux/inventory-screen.md` 不存在

**输入：** `/ux-review inventory-screen`

**预期行为：**
1. Skill 尝试读取 `design/ux/inventory-screen.md` — 文件未找到
2. Skill 输出："UX 规格未找到：design/ux/inventory-screen.md"
3. Skill 建议先运行 `/ux-design inventory-screen` 以创建规格
4. 不执行审查；不发布裁决

**断言：**
- [ ] 错误消息指明缺失文件的完整路径
- [ ] 建议 `/ux-design inventory-screen` 作为补救措施
- [ ] 不产出审查清单
- [ ] 不发布裁决（错误状态，非 APPROVED/NEEDS REVISION）

---

### 用例 5：总监门禁检查 — 无门禁；ux-review 本身就是审查

**夹具：**
- 有效的 UX 规格文件

**输入：** `/ux-review hud`

**预期行为：**
1. Skill 执行审查并发布裁决
2. 不会生成额外的总监 Agent
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不会调用任何总监门禁
- [ ] 不出现门禁跳过消息
- [ ] 裁决为 APPROVED、NEEDS REVISION 或 MAJOR REVISION NEEDED — 非门禁裁决

---

## 协议合规

- [ ] 检查所有 4 个必填章节（User Flows、Interaction States、Wireframe、Accessibility Notes）
- [ ] 检查所有 5 个交互状态（normal、hover、focus、disabled、error）
- [ ] 检查可访问性覆盖范围（键盘导航、对比度、屏幕阅读器）
- [ ] 不写入任何文件
- [ ] 当裁决非 APPROVED 时，提出具体的、可操作的反馈
- [ ] 以下一步交接结束，指向 `/ux-design` 进行修订或继续实施

---

## 覆盖说明

- 当结构性章节完全缺失（而非仅为空）或基础交互流程完全缺失时，会触发 MAJOR REVISION NEEDED；未在此用单独夹具测试。
- 美术圣经 / 设计系统一致性检查（调色板对齐）被列为一项能力但未单独进行夹具测试。
- 现有规格针对现已更名的屏幕编写的情况未测试；无论如何，skill 会按路径审查文件。
