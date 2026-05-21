<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# 可用技能（斜杠命令）

73 个斜杠命令，按阶段组织。在 Claude Code 中输入 `/` 即可使用任意命令。

## 入门与导航

| 命令 | 用途 |
|---------|---------|
| `/start` | 首次入门引导 — 询问你所在位置，然后引导你进入正确的工作流 |
| `/help` | 上下文感知的"我接下来该做什么？" — 读取当前阶段并呈现所需的下一步 |
| `/project-stage-detect` | 完整项目审计 — 检测阶段、识别存在差距、推荐下一步 |
| `/setup-engine` | 配置引擎 + 版本、检测知识差距、填充版本感知的参考文档 |
| `/adopt` | 棕地格式审计 — 检查现有 GDD/ADR/Story 的内部结构，生成迁移计划 |

## 游戏设计

| 命令 | 用途 |
|---------|---------|
| `/brainstorm` | 使用专业工作室方法论（MDA、SDT、Bartle、动词优先）进行引导式构思 |
| `/map-systems` | 将游戏概念分解为系统、映射依赖关系、优先排序设计顺序 |
| `/design-system` | 为单个游戏系统引导逐章编写 GDD |
| `/quick-design` | 适用于小型变更的轻量级设计规范 — 调优、微调、小型添加 |
| `/review-all-gdds` | 跨越所有设计文档的一致性检查和游戏设计整体性审查 |
| `/propagate-design-change` | 当 GDD 被修订时，找到受影响的 ADR 并生成影响报告 |

## 美术与资源

| 命令 | 用途 |
|---------|---------|
| `/art-bible` | 引导逐章编写美术圣经 — 在资源制作开始前创建视觉识别规范 |
| `/asset-spec` | 从 GDD、关卡文档或角色简档生成单个资源的视觉规范和 AI 生成提示 |
| `/asset-audit` | 审计资源的命名约定、文件大小预算和管线合规性 |

## UX 与界面设计

| 命令 | 用途 |
|---------|---------|
| `/ux-design` | 引导逐章编写 UX 规范（界面/流程、HUD 或交互模式库） |
| `/ux-review` | 验证 UX 规范的 GDD 对齐度、无障碍性和模式合规性 |

## 架构

| 命令 | 用途 |
|---------|---------|
| `/create-architecture` | 引导编写主架构文档 |
| `/architecture-decision` | 创建一个架构决策记录（ADR） |
| `/architecture-review` | 验证所有 ADR 的完整性、依赖排序和 GDD 覆盖率 |
| `/create-control-manifest` | 从已接受的 ADR 生成平面程序员规则表 |

## Story 与 Sprint

| 命令 | 用途 |
|---------|---------|
| `/create-epics` | 将 GDD + ADR 转化为 Epic — 每个架构模块一个 Epic |
| `/create-stories` | 将单个 Epic 分解为可实现的 Story 文件 |
| `/dev-story` | 读取一个 Story 并实现它 — 路由到正确的程序员 Agent |
| `/sprint-plan` | 生成或更新 Sprint 计划；初始化 sprint-status.yaml |
| `/sprint-status` | 快速 30 行 Sprint 快照（读取 sprint-status.yaml） |
| `/story-readiness` | 在开发领取前验证 Story 是否就绪（READY/NEEDS WORK/BLOCKED） |
| `/story-done` | 实现后 8 阶段完成审查；更新 Story 文件，呈现下一个 Story |
| `/estimate` | 结构化的工时估算，包含复杂度、依赖关系和风险分解 |

## 审查与分析

| 命令 | 用途 |
|---------|---------|
| `/design-review` | 审查游戏设计文档的完整性和一致性 |
| `/code-review` | 对文件或变更集的架构级代码审查 |
| `/balance-check` | 分析游戏数值平衡数据、公式和配置 — 标记异常值 |
| `/content-audit` | 审计 GDD 指定的内容数量与已实现的内容 |
| `/scope-check` | 分析功能或 Sprint 范围与原始计划的偏差，标记范围蔓延 |
| `/perf-profile` | 结构化的性能分析，包含瓶颈识别 |
| `/tech-debt` | 扫描、追踪、优先级排序和报告技术债务 |
| `/gate-check` | 验证在各开发阶段之间推进的就绪度（PASS/CONCERNS/FAIL） |
| `/consistency-check` | 扫描所有 GDD 并对照实体注册表检测跨文档不一致（相互冲突的数值、名称、规则） |
| `/security-audit` | 审计游戏的安全漏洞：存档篡改、作弊向量、网络漏洞、数据暴露和输入验证差距 |

