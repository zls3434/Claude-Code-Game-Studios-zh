<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# 游戏工作室 Agent 架构 —— 快速入门指南

## 这是什么？

这是一套完整的 Claude Code Agent 架构，用于游戏开发。它将 49 个专业 AI Agent
组织成一个反映真实游戏开发团队的工作室层级结构，具有明确的职责、委派规则和协调协议。
包含面向 Godot、Unity 和 Unreal 的引擎专业 Agent —— 每个引擎都有针对主要引擎子系统的
专属子专业 Agent。所有设计 Agent 和模板都基于成熟的游戏设计理论（MDA 框架、
自我决定理论、心流状态、Bartle 玩家类型）。使用与你的项目匹配的引擎集合。

## 如何使用

### 1. 理解层级结构

共有三个层级的 Agent：

- **第一层（Opus）**：做出高层次决策的总监
  - `creative-director` — 愿景和创意冲突解决
  - `technical-director` — 架构和技术决策
  - `producer` — 排期、协调和风险管理

- **第二层（Sonnet）**：拥有各自领域自主权的部门负责人
  - `game-designer`、`lead-programmer`、`art-director`、`audio-director`、
    `narrative-director`、`qa-lead`、`release-manager`、`localization-lead`

- **第三层（Sonnet/Haiku）**：在各自领域内执行的专业人员
  - 设计师、程序员、美术师、作家、测试员、工程师

### 2. 为任务选择合适的 Agent

问问自己："在一个真正的工作室里，应该由哪个部门来处理这件事？"

| 我需要... | 使用这个 Agent |
|-------------|---------------|
| 设计一个新机制 | `game-designer` |
| 编写战斗代码 | `gameplay-programmer` |
| 创建一个 Shader | `technical-artist` |
| 编写对白 | `writer` |
| 规划下一个 Sprint | `producer` |
| 审查代码质量 | `lead-programmer` |
| 编写测试用例 | `qa-tester` |
| 设计一个关卡 | `level-designer` |
| 修复性能问题 | `performance-analyst` |
| 搭建 CI/CD | `devops-engineer` |
| 设计掉落表 | `economy-designer` |
| 解决创意冲突 | `creative-director` |
| 做出架构决策 | `technical-director` |
| 管理发布 | `release-manager` |
| 为翻译准备字符串 | `localization-lead` |
| 快速测试一个机制想法 | `prototyper` |
| 审查代码安全隐患 | `security-engineer` |
| 检查无障碍合规 | `accessibility-specialist` |
| 获取 Unreal Engine 建议 | `unreal-specialist` |
| 获取 Unity 建议 | `unity-specialist` |
| 获取 Godot 建议 | `godot-specialist` |
| 设计 GAS 技能/效果 | `ue-gas-specialist` |
| 定义 BP/C++ 边界 | `ue-blueprint-specialist` |
| 实现 UE 网络同步 | `ue-replication-specialist` |
| 构建 UMG/CommonUI 组件 | `ue-umg-specialist` |
| 设计 DOTS/ECS 架构 | `unity-dots-specialist` |
| 编写 Unity Shader/VFX | `unity-shader-specialist` |
| 管理 Addressable 资源 | `unity-addressables-specialist` |
| 构建 UI Toolkit/UGUI 界面 | `unity-ui-specialist` |
| 编写地道的 GDScript | `godot-gdscript-specialist` |
| 编写 Godot C# 代码 | `godot-csharp-specialist` |
| 创建 Godot Shader | `godot-shader-specialist` |
| 构建 GDExtension 模块 | `godot-gdextension-specialist` |
| 规划线上活动和赛季 | `live-ops-designer` |
| 为玩家编写更新日志 | `community-manager` |
| 头脑风暴一个新游戏创意 | 使用 `/brainstorm` 技能 |

### 3. 使用斜杠命令处理常见任务

