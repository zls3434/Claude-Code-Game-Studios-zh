<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 技能流程图

各 skill 如何在 7 个开发阶段中链式串联的可视化地图。
这些图展示了每个 skill 之前和之后运行什么，以及它们之间流动什么产物。

---

## 完整管线概览（从零到交付）

```
阶段 1：概念
  /start ──────────────────────────────────────────────────────► 路由到 A/B/C/D
  /brainstorm ──────────────────────────────────────────────────► design/gdd/game-concept.md
  /setup-engine ────────────────────────────────────────────────► CLAUDE.md + technical-preferences.md
  /prototype [core-mechanic] ───────────────────────────────────► prototypes/[name]-concept/REPORT.md
        │ PROCEED                                                  （在编写 GDD 前验证想法）
        ▼
  /design-review [game-concept.md] ────────────────────────────► 概念已验证
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 systems-design
        │
        ▼
阶段 2：系统设计
  /map-systems ────────────────────────────────────────────────► design/gdd/systems-index.md
        │
        ▼ （对每个系统，按依赖顺序）
  /design-system [name] ──────────────────────────────────────► design/gdd/[system].md
  /design-review [system].md ─────────────────────────────────► 逐 GDD 审查评论
        │
        ▼ （所有 MVP GDD 完成后）
  /review-all-gdds ────────────────────────────────────────────► design/gdd/gdd-cross-review-[date].md
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 technical-setup
        │
        ▼
阶段 3：技术搭建
  /create-architecture ────────────────────────────────────────► docs/architecture/master.md
  /architecture-decision (×N) ─────────────────────────────────► docs/architecture/[adr-nnn].md
  /architecture-review ────────────────────────────────────────► 审查报告 + docs/architecture/tr-registry.yaml
  /create-control-manifest ────────────────────────────────────► docs/architecture/control-manifest.md
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 pre-production
        │
        ▼
阶段 4：预制作
  [UX —— 在 Epic 之前，以便故事验收标准能引用特定的 UX 产物]
  /ux-design [screen/hud/patterns] ────────────────────────────► design/ux/*.md
  /ux-review ──────────────────────────────────────────────────► UX 规格已批准（/team-ui 的硬门禁）

  [测试基础设施 —— 在故事引用测试之前先搭建框架]
  /test-setup ─────────────────────────────────────────────────► 测试框架 + CI/CD 管线
  /test-helpers ───────────────────────────────────────────────► tests/helpers/[engine-specific].gd

  [垂直切片 —— 在 Epic 之前，验证完整游戏循环]
  /vertical-slice ─────────────────────────────────────────────► prototypes/[name]-vertical-slice/REPORT.md
  /playtest-report ────────────────────────────────────────────► production/playtests/

  [故事 + Sprint 计划 —— 仅在垂直切片 PROCEEDS 之后]
  /create-epics [layer] ───────────────────────────────────────► production/epics/*/EPIC.md
  /create-stories [epic-slug] ─────────────────────────────────► production/epics/*/story-*.md
  /sprint-plan new ────────────────────────────────────────────► production/sprints/sprint-01.md
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 production
        │
        ▼
阶段 5：制作（重复的 Sprint 循环）
  /sprint-status ──────────────────────────────────────────────► sprint 快照
  /story-readiness [story] ────────────────────────────────────► 故事已验证 READY
        │
        ▼ （拾取并实现）
  /dev-story [story] ──────────────────────────────────────────► 路由到正确的程序员 Agent
        │
        ▼ （实现期间，根据需要）
  /code-review ────────────────────────────────────────────────► 代码审查报告
  /scope-check ────────────────────────────────────────────────► 范围蔓延检测 / 清除
  /content-audit ──────────────────────────────────────────────► GDD 内容缺口已识别
  /bug-report ─────────────────────────────────────────────────► production/qa/bugs/bug-NNN.md
  /bug-triage ─────────────────────────────────────────────────► Bug 重新排序 + 分配

  [功能区域的 Team skill —— 当开发完整功能时生成]
  /team-combat / /team-narrative / /team-ui / /team-level / /team-audio

  [每个 Sprint 的 QA 循环]
  /qa-plan ────────────────────────────────────────────────────► production/qa/qa-plan-sprint-NN.md
  /smoke-check ────────────────────────────────────────────────► 冒烟测试门禁（PASS/FAIL）
  /regression-suite ───────────────────────────────────────────► 覆盖缺口 + 缺失的回归测试
  /test-evidence-review ───────────────────────────────────────► 证据质量报告
  /test-flakiness ─────────────────────────────────────────────► 不稳定测试报告
        │
        ▼
  /story-done [story] ─────────────────────────────────────────► 故事已关闭 + 下一个浮现
  /sprint-plan [next] ─────────────────────────────────────────► 下一个 sprint
        │
        ▼ （制作里程碑之后）
  /milestone-review ───────────────────────────────────────────► 里程碑报告
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 polish
        │
        ▼
阶段 6：打磨
  /perf-profile ───────────────────────────────────────────────► 性能报告 + 修复
  /balance-check ──────────────────────────────────────────────► 平衡报告 + 修复
  /asset-audit ────────────────────────────────────────────────► 资产合规报告
  /tech-debt ──────────────────────────────────────────────────► docs/tech-debt-register.md
  /soak-test ──────────────────────────────────────────────────► 浸泡测试协议 + 结果
  /localize ───────────────────────────────────────────────────► 本地化就绪报告
  /team-polish ────────────────────────────────────────────────► 打磨 sprint 已编排
  /team-qa ────────────────────────────────────────────────────► 完整 QA 循环签核
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 release
        │
        ▼
阶段 7：发布
  /launch-checklist ───────────────────────────────────────────► 上线就绪报告
  /release-checklist ──────────────────────────────────────────► 平台特定清单
  /changelog ──────────────────────────────────────────────────► CHANGELOG.md
  /patch-notes ────────────────────────────────────────────────► 面向玩家的说明
  /team-release ───────────────────────────────────────────────► 发布管线已编排
        │
        ▼ （发布后，持续进行）
  /hotfix ─────────────────────────────────────────────────────► 紧急修复带审计跟踪
  /team-live-ops ──────────────────────────────────────────────► 实时运营内容计划
```

