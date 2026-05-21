<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/team-combat

## Skill 摘要

为单个战斗功能端到端编排完整的战斗团队流水线。协调 game-designer、gameplay-programmer、ai-programmer、technical-artist、sound-designer、主引擎 specialist 和 qa-tester 通过六个结构化阶段：Design → Architecture（含引擎 specialist 验证）→ Implementation（并行）→ Integration → Validation → Sign-off。在每个阶段转换点使用 `AskUserQuestion`。将所有文件写入委托给子 agent。生成摘要报告，verdict 为 COMPLETE / NEEDS WORK / BLOCKED，并移交至 `/code-review`、`/balance-check` 和 `/team-polish`。

---

## 静态断言（结构层面）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题（Phase 1 到 Phase 6 全部存在）
- [ ] 包含 verdict 关键字：COMPLETE、NEEDS WORK、BLOCKED
- [ ] 包含 "May I write" 或 "File Write Protocol" — 写入委托给子 agent，编排者不直接写入文件
- [ ] 包含下一步移交指引（引用 `/code-review`、`/balance-check`、`/team-polish`）
- [ ] 包含 Error Recovery Protocol 部分及四个恢复步骤
- [ ] 在阶段转换点使用 `AskUserQuestion`，待用户批准后方可继续
- [ ] Phase 3 显式标记为并行（gameplay-programmer、ai-programmer、technical-artist、sound-designer）
- [ ] Phase 2 包含生成主引擎 specialist（从 `.claude/docs/technical-preferences.md` 读取）
- [ ] Team Composition 列出全部七个角色（game-designer、gameplay-programmer、ai-programmer、technical-artist、sound-designer、engine specialist、qa-tester）

---

## 测试用例

### 用例 1：正常路径 — 所有 agent 成功，完整流水线运行至完成

**Fixture：**
- `design/gdd/game-concept.md` 存在并已填充
- 引擎已在 `.claude/docs/technical-preferences.md` 中配置（Engine Specialists 部分已填写）
- 请求的战斗功能尚无已有 GDD

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. Phase 1 — 生成 game-designer；生成 `design/gdd/parry-riposte.md`，覆盖全部 8 个必填部分（overview、player fantasy、rules、formulas、edge cases、dependencies、tuning knobs、acceptance criteria）；请求用户批准设计文档
2. Phase 2 — 生成 gameplay-programmer + ai-programmer；生成架构草图，包含类结构、接口和文件列表；然后生成主引擎 specialist 验证惯用方法；合并引擎 specialist 输出；`AskUserQuestion` 在 Phase 3 开始前展示架构选项
3. Phase 3 — 并行生成 gameplay-programmer、ai-programmer、technical-artist、sound-designer；全部四个返回输出后 Phase 4 开始
4. Phase 4 — 集成连接所有 Phase 3 输出；验证 tuning knobs 为数据驱动；`AskUserQuestion` 在 Phase 5 前确认集成
5. Phase 5 — 生成 qa-tester；基于 acceptance criteria 编写测试用例；验证边缘情况；对照预算检查性能影响
6. Phase 6 — 生成摘要报告：design COMPLETE、所有团队成员 COMPLETE、测试用例列出，verdict：COMPLETE
7. 列出下一步：`/code-review`、`/balance-check`、`/team-polish`

**断言：**
- [ ] `AskUserQuestion` 在每个阶段关卡调用（至少 Phase 3 前和 Phase 5 前）
- [ ] Phase 3 agent 同时启动 — gameplay-programmer、ai-programmer、technical-artist、sound-designer 之间无顺序依赖
- [ ] Engine specialist 在 Phase 2 中运行，在 Phase 3 开始之前完成（输出合并至架构中）
- [ ] 所有文件写入委托给子 agent（编排者从不直接调用 Write/Edit）
- [ ] Verdict COMPLETE 出现在最终报告中
- [ ] 下一步包含 `/code-review`、`/balance-check`、`/team-polish`
- [ ] 设计文档覆盖全部 8 个必填 GDD 部分

---

### 用例 2：受阻 Agent — 一个子 agent 在流水线中途返回 BLOCKED

**Fixture：**
- `design/gdd/parry-riposte.md` 存在（Phase 1 已完成）
- ai-programmer agent 返回 BLOCKED，因为不存在 AI system architecture ADR（ADR 状态为 Proposed）

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. Phase 1 — 找到设计文档；game-designer 确认有效；阶段批准
2. Phase 2 — gameplay-programmer 完成架构草图；ai-programmer 返回 BLOCKED："AI 行为系统 ADR 为 Proposed — 在 ADR 变为 Accepted 之前无法实现"
3. 触发 Error Recovery Protocol："ai-programmer: BLOCKED — AI 行为 ADR 为 Proposed"
4. `AskUserQuestion` 展示选项：(a) 跳过 ai-programmer 并注明缺口；(b) 以更窄范围重试；(c) 在此停止，先运行 `/architecture-decision`
5. 如果用户选择 (a)：Phase 3 仅使用 gameplay-programmer、technical-artist、sound-designer 继续；ai-programmer 缺口在部分报告中注明
6. 生成最终报告：文档化部分实现，ai-programmer 部分标记为 BLOCKED，整体 verdict：BLOCKED

