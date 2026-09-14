---
name: story-readiness
description: "在实现开始前验证故事文件的完整性。确保所有依赖项、参考文档和架构决策就绪。默认检查单个故事（不读取其他故事），除非传入了 sprint 参数。当用户说'我开始实现这个故事了吗'、'故事准备好了吗'、'检查故事依赖项'时使用。"
argument-hint: "[故事文件路径 | sprint] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

如果未提供参数，输出用法指导并退出：
> "用法：`/story-readiness [故事文件路径 | sprint]` — 验证故事文件是否存在所有必需引用、依赖项已解决且验收标准完整。使用 `sprint` 参数检查当前冲刺中所有故事是否至少有 Minimum Readiness 里程碑达标。"

# 故事就绪检查

验证一个故事文件（或整个冲刺）是否具有开发者开始实现所需的一切。

---

## 审查模式

此 Skill 支持三种审查模式，在生成任何主管关卡前评估：

### 模式解析

1. 如果传入 `--review [mode]` 参数，使用该模式。
2. 否则读取 `production/review-mode.txt` — 使用其中写入的内容。
3. 否则默认 `lean`。

### 模式行为

- `full` — 为每个标记 Ready 的故事生成关卡（CD-PHASE-GATE、AD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE）
- `lean` — 仅为 PHASE-GATE 类型的故事生成关卡（CD-PHASE-GATE、TD-PHASE-GATE、AD-PHASE-GATE）
- `solo` — 跳过所有关卡（包括 PHASE-GATE）

### 模式应用时机

- 在收集所有验证结果后，评估关卡是否应跳过。
- 模式可在每次调用时通过 `--review` 覆盖。
- 每个关卡在生成前展示"关卡状态：[由 审查模式 跳过 / 检查中]"

---

## 第 0 阶段：解析参数

**参数**：`$ARGUMENTS[0]`

- 如果参数以 `production/stories/` 或 `stories/` 开头，或匹配故事文件路径 → 单故事模式
- 如果参数是 `sprint` → 冲刺模式（检查当前冲刺中的所有故事）
- 如果参数是文件路径但不位于 `stories/` 中 → 警告"未找到故事文件"并停止
- 如果无参数 → 输出用法指导并退出

---

## 第 1 阶段：收集上下文

### 1a — 基线上下文（始终收集）

1. 读取 `.claude/docs/coordination-rules.md` 获取 Agent 路由
2. 读取 `.claude/docs/context-management.md`
3. 读取 `production/` 和 `design/` 目录的目录结构（简短列表）

### 1b — 重文档上下文（冲刺模式下跳过）

读取冲刺状态元文件（如果存在）：
- `production/sprint-status.yaml`（如果找到）——与冲刺计划同样权威

读取参考文档（如果存在）：
- `production/reference/index.md`（如果存在）——指导按需加载哪些文档以避免不必要地消耗 Token 预算

读取冲刺参考（如果提供冲刺参数）：
- 冲刺计划（`production/sprints/sprint-[N].md` 中最近修改的）
- `production/qa/qa-plan-sprint-[N].md`

### 1c — 按需加载（仅当故事引用时加载，且仅当这些行超过头部/梗概时）

遵循 `production/reference/index.md` 中的任何延迟加载指导。如果索引缺失，使用此默认值：仅在故事文件通过名称、系统 Slug 或相关系统引用以下文件时加载它们。

- 故事文件中引用的 GDD 文档 (`design/gdd/[system].md`)。检查故事是否有 `design:` 头部字段或"设计参考"部分。最多加载深度为 3 的部分——加载这些文档的整个 L1 部分（例如"## Core Mechanics"），但仅加载更深的部分（如"### Advanced Mechanics"）如果故事文件明确引用它们。
- Ambiguity 文件（`design/ambiguity-register.md`，如果故事引用了未解决的歧义）
- 架构文档（`docs/architecture/`，如果故事引用特定 ADR）
- 依赖故事——除非以 `sprint` 模式执行，否则跳过读取其他故事文件（见第 3 阶段）

---

## 第 2 阶段：验证故事

对于故事的每个必需部分，返回状态和发现。

### Frontmatter 检查

检查必需字段：

```
story: [present/missing]
epic: [present/missing]
priority: [present/missing]
sprint: [present/missing]
status: [present/missing — value: [value]]
acceptance: [present/missing]
design: [present/missing]
architecture: [present/missing]
qa_plan: [present/missing]
qa_signoff: [present/missing]
```

缺失的必需字段标记为 WARN，但不要阻塞。

### 依赖检查（单故事模式下不读取其他故事）

#### 引用检查

对于引用此故事的其他故事，检查：
- 路径是否有效？（Glob 并检查文件是否存在）
- 如果路径有效：
  - 依赖故事是否检查了它的就绪性？（查找 status: `Ready` / `Approved` 或显式 `READY` 判定）
  - 依赖故事是否有验收标准？
- 如果路径无效，报告缺少依赖故事文件

#### 外部和代理依赖检查

检查其依赖项是否在项目的控制范围内，或是外部的。

