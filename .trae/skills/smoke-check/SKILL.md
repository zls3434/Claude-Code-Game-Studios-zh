---
name: smoke-check
description: "在 QA 移交前运行关键路径冒烟测试关卡。执行自动化测试套件，验证核心功能，并生成 PASS/FAIL 报告。在 Sprint 的故事实现完成后、手动 QA 开始前运行。冒烟检查失败意味着构建版本未准备好进入 QA。"
argument-hint: "[sprint | quick | --platform pc|console|mobile|all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, AskUserQuestion
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 冒烟检查

此 Skill 是"实现完成"和"准备移交 QA"之间的关卡。它运行自动化测试套件，检查测试覆盖缺口，与开发者批量验证关键路径，并生成 PASS/FAIL 报告。

规则很简单：**冒烟检查失败的构建版本不能进入 QA。** 将有问题的构建版本交给 QA 会浪费他们的时间并打击团队士气。

**输出：** `production/qa/smoke-[date].md`

---

## 解析参数

参数可以组合：`/smoke-check sprint --platform console`

**基础模式**（第一个参数，默认：`sprint`）：
- `sprint` — 针对当前 Sprint 故事的完整冒烟检查
- `quick` — 跳过覆盖扫描（第 3 阶段）和 Batch 3；用于快速重新检查

**平台标志**（`--platform`，默认：无）：
- `--platform pc` — 添加 PC 特定检查（键盘、鼠标、窗口模式）
- `--platform console` — 添加主机特定检查（手柄、电视安全区、平台认证要求）
- `--platform mobile` — 添加移动端特定检查（触摸、竖屏/横屏、电池/热行为）
- `--platform all` — 添加所有平台变体；输出各平台判定表

如果提供了 `--platform`，第 4 阶段添加特定平台的批次，第 5 阶段在总体判定之外输出各平台判定表。

---

## 第 1 阶段：检测测试设置

在运行任何东西之前，了解环境：

1. **测试框架检查**：验证 `tests/` 目录是否存在。如果不存在："在 `tests/` 未找到测试目录。运行 `/test-setup` 搭建测试基础设施，或者如果测试在其他位置则手动创建目录。"然后停止。

2. **CI 检查**：检查 `.github/workflows/` 是否包含引用测试的工作流文件。在报告中注明 CI 是否已配置。

3. **引擎检测**：读取 `.claude/docs/technical-preferences.md` 并提取 `Engine:` 值。存储此值以供第 2 阶段的测试命令选择。

4. **冒烟测试列表**：检查 `production/qa/smoke-tests.md` 或 `tests/smoke/` 是否存在。如果找到冒烟测试列表，加载它以供第 4 阶段使用。如果两者都不存在，冒烟测试将从当前 QA 计划中提取（第 4 阶段回退）。

5. **QA 计划检查**：glob `production/qa/qa-plan-*.md` 并取最近修改的文件。如果找到，记录路径 — 它将在第 3 阶段和第 4 阶段使用。如果未找到，记录："未找到 QA 计划。在冒烟检查之前运行 `/qa-plan sprint` 以获得最佳结果。"

在继续之前报告发现："环境：[引擎]。测试目录：[找到 / 未找到]。CI 已配置：[是 / 否]。QA 计划：[路径 / 未找到]。"

---

## 第 2 阶段：运行自动化测试

尝试通过 Bash 运行测试套件。根据第 1 阶段检测到的引擎选择命令：

**Godot 4：**
```bash
godot --headless --script tests/gdunit4_runner.gd 2>&1
```
如果 GDUnit4 运行器脚本不在该路径，尝试：
```bash
godot --headless -s addons/gdunit4/GdUnitRunner.gd 2>&1
```
如果两个路径都不存在，记录："GDUnit4 运行器未找到 — 确认测试框架的运行器路径。"

**Unity：**
Unity 测试需要编辑器，在大多数环境中无法通过 shell 无头运行。检查最近的测试结果产物：
```bash
# 列出最近的测试结果（bash）— 在 Windows PowerShell 中使用下面的回退方案
ls -t test-results/ 2>/dev/null | head -5 \
  || powershell -Command "Get-ChildItem test-results/ -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 5 -ExpandProperty Name"
```
如果测试结果文件存在（XML 或 JSON），读取最近的一个并解析 PASS/FAIL 计数。如果没有产物："Unity 测试必须从编辑器或 CI 流水线运行。在继续之前请手动确认测试状态。"

