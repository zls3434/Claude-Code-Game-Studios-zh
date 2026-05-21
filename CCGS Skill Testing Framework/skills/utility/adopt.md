<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/adopt

## Skill 摘要

`/adopt` 审核现有项目的工件——GDD、ADR、故事、基础设施文件以及 `technical-preferences.md`——检查其格式是否符合模板的 skill 流水线要求。它将每个差距按严重程度分类（BLOCKING / HIGH / MEDIUM / LOW），编写一份有序编号的迁移计划，并在通过 `AskUserQuestion` 获得用户明确批准后写入 `docs/adoption-plan-[date].md`。

此 skill 与 `/project-stage-detect`（检查存在什么）不同。`/adopt` 检查存在的东西是否能与模板的 skills 实际配合使用。

不适用 director gate。此 skill 不会调用任何 director agent。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含严重程度层级关键词：BLOCKING、HIGH、MEDIUM、LOW
- [ ] 在写入采纳计划之前包含 "May I write" 或 `AskUserQuestion` 语言
- [ ] 结尾有下一步交接（例如，提供立即修复最高优先级差距的选项）

---

## Director Gate 检查

无。`/adopt` 是一个棕地审核工具。不适用 director gate。

---

## 测试用例

### 用例 1：Happy Path — 所有 GDD 合规，无差距，COMPLIANT

**Fixture：**
- `design/gdd/` 包含 3 个 GDD 文件；每个都有完整的 8 个必需 section 及内容
- `docs/architecture/adr-0001.md` 存在，包含 `## Status`、`## Engine Compatibility` 及所有其他必需 section
- `production/stage.txt` 存在
- `docs/architecture/tr-registry.yaml` 和 `docs/architecture/control-manifest.md` 存在
- 引擎已在 `technical-preferences.md` 中配置

**输入：** `/adopt`

**预期行为：**
1. Skill 输出 "Scanning project artifacts..."，然后静默读取所有工件
2. 报告检测到的阶段、GDD 数量、ADR 数量、故事数量
3. 阶段 2 审核：所有 3 个 GDD 均具有全部 8 个 section，Status 字段存在且有效
4. ADR 审核：所有必需 section 均存在
5. 基础设施审核：所有关键文件均存在
6. 阶段 3：零 BLOCKING、零 HIGH、零 MEDIUM、零 LOW 差距
7. 摘要报告："No blocking gaps — this project is template-compatible"
8. 使用 `AskUserQuestion` 询问是否写入计划；用户选择写入
9. 采纳计划写入 `docs/adoption-plan-[date].md`
10. 阶段 7 提供下一步操作：无阻塞差距，提供后续步骤选项

**断言：**
- [ ] Skill 在展示任何输出之前先静默读取
- [ ] "Scanning project artifacts..." 在静默读取阶段之前显示
- [ ] 差距计数显示 0 BLOCKING、0 HIGH、0 MEDIUM（或仅有 LOW）
- [ ] 在写入采纳计划之前使用 `AskUserQuestion`
- [ ] 采纳计划文件写入 `docs/adoption-plan-[date].md`
- [ ] 阶段 7 提供一个具体的下一步操作（不仅仅是列表）

---

### 用例 2：不合规文档 — GDD 缺少 section，NEEDS MIGRATION

**Fixture：**
- `design/gdd/` 包含 2 个 GDD 文件：
  - `combat.md` — 缺少 `## Acceptance Criteria` 和 `## Formulas` section
  - `movement.md` — 所有 8 个 section 均存在
- 一个 ADR（`adr-0001.md`）缺少 `## Status` section
- `docs/architecture/tr-registry.yaml` 不存在

**输入：** `/adopt`

**预期行为：**
1. Skill 扫描所有工件
2. 阶段 2 审核发现：
   - `combat.md`：缺少 2 个 section（Acceptance Criteria、Formulas）
   - `adr-0001.md`：缺少 `## Status` — BLOCKING 影响
   - `tr-registry.yaml`：缺失 — HIGH 影响
3. 阶段 3 分类：
   - BLOCKING：`adr-0001.md` 缺少 `## Status`（story-readiness 会静默通过）
   - HIGH：`tr-registry.yaml` 缺失；`combat.md` 缺少 Acceptance Criteria（无法生成故事）
   - MEDIUM：`combat.md` 缺少 Formulas
4. 阶段 4 构建有序迁移计划：
   - 步骤 1（BLOCKING）：向 `adr-0001.md` 添加 `## Status` — 命令：`/architecture-decision retrofit`
   - 步骤 2（HIGH）：运行 `/architecture-review` 引导生成 tr-registry.yaml
   - 步骤 3（HIGH）：向 `combat.md` 添加 Acceptance Criteria — 命令：`/design-system retrofit`
   - 步骤 4（MEDIUM）：向 `combat.md` 添加 Formulas
5. 差距预览以项目符号显示 BLOCKING 项（实际文件名），HIGH/MEDIUM 以计数形式显示
6. `AskUserQuestion` 询问是否写入计划；批准后写入
7. 阶段 7 提供立即修复最高优先级差距（ADR Status）的选项