| 命令 | 功能 |
|---------|-------------|
| `/start` | 首次入门引导 — 询问你所在位置，引导你进入正确的工作流 |
| `/help` | 上下文感知的"我接下来该做什么？" — 读取你当前的阶段和产出物 |
| `/project-stage-detect` | 分析项目状态、检测阶段、识别差距 |
| `/setup-engine` | 配置引擎 + 版本，填充参考文档 |
| `/adopt` | 对现有项目进行棕地审计并生成迁移计划 |
| `/brainstorm` | 从零开始引导游戏概念构思 |
| `/map-systems` | 将概念分解为系统、映射依赖关系、引导逐系统 GDD 编写 |
| `/design-system` | 为单个游戏系统引导逐章编写 GDD |
| `/quick-design` | 适用于小型变更的轻量级规范 — 调优、微调、小型添加 |
| `/review-all-gdds` | 跨越所有 GDD 的一致性检查和游戏设计理论审查 |
| `/propagate-design-change` | 找到受 GDD 变更影响的 ADR 和故事 |
| `/art-bible` | 引导逐章编写美术圣经 — 在资源制作前创建视觉识别规范 |
| `/asset-spec` | 从 GDD 或角色简档生成单个资源的视觉规范和 AI 生成提示 |
| `/ux-design` | 编写 UX 规范（界面/流程、HUD、交互模式） |
| `/ux-review` | 验证 UX 规范的无障碍性和 GDD 对齐度 |
| `/create-architecture` | 为游戏编写主架构文档 |
| `/architecture-decision` | 创建一个 ADR |
| `/architecture-review` | 验证所有 ADR、依赖排序、GDD 可追溯性 |
| `/create-control-manifest` | 从已接受的 ADR 生成平面程序员规则表 |
| `/create-epics` | 将 GDD + ADR 转化为 Epic（每个架构模块一个 Epic） |
| `/create-stories` | 将单个 Epic 分解为可实现的 Story 文件 |
| `/dev-story` | 读取一个 Story 并实现它 — 路由到正确的程序员 Agent |
| `/sprint-plan` | 创建或更新 Sprint 计划 |
| `/sprint-status` | 快速 30 行 Sprint 快照 |
| `/story-readiness` | 在开发领取前验证 Story 是否就绪 |
| `/story-done` | Story 完成后的结束审查 — 验证验收标准 |
| `/estimate` | 产出结构化的工作量估算 |
| `/design-review` | 审查设计文档 |
| `/code-review` | 审查代码质量和架构 |
| `/balance-check` | 分析游戏数值平衡数据 |
| `/asset-audit` | 审计资源合规性 |
| `/content-audit` | GDD 指定的内容 vs 已实现的内容 — 发现差距 |
| `/scope-check` | 检测相对于计划的蔓延 |
| `/perf-profile` | 性能分析和瓶颈识别 |
| `/tech-debt` | 扫描、追踪和优先级排序技术债务 |
| `/gate-check` | 验证阶段就绪度（PASS/CONCERNS/FAIL） |
| `/consistency-check` | 扫描所有 GDD 的跨文档不一致问题（冲突的数值、名称、规则） |
| `/security-audit` | 审计安全漏洞：存档篡改、作弊向量、网络漏洞、数据暴露 |
| `/reverse-document` | 从现有代码生成设计/架构文档 |
| `/milestone-review` | 审查里程碑进度 |
| `/retrospective` | 运行 Sprint/里程碑回顾 |
| `/bug-report` | 创建结构化的 Bug 报告 |
| `/playtest-report` | 创建或分析试玩反馈 |
| `/onboard` | 为某个角色生成入职文档 |
| `/release-checklist` | 验证发布前检查清单 |
| `/launch-checklist` | 完整的发布就绪度验证 |
| `/changelog` | 从 Git 历史生成变更日志 |
| `/patch-notes` | 生成面向玩家的更新说明 |
| `/hotfix` | 带审计追踪的紧急修复 |
| `/day-one-patch` | 为首日已知问题准备聚焦的首日补丁 |
| `/prototype` | 概念原型 — 在编写 GDD 前验证核心想法（第一阶段） |
| `/vertical-slice` | 生产级端到端构建 — 在全面生产前验证完整游戏循环（第四阶段） |
| `/localize` | 本地化扫描、提取、验证 |
| `/team-combat` | 编排完整的战斗团队管线 |
| `/team-narrative` | 编排完整的叙事团队管线 |
| `/team-ui` | 编排完整的 UI 团队管线 |
| `/team-release` | 编排完整的发布团队管线 |
| `/team-polish` | 编排完整的打磨团队管线 |
| `/team-audio` | 编排完整的音频团队管线 |
| `/team-level` | 编排完整的关卡创建管线 |
| `/team-live-ops` | 编排线上运营团队：赛季、活动和发布后内容 |
| `/team-qa` | 编排完整的 QA 团队周期 — 测试计划、测试用例、冒烟测试、签收 |
| `/qa-plan` | 为 Sprint 或功能生成 QA 测试计划 |
| `/bug-triage` | 重新优先排序未解决的 Bug，分配到 Sprint，呈现系统性问题趋势 |
| `/smoke-check` | 在 QA 交接前运行关键路径冒烟测试关卡 |
| `/soak-test` | 为持续游戏会话生成浸泡测试协议 |
| `/regression-suite` | 将覆盖率映射到 GDD 关键路径、标记差距、维护回归套件 |
| `/test-setup` | 为项目引擎搭建测试框架 + CI 管线（仅运行一次） |
| `/test-helpers` | 生成引擎特定的测试辅助库和工厂函数 |
| `/test-flakiness` | 从 CI 历史中检测不稳定的测试，标记隔离或修复 |
| `/test-evidence-review` | 测试文件和手动证据的质量审查 — ADEQUATE/INCOMPLETE/MISSING |
| `/skill-test` | 验证技能文件的合规性和正确性（静态/规范/审计） |
| `/skill-improve` | 使用测试-修复-重测循环改进技能 — 诊断、提出修复、重写、验证 |