---

## Skill 链：/design-system 详解

单份 GDD 如何编写、审查并交接给架构：

```
systems-index.md（输入）
game-concept.md（输入）
上游 GDD（输入，如果有）
        │
        ▼
/design-system [name]
        │
        ├── 预检：可行性表 + 引擎风险标记
        │
        ├── 逐节循环 × 8：
        │     问题 → 选项 → 决策 → 草稿 → 审批 → 写入
        │     [每节审批后立即写入文件]
        │
        └── 输出：design/gdd/[system].md（完整，全部 8 节）
                │
                ▼
        /design-review design/gdd/[system].md
                │
                ├── APPROVED → 在 systems-index 中标记 DONE，继续下一个系统
                ├── NEEDS REVISION → Agent 显示具体问题，重新进入逐节循环
                └── MAJOR REVISION → 进入下一个系统前需要重大重新设计
                        │
                        ▼ （所有 MVP GDD + 交叉审查后）
                /review-all-gdds
                        │
                        └── 输出：gdd-cross-review-[date].md
```

---

## Skill 链：UX / UI 管线详解

UX 规格在阶段 4（预制作）中编写，在 Epic 之前，以便
故事验收标准可以引用特定的 UX 产物。

```
design/gdd/*.md（提取 UI/UX 需求）
design/player-journey.md（情感弧线，如果已编写）
        │
        ▼
/ux-design hud              → design/ux/hud.md
/ux-design screen [name]    → design/ux/screens/[name].md
/ux-design patterns         → design/ux/interaction-patterns.md
        │
        ▼
/ux-review design/ux/
        │
        ├── APPROVED → UX 规格就绪，继续 /create-epics
        ├── NEEDS REVISION → 列出阻塞问题 → 修复 → 重新运行审查
        └── MAJOR REVISION → 根本性 UX 问题 → 在 Epic 之前重新设计
                │
                ▼ （APPROVED 后 —— 在阶段 5 中实现 UI 功能时）
        /team-ui
                │
                ├── 阶段 1：/ux-design（如果仍有缺少的规格）+ /ux-review
                ├── 阶段 2：视觉设计（art-director）
                ├── 阶段 3：布局实现（ui-programmer）
                ├── 阶段 4：无障碍审计（accessibility-specialist）
                └── 阶段 5：最终审查

注意：/ux-design 和 /ux-review 属于阶段 4（预制作）。
      /team-ui 属于阶段 5（制作），当构建 UI 功能时使用。
```

---

## Skill 链：Dev Story 流详解

故事如何从积压移动到已关闭：

```
/story-readiness [story]
        │
        ├── READY → 状态：ready-for-dev → 拾取以进行实现
        ├── NEEDS WORK → Agent 显示具体缺口 → 解决 → 重新运行就绪检查
        └── BLOCKED → ADR 仍为 Proposed，或上游故事未完成
                │
                ▼ （READY 后）
        /dev-story [story]
                │
                ├── 读取：故事文件、链接的 GDD 需求、ADR 决策、Control Manifest
                ├── 路由到：gameplay-programmer / engine-programmer / ui-programmer / 等
                │
                └── 实现开始
                        │
                        ▼ （可选，实现期间/后）
                /code-review          → 变更集的架构审查
                /scope-check          → 对照原始故事标准验证无范围蔓延
                /test-evidence-review → 验证测试文件和手动证据质量
                        │
                        ▼
                /story-done [story]
                        │
                        ├── COMPLETE → 状态：Complete，sprint-status.yaml 已更新，下一个故事浮现
                        ├── COMPLETE WITH NOTES → 完成但部分标准被延期（已记录）
                        └── BLOCKED → 验收标准无法验证 → 调查阻塞因素
```

---

## Skill 链：故事生命周期（积压到已关闭）

故事如何从积压到已关闭（摘要视图）：

