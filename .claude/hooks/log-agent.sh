# 翻译修改：2026-05-20, 修改人: zls3434
#!/bin/bash
# Claude Code SubagentStart hook：记录 Agent 调用日志用于审计追踪
# 追踪使用了哪些 Agent 以及何时使用
#
# 输入 schema（SubagentStart）—— 依据 Claude Code hooks 参考文档：
# { "session_id": "...", "agent_id": "agent-abc123", "agent_type": "Explore", ... }
#
# Agent 名称在 `agent_type` 中，而非 `agent_name`。读取 `.agent_name`
# 每次调用都返回 null，因此备用值 "unknown" 总是被使用，
# 审计追踪记录不到有用信息。

INPUT=$(cat)

# 解析 Agent 名称 —— 优先使用 jq，备用 grep
if command -v jq >/dev/null 2>&1; then
    AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_type // "unknown"' 2>/dev/null)
else
    AGENT_NAME=$(echo "$INPUT" | grep -oE '"agent_type"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"agent_type"[[:space:]]*:[[:space:]]*"//;s/"$//')
    [ -z "$AGENT_NAME" ] && AGENT_NAME="unknown"
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SESSION_LOG_DIR="production/session-logs"

mkdir -p "$SESSION_LOG_DIR" 2>/dev/null

echo "$TIMESTAMP | Agent 已调用：$AGENT_NAME" >> "$SESSION_LOG_DIR/agent-audit.log" 2>/dev/null

exit 0
