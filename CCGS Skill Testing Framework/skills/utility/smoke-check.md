<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/smoke-check

## Skill 摘要

`/smoke-check` 是实现与 QA 交接之间的关卡。它检测测试环境，运行自动化测试套件（通过 Bash），根据冲刺故事扫描测试覆盖率，并使用 `AskUserQuestion` 让开发者批量验证手动冒烟检查。经过明确的用户批准后，将报告写入 `production/qa/smoke-[date].md`。

判决：PASS（测试通过，所有冒烟检查通过，无缺失的测试证据）、PASS WITH WARNINGS（测试通过或 NOT RUN，所有关键检查通过，但存在建议性差距，如缺失的测试覆盖率）或 FAIL（任何自动化测试失败或任何 Batch 1/Batch 2 冒烟检查返回 FAIL）。

不适用 director gate。该 skill 不会调用任何 director agent。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：PASS、PASS WITH WARNINGS、FAIL
- [ ] 在写入报告前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，FAIL 时使用 `/bug-report`，PASS 时给出 QA 交接引导）

---

## Director Gate 检查

无。`/smoke-check` 是一个预 QA 工具 skill。不适用 director gate。

---

## 测试用例

### 用例 1：Happy Path — 自动化测试通过，手动项确认，PASS

**Fixture：**
- `tests/` 目录存在，有 GDUnit4 运行脚本
- 从 `technical-preferences.md` 检测到引擎为 Godot
- `production/qa/qa-plan-sprint-005.md` 存在
- 自动化测试运行器报告 12 个测试，12 个通过，0 个失败
- 开发者确认所有 Batch 1 和 Batch 2 冒烟检查为 PASS
- 所有冲刺故事都有匹配的测试文件（无 MISSING 覆盖率）

**输入：** `/smoke-check`

**预期行为：**
1. Skill 检测测试目录和引擎，注明找到 QA 计划
2. 通过 Bash 运行 `godot --headless --script tests/gdunit4_runner.gd`
3. 解析输出：12/12 通过
4. 扫描测试覆盖率 — 所有故事 COVERED 或 EXPECTED
5. 使用 `AskUserQuestion` 进行 Batch 1（核心稳定性）和 Batch 2（冲刺机制）
6. 开发者对所有项选择 PASS
7. 汇编报告：自动化测试 PASS，所有冒烟检查 PASS，无 MISSING 覆盖率
8. 询问 "May I write this smoke check report to `production/qa/smoke-[date].md`?"
9. 批准后写入报告
10. 交付判决：PASS

**断言：**
- [ ] 通过 Bash 调用自动化测试运行器
- [ ] 对手动冒烟检查批次使用 `AskUserQuestion`
- [ ] 写入报告文件前询问 "May I write"
- [ ] 报告写入 `production/qa/smoke-[date].md`
- [ ] 判决为 PASS

---

### 用例 2：失败路径 — 自动化测试失败，FAIL 判决

**Fixture：**
- `tests/` 目录存在，引擎为 Godot
- 自动化测试运行器报告 10 个测试运行：8 个通过，2 个失败
  - 失败测试：`test_health_clamp_at_zero`、`test_damage_calculation_negative`
- QA 计划存在

**输入：** `/smoke-check`

**预期行为：**
1. Skill 通过 Bash 运行自动化测试
2. 解析输出 — 检测到 2 个失败
3. 记录失败测试名称
4. 继续进行手动冒烟检查批次
5. 报告显示自动化测试为 FAIL，列出失败测试名称
6. 请求写入报告；批准后写入
7. 交付 FAIL 判决，附消息："The smoke check failed. Do not hand off to QA until these failures are resolved." 列出失败测试并建议修复后重新运行 `/smoke-check`

**断言：**
- [ ] 报告中列出失败测试名称
- [ ] 判决为 FAIL
- [ ] 判决后消息指示开发者在 QA 交接前修复失败
- [ ] 建议修复后重新运行 `/smoke-check`

---

### 用例 3：手动确认 — 使用 AskUserQuestion，PASS WITH WARNINGS

