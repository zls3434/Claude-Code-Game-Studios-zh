<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/skill-improve

## Skill 摘要

`/skill-improve` 分析来自 `/skill-test dynamic` 运行或手动审查的测试结果，以生成系统化的 skill 改进建议。它识别失败的测试、不合规的协议行为以及缺失的所需输出 section，然后将改进按优先级排序为三个类别：修复（必须解决阻塞性失败）、增强（添加缺失的功能或协议步骤）、重构（改善模糊语言或 stage 定义）。

该 skill 在经过 "May I write" 询问后将改进报告写入 `.claude/skills/improvement-log/[skill-name]-[date].md`。如果同一 skill 的先前改进日志存在，它会在建议中引用历史记录。有两个 director gate — CD-DOC（标记功能文档差距）和 PR-POLISH（标记时间线风险），这两个均在报告写入前以 ADVISORY 级别运行。判决始终为 REPORT COMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：REPORT COMPLETE
- [ ] 包含 "May I write" 语言（用于改进日志文件）
- [ ] 有下一步交接（例如，`/skill-test dynamic` 重新验证）

---

## Director Gate 检查

在 `full` 模式下：CD-DOC 和 PR-POLISH 均在报告生成后、写入前以 ADVISORY 级别运行。在 `lean` 模式下：两个 gate 均被跳过（"CD-DOC skipped — lean mode"、"PR-POLISH skipped — lean mode"）。在 `solo` 模式下：两个 gate 均被跳过。

CD-DOC 和 PR-POLISH 均为 ADVISORY — 它们从不阻塞报告写入。其担忧在报告中注明供人工审查。

---

## 测试用例

### 用例 1：Happy Path — Full 模式，测试结果分析，建议已生成并写入

**Fixture：**
- `production/session-state/review-mode.txt` 包含 `full`
- 已提供 `/skill-test dynamic` 测试运行的测试结果
- 结果：1 个 FAIL（缺失阶段输出），2 个 PASS

**输入：** `/skill-improve my-skill-name`

**预期行为：**
1. Skill 分析测试结果中的 1 个 FAIL
2. 识别缺失的阶段输出 → 分类为修复："Add stage output [X] before stage [Y]"
3. 识别 2 个 PASS 测试 — 无需修复
4. 为剩余的协议不合规性生成增强和重构建议
5. CD-DOC 和 PR-POLISH gate 均以 ADVISORY 级别运行
6. Skill 询问 "May I write to `.claude/skills/improvement-log/my-skill-name-2026-04-06.md`?"
7. 报告写入；判决为 REPORT COMPLETE

**断言：**
- [ ] 失败被分类为修复，附解决方案建议
- [ ] 两个 director gate 以 ADVISORY 级别运行
- [ ] 报告以三类改进结构化：修复、增强、重构
- [ ] "May I write" 以正确的文件路径询问
- [ ] 判决为 REPORT COMPLETE

---

### 用例 2：Lean 模式 — 两个 gate 均被跳过

**Fixture：**
- 测试结果已提供
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/skill-improve my-skill-name`

**预期行为：**
1. Skill 分析测试结果
2. 两个 director gate 均被跳过："CD-DOC skipped — lean mode"、"PR-POLISH skipped — lean mode"
3. 报告以 gate 建议部分缺失写入
4. 判决为 REPORT COMPLETE

**断言：**
- [ ] 输出中出现两个 gate 跳过消息
- [ ] 报告写入时包含改进建议（无 gate 输入）
- [ ] 判决为 REPORT COMPLETE

---

### 用例 3：先前改进日志存在 — 引用历史改进

**Fixture：**
- `.claude/skills/improvement-log/my-skill-name-2026-03-01.md` 存在，包含先前的改进建议："Fix: Added missing May I write stage"
- 新测试结果包含不同的失败

**输入：** `/skill-improve my-skill-name`

**预期行为：**
1. Skill 找到并加载先前改进日志
2. Skill 检查先前的修复是否已应用（现在 "May I write" 测试 PASS）
3. 先前修复被注明为 "Previously resolved — no longer flagged"
4. 新失败与先前历史分开记录
5. 报告中包含带日期的历史引用

**断言：**
- [ ] 先前改进日志被引用（带日期和修复）
- [ ] 先前修复被注明为已解决
- [ ] 新问题与历史问题分开列出
- [ ] 判决为 REPORT COMPLETE

---

### 用例 4：CD-DOC 返回 CONCERNS — 在报告中注明，非阻塞

**Fixture：**
- Full 模式
- CD-DOC gate 返回 CONCERNS："Skill is missing 'Next Steps Handoff' that describes how output integrates into the pipeline"

**输入：** `/skill-improve my-skill-name`

**预期行为：**
1. CD-DOC 以 CONCERNS 返回
2. Skill 将担忧记录在报告中："CD-DOC flagged: Missing 'Next Steps Handoff' section"
3. 报告仍然写入 — CD-DOC 仅为 ADVISORY，即使有 CONCERNS 也不阻塞
4. 判决为 REPORT COMPLETE

**断言：**
- [ ] CD-DOC 担忧被记录（非阻塞报告写入）
- [ ] 报告写入带有担忧注释
- [ ] 判决为 REPORT COMPLETE
- [ ] 用户知晓担忧但不被强制处理

---

### 用例 5：Director Gate — 两个 ADVISORY gate 均并行运行

**Fixture：**
- Full 模式，测试结果已提供

**输入：** `/skill-improve my-skill-name`

**预期行为：**
1. Skill 分析测试结果
2. CD-DOC 和 PR-POLISH 并行生成（非顺序）
3. Skill 等待两个 gate 完成
4. 两个 gate 的担忧（如有）均记录在报告中
5. 要写入的内容中不出现 gate ID
6. 判决为 REPORT COMPLETE

**断言：**
- [ ] 两个 gate 并行运行（非一个接一个）
- [ ] Skill 在写入报告前等待两个 gate
- [ ] 任何 gate 担忧均出现在报告中
- [ ] gate 不阻碍报告写入
- [ ] 最终输出中不出现 gate ID

---

## 协议合规性

- [ ] 将 failures-and-gaps 测试输入分类为三类：修复、增强、重构
- [ ] 如有先前改进日志，加载并引用
- [ ] 以 ADVISORY 级别运行 CD-DOC 和 PR-POLISH gate（full 模式）
- [ ] 在 lean 和 solo 模式下跳过 gate
- [ ] 写入改进报告前询问 "May I write"
- [ ] 判决始终为 REPORT COMPLETE（不阻塞）

---

## 覆盖说明

- Solo 模式（两个 gate 均跳过）遵循与 lean 模式相同的模式，使用 "solo mode" 标签；不单独 fixture 测试。
- `final-report` 参数将建议范围限制为最终摘要生成；它更改输出模式但不更改 gate 逻辑，此处不测试。
- 改进建议的精确格式是建议性的 — skill 生成分类项目符号列表，而非结构化机器可读输出。
