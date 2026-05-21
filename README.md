<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

<p align="center">
  <h1 align="center">Claude Code Game Studios</h1>
  <p align="center">
    将一个 Claude Code 会话转变为一间完整的游戏开发工作室。
    <br />
    49 个 Agent。73 个技能。一个协调统一的 AI 团队。
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-49-blueviolet" alt="49 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-73-green" alt="73 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-12-orange" alt="12 Hooks"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-11-red" alt="11 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
  <a href="https://www.buymeacoffee.com/donchitos3"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Support%20this%20project-FFDD00?logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee"></a>
  <a href="https://github.com/sponsors/Donchitos"><img src="https://img.shields.io/badge/GitHub%20Sponsors-Support%20this%20project-ea4aaa?logo=githubsponsors&logoColor=white" alt="GitHub Sponsors"></a>
</p>

---

## 为什么需要这个项目

用 AI 独自构建游戏功能强大——但单个聊天会话缺乏结构。没人阻止你硬编码魔法数字、跳过设计文档或写出意大利面条式的代码。没有 QA 检查、没有设计评审、没有人问"这真的符合游戏的愿景吗？"

**Claude Code Game Studios** 通过为 AI 会话赋予真实工作室的结构来解决这个问题。你获得的不是一个通用助手，而是被组织成工作室层级结构的 49 个专业 Agent——维护愿景的导演、主导各自领域的部门负责人、执行具体工作的专家。每个 Agent 都有明确的职责、升级路径和质量关卡。

结果是：你仍然做出每一个决策，但现在你拥有了一个团队，他们能提出正确的问题、及早发现错误，并让你的项目从最初的头脑风暴到发布始终井然有序。

---

## 目录