**断言：**
- [ ] BLOCKED 浮现消息在任何依赖阶段继续之前出现
- [ ] `AskUserQuestion` 提供至少三个选项：跳过 / 重试 / 停止
- [ ] 生成部分报告 — 已完成 agent 的工作不被丢弃
- [ ] 任何 agent 未解决时，整体 verdict 为 BLOCKED（非 COMPLETE）
- [ ] 阻塞原因引用 ADR 并建议 `/architecture-decision`
- [ ] 编排者不会静默越过受阻依赖继续执行

---

### 用例 3：无参数 — 显示清晰的使用指南

**Fixture：**
- 任何项目状态

**输入：** `/team-combat`（无参数）

**预期行为：**
1. Skill 检测到未提供参数
2. 输出使用消息，解释所需参数（战斗功能描述）
3. 提供调用示例：`/team-combat [combat feature description]`
4. Skill 退出，不生成任何子 agent

**断言：**
- [ ] 未提供参数时 skill 不生成任何子 agent
- [ ] 使用消息包含来自 frontmatter 的 argument-hint 格式
- [ ] 错误消息包含至少一个有效调用示例
- [ ] 除检测缺少参数所需外，不读取任何文件
- [ ] Verdict 不显示（流水线从未运行）

---

### 用例 4：并行阶段验证 — Phase 3 agent 同时运行

**Fixture：**
- `design/gdd/parry-riposte.md` 存在且完整
- 架构草图已批准
- Engine specialist 已验证架构

**输入：** `/team-combat parry and riposte system`（从 Phase 2 完成后恢复）

**预期行为：**
1. 架构批准后 Phase 3 开始
2. 全部四个 Task 调用 — gameplay-programmer、ai-programmer、technical-artist、sound-designer — 在等待任何结果之前发出
3. Skill 等待全部四个 agent 完成后再进入 Phase 4
4. 如果某个 agent 提前完成，skill 不会在全部四个返回之前开始 Phase 4

**断言：**
- [ ] 四个 Task 调用在同一批次中发出（它们之间无顺序等待）
- [ ] Phase 4 在全部四个 Phase 3 agent 返回结果之前不开始
- [ ] Skill 不会将一个 Phase 3 agent 的输出作为另一个 Phase 3 agent 的输入传递（它们彼此独立）
- [ ] 全部四个 Phase 3 agent 结果在 Phase 4 集成步骤中被引用

---

### 用例 5：架构阶段引擎路由 — Engine specialist 收到正确的上下文

**Fixture：**
- `.claude/docs/technical-preferences.md` 的 Engine Specialists 部分已填充（例如 Primary: godot-specialist）
- gameplay-programmer 生成的架构草图可用
- 引擎版本固定于 `docs/engine-reference/godot/VERSION.md`

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. Phase 2 — gameplay-programmer 生成架构草图
2. Skill 读取 `.claude/docs/technical-preferences.md` 的 Engine Specialists 部分以识别主引擎 specialist agent 类型
3. Engine specialist 被生成并配备：架构草图、GDD 路径、来自 `VERSION.md` 的引擎版本，以及检查已弃用 API 的明确指令
4. Engine specialist 输出（惯用方法注释、已弃用 API 警告、原生系统建议）返回给编排者
5. 编排者在向用户展示 Phase 2 结果之前将引擎注释合并到架构中
6. `AskUserQuestion` 包含 engine specialist 的注释以及架构草图

**断言：**
- [ ] Engine specialist agent 类型从 `.claude/docs/technical-preferences.md` 读取 — 非硬编码
- [ ] Engine specialist 提示包含架构草图和 GDD 路径
- [ ] Engine specialist 根据固定引擎版本检查已弃用 API
- [ ] Engine specialist 输出在 Phase 3 开始前合并（非跳过或单独追加）
- [ ] 如果未配置引擎，engine specialist 步骤跳过并在报告中添加注释

---

## 协议合规

- [ ] 在每个阶段转换点使用 `AskUserQuestion` — 用户批准后方可推进流水线
- [ ] 所有文件写入通过 Task 委托给子 agent — 编排者不直接调用 Write 或 Edit
- [ ] 遵循 Error Recovery Protocol：浮现 → 评估 → 提供选项 → 部分报告
- [ ] Phase 3 agent 按 skill 规格并行启动
- [ ] 即使 agent 处于 BLOCKED 状态，始终生成部分报告
- [ ] Verdict 为 COMPLETE / NEEDS WORK / BLOCKED 之一
- [ ] 输出末尾列出下一步：`/code-review`、`/balance-check`、`/team-polish`

---

## 覆盖说明

- NEEDS WORK verdict 路径（qa-tester 在 Phase 5 发现失败）此处不单独测试；它遵循与用例 2 相同的 error recovery 和 partial report 协议。
- "缩小范围重试"的 error recovery 选项在断言中列出，但其完整递归行为（通过 `/create-stories` 拆分）由 `/create-stories` 规格覆盖。
- Phase 4 集成逻辑（连接 gameplay、AI、VFX、audio）在正常路径用例中隐式验证；独立集成测试需要 fixture 代码文件。
- Engine specialist 不可用（未配置引擎）在用例 5 中断言中部分覆盖 — 未配置引擎状态的独立 fixture 可加强覆盖。
