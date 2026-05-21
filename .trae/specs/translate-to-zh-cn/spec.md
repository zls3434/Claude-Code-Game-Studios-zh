# 项目全面中文化翻译 规格说明

## 为什么

Claude Code Game Studios 是一个完整的游戏工作室 Agent 架构框架，包含 49 个 Agent、73 个 Skill、12 个 Hook、11 个 Rule 以及大量文档模板和参考资料。当前所有内容均为英文，需要将其全面翻译为中文，以便中文用户更好地理解和使用该框架。翻译完成后将存放在独立的 `zh_cn` 分支中，保持 `main` 分支不变。

## 变更内容

- 翻译所有 Markdown 文档（.md 文件）中的英文叙述性文本为中文
- 翻译所有 YAML 前端元数据中的描述性字段为中文
- 翻译所有 Shell 脚本（.sh）中的注释为中文
- 翻译 JSON 配置文件中的注释（如有）
- 翻译 YAML 文件（catalog.yaml、entities.yaml 等）中的描述字段
- 保留所有技术术语不翻译（如 Git、Claude Code、Godot、Unity、Unreal、API、JSON、YAML 等）
- 保留所有代码标识符不翻译（文件名、路径、命令名、变量名、函数名）
- 保留所有代码示例中的内容不翻译
- 保留所有 URL 和引用路径不翻译
- 创建新分支 `zh_cn` 并提交所有翻译变更

## 影响范围

- 受影响规格：所有项目文件（约 350+ 个文件）
- 受影响代码：`.claude/` 目录、`CCGS Skill Testing Framework/` 目录、`design/` 目录、`docs/` 目录、`src/` 目录、根目录文件、`.github/` 目录

## 新增需求

### 需求：所有英文叙述性文本翻译为中文

系统应当将项目中所有英文叙述性文本翻译为简体中文，同时保留技术术语、代码标识符、文件路径和 URL 不变。

#### 场景：翻译 Agent 定义文件

- **当** 处理 `.claude/agents/*.md` 文件时
- **则** 所有英文叙述性文本翻译为中文，YAML frontmatter 中的 `description` 字段翻译为中文，`name`、`model`、`tools`、`skills` 等技术字段保持原样

#### 场景：翻译 Skill 定义文件

- **当** 处理 `.claude/skills/*/SKILL.md` 文件时
- **则** 所有英文叙述性文本翻译为中文，YAML frontmatter 中的 `description` 和 `argument-hint` 字段翻译为中文，`name`、`allowed-tools`、`model`、`user-invocable` 等技术字段保持原样

#### 场景：翻译文档和模板文件

- **当** 处理 `.claude/docs/` 和 `.claude/docs/templates/` 下的文件时
- **则** 所有英文叙述性文本翻译为中文，模板中的占位符和结构保持原样

#### 场景：翻译 Shell 脚本注释

- **当** 处理 `.claude/hooks/*.sh` 文件时
- **则** 脚本注释翻译为中文，脚本逻辑代码和命令保持原样

#### 场景：翻译根目录文档

- **当** 处理根目录的 README.md、CLAUDE.md、CONTRIBUTING.md、SECURITY.md、UPGRADING.md 等文件时
- **则** 所有英文叙述性文本翻译为中文，代码块内容、URL、Markdown 链接目标保持原样

### 需求：技术术语保留不翻译

系统应当在翻译过程中保留所有技术术语和专有名词不翻译，确保技术准确性。

#### 场景：保留引擎和工具名称

- **当** 文本中包含 Godot、Unity、Unreal Engine、Claude Code、Git、GitHub、Docker 等专有名词时
- **则** 这些名称保持英文原文

#### 场景：保留编程和技术概念

- **当** 文本中包含 API、JSON、YAML、Markdown、CI/CD、HTTP、DOM、CSS 等技术概念时
- **则** 这些术语保持英文原文

#### 场景：保留框架和方法论名称

- **当** 文本中包含 MDA、SDT、Bartle、ADR、GDD、PRD、ECS、DOTS、GAS、UMG 等框架/方法论缩写时
- **则** 这些缩写保持英文原文

### 需求：在 zh_cn 分支上提交变更

系统应当在新建的 `zh_cn` 分支上进行所有翻译修改并提交，确保 `main` 分支保持不变。

#### 场景：创建并切换到 zh_cn 分支

- **当** 开始翻译工作时
- **则** 从当前 main 分支创建 `zh_cn` 分支，所有翻译变更仅在此分支上进行

#### 场景：提交翻译变更

- **当** 所有翻译工作完成并验证通过后
- **则** 在 `zh_cn` 分支上使用规范的提交信息提交所有变更

### 需求：文件头部添加翻译修改注释

系统应当在每个被翻译的文件头部添加修改注释，记录翻译日期和修改人信息。

#### 场景：为 Markdown 文件添加修改注释

- **当** 翻译 Markdown 文件时
- **则** 在文件头部 YAML frontmatter 之后（如有）或文件开头添加翻译修改注释，包含修改日期（2026-05-20）和修改人（zls3434）

#### 场景：为 Shell 脚本添加修改注释

- **当** 翻译 Shell 脚本注释时
- **则** 在文件头部添加中文翻译修改注释，包含修改日期和修改人
