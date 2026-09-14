---
name: skill-test
description: "验证 Skill 文件的结构合规性和行为正确性。三种模式：static（性能检查器）、spec（行为验证）、audit（覆盖率报告）。"
argument-hint: "static [skill-name | all] | spec [skill-name] | category [skill-name | all] | audit"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试

验证 `.claude/skills/*/SKILL.md` 文件的结构合规性和行为正确性。无外部依赖 — 完全在现有 Skill/钩子/模板架构内运行。

**四种模式：**

| 模式 | 命令 | 用途 | Token 成本 |
|------|---------|---------|------------|
| `static` | `/skill-test static [name\|all]` | 结构检查器 — 每个 Skill 7 项合规检查 | 低（约 1k/每个 Skill） |
| `spec` | `/skill-test spec [name]` | 行为验证器 — 评估测试规格中的断言 | 中（约 5k/每个 Skill） |
| `category` | `/skill-test category [name\|all]` | 分类评分标准 — 检查 Skill 是否符合其分类特定指标 | 低（约 2k/每个 Skill） |
| `audit` | `/skill-test audit` | 覆盖率报告 — Skill、Agent 规格、上次测试日期 | 低（总计约 3k） |

---

## 第 1 阶段：解析参数

从第一个参数确定模式：

- `static [name]` → 对一个 Skill 运行 7 项结构检查
- `static all` → 对所有 Skill 运行 7 项结构检查（Glob `.claude/skills/*/SKILL.md`）
- `spec [name]` → 读取 Skill + 测试规格，评估断言
- `category [name]` → 运行来自 `CCGS Skill Testing Framework/quality-rubric.md` 的分类特定评分标准
- `category all` → 对目录中每个有 `category:` 的 Skill 运行分类评分标准
- `audit`（或无参数）→ 读取目录，列出所有 Skill 和 Agent，显示覆盖率

如果参数缺失或无法识别，输出用法并停止。

---

## 第 2A 阶段：Static 模式 — 结构检查器

对于每个被测试的 Skill，完整读取其 `SKILL.md` 并运行全部 7 项检查：

### 检查 1 — 必需的 Frontmatter 字段
文件必须在 YAML frontmatter 块中包含所有以下字段：
- `name:`
- `description:`
- `argument-hint:`
- `user-invocable:`
- `allowed-tools:`

**FAIL** 如果有任何缺失。

### 检查 2 — 多个阶段
Skill 必须有 ≥2 个编号的阶段标题。查找以下模式：
- `## Phase N` 或 `## Phase N:`
- `## N.`（编号的顶级部分）
- 如果阶段未显式编号，至少 2 个不同的 `##` 标题

**FAIL** 如果找到少于 2 个类似阶段的标题。

### 检查 3 — 判定关键字
Skill 必须至少包含以下之一：`PASS`、`FAIL`、`CONCERNS`、`APPROVED`、`BLOCKED`、`COMPLETE`、`READY`、`COMPLIANT`、`NON-COMPLIANT`

**FAIL** 如果以上均不存在。

### 检查 4 — 协作协议语言
Skill 必须包含写入前询问的语言。查找：
- `"May I write"`（规范形式）
- 文件写入说明附近的 `"before writing"` 或 `"approval"`
- 同一部分中 `"ask"` 和 `"write"` 的紧密组合

**WARN** 如果缺失（一些只读 Skill 合理跳过此项）。
**FAIL** 如果 `allowed-tools` 包含 `Write` 或 `Edit` 但未找到写入前询问的语言。

### 检查 5 — 后续步骤交接
Skill 必须以推荐的下一步行动或跟进路径结束。查找：
- 提及另一个 Skill 的最终部分（例如 `/story-done`、`/gate-check`）
- "Recommended next" 或 "next step" 措辞
- "Follow-Up" 或 "After this" 部分

**WARN** 如果缺失。

### 检查 6 — Fork 上下文复杂度
如果 frontmatter 包含 `context: fork`，则 Skill 应有 ≥5 个阶段标题（`##` 级别或编号的 Phase N 标题）。Fork 上下文适用于复杂的多阶段 Skill；简单 Skill 不应使用它。

**WARN** 如果设置了 `context: fork` 但找到的阶段少于 5 个。

### 检查 7 — 参数提示合理性
`argument-hint` 必须非空。如果 Skill 正文提及多种模式（例如 "Mode A | Mode B"），提示应反映它们。将提示与第一阶段"Parse Arguments"部分交叉引用。

**WARN** 如果提示为 `""` 或文档化的模式与提示不匹配。

---

### Static 模式输出格式

对于单个 Skill：
```
=== Skill 静态检查：/[name] ===

检查 1 — Frontmatter 字段：    PASS
检查 2 — 多个阶段：             PASS（找到 7 个阶段）
检查 3 — 判定关键字：           PASS（PASS、FAIL、CONCERNS）
检查 4 — 协作协议：             PASS（找到 "May I write"）
检查 5 — 后续步骤交接：         WARN（未找到跟进部分）
检查 6 — Fork 上下文复杂度：     PASS（8 个阶段，已设置 context: fork）
检查 7 — 参数提示：             PASS

判定：WARNINGS（1 个警告，0 个失败）
建议：在 Skill 末尾添加"后续行动"部分。
```

