# 翻译任务列表

## 任务 0：准备工作 — 创建 zh_cn 分支
- [ ] 任务 0：创建 `zh_cn` 分支用于存放中文翻译
  - [ ] 从当前 main 分支创建新分支 `zh_cn`
  - [ ] 切换到 `zh_cn` 分支

## 任务 1：翻译根目录文档文件
- [ ] 任务 1：翻译项目根目录的主要文档
  - [ ] 翻译 `README.md`
  - [ ] 翻译 `CLAUDE.md`
  - [ ] 翻译 `CONTRIBUTING.md`
  - [ ] 翻译 `SECURITY.md`
  - [ ] 翻译 `UPGRADING.md`

## 任务 2：翻译 .claude/agents/ 目录下所有 Agent 定义文件
- [ ] 任务 2：翻译 Agent 定义文件（约 49 个文件）
  - [ ] 翻译导演层 Agents：creative-director, technical-director, producer
  - [ ] 翻译部门负责人 Agents：game-designer, lead-programmer, art-director, audio-director, narrative-director, qa-lead, release-manager, localization-lead
  - [ ] 翻译专业 Agents（编程类）：gameplay-programmer, engine-programmer, ai-programmer, network-programmer, tools-programmer, ui-programmer
  - [ ] 翻译专业 Agents（设计类）：systems-designer, level-designer, economy-designer, live-ops-designer
  - [ ] 翻译专业 Agents（其他）：technical-artist, sound-designer, writer, world-builder, ux-designer, prototyper, performance-analyst, devops-engineer, analytics-engineer, security-engineer, qa-tester, accessibility-specialist, community-manager
  - [ ] 翻译引擎专用 Agents：godot-specialist, godot-gdscript-specialist, godot-csharp-specialist, godot-shader-specialist, godot-gdextension-specialist
  - [ ] 翻译引擎专用 Agents：unity-specialist, unity-dots-specialist, unity-shader-specialist, unity-addressables-specialist, unity-ui-specialist
  - [ ] 翻译引擎专用 Agents：unreal-specialist, ue-gas-specialist, ue-blueprint-specialist, ue-replication-specialist, ue-umg-specialist

## 任务 3：翻译 .claude/skills/ 目录下所有 Skill 定义文件
- [ ] 任务 3：翻译 Skill 定义文件（约 73 个 SKILL.md 文件）
  - [ ] 翻译 adopt, architecture-decision, architecture-review, art-bible, asset-audit, asset-spec
  - [ ] 翻译 balance-check, brainstorm, bug-report, bug-triage, changelog, code-review, consistency-check, content-audit
  - [ ] 翻译 create-architecture, create-control-manifest, create-epics, create-stories, day-one-patch, design-review, design-system, dev-story
  - [ ] 翻译 estimate, gate-check, help, hotfix, launch-checklist, localize, map-systems, milestone-review
  - [ ] 翻译 onboard, patch-notes, perf-profile, playtest-report, project-stage-detect, propagate-design-change, prototype
  - [ ] 翻译 qa-plan, quick-design, regression-suite, release-checklist, retrospective, reverse-document, review-all-gdds, scope-check
  - [ ] 翻译 security-audit, setup-engine, skill-improve, skill-test, smoke-check, soak-test, sprint-plan, sprint-status, start
  - [ ] 翻译 story-done, story-readiness, team-audio, team-combat, team-level, team-live-ops, team-narrative, team-polish, team-qa, team-release, team-ui
  - [ ] 翻译 tech-debt, test-evidence-review, test-flakiness, test-helpers, test-setup, ux-design, ux-review, vertical-slice

## 任务 4：翻译 .claude/docs/ 目录下所有文档
- [ ] 任务 4：翻译文档和参考资料
  - [ ] 翻译 `agent-roster.md`
  - [ ] 翻译 `agent-coordination-map.md`
  - [ ] 翻译 `coding-standards.md`
  - [ ] 翻译 `context-management.md`
  - [ ] 翻译 `coordination-rules.md`
  - [ ] 翻译 `director-gates.md`
  - [ ] 翻译 `directory-structure.md`
  - [ ] 翻译 `hooks-reference.md`
  - [ ] 翻译 `quick-start.md`
  - [ ] 翻译 `review-workflow.md`
  - [ ] 翻译 `rules-reference.md`
  - [ ] 翻译 `settings-local-template.md`
  - [ ] 翻译 `setup-requirements.md`
  - [ ] 翻译 `skills-reference.md`
  - [ ] 翻译 `technical-preferences.md`
  - [ ] 翻译 `CLAUDE-local-template.md`
  - [ ] 翻译 `workflow-catalog.yaml`

