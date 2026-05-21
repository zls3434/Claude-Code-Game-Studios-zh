<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/team-ui

## Skill 摘要

为单个 UI 功能编排 UI 团队完成完整的 UX 流水线。协调 ux-designer、ui-programmer、art-director、引擎 UI 专家以及 accessibility-specialist，通过五个结构化阶段：上下文收集 + UX 规格说明（阶段 1a/1b）→ UX 评审关卡（阶段 1c）→ 视觉设计（阶段 2）→ 实现（阶段 3）→ 并行评审（阶段 4）→ 打磨（阶段 5）。在每个阶段转换处使用 `AskUserQuestion`。将所有文件写入委托给子 Agent 和子 Skill（`/ux-design`、`ui-programmer`）。生成一份总结报告，附有 COMPLETE / BLOCKED 裁定以及向 `/ux-review`、`/code-review`、`/team-polish` 的交接指示。

---

## 静态断言（结构层面）

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题（阶段 1a 到阶段 5 全部存在）
- [ ] 包含裁定关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 或 "File Write Protocol" — 文件写入委托给子 Agent 和子 Skill，编排者不直接写文件
- [ ] 末尾有下一步交接指示（引用 `/ux-review`、`/code-review`、`/team-polish`）
- [ ] 错误恢复协议（Error Recovery Protocol）章节存在，包含全部四个恢复步骤
- [ ] 在阶段转换处使用 `AskUserQuestion` 获取用户审批后再继续
- [ ] 阶段 4 明确标记为并行（ux-designer、art-director、accessibility-specialist）
- [ ] UX 评审关卡（阶段 1c）定义为阻塞关卡 — 未获得 APPROVED 裁定前 Skill 不得进入阶段 2
- [ ] 团队组成列出了全部五个角色（ux-designer、ui-programmer、art-director、引擎 UI 专家、accessibility-specialist）
- [ ] 引用了交互模式库（`design/ux/interaction-patterns.md`）— ui-programmer 必须使用已有模式
- [ ] 阶段 1a 在设计开始前读取 `design/accessibility-requirements.md`

---

## 测试用例

### 用例 1：Happy Path — 从 UX 规格说明到打磨的完整流水线成功完成

**测试夹具：**
- `design/gdd/game-concept.md` 存在，包含目标平台和预期受众
- `design/player-journey.md` 存在
- `design/ux/interaction-patterns.md` 存在，包含相关模式
- `design/accessibility-requirements.md` 存在，包含已承诺的等级（例如 Enhanced）
- 引擎 UI 专家已在 `.claude/docs/technical-preferences.md` 中配置

**输入：** `/team-ui inventory screen`

**预期行为：**
1. 阶段 1a — 编排者读取 game-concept.md、player-journey.md、相关 GDD UI 章节、interaction-patterns.md、accessibility-requirements.md；为 ux-designer 总结一份简报
2. 阶段 1b — 调用 `/ux-design inventory-screen`（或直接启动 ux-designer）；使用 `ux-spec.md` 模板产出 `design/ux/inventory-screen.md`；评审前用 `AskUserQuestion` 确认规格说明
3. 阶段 1c — 调用 `/ux-review design/ux/inventory-screen.md`；返回 APPROVED；关卡通过，进入阶段 2
4. 阶段 2 — 启动 art-director；评审完整的 UX 规格说明（不仅是线框图）；应用视觉处理；验证颜色对比度；产出包含资源清单的视觉设计规格说明；阶段 3 前用 `AskUserQuestion` 确认
5. 阶段 3 — 首先启动引擎 UI 专家（从 technical-preferences.md 读取）；为 ui-programmer 产出实现说明；启动 ui-programmer，附有 UX 规格说明 + 视觉规格说明 + 引擎说明；产出实现代码；如果引入了新模式则更新 interaction-patterns.md
6. 阶段 4 — 并行启动 ux-designer、art-director、accessibility-specialist；三者全部返回结果后再进入阶段 5
7. 阶段 5 — 处理评审反馈；验证动画可跳过；通过音频事件系统确认 UI 音效；interaction-patterns.md 最终检查；裁定：COMPLETE
8. 总结报告：UX 规格说明 APPROVED，视觉设计 COMPLETE，实现 COMPLETE，无障碍 COMPLIANT，所有输入方式均受支持，模式库已更新，裁定：COMPLETE

