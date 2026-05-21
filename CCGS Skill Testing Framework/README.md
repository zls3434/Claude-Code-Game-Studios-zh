<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# CCGS Skill Testing Framework

**Claude Code Game Studios** 框架的质量保障基础设施。
测试 skill 和 agent 本身 — 而非任何使用它们构建的游戏。

> **本文件夹是自包含且可选的。**
> 使用 CCGS 的游戏开发者不需要它。要完全移除：
> `rm -rf "CCGS Skill Testing Framework"` — `.claude/` 中没有任何内容依赖它。

---

## 内容概览

```
CCGS Skill Testing Framework/
├── README.md              ← 你在这里
├── CLAUDE.md              ← 告知 Claude 如何使用此框架
├── catalog.yaml           ← 主注册表：全部 73 个 skill + 49 个 agent，覆盖追踪
├── quality-rubric.md      ← 按 category 分类的 PASS/FAIL 指标，用于 /skill-test category
│
├── skills/                ← skill 的行为规范文件（每个 skill 一个）
│   ├── gate/              ← gate category 规范
│   ├── review/            ← review category 规范
│   ├── authoring/         ← authoring category 规范
│   ├── readiness/         ← readiness category 规范
│   ├── pipeline/          ← pipeline category 规范
│   ├── analysis/          ← analysis category 规范
│   ├── team/              ← team category 规范
│   ├── sprint/            ← sprint category 规范
│   └── utility/           ← utility category 规范
│
├── agents/                ← agent 的行为规范文件（每个 agent 一个）
│   ├── directors/         ← creative-director, technical-director, producer, art-director
│   ├── leads/             ← lead-programmer, narrative-director, audio-director 等
│   ├── specialists/       ← engine/code/shader/UI 专家
│   ├── godot/             ← Godot 专属专家
│   ├── unity/             ← Unity 专属专家
│   ├── unreal/            ← Unreal 专属专家
│   ├── operations/        ← QA, live-ops, release, localization 等
│   └── creative/          ← writer, world-builder, game-designer 等
│
├── templates/             ← 用于编写新规范的 spec 文件模板
│   ├── skill-test-spec.md ← skill 行为规范模板
│   └── agent-test-spec.md ← agent 行为规范模板
│
└── results/               ← 测试运行输出（由 /skill-test spec 写入，已 gitignore）
```

---

## 使用方法

所有测试均由框架中已有的两个 skill 驱动：

### 检查结构合规性

```
/skill-test static [skill-name]     # 检查一个 skill（7 项检查）
/skill-test static all              # 检查所有 73 个 skill
```

### 运行行为规范测试

```
/skill-test spec gate-check         # 根据其书面规范评估一个 skill
/skill-test spec design-review
```

### 按 category rubric 检查

```
/skill-test category gate-check     # 根据其 category 指标评估一个 skill
/skill-test category all            # 对所有已分类 skill 运行 rubric 检查
```

### 查看完整覆盖图

```
/skill-test audit                   # Skills + agents：has-spec、最后测试时间、结果
```

### 改进一个失败的 skill

```
/skill-improve gate-check           # 测试 → 诊断 → 建议修复 → 重测 循环
```

---

## Skill 类别

| Category | Skills | 关键指标 |
|----------|--------|-------------|
| `gate` | gate-check | Review mode 读取，full/lean/solo director panel，不自动推进 |
| `review` | design-review, architecture-review, review-all-gdds | 只读，8-section 检查，正确裁决 |
| `authoring` | design-system, quick-design, art-bible, create-architecture, … | 逐 section 的 May-I-write，skeleton-first |
| `readiness` | story-readiness, story-done | 浮现 blocker，full mode 下的 director gate |
| `pipeline` | create-epics, create-stories, dev-story, map-systems, … | 上游依赖检查，交接路径清晰 |
| `analysis` | consistency-check, balance-check, code-review, tech-debt, … | 只读报告，裁决关键词，不执行写入 |
| `team` | team-combat, team-narrative, team-audio, … | 所有必需的 agent 被 spawn，blocked 被浮现 |
| `sprint` | sprint-plan, sprint-status, milestone-review, … | 读取 sprint 数据，状态关键词存在 |
| `utility` | start, adopt, hotfix, localize, setup-engine, … | 通过静态检查 |

---

## Agent 层级

| Tier | Agents |
|------|--------|
| `directors` | creative-director, technical-director, producer, art-director |
| `leads` | lead-programmer, narrative-director, audio-director, ux-designer, qa-lead, release-manager, localization-lead |
| `specialists` | gameplay-programmer, engine-programmer, ui-programmer, tools-programmer, network-programmer, ai-programmer, level-designer, sound-designer, technical-artist |
| `godot` | godot-specialist, godot-gdscript-specialist, godot-csharp-specialist, godot-shader-specialist, godot-gdextension-specialist |
| `unity` | unity-specialist, unity-ui-specialist, unity-shader-specialist, unity-dots-specialist, unity-addressables-specialist |
| `unreal` | unreal-specialist, ue-gas-specialist, ue-replication-specialist, ue-umg-specialist, ue-blueprint-specialist |
| `operations` | devops-engineer, security-engineer, performance-analyst, analytics-engineer, community-manager |
| `creative` | writer, world-builder, game-designer, economy-designer, systems-designer, prototyper |

---

## 更新 catalog

`catalog.yaml` 追踪每个 skill 和 agent 的测试覆盖情况。运行测试后：

- `/skill-test spec [name]` 会提示更新 `last_spec` 和 `last_spec_result`
- `/skill-test category [name]` 会提示更新 `last_category` 和 `last_category_result`
- `last_static` 和 `last_static_result` 需手动更新或通过 `/skill-improve` 更新

---

## 编写新 spec

1. 在 `templates/skill-test-spec.md` 找到 spec 模板
2. 将其复制到 `skills/[category]/[skill-name].md`
3. 更新 `catalog.yaml` 中的 `spec:` 字段以指向新文件
4. 运行 `/skill-test spec [skill-name]` 验证它

---

## 移除此框架

本文件夹与主项目没有任何挂钩。要移除：

```bash
rm -rf "CCGS Skill Testing Framework"
```

`/skill-test` 和 `/skill-improve` 这两个 skill 仍可正常工作 — 它们只会
报告 `catalog.yaml` 缺失，并建议运行 `/skill-test audit` 来初始化它。
