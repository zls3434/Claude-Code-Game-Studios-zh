#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 AGENTS.md（Codex 与 DeepSeek Harness 共用入口）。

从规范源 .claude/ 生成：
  - 项目根目录 AGENTS.md（Agent 花名册 + 协调规则 + 技能目录 + 安全约束）
  - src/AGENTS.md、docs/AGENTS.md、design/AGENTS.md（子目录规则，源自对应 CLAUDE.md）

AGENTS.md 是被 Codex、DeepSeek Harness (dsh)、Cursor、Windsurf 等广泛支持的
跨平台主配置开放标准。
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import lib

# Agent 三层架构分组（与 .claude/docs/agent-roster.md 保持一致）
TIER_GROUPS: list[tuple[str, list[str]]] = [
    ("第一层 —— 领导层（Opus）", [
        "creative-director", "technical-director", "producer",
    ]),
    ("第二层 —— 部门负责人（Sonnet）", [
        "game-designer", "lead-programmer", "art-director", "audio-director",
        "narrative-director", "qa-lead", "release-manager", "localization-lead",
    ]),
    ("第三层 —— 专业 Agent（Sonnet / Haiku）", [
        "systems-designer", "level-designer", "economy-designer",
        "gameplay-programmer", "engine-programmer", "ai-programmer",
        "network-programmer", "tools-programmer", "ui-programmer",
        "technical-artist", "sound-designer", "writer", "world-builder",
        "qa-tester", "performance-analyst", "devops-engineer",
        "analytics-engineer", "ux-designer", "prototyper", "security-engineer",
        "accessibility-specialist", "live-ops-designer", "community-manager",
    ]),
    ("引擎负责人（与项目引擎匹配，Sonnet）", [
        "unreal-specialist", "unity-specialist", "godot-specialist",
    ]),
    ("Unreal Engine 子专业（Sonnet）", [
        "ue-gas-specialist", "ue-blueprint-specialist",
        "ue-replication-specialist", "ue-umg-specialist",
    ]),
    ("Unity 子专业（Sonnet）", [
        "unity-dots-specialist", "unity-shader-specialist",
        "unity-addressables-specialist", "unity-ui-specialist",
    ]),
    ("Godot 子专业（Sonnet）", [
        "godot-gdscript-specialist", "godot-csharp-specialist",
        "godot-shader-specialist", "godot-gdextension-specialist",
    ]),
]

SUBDIR_FILES = ["src", "docs", "design"]

COORDINATION_RULES = """1. 纵向委派，不可越级：上层可向下层委派，禁止越级向下委派
2. 横向协商，无单方面决定权：同层 Agent 通过协商解决跨领域问题
3. 冲突由上一层级仲裁：同层协商 → 上级仲裁 → 用户最终决策
4. 变更须传播：设计/架构变更须传播到所有受影响方（见 /propagate-design-change）
5. 禁止单方面跨领域变更：不得修改不属于自己领域的文件"""

COLLAB_PROTOCOL = """**用户驱动的协作，而非自主执行。** 每个任务遵循五步流程：
1. **提问** — Agent 在提出解决方案前先提问，理解用户意图
2. **呈现选项** — Agent 展示 2-4 个选项及其优缺点
3. **决策** — 用户始终掌握决策权
4. **草稿** — Agent 在最终确认前展示成果
5. **审批** — 未经用户签字确认，不写入任何内容

关键约束：
- Agent 在使用写入/编辑工具前必须询问："我可以将此写入 [文件路径] 吗？"
- Agent 在请求审批前必须展示草稿或摘要
- 多文件修改需要针对完整变更集的明确审批
- 未经用户指示不得进行提交"""


def collect_agents(claude_dir: Path) -> dict[str, dict]:
    """读取全部 Agent 定义，返回 {name: metadata}。"""
    agents: dict[str, dict] = {}
    for path in lib.iter_agent_files(claude_dir):
        meta, _body = lib.split_frontmatter(lib.read_text(path))
        name = str(meta.get("name") or path.stem)
        agents[name] = meta
    return agents