## 任务 5：翻译 .claude/docs/hooks-reference/ 目录
- [ ] 任务 5：翻译 Hook 参考文档
  - [ ] 翻译 `hook-input-schemas.md`
  - [ ] 翻译 `post-merge-asset-validation.md`
  - [ ] 翻译 `post-sprint-retrospective.md`
  - [ ] 翻译 `pre-commit-code-quality.md`
  - [ ] 翻译 `pre-commit-design-check.md`
  - [ ] 翻译 `pre-push-test-gate.md`

## 任务 6：翻译 .claude/docs/templates/ 目录下所有模板
- [ ] 任务 6：翻译文档模板（约 41 个文件）
  - [ ] 翻译 collaborative-protocols 子目录：design-agent-protocol, implementation-agent-protocol, leadership-agent-protocol
  - [ ] 翻译游戏设计模板：game-concept, game-design-document, game-pillars, pitch-document, difficulty-curve, systems-index, economy-model, faction-design
  - [ ] 翻译技术和架构模板：architecture-decision-record, architecture-doc-from-code, architecture-traceability, technical-design-document
  - [ ] 翻译美术和UX模板：art-bible, sound-bible, hud-design, ux-spec, interaction-pattern-library, accessibility-requirements
  - [ ] 翻译管理和流程模板：sprint-plan, milestone-definition, project-stage-report, prototype-report, vertical-slice-report, post-mortem, incident-response, risk-register-entry, release-checklist-template, release-notes, changelog-template
  - [ ] 翻译QA和测试模板：test-plan, test-evidence, skill-test-spec
  - [ ] 翻译叙事和设计模板：narrative-character-sheet, player-journey, level-design-document, concept-doc-from-prototype, design-doc-from-implementation

## 任务 7：翻译 Hook Shell 脚本
- [ ] 任务 7：翻译 Hook 脚本中的注释（约 12 个 .sh 文件）
  - [ ] 翻译 detect-gaps.sh
  - [ ] 翻译 log-agent.sh
  - [ ] 翻译 log-agent-stop.sh
  - [ ] 翻译 notify.sh
  - [ ] 翻译 post-compact.sh
  - [ ] 翻译 pre-compact.sh
  - [ ] 翻译 session-start.sh
  - [ ] 翻译 session-stop.sh
  - [ ] 翻译 validate-assets.sh
  - [ ] 翻译 validate-commit.sh
  - [ ] 翻译 validate-push.sh
  - [ ] 翻译 validate-skill-change.sh

## 任务 8：翻译 .claude/rules/ 目录下所有规则文件
- [ ] 任务 8：翻译编码标准规则文件（约 11 个文件）
  - [ ] 翻译 ai-code.md
  - [ ] 翻译 data-files.md
  - [ ] 翻译 design-docs.md
  - [ ] 翻译 engine-code.md
  - [ ] 翻译 gameplay-code.md
  - [ ] 翻译 narrative.md
  - [ ] 翻译 network-code.md
  - [ ] 翻译 prototype-code.md
  - [ ] 翻译 shader-code.md
  - [ ] 翻译 test-standards.md
  - [ ] 翻译 ui-code.md

## 任务 9：翻译 CCGS Skill Testing Framework 目录
- [ ] 任务 9：翻译 CCGS 技能测试框架
  - [ ] 翻译 `CCGS Skill Testing Framework/CLAUDE.md`
  - [ ] 翻译 `CCGS Skill Testing Framework/README.md`
  - [ ] 翻译 `CCGS Skill Testing Framework/catalog.yaml`（仅描述字段）
  - [ ] 翻译 `CCGS Skill Testing Framework/quality-rubric.md`
  - [ ] 翻译 `CCGS Skill Testing Framework/templates/agent-test-spec.md`
  - [ ] 翻译 `CCGS Skill Testing Framework/templates/skill-test-spec.md`

