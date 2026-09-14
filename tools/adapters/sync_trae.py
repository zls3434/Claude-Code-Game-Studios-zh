#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 Trae IDE 配置（.trae/）。

从规范源 .claude/ 生成：
  - .trae/agents/*.md        — Agent 定义直接复制（Trae 兼容该 frontmatter 格式）
  - .trae/rules/project_rules.md — 路径规则拼接为单文件内联规则
  - .trae/skills/<名称>/SKILL.md — 技能直接复制（Agent Skills 标准兼容）

注意：不触碰 .trae/ 下已有的其他目录（如 specs/）。
"""

from __future__ import annotations

import re
import shutil
import sys
from pathlib import Path

import lib

def project_overview(agent_count: int) -> str:
    return f"""通过 {agent_count} 个协调的 AI Agent 管理独立游戏开发。每个 Agent 负责一个特定领域，
确保关注点分离和质量把控。Agent 定义位于 `.trae/agents/`（{agent_count} 个，三层架构），
技能位于 `.trae/skills/`（Agent Skills 标准格式）。

**语言要求：必须始终使用简体中文与用户对话，生成的文档与代码注释也必须使用简体中文编写。**

三层 Agent 架构：
- 领导层（3，Opus）：creative-director、technical-director、producer
- 部门负责人层（8，Sonnet）：game-designer、lead-programmer、art-director、audio-director、
  narrative-director、qa-lead、release-manager、localization-lead
- 专业层 + 引擎专属（38，Sonnet/Haiku）：详见 `.claude/docs/agent-roster.md`"""

TECH_STACK = """- 引擎：[选择：Godot 4 / Unity / Unreal Engine 5]（通过 /setup-engine 配置）
- 语言：[选择：GDScript / C# / C++ / Blueprint]
- 版本控制：Git，采用基于主干的开发模式

> 存在针对 Godot、Unity 和 Unreal 的引擎专业 Agent（.trae/agents/）。
> 请使用与项目引擎匹配的集合。"""

RULES_HEADER = """1. 纵向委派，不可越级：上层可向下层委派，禁止越级向下委派
2. 横向协商，无单方面决定权：同层 Agent 通过协商解决跨领域问题
3. 冲突由上一层级仲裁：同层协商 → 上级仲裁 → 用户最终决策
4. 变更须传播：设计/架构变更须传播到所有受影响方
5. 禁止单方面跨领域变更：不得修改不属于自己领域的文件"""

PROTOCOL = """**用户驱动的协作，而非自主执行。** 每个任务遵循：提问 → 选项 → 决策 → 草稿 → 审批。

关键约束：
- Agent 在使用写入/编辑工具前必须询问："我可以将此写入 [文件路径] 吗？"
- Agent 在请求审批前必须展示草稿或摘要
- 多文件修改需要针对完整变更集的明确审批
- 未经用户指示不得进行提交"""


def sync_agents(claude_dir: Path, trae_dir: Path) -> int:
    out_dir = trae_dir / "agents"
    out_dir.mkdir(parents=True, exist_ok=True)
    count = 0
    for src in lib.iter_agent_files(claude_dir):
        # 直接复制：Trae 兼容 Claude Code Agent 的 frontmatter（name/description/tools/model 等）
        lib.write_text(out_dir / src.name, lib.read_text(src))
        count += 1
    return count


def sync_skills(claude_dir: Path, trae_dir: Path) -> int:
    out_root = trae_dir / "skills"
    count = 0
    for skill_dir in lib.iter_skill_files(claude_dir):
        dest = out_root / skill_dir.name
        dest.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(skill_dir / "SKILL.md", dest / "SKILL.md")
        count += 1
    return count


def render_project_rules(claude_dir: Path, agent_count: int) -> str:
    sections = []
    for rule_path in lib.iter_rule_files(claude_dir):
        meta, body = lib.split_frontmatter(lib.read_text(rule_path))
        paths = lib.as_list(meta.get("paths"))
        scope = "、".join(f"`{p}`" for p in paths) if paths else "全局"
        body = body.strip()
        # 用规则体自带的一级标题作为小节标题，避免标题层级冲突
        title = rule_path.stem
        m = re.match(r"^#\s+(.+?)\s*$", body, re.MULTILINE)
        if m:
            title = m.group(1)
            body = body[m.end():].strip()
        sections.append(f"## {title}（适用：{scope}）\n\n{body}\n")

    rules_text = "\n".join(sections)
    return f"""{lib.GENERATED_NOTICE}
# Claude Code Game Studios — Trae 项目规则

## 项目概述

{project_overview(agent_count)}

## 技术栈

{TECH_STACK}

## Agent 协调规则

{RULES_HEADER}

详细规则见 `.claude/docs/coordination-rules.md`。

## 协作协议

{PROTOCOL}

完整协议见 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`。

## 路径范围规则

以下规则按源文件内联，原始定义位于 `.claude/rules/`（YAML frontmatter 含 paths 适用范围）。

{rules_text}
"""


def main() -> int:
    root = lib.project_root()
    claude_dir = root / ".claude"
    trae_dir = root / ".trae"
    trae_dir.mkdir(parents=True, exist_ok=True)

    agent_count = sync_agents(claude_dir, trae_dir)
    skill_count = sync_skills(claude_dir, trae_dir)
    lib.write_text(trae_dir / "rules" / "project_rules.md", render_project_rules(claude_dir, agent_count))

    print(f"Trae 配置已生成：agents/{agent_count} 个、skills/{skill_count} 个、rules/project_rules.md")
    return 0


if __name__ == "__main__":
    sys.exit(main())