- [包含内容](#包含内容)
- [工作室层级](#工作室层级)
- [斜杠命令](#斜杠命令)
- [快速上手](#快速上手)
- [升级指南](#升级指南)
- [项目结构](#项目结构)
- [工作原理](#工作原理)
- [设计理念](#设计理念)
- [定制化](#定制化)
- [平台支持](#平台支持)
- [社区](#社区)
- [支持本项目](#支持本项目)
- [许可证](#许可证)

---

## 包含内容

| 类别 | 数量 | 描述 |
|----------|-------|-------------|
| **Agent** | 49 | 涵盖设计、编程、美术、音频、叙事、QA 和制作的子 Agent |
| **技能** | 73 | 覆盖每个工作流阶段的斜杠命令（`/start`、`/design-system`、`/create-epics`、`/create-stories`、`/dev-story`、`/story-done` 等） |
| **Hooks** | 12 | 提交、推送、资源变更、会话生命周期、Agent 审计跟踪和缺口检测的自动化验证 |
| **规则** | 11 | 编辑玩法、引擎、AI、UI、网络等代码时强制执行的路径范围编码规范 |
| **模板** | 41 | GDD、UX 规格、ADR、Sprint 计划、HUD 设计、无障碍要求等文档模板 |

## 工作室层级

Agent 被组织成三个层级，与真实工作室的运作方式一致：

```
第一层 — 导演类 (Opus)
  creative-director    technical-director    producer

第二层 — 部门负责人 (Sonnet)
  game-designer        lead-programmer       art-director
  audio-director       narrative-director    qa-lead
  release-manager      localization-lead

第三层 — 专家类 (Sonnet/Haiku)
  gameplay-programmer  engine-programmer     ai-programmer
  network-programmer   tools-programmer      ui-programmer
  systems-designer     level-designer        economy-designer
  technical-artist     sound-designer        writer
  world-builder        ux-designer           prototyper
  performance-analyst  devops-engineer       analytics-engineer
  security-engineer    qa-tester             accessibility-specialist
  live-ops-designer    community-manager
```

### 引擎专家

模板包含三大主流引擎的 Agent 集合。请使用与您的项目匹配的集合：

| 引擎 | 主导 Agent | 子专家 |
|--------|-----------|-----------------|
| **Godot 4** | `godot-specialist` | GDScript、Shaders、GDExtension |
| **Unity** | `unity-specialist` | DOTS/ECS、Shaders/VFX、Addressables、UI Toolkit |
| **Unreal Engine 5** | `unreal-specialist` | GAS、Blueprints、Replication、UMG/CommonUI |

## 斜杠命令

在 Claude Code 中输入 `/` 即可访问全部 73 个技能：

**上手与导航**
`/start` `/help` `/project-stage-detect` `/setup-engine` `/adopt`

**游戏设计**
`/brainstorm` `/map-systems` `/design-system` `/quick-design` `/review-all-gdds` `/propagate-design-change`

**美术与资源**
`/art-bible` `/asset-spec` `/asset-audit`

**UX 与界面设计**
`/ux-design` `/ux-review`

**架构**
`/create-architecture` `/architecture-decision` `/architecture-review` `/create-control-manifest`

**Story 与 Sprint**
`/create-epics` `/create-stories` `/dev-story` `/sprint-plan` `/sprint-status` `/story-readiness` `/story-done` `/estimate`

**评审与分析**
`/design-review` `/code-review` `/balance-check` `/content-audit` `/scope-check` `/perf-profile` `/tech-debt` `/gate-check` `/consistency-check` `/security-audit`

**QA 与测试**
`/qa-plan` `/smoke-check` `/soak-test` `/regression-suite` `/test-setup` `/test-helpers` `/test-evidence-review` `/test-flakiness` `/skill-test` `/skill-improve`

**制作阶段**
`/milestone-review` `/retrospective` `/bug-report` `/bug-triage` `/reverse-document` `/playtest-report`

**发布**
`/release-checklist` `/launch-checklist` `/changelog` `/patch-notes` `/hotfix` `/day-one-patch`

**创意与内容**
`/prototype` `/onboard` `/localize`

**团队协调**（协调多个 Agent 完成单个功能）
`/team-combat` `/team-narrative` `/team-ui` `/team-release` `/team-polish` `/team-audio` `/team-level` `/team-live-ops` `/team-qa`

## 快速上手

### 前置条件

- [Git](https://git-scm.com/)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- **推荐**：[jq](https://jqlang.github.io/jq/)（用于 Hook 验证）和 Python 3（用于 JSON 验证）

所有 Hook 在可选工具缺失时会优雅降级——不会有任何损坏，只是会缺失验证功能。

### 安装步骤

1. **克隆或用作模板**：
   ```bash
   git clone https://github.com/Donchitos/Claude-Code-Game-Studios.git my-game
   cd my-game
   ```

2. **打开 Claude Code** 并启动会话：
   ```bash
   claude
   ```

3. **运行 `/start`** —— 系统会询问你当前的状态（毫无概念、模糊想法、
   清晰设计、已有成果）并引导你进入正确的工作流。不会做任何假设。

   如果已经知道自己需要什么，也可以直接跳转到特定技能：
   - `/brainstorm` —— 从零开始探索游戏创意
   - `/setup-engine godot 4.6` —— 如果已经确定引擎，直接配置
   - `/project-stage-detect` —— 分析已有项目

## 升级指南

已经在使用旧版本的模板？查看 [UPGRADING.md](UPGRADING.md) 获取逐步迁移说明、版本间变更的详细分解，以及哪些文件可以安全覆盖、哪些需要手动合并。

## 项目结构

```
CLAUDE.md                           # 主配置文件
.claude/
  settings.json                     # Hooks、权限、安全规则
  agents/                           # 49 个 Agent 定义（markdown + YAML frontmatter）
  skills/                           # 73 个斜杠命令（每个技能一个子目录）
  hooks/                            # 12 个 Hook 脚本（bash，跨平台）
  rules/                            # 11 个路径范围编码规范
  statusline.sh                     # 状态栏脚本（上下文使用率%、模型、阶段、Epic 面包屑）
  docs/
    workflow-catalog.yaml           # 7 阶段管线定义（被 /help 读取）
    templates/                      # 41 个文档模板
src/                                # 游戏源代码
assets/                             # 美术、音频、VFX、Shader、数据文件
design/                             # GDD、叙事文档、关卡设计
docs/                               # 技术文档和 ADR
tests/                              # 测试套件（单元、集成、性能、试玩测试）
tools/                              # 构建和管线工具
prototypes/                         # 一次性原型（与 src/ 隔离）
production/                         # Sprint 计划、里程碑、发布跟踪
```

## 工作原理

### Agent 协调机制

Agent 遵循结构化的委托模型：

1. **纵向委托** —— 导演委托给负责人，负责人委托给专家
2. **横向咨询** —— 同级 Agent 可以相互咨询，但不能做出跨领域的约束性决策
3. **冲突解决** —— 分歧升级到共同的上级（设计类由 `creative-director` 负责，技术类由 `technical-director` 负责）
4. **变更传播** —— 跨部门的变更由 `producer` 协调
5. **领域边界** —— Agent 在没有明确委托的情况下不得修改其领域之外的文件

### 协作式，非自主式

这**不是**一个自动驾驶系统。每个 Agent 都遵循严格的协作协议：

1. **询问** —— Agent 在提出解决方案前先提问
2. **呈现选项** —— Agent 展示 2-4 个选项及其优缺点
3. **你来决定** —— 用户始终掌握决策权
4. **草稿** —— Agent 在最终确认前展示成果
5. **审批** —— 未经你签字确认，不会写入任何内容

你始终掌控全局。Agent 提供的是结构和专业知识，而非自主权。

### 自动化安全保护

**Hooks** 在每次会话中自动运行：

| Hook | 触发条件 | 功能 |
|------|---------|--------------|
| `validate-commit.sh` | PreToolUse (Bash) | 检查硬编码值、TODO 格式、JSON 有效性、设计文档章节——如果命令不是 `git commit` 则提前退出 |
| `validate-push.sh` | PreToolUse (Bash) | 向受保护分支推送时发出警告——如果命令不是 `git push` 则提前退出 |
| `validate-assets.sh` | PostToolUse (Write/Edit) | 验证命名规范和 JSON 结构——如果文件不在 `assets/` 中则提前退出 |
| `session-start.sh` | 会话打开 | 显示当前分支和最近提交以便定位 |
| `detect-gaps.sh` | 会话打开 | 检测全新项目（建议 `/start`）以及代码或原型存在但缺失设计文档的情况 |
| `pre-compact.sh` | 压缩前 | 保存会话进度备注 |
| `post-compact.sh` | 压缩后 | 提醒 Claude 从 `active.md` 恢复会话状态 |
| `notify.sh` | 通知事件 | 通过 PowerShell 显示 Windows Toast 通知 |
| `session-stop.sh` | 会话关闭 | 将 `active.md` 归档到会话日志并记录 git 活动 |
| `log-agent.sh` | Agent 启动 | 审计跟踪起始——记录子 Agent 调用 |
| `log-agent-stop.sh` | Agent 停止 | 审计跟踪结束——完成子 Agent 记录 |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | 在任何 `.claude/skills/` 变更后建议运行 `/skill-test` |

> **注意**：`validate-commit.sh`、`validate-assets.sh` 和 `validate-skill-change.sh` 在每次 Bash/Write 工具调用时触发，当命令或文件路径不相关时会立即退出（exit 0）。这是正常的 Hook 行为——并非性能问题。

`settings.json` 中的**权限规则**自动允许安全操作（git status、测试运行）并阻止危险操作（强制推送、`rm -rf`、读取 `.env` 文件）。

### 路径范围规则

编码规范根据文件位置自动执行：

| 路径 | 强制规范 |
|------|----------|
| `src/gameplay/**` | 数据驱动值、delta time 使用、禁止 UI 引用 |
| `src/core/**` | 热路径零分配、线程安全、API 稳定性 |
| `src/ai/**` | 性能预算、可调试性、数据驱动参数 |
| `src/networking/**` | 服务器权威、版本化消息、安全性 |
| `src/ui/**` | 禁止拥有游戏状态、本地化就绪、无障碍访问 |
| `design/gdd/**` | 必需的 8 个章节、公式格式、边界情况 |
| `tests/**` | 测试命名、覆盖率要求、fixture 模式 |
| `prototypes/**` | 宽松标准、README 必需、假设需文档化 |

## 设计理念

此模板基于专业的游戏开发实践：

- **MDA 框架** —— 用于游戏设计的机制、动态、美学分析
- **自我决定理论** —— 用于玩家动机的自主性、胜任感、关联性
- **心流状态设计** —— 用于玩家投入度的挑战-技能平衡
- **Bartle 玩家类型** —— 受众定位与验证
- **验证驱动开发** —— 先测试，后实现

## 定制化

这是一个**模板**，而非封闭的框架。一切都可定制：

- **增删 Agent** —— 删除不需要的 Agent 文件，为你的领域添加新的
- **编辑 Agent 提示词** —— 调整 Agent 行为，添加项目专属知识
- **修改技能** —— 调整工作流以匹配你团队的流程
- **添加规则** —— 为项目目录结构创建新的路径范围规则
- **调整 Hooks** —— 调整验证严格度，添加新检查
- **选择引擎** —— 使用 Godot、Unity 或 Unreal 的 Agent 集合（或都不选用）
- **设置审阅强度** —— `full`（所有导演关卡）、`lean`（仅阶段关卡）或 `solo`（无）。在 `/start` 期间设置或编辑 `production/review-mode.txt`。对任意技能使用 `--review solo` 来单次覆盖。

## 平台支持

主要开发和测试在 **Windows 10** 上使用 Git Bash 进行。所有 Hook 使用 POSIX 兼容模式（`grep -E`，而非 `grep -P`），并包含缺失工具的回退方案，因此它们在 macOS 和 Linux 上应该也能运行。`notify.sh` Hook 使用 PowerShell 实现 Windows Toast 通知，在其他平台上为 no-op——macOS/Linux 的桌面通知尚未接入。跨平台测试正在进行中；如遇平台特定的问题，请提交 issue。

## 社区

- **讨论** —— [GitHub Discussions](https://github.com/Donchitos/Claude-Code-Game-Studios/discussions) 用于提问、创意交流和展示你的成果
- **问题反馈** —— [Bug 报告和功能请求](https://github.com/Donchitos/Claude-Code-Game-Studios/issues)

---

## 支持本项目

Claude Code Game Studios 是免费开源项目。如果它为你节省了时间或帮助你发布了游戏，请考虑支持持续开发：

<p>
  <a href="https://www.buymeacoffee.com/donchitos3"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me a Coffee"></a>
  &nbsp;
  <a href="https://github.com/sponsors/Donchitos"><img src="https://img.shields.io/badge/GitHub%20Sponsors-ea4aaa?style=for-the-badge&logo=githubsponsors&logoColor=white" alt="GitHub Sponsors"></a>
</p>

- **[Buy Me a Coffee](https://www.buymeacoffee.com/donchitos3)** —— 一次性支持
- **[GitHub Sponsors](https://github.com/sponsors/Donchitos)** —— 通过 GitHub 的持续性支持

赞助有助于资助维护技能、添加新 Agent、跟进 Claude Code 和引擎 API 变更，以及回复社区问题所花费的时间。

---

*为 Claude Code 打造。持续维护和扩展——欢迎通过 [GitHub Discussions](https://github.com/Donchitos/Claude-Code-Game-Studios/discussions) 贡献。*

## 许可证

MIT 许可证。详见 [LICENSE](LICENSE)。
