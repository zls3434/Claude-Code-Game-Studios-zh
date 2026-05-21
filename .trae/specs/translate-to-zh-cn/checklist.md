# 翻译检查清单

## 分支和版本控制
- [x] `zh_cn` 分支已从 main 分支创建
- [x] `main` 分支未受影响，保持原始英文内容（已确认 0 个修改文件）
- [x] 所有翻译变更仅在 `zh_cn` 分支上（297 个文件变更）

## 根目录文档
- [x] README.md 已翻译为中文，技术术语和代码保持不变
- [x] CLAUDE.md 已翻译为中文
- [x] CONTRIBUTING.md 已翻译为中文
- [x] SECURITY.md 已翻译为中文
- [x] UPGRADING.md 已翻译为中文

## .claude/agents/ — Agent 定义文件
- [x] 所有 49 个 Agent 文件中的描述文本已翻译为中文
- [x] YAML frontmatter 中 `description` 字段已翻译
- [x] `name`、`model`、`tools`、`skills`、`allowed-tools` 等字段保持原样
- [x] 代码块和示例保持原样
- [x] 文件路径引用保持原样

## .claude/skills/ — Skill 定义文件
- [x] 所有 73 个 SKILL.md 文件中的描述文本已翻译为中文
- [x] YAML frontmatter 中 `description` 和 `argument-hint` 字段已翻译
- [x] `name`、`allowed-tools`、`model` 等字段保持原样
- [x] 斜杠命令名称保持原样（如 `/start`、`/brainstorm`）
- [x] 文件路径引用保持原样

## .claude/docs/ — 核心文档
- [x] agent-roster.md 已翻译
- [x] agent-coordination-map.md 已翻译
- [x] coding-standards.md 已翻译
- [x] context-management.md 已翻译
- [x] coordination-rules.md 已翻译
- [x] director-gates.md 已翻译
- [x] directory-structure.md 已翻译
- [x] hooks-reference.md 已翻译
- [x] quick-start.md 已翻译
- [x] review-workflow.md 已翻译
- [x] rules-reference.md 已翻译
- [x] settings-local-template.md 已翻译
- [x] setup-requirements.md 已翻译
- [x] skills-reference.md 已翻译
- [x] technical-preferences.md 已翻译
- [x] CLAUDE-local-template.md 已翻译
- [x] workflow-catalog.yaml 描述字段已翻译

## .claude/docs/hooks-reference/ — Hook 参考
- [x] hook-input-schemas.md 已翻译
- [x] post-merge-asset-validation.md 已翻译
- [x] post-sprint-retrospective.md 已翻译
- [x] pre-commit-code-quality.md 已翻译
- [x] pre-commit-design-check.md 已翻译
- [x] pre-push-test-gate.md 已翻译

## .claude/docs/templates/ — 文档模板
- [x] collaborative-protocols 子目录（3 个文件）已翻译
- [x] 游戏设计模板（8 个文件）已翻译
- [x] 架构模板（4 个文件）已翻译
- [x] 美术和UX模板（6 个文件）已翻译
- [x] 项目管理模板（11 个文件）已翻译
- [x] QA和测试模板（3 个文件）已翻译
- [x] 叙事和设计模板（5 个文件）已翻译
- [x] 所有 41 个模板文件已翻译

## .claude/hooks/ — Hook Shell 脚本
- [x] 所有 12 个 .sh 文件中的英文注释已翻译为中文
- [x] 脚本逻辑代码和命令保持原样
- [x] shebang 行保持原样
- [x] 退出码和条件判断保持原样

## .claude/rules/ — 编码规则
- [x] 所有 11 个规则文件已翻译
- [x] YAML frontmatter 中的 paths 配置保持原样
- [x] 代码示例中的代码保持原样
- [x] 示例中的注释可选择性翻译

## CCGS Skill Testing Framework — 测试框架
- [x] CLAUDE.md 已翻译
- [x] README.md 已翻译
- [x] catalog.yaml 描述字段已翻译
- [x] quality-rubric.md 已翻译
- [x] templates/agent-test-spec.md 已翻译
- [x] templates/skill-test-spec.md 已翻译
- [x] agents/ 下所有 49 个测试规格文件已翻译
- [x] skills/ 下所有 73 个测试规格文件已翻译

## design/ — 设计目录
- [x] CLAUDE.md 已翻译
- [x] registry/entities.yaml 描述字段已翻译

## docs/ — 项目文档
- [x] CLAUDE.md 已翻译
- [x] COLLABORATIVE-DESIGN-PRINCIPLE.md 已翻译
- [x] WORKFLOW-GUIDE.md 已翻译
- [x] engine-reference/README.md 已翻译
- [x] engine-reference/godot/VERSION.md 已翻译
- [x] engine-reference/godot/breaking-changes.md 已翻译
- [x] engine-reference/godot/current-best-practices.md 已翻译
- [x] engine-reference/godot/deprecated-apis.md 已翻译
- [x] engine-reference/godot/modules/ 下所有 7 个模块文件已翻译
- [x] architecture/tr-registry.yaml 描述字段已翻译

## .github/ — GitHub 配置
- [x] ISSUE_TEMPLATE/bug_report.md 已翻译
- [x] ISSUE_TEMPLATE/feature_request.md 已翻译
- [x] PULL_REQUEST_TEMPLATE.md 已翻译

## 其他文件
- [x] src/CLAUDE.md 已翻译
- [x] .claude/agent-memory/lead-programmer/MEMORY.md 已翻译
- [x] .claude/statusline.sh 注释已翻译

## 翻译质量
- [x] 所有技术术语保留英文原文（Godot、Unity、Unreal、Claude Code、Git、API、JSON 等）
- [x] 所有框架/方法论缩写保留英文原文（MDA、SDT、Bartle、ADR、GDD 等）
- [x] 所有文件路径保持原样
- [x] 所有 URL 保持原样
- [x] 所有代码块内容保持原样
- [x] Markdown 链接语法保持正确
- [x] YAML frontmatter 格式保持正确
- [x] Shell 脚本语法保持正确
- [x] 翻译后的中文语句通顺、专业
- [x] 文件编码为 UTF-8，中文不会出现乱码