## QA 与测试

| 命令 | 用途 |
|---------|---------|
| `/qa-plan` | 为 Sprint 或功能生成 QA 测试计划 |
| `/smoke-check` | 在 QA 交接前运行关键路径冒烟测试关卡 |
| `/soak-test` | 为持续游戏会话生成浸泡测试协议 |
| `/regression-suite` | 将测试覆盖率映射到 GDD 关键路径，识别缺少回归测试的已修复 Bug |
| `/test-setup` | 为项目引擎搭建测试框架和 CI/CD 管线 |
| `/test-helpers` | 为测试套件生成引擎特定的测试辅助库 |
| `/test-evidence-review` | 测试文件和手动证据文档的质量审查 |
| `/test-flakiness` | 从 CI 运行日志中检测不确定性（不稳定）测试 |
| `/skill-test` | 验证技能文件的结构合规性和行为正确性 |
| `/skill-improve` | 使用测试-修复-重测循环改进技能 — 诊断、提出修复、重写、验证 |

## 制作

| 命令 | 用途 |
|---------|---------|
| `/milestone-review` | 审查里程碑进度并生成状态报告 |
| `/retrospective` | 运行结构化的 Sprint 或里程碑回顾 |
| `/bug-report` | 创建结构化的 Bug 报告 |
| `/bug-triage` | 读取所有未解决的 Bug，重新评估优先级 vs 严重性，分配负责人和标签 |
| `/reverse-document` | 从现有实现生成设计或架构文档 |
| `/playtest-report` | 生成结构化的试玩报告或分析现有试玩笔记 |

## 发布

| 命令 | 用途 |
|---------|---------|
| `/release-checklist` | 为当前构建生成并验证发布前检查清单 |
| `/launch-checklist` | 跨所有部门的完整发布就绪度验证 |
| `/changelog` | 从 git 提交和 Sprint 数据自动生成变更日志 |
| `/patch-notes` | 从 git 历史记录和内部数据生成面向玩家的更新说明 |
| `/hotfix` | 带审计追踪的紧急修复工作流，绕过正常的 Sprint 流程 |
| `/day-one-patch` | 为 Gold Master 之后、公开发布之前或发布时发现的已知问题准备聚焦的首日补丁 |

## 创意与内容

| 命令 | 用途 |
|---------|---------|
| `/prototype` | 概念原型 — 脑暴后直接进行的一次性构建，用于验证核心想法（第一阶段） |
| `/vertical-slice` | 预生产验证 — 在全面投入生产前的生产级端到端构建（第四阶段） |
| `/onboard` | 为新贡献者或 Agent 生成上下文化的入职文档 |
| `/localize` | 本地化工作流：字符串提取、验证、翻译就绪度 |

## 团队编排

协调多个 Agent 处理单个功能领域：

| 命令 | 协调的 Agent |
|---------|-------------|
| `/team-combat` | game-designer + gameplay-programmer + ai-programmer + technical-artist + sound-designer + qa-tester |
| `/team-narrative` | narrative-director + writer + world-builder + level-designer |
| `/team-ui` | ux-designer + ui-programmer + art-director + accessibility-specialist |
| `/team-release` | release-manager + qa-lead + devops-engineer + producer |
| `/team-polish` | performance-analyst + technical-artist + sound-designer + qa-tester |
| `/team-audio` | audio-director + sound-designer + technical-artist + gameplay-programmer |
| `/team-level` | level-designer + narrative-director + world-builder + art-director + systems-designer + qa-tester |
| `/team-live-ops` | live-ops-designer + economy-designer + community-manager + analytics-engineer |
| `/team-qa` | qa-lead + qa-tester + gameplay-programmer + producer |
