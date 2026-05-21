---
name: start
description: "首次上手引导 — 询问你在哪里，然后引导你进入正确的工作流程。不做任何假设。"
argument-hint: "[无参数]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 引导式上手

此 Skill 写入一个文件：`production/review-mode.txt`（在第 3b 阶段设置的审查模式配置）。

此 Skill 是新用户的入口点。它**不会**假设你有游戏想法、引擎偏好或任何先前经验。它先询问，然后将你引导到正确的工作流程。

---

## 第 1 阶段：检测项目状态

在询问任何事之前，静默收集上下文，以便量身定制你的指导。不要主动展示这些结果 — 它们为推荐提供信息，而非对话开场。

检查：
- **引擎是否已配置？** 读取 `.claude/docs/technical-preferences.md`。如果 Engine 字段包含 `[TO BE CONFIGURED]`，引擎未设置。
- **游戏概念是否存在？** 检查 `design/gdd/game-concept.md`。
- **源代码是否存在？** Glob `src/` 中的源文件（`*.gd`、`*.cs`、`*.cpp`、`*.h`、`*.rs`、`*.py`、`*.js`、`*.ts`）。
- **原型是否存在？** 检查 `prototypes/` 中的子目录。
- **设计文档是否存在？** 统计 `design/gdd/` 中的 Markdown 文件数。
- **生产产物？** 检查 `production/sprints/` 或 `production/milestones/` 中的文件。

将这些发现内部存储，以验证用户的自我评估并调整推荐。

---

## 第 2 阶段：询问用户所在位置

这是用户看到的第一件事。使用 `AskUserQuestion` 配合这些确切选项，让用户可以点击而非输入：

- **Prompt**："欢迎来到 Claude Code Game Studios！在我建议任何事之前，我想了解你的起点。你的游戏想法目前处于什么阶段？"
- **Options**：
  - `A) 还没有想法` — 我完全没有游戏概念。我想探索和弄清楚要做什么。
  - `B) 模糊想法` — 我有一个大致主题、感觉或类型（如"太空相关"或"温馨农场游戏"），但没有具体内容。
  - `C) 清晰概念` — 我知道核心想法 — 类型、基本机制，也许有一句定位 — 但还没有正式文档化。
  - `D) 已有工作` — 我已经有设计文档、原型、代码或重要的规划。我想组织或继续工作。

等待用户的选择。在他们回复之前不要继续。

---

## 第 3 阶段：根据答案路由

#### 如果 A：还没有想法

用户在进行任何其他操作之前需要创意探索。

1. 确认从零开始完全没有问题
2. 简要解释 `/brainstorm` 做什么（使用专业框架的引导式概念生成 — MDA、玩家心理学、动词优先设计）。提到它有两种模式：`/brainstorm open` 用于完全开放的探索，或者 `/brainstorm [hint]` 如果他们即使只有一个模糊主题（如"太空"、"温馨"、"恐怖"）
3. 推荐运行 `/brainstorm open` 作为下一步，但如果他们想到什么可以邀请他们使用提示
4. 展示推荐路径：
   **概念阶段：**
   - `/brainstorm open` — 发现你的游戏概念
   - `/setup-engine` — 配置引擎（brainstorm 会推荐一个）
   - `/prototype` — 丢弃式概念构建：在设计前验证核心想法是否有趣（1–3 天）
   - `/art-bible` — 定义视觉身份（使用 brainstorm 生成的 Visual Identity Anchor）
   - `/map-systems` — 将概念分解为系统
   - `/design-system` — 为每个 MVP 系统编写 GDD
   - `/review-all-gdds` — 跨系统一致性检查
   - `/gate-check` — 在架构工作前验证准备就绪
   **架构阶段：**
   - `/create-architecture` — 生成主架构蓝图和必需 ADR 列表
   - `/architecture-decision (×N)` — 记录关键技术决策，遵循必需 ADR 列表
   - `/create-control-manifest` — 将决策编译为可操作规则表
   - `/architecture-review` — 验证架构覆盖率
   **预生产阶段：**
   - `/ux-design` — 编写关键界面的 UX 规格（主菜单、HUD、核心交互）
   - `/vertical-slice` — 生产质量的端到端构建以验证完整游戏循环
   - `/playtest-report (×1+)` — 记录每次垂直切片试玩会话
   - `/create-epics` — 将系统映射为 Epics
   - `/create-stories` — 将 Epics 分解为可实现的故事
   - `/sprint-plan` — 规划第一个 Sprint
   **生产阶段：** → 使用 `/dev-story` 选取故事

