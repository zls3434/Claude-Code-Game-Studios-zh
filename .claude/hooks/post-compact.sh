# 翻译修改：2026-05-20, 修改人: zls3434
#!/usr/bin/env bash
# post-compact.sh — 对话压缩后触发
# 提醒 Claude 从文件备份中恢复会话状态。

ACTIVE="production/session-state/active.md"

echo "=== 压缩后上下文已恢复 ==="

if [ -f "$ACTIVE" ]; then
  SIZE=$(wc -l < "$ACTIVE" 2>/dev/null || echo "?")
  echo "会话状态文件存在：$ACTIVE（$SIZE 行）"
  echo "重要：请立即读取此文件以恢复工作上下文。"
  echo "其中包含：当前任务、已做出的决策、正在处理的文件、待解决的问题。"
else
  echo "未在 $ACTIVE 找到会话状态文件"
  echo "如果任务进行到一半，请查看 production/session-logs/ 获取上次会话审计。"
fi

echo "========================================="