**Fixture：**
- `tests/` 目录存在，引擎为 Godot
- 自动化测试运行器报告所有测试通过（8/8）
- 一个 Logic 故事没有匹配的测试文件（MISSING 覆盖率）
- 开发者确认所有 Batch 1 和 Batch 2 冒烟检查为 PASS

**输入：** `/smoke-check`

**预期行为：**
1. 自动化测试 PASS
2. 覆盖率扫描发现 1 个 Logic 故事的 MISSING 条目
3. 对 Batch 1 和 Batch 2 使用 `AskUserQuestion` — 开发者确认所有 PASS
4. 报告显示：自动化测试 PASS，手动检查全部 PASS，1 个 MISSING 覆盖条目
5. 判决为 PASS WITH WARNINGS — 构建可交付 QA，但 MISSING 条目必须在 `/story-done` 关闭受影响故事前解决
6. 请求写入报告；批准后写入

**断言：**
- [ ] 对手动冒烟检查批次使用 `AskUserQuestion`（非内联文本提示）
- [ ] 报告中出现 MISSING 测试覆盖条目
- [ ] 判决为 PASS WITH WARNINGS（非 PASS，非 FAIL）
- [ ] 建议说明解释 MISSING 条目必须在 `/story-done` 前解决
- [ ] 报告文件写入 `production/qa/smoke-[date].md`

---

### 用例 4：无测试目录 — Skill 停止并引导

**Fixture：**
- `tests/` 目录不存在
- 引擎配置为 Godot

**输入：** `/smoke-check`

**预期行为：**
1. 阶段 1 检查 `tests/` 目录 — 未找到
2. Skill 输出："No test directory found at `tests/`. Run `/test-setup` to scaffold the testing infrastructure, or create the directory manually if tests live elsewhere."
3. Skill 停止 — 不运行自动化测试，不进行手动冒烟检查，不写入报告

**断言：**
- [ ] 错误消息引用缺失的 `tests/` 目录
- [ ] 建议 `/test-setup` 作为补救步骤
- [ ] Skill 在此消息后停止（不运行后续阶段）
- [ ] 不写入报告文件

---

### 用例 5：Director Gate 检查 — 无 gate；smoke-check 是一个 QA 预检工具

**Fixture：**
- 有效的测试设置，自动化测试通过，手动冒烟检查已确认

**输入：** `/smoke-check`

**预期行为：**
1. Skill 运行所有阶段并生成 PASS 或 PASS WITH WARNINGS 判决
2. 在任何时候都不生成 director agent
3. 输出中不出现 gate ID（CD-*、TD-*、AD-*、PR-*）
4. 不调用 `/gate-check`

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 PASS、PASS WITH WARNINGS 或 FAIL — 不涉及 gate 判决

---

## 协议合规性

- [ ] 对所有手动冒烟检查批次（Batch 1、Batch 2、Batch 3）使用 `AskUserQuestion`
- [ ] 在询问任何手动问题之前通过 Bash 运行自动化测试
- [ ] 在创建报告文件前询问 "May I write" — 从未在无批准的情况下写入
- [ ] 判决词汇严格为 PASS / PASS WITH WARNINGS / FAIL — 无其他判决
- [ ] FAIL 由自动化测试失败或 Batch 1/Batch 2 FAIL 响应触发
- [ ] PASS WITH WARNINGS 当存在 MISSING 测试覆盖率但无关键失败时触发
- [ ] NOT RUN（引擎二进制不可用）记录为警告，非 FAIL
- [ ] 任何时候都不调用 director gate

---

## 覆盖说明

- `quick` 参数（跳过阶段 3 覆盖率扫描和 Batch 3）不单独 fixture 测试；它遵循与用例 1 相同的模式，输出中有覆盖率跳过说明。
- `--platform` 参数添加平台特定的 AskUserQuestion 批次和每个平台的判决表；此处不单独测试。
- 引擎二进制不在 PATH 上的情况（NOT RUN）遵循 PASS WITH WARNINGS 模式，由上述协议合规性断言覆盖。
