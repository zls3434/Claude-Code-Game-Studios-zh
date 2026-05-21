# 翻译检查清单

## 分支和版本控制
- [ ] `zh_cn` 分支已从 main 分支创建
- [ ] `main` 分支未受影响，保持原始英文内容
- [ ] 所有翻译变更仅在 `zh_cn` 分支上

## 根目录文档
- [ ] README.md 已翻译为中文，技术术语和代码保持不变
- [ ] CLAUDE.md 已翻译为中文
- [ ] CONTRIBUTING.md 已翻译为中文
- [ ] SECURITY.md 已翻译为中文
- [ ] UPGRADING.md 已翻译为中文

## .claude/agents/ — Agent 定义文件
- [ ] 所有 49 个 Agent 文件中的描述文本已翻译为中文
- [ ] YAML frontmatter 中 `description` 字段已翻译
- [ ] `name`、`model`、`tools`、`skills`、`allowed-tools` 等字段保持原样
- [ ] 代码块和示例保持原样
- [ ] 文件路径引用保持原样

## .claude/skills/ — Skill 定义文件
- [ ] 所有 73 个 SKILL.md 文件中的描述文本已翻译为中文
- [ ] YAML frontmatter 中 `description` 和 `argument-hint` 字段已翻译
- [ ] `name`、`allowed-tools`、`model` 等字段保持原样
- [ ] 斜杠命令名称保持原样（如 `/start`、`/brainstorm`）
- [ ] 文件路径引用保持原样

## .claude/docs/ — 核心文档
- [ ] agent-roster.md 已翻译
- [ ] agent-coordination-map.md 已翻译
- [ ] coding-standards.md 已翻译
- [ ] context-management.md 已翻译
- [ ] coordination-rules.md 已翻译
- [ ] director-gates.md 已翻译
- [ ] directory-structure.md 已翻译
- [ ] hooks-reference.md 已翻译
- [ ] quick-start.md 已翻译
- [ ] review-workflow.md 已翻译
- [ ] rules-reference.md 已翻译
- [ ] settings-local-template.md 已翻译
- [ ] setup-requirements.md 已翻译
- [ ] skills-reference.md 已翻译
- [ ] technical-preferences.md 已翻译
- [ ] CLAUDE-local-template.md 已翻译
- [ ] workflow-catalog.yaml 描述字段已翻译

## .claude/docs/hooks-reference/ — Hook 参考
- [ ] hook-input-schemas.md 已翻译
- [ ] post-merge-asset-validation.md 已翻译
- [ ] post-sprint-retrospective.md 已翻译
- [ ] pre-commit-code-quality.md 已翻译
- [ ] pre-commit-design-check.md 已翻译
- [ ] pre-push-test-gate.md 已翻译

## .claude/docs/templates/ — 文档模板
- [ ] collaborative-protocols 子目录（3 个文件）已翻译
- [ ] 游戏设计模板（8 个文件）已翻译
- [ ] 架构模板（4 个文件）已翻译
- [ ] 美术和UX模板（5 个文件）已翻译
- [ ] 项目管理模板（9 个文件）已翻译
- [ ] QA和测试模板（3 个文件）已翻译
- [ ] 叙事和设计模板（5 个文件）已翻译
- [ ] 独立模板文件（4 个文件）已翻译

## .claude/hooks/ — Hook Shell 脚本
- [ ] 所有 12 个 .sh 文件中的英文注释已翻译为中文
- [ ] 脚本逻辑代码和命令保持原样
- [ ] shebang 行保持原样
- [ ] 退出码和条件判断保持原样

## .claude/rules/ — 编码规则
- [ ] 所有 11 个规则文件已翻译
- [ ] YAML frontmatter 中的 paths 配置保持原样
- [ ] 代码示例中的代码保持原样
- [ ] 示例中的注释可选择性翻译

## CCGS Skill Testing Framework — 测试框架
- [ ] CLAUDE.md 已翻译
- [ ] README.md 已翻译
- [ ] catalog.yaml 描述字段已翻译
- [ ] quality-rubric.md 已翻译
- [ ] templates/agent-test-spec.md 已翻译
- [ ] templates/skill-test-spec.md 已翻译
- [ ] agents/ 下所有 49 个测试规格文件已翻译
- [ ] skills/ 下所有 73 个测试规格文件已翻译

## design/ — 设计目录
- [ ] CLAUDE.md 已翻译
- [ ] registry/entities.yaml 描述字段已翻译

## docs/ — 项目文档
- [ ] CLAUDE.md 已翻译
- [ ] COLLABORATIVE-DESIGN-PRINCIPLE.md 已翻译
- [ ] WORKFLOW-GUIDE.md 已翻译
- [ ] engine-reference/README.md 已翻译
- [ ] engine-reference/godot/VERSION.md 已翻译
- [ ] engine-reference/godot/breaking-changes.md 已翻译
- [ ] engine-reference/godot/current-best-practices.md 已翻译
- [ ] engine-reference/godot/deprecated-apis.md 已翻译
- [ ] engine-reference/godot/modules/ 下所有 7 个模块文件已翻译
- [ ] architecture/tr-registry.yaml 描述字段已翻译

## .github/ — GitHub 配置
- [ ] ISSUE_TEMPLATE/bug_report.md 已翻译
- [ ] ISSUE_TEMPLATE/feature_request.md 已翻译
- [ ] PULL_REQUEST_TEMPLATE.md 已翻译

## 其他文件
- [ ] src/CLAUDE.md 已翻译
- [ ] .claude/agent-memory/lead-programmer/MEMORY.md 已翻译
- [ ] .claude/statusline.sh 注释已翻译

## 翻译质量
- [ ] 所有技术术语保留英文原文（Godot、Unity、Unreal、Claude Code、Git、API、JSON 等）
- [ ] 所有框架/方法论缩写保留英文原文（MDA、SDT、Bartle、ADR、GDD 等）
- [ ] 所有文件路径保持原样
- [ ] 所有 URL 保持原样
- [ ] 所有代码块内容保持原样
- [ ] Markdown 链接语法保持正确
- [ ] YAML frontmatter 格式保持正确
- [ ] Shell 脚本语法保持正确
- [ ] 翻译后的中文语句通顺、专业
- [ ] 文件编码为 UTF-8，中文不会出现乱码