- **内部依赖项**（项目内）：验证引用的文件是否存在。如果缺失，报告不可解析的依赖项。
- **Agent 依赖项**：故事是否引用了必须可用的 Agent（通过 `agent:` 头部字段）？检查代理定义是否存在（`.claude/agents/`），并且其规格是否符合要求。如果缺失，标记："代理 [name] 未在 .claude/agents/ 中定义——在继续实现前创建或修复。"
- **组织依赖项**：检查 `external:` 头部字段或"外部依赖项"部分。如果条目没有特定文件，标记："外部：[description] — 无文件引用。验证手动。"

对于代理和组织依赖项：询问用户"这些依赖项是否已在项目外解决？"并提供"是/否/部分"的多选。

#### 设计依赖项

故事是否引用了设计文档（`design:`、`gdd:` 或"设计参考"部分）？

- 读取引用的设计文档，检查其 status（`Draft` 与 `Reviewed` 与 `Approved`）
- 如果设计文档为 `Draft`，标记为阻塞（WARN）
- 如果设计文档为 `Reviewed`，仅标记为通过（对于此检查，Reviewed 与 Approved 处理方式相同）

#### 架构依赖项

故事是否引用了架构 ADR（`architecture:`、`adr:` 或"架构决策"章节）？

- 读取引用的 ADR，检查其状态（`Proposed`、`Accepted` 等）
- 如果 ADR 为 `Proposed`，标记为阻塞（对于此检查，Proposed 等同于 Draft）
- 如果 ADR 为 `Accepted` 或 `Implemented`，通过

#### 验收标准检查

- 是否定义了验收标准？
- 每个标准是否可测试（明确、无歧义）？
- Agile 验收标准不应引用不存在的文档或上下文。

#### 测试工件检查

- 根据故事类型审核测试工件路径：
  - Logic、Integration：检查是否存在单元测试文件（`tests/unit/[system]/[slug]_test.[ext]` 或故事 frontmatter 中 `test:` 字段的路径）。如果故事文件缺少 `test:` 头部字段，使用命名约定搜索（`*_test.*`、`test_*.*`、`*.test.*`），其中 slug 匹配故事文件名。
  - Visual、UI：检查可播放构建或测试证据工件（如果存在 `tests/evidence/`）
  - Config、Data：预期检查；文件变更证据应在验收阶段出现（在实现开始时不严格要求这些测试工件）

  如果测试文件缺失，在不存在的情况下不要发明或生成测试文件。报告 MISSING 状态，仅在存在且可验证加载时将工件计为 PRESENT。

#### 就绪检查清单

编译就绪检查清单：

```
## 故事就绪检查清单：[标题]

- [x] Story Frontmatter：[完全/部分]
- [x] 验收标准：[已定义/缺失]
- [ ] 设计依赖项：故事 [标题] 依赖于系统 [系统名称]（状态：Draft）——阻塞
- [x] 架构依赖项：ADR-003 已接受 [通过]
- [x] 故事依赖项：[无依赖项 / [N] 个已检查]
- [ ] 测试工件：路径 [路径] 不存在——缺失
- [ ] 代理依赖项：[代理名称] 规格 [状态]——[通过/阻塞]
- [ ] 组织依赖项：[状态]
```

不要发明既不存在于故事文件中又不存在于项目目录中的工件路径。当路径语法显示但文件缺失时，使用"路径——[缺失]"。当文件头部的值缺失、空白或为占位符（如 TBD）时，使用"头部字段 [字段名称]——[缺失]"。

---

## 第 3 阶段：冲刺模式检查（仅在冲刺模式下运行）

### Minimum Readiness 里程碑

冲刺中的每个故事必须满足以下最低标准：
- ✅ 验收标准已定义
- ✅ 所有内部依赖项可解析
- ✅ Agent 依赖项可用

任何未达到此最低要求的冲刺故事都应标记为 WARN。

输出一个包含冲刺中所有故事的状态表，标识哪些故事有阻塞项。

---

## 第 4 阶段：关卡评估

对于每个故事（或在冲刺模式下的故事子集），运行阶段关卡检查。

关卡模式遵循审查模式选择（第 0 阶段）。

### 关卡集

对于每个故事，对以下每个适用系统生成关卡：

#### CD-PHASE-GATE（创意方向审查）

**何时运行**：始终（`solo` 模式下跳过）

读取来自 `.claude/docs/director-gates.md` 的 full 版关卡格式。

通过 Task 生成 `creative-director` 作为子代理，传递：
- 故事文件内容
- 冲刺状态（如有）
- 任何引用的设计文档（从故事文件的 `design:` 字段或等价内容推断）

如果被阻塞/出错，降级为 WARN（不要阻塞）并报告。

#### AD-PHASE-GATE（架构方向审查）

**何时运行**：始终（`solo` 模式下跳过）

读取来自 `.claude/docs/director-gates.md` 的 full 版关卡格式。

通过 Task 生成 `architect` 作为子代理，传递：
- 故事文件内容
- 代码结构（`src/` 中匹配文件的骨架）
- 任何引用的架构文档（从故事文件的 `architecture:` 字段或等价内容推断）