**断言：**
- [ ] 阶段 1a 在向 ux-designer 简报前读取全部五个来源
- [ ] UX 评审关卡在阶段 2 之前检查 — 在获得 APPROVED 之前阶段 2 不得开始
- [ ] 阶段 2 中的 art-director 评审完整规格说明，而不仅是线框图图像
- [ ] 阶段 3 中引擎 UI 专家在 ui-programmer 之前启动
- [ ] 阶段 4 的 Agent 同时启动（ux-designer、art-director、accessibility-specialist）
- [ ] 所有文件写入委托给子 Agent 和子 Skill
- [ ] 最终总结报告中裁定为 COMPLETE
- [ ] 下一步包括 `/ux-review`、`/code-review`、`/team-polish`

---

### 用例 2：UX 评审关卡 — 规格说明未通过评审；Skill 在实现前停止

**测试夹具：**
- 阶段 1b 产出了 `design/ux/inventory-screen.md`
- `/ux-review` 返回裁定 NEEDS REVISION 并标记了具体问题（例如手柄导航流程不完整、对比度低于最低要求）

**输入：** `/team-ui inventory screen`

**预期行为：**
1. 阶段 1a + 1b 完成 — UX 规格说明已产出
2. 阶段 1c — `/ux-review design/ux/inventory-screen.md` 返回 NEEDS REVISION
3. Skill 不进入阶段 2
4. `AskUserQuestion` 展示具体标记的问题并提供选项：
   - (a) 返回 ux-designer 解决问题并重新评审
   - (b) 接受风险并仍然进入阶段 2（有意识的决定）
5. 若用户选择 (a)：ux-designer 修订规格说明，重新运行 `/ux-review`；循环持续直到 APPROVED 或用户主动覆盖
6. 若用户选择 (b)：Skill 继续运行，在最终报告中附上明确的 NEEDS REVISION 注释
7. Skill 不静默越过关卡

**断言：**
- [ ] 在 UX 评审裁定为 NEEDS REVISION 时阶段 2 不开始
- [ ] `AskUserQuestion` 在提供选项前展示具体标记的问题
- [ ] 用户必须做出有意识的选择才能覆盖 — Skill 不假定覆盖
- [ ] 若用户接受风险，NEEDS REVISION 问题记录在最终报告中
- [ ] 提供修订并重新评审的循环（不是一次性的失败）
- [ ] Skill 不丢弃已产出的 UX 规格说明

---

### 用例 3：无参数 — 显示使用说明

**测试夹具：**
- 任意项目状态

**输入：** `/team-ui`（无参数）

**预期行为：**
1. Skill 检测到未提供参数
2. 输出使用说明，解释必需的参数（UI 功能描述）
3. 提供示例调用：`/team-ui [UI 功能描述]`
4. Skill 退出，不启动任何子 Agent，不读取任何项目文件

**断言：**
- [ ] 无参数时 Skill 不启动任何子 Agent
- [ ] 使用说明包含 frontmatter 中的 argument-hint 格式
- [ ] 至少展示一个有效调用示例
- [ ] 失败前未读取任何 UX 规格说明文件或 GDD
- [ ] 不显示裁定（流水线从未开始）

---

### 用例 4：无障碍并行评审 — 阶段 4 同时运行三个流

**测试夹具：**
- `design/ux/inventory-screen.md` 存在（APPROVED）
- 视觉设计规格说明完整
- 实现完整
- `design/accessibility-requirements.md` 已承诺等级：Enhanced

**输入：** `/team-ui inventory screen`（从阶段 3 完成后恢复）

**预期行为：**
1. 实现确认完成后阶段 4 开始
2. 同时发出三个 Task 调用：ux-designer、art-director、accessibility-specialist
3. 每个流独立运行：
   - ux-designer：验证实现与线框图匹配，测试仅键盘和仅手柄导航，检查无障碍功能是否正常
   - art-director：验证视觉在最低和最高支持分辨率下与美术规范的一致性
   - accessibility-specialist：对照 `design/accessibility-requirements.md` 中的 Enhanced 无障碍等级进行审计；任何违规标记为阻塞项
