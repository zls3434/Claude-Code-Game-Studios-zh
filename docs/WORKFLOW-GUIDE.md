<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 工作流指南

## 工作流目录

Skill 按项目阶段组织。此目录定义每个阶段可用的内容
以及 Skill 之间的依赖关系。

---

## 概念阶段

定义游戏是高概念还是低概念。建立创作支柱。生成并选择核心概念。

| 优先级 | Skill | 用途 | 输入 | 输出 | 依赖项 | 可重复 |
|----------|-------|---------|-------|--------|--------------|----------|
| 必需 | `/start` | 引导式项目搭建 | — | `.claude/docs/technical-preferences.md`、`.claude/docs/directory-structure.md`、`production/review-mode.txt` | — | 否 |
| 必需 | `/brainstorm` | MDA 脑暴框架，概念生成与选择 | 创意种子 / 类型 | `design/concept.md` | 如果先于 `/start`，则需引擎配置 | 是 |
| 可选 | `/prototype` | 在动手编码前快速验证概念 | 概念文档，检查点 | `prototypes/[名称]/` 含 README.md、运行日志 | `/brainstorm`（相同概念） | 是 |

**概念关卡：** `/gate-check concept`
- 检验本阶段所有必需 Skill 是否已完成。不要求 Skill 间顺序。
- 验证 `design/concept.md` 存在并已填充。

---

## 系统设计阶段

定义游戏系统、实体、关系。在编写代码前建立公式和规则。

| 优先级 | Skill | 用途 | 输入 | 输出 | 依赖项 | 可重复 |
|----------|-------|---------|-------|--------|--------------|----------|
| 必需 | `/map-systems` | 实体发现、分层、关系定义 | concept.md | `design/gdd/systems-index.md`、`design/glossary/`、`design/registry/entities.yaml`（填充） | `/brainstorm` | 是 |
| 必需 | `/design-system` | 引导式 8 部分 GDD 创作（逐个系统） | map-systems 输出、entities.yaml、glossary | `design/gdd/[系统].md`（8 个部分均已填充） | `/map-systems` | 是（每个系统一次） |
| 必需 | `/review-all-gdds` | ⭐ 跨 GDD 交叉验证（一致性 + 需求完整性） | 全部 GDD、entities.yaml、glossary | 发现矩阵、修复确认 | `/map-systems` + 所有 `/design-system` 运行 | 是 |
| 可选 | `/consistency-check` | 在发现矩阵上按行修复 | review-all-gdds 发现项、entities.yaml | entities.yaml 更新（实体、公式、常量）、审查的 GDD | 发现矩阵 | 是（每个发现项重复） |

**系统设计关卡：** `/gate-check systems`
- 检验本阶段前 3 个必需 Skill 是否已完成（`/map-systems`、`/design-system`、`/review-all-gdds`）。
  `/consistency-check` 可延迟。
- 验证 `design/gdd/systems-index.md` 存在，至少 1 个系统 GDD 已填充。

---

## 技术准备阶段

定义引擎、编码规范。创建美术圣经和视觉识别。

| 优先级 | Skill | 用途 | 输入 | 输出 | 依赖项 | 可重复 |
|----------|-------|---------|-------|--------|--------------|----------|
| 必需 | `/setup-engine` | 引导式引擎选择与版本偏好设置 | — | `.claude/docs/technical-preferences.md`、`.claude/docs/coding-standards.md`、`docs/engine-reference/` 文件 | — | 是（选择后可不重新运行） |
| 必需 | `/art-bible` | ⭐ 引导式逐节视觉识别创作（9 章节） | concept.md | `design/visual/art-bible.md`（所有章节已填充） | `/brainstorm` | 更新时是 |

**技术准备关卡：** `/gate-check tech-ready`
- 检验本阶段所有必需 Skill 是否已完成。不要求 Skill 间顺序。
- 验证 `docs/engine-reference/` 可读，引擎偏好已填充。
- 验证 `design/visual/art-bible.md` 存在并包含所有 9 个章节。
- 验证 `design/concept.md` 中视觉识别锚存在（若从 `/brainstorm` 阶段 7 设置）。

---

## 架构阶段

定义编码架构、执行计划、工作跟踪设置。