**断言：**
- [ ] BLOCKING 差距在差距预览中以明确的文件名项目符号列出
- [ ] HIGH 和 MEDIUM 在差距预览中以计数形式显示
- [ ] 迁移计划项按 BLOCKING 优先的顺序排列
- [ ] 每个计划项包含修复命令或手动步骤
- [ ] 写入前使用 `AskUserQuestion`
- [ ] 阶段 7 提供立即修复第一个 BLOCKING 项的选项

---

### 用例 3：混合状态 — 部分文档合规，部分不合规，部分报告

**Fixture：**
- 4 个 GDD 文件：2 个完全合规，2 个有差距（一个缺少 Tuning Knobs，一个缺少 Edge Cases）
- ADR：3 个文件 — 2 个合规，1 个缺少 `## ADR Dependencies`
- 故事：5 个文件 — 3 个有 TR-ID 引用，2 个没有
- 基础设施：所有关键文件存在；`technical-preferences.md` 已完全配置

**输入：** `/adopt`

**预期行为：**
1. Skill 审核所有工件类型
2. 审核摘要显示总计："4 GDDs (2 fully compliant, 2 with gaps); 3 ADRs (2 fully compliant, 1 with gaps); 5 stories (3 with TR-IDs, 2 without)"
3. 差距分类：
   - 无 BLOCKING 差距
   - HIGH：1 个 ADR 缺少 `## ADR Dependencies`
   - MEDIUM：2 个 GDD 缺少 section；2 个故事缺少 TR-ID
   - LOW：无
4. 迁移计划先列出 HIGH 差距，然后按顺序列出 MEDIUM 差距
5. 包含说明："Existing stories continue to work — do not regenerate stories that are in progress or done"
6. `AskUserQuestion` 写入计划；批准后写入

**断言：**
- [ ] 显示每种工件的合规统计（N 个合规，M 个有差距）
- [ ] 计划中包含现有故事兼容性说明
- [ ] 无 BLOCKING 差距导致迁移计划中无 BLOCKING section
- [ ] HIGH 差距在计划排序中先于 MEDIUM 差距
- [ ] 写入前使用 `AskUserQuestion`

---

### 用例 4：无工件 — 新项目，引导运行 /start

**Fixture：**
- 仓库中 `design/gdd/`、`docs/architecture/`、`production/epics/` 无文件
- `production/stage.txt` 不存在
- `src/` 目录不存在或文件少于 10 个
- 无 game-concept.md、无 systems-index.md

**输入：** `/adopt`

**预期行为：**
1. 阶段 1 存在性检查未发现工件
2. Skill 推断为 "Fresh" — 无棕地工作需要迁移
3. 使用 `AskUserQuestion`：
   - "This looks like a fresh project — no existing artifacts found. `/adopt` is for projects with work to migrate. What would you like to do?"
   - 选项："Run `/start`"、"My artifacts are in a non-standard location"、"Cancel"
4. Skill 停止 — 无论用户选择什么，都不会进入审核阶段

**断言：**
- [ ] 未发现工件时使用 `AskUserQuestion`（而非纯文本消息）
- [ ] `/start` 作为命名选项呈现
- [ ] Skill 在问题之后停止 — 不运行审核阶段
- [ ] 不写入采纳计划文件

---

### 用例 5：Director Gate 检查 — 无 gate；adopt 是一个工具审核 skill

**Fixture：**
- 项目包含合规与不合规 GDD 的混合

**输入：** `/adopt`

**预期行为：**
1. Skill 完成完整审核并生成迁移计划
2. 在任何时候都不生成 director agent
3. 输出中不出现 gate ID（CD-*、TD-*、AD-*、PR-*）
4. skill 运行期间不调用 `/gate-check`

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] Skill 在到达计划写入或取消时没有任何 gate 判决

---

## 协议合规性

- [ ] 在静默读取阶段之前输出 "Scanning project artifacts..."
- [ ] 在展示任何结果之前静默读取所有工件
- [ ] 在询问是否写入之前显示采纳审核摘要和差距预览
- [ ] 在写入采纳计划文件之前使用 `AskUserQuestion`
- [ ] 采纳计划写入 `docs/adoption-plan-[date].md` — 不写入其他路径
- [ ] 迁移计划项排序：BLOCKING 优先，HIGH 其次，MEDIUM 第三，LOW 最后
- [ ] 阶段 7 始终提供一个具体的下一步操作（而非通用列表）
- [ ] 绝不重新生成现有工件 — 仅填补存在内容的差距
- [ ] 任何时候都不调用 director gate

---

## 覆盖说明

- `gdds`、`adrs`、`stories` 和 `infra` 参数模式会缩小审核范围；每种模式遵循与完整审核相同的模式，但仅限于该工件类型。此处不单独 fixture 测试。
- systems-index.md 的括号状态值检查（BLOCKING）是一个特殊情况，会在写入计划之前触发立即修复提议；不单独测试。
- review-mode.txt 提示（阶段 6b）在计划写入后且 `production/review-mode.txt` 不存在时运行；此处不单独测试。
