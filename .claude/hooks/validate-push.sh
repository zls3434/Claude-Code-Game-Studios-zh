# 翻译修改：2026-05-20, 修改人: zls3434
#!/bin/bash
# Claude Code PreToolUse hook：验证 git push 命令
# 对推送到受保护分支的操作发出警告
# 退出码 0 = 允许，退出码 2 = 阻止
#
# 输入 schema（Bash 的 PreToolUse）：
# { "tool_name": "Bash", "tool_input": { "command": "git push origin main" } }

INPUT=$(cat)

# 解析命令 —— 优先使用 jq，备用 grep
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
else
    COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# 仅处理 git push 命令
if ! echo "$COMMAND" | grep -qE '^git[[:space:]]+push'; then
    exit 0
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
MATCHED_BRANCH=""

# 检查是否推送到受保护分支
for branch in develop main master; do
    if [ "$CURRENT_BRANCH" = "$branch" ]; then
        MATCHED_BRANCH="$branch"
        break
    fi
    # 同时检查是否在命令中显式指定推送到受保护分支（为安全起见加引号）
    if echo "$COMMAND" | grep -qE "[[:space:]]${branch}([[:space:]]|$)"; then
        MATCHED_BRANCH="$branch"
        break
    fi
done

if [ -n "$MATCHED_BRANCH" ]; then
    echo "检测到推送到受保护分支 '$MATCHED_BRANCH'。" >&2
    echo "提醒：确保构建通过、单元测试通过、且无 S1/S2 级别 Bug。" >&2
    # 允许推送但发出警告 —— 取消下方注释可改为阻止：
    # echo "已阻止：推送前请先在 $CURRENT_BRANCH 上运行测试" >&2
    # exit 2
fi

exit 0