def parse_workflow_catalog(catalog_path: Path) -> list[tuple[str, list[tuple[str, str]]]]:
    """从 workflow-catalog.yaml 提取 (阶段标签, [(命令, 描述)]) 列表。

    catalog 结构为受控的嵌套 YAML；此处用行扫描提取所需字段，
    避免对完整 YAML 解析器的硬依赖。
    """
    phases: list[tuple[str, list[tuple[str, str]]]] = []
    if not catalog_path.is_file():
        return phases
    label = ""
    command = ""
    description = ""
    steps: list[tuple[str, str]] = []
    for line in lib.read_text(catalog_path).split("\n"):
        m = re.match(r'^\s{4}label:\s*"(.*)"\s*$', line)
        if m:
            label = m.group(1)
            continue
        step_match = re.match(r"^\s+- id: \S+\s*$", line)
        if step_match:
            if command and description and label:
                steps.append((command, description))
            command, description = "", ""
            continue
        m = re.match(r"^\s+command: (\S+)\s*$", line)
        if m:
            command = m.group(1)
            continue
        m = re.match(r'^\s+description:\s*"(.*)"\s*$', line)
        if m:
            description = m.group(1)
            continue
        # 新阶段开始（顶层 phases 下的两空格缩进键）
        if re.match(r"^  [a-z][\w-]*:\s*$", line) and label:
            if steps or command:
                if command and description:
                    steps.append((command, description))
                    command, description = "", ""
                phases.append((label, steps))
            label, steps = "", []
    if command and description:
        steps.append((command, description))
    if label and steps:
        phases.append((label, steps))
    return phases


def fallback_skills(claude_dir: Path) -> list[tuple[str, list[tuple[str, str]]]]:
    """catalog 缺失时，直接扫描技能目录生成清单。"""
    steps = []
    for skill_dir in lib.iter_skill_files(claude_dir):
        meta, _ = lib.split_frontmatter(lib.read_text(skill_dir / "SKILL.md"))
        name = str(meta.get("name") or skill_dir.name)
        steps.append((f"/{name}", str(meta.get("description") or "")))
    return [("全部技能", steps)] if steps else []


def render_roster(agents: dict[str, dict]) -> str:
    grouped = {name for _, names in TIER_GROUPS for name in names}
    sections = []
    for title, names in TIER_GROUPS:
        rows = []
        for name in names:
            meta = agents.get(name)
            if not meta:
                continue
            desc = str(meta.get("description") or "").strip()
            rows.append(f"| `{name}` | {desc} |")
        sections.append(f"### {title}（{len(rows)} 个）\n\n| Agent | 职责 |\n|---|---|\n" + "\n".join(rows))
    # 未分组的 Agent 兜底列出，防止新增 Agent 后遗漏
    extra = sorted(set(agents) - grouped)
    if extra:
        rows = [f"| `{n}` | {agents[n].get('description', '')} |" for n in extra]
        sections.append(
            f"### 其他（{len(rows)} 个）\n\n| Agent | 职责 |\n|---|---|\n" + "\n".join(rows)
        )
    return "\n\n".join(sections)