**Unreal Engine：**
```bash
# 列出最近的 Unreal 自动化日志（bash）— 在 Windows PowerShell 中使用下面的回退方案
ls -t Saved/Logs/ 2>/dev/null | grep -i "test\|automation" | head -5 \
  || powershell -Command "Get-ChildItem Saved/Logs/ -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'test|automation' } | Sort-Object LastWriteTime -Descending | Select-Object -First 5 -ExpandProperty Name"
```
如果未找到匹配的日志："UE 自动化测试必须通过 Session Frontend 或 CI 流水线运行。请手动确认测试状态。"

**未知引擎 / 未配置：**
"引擎未在 `.claude/docs/technical-preferences.md` 中配置。运行 `/setup-engine` 指定引擎，然后重新运行 `/smoke-check`。"

**如果测试运行器在此环境中不可用**（引擎二进制文件不在 PATH 上，运行器脚本未找到等），明确报告：

"自动化测试无法执行 — 引擎二进制文件未在 PATH 上找到。状态将记录为 NOT RUN。请从你的本地 IDE 或 CI 流水线确认测试结果。未确认的 NOT RUN 视为 PASS WITH WARNINGS，而非 FAIL — 开发者必须手动确认结果。"

不要将 NOT RUN 视为自动 FAIL。将其记录为警告。开发者在第 4 阶段的手动确认可以解决它。

解析运行器输出并提取：
- 运行的测试总数
- 通过数
- 失败数
- 失败测试的名称（最多 10 个；如果更多，记录数量）
- 运行器本身的任何崩溃或错误输出

---

## 第 3 阶段：检查测试覆盖

按以下优先级顺序提取故事列表：
1. 第 1 阶段找到的 QA 计划（其 Test Summary 表列出了每个故事的预期测试文件路径）
2. 来自 `production/sprints/` 的当前 Sprint 计划（最近修改的文件）
3. 如果传入了 `quick` 参数，完全跳过此阶段并注明："覆盖扫描已跳过 — 运行 `/smoke-check sprint` 进行完整覆盖分析。"

对于范围内的每个故事：

1. 从故事的文件路径中提取系统 slug（例如，`production/epics/combat/story-001.md` → `combat`）
2. Glob `tests/unit/[system]/` 和 `tests/integration/[system]/` 以查找名称包含故事 slug 或密切相关术语的文件
3. 检查故事文件本身是否有 `Test file:` 头部字段或"Test Evidence"部分

为每个故事分配覆盖状态：

| 状态 | 含义 |
|--------|---------|
| **COVERED** | 找到与此故事系统和范围匹配的测试文件 |
| **MANUAL** | 故事类型为 Visual/Feel 或 UI；找到测试证据文档 |
| **MISSING** | Logic 或 Integration 故事，没有匹配的测试文件 |
| **EXPECTED** | Config/Data 故事 — 不需要测试文件；抽查即可 |
| **UNKNOWN** | 故事文件缺失或不可读 |

MISSING 条目是建议性缺口。它们不会导致 FAIL 判定，但必须显著地显示在报告中，并且必须在 `/story-done` 完全关闭这些故事之前解决。

---

## 第 4 阶段：运行手动冒烟检查

按以下优先级顺序提取冒烟测试清单：
1. QA 计划的"Smoke Test Scope"部分（如果在第 1 阶段找到 QA 计划）
2. `production/qa/smoke-tests.md`（如果存在）
3. `tests/smoke/` 目录内容（如果存在）
4. 以下标准回退列表（仅当以上都不存在时使用）

将批次 2 和 3 调整为从 Sprint 或 QA 计划中识别出的实际系统。将括号占位符替换为当前 Sprint 故事中的真实机制名称。

使用 `AskUserQuestion` 进行批量验证。最多保持 3 次调用。

**Batch 1 — 核心稳定性（始终运行）：**
```
question: "核心稳定性 — 选择任何 FAILED 的项（如果全部通过则不选择）："
multiSelect: true
options:
  - "游戏无法启动或在到达主菜单前崩溃"
  - "新游戏 / 会话无法开始"
  - "主菜单不响应输入"
  - "基础导航期间观察到崩溃或卡死"
```

