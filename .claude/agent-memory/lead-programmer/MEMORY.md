<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Lead Programmer — Agent 记忆

## Skill 编写规范

### Frontmatter
- 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- 只读分析 Skill（隔离运行）还附带了 `context: fork` 和 `agent:`
- 交互式 Skill（写入文件、提问）不使用 `context: fork`
- `AskUserQuestion` 是一种在 Skill 正文中描述的使用模式 —— 它不列入
  `allowed-tools` frontmatter（现有 Skill 中没有任何一个这样做）

### 文件布局
- Skill 位于 `.claude/skills/<名称>/SKILL.md`（每个 Skill 一个子目录，绝不使用平铺 .md）
- 阶段标题使用 `##` 表示，子章节使用 `###`
- 阶段命名遵循 "阶段 N: 动词 名词" 模式（例如 "阶段 1: 找到故事"）
- 输出格式模板放在带围栏的代码块中

### 已确认的规范化路径（在新 Skill 中引用前需验证）
- 技术债务登记册：`docs/tech-debt-register.md`（非 `production/tech-debt.md`）
- Sprint 文件：`production/sprints/`
- Epic 故事文件：`production/epics/[epic-slug]/story-[NNN]-[slug].md`
- 控制清单：`docs/architecture/control-manifest.md`
- 会话状态：`production/session-state/active.md`
- 系统索引：`design/gdd/systems-index.md`
- 引擎参考：`docs/engine-reference/[engine]/VERSION.md`

### 已完成的 Skill
- `story-done` — 故事结束完成握手（阶段 1-8，写入故事文件）