def render_root(claude_dir: Path, agents: dict[str, dict], skills: list) -> str:
    agent_count = len(agents)
    # 技能总数以实际技能目录为准；catalog 编排数可能因复用/缺省而不同
    skill_dirs = list(lib.iter_skill_files(claude_dir))
    skill_total = len(skill_dirs)
    skill_sections = []
    covered: set[str] = set()
    for label, steps in skills:
        lines = []
        for cmd, desc in steps:
            covered.add(cmd.lstrip("/"))
            lines.append(f"- {cmd} — {desc}")
        skill_sections.append(f"### {label}\n\n" + "\n".join(lines))
    # 补列未编入 workflow-catalog 的技能，保证清单完整
    others = []
    for skill_dir in skill_dirs:
        if skill_dir.name in covered:
            continue
        meta, _ = lib.split_frontmatter(lib.read_text(skill_dir / "SKILL.md"))
        others.append(f"- /{skill_dir.name} — {meta.get('description', '')}")
    if others:
        skill_sections.append("### 其他技能\n\n" + "\n".join(sorted(others)))
    skills_text = "\n\n".join(skill_sections)

    return f"""{lib.GENERATED_NOTICE}
# AGENTS.md — Claude Code Game Studios

适用于 **Codex**、**DeepSeek Harness（dsh）** 及所有读取 AGENTS.md 开放标准的 Agent 工具。
Claude Code 用户请继续使用 `CLAUDE.md`（规范源入口，本文件由其派生）。

## 语言要求

必须始终使用简体中文与用户对话，生成的文档与代码注释也必须使用简体中文编写。

## 项目概述

Claude Code Game Studios 通过 {agent_count} 个协调的 AI Agent 管理独立游戏开发。
每个 Agent 负责一个特定领域，确保关注点分离和质量把控。

**核心理念：用户驱动的协作，而非自主执行。**

## 技术栈

- **引擎**：[选择：Godot 4 / Unity / Unreal Engine 5]
- **语言**：[选择：GDScript / C# / C++ / Blueprint]
- **版本控制**：Git，采用基于主干的开发模式

> 引擎一经选定，请同步配置 `.claude/docs/technical-preferences.md`，
> 并使用与引擎匹配的引擎专属 Agent 集合。

## Agent 花名册（{agent_count} 个）

完整定义位于 `.claude/agents/`（每个 Agent 一个文件，含触发条件与协作协议）。

{render_roster(agents)}

## 协调规则

{COORDINATION_RULES}

详细规则见 `.claude/docs/coordination-rules.md`。

## 协作协议

{COLLAB_PROTOCOL}

完整协议见 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`。

## 技能 / 工作流（{skill_total} 个）

技能定义位于 `.claude/skills/<技能名>/SKILL.md`（Agent Skills 开放标准格式，
Codex / dsh / Trae 等可直接读取）。按开发阶段分类：

{skills_text}

## 编码规范

- 游戏性数值必须数据驱动（外部配置文件），绝不可硬编码
- 所有依赖时间的计算必须使用 delta time（帧率无关）
- 使用事件/信号进行跨系统通信，禁止直接引用 UI 代码
- 测试遵循 AAA 模式，逻辑与表现分离，位于 `tests/` 目录
- 提交必须引用相关的 Story ID 或设计文档
- 路径范围规则见 `.claude/rules/`（gameplay / engine / ui / network / shader 等分类）

## 平台能力差异（降级说明）

以下功能为 Claude Code 专属，在本平台以降级形式提供：

| 功能 | 降级方式 |
|---|---|
| Hook 自动验证（提交/推送/资产校验） | 提交前人工执行 `bash .claude/hooks/validate-commit.sh` 等检查 |
| 权限控制（settings.json） | 遵守下方"安全注意事项"文档指令 |
| 模型层级分配（Opus/Sonnet/Haiku） | 所有任务使用平台默认模型 |
| 子 Agent 自动派发 | 通过 `.claude/agents/` 定义 + 技能工作流模拟（dsh 原生支持子代理委派） |

## 安全注意事项

- 禁止执行 `rm -rf`、`git push --force`、`git reset --hard`、`sudo` 等危险命令
- 禁止读取或写入 `.env` 及任何含密钥/令牌的文件
- 敏感信息禁止硬编码，一律通过环境变量注入
- 未经用户明确指示不得进行 git 提交或推送

## 维护

修改规范源 `.claude/` 后运行：

```
python tools/adapters/sync_all.py
```
"""


def render_subdir(claude_dir: Path, subdir: str) -> str:
    """从子目录 CLAUDE.md 生成对应 AGENTS.md（轻量转换，保持内容同步）。"""
    source = claude_dir.parent / subdir / "CLAUDE.md"
    _meta, body = lib.split_frontmatter(lib.read_text(source))
    body = lib.strip_leading_comments(body).strip()
    # 引用调整：CLAUDE.md 特有指引用相对文档路径替代
    body = body.replace(
        "请参阅 `CLAUDE.md` → 技术偏好 → 引擎专家 → 文件扩展名路由。",
        "请参阅 `.claude/docs/technical-preferences.md` 的 引擎专家/文件扩展名路由。",
    )
    body = body.replace(
        "如有疑问，请使用 `CLAUDE.md` 中配置的主要引擎专家。",
        "如有疑问，请使用 `.claude/docs/technical-preferences.md` 中配置的主要引擎专家。",
    )
    return f"""{lib.GENERATED_NOTICE}
# {subdir}/ 目录规则（AGENTS.md）

> 本文件由 `{subdir}/CLAUDE.md` 派生，供 Codex / DeepSeek Harness 等读取 AGENTS.md 的工具使用。

{body}
"""


def main() -> int:
    root = lib.project_root()
    claude_dir = root / ".claude"

    agents = collect_agents(claude_dir)
    if not agents:
        print("错误：未在 .claude/agents/ 找到 Agent 定义", file=sys.stderr)
        return 1

    skills = parse_workflow_catalog(claude_dir / "docs" / "workflow-catalog.yaml")
    if not skills:
        skills = fallback_skills(claude_dir)

    lib.write_text(root / "AGENTS.md", render_root(claude_dir, agents, skills))
    skill_total = len(list(lib.iter_skill_files(claude_dir)))
    print(f"AGENTS.md 已生成（{len(agents)} 个 Agent，{skill_total} 个技能）")

    for subdir in SUBDIR_FILES:
        source = root / subdir / "CLAUDE.md"
        if source.is_file():
            lib.write_text(root / subdir / "AGENTS.md", render_subdir(claude_dir, subdir))
            print(f"{subdir}/AGENTS.md 已生成")
        else:
            print(f"跳过 {subdir}/AGENTS.md（无对应 CLAUDE.md）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
