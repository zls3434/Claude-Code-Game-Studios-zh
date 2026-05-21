# 翻译修改：2026-05-20, 修改人: zls3434
#!/bin/bash
# Claude Code Stop hook：Claude 完成时记录会话摘要
# 记录已完成的工作，用于审计追踪和 Sprint 跟踪

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SESSION_LOG_DIR="production/session-logs"

mkdir -p "$SESSION_LOG_DIR" 2>/dev/null

# 记录本次会话中最近的 git 活动（最长 8 小时，适配长会话）
RECENT_COMMITS=$(git log --oneline --since="8 hours ago" 2>/dev/null)
MODIFIED_FILES=$(git diff --name-only 2>/dev/null)

# --- 关闭时归档活跃会话状态（不删除）---
# active.md 在干净退出后保留，以便多会话恢复。
# 仅在手动删除或显式替代时才可合法删除 active.md。
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
    {
        echo "## 已归档会话状态：$TIMESTAMP"
        cat "$STATE_FILE"
        echo "---"
        echo ""
    } >> "$SESSION_LOG_DIR/session-log.md" 2>/dev/null
fi

if [ -n "$RECENT_COMMITS" ] || [ -n "$MODIFIED_FILES" ]; then
    {
        echo "## 会话结束：$TIMESTAMP"
        if [ -n "$RECENT_COMMITS" ]; then
            echo "### 提交"
            echo "$RECENT_COMMITS"
        fi
        if [ -n "$MODIFIED_FILES" ]; then
            echo "### 未提交更改"
            echo "$MODIFIED_FILES"
        fi
        echo "---"
        echo ""
    } >> "$SESSION_LOG_DIR/session-log.md" 2>/dev/null
fi

exit 0
