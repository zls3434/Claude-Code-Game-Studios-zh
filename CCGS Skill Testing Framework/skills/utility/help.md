<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/help

## Skill 摘要

`/help` 分析已完成的工作和项目工作流中接下来的步骤。它在 Haiku 模型上运行（只读、格式化任务），读取 `production/stage.txt`、活动冲刺文件和最近的会话状态，生成简洁的情境引导摘要。该 skill 可选接受上下文查询（例如，`/help testing`）以展示特定主题的相关 skills。

输出始终是信息性的——不写入文件，不调用 director gate。判决始终为 HELP COMPLETE。该 skill 充当工作流导航器，根据当前项目状态建议 2-3 个后续 skills。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：HELP COMPLETE
- [ ] 不包含 "May I write" 语言（skill 是只读的）
- [ ] 有下一步交接（基于状态建议 2-3 个相关 skills）

---

## Director Gate 检查

无。`/help` 是一个只读导航 skill。不适用 director gate。

---

## 测试用例

### 用例 1：Happy Path — Production 阶段，有活动冲刺

**Fixture：**
- `production/stage.txt` 包含 `Production`
- `production/sprints/sprint-004.md` 存在，有进行中的故事
- `production/session-state/active.md` 有一个最近检查点

**输入：** `/help`

**预期行为：**
1. Skill 读取 stage.txt 和活动冲刺
2. Skill 识别当前冲刺编号和进行中的故事数量
3. Skill 输出：当前阶段、冲刺摘要和 3 个建议的后续 skills（例如，`/sprint-status`、`/dev-story`、`/story-done`）
4. 建议按与当前冲刺状态的相关性排序
5. 判决为 HELP COMPLETE

**断言：**
- [ ] 显示当前阶段（Production）
- [ ] 提及活动冲刺编号和故事数量
- [ ] 恰好给出 2-3 个后续 skill 建议（而非所有 skills 的列表）
- [ ] 建议适用于 Production 阶段
- [ ] 判决为 HELP COMPLETE
- [ ] 没有文件被写入

---

### 用例 2：Concept 阶段 — 显示概念到系统设计的工作流路径

**Fixture：**
- `production/stage.txt` 包含 `Concept`
- 无冲刺文件，无 GDD 文件
- `technical-preferences.md` 已配置（已选择引擎）

**输入：** `/help`

**预期行为：**
1. Skill 读取 stage.txt — 检测到 Concept 阶段
2. Skill 输出 Concept 阶段工作流：brainstorm → map-systems → design-system
3. 建议的 skills 为：`/brainstorm`、`/map-systems`（如果概念已存在）
4. 注明当前进度："Engine configured, concept not yet created"

**断言：**
- [ ] 阶段识别为 Concept
- [ ] 工作流路径显示此阶段的预期顺序
- [ ] 建议不包含 Production 阶段 skills（例如 `/dev-story`）
- [ ] 判决为 HELP COMPLETE

---

### 用例 3：无 stage.txt — 显示完整工作流概览

**Fixture：**
- 无 `production/stage.txt`
- 无冲刺文件
- `technical-preferences.md` 为占位符

**输入：** `/help`

**预期行为：**
1. Skill 无法从 stage.txt 确定阶段
2. Skill 运行 project-stage-detect 逻辑从工件推断阶段
3. 如果无法推断阶段：输出从 Concept 到 Release 的完整工作流概览作为参考图
4. 主要建议是 `/start` 开始配置

**断言：**
- [ ] stage.txt 缺失时 skill 不崩溃
- [ ] 无法确定阶段时显示完整工作流概览
- [ ] `/start` 或 `/project-stage-detect` 是首要建议
- [ ] 判决为 HELP COMPLETE

---

### 用例 4：上下文查询 — 用户请求关于测试的帮助

**Fixture：**
- `production/stage.txt` 包含 `Production`
- 活动冲刺有一个 `Status: In Review` 的故事

**输入：** `/help testing`

**预期行为：**
1. Skill 读取上下文查询："testing"
2. Skill 展示与测试相关的 skills：`/qa-plan`、`/smoke-check`、`/regression-suite`、`/test-setup`、`/test-evidence-review`
3. 输出聚焦测试工作流，而非通用冲刺导航
4. 当前正在审查的故事被标记为测试候选

**断言：**
- [ ] 输出中确认了上下文查询（"Help topic: testing"）
- [ ] 列出至少 3 个测试相关的 skills
- [ ] 通用冲刺 skills（例如 `/sprint-plan`）不是主要建议
- [ ] 判决为 HELP COMPLETE

---

### 用例 5：Director Gate 检查 — 无 gate；help 是只读导航

**Fixture：**
- 任何项目状态

**输入：** `/help`

**预期行为：**
1. Skill 生成工作流引导摘要
2. 不生成任何 director agent
3. 输出中不出现 gate ID
4. 不调用写入工具

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不调用写入工具
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 HELP COMPLETE，无任何 gate 检查

---

## 协议合规性

- [ ] 在生成建议前读取阶段、冲刺和会话状态
- [ ] 建议针对当前项目状态（非通用）
- [ ] 上下文查询（如提供）缩小建议集
- [ ] 不写入任何文件
- [ ] 所有情况下判决均为 HELP COMPLETE

---

## 覆盖说明

- 活动冲刺已完成（所有故事 Done）的情况不单独测试；skill 会建议 `/sprint-plan` 用于下一个冲刺。
- `/help` skill 不验证建议的 skills 是否可用 — 它假定标准 skill 目录可用。
- 阶段检测回退（stage.txt 缺失时）委托给与 `/project-stage-detect` 相同的逻辑，此处不重新详细测试。
