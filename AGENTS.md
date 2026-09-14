<!-- 本文件由 tools/adapters/ 自动生成，请勿手动修改。
     修改规范源 .claude/ 后运行 python tools/adapters/sync_all.py 重新生成。 -->
# AGENTS.md — Claude Code Game Studios

适用于 **Codex**、**DeepSeek Harness（dsh）** 及所有读取 AGENTS.md 开放标准的 Agent 工具。
Claude Code 用户请继续使用 `CLAUDE.md`（规范源入口，本文件由其派生）。

## 语言要求

必须始终使用简体中文与用户对话，生成的文档与代码注释也必须使用简体中文编写。

## 项目概述

Claude Code Game Studios 通过 49 个协调的 AI Agent 管理独立游戏开发。
每个 Agent 负责一个特定领域，确保关注点分离和质量把控。

**核心理念：用户驱动的协作，而非自主执行。**

## 技术栈

- **引擎**：[选择：Godot 4 / Unity / Unreal Engine 5]
- **语言**：[选择：GDScript / C# / C++ / Blueprint]
- **版本控制**：Git，采用基于主干的开发模式

> 引擎一经选定，请同步配置 `.claude/docs/technical-preferences.md`，
> 并使用与引擎匹配的引擎专属 Agent 集合。

## Agent 花名册（49 个）

完整定义位于 `.claude/agents/`（每个 Agent 一个文件，含触发条件与协作协议）。

### 第一层 —— 领导层（Opus）（3 个）

| Agent | 职责 |
|---|---|
| `creative-director` | 创意总监是项目的最高创意权威。此 Agent 对游戏愿景、基调、美学方向做出具有约束力的决策，并解决设计、美术、叙事和音频各支柱之间的冲突。当某个决策影响游戏的根本定位，或各部门负责人无法达成共识时，使用此 Agent。 |
| `technical-director` | 技术总监负责所有高层级技术决策，包括引擎架构、技术选型、性能策略和技术风险管理。当需要架构级决策、技术评估、跨系统技术冲突，或技术选择将约束或开放设计可能性时，使用此 Agent。 |
| `producer` | 制作人管理所有制作相关事务：冲刺规划、里程碑追踪、风险管理、范围协商和跨部门协调。这是主要的协调 Agent。当工作需要规划、追踪、排定优先级，或多个部门需要同步时，使用此 Agent。 |

### 第二层 —— 部门负责人（Sonnet）（8 个）

| Agent | 职责 |
|---|---|
| `game-designer` | 游戏设计师负责游戏的机制和系统设计。此 Agent 设计核心循环、成长系统、战斗机制、经济系统和面向玩家的规则。当涉及"游戏在机制层面如何运作"的任何问题时，使用此 Agent。 |
| `lead-programmer` | 主程序员负责代码级架构、编码标准、代码审查以及将编程工作分配给专业程序员。当需要代码审查、API 设计、重构策略，或决定如何将设计转化为代码结构时，使用此 Agent。 |
| `art-director` | 美术总监负责游戏的视觉定位：风格指南、美术圣经、资源标准、调色板、UI/UX 视觉设计和美术制作管线。当需要视觉一致性审查、资源规格创建、美术圣经维护或 UI 视觉方向时，使用此 Agent。 |
| `audio-director` | 音频总监负责游戏的声音定位：音乐方向、音效设计哲学、音频实现策略和混音平衡。当需要音频方向决策、声音调色板定义、音乐提示规划或音频系统架构时，使用此 Agent。 |
| `narrative-director` | 叙事总监负责故事架构、世界构建、角色设计和对话策略。当需要故事弧线规划、角色发展、世界规则定义和叙事系统设计时，使用此 Agent。此 Agent 侧重于结构和方向，而非编写具体台词。 |
| `qa-lead` | QA负责人拥有测试策略、Bug分类、发布质量关卡和测试流程设计。使用此Agent进行测试计划创建、Bug严重程度评估、回归测试计划或发布就绪评估。 |
| `release-manager` | 负责发布流水线：认证检查清单、商店提交、平台要求、版本编号和发布日协调。用于发布计划、平台认证、商店页面准备或版本管理。 |
| `localization-lead` | 负责国际化架构、字符串管理、区域测试和翻译流水线。适用于 i18n 系统设计、字符串提取工作流、区域特定问题或翻译质量审查。 |

### 第三层 —— 专业 Agent（Sonnet / Haiku）（23 个）

| Agent | 职责 |
|---|---|
| `systems-designer` | Systems Designer 为特定游戏子系统创建详细的机制设计 —— 战斗公式、成长曲线、合成配方、状态效果交互。当某个机制需要详细的规则规范、数学建模或交互矩阵设计时，使用此 Agent。 |
| `level-designer` | Level Designer 为游戏关卡和区域创建空间设计、遭遇布局、节奏规划和环境叙事指南。使用此 Agent 进行关卡布局规划、遭遇设计、难度节奏或空间谜题设计。 |
| `economy-designer` | Economy Designer 专注于资源经济、战利品系统、成长曲线和游戏内市场设计。使用此 Agent 进行战利品表设计、资源产出/消耗分析、成长曲线校准或经济平衡验证。 |
| `gameplay-programmer` | Gameplay Programmer 负责将游戏机制、玩家系统、战斗和交互功能实现为代码。使用此 Agent 来实现已设计的机制、编写游戏系统代码，或将设计文档转化为可运行的游戏功能。 |
| `engine-programmer` | Engine Programmer 负责核心引擎系统：渲染管线、物理、内存管理、资源加载、场景管理和核心框架代码。使用此 Agent 实现引擎级功能、性能关键系统或核心框架修改。 |
| `ai-programmer` | AI Programmer 负责实现游戏 AI 系统：行为树、状态机、寻路、感知系统、决策制定和 NPC 行为。使用此 Agent 进行 AI 系统实现、寻路优化、敌人行为编程或 AI 调试。 |
| `network-programmer` | Network Programmer 负责实现多人游戏网络：状态复制、延迟补偿、匹配和网络协议设计。使用此 Agent 进行网络代码实现、同步策略、带宽优化或多人游戏架构设计。 |
| `tools-programmer` | Tools Programmer 负责构建内部开发工具：编辑器扩展、内容创作工具、调试工具和管线自动化。使用此 Agent 进行自定义工具创建、编辑器工作流改进或开发管线自动化。 |
| `ui-programmer` | UI Programmer 负责实现用户界面系统：菜单、HUD、库存界面、对话窗口和 UI 框架代码。使用此 Agent 进行 UI 系统实现、组件开发、数据绑定或界面流程编程。 |
| `technical-artist` | Technical Artist 连接美术与工程：着色器、VFX、渲染优化、美术管线工具和视觉系统的性能分析。使用此 Agent 进行着色器开发、VFX 系统设计、视觉优化或美术到引擎的管线问题。 |
| `sound-designer` | Sound Designer 为音效创建详细规格说明、记录音频事件并定义混音参数。使用此 Agent 进行 SFX 规格表、音频事件规划、混音文档或音频类别定义。 |
| `writer` | Writer 负责创作对话、传说条目、物品描述、环境文本和所有面向玩家的文字内容。使用此 Agent 进行对话写作、传说创作、物品/能力描述或任何类型的游戏内文本。 |
| `world-builder` | World Builder 负责设计详细的世界传说：阵营、文化、历史、地理、生态和游戏世界运行规则。使用此 Agent 进行传说一致性检查、阵营设计、历史时间线创建或世界规则编码。 |
| `qa-tester` | QA测试员编写详细的测试用例、Bug报告和测试检查清单。使用此Agent进行测试用例生成、回归检查清单创建、Bug报告编写或测试执行文档。 |
| `performance-analyst` | 性能分析师负责分析游戏性能、识别瓶颈、推荐优化方案并追踪长期性能指标。当需要进行性能分析、内存分析、帧时间调查或优化策略制定时，请使用此 Agent。 |
| `devops-engineer` | DevOps 工程师负责维护构建流水线、CI/CD 配置、版本控制工作流和部署基础设施。当需要构建脚本维护、CI 配置、分支策略或自动化测试流水线搭建时，请使用此 Agent。 |
| `analytics-engineer` | 分析工程师负责设计遥测系统、玩家行为追踪、A/B 测试框架和数据分析管道。当需要事件追踪设计、仪表盘规范、A/B 测试设计或玩家行为分析方法论时，请使用此 Agent。 |
| `ux-designer` | UX Designer 负责用户体验流程、交互设计、无障碍、信息架构和输入处理设计。使用此 Agent 进行用户流程映射、交互模式设计、无障碍审计或上手流程设计。 |
| `prototyper` | 原型制作专家。在工作流的两个节点构建一次性实现：(1) 概念原型在脑暴之后立即验证一个想法的趣味性，在编写 GDD 之前（/prototype），以及 (2) 在预生产阶段构建垂直切片以验证完整游戏循环，在投入 Production 之前（/vertical-slice）。标准有意放宽以追求速度。 |
| `security-engineer` | 安全工程师负责保护游戏免受作弊、漏洞利用和数据泄露的威胁。他们审查代码漏洞、设计反作弊措施、保护存档数据和网络通信安全，并确保玩家数据隐私合规。 |
| `accessibility-specialist` | 无障碍专家确保游戏可被尽可能广泛的受众游玩。他们执行无障碍标准、审查UI合规性，并设计辅助功能，包括按键重映射、文本缩放、色盲模式和屏幕阅读器支持。 |
| `live-ops-designer` | Live-ops Designer 负责上线后内容策略：季节性活动、战令、内容发布节奏、玩家留存机制、在线服务经济和参与度分析。确保游戏保持新鲜感且玩家保持参与度，同时避免掠夺性变现。 |
| `community-manager` | 社区经理负责面向玩家的沟通：补丁说明、社交媒体帖子、社区更新、玩家反馈收集、来自玩家的Bug报告分类和危机沟通。他们在开发团队和玩家社区之间进行翻译。 |

### 引擎负责人（与项目引擎匹配，Sonnet）（3 个）

| Agent | 职责 |
|---|---|
| `unreal-specialist` | Unreal Engine 专家是所有 Unreal 特定模式、API 和优化技术的权威。他们指导 Blueprint vs C++ 的决策，确保正确使用 UE 子系统（GAS、Enhanced Input、Common UI、Niagara 等），并在整个代码库中强制执行 Unreal 最佳实践。 |
| `unity-specialist` | Unity 引擎专家是所有 Unity 特定模式、API 和优化技术的权威。他们指导 MonoBehaviour vs DOTS/ECS 的决策，确保正确使用 Unity 子系统（Addressables、Input System、UI Toolkit 等），并强制执行 Unity 最佳实践。 |
| `godot-specialist` | Godot 引擎专家是所有 Godot 特定模式、API 和优化技术的权威。他们指导 GDScript vs C# vs GDExtension 的决策，确保正确使用 Godot 的节点/场景架构、信号和资源，并强制执行 Godot 最佳实践。 |

### Unreal Engine 子专业（Sonnet）（4 个）

| Agent | 职责 |
|---|---|
| `ue-gas-specialist` | Gameplay Ability System 专家负责所有 GAS 实现：能力、Gameplay Effects、Attribute Sets、Gameplay Tags、Ability Tasks 和 GAS 预测。他们确保一致的 GAS 架构并防止常见的 GAS 反模式。 |
| `ue-blueprint-specialist` | Blueprint 专家负责 Blueprint 架构决策、Blueprint/C++ 边界指南、Blueprint 优化，并确保 Blueprint 图保持可维护性和高性能。他们防止 Blueprint 意大利面条式代码并强制执行整洁的 BP 模式。 |
| `ue-replication-specialist` | UE 复制专家负责所有 Unreal 网络功能：属性复制、RPC、客户端预测、相关性、网络序列化和带宽优化。他们确保服务器权威架构和响应式的多人游戏体验。 |
| `ue-umg-specialist` | UMG/CommonUI 专家负责所有 Unreal UI 实现：控件层级、数据绑定、CommonUI 输入路由、控件样式和 UI 优化。他们确保 UI 遵循 Unreal 最佳实践并表现良好。 |

### Unity 子专业（Sonnet）（4 个）

| Agent | 职责 |
|---|---|
| `unity-dots-specialist` | DOTS/ECS 专家负责所有 Unity 数据导向技术栈的实现：Entity Component System 架构、Jobs 系统、Burst 编译器优化、混合渲染器以及基于 DOTS 的游戏系统。他们确保正确的 ECS 模式和最大性能。 |
| `unity-shader-specialist` | Unity Shader/VFX 专家负责所有 Unity 渲染定制：Shader Graph、自定义 HLSL 着色器、VFX Graph、渲染管线定制（URP/HDRP）、后处理和视觉效果优化。他们确保在性能预算内的视觉质量。 |
| `unity-addressables-specialist` | Addressables 专家负责所有 Unity 资产管理：Addressable 组、资产加载/卸载、内存管理、内容目录、远程内容分发和 Asset Bundle 优化。他们确保快速加载时间和内存使用受控。 |
| `unity-ui-specialist` | Unity UI 专家负责所有 Unity UI 实现：UI Toolkit（UXML/USS）、UGUI（Canvas）、数据绑定、运行时 UI 性能、输入处理和跨平台 UI 适配。他们确保构建响应式、高性能和可访问的 UI。 |

### Godot 子专业（Sonnet）（4 个）

| Agent | 职责 |
|---|---|
| `godot-gdscript-specialist` | GDScript 专家负责所有 GDScript 代码质量：静态类型强制执行、设计模式、信号架构、协程模式、性能优化和 GDScript 特定习语。他们确保整个项目中编写出整洁、类型化、高性能的 GDScript。 |
| `godot-csharp-specialist` | Godot C# 专家负责 Godot 4 项目中的所有 C# 代码质量：.NET 模式、基于属性的导出、信号委托、异步模式、类型安全的节点访问以及 C# 特定的 Godot 习语。他们确保编写出整洁、高性能、类型安全的 C# 代码，正确遵循 .NET 和 Godot 4 习语。 |
| `godot-shader-specialist` | Godot Shader 专家负责所有 Godot 渲染定制：Godot 着色语言、可视化着色器、材质设置、粒子着色器、后处理和渲染性能。他们确保在 Godot 渲染管线内的视觉质量。 |
| `godot-gdextension-specialist` | GDExtension 专家负责所有与 Godot 的原生代码集成：GDExtension API、C/C++/Rust 绑定（godot-cpp、godot-rust）、原生性能优化、自定义节点类型以及 GDScript/原生边界。他们确保原生代码与 Godot 的节点系统干净地集成。 |

## 协调规则

1. 纵向委派，不可越级：上层可向下层委派，禁止越级向下委派
2. 横向协商，无单方面决定权：同层 Agent 通过协商解决跨领域问题
3. 冲突由上一层级仲裁：同层协商 → 上级仲裁 → 用户最终决策
4. 变更须传播：设计/架构变更须传播到所有受影响方（见 /propagate-design-change）
5. 禁止单方面跨领域变更：不得修改不属于自己领域的文件

详细规则见 `.claude/docs/coordination-rules.md`。

## 协作协议

**用户驱动的协作，而非自主执行。** 每个任务遵循五步流程：
1. **提问** — Agent 在提出解决方案前先提问，理解用户意图
2. **呈现选项** — Agent 展示 2-4 个选项及其优缺点
3. **决策** — 用户始终掌握决策权
4. **草稿** — Agent 在最终确认前展示成果
5. **审批** — 未经用户签字确认，不写入任何内容

关键约束：
- Agent 在使用写入/编辑工具前必须询问："我可以将此写入 [文件路径] 吗？"
- Agent 在请求审批前必须展示草稿或摘要
- 多文件修改需要针对完整变更集的明确审批
- 未经用户指示不得进行提交

完整协议见 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`。

## 技能 / 工作流（73 个）

技能定义位于 `.claude/skills/<技能名>/SKILL.md`（Agent Skills 开放标准格式，
Codex / dsh / Trae 等可直接读取）。按开发阶段分类：

### 概念阶段

- /brainstorm — 使用 MDA、动词优先和玩家心理学框架探索游戏概念
- /setup-engine — 配置引擎、锁定版本、设置命名约定和性能预算
- /brainstorm — 正式确定概念，包含支柱、MDA 分析和范围层级
- /design-review — 验证游戏概念（建议在继续前执行）
- /art-bible — 编写视觉识别规范（9 个章节）。使用 /brainstorm 生成的视觉识别锚点。在游戏概念形成之后、系统设计之前运行。
- /map-systems — 将概念分解为系统，包含依赖排序和优先级层级

### 系统设计阶段

- /design-system — 编写逐系统 GDD（引导式，逐章编写）。每个系统运行一次。
- /design-review — 验证每个 GDD（8 个必需章节，不得出现 MAJOR REVISION 判定）。每个系统运行。
- /review-all-gdds — 同时对所有 GDD 进行整体一致性检查 + 设计理论审查
- /consistency-check — 扫描所有 GDD 中的矛盾、未定义引用和机制冲突。在 /review-all-gdds 之后运行，在项目中期每次添加或修订 GDD 时再次运行。

### 技术设置阶段

- /create-architecture — 编写涵盖所有系统的主架构文档
- /architecture-decision — 将关键技术决策记录为 ADR。最低需要 3 个 Foundation 层 ADR。
- /architecture-review — 验证完整性、依赖排序、引擎兼容性
- /create-control-manifest — 从所有已接受的 ADR 生成平面程序员规则表

### 预生产阶段

- /asset-spec — 枚举游戏视觉上需要的一切：实体（角色、敌人、建筑、环境部件）、UI 界面、HUD 元素、面板。不带参数运行 /asset-spec 可启动协作清单会话 — 根据你的回答选择简要或详细。读取 GDD 和美术圣经以提出起始列表；你添加、删除和调整。成为所有美术和 UX 工作的真实数据源。如果游戏只有极少数视觉元素，则非必需。
- /asset-spec — 生成单个资源的视觉规范和 AI 生成提示。每个实体、系统、关卡或角色运行一次。如果不存在源文档，/asset-spec 会内联询问你 — 无需叙事文档。
- /ux-design — 为实体清单（或 GDD，如果没有清单）中识别的界面编写 UX 规范。最低要求：主菜单、核心玩法 HUD、暂停菜单。根据清单识别结果添加更多界面。从 technical-preferences.md 读取输入方式和平台信息。
- /ux-review — 验证所有关键界面的 UX 规范是否符合 GDD 对齐度和无障碍等级要求。在创建 Epic 之前运行。
- /prototype — 构建一次性原型以在全面投入生产前验证核心机制是否有趣。推荐用于首次尝试的机制或高风险设计决策。已验证概念的个人开发者可以跳过。
- /create-epics — 将 GDD + ADR 转化为 Epic — 每个架构模块一个 Epic。按层运行：/create-epics layer: foundation，然后 /create-epics layer: core
- /create-stories — 将每个 Epic 分解为可实现的 Story 文件。每个 Epic 运行：/create-stories [epic-slug]
- /test-setup — 在第一个 Sprint 之前一次性搭建测试框架和 CI 管线。之后可运行 /test-helpers 生成 Fixture、/qa-plan 按 Epic 生成测试计划、/smoke-check 按 Sprint 验证。
- /sprint-plan — 使用从 Epic 中优先排序的 Story 规划第一个 Sprint
- /vertical-slice — 构建并试玩垂直切片 — 核心循环的完整端到端体验。推荐在提交 Epic 和 Story 到 Production 之前执行。跳过是个人开发者的有效选择，但会增加后期设计转向的风险。如果构建了，必须在推进前试玩并记录。

### 生产阶段

- /sprint-plan — 使用优先级排序的就绪 Story 规划当前 Sprint
- /story-readiness — 在开发人员领取之前验证 Story 是否可实现
- /dev-story — 领取下一个就绪 Story 并使用 /dev-story [story-path] 实现它。路由到正确的程序员 Agent。
- /code-review — 每个 Story 实现后的架构级代码审查。在 /dev-story 之后、/story-done 之前运行。
- /story-done — 验证所有验收标准、检查 GDD/ADR 偏差、关闭 Story
- /qa-plan — 为每个 Epic 或 Sprint 生成 QA 测试计划。运行 /qa-plan [epic-slug]。为 /smoke-check、/regression-suite 和 /test-evidence-review 生成测试用例。
- /bug-report — 记录并优先级排序实现过程中发现的 Bug。/bug-report 创建结构化的报告；/bug-triage 对未解决积压进行优先级排序。
- /retrospective — Sprint 后审查，捕捉有效的做法和需要改变的地方。在每个 Sprint 结束时、规划下一个 Sprint 之前运行。
- /scope-check — 通过比较当前 Sprint 范围与原始 Epic 范围来检测范围蔓延。在以下情况运行：(a) Story 在 Sprint 中途被添加时，或 (b) Sprint 回顾之前。
- /sprint-status — 无需完整报告的 Sprint 进度快速 30 行快照

### 打磨阶段

- /perf-profile — 分析和优化 CPU/GPU/内存瓶颈
- /balance-check — 分析游戏平衡公式和数据，查找异常值和断裂的成长曲线
- /asset-audit — 验证命名约定、文件格式标准和大小预算
- /playtest-report — 覆盖：新玩家体验、中期系统、难度曲线
- /team-polish — 跨性能、音频、视觉和 UX 的协调打磨遍历

### 发布阶段

- /release-checklist — 跨所有部门的发布前验证：代码、内容、商店、法律
- /patch-notes — 从 git 历史记录和 Sprint 数据生成面向玩家的更新说明
- /changelog — 从 commits、Sprint 和设计文档自动生成内部变更日志
- /launch-checklist — 最终发布就绪度 — 交付给玩家前的最后一道关卡

### 其他技能

- /adopt — 棕地项目上线 — 审计现有项目制品是否符合模板格式规范（不仅仅是检查是否存在），按影响程度分类差距，并生成编号的迁移计划。在加入进行中的项目或从旧模板版本升级时运行此技能。与 /project-stage-detect 不同（后者检查存在什么） — 此技能检查存在的东西是否能与模板的技能实际协同工作。
- /bug-triage — 读取 production/qa/bugs/ 中所有未解决的 bug，重新评估优先级与严重程度，分配到 Sprint，发现系统性趋势，并生成分类报告。在 Sprint 开始或 bug 数量增长到需要重新排序时运行。
- /content-audit — 将 GDD 中指定的内容数量与实际实现的内容进行审计。识别计划内容与已构建内容的差异。
- /day-one-patch — 生成发布日补丁检查清单——审核发布候选版的质量、优化状态和准备就绪性。在第一个候选版本标记后立即运行。
- /estimate — 通过分析复杂度、依赖关系、历史速度和风险因素来估算任务工作量。生成带有置信度等级的结构化估算。
- /gate-check — 阶段门禁评估——关于项目是否准备好进入下一个开发阶段的正式裁决。检查每个阶段的设计完整性。
- /help — 分析已完成的工作和用户查询，提供下一步该做什么的建议。当用户说'我接下来该做什么'、'现在我该做什么'、'我卡住了'或'我不知道该做什么'时使用
- /hotfix — 绕过正常冲刺流程的紧急修复工作流，带有完整的审计追踪。创建修复分支、跟踪审批并确保正确的向下合并修复。
- /localize — 从游戏源文件生成供翻译使用的本地化资源文件，并将翻译后的本地化数据重新应用于游戏。将所有外部本地化文件聚合到引擎的本地化管道中。支持 po、csv、xliff、json 和 csv 格式。
- /milestone-review — 根据里程碑目标进行全面的进度审计。测量完成百分比，比较估算 vs 实际，并识别未来工作的风险。
- /onboard — 为加入项目的新贡献者或 Agent 生成上下文化的入职文档。总结与指定角色或领域相关的项目状态、架构、规范和当前优先级。
- /project-stage-detect — 自动分析项目状态、检测阶段、识别差距并根据现有产物推荐后续步骤。当用户问'项目开发到哪个阶段了'、'我们在什么阶段'、'完整的项目审计'时使用。
- /propagate-design-change — 当设计文档发生变更时，分析该变更对相关系统、故事、依赖项、资产和平衡的下游影响，以保持一致性。
- /quick-design — 快速地、针对特定问题或微小功能进行轻量级设计——不可替代正式的设计评审。输出是草图，而非规范。
- /regression-suite — 从受影响的故事内容和风险区域生成针对性回归测试计划。检查来源以识别覆盖缺口，并报告风险矩阵。
- /reverse-document — 从现有实现生成设计或架构文档。从代码/原型反向工作，以创建缺失的规划文档。
- /security-audit — 审计游戏的安全漏洞：存档篡改、作弊途径、网络漏洞利用、数据泄露和输入验证缺陷。生成带有修复指导的优先级安全报告。在任何公开发布或多人游戏上线前运行。
- /skill-improve — 使用测试-修复-重测循环改进一个 Skill。运行静态检查，提出针对性修复，重写 Skill，重新测试，根据分数变化决定保留或回滚。
- /skill-test — 验证 Skill 文件的结构合规性和行为正确性。三种模式：static（性能检查器）、spec（行为验证）、audit（覆盖率报告）。
- /smoke-check — 在 QA 移交前运行关键路径冒烟测试关卡。执行自动化测试套件，验证核心功能，并生成 PASS/FAIL 报告。在 Sprint 的故事实现完成后、手动 QA 开始前运行。冒烟检查失败意味着构建版本未准备好进入 QA。
- /soak-test — 生成长时间游戏会话的浸泡测试协议。定义在长时游玩中观察、测量和记录的内容，以发现仅在持续游玩后才会出现的缓慢泄漏、疲劳效应和边缘情况。主要用于打磨和发布阶段。
- /start — 首次上手引导 — 询问你在哪里，然后引导你进入正确的工作流程。不做任何假设。
- /team-audio — 编排音频团队：audio-director + sound-designer + technical-artist + gameplay-programmer 实现从方向到实现的完整音频管线。
- /team-combat — 编排战斗团队：协调 game-designer、gameplay-programmer、ai-programmer、technical-artist、sound-designer 和 qa-tester，端到端地设计、实现和验证一个战斗功能。
- /team-level — 编排关卡设计团队：level-designer + narrative-director + world-builder + art-director + systems-designer + qa-tester 进行完整的区域/关卡创作。
- /team-live-ops — 编排线上运营团队进行发布后内容规划：协调 live-ops-designer、economy-designer、analytics-engineer、community-manager、writer 和 narrative-director 来设计和规划一个赛季、活动或线上内容更新。
- /team-narrative — 编排叙事团队：协调 narrative-director、writer、world-builder 和 level-designer 来创建 cohesive 的故事内容、世界传说和叙事驱动的关卡设计。
- /team-qa — 编排 QA 团队进行全面的 Sprint 质量验证：协调 qa-lead、qa-tester、bug-triage Agent 和 performance-analyst，对当前 Sprint 故事执行端到端 QA 流水线。
- /team-release — 编排发布团队：协调 release-manager、qa-lead、devops-engineer 和 producer 将发布版本从候选版推向部署。
- /team-ui — 编排 UI 团队完成完整 UX 管线：从 UX 规格创作到视觉设计、实现、审查和打磨。集成 /ux-design、/ux-review 和工作室 UX 模板。
- /tech-debt — 跟踪、分类和优先排序全代码库的技术债务。扫描债务指标，维护债务登记册，推荐偿还排期。
- /test-evidence-review — 从测试结果文件生成测试证据摘要。解析测试 XML、提取通过率和覆盖报告，并与 CI 日志交叉引用以识别不一致处。提供结构化摘要，不修改原始文件，不重复已存在的 CI 总结。
- /test-flakiness — 通过读取 CI 运行日志或测试结果历史来检测非确定性（不稳定）测试。汇总每个测试的通过率，识别间歇性失败，推荐隔离或修复方案，维护不稳定测试登记册。最好在打磨阶段或多次 CI 运行后使用。
- /test-helpers — 为各引擎生成测试辅助函数（模拟器、工厂函数、固定装置、存根）。创建适合项目引擎和测试框架的辅助函数。在设置测试基础设施时运行。

## 编码规范

- 游戏性数值必须数据驱动（外部配置文件），绝不可硬编码
- 所有依赖时间的计算必须使用 delta time（帧率无关）
- 使用事件/信号进行跨系统通信，禁止直接引用 UI 代码
- 测试遵循 AAA 模式，逻辑与表现分离，位于 `tests/` 目录
- 提交必须引用相关的 Story ID 或设计文档
- 路径范围规则见 `.claude/rules/`（gameplay / engine / ui / network / shader 等分类）

## 平台能力差异（降级说明）

以下功能为 Claude Code 专属，在本平台以降级形式提供：

| 功能 | 降级方式 |
|---|---|
| Hook 自动验证（提交/推送/资产校验） | 提交前人工执行 `bash .claude/hooks/validate-commit.sh` 等检查 |
| 权限控制（settings.json） | 遵守下方"安全注意事项"文档指令 |
| 模型层级分配（Opus/Sonnet/Haiku） | 所有任务使用平台默认模型 |
| 子 Agent 自动派发 | 通过 `.claude/agents/` 定义 + 技能工作流模拟（dsh 原生支持子代理委派） |

## 安全注意事项

- 禁止执行 `rm -rf`、`git push --force`、`git reset --hard`、`sudo` 等危险命令
- 禁止读取或写入 `.env` 及任何含密钥/令牌的文件
- 敏感信息禁止硬编码，一律通过环境变量注入
- 未经用户明确指示不得进行 git 提交或推送

## 维护

修改规范源 `.claude/` 后运行：

```
python tools/adapters/sync_all.py
```
