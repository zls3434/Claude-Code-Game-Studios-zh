# 翻译修改：2026-05-20, 修改人: zls3434
#!/bin/bash
# Claude Code PostToolUse hook：在 Skill 文件修改后建议运行 skill-test
# 当 .claude/skills/ 中的任意文件被写入或编辑时触发。
#
# 退出行为：
#   exit 0 = 仅建议（非阻塞）
#
# 输入 schema（Write|Edit 的 PostToolUse）：
# { "tool_name": "Write", "tool_input": { "file_path": "...", "content": "..." } }

INPUT=$(cat)

# 解析文件路径 —— 优先使用 jq，备用 grep
if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# 规范化路径分隔符（Windows 反斜杠转正斜杠）
FILE_PATH=$(echo "$FILE_PATH" | sed 's|\\|/|g')

# 仅对 .claude/skills/ 中的文件进行操作
if ! echo "$FILE_PATH" | grep -qE '(^|/)\.claude/skills/'; then
    exit 0
fi

# 从路径中提取 Skill 名称（.claude/skills/[skill-name]/SKILL.md）
SKILL_NAME=$(echo "$FILE_PATH" | grep -oE '\.claude/skills/[^/]+' | sed 's|\.claude/skills/||')

if [ -z "$SKILL_NAME" ]; then
    exit 0
fi

echo "=== Skill 已修改：$SKILL_NAME ===" >&2
echo "执行 /skill-test static $SKILL_NAME 来验证结构合规性。" >&2
echo "====================================" >&2

exit 0
