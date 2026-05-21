<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 质量评分标准

用于 `/skill-test category [name|all]`，评估 skill 在结构合规性之外的质量。
每个 category 定义 4–5 个二元的 PASS/FAIL 指标，针对该 skill 的具体职责。

当 skill 的书面指令明确满足某条标准时，该指标为 PASS。
当指令缺失、模糊或矛盾时，该指标为 FAIL。
当指令部分满足标准时，该指标为 WARN。

---

## Skill 类别

### `gate`

**Skills**：gate-check

Gate skill 控制阶段转换。它必须在不过度自动推进 stage 的前提下强制执行正确性，
并且必须遵守三种 review mode。

| 指标 | PASS 标准 |
|---|---|
| **G1 — Review mode 读取** | Skill 在决定 spawn 哪些 director 之前读取 `production/session-state/review-mode.txt`（或等效文件） |
| **G2 — Full mode：所有 4 个 director 均 spawn** | 在 `full` mode 下，所有 4 个 Tier-1 director（CD, TD, PR, AD）的 PHASE-GATE prompt 被并行 invoke |
| **G3 — Lean mode：仅 PHASE-GATE** | 在 `lean` mode 下，仅运行 `*-PHASE-GATE` gate；内联 gate（CD-PILLARS, TD-ARCHITECTURE 等）被跳过 |
| **G4 — Solo mode：无 director** | 在 `solo` mode 下，不 spawn 任何 director gate；每个都被标注为"已跳过 — Solo mode" |
| **G5 — 不自动推进** | Skill 在未经用户通过"May I write"明确确认的情况下，绝不写入 `production/stage.txt` |

---

### `review`

**Skills**：design-review, architecture-review, review-all-gdds

Review skill 读取文档并产出结构化的裁决结果。它们在分析阶段主要处于只读模式，
且不得触发 director gate。

| 指标 | PASS 标准 |
|---|---|
| **R1 — 只读强制** | Skill 在未经用户明确批准的情况下不修改被审查的文档；任何写操作（review log、index 更新）都受"May I write" gate 控制 |
| **R2 — 8-section 检查** | Skill 明确评估所有 8 个必需的 GDD section（或等效的架构 section） |
| **R3 — 正确的裁决词汇** | 裁决必须恰好为以下之一：APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED（design）或 PASS / CONCERNS / FAIL（architecture） |
| **R4 — 分析阶段无 director gate** | Skill 在其分析阶段不 spawn director gate；分析后 director review（如 architecture-review 中）在 skill 的范围和风险需要时是可接受的 |
| **R5 — 结构化发现** | 输出在最终裁决之前包含逐 section 的状态表或 checklist |

> **例外情况：**
> - `design-review`：在 allowed-tools 中包含 `Write, Edit`，以支持可选的"立即修订"路径（所有写入受用户批准控制）以及写入 review log。R1 满足，因为被审查的文档不会被静默修改。
> - `architecture-review`：在分析完成后 spawn TD-ARCHITECTURE 和 LP-FEASIBILITY gate。这是有意为之 — architecture review 属于高风险操作，受益于 director 签字。R4 满足，因为 gate 在分析之后运行，而非分析期间。

---

### `authoring`

**Skills**：design-system, quick-design, architecture-decision, ux-design, ux-review, art-bible, create-architecture

Authoring skill 以协作方式创建或更新设计文档。完整的 GDD/UX authoring skill 使用
逐 section 循环；轻量级 authoring skill 使用适合其较小范围的单草稿模式。

| 指标 | PASS 标准 |
|---|---|
| **A1 — 逐 section 循环** | 完整 authoring skill（design-system, ux-design, art-bible）一次编写一个 section，在继续下一个之前呈现内容供审批。轻量级 skill（quick-design, architecture-decision, create-architecture）可草拟完整文档后请求审批 — 对于实现范围约 4 小时以下的文档，单草稿模式是可接受的。 |
| **A2 — 逐 section 的 May-I-write** | 完整 authoring skill 在写入每个 section 之前询问"May I write this to [filepath]?"。轻量级 skill 对完整文档询问一次。 |
| **A3 — Retrofit mode** | Skill 检测目标文件是否已存在，并提供更新特定 section 而非覆盖整个文档的选项。始终创建新文件的轻量级 skill（quick-design）除外。 |
| **A4 — Director gate 在正确的层级** | 如果为此 skill 定义了 director gate（例如 CD-GDD-ALIGN, TD-ADR），则在正确的 mode 阈值（full/lean）下运行 — 不在 solo 下运行 |
| **A5 — Skeleton-first** | 完整 authoring skill 在填充内容之前创建一个包含所有 section 标题的文件骨架，以便在会话中断时保留进度。轻量级 skill 除外。 |

> **完整 authoring skill**（必须通过全部 5 项指标）：`design-system`, `ux-design`, `art-bible`
> **轻量级 authoring skill**（A1、A2、A5 使用单草稿模式；A3 对于仅创建新文件的 skill 豁免）：`quick-design`, `architecture-decision`, `create-architecture`
> **Review-mode skill**（按 review 指标评估）：`ux-review`

---

