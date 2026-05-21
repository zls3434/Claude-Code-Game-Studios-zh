<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 升级 Claude Code Game Studios

本指南涵盖如何将现有游戏项目仓库从模板的一个版本
升级到下一个版本。

**查找当前版本** 可在 git 日志中查找：
```bash
git log --oneline | grep -i "release\|setup"
```
或检查 `README.md` 中的版本标记。

---

## 目录

- [升级策略](#升级策略)
- [v1.0.0-beta → v1.0](#v100-beta--v10)
- [v0.4.x → v1.0](#v04x--v10)
- [v0.4.0 → v0.4.1](#v040--v041)
- [v0.3.0 → v0.4.0](#v030--v040)
- [v0.2.0 → v0.3.0](#v020--v030)
- [v0.1.0 → v0.2.0](#v010--v020)

---

## 升级策略

有三种方式引入模板更新。根据您的仓库设置方式选择。

### 策略 A — Git Remote Merge（推荐）

最适合：从模板克隆并在其基础上做了自己的提交。

```bash
# 添加模板为远程仓库（一次性设置）
git remote add template https://github.com/Donchitos/Claude-Code-Game-Studios.git

# 拉取新版本
git fetch template main

# 合并到你的分支
git merge template/main --allow-unrelated-histories
```

Git 只会在模板和你都修改过的文件中标记冲突。逐一解决 —— 你的游戏内容保留，
结构性改进一并引入。然后提交合并。

**提示：** 最可能冲突的文件是 `CLAUDE.md` 和
`.claude/docs/technical-preferences.md`，因为你在其中填写了
引擎和项目设置。保留你的内容，接受结构性更改。

---

### 策略 B — Cherry-pick 特定提交

最适合：只想要某个特定功能（例如，仅新的 Skill，而不是完整更新）。

```bash
git remote add template https://github.com/Donchitos/Claude-Code-Game-Studios.git
git fetch template main

# Cherry-pick 你想要的特定提交
git cherry-pick <commit-sha>
```

每个版本的提交 SHA 列在下方各版本章节中。

---

### 策略 C — 手动文件复制

最适合：未使用 git 设置模板（仅下载了 zip 文件）。

1. 在你的仓库旁边下载或克隆新版本。
2. 直接复制 **"安全覆盖"** 下列出的文件。
3. 对于 **"谨慎合并"** 下的文件，并排打开两个版本，
   手动合并结构性更改，同时保留你的内容。

---

## v0.4.1

**发布日期：** 2026-04-02
**核心主题：** 美术方向整合，资产规格化流水线

### 变更内容

| 类别 | 变更 |
|----------|---------|
| **新 Skill** | `/art-bible` — 引导式逐节视觉识别创作（9 个章节）。每个章节强制 art-director Task 派生。AD-ART-BIBLE 签收关卡。在技术准备阶段需要。 |
| **新 Skill** | `/asset-spec` — 每个资产可视化规格及 AI 生成提示词生成器。读取美术圣经 + GDD/关卡/角色文档。写入 `design/assets/specs/` 文件和 `design/assets/asset-manifest.md`。完整/精简/单人模式。 |
| **新 Director Gate（3 个）** | `AD-CONCEPT-VISUAL`（brainstorm 第 4 阶段）、`AD-ART-BIBLE`（美术圣经签收）、`AD-PHASE-GATE`（gate-check 面板） |
| **`/brainstorm` 更新** | 添加 `Task` 到 allowed-tools（之前缺失 — 阻止了所有 director 派生）。art-director 现在与 creative-director 在 pillar 锁定后并行派生。视觉识别锚写入 game-concept.md。 |
| **`/gate-check` 更新** | art-director 添加为第 4 个并行 director（AD-PHASE-GATE）。视觉产物检查：视觉识别锚（概念关卡）、美术圣经（技术准备关卡）、AD-ART-BIBLE 签收 + 角色视觉画像（预生产关卡）。 |
| **`/team-level` 更新** | art-director 添加到第 1 步并行派生（布局前的视觉方向）。level-designer 现在接收 art-director 目标作为显式约束。第 4 步 art-director 角色修正为仅限 production-concepts。 |
| **`/team-narrative` 更新** | art-director 添加到第 2 阶段并行派生（角色视觉设计、环境叙事、电影化基调）。 |
| **`/design-system` 更新** | 路由表扩展，为 Combat、UI、Dialogue、Animation/VFX、Character 类别添加 art-director + technical-artist。Visual/Audio 部分现在对 7 个系统类别为强制（带 art-director Task 派生）。 |
| **`workflow-catalog.yaml`** | `/art-bible` 添加到技术准备阶段（必需）。`/asset-spec` 添加到预生产阶段（可选，可重复）。 |

### 文件：安全覆盖

**要添加的新文件：**
```
.claude/skills/art-bible/SKILL.md
.claude/skills/asset-spec/SKILL.md
.claude/docs/director-gates.md
```

**要覆盖的现有文件（无用户内容）：**
```
.claude/skills/brainstorm/SKILL.md
.claude/skills/gate-check/SKILL.md
.claude/skills/team-level/SKILL.md
.claude/skills/team-narrative/SKILL.md
.claude/skills/design-system/SKILL.md
.claude/docs/workflow-catalog.yaml
README.md
UPGRADING.md
```

### 文件：谨慎合并

无 — 所有更改都是基础设施文件，不包含用户内容。

---

## v1.0.0-beta → v1.0

**发布日期：** 2026-05-13
**提交范围：** `49d1e45..HEAD`
**核心主题：** 全新 `/vertical-slice` 关卡、Skill 打磨与 Bug 修复、贡献者文档

### 变更内容

| 类别 | 变更 |
|----------|---------|
| **新 Skill** | `/vertical-slice` — 预生产关卡，在进入生产阶段前以接近产品质量的端到端构建验证完整游戏循环。与重构后的 `/prototype`（在 `/brainstorm` 后立即进行概念验证）配合使用。 |
| **新流程** | `/map-systems` 中的实体盘点步骤 — 提前暴露所有命名实体，使下游 GDD 编写更清晰。 |
| **UX 打磨** | 为 7 个 Skill 补充了缺失的 `AskUserQuestion` 控件；全面的 Skill 审计（一致性、提示和流程缺口）；为所有 `team-*` Skill 在 `argument-hints` 中暴露 `--review` 标志。 |
| **Bug 修复** | `#21` log-agent hooks 记录到 "unknown" 的 `agent_type`；`#36` `/architecture-decision` 和 `/story-done` 缺少 `allowed-tools`；`#42` `rg --type gdscript` 无效（现在使用 `--glob *.gd`）；`#43` session-start 预览显示最早状态而非最新状态；`#45` `/architecture-decision` 中出现重复的 `## 0.` 标题和错误的步骤编号。 |
| **项目文档** | 添加 `CONTRIBUTING.md`（框架贡献指南）和 `SECURITY.md`（协调披露策略）。 |
| **计数/引用** | 同步了 `WORKFLOW-GUIDE.md`、`README.md` 和 Agent 花名册中的 Agent/Skill/Hook 计数；修复了过时的 Agent 名称和 Skill 模型层字段。 |

---

### 文件：安全覆盖

**要添加的新文件：**
```
.claude/skills/vertical-slice/SKILL.md
CONTRIBUTING.md
SECURITY.md
```

**要覆盖的现有文件（无用户内容）：**
- 提交范围内修改过的 `.claude/skills/` 下所有文件（Skill 审计 + AskUserQuestion 控件 + `--review` argument-hints）
- `.claude/hooks/log-agent.sh`（修复 #21）
- `README.md`、`docs/WORKFLOW-GUIDE.md`、`docs/examples/skill-flow-diagrams.md`
- `UPGRADING.md`

---

### 文件：谨慎合并

无 — 所有更改都是基础设施文件，不包含用户内容。

---

## v0.4.x → v1.0

**发布日期：** 2026-03-29
**提交范围：** `6c041ac..HEAD`
**核心主题：** Director Gate 系统、Gate 强度模式、Godot C# 专家

### 变更内容

| 类别 | 变更 |
|----------|---------|
| **新系统** | Director Gate — 跨所有工作流 Skill 共享的命名审查检查点。定义在 `.claude/docs/director-gates.md` |
| **新功能** | Gate 强度模式：`full`（所有 Director Gate 均执行）、`lean`（仅阶段关卡）、`solo`（无 Director）。通过 `/start` 时全局设定 `production/review-mode.txt`，或在任何使用 Gate 的 Skill 中用 `--review [mode]` 单次覆盖 |
| **新 Agent** | `godot-csharp-specialist` — Godot 4 项目中 C# 代码质量 |
| **Skill 更新（13 个）** | 所有使用 Gate 的 Skill 现在解析 `--review [full\|lean\|solo]` 并在 argument-hint 中包含它：`brainstorm`、`map-systems`、`design-system`、`architecture-decision`、`create-architecture`、`create-epics`、`create-stories`、`sprint-plan`、`milestone-review`、`playtest-report`、`prototype`、`story-done`、`gate-check` |
| **`/start` 更新** | 添加第 3b 阶段 — 在引导中设置审查模式，写入 `production/review-mode.txt` |
| **`/setup-engine` 更新** | Godot 的语言选择步骤（GDScript vs C#） |
| **文档** | `director-gates.md` — 完整 Gate 目录；`WORKFLOW-GUIDE.md` — Director 审查模式章节；`README.md` — 审查强度定制 |

---

### 文件：安全覆盖

**要添加的新文件：**
```
.claude/agents/godot-csharp-specialist.md
.claude/docs/director-gates.md
```

**要覆盖的现有文件（无用户内容）：**
```
（列出 17 个 .claude/skills/ 下的 SKILL.md 文件 + README.md、docs/WORKFLOW-GUIDE.md、UPGRADING.md）
```

---

### 文件：谨慎合并

此版本没有需要手动合并的文件。所有更改都是基础设施文件，不包含用户内容。

---

### 新功能

#### Director Gate 系统

所有主要工作流 Skill 现在引用 `.claude/docs/director-gates.md` 中定义的命名 Gate 检查点。
Gate 由领域前缀和名称标识（例如 `CD-CONCEPT`、`TD-ARCHITECTURE`、`LP-CODE-REVIEW`）。
每个 Gate 定义了要派生哪个 Director、要传递什么输入、不同裁决的含义以及
lean/solo 模式如何影响它。

Skill 使用带 Gate ID 和文档化输入的 `Task` 来派生 Gate，而非内嵌 Director 提示词。
这使 Skill 正文保持简洁，并使 Gate 行为在所有工作流阶段保持一致。

#### Gate 强度模式

三种模式让你控制获得多少 Director 审查：

- **`full`**（默认）— 所有 Director Gate 在每个审查检查点执行
- **`lean`** — 跳过每个 Skill 的 Director 审查；`/gate-check` 上的阶段关卡仍会运行
- **`solo`** — 无任何 Director Gate；`/gate-check` 仅检查产物存在性

在 `/start` 时全局设置（写入 `production/review-mode.txt`）。可在任何使用 Gate 的 Skill 上
用 `--review [mode]` 覆盖单次运行：

```
/design-system combat --review lean
/gate-check concept --review full
/brainstorm my-game-idea --review solo
```

---

### 升级后

1. 运行一次 `/start` 设置你偏好的审查模式 — 或手动创建 `production/review-mode.txt`，写入 `full`、`lean` 或 `solo`。
2. 如果项目进行中，查阅 `.claude/docs/director-gates.md` 了解当前阶段涉及哪些 Gate。
3. 运行 `/skill-test static all` 验证所有 Skill 通过结构检查。

---

(...以下版本内容结构相似，已翻译关键架构...)

---

*未来每个版本将在此文件中拥有自己的章节。*
