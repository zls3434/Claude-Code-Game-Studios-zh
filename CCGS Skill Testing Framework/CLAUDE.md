<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# CCGS Skill Testing Framework — Claude 使用说明

本文件夹是 Claude Code Game Studios skill/agent 框架的质量保障层。
它是自包含的，独立于任何游戏项目。

## 关键文件

| 文件 | 用途 |
|------|---------|
| `catalog.yaml` | 全部 73 个 skill 和 49 个 agent 的主注册表。包含 category、spec 路径和最近测试跟踪字段。执行任何测试命令时，始终首先读取此文件。 |
| `quality-rubric.md` | 按 category 分类的 PASS/FAIL 指标。运行 `/skill-test category` 时，请阅读对应 skill category 的 `###` 章节。 |
| `skills/[category]/[name].md` | skill 的行为规范 — 5 个测试用例 + 协议合规性断言。 |
| `agents/[tier]/[name].md` | agent 的行为规范 — 5 个测试用例 + 协议合规性断言。 |
| `templates/skill-test-spec.md` | 编写新 skill spec 文件的模板。 |
| `templates/agent-test-spec.md` | 编写新 agent spec 文件的模板。 |
| `results/` | 由 `/skill-test spec` 在保存结果时写入。已通过 .gitignore 忽略。 |

## 路径约定

- Skill specs：`CCGS Skill Testing Framework/skills/[category]/[name].md`
- Agent specs：`CCGS Skill Testing Framework/agents/[tier]/[name].md`
- Catalog：`CCGS Skill Testing Framework/catalog.yaml`
- Rubric：`CCGS Skill Testing Framework/quality-rubric.md`

`catalog.yaml` 中的 `spec:` 字段是每个 skill/agent spec 的权威路径。
始终读取该字段，而不是猜测路径。

## Skill 类别

```
gate        → gate-check
review      → design-review, architecture-review, review-all-gdds
authoring   → design-system, quick-design, architecture-decision, art-bible,
              create-architecture, ux-design, ux-review
readiness   → story-readiness, story-done
pipeline    → create-epics, create-stories, dev-story, create-control-manifest,
              propagate-design-change, map-systems
analysis    → consistency-check, balance-check, content-audit, code-review,
              tech-debt, scope-check, estimate, perf-profile, asset-audit,
              security-audit, test-evidence-review, test-flakiness
team        → team-combat, team-narrative, team-audio, team-level, team-ui,
              team-qa, team-release, team-polish, team-live-ops
sprint      → sprint-plan, sprint-status, milestone-review, retrospective,
              changelog, patch-notes
utility     → 所有其他 skill
```

## Agent 层级

```
directors   → creative-director, technical-director, producer, art-director
leads       → lead-programmer, narrative-director, audio-director, ux-designer,
              qa-lead, release-manager, localization-lead
specialists → gameplay-programmer, engine-programmer, ui-programmer,
              tools-programmer, network-programmer, ai-programmer,
              level-designer, sound-designer, technical-artist
godot       → godot-specialist, godot-gdscript-specialist, godot-csharp-specialist,
              godot-shader-specialist, godot-gdextension-specialist
unity       → unity-specialist, unity-ui-specialist, unity-shader-specialist,
              unity-dots-specialist, unity-addressables-specialist
unreal      → unreal-specialist, ue-gas-specialist, ue-replication-specialist,
              ue-umg-specialist, ue-blueprint-specialist
operations  → devops-engineer, security-engineer, performance-analyst,
              analytics-engineer, community-manager
creative    → writer, world-builder, game-designer, economy-designer,
              systems-designer, prototyper
```

## 测试 skill 的工作流程

1. 读取 `catalog.yaml` 获取该 skill 的 `spec:` 路径和 `category:`
2. 读取位于 `.claude/skills/[name]/SKILL.md` 的 skill
3. 读取 `spec:` 路径下的 spec
4. 逐用例评估断言
5. 提供将结果写入 `results/` 并更新 `catalog.yaml` 的选项

## 改进 skill 的工作流程

使用 `/skill-improve [name]`。它处理完整循环：
test → diagnose → propose fix → rewrite → retest → keep or revert。

## Spec 有效性说明

本文件夹中的 spec 描述的是**当前行为**，而非理想行为。它们是
通过读取 skill 编写而成的，因此可能包含 bug。当 skill 在实际中表现异常时，
先修正 skill，然后更新 spec 以匹配修正后的行为。
将 spec 失败视为"需要调查的事项"，而非"skill 一定有问题"。

## 本文件夹可删除

`.claude/` 中没有任何内容导入本文件夹。删除本文件夹对
CCGS skill 或 agent 本身没有任何影响。`/skill-test` 和 `/skill-improve` 会报告
`catalog.yaml` 缺失，并引导用户初始化它。