### `readiness`

**Skills**：story-readiness, story-done

Readiness skill 在实现之前或之后验证 story。它们必须产出
多维裁决，并与 director gate mode 正确集成。

| 指标 | PASS 标准 |
|---|---|
| **RD1 — 多维检查** | Skill 检查 ≥3 个独立维度（例如 Design, Architecture, Scope, DoD），并分别报告每个维度 |
| **RD2 — 三级裁决** | 裁决层次结构明确定义：READY/COMPLETE > NEEDS WORK/COMPLETE WITH NOTES > BLOCKED |
| **RD3 — BLOCKED 需要外部操作** | BLOCKED 裁决仅保留给 story 作者独自无法解决的问题（例如 Proposed ADR、不可解决的依赖） |
| **RD4 — Director gate 在正确的 mode** | QL-STORY-READY 或 LP-CODE-REVIEW gate 在 `full` mode 下 spawn，在 `lean`/`solo` 下跳过并附跳过说明信息 |
| **RD5 — 下一个 story 交接** | 完成后，skill 显示活动 sprint 中的下一个 READY story |

---

### `pipeline`

**Skills**：create-epics, create-stories, dev-story, create-control-manifest, propagate-design-change, map-systems

Pipeline skill 产出供其他 skill 消费的工件。它们必须按正确 schema 写入文件，
遵守 layer/priority 排序，并在写入前 gate。

| 指标 | PASS 标准 |
|---|---|
| **P1 — 正确的输出 schema** | 每个产出文件遵循项目模板（EPIC.md、story frontmatter 等）；skill 引用模板路径 |
| **P2 — Layer/priority 排序** | 产出 epic 或 story 的 skill 遵守 layer 排序（core → extended → meta）和 priority 字段 |
| **P3 — 每个工件前 May-I-write** | Skill 在创建每个输出文件之前询问"May I write [artifact]?"，而非一次性批量批准所有文件 |
| **P4 — Director gate 在正确的层级** | 范围内的 gate（PR-EPIC, QL-STORY-READY, LP-CODE-REVIEW 等）在 `full` 下运行，在 `lean`/`solo` 下跳过并附跳过说明 |
| **P5 — 写前先读** | Skill 在产出工件前读取相关的 GDD/ADR/manifest 以确保对齐 |

---

### `analysis`

**Skills**：consistency-check, balance-check, content-audit, code-review, tech-debt,
scope-check, estimate, perf-profile, asset-audit, security-audit, test-evidence-review, test-flakiness

Analysis skill 扫描项目并呈现发现结果。它们在分析期间是只读的，
且必须在推荐任何文件写入之前询问。

| 指标 | PASS 标准 |
|---|---|
| **AN1 — 只读扫描** | 分析阶段仅使用 Read/Glob/Grep 工具；扫描过程中不使用 Write 或 Edit |
| **AN2 — 结构化发现表** | 输出包含一个发现表或 checklist（而非仅文本描述），每条发现附有 severity/priority |
| **AN3 — 不自动写入** | 任何建议的文件写入（例如 tech-debt 登记、修复补丁）受"May I write"控制 |
| **AN4 — 分析期间无 director gate** | Analysis skill 不 spawn director gate；它们产出发现供人工审查 |

---

### `team`

**Skills**：team-combat, team-narrative, team-audio, team-level, team-ui, team-qa,
team-release, team-polish, team-live-ops

Team skill 为某个部门编排多个 specialist agent。它们必须
spawn 正确的 agent，以并行方式运行相互独立的 agent，并立即浮现 block。

| 指标 | PASS 标准 |
|---|---|
| **T1 — 命名 agent 列表** | Skill 明确列出它 spawn 哪些 agent 以及顺序 |
| **T2 — 独立任务并行化** | 输入不相互依赖的 agent 被并行 spawn（单条消息，多个 Task 调用） |
| **T3 — BLOCKED 浮现** | 如果任何 spawn 的 agent 返回 BLOCKED 或失败，skill 立即浮现该状态并停止依赖工作 — 绝不静默跳过 |
| **T4 — 在继续之前收集所有裁决** | 依赖阶段等待所有并行 agent 完成后才继续 |
| **T5 — 无参数时输出用法错误** | 如果缺少必需参数（例如 feature name），skill 输出用法提示并停止，不 spawn agent |

---

### `sprint`

**Skills**：sprint-plan, sprint-status, milestone-review, retrospective, changelog, patch-notes

Sprint skill 读取 production 状态并产出报告或规划工件。
它们在特定 mode 阈值下有 PR-SPRINT 或 PR-MILESTONE gate。

| 指标 | PASS 标准 |
|---|---|
| **SP1 — 读取 sprint/milestone 状态** | Skill 在产出输出之前读取 `production/sprints/` 或 `production/milestones/` |
| **SP2 — 正确的 sprint gate** | PR-SPRINT（用于规划）或 PR-MILESTONE（用于 milestone review）gate 在 `full` mode 下运行，在 `lean`/`solo` 下跳过 |
| **SP3 — 结构化输出** | 输出使用一致的结构（velocity table、risk list、action items），而非自由文本 |
| **SP4 — 不自动提交** | Skill 在未经"May I write"的情况下绝不写入 sprint 文件或 milestone 记录 |