#### 如果 B：模糊想法

1. 请他们分享模糊想法 — 即使几个词也足够
2. 验证该想法作为一个起点（不要评判或改向）
3. 推荐运行 `/brainstorm [他们的提示]` 来发展它
4. 展示推荐路径：
   **概念阶段：**
   - `/brainstorm [hint]` — 将想法发展为完整概念
   - `/setup-engine` — 配置引擎
   - `/prototype` — 丢弃式概念构建：在设计前验证核心想法是否有趣（1–3 天）
   - `/art-bible` — 定义视觉身份（使用 brainstorm 生成的 Visual Identity Anchor）
   - `/map-systems` — 将概念分解为系统
   - `/design-system` — 为每个 MVP 系统编写 GDD
   - `/review-all-gdds` — 跨系统一致性检查
   - `/gate-check` — 在架构工作前验证准备就绪
   **架构阶段：**
   - `/create-architecture` — 生成主架构蓝图和必需 ADR 列表
   - `/architecture-decision (×N)` — 记录关键技术决策，遵循必需 ADR 列表
   - `/create-control-manifest` — 将决策编译为可操作规则表
   - `/architecture-review` — 验证架构覆盖率
   **预生产阶段：**
   - `/ux-design` — 编写关键界面的 UX 规格（主菜单、HUD、核心交互）
   - `/vertical-slice` — 生产质量的端到端构建以验证完整游戏循环
   - `/playtest-report (×1+)` — 记录每次垂直切片试玩会话
   - `/create-epics` — 将系统映射为 Epics
   - `/create-stories` — 将 Epics 分解为可实现的故事
   - `/sprint-plan` — 规划第一个 Sprint
   **生产阶段：** → 使用 `/dev-story` 选取故事

#### 如果 C：清晰概念

1. 请他们用一句话描述他们的概念 — 类型和核心机制。使用纯文本，而非 AskUserQuestion（这是开放式回答）。
2. 确认概念后，使用 `AskUserQuestion` 提供两条路径：
   - **Prompt**："你想如何继续？"
   - **Options**：
     - `先正式化` — 运行 `/brainstorm [concept]` 将其构建为正式的游戏概念文档
     - `直接开始` — 现在运行 `/setup-engine`，之后再手动编写 GDD
3. 展示推荐路径：
   **概念阶段：**
   - `/brainstorm` 或 `/setup-engine` —（步骤 2 中他们的选择）
   - `/prototype` — 丢弃式概念构建：在设计前验证核心想法是否有趣（1–3 天）
   - `/art-bible` — 定义视觉身份（在运行 brainstorm 后，或在概念文档存在后）
   - `/design-review` — 验证概念文档
   - `/map-systems` — 将概念分解为独立系统
   - `/design-system` — 为每个 MVP 系统编写 GDD
   - `/review-all-gdds` — 跨系统一致性检查
   - `/gate-check` — 在架构工作前验证准备就绪
   **架构阶段：**
   - `/create-architecture` — 生成主架构蓝图和必需 ADR 列表
   - `/architecture-decision (×N)` — 记录关键技术决策，遵循必需 ADR 列表
   - `/create-control-manifest` — 将决策编译为可操作规则表
   - `/architecture-review` — 验证架构覆盖率
   **预生产阶段：**
   - `/ux-design` — 编写关键界面的 UX 规格（主菜单、HUD、核心交互）
   - `/vertical-slice` — 生产质量的端到端构建以验证完整游戏循环
   - `/playtest-report (×1+)` — 记录每次垂直切片试玩会话
   - `/create-epics` — 将系统映射为 Epics
   - `/create-stories` — 将 Epics 分解为可实现的故事
   - `/sprint-plan` — 规划第一个 Sprint
   **生产阶段：** → 使用 `/dev-story` 选取故事

#### 如果 D：已有工作

1. 分享在第 1 阶段发现的内容：
   - "我可以看到你有 [X 个源文件 / Y 个设计文档 / Z 个原型]..."
   - "你的引擎 [已配置为 X / 尚未配置]..."

2. **子情况 D1 — 早期阶段**（引擎未配置或仅存在游戏概念）：
   - 如果引擎未配置，推荐先运行 `/setup-engine`
   - 然后运行 `/project-stage-detect` 进行缺口盘点

   **子情况 D2 — GDD、ADR 或故事已存在：**
   - 解释："有文件不等同于模板的 Skill 能够使用它们。GDD 可能缺少必需的部分。`/adopt` 专门检查这一点。"
   - 推荐：
     1. `/project-stage-detect` — 理解当前阶段以及完全缺失的内容
     2. `/adopt` — 审计现有产物是否采用正确的内部格式