对于任何选中的项，在生成报告之前询问用户简要描述失败情况。

**Batch 2 — Sprint 变更和回归（始终运行）：**
```
question: "Sprint 变更和回归 — 选择任何 FAILED 的项（如果全部通过则不选择）："
multiSelect: true
options:
  - "[本 Sprint 主要机制] — FAILED"
  - "[本 Sprint 第二个显著变更（如有）] — FAILED"
  - "之前 Sprint 的功能出现回归 — FAILED"
  - "观察到其他意外的破坏 — FAILED"
```

对于任何选中的项，在生成报告之前询问用户简要描述损坏情况。

**Batch 3 — 数据完整性和性能（除非 `quick` 参数则运行）：**
```
question: "数据完整性和性能 — 选择任何 FAILED 或跳过的项（如果全部通过则不选择）："
multiSelect: true
options:
  - "保存 / 加载 — FAILED（观察到数据丢失或损坏）"
  - "保存 / 加载 — N/A（存档系统尚未实现）"
  - "观察到帧率下降或卡顿 — FAILED"
  - "本次会话未检查性能"
```

对于任何选中的 FAILED 项，在生成报告之前询问用户描述损坏情况。

在报告中逐字记录每个响应。

**平台批次** *（仅当提供了 `--platform` 参数时运行）*：

**PC 平台**（`--platform pc` 或 `--platform all`）：
```
question: "PC 平台 — 选择任何 FAILED 的项（如果全部通过则不选择）："
multiSelect: true
options:
  - "键盘控制 — FAILED（之后描述问题）"
  - "鼠标输入或光标可见性 — FAILED（之后描述问题）"
  - "窗口 / 全屏模式 — FAILED（之后描述问题）"
  - "分辨率更改 — FAILED（之后描述问题）"
```

**主机平台**（`--platform console` 或 `--platform all`）：
```
question: "主机平台 — 选择任何 FAILED 的项（如果全部通过则不选择）："
multiSelect: true
options:
  - "手柄输入 — FAILED（之后描述问题）"
  - "UI 超出电视安全区 / 文字被裁剪 — FAILED（之后描述被裁剪的内容）"
  - "手柄用户看到键鼠回退提示 — FAILED（之后描述）"
  - "冷启动（无先前存档）— FAILED（之后描述问题）"
```

**移动端平台**（`--platform mobile` 或 `--platform all`）：
```
question: "移动端平台 — 选择任何 FAILED 的项（如果全部通过则不选择）："
multiSelect: true
options:
  - "触摸控制 — FAILED（之后描述问题）"
  - "方向切换（竖屏 ↔ 横屏）— FAILED（之后描述损坏情况）"
  - "后台 / 前台转换（主页按钮）— FAILED（之后描述问题）"
  - "目标设备上的性能 / 热降频 — FAILED（之后描述）"
```

---

## 第 5 阶段：生成报告

组装完整的冒烟检查报告：

````markdown
## 冒烟检查报告
**日期**：[日期]
**Sprint**：[Sprint 名称/编号，或"未识别"]
**引擎**：[引擎]
**QA 计划**：[路径，或"未找到 — 先运行 /qa-plan"]
**参数**：[sprint | quick | 空白]

---

### 自动化测试

**状态**：[PASS（[N] 个测试，[N] 个通过）| FAIL（[N] 个失败）| NOT RUN（[原因]）]

[如果 FAIL，列出失败的测试：]
- `[测试名称]` — [来自运行器输出的简要失败描述]

[如果 NOT RUN：]
"需要手动确认：测试在你的本地 IDE 或 CI 中通过了吗？这将决定自动化测试行是否计入 FAIL 判定。"

---

### 测试覆盖

| 故事 | 类型 | 测试文件 | 覆盖状态 |
|-------|------|-----------|----------------|
| [标题] | Logic | `tests/unit/[system]/[slug]_test.[ext]` | COVERED |
| [标题] | Visual/Feel | `tests/evidence/[slug]-screenshots.md` | MANUAL |
| [标题] | Logic | — | MISSING ⚠ |
| [标题] | Config/Data | — | EXPECTED |

