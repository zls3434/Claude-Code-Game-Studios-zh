# 翻译修改：2026-05-20, 修改人: zls3434
#!/usr/bin/env bash
# 通知 hook —— 当 Claude Code 发送通知时触发
# 通过 PowerShell 显示 Windows 弹窗通知

# 从 stdin 读取通知 JSON
INPUT=$(cat)

# 提取消息 —— 优先使用 jq，备用 grep
if command -v jq &>/dev/null; then
  MESSAGE=$(echo "$INPUT" | jq -r '.message // empty' 2>/dev/null)
fi
if [ -z "$MESSAGE" ]; then
  MESSAGE=$(echo "$INPUT" | grep -oE '"message":"[^"]*"' | sed 's/"message":"//;s/"//')
fi
if [ -z "$MESSAGE" ]; then
  MESSAGE="Claude Code needs your attention"
fi

# 清理消息，使其安全嵌入 PowerShell 字符串（转义单引号）
MESSAGE_SAFE=$(echo "$MESSAGE" | sed "s/'/''/g" | head -c 200)

# 显示 Windows 气泡提示通知（适用于所有 Windows 10/11，无需额外模块）
powershell.exe -NonInteractive -WindowStyle Hidden -Command "
  Add-Type -AssemblyName System.Windows.Forms
  \$notify = New-Object System.Windows.Forms.NotifyIcon
  \$notify.Icon = [System.Drawing.SystemIcons]::Information
  \$notify.BalloonTipTitle = 'Claude Code'
  \$notify.BalloonTipText = '$MESSAGE_SAFE'
  \$notify.Visible = \$true
  \$notify.ShowBalloonTip(5000)
  Start-Sleep -Seconds 6
  \$notify.Dispose()
" 2>/dev/null &

echo "通知：$MESSAGE_SAFE"