3. 展示 D2 的推荐路径：
   - `/project-stage-detect` — 阶段检测 + 存在缺口
   - `/adopt` — 格式合规审计 + 迁移计划
   - `/setup-engine` — 如果引擎未配置
   - `/design-system retrofit [path]` — 填补缺失的 GDD 部分
   - `/architecture-decision retrofit [path]` — 添加缺失的 ADR 部分
   - `/architecture-review` — 启动 TR 需求注册表
   - `/gate-check` — 验证下一阶段的准备就绪

---

## 第 3c 阶段：写入初始阶段文件

确认起始路径后（询问审查模式之前），将初始阶段写入 `production/stage.txt`。如果 `production/` 目录不存在则创建它。

阶段映射：
- **路径 A、B 或 C（从头开始）**：写入 `Concept`
- **路径 D，已有项目，引擎未配置或仅存在游戏概念**：写入 `Concept`
- **路径 D，已有项目，有 GDD 但无架构文档**：写入 `Systems Design`
- **路径 D，已有项目，有完整架构（ADR、架构文档）**：写入 `Technical Setup`

静默执行 — 对这个单行文件不需要"我可以写入吗？"。

提示："我已将 `production/stage.txt` 设置为 `[stage]` — 这锁定了你的状态行和阶段检测。"

---

## 第 3b 阶段：设置审查模式

检查 `production/review-mode.txt` 是否已存在。

**如果存在**：读取并显示当前模式 — "审查模式已设置为 `[current]`。" — 然后继续第 4 阶段。不再询问。

**如果不存在**：使用 `AskUserQuestion`：

- **Prompt**："一个设置选择：在工作流程中你希望多少设计审查？"
- **Options**：
  - `Full` — 主管专家在每个关键工作流程步骤进行审查。最适合团队、学习工作流程或当你希望每个决策都有全面反馈时。
  - `Lean（推荐）` — 主管仅在阶段关卡过渡时介入（/gate-check）。跳过每个 Skill 的审查。独立开发者和小型团队的平衡方案。
  - `Solo` — 完全没有主管审查。最快速度。最适合游戏 Jam、原型阶段或审查感觉像负担时。

在用户选择后立即将选择写入 `production/review-mode.txt` — 不需要单独的"我可以写入吗？"，因为写入是选择的直接结果：
- `Full` → 写入 `full`
- `Lean（推荐）` → 写入 `lean`
- `Solo` → 写入 `solo`

如果 `production/` 目录不存在则创建它。

---

## 第 4 阶段：在继续前确认

呈现推荐路径后，使用 `AskUserQuestion` 询问用户想先做哪一步。绝不自动运行下一个 Skill。

- **Prompt**："你想从 [推荐的第一步] 开始吗？"
- **Options**：
  - `是的，我们从 [推荐的第一步] 开始`
  - `我想先做其他事情`

---

## 第 5 阶段：交接

当用户确认下一步时，用一句简短的话回复："输入 `[skill command]` 开始。"没有其他内容。不要重新解释 Skill 或添加鼓励。`/start` Skill 的工作已完成。

判定：**COMPLETE** — 用户已引导并交接至下一步。

---

## 边缘情况

- **用户选择了 D 但项目为空**：温和地重定向 — "看起来项目是一个没有产物的新模板。路径 A 或 B 会更合适吗？"
- **用户选择了 A 但项目有代码**：提及你发现的内容 — "我注意到 `src/` 中已有代码。你确定是想选 D（已有工作）吗？"
- **用户是回归者（引擎已配置，概念已存在）**：完全跳过上手 — "看起来你已经设置好了！你的引擎是 [X]，你在 `design/gdd/game-concept.md` 有游戏概念。审查模式：`[从 production/review-mode.txt 读取，缺失则为 'lean（默认）']`。想继续上次的工作吗？试试 `/sprint-plan` 或直接告诉我你想做什么。"
- **用户不适合任何选项**：让他们用自己的语言描述情况并适应。

---

## 协作协议

1. **先询问** — 绝不假设用户的状态或意图
2. **提供选项** — 给出清晰的路径，而非命令
3. **用户决定** — 他们选择方向
4. **不自动执行** — 推荐下一个 Skill，不要不询问就运行
5. **适应** — 如果用户的情况不适合模板，倾听并调整