---

### `utility`

**Skills**：start, help, brainstorm, onboard, adopt, hotfix, prototype, localize,
launch-checklist, release-checklist, smoke-check, soak-test, test-setup, test-helpers,
regression-suite, qa-plan, bug-triage, bug-report, playtest-report, asset-spec,
reverse-document, project-stage-detect, setup-engine, skill-test, skill-improve,
day-one-patch，以及不在上述 category 中的任何其他 skill

Utility skill 通过 7 项标准静态检查。如果它们碰巧 spawn director
gate，则 gate mode 逻辑也必须正确。

| 指标 | PASS 标准 |
|---|---|
| **U1 — 通过全部 7 项静态检查** | `/skill-test static [name]` 返回 COMPLIANT，0 个 FAIL |
| **U2 — Gate mode 正确（如适用）** | 如果 skill spawn 任何 director gate，则正确读取 review-mode 并应用 full/lean/solo 逻辑 |

---

## Agent 类别

用于验证 `tests/agents/` 中的 agent spec 文件。

### `director`

**Agents**：creative-director, technical-director, art-director, producer

| 指标 | PASS 标准 |
|---|---|
| **D1 — 正确的裁决词汇** | 返回 APPROVE / CONCERNS / REJECT（或领域等价词：producer 使用 REALISTIC/CONCERNS/UNREALISTIC） |
| **D2 — 尊重领域边界** | 不在其声明的领域之外做出有约束力的决策 |
| **D3 — 冲突升级** | 当两个部门冲突时，升级到正确的父级（creative-director 或 technical-director），而非单方面决定 |
| **D4 — Opus model tier** | Agent 按 coordination-rules.md 分配 Opus 模型 |

### `lead`

**Agents**：lead-programmer, qa-lead, narrative-director, audio-director, game-designer,
systems-designer, level-designer

| 指标 | PASS 标准 |
|---|---|
| **L1 — 领域裁决** | 返回领域特定的裁决（例如 lead-programmer 使用 FEASIBLE/INFEASIBLE，qa-lead 使用 PASS/FAIL） |
| **L2 — 升级到共享父级** | 领域外冲突升级到 creative-director（design）或 technical-director（tech） |
| **L3 — Sonnet model tier** | Agent 按 coordination-rules.md 分配 Sonnet 模型（默认） |

### `specialist`

**Agents**：gameplay-programmer, ai-programmer, technical-artist, sound-designer,
engine-programmer, tools-programmer, network-programmer, security-engineer,
accessibility-specialist, ux-designer, ui-programmer, performance-analyst, prototyper,
qa-tester, writer, world-builder

| 指标 | PASS 标准 |
|---|---|
| **S1 — 留在领域内** | 明确限定自身到其声明的领域；将领域外请求转交 |
| **S2 — 不做出跨领域有约束力的决策** | 不单方面决定由另一个 specialist 拥有的事项 |
| **S3 — 正确转交** | 领域外请求被重定向到正确的 agent，而非静默拒绝 |

### `engine`

**Agents**：godot-specialist, godot-gdscript-specialist, godot-csharp-specialist,
godot-shader-specialist, godot-gdextension-specialist, unity-specialist, unity-ui-specialist,
unity-shader-specialist, unity-dots-specialist, unity-addressables-specialist,
unreal-specialist, ue-blueprint-specialist, ue-gas-specialist, ue-umg-specialist,
ue-replication-specialist

| 指标 | PASS 标准 |
|---|---|
| **E1 — 版本感知** | 在建议 API 调用之前引用 `docs/engine-reference/` 中的引擎版本；标记截止后风险 |
| **E2 — 文件路由** | 将文件类型路由到正确的子 specialist（例如 `.gdshader` → godot-shader-specialist，而非 godot-gdscript-specialist） |
| **E3 — 引擎特定模式** | 强制执行引擎特定的惯用法（例如 GDScript static typing、C# attribute exports、Blueprint function libraries） |

### `qa`

**Agents**：qa-tester, qa-lead, security-engineer, accessibility-specialist

| 指标 | PASS 标准 |
|---|---|
| **Q1 — 产出工件而非代码** | 主要输出是 test case、bug report 或 coverage gap — 而非实现代码 |
| **Q2 — 证据格式** | Test case 遵循项目的 test evidence 格式（按 coding-standards.md 的 unit/integration/visual/UI） |
| **Q3 — 不越界** | 不提议新功能；标记缺口供人工决定 |

### `operations`

**Agents**：devops-engineer, release-manager, live-ops-designer, community-manager,
analytics-engineer, economy-designer, localization-lead

| 指标 | PASS 标准 |
|---|---|
| **O1 — 领域所有权明确** | Agent 描述清楚说明它拥有什么（pipeline、release、economy 等） |
| **O2 — 转交实现** | 不编写游戏逻辑或引擎代码；委托给适当的 specialist |
| **O3 — 工具集匹配角色** | Frontmatter 中的 `allowed-tools` 匹配角色的运维性质（而非编码性质）|
