#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""平台同步总入口：从规范源 .claude/ 生成各平台配置。

用法：
    python tools/adapters/sync_all.py            # 同步全部平台
    python tools/adapters/sync_all.py codex       # 仅同步 AGENTS.md（Codex / DeepSeek Harness）
    python tools/adapters/sync_all.py trae        # 仅同步 .trae/（Trae IDE）

平台与输出对照：
    codex  → AGENTS.md + src|docs|design/AGENTS.md（DeepSeek Harness 共用）
    trae   → .trae/agents/ + .trae/rules/project_rules.md + .trae/skills/
"""

from __future__ import annotations

import sys

import sync_agents_md
import sync_trae

ALL_PLATFORMS = ("codex", "trae")


def main(argv: list[str]) -> int:
    platforms = [a.lstrip("-").lower() for a in argv[1:] if not a.startswith("--")]
    platforms = [p for p in platforms if p in ALL_PLATFORMS] or list(ALL_PLATFORMS)

    print("=== Claude Code Game Studios 平台同步 ===")
    print("规范源: .claude/\n")

    failed = False
    if "codex" in platforms:
        try:
            rc = sync_agents_md.main()
            failed = failed or rc != 0
        except Exception as exc:  # noqa: BLE001
            print(f"错误：codex 同步失败：{exc}", file=sys.stderr)
            failed = True
        print()
    if "trae" in platforms:
        try:
            rc = sync_trae.main()
            failed = failed or rc != 0
        except Exception as exc:  # noqa: BLE001
            print(f"错误：trae 同步失败：{exc}", file=sys.stderr)
            failed = True
        print()

    print("=== 同步完成 ===" if not failed else "=== 同步完成（存在失败项）===")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