### 4. 使用模板创建新文档

模板位于 `.claude/docs/templates/`：

- `game-design-document.md` — 用于新机制和系统
- `architecture-decision-record.md` — 用于技术决策
- `architecture-traceability.md` — 将 GDD 需求映射到 ADR 和 Story ID
- `risk-register-entry.md` — 用于新增风险
- `narrative-character-sheet.md` — 用于新增角色
- `test-plan.md` — 用于功能测试计划
- `sprint-plan.md` — 用于 Sprint 规划
- `milestone-definition.md` — 用于新增里程碑
- `level-design-document.md` — 用于新增关卡
- `game-pillars.md` — 用于核心设计支柱
- `art-bible.md` — 用于视觉风格参考
- `technical-design-document.md` — 用于每个系统的技术设计
- `post-mortem.md` — 用于项目/里程碑复盘
- `sound-bible.md` — 用于音频风格参考
- `release-checklist-template.md` — 用于平台发布检查清单
- `changelog-template.md` — 用于面向玩家的更新说明
- `release-notes.md` — 用于面向玩家的发布说明
- `incident-response.md` — 用于线上事故响应手册
- `game-concept.md` — 用于初始游戏概念（MDA、SDT、心流、Bartle）
- `pitch-document.md` — 用于向利益相关者推介游戏
- `economy-model.md` — 用于虚拟经济设计（源头/消耗模型）
- `faction-design.md` — 用于派系身份、背景和玩法角色
- `systems-index.md` — 用于系统分解和依赖映射
- `project-stage-report.md` — 用于项目阶段检测输出
- `design-doc-from-implementation.md` — 用于将现有代码反向文档化为 GDD
- `architecture-doc-from-code.md` — 用于将代码反向文档化为架构文档
- `concept-doc-from-prototype.md` — 用于将原型反向文档化为概念文档
- `ux-spec.md` — 用于每个界面的 UX 规范（布局区域、状态、事件）
- `hud-design.md` — 用于整体游戏的 HUD 理念、区域和元素规范
- `accessibility-requirements.md` — 用于项目级无障碍等级和功能矩阵
- `interaction-pattern-library.md` — 用于标准 UI 控件和游戏特定交互模式
- `player-journey.md` — 用于 6 阶段情感曲线和按时间尺度的留存钩子
- `difficulty-curve.md` — 用于难度轴、新手引导曲线和跨系统交互
- `test-evidence.md` — 用于记录手动测试证据的模板（截图、走查笔记）

也在 `.claude/docs/templates/collaborative-protocols/` 中（由 Agent 使用，通常不直接编辑）：

- `design-agent-protocol.md` — 设计 Agent 的"提问-选项-草稿-批准"周期
- `implementation-agent-protocol.md` — 编程 Agent 的"Story 领取到 /story-done"周期
- `leadership-agent-protocol.md` — 总监层 Agent 的跨部门委派和上报机制

### 5. 遵循协调规则

1. 工作沿着层级向下流动：总监 -> 负责人 -> 专业人员
2. 冲突沿着层级向上上报
3. 跨部门工作由 `producer` 协调
4. Agent 未经委派不得修改其领域外的文件
5. 所有决策均需文档化记录

## 新项目的第一步

**不知道从哪里开始？** 运行 `/start`。它会询问你所在的位置并引导你进入正确的工作流。
不会对你的游戏、引擎或经验水平做任何假设。