| 优先级 | Skill | 用途 | 输入 | 输出 | 依赖项 | 可重复 |
|----------|-------|---------|-------|--------|--------------|----------|
| 必需 | `/architecture-decision` | 引导式 ADR 创作 | GDD、system-design 输出、coding-standards（架构约束） | `docs/architecture/adr-###-[slug].md`、`docs/architecture/tr-registry.yaml`（更新） | `/design-system`（相关系统） | 是 |
| 必需 | `/create-architecture` | ⭐ 批量 ADR 生成整个分层代码架构 | 全部 GDD、systems-index、coding-standards | 所有 ADR、meta-ADR、control-manifest.md、tr-registry.yaml（填充）、layout-guide.md | `/design-system`（所有系统 GDD） | 是 |
| 可选 | `/architecture-review` | 跨 ADR 和 GDD 验证 | 所有 ADR、所有 GDD、systems-index | 审查通行证、tr-registry.yaml（更新） | `/create-architecture` | 是 |

**架构关卡：** `/gate-check architecture`
- 检验本阶段所有必需 Skill 是否已完成。不要求 Skill 间顺序。
- 验证至少 1 个 ADR 存在，`docs/architecture/control-manifest.md` 存在且 `docs/architecture/tr-registry.yaml` 已填充。

---

## 预生产阶段

创建资产规格、Epic 和故事。准备实现。

| 优先级 | Skill | 用途 | 输入 | 输出 | 依赖项 | 可重复 |
|----------|-------|---------|-------|--------|--------------|----------|
| 必需 | `/asset-spec` | 每个资产可视化规格 + AI 生成提示词 | art-bible、GDD、关卡/角色文档 | `design/assets/specs/[资产名].md`、`design/assets/asset-manifest.md`（更新） | `/art-bible`、GDD | 是（每个资产一次） |
| 可选 | `/create-epics` | 将设计文档映射到史诗级工作 | 所有 GDD、architecture 决策、tr-registry | `production/epics/[epic-slug]/epic-summary.md` | `/create-architecture` | 是 |
| 可选 | `/create-stories` | 从 Epic 生成实现故事 | Epic 摘要、架构决策 | `production/epics/[epic-slug]/story-[NNN]-[slug].md` | `/create-epics`（相关 Epic） | 是 |

**预生产关卡：** `/gate-check pre-production`
- 检验本阶段所有必需 Skill 是否已完成。不要求 Skill 间顺序。
- 验证 `design/assets/asset-manifest.md` 存在。
- 验证所有 GDD 的 `§8 验收标准` 已填充。

---

## 生产阶段

编写代码、运行测试、跟踪进度。

| 优先级 | Skill | 用途 | 输入 | 输出 | 依赖项 | 可重复 |
|----------|-------|---------|-------|--------|--------------|----------|
| 可选 | `/sprint-plan` | 按优先级整理故事 | 故事（可选）、milestone（可选） | `production/sprints/sprint-[NNN].md` | 故事列表 | 是 |
| 必需 | `/story-done` | ⭐ 故事结束完成握手（写入故事文件，Gate 审查） | 故事文件 + 实现 | 故事文件已更新（阶段 1-8） | GDD、ADR、tr-registry、control-manifest、stories、stories-index | 是（每个故事一次） |
| 可选 | `/testing-sprint` | 测试冲刺规划 | 故事、milestone | `production/testing/[测试计划]` | sprint-plan 输出 | 是 |
| 可选 | `/milestone-review` | 里程碑收尾仪式 | 故事文件、milestone 文件、ADR、控制清单 | 审查发现项、里程碑文件更新（Gate 裁决）、stories-index 更新 | `/sprint-plan`、`/story-done`（所有故事） | 是 |
| 可选 | `/playtest-report` | ⭐ 结构化游戏测试报告 | 游戏测试会话观察 | `tests/playtest/playtest-[日期].md` | 可玩构建 | 是 |

**生产关卡：** `/gate-check production`
- 检验通过 `gate-check full` 进行所有导演的审查，其中包括代码审查和故事索引交叉引用。

---

## 打磨阶段

漏洞追踪、优化冲刺。

