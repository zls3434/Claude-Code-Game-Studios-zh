# 翻译修改：2026-05-20, 修改人: zls3434
#!/bin/bash
# Claude Code SessionStart hook：会话启动时加载项目上下文
# 输出 Claude 在会话开始时看到的上下文信息
#
# 输入 schema（SessionStart）：无 stdin 输入

echo "=== Claude Code Game Studios — 会话上下文 ==="

# 当前分支
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ]; then
    echo "分支：$BRANCH"

    # 最近的提交
    echo ""
    echo "最近提交："
    git log --oneline -5 2>/dev/null | while read -r line; do
        echo "  $line"
    done
fi

# 当前 Sprint（找到最近的 sprint 文件）
LATEST_SPRINT=$(ls -t production/sprints/sprint-*.md 2>/dev/null | head -1)
if [ -n "$LATEST_SPRINT" ]; then
    echo ""
    echo "活跃 Sprint：$(basename "$LATEST_SPRINT" .md)"
fi

# 当前里程碑
LATEST_MILESTONE=$(ls -t production/milestones/*.md 2>/dev/null | head -1)
if [ -n "$LATEST_MILESTONE" ]; then
    echo "活跃里程碑：$(basename "$LATEST_MILESTONE" .md)"
fi

# 未解决 Bug 数量
BUG_COUNT=0
for dir in tests/playtest production; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "BUG-*.md" 2>/dev/null | wc -l)
        BUG_COUNT=$((BUG_COUNT + count))
    fi
done
if [ "$BUG_COUNT" -gt 0 ]; then
    echo "未解决 Bug：$BUG_COUNT"
fi

# 代码健康快速检查
if [ -d "src" ]; then
    TODO_COUNT=$(grep -r "TODO" src/ 2>/dev/null | wc -l)
    FIXME_COUNT=$(grep -r "FIXME" src/ 2>/dev/null | wc -l)
    if [ "$TODO_COUNT" -gt 0 ] || [ "$FIXME_COUNT" -gt 0 ]; then
        echo ""
        echo "代码健康：src/ 中有 ${TODO_COUNT} 个 TODO，${FIXME_COUNT} 个 FIXME"
    fi
fi

# --- 活跃会话状态恢复 ---
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
    echo ""
    echo "=== 检测到活跃会话状态 ==="
    echo "上次会话留下的状态位于：$STATE_FILE"
    echo "请读取此文件以恢复上下文并从上次中断处继续。"
    echo ""
    echo "快速摘要（最后 20 行）："
    tail -20 "$STATE_FILE" 2>/dev/null
    TOTAL_LINES=$(wc -l < "$STATE_FILE" 2>/dev/null)
    if [ "$TOTAL_LINES" -gt 20 ]; then
        echo "  ... （共 $TOTAL_LINES 行 — 读取完整文件以继续）"
    fi
    echo "=== 会话状态预览结束 ==="
fi

echo "==================================="
exit 0