```
/create-epics [layer]
        │
        └── 输出：production/epics/[slug]/EPIC.md
                │
                ▼
        /create-stories [epic-slug]
                │
                └── 输出：production/epics/[slug]/story-NNN-[slug].md
                            （状态：Ready 或如果 ADR 为 Proposed 则为 Blocked）
                │
                ▼
        /story-readiness [story]
                │
                ├── READY → /dev-story → 实现 → /story-done
                ├── NEEDS WORK → 解决缺口 → 重新运行
                └── BLOCKED → 先修复上游依赖
```

---

## Skill 链：QA 管线详解

```
[阶段 4 —— 一次性基础设施搭建]
/test-setup ────────────────────────────────────────────────────► 测试框架已搭建 + CI/CD 已接线
/test-helpers ──────────────────────────────────────────────────► tests/helpers/[engine].gd（GDUnit4、NUnit 等）

[阶段 5 —— 每个 Sprint 的 QA 循环]
/qa-plan [sprint or feature]
        │
        ├── 读取：故事文件、GDD、验收标准
        ├── 按测试类型对每个故事进行分类：
        │     逻辑 → 自动化单元测试（BLOCKING）
        │     集成 → 集成测试或文档化的试玩测试（BLOCKING）
        │     视觉/触感 → 截图 + 负责人签核（ADVISORY）
        │     UI → 手动遍历或交互测试（ADVISORY）
        │     配置/数据 → 冒烟检查（ADVISORY）
        └── 输出：production/qa/qa-plan-sprint-NN.md
                │
                ▼
        /smoke-check
                │
                ├── PASS → QA 交接已清关
                └── FAIL → 阻止 sprint 关闭 → 先修复关键路径
                        │
                        ▼
                /regression-suite
                        │
                        └── 覆盖缺口 + 缺少回归测试的已修复 Bug 列表
                                │
                                ▼
                        /test-evidence-review
                                │
                                └── 验证证据质量，而非仅是存在
                                        │
                                        ▼ （如果 CI 运行历史可用）
                        /test-flakiness
                                │
                                └── 不稳定测试报告 + 修复建议

[阶段 6 —— 扩展稳定性测试]
/soak-test ─────────────────────────────────────────────────────► 浸泡测试协议 + 观察结果
/team-qa ───────────────────────────────────────────────────────► 发布门禁的完整 QA 循环签核

[持续 —— Bug 管理]
/bug-report ────────────────────────────────────────────────────► production/qa/bugs/bug-NNN.md
/bug-triage ────────────────────────────────────────────────────► 未关闭的 Bug 重新排序 + 分配

[元 —— harness 验证]
/skill-test [lint|spec|catalog] ────────────────────────────────► skill 文件结构 + 行为检查
```

---

## 棕地上手流程

对于有现有工作的项目（使用 `/start` 选项 D 或直接运行）：

```
/project-stage-detect    → 阶段检测报告
        │
        ▼
/adopt
        │
        ├── 阶段 1：检测已存在的内容
        ├── 阶段 2：格式审计（不仅是存在性）
        ├── 阶段 3：分类缺口（BLOCKING / HIGH / MEDIUM / LOW）
        ├── 阶段 4：有序迁移计划
        ├── 阶段 5：写入 docs/adoption-plan-[date].md
        └── 阶段 6：内联修复最紧急的缺口（可选）
                │
                ▼
        /design-system retrofit [path]    → 填补缺失的 GDD 节
        /architecture-decision retrofit [path] → 填补缺失的 ADR 节
        /gate-check                       → 你在管线中的哪个位置？
```

---

## 如何阅读这些图表

| 符号 | 含义 |
|--------|---------|
| `──►` | 产生此产物 |
| `│ ▼` | 流入下一步 |
| `├──` | 分支（多个可能结果） |
| `×N` | 运行 N 次（每个系统、每个故事等） |
| `（输入）` | 被 skill 读取但不在此产生 |
| `[可选]` | 门禁通过不要求此项 |
| `写入`（大写） | 文件立即写入磁盘 |

---

## 常见入口点

| 你在哪里 | 运行这个 |
|---------------|---------|
| 全新，没有想法 | `/start` → `/brainstorm` |
| 有概念，无引擎 | `/setup-engine` |
| 有概念 + 引擎 | `/map-systems` |
| 系统设计中途 | `/design-system [下一个系统]` 或 `/map-systems next` |
| 所有 GDD 完成 | `/review-all-gdds` → `/gate-check` |
| 在技术搭建中 | `/create-architecture` → `/architecture-decision` |
| 开始 UX 设计 | `/ux-design screen [名称]` 或 `/ux-design hud` |
| 搭建测试 | `/test-setup` → `/test-helpers` |
| 有故事，准备编码 | `/story-readiness [故事]` → `/dev-story [故事]` |
| 故事完成 | `/story-done [故事]` |
| 为 sprint 运行 QA | `/qa-plan` → `/smoke-check` → `/regression-suite` |
| Bug 积压需要整理 | `/bug-triage` |
| 扩展稳定性测试 | `/soak-test` |
| 不确定 | `/help` |
| 现有项目 | `/adopt` |
