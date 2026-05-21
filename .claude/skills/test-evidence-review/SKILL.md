---
name: test-evidence-review
description: "从测试结果文件生成测试证据摘要。解析测试 XML、提取通过率和覆盖报告，并与 CI 日志交叉引用以识别不一致处。提供结构化摘要，不修改原始文件，不重复已存在的 CI 总结。"
argument-hint: "[--format xml|json|txt|auto] [--tolerance <N>] [--output <dir>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: haiku
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 测试证据审查

解析自动化测试结果并产出证据摘要。这是一个只读整理器——它读取现有的测试输出文件并创建结构化摘要，不修改或运行测试。

**何时使用此 Skill：**
- 代码管道输出 JUnit XML、NUnit XML 或其他结构化测试结果，你想从中提取可操作的摘要
- CI 返回的日志未预先结构化为摘要表
- 手动测试（类型为 Visual/UI）需要记录以供签收
- `/smoke-check` 已将自动化测试报告为 NOT RUN，你需要生成证据材料
- 多个运行需要交叉引用以发现模式

**在以下情况使用其他 Skill：**
- **运行**测试套件 → 使用 `/smoke-check`（运行自动化套件 + 手动冒烟验证）
- 诊断**不稳定**测试 → 使用 `/test-flakiness`（检测间歇性失败及其根本原因）
- **编写**新的测试 → 使用 `/dev-story`（实现逻辑故事时编写测试）
- 从空白状态**搭建**测试基础设施 → 使用 `/test-setup`（从头创建测试目录结构、框架和辅助函数）

**输出**：`production/qa/test-evidence-[date]-[scope].md` 或 `tests/evidence/tests-[story-slug].md`

---

## 1. 参数

- `--format xml|json|txt|auto` — 预期格式。默认：`auto`。
- `--tolerance N` — 将不超过 N 个失败测试视为通过（默认：0）。
- `--output <dir>` — 写入摘要的备选目录。
- `--scope sprint|story` — 结果是否针对整个冲刺或单个故事（用于文件命名）。
- 未提供其他参数时运行 `auto`。

---

## 2. 自动检测

1. **检查 QA 计划**：Glob `production/qa/qa-plan-sprint-[N].md`（最近修改的在最后）。提取：冲刺编号、计划中每个故事的项目符号用例以及任何边缘情况列表。*如果未找到 QA 计划：继续而不包括 QA 对比。*
2. **扫描源文件**：Glob `test-results/`、`tests/evidence/`、`Saved/Logs/` 获取最新的结构化测试输出。
3. **检查配置框架**（来自 `/smoke-check` 或目录结构）以确定解析策略。
4. 如果任何地方都未找到测试结果文件，停止并提示用户提供日志路径或首先运行测试。

在继续读取任何日志之前报告已找到的文件清单。

---

## 3. 解析

读取每个测试结果文件并根据检测到的格式提取：

### JUnit XML（GdUnit4、Unity Test Framework、大多数 CI 运行器）
- 每个 `<testsuite>` 节点 → 测试组
- 每个 `<testcase>` → 测试名称、类名、时间
- 带有 `<failure>` 或 `<error>` 子节点的 `<testcase>` → 失败的测试
- 提取 `message` 属性以获取失败原因

### 自定义 Godot GdUnit4 格式
- Grep 模式 `✅` 和 `❌`
- 失败测试通常具有结构：`❌ [test_name]`
- 如果可用，还会输出到 `test-results/gdunit4_report.xml`

### Unity Test Framework 文本日志
- Grep `Passed:` 和 `Failed:` 行
- 测试名称模式：`TestName (X.XXXs)`

### Unreal Automation 日志
- Grep `LogAutomationController: Test Started. Name=` 以获取测试名称
- Grep `LogAutomationController: Test Completed. Result=` 以获取通过/失败
- 失败有 `Errors=` 和 `Warnings=` 计数器

### 自定义 JSON（如果检测到）
- 按预期模式映射到标准化的内部格式

---

## 4. 与 QA 计划交叉引用（如果存在 QA 计划）

对于 QA 计划中按故事组织的每个测试用例：
1. 检测此用例是否有测试结果
2. 如果不存在自动测试结果：输出 `MANUAL` — 需要人工 QA
3. 如果存在测试结果：匹配通过计数/失败状态并与 QA 用例对齐

输出每个故事的覆盖率表（与 QA 计划中的格式匹配）。

---

## 5. 生成摘要

### 对话内摘要

```
## 测试证据摘要
日期：[date]
源文件：     [number] 个文件
测试运行：   [number] 次运行
通过测试：   [number]（[pass-rate]%）
失败测试：   [number]（[failure-rate]%）
不稳定测试： [zero if never run, otherwise as computed]
QA 计划匹配：  [number] 个匹配，[number] 个仅 MANUAL，[number] 个未找到
```

### Markdown 证据文件（写入时）

对通过/失败表使用 `test-evidence-template.md` 模板，并根据已解析的测试输出中的实际列调整列。包括：

- **每次运行的各题组通过率**
- **失败详情** 带有测试名称和失败原因（最多 10 行）
- **QA 计划覆盖交叉引用**（如果有 QA 计划可用）
- **汇总通过率** 与 Sprint "完成定义"阈值进行对比
- **关键提醒**（例如没有任何测试结果的故事需标记为手动 QA 或视为不合格）

---

## 6. 写入

仅在用户批准后写入。如果 QA 计划存在且已解析，则在摘要文件中包含 QA 验证部分；如果不存在，则省略该部分。

- 如果 `--scope sprint`：写入 `production/qa/test-evidence-[date]-sprint[N].md`
- 如果 `--scope story`：写入 `tests/evidence/tests-[story-slug].md` 并更新 `sprint-status.yaml` 中的故事状态或故事文件的 frontmatter（与 `/story-done` 使用的相同 slug）
- 如果无 `--scope` 参数：写入 `production/qa/test-evidence-[date].md`

---

## 协作协议

- 此 Skill 为**只读解析器** — 不运行测试，不修改测试文件。仅读取结果并摘要化。
- **绝不重复**已经在对话或 CI 输出中可见的原始日志内容。仅生成摘要，使审查者可操作。
- 除了 QA 计划交叉引用外，不要添加在已解析的测试输出中找不到的测试引用。
