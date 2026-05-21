<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/qa-plan

## Skill 摘要

`/qa-plan` 为功能或冲刺里程碑生成结构化的 QA 测试计划。它读取指定冲刺的故事文件，从每个故事中提取验收标准，交叉引用 `coding-standards.md` 中的测试标准以分配适当的测试类型（单元测试、集成测试、视觉测试、UI 测试或配置/数据测试），并生成按优先级排序的 QA 计划文档。

该 skill 在持久化输出前询问 "May I write to `production/qa/qa-plan-sprint-NNN.md`?"。如果同一冲刺的现有测试计划已存在，skill 会提供更新而非替换的选项。计划写入后判决为 COMPLETE。不使用 director gate——gate 级别的故事就绪性由 `/story-readiness` 处理。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：COMPLETE
- [ ] 在写入计划前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，`/smoke-check` 或 `/story-readiness`）

---

## Director Gate 检查

无。`/qa-plan` 是一个计划工具。故事就绪性 gate 是独立的。

---

## 测试用例

### 用例 1：Happy Path — 包含 4 个故事的冲刺，生成完整测试计划

**Fixture：**
- `production/sprints/sprint-003.md` 列出 4 个有定义的验收标准的故事
- 故事跨度类型：1 个逻辑（公式）、1 个集成、1 个视觉、1 个 UI
- `coding-standards.md` 存在，包含测试证据表

**输入：** `/qa-plan sprint-003`

**预期行为：**
1. Skill 读取 sprint-003.md 并识别 4 个故事
2. Skill 读取每个故事的验收标准
3. Skill 根据 coding-standards.md 表分配测试类型：
   - 逻辑故事 → 单元测试（BLOCKING）
   - 集成故事 → 集成测试（BLOCKING）
   - 视觉故事 → 截图 + 主管签字（ADVISORY）
   - UI 故事 → 手动走查文档（ADVISORY）
4. Skill 草拟 QA 计划，包含逐故事测试类型分解
5. Skill 询问 "May I write to `production/qa/qa-plan-sprint-003.md`?"
6. 批准后写入文件；判决为 COMPLETE

**断言：**
- [ ] 计划中包含全部 4 个故事
- [ ] 测试类型按 coding-standards.md 分配（非猜测）
- [ ] 每个故事注明 gate 级别（BLOCKING vs ADVISORY）
- [ ] "May I write" 以正确的文件路径询问
- [ ] 判决为 COMPLETE

---

### 用例 2：故事无验收标准 — 标记为 UNTESTABLE

**Fixture：**
- `production/sprints/sprint-004.md` 列出 3 个故事；一个故事的验收标准 section 为空

**输入：** `/qa-plan sprint-004`

**预期行为：**
1. Skill 读取全部 3 个故事
2. Skill 检测到无 AC 的故事
3. 该故事在计划中标记为 `UNTESTABLE — Acceptance Criteria required`
4. 其余 2 个故事获得正常的测试类型分配
5. 计划以 UNTESTABLE 故事被标记写入；判决为 COMPLETE

**断言：**
- [ ] UNTESTABLE 标签出现在无 AC 的故事上
- [ ] 计划不被阻塞 — 其他故事仍有计划
- [ ] 输出建议向被标记的故事添加 AC（下一步）
- [ ] 判决为 COMPLETE（计划仍然生成）

---

### 用例 3：现有测试计划存在 — 提供更新而非替换

**Fixture：**
- `production/qa/qa-plan-sprint-003.md` 已存在，来自之前的运行
- Sprint-003 自上次计划以来新增了 2 个故事

**输入：** `/qa-plan sprint-003`

**预期行为：**
1. Skill 读取 sprint-003.md 并检测到 2 个不在现有计划中的故事
2. Skill 报告："Existing QA plan found for sprint-003 — offering to update"
3. Skill 展示 2 个新故事及其建议的测试分配
4. Skill 询问 "May I update `production/qa/qa-plan-sprint-003.md`?"（非覆盖）
5. 批准后写入更新后的计划

**断言：**
- [ ] Skill 检测到现有计划文件
- [ ] 使用 "update" 语言（非 "overwrite"）
- [ ] 仅建议新增故事 — 现有条目被保留
- [ ] 判决为 COMPLETE

---

### 用例 4：冲刺中无故事 — 错误附引导

**Fixture：**
- `production/sprints/sprint-007.md` 不存在
- 没有匹配 sprint-007 的其他冲刺文件

**输入：** `/qa-plan sprint-007`

**预期行为：**
1. Skill 尝试读取 sprint-007.md — 文件未找到
2. Skill 输出："No sprint file found for sprint-007"
3. Skill 建议先运行 `/sprint-plan` 创建冲刺
4. 不写入计划；不询问 "May I write"

**断言：**
- [ ] 错误消息命名缺失的冲刺文件
- [ ] 建议 `/sprint-plan` 作为补救步骤
- [ ] 不调用写入工具
- [ ] 判决非 COMPLETE（错误状态）

---

### 用例 5：Director Gate 检查 — 无 gate；QA 计划是一个工具

**Fixture：**
- 包含有效故事和 AC 的冲刺

**输入：** `/qa-plan sprint-003`

**预期行为：**
1. Skill 生成并写入 QA 计划
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] Skill 在无任何 gate 检查的情况下达到 COMPLETE

---

## 协议合规性

- [ ] 在分配测试类型前读取 coding-standards.md 测试证据表
- [ ] 根据故事类型分配 BLOCKING 或 ADVISORY gate 级别
- [ ] 将无 AC 的故事标记为 UNTESTABLE（不静默跳过）
- [ ] 检测现有计划并提供更新路径
- [ ] 创建或更新计划文件前询问 "May I write"
- [ ] 计划写入后判决为 COMPLETE

---

## 覆盖说明

- `coding-standards.md` 缺失的情况（skill 无法分配测试类型）不进行 fixture 测试；行为会遵循 BLOCKED 模式，附恢复标准文件说明。
- 多冲刺计划（跨越 2 个冲刺）不测试；该 skill 设计为一次一个冲刺。
- 配置/数据故事类型（平衡调参 → 冒烟检查）遵循与用例 1 中其他类型相同的分配模式，不单独测试。