**摘要**：[N] 个已覆盖，[N] 个手动，[N] 个缺失，[N] 个预期。

---

### 手动冒烟检查

- [x] 游戏启动无崩溃 — PASS
- [x] 新游戏启动 — PASS
- [x] [核心机制] — PASS
- [ ] [其他检查] — FAIL：[用户描述]
- [x] 保存 / 加载 — PASS
- [-] 性能 — 本次会话未检查

---

### 缺失测试证据

必须通过 `/story-done` 标记为 COMPLETE 之前拥有测试证据的故事：

- **[故事标题]**（`[路径]`）— 逻辑故事没有测试文件。预期位置：`tests/unit/[system]/[story-slug]_test.[ext]`

[如果无：]"所有 Logic 和 Integration 故事均有测试覆盖。"

---

### 平台特定结果 *（仅当提供了 `--platform` 时）*

| 平台 | 检查数 | 通过 | 失败 | 平台判定 |
|----------|-----------|--------|--------|-----------------|
| PC | [N] | [N] | [N] | PASS / FAIL |
| Console | [N] | [N] | [N] | PASS / FAIL |
| Mobile | [N] | [N] | [N] | PASS / FAIL |

**平台备注**：[pass/fail 中未捕获的任何平台特定观察]

任何有一个或多个 FAIL 检查的平台都会计入总体 FAIL 判定。

---

### 判定：[PASS | PASS WITH WARNINGS | FAIL]

[判定规则 — 第一个匹配的规则生效：]

**FAIL** 如果以下任一：
- 自动化测试套件运行并报告一个或多个测试失败
- 任何 Batch 1（核心稳定性）检查返回 FAIL
- 任何 Batch 2（主要 Sprint 机制或回归检查）返回 FAIL

**PASS WITH WARNINGS** 如果以下全部：
- 自动化测试 PASS 或 NOT RUN（开发者尚未确认）
- 所有 Batch 1 和 Batch 2 冒烟检查 PASS
- 一个或多个 Logic/Integration 故事存在 MISSING 测试证据

**PASS** 如果以下全部：
- 自动化测试 PASS
- 所有批次的所有冒烟检查 PASS 或 N/A
- 无 MISSING 测试证据条目
````

---

## 第 6 阶段：写入和关卡判定

在对话中呈现完整报告，然后询问：

"我可以将此冒烟检查报告写入 `production/qa/smoke-[date].md` 吗？"

仅在获得批准后写入。

写入后，交付关卡判定：

**如果判定是 FAIL：**

"冒烟检查失败。在解决以下失败之前不要移交给 QA：

[列出每个失败的自动化测试或冒烟检查及一行描述]

修复失败项并再次运行 `/smoke-check` 以在 QA 移交前重新验证。"

**如果判定是 PASS WITH WARNINGS：**

"冒烟检查以警告通过。构建版本可以进行手动 QA。

在受影响的故事上运行 `/story-done` 之前需要解决的建议项：
[列出 MISSING 测试证据条目]

QA 移交：与 qa-tester Agent 共享 `production/qa/qa-plan-[sprint].md` 以开始手动验证。"

**如果判定是 PASS：**

"冒烟检查干净通过。构建版本可以进行手动 QA。

QA 移交：与 qa-tester Agent 共享 `production/qa/qa-plan-[sprint].md` 以开始手动验证。"

---

## 协作协议

- **绝不将 NOT RUN 视为自动 FAIL** — 将其记录为 NOT RUN，让开发者手动确认状态。未确认的 NOT RUN 计入 PASS WITH WARNINGS，而非 FAIL。
- **绝不自动修复失败** — 报告它们并说明必须解决的内容。不要尝试编辑源代码或测试文件。
- **PASS WITH WARNINGS 不阻塞 QA 移交** — 它记录供 `/story-done` 后续跟进的建议性缺口。
- **`quick` 参数**跳过第 3 阶段（覆盖扫描）和第 4 阶段 Batch 3。用于修复特定失败后的快速重新检查。
- 对所有手动冒烟检查验证使用 `AskUserQuestion`。
- **未经询问绝不写入报告** — 第 6 阶段要求在创建任何文件之前获得明确批准。
