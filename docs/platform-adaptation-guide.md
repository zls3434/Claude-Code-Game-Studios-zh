<!-- Claude Code Game Studios -->
# 平台适配指南

本文件介绍 Claude Code Game Studios 的多 Agent 工具适配架构和使用方法。

## 两层架构 + 输出层

### 第一层：规范源层（.claude/）

Claude Code 原生配置即单一真相源，所有配置在此维护：

- `.claude/agents/` — 49 个 Agent 定义（YAML frontmatter + 正文）
- `.claude/skills/` — 73 个技能定义（Agent Skills 标准格式）
- `.claude/rules/` — 11 个路径范围规则
- `.claude/hooks/` — 12 个 Hook 脚本
- `.claude/docs/` — 规范文档与模板
- `CLAUDE.md` — Claude Code 入口（含 `@` 引用）

### 第二层：适配层（tools/adapters/）

Python 3 脚本（仅标准库，PyYAML 可选）将规范源转换为各平台格式：

- `sync_all.py` — 同步所有平台（总入口）
- `sync_agents_md.py` — 生成 AGENTS.md（Codex 与 DeepSeek Harness 共用）
- `sync_trae.py` — 生成 Trae IDE 配置
- `lib.py` — 共享工具（frontmatter 解析、文件读写）

### 第三层：输出层

各平台原生配置，由同步脚本自动生成并提交入库：

| 输出 | 目标平台 |
|---|---|
| `AGENTS.md`、`src|docs|design/AGENTS.md` | Codex、DeepSeek Harness（dsh） |
| `.trae/agents/`、`.trae/rules/project_rules.md`、`.trae/skills/` | Trae IDE |

## 开放标准

### AGENTS.md

被 Codex、DeepSeek Harness、Cursor、Windsurf 等广泛支持的跨平台主配置标准。
项目根目录的 `AGENTS.md` 是这些平台的共享入口。

DeepSeek Harness（`dsh`）通过其 `@deepseek-ai/dsh-agent-instructions` 插件原生读取
工作区 `AGENTS.md`（回退 `CLAUDE.md`），无需任何额外配置。

### Agent Skills

Anthropic 主导的技能开放标准，被 Claude Code、Codex、Trae 等支持。
`.claude/skills/` 下的 SKILL.md 遵循此标准，可被上述平台直接读取。

## 格式转换

### Agent 定义

| 目标平台 | 转换方式 |
|---|---|
| Codex / DeepSeek Harness | 浓缩为 AGENTS.md 中的分层花名册表（名称 + 职责） |
| Trae IDE | 直接复制到 `.trae/agents/`（Trae 兼容该 frontmatter 格式） |

### 技能定义

| 目标平台 | 转换方式 |
|---|---|
| Codex / DeepSeek Harness | AGENTS.md 技能清单（源自 workflow-catalog.yaml + 技能目录扫描） |
| Trae IDE | 直接复制到 `.trae/skills/<名称>/SKILL.md`（Agent Skills 标准兼容） |

### 路径规则

| 目标平台 | 转换方式 |
|---|---|
| Codex / DeepSeek Harness | 摘要写入 AGENTS.md"编码规范"，子目录规则由 `src|docs|design/AGENTS.md` 承载 |
| Trae IDE | 拼接为 `.trae/rules/project_rules.md` 单文件内联规则 |

### Hook 与权限

Hook 与 settings.json 权限为 Claude Code 专属，其他平台降级为
AGENTS.md 中的文档指令（见"平台能力差异"章节）。详见 `docs/platform-comparison-matrix.md`。

## 常见操作

### 修改 Agent 定义

1. 编辑 `.claude/agents/对应文件.md`
2. 运行 `python tools/adapters/sync_all.py`
3. 提交变更（规范源与生成物一并提交）

### 新增技能

1. 在 `.claude/skills/新技能名/` 创建 SKILL.md
2. 如需纳入阶段编排，更新 `.claude/docs/workflow-catalog.yaml`
3. 运行同步并提交

### 修改规则

1. 编辑 `.claude/rules/对应文件.md`
2. 运行同步并提交

### 仅同步单个平台

```bash
python tools/adapters/sync_all.py codex   # 仅生成 AGENTS.md 系列
python tools/adapters/sync_all.py trae    # 仅生成 .trae/ 配置
```

## 维护约定

- **生成文件勿手改**：所有输出文件头部带"自动生成"声明，手改内容会在下次同步时丢失
- **幂等性**：脚本可重复运行，输出确定（换行统一为 LF）
- **新增 Agent**：若未编入 `sync_agents_md.py` 的 `TIER_GROUPS` 分组，会自动落入
  AGENTS.md 的"其他"分组；建议同步更新分组以保持花名册结构