| 优先级 | Skill | 用途 | 输入 | 输出 | 依赖项 | 可重复 |
|----------|-------|---------|-------|--------|--------------|----------|
| 可选 | `/optimization-sprint` | 性能基准与优化规划 | 构建、剖析数据 | `production/optimization/[计划]` | 可玩构建 | 是 |
| 必需 | `/polish-round` | ⭐ 从 backlog 选取事项并写为行动卡 | 事项列表，类型标签 | `production/polish-backlog/[类型]/cards/` | 清单源文件 | 是（每轮一次） |

**打磨关卡：** `/gate-check polish`
- 验证优化回归阈值通过 + 清单重新评分分数改善或稳定。

---

## 技能概览

| 技能名称 | 阶段 | 参数提示 | 可重复 | 要求 |
|------------|-------|----------------|------------|-----------|
| `/start` | 概念 | — | 否 | — |
| `/brainstorm` | 概念 | `<创意/类型/种子>` | 是 | 无（但需引擎配置） |
| `/prototype` | 概念 | `<概念名称或ID> [检查点] [--review <模式>]` | 是 | `/brainstorm` |
| `/map-systems` | 系统设计 | — | 是 | `/brainstorm` |
| `/design-system` | 系统设计 | `<系统名称>` | 是 | `/map-systems` |
| `/review-all-gdds` | 系统设计 | — | 是 | `/map-systems` + 至少一次 `/design-system` |
| `/consistency-check` | 系统设计 | `<发现项ID>` | 是 | `/review-all-gdds` |
| `/setup-engine` | 技术准备 | `--lang <语言>` | 否 | `/start` |
| `/art-bible` | 技术准备 | `[章节编号]` | 是 | `/brainstorm` |
| `/architecture-decision` | 架构 | `<子系统>` | 是 | `/design-system` |
| `/create-architecture` | 架构 | `[--system <名称>] [--skip-existing]` | 是 | 所有 GDD |
| `/architecture-review` | 架构 | — | 是 | 所有 ADR + 所有 GDD |
| `/asset-spec` | 预生产 | `<资产名称>` | 是 | `/art-bible`、相关 GDD |
| `/create-epics` | 预生产 | `[系统]` | 是 | 架构决策 |
| `/create-stories` | 预生产 | `<史诗>` | 是 | Epic |
| `/vertical-slice` | 预生产 | `<目标功能或循环>` | 是 | `/brainstorm` |
| `/story-done` | 生产 | `<故事ID>` | 是 | GDD、ADR、tr-registry、控制清单、故事索引 |
| `/sprint-plan` | 生产 | `[故事列表]` | 是 | Epic + 故事文件 |
| `/milestone-review` | 生产 | `<里程碑>` | 是 | 该里程碑的所有故事均已完成 |
| `/playtest-report` | 生产 | — | 是 | 可玩构建 |
| `/testing-sprint` | 生产 | `<范围> [策略]` | 是 | `/sprint-plan` |
| `/optimization-sprint` | 打磨 | `[剖析数据]` | 是 | 可玩构建 |
| `/polish-round` | 打磨 | `<类型标签>` | 是 | 清单源文件 |
| `/project-stage-detect` | 全局 | — | 是 | — |
| `/gate-check` | 全局 | `<关卡名称> [--review full|lean|solo]` | 是 | — |

---

## 常见模式

### MVP 模式

最小可行路径：

```
/brainstorm <创意>
  → /map-systems
  → /design-system <核心系统>
  → /setup-engine
  → /create-architecture
  → /create-epics
  → /create-stories
  → /sprint-plan
  → /story-done（每个故事）
```

### 扩展模式

单个系统的端到端：

```
/brainstorm <创意>
  → /map-systems
  → /design-system <系统>
  → /architecture-decision <系统>
  → /create-epics <系统>
  → /create-stories <史诗>
  → /story-done <故事-ID>
```

### 迭代模式

对一个系统重复设计：

```
/brainstorm          ← 仅在需要新创意时重新运行
  → /map-systems     ← 添加系统时更新
  → /design-system   ← 反馈后重新运行
  → /review-all-gdds ← 设计系统后重新运行
  → /architecture-decision ← 需要新 ADR 时重新运行
```

### 批量模式

规划大量工作时：

```
/create-architecture  ← 在开始编码前生成所有 ADR
  → /create-epics      ← 按系统（多个 Epic）或一次全部
  → /create-stories    ← 批量生成所有故事
  → /sprint-plan       ← 根据容量安排多个 Sprint
```