对于 `static all`，生成摘要表，然后列出任何不合规的 Skill：
```
=== Skill 静态检查：全部 52 个 Skill ===

Skill                  | 结果        | 问题
-----------------------|--------------|-------
gate-check             | COMPLIANT    |
design-review          | COMPLIANT    |
story-readiness        | WARNINGS     | 检查 5：无交接
...

摘要：48 个 COMPLIANT，3 个 WARNINGS，1 个 NON-COMPLIANT
综合判定：N 个 WARNINGS / N 个 FAILURES
```

---

## 第 2B 阶段：Spec 模式 — 行为验证器

### 步骤 1 — 定位文件

在 `.claude/skills/[name]/SKILL.md` 找到 Skill。
从 `CCGS Skill Testing Framework/catalog.yaml` 查找规格路径 — 使用匹配 Skill 条目的 `spec:` 字段。

如果任一缺失：
- 缺失 Skill："Skill '[name]' 在 `.claude/skills/` 中未找到。"
- 目录中缺失规格路径："在 catalog.yaml 中未为 '[name]' 设置规格路径。"
- 在路径上未找到规格文件："规格文件在 [path] 缺失。运行 `/skill-test audit` 查看覆盖缺口。"

### 步骤 2 — 读取两个文件

完整读取 Skill 文件和测试规格文件。

### 步骤 3 — 评估断言

对于规格中的每个**测试用例**：

1. 阅读 **Fixture** 描述（项目文件的假设状态）
2. 阅读**预期行为**步骤
3. 阅读每个**断言**复选框

对于每个断言，评估：如果在给定 Fixture 状态的情况下正确遵循 Skill 的书面说明，是否满足该断言。这是一个 Claude 评估的推理检查，而非代码执行。

标记每个断言：
- **PASS** — Skill 说明明确满足此断言
- **PARTIAL** — Skill 说明部分满足，但存在歧义
- **FAIL** — 给定 Fixture，Skill 说明不会满足此断言

对于**协议合规性**断言（始终存在）：
- 检查 Skill 是否在文件写入前要求"May I write"
- 检查 Skill 是否在请求批准前呈现发现
- 检查 Skill 是否以推荐的下一步结束
- 检查 Skill 是否避免未经批准自动创建文件

### 步骤 4 — 构建报告

```
=== Skill Spec 测试：/[name] ===
日期：[date]
Spec：CCGS Skill Testing Framework/skills/[category]/[name].md

案例 1：[Happy Path — 名称]
  Fixture：[摘要]
  断言：
    [PASS] [断言文本]
    [FAIL] [断言文本]
       原因：Skill 的第 3 阶段说"..."但 Fixture 状态意味着"..."
  案例判定：FAIL

案例 2：[Edge Case — 名称]
  ...
  案例判定：PASS

协议合规性：
  [PASS] 在文件写入前使用 "May I write"
  [PASS] 在请求批准前呈现发现
  [WARN] 末尾无显式后续步骤交接

总体判定：FAIL（1 个案例失败，1 个警告）
```

### 步骤 5 — 提供写入结果

"我可以将这些结果写入 `CCGS Skill Testing Framework/results/skill-test-spec-[name]-[date].md` 并更新 `CCGS Skill Testing Framework/catalog.yaml` 吗？"

如果同意：
- 将结果文件写入 `CCGS Skill Testing Framework/results/`
- 更新 Skill 在 `CCGS Skill Testing Framework/catalog.yaml` 中的条目：
  - `last_spec: [date]`
  - `last_spec_result: PASS|PARTIAL|FAIL`

---

## 第 2D 阶段：Category 模式 — 评分标准评估

### 步骤 1 — 定位 Skill 和分类

在 `.claude/skills/[name]/SKILL.md` 找到 Skill。
在 `CCGS Skill Testing Framework/catalog.yaml` 中查找 `category:` 字段。

如果未找到 Skill："Skill '[name]' 未找到。"
如果无 `category:` 字段："在 catalog.yaml 中未为 '[name]' 分配分类。请先将 `category: [name]` 添加到 Skill 条目。"

对于 `category all`：收集所有有 `category:` 字段的 Skill 并逐一处理。`category: utility` 的 Skill 仅评估 U1（静态检查通过）和 U2（关卡模式正确，如适用）— 跳至静态模式进行 U1。

### 步骤 2 — 读取评分标准部分

读取 `CCGS Skill Testing Framework/quality-rubric.md`。
提取匹配 Skill 分类的部分（例如 `### gate`、`### team`）。

### 步骤 3 — 读取 Skill

完整读取 Skill 的 `SKILL.md`。

