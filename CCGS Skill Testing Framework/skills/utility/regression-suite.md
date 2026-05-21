<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/regression-suite

## Skill 摘要

`/regression-suite` 将测试覆盖率映射到 GDD 需求：它从当前冲刺（或指定的 epic）的故事文件中读取验收标准，然后扫描 `tests/` 中对应的测试文件，并检查每个 AC 是否有匹配的断言。它生成覆盖率报告，识别哪些 AC 被完全覆盖、部分覆盖或未测试，以及哪些测试文件没有匹配的 AC（孤儿测试）。

该 skill 可在 "May I write" 询问后将覆盖率报告写入 `production/qa/`。不适用 director gate。判决：FULL COVERAGE（所有 AC 都有测试）、GAPS FOUND（某些 AC 未测试）或 CRITICAL GAPS（关键优先级 AC 无测试）。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：FULL COVERAGE、GAPS FOUND、CRITICAL GAPS
- [ ] 包含 "May I write" 语言（skill 可写入覆盖率报告）
- [ ] 有下一步交接（例如，`/test-setup` 如果缺少框架，`/qa-plan` 如果缺少计划）

---

## Director Gate 检查

无。`/regression-suite` 是一个 QA 分析工具。不适用 director gate。

---

## 测试用例

### 用例 1：完全覆盖 — 冲刺中所有 AC 都有对应测试

**Fixture：**
- `production/sprints/sprint-004.md` 列出 3 个故事，每个有 2 个 AC（共 6 个）
- `tests/unit/` 和 `tests/integration/` 包含匹配全部 6 个 AC 的测试文件（按系统名称和场景描述）

**输入：** `/regression-suite sprint-004`

**预期行为：**
1. Skill 从 sprint-004 故事中读取全部 6 个 AC
2. Skill 扫描测试文件并将每个 AC 至少匹配一个测试断言
3. 全部 6 个 AC 都有覆盖率
4. Skill 生成覆盖率报告："6/6 ACs covered"
5. Skill 询问 "May I write to `production/qa/regression-sprint-004.md`?"
6. 批准后写入文件；判决为 FULL COVERAGE

**断言：**
- [ ] 覆盖率报告中包含全部 6 个 AC
- [ ] 每个 AC 标记为已覆盖，并引用匹配的测试文件
- [ ] 判决为 FULL COVERAGE
- [ ] 写入报告前询问 "May I write"

---

### 用例 2：发现差距 — 3 个 AC 无测试

**Fixture：**
- 冲刺有 5 个故事，共 8 个 AC
- 8 个 AC 中有 5 个有测试；3 个 AC 无对应的测试文件或断言

**输入：** `/regression-suite`

**预期行为：**
1. Skill 读取全部 8 个 AC
2. Skill 扫描测试 — 5 个匹配，3 个不匹配
3. 覆盖率报告按故事和 AC 文字列出 3 个未测试的 AC
4. Skill 询问 "May I write to `production/qa/regression-[sprint]-[date].md`?"
5. 写入报告；判决为 GAPS FOUND

**断言：**
- [ ] 报告中按名称列出 3 个未测试的 AC
- [ ] 匹配的 AC 也被显示（不仅显示差距）
- [ ] 判决为 GAPS FOUND（非 FULL COVERAGE）
- [ ] 经 "May I write" 批准后写入报告

---

### 用例 3：关键 AC 未测试 — CRITICAL GAPS 判决，显著标记

**Fixture：**
- 冲刺有 4 个故事；一个故事 Priority: Critical 有 2 个 AC
- 其中一个关键优先级 AC 无测试

**输入：** `/regression-suite`

**预期行为：**
1. Skill 读取所有故事和 AC，注意哪些故事是关键优先级
2. Skill 扫描测试 — 关键 AC 没有匹配
3. 报告显著标记："CRITICAL GAP: [AC text] — no test found (Critical priority story)"
4. Skill 建议在添加测试前阻塞故事完成
5. 判决为 CRITICAL GAPS

**断言：**
- [ ] 判决为 CRITICAL GAPS（非 GAPS FOUND）
- [ ] 关键优先级 AC 比普通差距更显著地标记
- [ ] 包含阻塞故事完成的建议
- [ ] 非关键差距（如有）也被列出

---

### 用例 4：孤儿测试 — 测试文件无匹配的 AC

**Fixture：**
- `tests/unit/save_system_test.gd` 存在，包含当前任何故事的 AC 列表中均不存在的场景断言
- 当前冲刺故事不引用存档系统

**输入：** `/regression-suite`

**预期行为：**
1. Skill 扫描测试并交叉引用 AC
2. `save_system_test.gd` 断言不匹配任何当前 AC
3. 测试文件在覆盖率报告中标记为 ORPHAN TEST
4. 报告注明："Orphan tests may belong to a past or future sprint, or AC was renamed"
5. 判决为 FULL COVERAGE 或 GAPS FOUND（取决于总体 AC 覆盖率）（孤儿测试不影响判决，它们是建议性的）

**断言：**
- [ ] 报告中标记孤儿测试
- [ ] 孤儿标记包含文件名和建议（过去的冲刺 / 重命名的 AC）
- [ ] 孤儿测试本身不会导致 GAPS FOUND 判决
- [ ] 总体判决仅反映 AC 覆盖率

---

### 用例 5：Director Gate 检查 — 无 gate；regression-suite 是一个 QA 工具

**Fixture：**
- 包含故事和测试文件的冲刺

**输入：** `/regression-suite`

**预期行为：**
1. Skill 生成覆盖率报告并写入
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 FULL COVERAGE、GAPS FOUND 或 CRITICAL GAPS — 无 gate 判决

---

## 协议合规性

- [ ] 在扫描测试之前从冲刺文件中读取故事 AC
- [ ] 按系统名称和场景（而不仅是文件名）匹配 AC 与测试
- [ ] 将关键优先级未测试 AC 标记为 CRITICAL GAPS
- [ ] 标记孤儿测试（存在于 tests/ 中但无 AC 匹配）
- [ ] 持久化覆盖率报告前询问 "May I write"
- [ ] 判决为 FULL COVERAGE、GAPS FOUND 或 CRITICAL GAPS

---

## 覆盖说明

- AC 与测试匹配的启发式方法（按系统名称 + 场景关键词）是近似值；精确匹配逻辑在 skill 正文中定义。
- 集成测试覆盖率与单元测试覆盖率映射方式相同；两者之间判决无区别。
- 此 skill 不运行测试——它将 AC 文本映射到测试断言。测试执行由 CI 流水线处理。