## 任务 10：翻译 CCGS Skill Testing Framework/agents/ 目录
- [ ] 任务 10：翻译 CCGS Agent 测试规格文件（约 49 个文件）
  - [ ] 翻译 directors 子目录
  - [ ] 翻译 engine/godot 子目录
  - [ ] 翻译 engine/unity 子目录
  - [ ] 翻译 engine/unreal 子目录
  - [ ] 翻译 leads 子目录
  - [ ] 翻译 operations 子目录
  - [ ] 翻译 qa 子目录
  - [ ] 翻译 specialists 子目录

## 任务 11：翻译 CCGS Skill Testing Framework/skills/ 目录
- [ ] 任务 11：翻译 CCGS Skill 测试规格文件（约 73 个文件）
  - [ ] 翻译 analysis 子目录（约 12 文件）
  - [ ] 翻译 authoring 子目录（约 7 文件）
  - [ ] 翻译 gate 子目录
  - [ ] 翻译 pipeline 子目录（约 6 文件）
  - [ ] 翻译 readiness 子目录
  - [ ] 翻译 review 子目录
  - [ ] 翻译 sprint 子目录（约 6 文件）
  - [ ] 翻译 team 子目录（约 9 文件）
  - [ ] 翻译 utility 子目录（约 28 文件）

## 任务 12：翻译 design/ 目录
- [ ] 任务 12：翻译设计目录文件
  - [ ] 翻译 `design/CLAUDE.md`
  - [ ] 翻译 `design/registry/entities.yaml`（仅描述字段）

## 任务 13：翻译 docs/ 目录
- [ ] 任务 13：翻译文档目录文件
  - [ ] 翻译 `docs/CLAUDE.md`
  - [ ] 翻译 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`
  - [ ] 翻译 `docs/WORKFLOW-GUIDE.md`
  - [ ] 翻译 `docs/engine-reference/README.md`
  - [ ] 翻译 `docs/architecture/tr-registry.yaml`（仅描述字段）
  - [ ] 翻译 `docs/engine-reference/godot/VERSION.md`
  - [ ] 翻译 `docs/engine-reference/godot/breaking-changes.md`
  - [ ] 翻译 `docs/engine-reference/godot/current-best-practices.md`
  - [ ] 翻译 `docs/engine-reference/godot/deprecated-apis.md`
  - [ ] 翻译 `docs/engine-reference/godot/modules/animation.md`
  - [ ] 翻译 `docs/engine-reference/godot/modules/audio.md`
  - [ ] 翻译 `docs/engine-reference/godot/modules/input.md`
  - [ ] 翻译 `docs/engine-reference/godot/modules/navigation.md`
  - [ ] 翻译 `docs/engine-reference/godot/modules/networking.md`
  - [ ] 翻译 `docs/engine-reference/godot/modules/physics.md`
  - [ ] 翻译 `docs/engine-reference/godot/modules/rendering.md`

## 任务 14：翻译 .github/ 目录
- [ ] 任务 14：翻译 GitHub 模板文件
  - [ ] 翻译 `ISSUE_TEMPLATE/bug_report.md`
  - [ ] 翻译 `ISSUE_TEMPLATE/feature_request.md`
  - [ ] 翻译 `PULL_REQUEST_TEMPLATE.md`
  - [ ] 翻译 `CODEOWNERS`（如包含注释）
  - [ ] 翻译 `FUNDING.yml`（如包含注释）

## 任务 15：翻译 src/ 和 .claude/agent-memory/ 目录
- [ ] 任务 15：翻译剩余文件
  - [ ] 翻译 `src/CLAUDE.md`
  - [ ] 翻译 `.claude/agent-memory/lead-programmer/MEMORY.md`
  - [ ] 翻译 `.claude/statusline.sh` 注释

## 任务 16：提交所有翻译变更
- [ ] 任务 16：在 zh_cn 分支上提交变更
  - [ ] 确保所有翻译文件正确
  - [ ] 使用规范的提交信息提交所有变更

# 任务依赖关系

- 任务 0 是所有其他任务的前置条件
- 任务 1-15 之间相互独立，可并行执行
- 任务 16 依赖任务 1-15 全部完成