### 步骤 4 — 评估评分标准指标

对于分类评分标准表中的每个指标：
1. 检查 Skill 的书面说明是否明确满足该标准
2. 标记 PASS、FAIL 或 WARN
3. 对于 FAIL/WARN，识别 Skill 文本中的确切缺陷（引用相关部分或注明其缺失）

### 步骤 5 — 输出报告

```
=== Skill 分类检查：/[name]（[category]）===

指标 G1 — Review 模式读取：       PASS
指标 G2 — Full 模式主管：         FAIL
  缺陷：第 3 阶段仅生成 CD-PHASE-GATE；缺少 TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE
指标 G3 — Lean 模式：仅 PHASE-GATE：PASS
指标 G4 — Solo 模式：无主管：     PASS
指标 G5 — 无自动推进：             PASS

判定：FAIL（1 个失败，0 个警告）
修复：将 TD-PHASE-GATE、PR-PHASE-GATE 和 AD-PHASE-GATE 添加到第 3 阶段的 full 模式主管面板。
```

### 步骤 6 — 提供更新目录

"我可以更新 `CCGS Skill Testing Framework/catalog.yaml` 以记录此次分类检查（`last_category`、`last_category_result`）对 [name] 吗？"

---

## 第 2C 阶段：Audit 模式 — 覆盖率报告

### 步骤 1 — 读取目录

读取 `CCGS Skill Testing Framework/catalog.yaml`。如果缺失，注明目录尚不存在（首次运行状态）。

### 步骤 2 — 枚举所有 Skill 和 Agent

Glob `.claude/skills/*/SKILL.md` 获取完整的 Skill 列表。从每个路径（目录名）提取 Skill 名称。

同时从 `CCGS Skill Testing Framework/catalog.yaml` 读取 `agents:` 部分以获取完整的 Agent 列表。

### 步骤 3 — 构建 Skill 覆盖表

对于每个 Skill：
- 检查是否存在规格文件（使用目录中的 `spec:` 路径，或 glob `CCGS Skill Testing Framework/skills/*/[name].md`）
- 从目录中查找 `last_static`、`last_static_result`、`last_spec`、`last_spec_result`、`last_category`、`last_category_result`、`category`（如果不在目录中则标记为"从未"/"—"）
- 优先级来自目录 `priority:` 字段（critical/high/medium/low）

### 步骤 3b — 构建 Agent 覆盖表

对于目录 `agents:` 部分中的每个 Agent：
- 检查是否存在规格文件（使用目录中的 `spec:` 路径，或 glob `CCGS Skill Testing Framework/agents/*/[name].md`）
- 从目录中查找 `last_spec`、`last_spec_result`、`category`

### 步骤 4 — 输出报告

```
=== Skill 测试覆盖审计 ===
日期：[date]

SKILLS（共 72 个）
已编写规格：72（100%）| 从未进行静态测试：72 | 从未进行分类测试：72

Skill                  | 分类     | 有 Spec | 上次 Static | S.结果   | 上次 Cat | C.结果   | 优先级
-----------------------|----------|----------|-------------|----------|----------|----------|----------
gate-check             | gate     | YES      | 从未         | —        | 从未      | —        | critical
design-review          | review   | YES      | 从未         | —        | 从未      | —        | critical
...

AGENTS（共 49 个）
已编写 Agent 规格：49（100%）

Agent                  | 分类       | 有 Spec | 上次 Spec    | 结果
-----------------------|------------|----------|-------------|--------
creative-director      | director   | YES      | 从未         | —
technical-director     | director   | YES      | 从未         | —
...

Top 5 优先级缺口（无规格的 Skill，critical/high 优先级）：
（如果所有规格均已编写则为 none）

Skill 覆盖率：  72/72 个规格（100%）
Agent 覆盖率：  49/49 个规格（100%）
```

Audit 模式下不写入文件。

提供："你想运行 `/skill-test static all` 检查所有 Skill 的结构合规性吗？`/skill-test category all` 运行分类评分标准检查？还是 `/skill-test spec [name]` 运行特定的行为测试？"

---

## 第 3 阶段：推荐的后续步骤

任何模式完成后，提供上下文相关的跟进：

- `static [name]` 后："如果测试规格存在，运行 `/skill-test spec [name]` 验证行为正确性。"
- `static all` 有失败后："首先处理 NON-COMPLIANT Skill。单独运行 `/skill-test static [name]` 获取详细的修复指导。"
- `spec [name]` PASS 后："更新 `CCGS Skill Testing Framework/catalog.yaml` 记录此次通过日期。考虑运行 `/skill-test audit` 查找下一个规格缺口。"
- `spec [name]` FAIL 后："审查失败的断言并更新 Skill 或测试规格以解决不匹配。"
- `audit` 后："从 critical 优先级缺口开始。使用位于 `CCGS Skill Testing Framework/templates/skill-test-spec.md` 的规格模板创建新规格。"
