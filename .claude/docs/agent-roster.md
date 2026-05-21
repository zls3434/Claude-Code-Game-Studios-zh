<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Agent 名单

以下 Agent 可供使用。每个 Agent 在 `.claude/agents/` 目录下都有独立的定义文件。
请使用最适合当前任务的 Agent。当任务跨越多个领域时，协调 Agent（通常是 `producer` 或
领域负责人）应将任务委派给各专业 Agent。

## 第一层 —— 领导层 Agent（Opus）
| Agent | 领域 | 使用场景 |
|-------|--------|-------------|
| `creative-director` | 高层次愿景 | 重大创意决策、支柱冲突、基调/方向把控 |
| `technical-director` | 技术愿景 | 架构决策、技术栈选择、性能策略 |
| `producer` | 制作管理 | Sprint 规划、里程碑追踪、风险管理、协调统筹 |

## 第二层 —— 部门负责人 Agent（Sonnet）
| Agent | 领域 | 使用场景 |
|-------|--------|-------------|
| `game-designer` | 游戏设计 | 机制、系统、进程、经济、数值平衡 |
| `lead-programmer` | 代码架构 | 系统设计、代码审查、API 设计、重构 |
| `art-director` | 视觉指导 | 风格指南、美术圣经、资源标准、UI/UX 指导 |
| `audio-director` | 音频指导 | 音乐方向、音效调色板、音频实现策略 |
| `narrative-director` | 故事与写作 | 故事弧线、世界观构建、角色设计、对白策略 |
| `qa-lead` | 质量保证 | 测试策略、Bug 分类、发布就绪度、回归规划 |
| `release-manager` | 发布管线 | 构建管理、版本管理、变更日志、部署、回滚 |
| `localization-lead` | 国际化 | 字符串外部化、翻译管线、区域测试 |

## 第三层 —— 专业 Agent（Sonnet 或 Haiku）
| Agent | 领域 | 模型 | 使用场景 |
|-------|--------|-------|-------------|
| `systems-designer` | 系统设计 | Sonnet | 具体机制实现、公式设计、循环系统 |
| `level-designer` | 关卡设计 | Sonnet | 关卡布局、节奏控制、遭遇设计、流程设计 |
| `economy-designer` | 经济/数值 | Sonnet | 资源经济、掉落表、成长曲线 |
| `gameplay-programmer` | 玩法代码 | Sonnet | 功能实现、玩法系统代码 |
| `engine-programmer` | 引擎系统 | Sonnet | 核心引擎、渲染、物理、内存管理 |
| `ai-programmer` | AI 系统 | Sonnet | 行为树、寻路、NPC 逻辑、状态机 |
| `network-programmer` | 网络 | Sonnet | 网络代码、同步复制、延迟补偿、匹配系统 |
| `tools-programmer` | 开发工具 | Sonnet | 编辑器扩展、管线工具、调试工具 |
| `ui-programmer` | UI 实现 | Sonnet | UI 框架、界面、组件、数据绑定 |
| `technical-artist` | 技术美术 | Sonnet | Shader、VFX、优化、美术管线工具 |
| `sound-designer` | 音效设计 | Sonnet | SFX 设计文档、音频事件列表、混音笔记 |
| `writer` | 对白/背景 | Sonnet | 对白编写、背景条目、物品描述 |
| `world-builder` | 世界观/背景设计 | Sonnet | 世界规则、派系设计、历史、地理 |
| `qa-tester` | 测试执行 | Haiku | 编写测试用例、Bug 报告、测试清单 |
| `performance-analyst` | 性能分析 | Sonnet | 性能分析、优化建议、内存分析 |
| `devops-engineer` | 构建/部署 | Haiku | CI/CD、构建脚本、版本控制工作流 |
| `analytics-engineer` | 数据埋点 | Sonnet | 事件追踪、数据看板、A/B 测试设计 |
| `ux-designer` | UX 流程 | Sonnet | 用户流程、线框图、无障碍、输入处理 |
| `prototyper` | 快速原型 | Sonnet | 一次性原型、机制测试、可行性验证 |
| `security-engineer` | 安全 | Sonnet | 反作弊、漏洞防护、存档加密、网络安全 |
| `accessibility-specialist` | 无障碍 | Haiku | WCAG 合规、色盲模式、按键映射、文字缩放 |
| `live-ops-designer` | 线上运营 | Sonnet | 赛季、活动、通行证、留存、线上经济 |
| `community-manager` | 社区 | Haiku | 更新日志、玩家反馈、危机沟通、社区健康度 |

## 引擎专属 Agent（使用与你的引擎匹配的集合）

### 引擎负责人

| Agent | 引擎 | 模型 | 使用场景 |
| ---- | ---- | ---- | ---- |
| `unreal-specialist` | Unreal Engine 5 | Sonnet | Blueprint vs C++、GAS 概览、UE 子系统、Unreal 优化 |
| `unity-specialist` | Unity | Sonnet | MonoBehaviour vs DOTS、Addressables、URP/HDRP、Unity 优化 |
| `godot-specialist` | Godot 4 | Sonnet | GDScript 模式、节点/场景架构、信号、Godot 优化 |

### Unreal Engine 子专业 Agent

| Agent | 子系统 | 模型 | 使用场景 |
| ---- | ---- | ---- | ---- |
| `ue-gas-specialist` | Gameplay Ability System | Sonnet | 技能、玩法效果、属性集、标签、预测 |
| `ue-blueprint-specialist` | Blueprint 架构 | Sonnet | BP/C++ 边界、图表规范、命名、BP 优化 |
| `ue-replication-specialist` | 网络/同步复制 | Sonnet | 属性复制、RPC、预测、相关性、带宽 |
| `ue-umg-specialist` | UMG/CommonUI | Sonnet | 组件层级、数据绑定、CommonUI 输入、UI 性能 |

### Unity 子专业 Agent

| Agent | 子系统 | 模型 | 使用场景 |
| ---- | ---- | ---- | ---- |
| `unity-dots-specialist` | DOTS/ECS | Sonnet | Entity Component System、Jobs、Burst 编译器、混合渲染器 |
| `unity-shader-specialist` | Shader/VFX | Sonnet | Shader Graph、VFX Graph、URP/HDRP 定制、后处理 |
| `unity-addressables-specialist` | 资源管理 | Sonnet | Addressable 分组、异步加载、内存、内容分发 |
| `unity-ui-specialist` | UI Toolkit/UGUI | Sonnet | UI Toolkit、UXML/USS、UGUI Canvas、数据绑定、跨平台输入 |

### Godot 子专业 Agent

| Agent | 子系统 | 模型 | 使用场景 |
| ---- | ---- | ---- | ---- |
| `godot-gdscript-specialist` | GDScript | Sonnet | 静态类型、设计模式、信号、协程、GDScript 性能 |
| `godot-csharp-specialist` | C# / .NET | Sonnet | .NET 模式、[Signal] 委托、async、可空类型、类型安全节点访问 |
| `godot-shader-specialist` | Shader/渲染 | Sonnet | Godot 着色语言、可视化 Shader、粒子、后处理 |
| `godot-gdextension-specialist` | GDExtension | Sonnet | C++/Rust 绑定、原生性能、自定义节点、构建系统 |