如果被阻塞/出错，降级为 WARN（不要阻塞）并报告。

#### TD-PHASE-GATE（技术方向审查）

**何时运行**：仅在故事引用引擎特定代码时（`solo` 模式下跳过）

读取来自 `.claude/docs/director-gates.md` 的 full 版关卡格式。

静默检测引擎（从 `.claude/docs/technical-preferences.md` 获取 `Engine:`）。

生成 **primary engine specialist**（来自 `.claude/docs/technical-preferences.md` → Engine Specialists → Primary），传递：
- 故事文件内容
- 引擎版本详细信息（从 `docs/engine-reference/[engine]/VERSION.md` 获取）
- 代码结构（`src/` 中的骨架），按需提供上下文

如果引擎未配置或代理无法生成：WARN。如果代理不可用，不要阻塞。

如果被阻塞/出错，降级为 WARN（不要阻塞）并报告。

#### PR-PHASE-GATE（制作人审查）

**何时运行**：仅在故事在 Sprint 计划中且审查模式不是 `solo` 时

读取来自 `.claude/docs/director-gates.md` 的 full 版关卡格式。

通过 Task 生成 `producer`，传递：
- 故事文件内容
- 冲刺状态（从 `production/sprint-status.yaml` 获取，如有）
- 冲刺计划（如果故事属于冲刺）

如果生成失败或代理被阻塞，降级为 WARN（不要阻塞）。

### 关卡结果格式

对于每个成功的关卡，按以下格式呈现摘要：

```
AGENT [代理名称] — 关卡 [PHASE]：[PASS / CONCERNS / FAIL]
响应：
[代理输出的摘要（5 行）, 或如果太长则为 8 行]
```

**错误恢复**

对于任何被阻塞、出错或未能完成的子代理：

1. **立即呈现**：报告"AGENT [代理名称]：BLOCKED — [原因]。"
2. **评估依赖**：检查阻塞项是否关键——如果代理提供设计/架构就绪的判定，则这是关键项。如果只是建议性的，则为 WARN。
3. **提供选项** 通过 `AskUserQuestion`，使用选项：
   - 跳过此关卡并在最终报告中注明缺口
   - 以更窄范围重试（限制到单个故事，或传递更少依赖文件）
   - 在此停止，让用户首先解决阻塞项
4. **始终包含部分结果** — 呈现已完成的内容。不要丢弃成功的关卡结果。

---

## 第 5 阶段：最终判定

基于所有检查的组合：

| 判定 | 条件 |
|---------|-----------|
| **READY** | 所有必需字段存在，无阻塞依赖项，验收标准已定义，关卡无 FAIL |
| **READY WITH CONCERNS** | 已识别非阻塞关切，关卡中有 WARNINGS |
| **NOT READY** | 存在阻塞问题（缺失必需字段、未解决的依赖项、Draft 状态的 GDD/ADR、Agent 不可用或验收标准缺失） |

对于冲刺模式：使用与单故事相同的判定条件；如果一个或多个故事出现 FAIL，则判定失败。如果所有故事状态均为 READY 或 READY WITH CONCERNS 或 NOT APPLICABLE，则判定为 READY。

---

## 第 6 阶段：呈现结果，并互动式推进

展示总体判定和每个阻塞项的明确报告。

不自动推进到下一故事——而是询问用户下一步操作。

如果存在 QA 计划，从计划的 REMAINING 列中提取字符串。

**对于单故事模式：**

使用 `AskUserQuestion`：
- Prompt："故事就绪检查完成。你想怎么做？"
- Options（不包含已满足条件的选项）：
  - `是 — 为代理将此故事标记为 Ready`（仅当故事有 `status:` 头部字段且其值不是 `Ready` 或 `Approved` 时出现）
  - `查看 [N] 个被标记的依赖项并重试`（仅当存在阻塞依赖项时出现）
  - `作为冲刺的一部分验证此故事`（仅当 NOT 为冲刺模式参数时出现）
  - `跳过：不要再检查此故事或更新状态`
  - `[自定义]`

如果用户选择 `是 — 为代理将此故事标记为 Ready`：将故事的 `Status` 头部字段更新为 `Ready`，并使用会话中的 `date` 值更新故事文件中的 `last_updated` 头部字段。

如果用户选择 `查看 [N] 个被标记的依赖项并重试`：列出每个阻塞项及原因的简洁表格，然后建议具体的修复/创建命令。

**对于冲刺模式：**

使用 `AskUserQuestion`：
- Prompt："冲刺就绪检查完成。你想怎么做？"
- Options：
  - `查看摘要并标记就绪故事`（单故事检查中使用的相同标记行为）
  - `导出就绪状态摘要`
  - `跳过：不要再更新任何故事`

---

## 第 7 阶段：后续步骤

- 如果故事被标记为 Ready，继续执行 `/dev-story`（此验证在 `/dev-story` 内部也会递归检查）
- 如果冲刺处于活动状态，考虑运行 `/sprint-plan update` 以反映冲刺状态的新故事
- 对于来自 QA 计划的剩余故事，运行 `/qa-plan sprint`