如果你已经知道自己需要什么，可以直接跳到对应的路径：

### 路径 A："我不知道要做什么"

1. **运行 `/start`**（或 `/brainstorm open`）— 引导式创意探索：
   什么让你兴奋、你玩过什么、你的限制条件
   - 生成 3 个概念，帮助你选择其一，定义核心循环和支柱
   - 产出一个游戏概念文档并推荐一个引擎
2. **配置引擎** — 运行 `/setup-engine`（使用脑暴推荐的结果）
   - 配置 CLAUDE.md、检测知识差距、填充参考文档
   - 创建 `.claude/docs/technical-preferences.md`，包含命名约定、
     性能预算和引擎特定默认值
   - 如果引擎版本比 LLM 的训练数据更新，它会从网上获取当前文档，
     使 Agent 能够推荐正确的 API
3. **验证概念** — 运行 `/design-review design/gdd/game-concept.md`
4. **分解为系统** — 运行 `/map-systems` 映射所有系统和依赖关系
5. **设计每个系统** — 运行 `/design-system [system-name]`（或 `/map-systems next`）
   按依赖顺序编写 GDD
6. **制作机制原型** — 运行 `/prototype [core-mechanic]`（1-3 天 — 在编写 GDD 之前）
7. **设计每个系统** — 运行 `/design-system [system-name]` 编写 GDD，受原型发现启发
8. **规划第一个 Sprint** — 架构和 `/vertical-slice` 之后，运行 `/sprint-plan new`
9. 开始构建

### 路径 B："我知道我想做什么"

如果你已经有了游戏概念和引擎选择：

1. **配置引擎** — 运行 `/setup-engine [engine] [version]`
   （例如：`/setup-engine godot 4.6`）— 同时创建技术偏好设置
2. **编写游戏支柱** — 委派给 `creative-director`
3. **分解为系统** — 运行 `/map-systems` 枚举系统和依赖关系
4. **设计每个系统** — 运行 `/design-system [system-name]` 按依赖顺序编写 GDD
5. **创建初始 ADR** — 运行 `/architecture-decision`
6. **创建第一个里程碑**，放在 `production/milestones/`
7. **规划第一个 Sprint** — 运行 `/sprint-plan new`
8. 开始构建

### 路径 C："我知道游戏但不知道引擎"

如果你有概念但不知道哪个引擎合适：

1. **运行 `/setup-engine`** 不带参数 — 它会询问你的游戏需求
   （2D/3D、平台、团队规模、语言偏好）并根据你的回答推荐引擎
2. 从路径 B 的第 2 步继续

### 路径 D："我有一个现有项目"

如果你已经有设计文档、原型或代码：

1. **运行 `/start`**（或 `/project-stage-detect`）— 分析已有内容、
   识别差距并推荐下一步
2. **运行 `/adopt`** 如果你已有 GDD、ADR 或 Story — 审计
   内部格式合规性并构建编号的迁移计划以填补差距，
   不会覆盖你已有的工作
3. **按需配置引擎** — 如果尚未配置，运行 `/setup-engine`
4. **验证阶段就绪度** — 运行 `/gate-check` 了解你的当前位置
5. **规划下一个 Sprint** — 运行 `/sprint-plan new`

## 文件结构参考

```
CLAUDE.md                          -- 主配置（请先阅读此文件，约 60 行）
.claude/
  settings.json                    -- Claude Code Hook 和项目设置
  agents/                          -- 49 个 Agent 定义（YAML 前置元数据）
  skills/                          -- 73 个斜杠命令定义（YAML 前置元数据）
  hooks/                           -- 12 个 Hook 脚本 (.sh)，由 settings.json 配置
  rules/                           -- 11 个路径特定规则文件
  docs/
    quick-start.md                 -- 本文件
    technical-preferences.md       -- 项目特定标准（由 /setup-engine 填充）
    coding-standards.md            -- 编码和设计文档标准
    coordination-rules.md          -- Agent 协调规则
    context-management.md          -- 上下文预算和压缩指令
    directory-structure.md         -- 项目目录布局
    workflow-catalog.yaml          -- 7 个阶段的管线定义（由 /help 读取）
    setup-requirements.md          -- 系统先决条件（Git Bash、jq、Python）
    settings-local-template.md     -- 个人 settings.local.json 指南
    templates/                     -- 41 个文档模板
```