4. Skill 等待全部三个结果后再进入阶段 5
5. 阶段 5 开始前，`AskUserQuestion` 展示全部三个评审结果

**断言：**
- [ ] 全部三个 Task 调用在等待任何结果之前发出（并行，而非顺序）
- [ ] 阶段 4 的三个 Agent 全部返回后阶段 5 才开始
- [ ] accessibility-specialist 明确读取 `design/accessibility-requirements.md` 以获取已承诺等级
- [ ] 无障碍违规标记为 BLOCKING（而不仅是建议性的）
- [ ] `AskUserQuestion` 在阶段 5 审批前一起展示全部三个评审流的结果
- [ ] 没有任何阶段 4 Agent 的输出被用作另一个阶段 4 Agent 的输入

---

### 用例 5：缺少交互模式库 — Skill 标注此差距而不是凭空创造模式

**测试夹具：**
- `design/ux/interaction-patterns.md` 不存在
- 其他所有必需文件存在

**输入：** `/team-ui settings menu`

**预期行为：**
1. 阶段 1a — 编排者尝试读取 `design/ux/interaction-patterns.md`；文件未找到
2. Skill 呈现此差距："interaction-patterns.md 不存在 — 无可复用的已有模式"
3. `AskUserQuestion` 展示选项：
   - (a) 先运行 `/ux-design patterns` 建立模式库，然后继续
   - (b) 无模式库继续 — ux-designer 将在创建新模式时进行文档记录
4. Skill 不从其他来源凭空创造或假定模式
5. 若用户选择 (b)：明确指示 ui-programmer 将所有创建的模式视为新模式，并在完成后逐一添加到新的 `design/ux/interaction-patterns.md` 中
6. 最终报告注明 interaction-patterns.md 已创建（或若用户跳过则仍不存在）

**断言：**
- [ ] Skill 不静默忽略缺失的模式库
- [ ] Skill 不通过猜测功能名称或仅凭 GDD 来凭空创造模式
- [ ] `AskUserQuestion` 提供"先创建模式库"选项（引用 `/ux-design patterns`）
- [ ] 若用户无模式库继续，告知 ui-programmer 将所有模式视为新模式
- [ ] 最终报告记录模式库状态（已创建 / 不存在 / 已更新）
- [ ] Skill 不完全失败 — 差距被标注，用户获得选择权

---

## 协议合规

- [ ] 每个阶段转换处使用 `AskUserQuestion` — 用户在流水线推进前审批
- [ ] UX 评审关卡（阶段 1c）是阻塞性的 — 无 APPROVED 或明确的用户覆盖时阶段 2 不得开始
- [ ] 所有文件写入委托给子 Agent 和子 Skill — 编排者不直接调用 Write 或 Edit
- [ ] 阶段 4 Agent 按 Skill 规范并行启动
- [ ] 遵循错误恢复协议：呈现 → 评估 → 提供选项 → 部分报告
- [ ] 即使 Agent 处于 BLOCKED 状态，始终产出一份部分报告
- [ ] 裁定为 COMPLETE / BLOCKED 之一
- [ ] 末尾有下一步：`/ux-review`、`/code-review`、`/team-polish`

---

## 覆盖说明

- HUD 特定路径（`/ux-design hud` + `hud-design.md` 模板 + 阶段 5 中的视觉预算检查）
  此处未单独测试；它与普通路径共享相同的阶段结构，但使用不同的模板。
- interaction-patterns.md 的"就地更新"路径（实现期间添加新模式）
  在用例 1 步骤 5 中被隐式覆盖 — 若有一个带有已知新模式的专用测试夹具会更完整。
- 引擎 UI 专家不可用（未配置引擎）— Skill 规范声明"如果未配置引擎则跳过"；
  此路径在用例 1 中被断言但未提供专用测试夹具。
- NEEDS REVISION 接受风险覆盖（用例 2 选项 b）要求覆盖操作
  明确记录在报告中；此处有断言但未测试下游影响。
