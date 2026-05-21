<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 为 Claude Code Game Studios 做贡献

CCGS 是一个使用 Claude Code 进行独立游戏开发的协调框架。
欢迎贡献——包括 Bug 修复、填补实际空白的新技能、Agent 改进以及 Hook 修复。不符合框架方向的 PR 将被关闭，不做冗长解释。

## 什么构成好的 PR

- **Bug 修复** —— 某个功能损坏了，这里是修复方案
- **新技能**，用于解决尚未覆盖的工作流空白
- 对现有 Agent、技能或 Hook 的**改进**
- **文档修正** —— 错误信息、失效引用、过时步骤

以 PR 形式提交的功能请求将被关闭，请改用 issue。

**此仓库不适用于：**
CCGS 是帮助你构建游戏的系统，而不是存放你用它构建出的游戏的地方。GDD、ADR、PRD、游戏概念、关卡设计、叙事文档或任何其他由 CCGS 为你自己项目生成的输出都不应合并到这里——请将其保留在你自己的仓库中。

## 不可协商的技术规则

以下事项如果遗漏会导致你的 PR 被拒绝。

**技能文件**
- 技能必须放在 `.claude/skills/<名称>/SKILL.md` 中——必须使用子目录格式。扁平的 `.md` 文件会被 Claude Code 静默忽略。
- SKILL.md 必须包含 YAML frontmatter：`name`、`description`、
  `argument-hint`、`allowed-tools` 和 `model`
- 模型层级：`haiku` 用于只读状态检查，`opus` 用于多文档合成和阶段关卡，`sonnet` 用于其余所有场景

**Hooks**
- 使用 `grep -E`——切勿使用 `grep -P`（Perl 正则表达式在 Windows Git Bash 上会出问题）
- 为未安装 `jq` 或 `python` 的系统提供回退方案
- Hook 在每次会话启动时运行——当不适用时必须快速优雅地退出
  （`exit 0`）

**Agent**
- 新 Agent 必须包含**协作协议**章节，描述 Agent 如何提问和将决策权交给用户
- Agent 未经用户明确授权，不得修改其文档范围之外的文件

**参考文档**
- 如果你的 PR 添加或更改了技能、Agent 或 Hook，请更新对应的参考文档（agent-roster、skills-reference、hooks-reference 或 rules-reference）。添加内容但未更新索引的 PR 将被退回。

## 协作原则

CCGS 不是一个自主系统。每个工作流都遵循：
**提问 → 选项 → 决策 → 草稿 → 审批 → 写入**

技能和 Agent 必须在行动前询问。未经用户明确确认，不得向文件写入任何内容。如果你的贡献包含 Agent 单方面做出决策或写入文件的行为，将不会被合并。

## 测试你的更改

在 Claude Code 会话中运行，确认端到端功能正常。对于技能，调用该技能并验证输出与技能声称的功能是否一致。对于 Hook，触发相关事件并确认 Hook 正确触发且干净退出。

在 PR 描述中附上简要说明，描述你测试了哪些内容以及输出是什么样的。

## 提交格式

使用 [Conventional Commits](https://www.conventionalcommits.org/)：

```
feat: 为 Sprint 末尾回顾添加 /retrospective 技能
fix: 修正 session-start Hook 中的 grep -P 用法
docs: 更新 skills-reference，增加新的 /qa-plan 条目
```

类型：`feat`、`fix`、`docs`、`chore`、`refactor`、`test`

## PR 流程

- 你的 PR 将通过 CODEOWNERS 自动分配给维护者
- 审查在有时间时进行——这是一个个人维护的项目
- 如果你的 PR 在几周内未收到反馈，可以友好地提醒一下
- 已合并的贡献者将在发布说明中致谢

## 平台兼容性

CCGS 必须能在 Windows（Git Bash）、macOS 和 Linux 上运行。如果你的 Hook 或脚本使用了任何平台特定的内容，将被拒绝。如有疑问，请在 Windows 上测试。
