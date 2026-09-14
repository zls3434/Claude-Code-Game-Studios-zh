#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""共享工具库：frontmatter 解析与文件读写。

规范源为 .claude/ 目录（Claude Code 原生配置）。
本模块仅依赖 Python 标准库；若环境中安装了 PyYAML，则优先使用其解析 frontmatter，
否则回退到内置的精简 YAML 解析器（覆盖本项目 frontmatter 所用语法子集）。
"""

from __future__ import annotations

import re
from pathlib import Path

try:  # PyYAML 可选依赖
    import yaml  # type: ignore

    _HAS_PYYAML = True
except ImportError:  # pragma: no cover
    _HAS_PYYAML = False

# 生成文件头部声明
GENERATED_NOTICE = (
    "<!-- 本文件由 tools/adapters/ 自动生成，请勿手动修改。\n"
    "     修改规范源 .claude/ 后运行 python tools/adapters/sync_all.py 重新生成。 -->"
)


def project_root() -> Path:
    """返回项目根目录（tools/adapters/ 的上两级）。"""
    return Path(__file__).resolve().parents[2]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text(path: Path, text: str) -> None:
    """写入文件，统一使用 LF 换行，避免跨平台 git diff 噪音。"""
    path.parent.mkdir(parents=True, exist_ok=True)
    text = text.replace("\r\n", "\n")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def strip_leading_comments(text: str) -> str:
    """去除文件开头的 HTML 注释行（如翻译标记）。"""
    return re.sub(r"^(<!--.*?-->\s*\n)+", "", text, count=1, flags=re.DOTALL)


def split_frontmatter(text: str) -> tuple[dict, str]:
    """拆分 YAML frontmatter 与正文，返回 (metadata, body)。

    兼容 frontmatter 之前存在 HTML 注释行的情况（.claude/rules/ 采用此格式）。
    """
    text = strip_leading_comments(text)
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n?(.*)$", text, re.DOTALL)
    if not match:
        return {}, text
    return parse_simple_yaml(match.group(1)), match.group(2)


def parse_simple_yaml(raw: str) -> dict:
    """解析 YAML 字符串。优先 PyYAML，失败或未安装时回退到精简解析器。"""
    if _HAS_PYYAML:
        try:
            data = yaml.safe_load(raw)
            return data if isinstance(data, dict) else {}
        except Exception:
            pass
    return _minimal_yaml(raw)


def _parse_scalar(s: str):
    s = s.strip()
    if s.startswith("[") and s.endswith("]"):
        inner = s[1:-1].strip()
        if not inner:
            return []
        return [v.strip().strip("\"'") for v in inner.split(",")]
    if len(s) >= 2 and s[0] == s[-1] and s[0] in "\"'":
        return s[1:-1]
    return s


def _minimal_yaml(raw: str) -> dict:
    """精简 YAML 解析器，覆盖本项目 frontmatter 语法子集：
    单层键值、行内标量、行内列表 [a, b]、块列表（- item）。
    """
    result: dict = {}
    lines = [ln for ln in raw.split("\n") if ln.strip() and not ln.strip().startswith("#")]
    i = 0
    while i < len(lines):
        m = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", lines[i])
        if not m:
            i += 1
            continue
        key, value = m.group(1), m.group(2).strip()
        if value:
            result[key] = _parse_scalar(value)
        else:
            # 块列表
            items = []
            j = i + 1
            while j < len(lines):
                lm = re.match(r"^\s+-\s+(.*)$", lines[j])
                if not lm:
                    break
                items.append(_parse_scalar(lm.group(1)))
                j += 1
            result[key] = items
            i = j - 1
        i += 1
    return result


def iter_agent_files(claude_dir: Path):
    """遍历规范源中的 Agent 定义文件，按文件名排序。"""
    return sorted((claude_dir / "agents").glob("*.md"))


def iter_skill_files(claude_dir: Path):
    """遍历规范源中的技能目录（含 SKILL.md），按技能名排序。"""
    return sorted(
        d for d in (claude_dir / "skills").iterdir()
        if d.is_dir() and (d / "SKILL.md").is_file()
    )


def iter_rule_files(claude_dir: Path):
    """遍历规范源中的路径规则文件，按文件名排序。"""
    return sorted((claude_dir / "rules").glob("*.md"))


def as_list(value) -> list:
    """把 frontmatter 中的标量/列表统一为列表。"""
    if value is None:
        return []
    if isinstance(value, list):
        return value
    if isinstance(value, str):
        inner = [v.strip() for v in value.split(",") if v.strip()]
        return inner if inner else [value]
    return [value]
