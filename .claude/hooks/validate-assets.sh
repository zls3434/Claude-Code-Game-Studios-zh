# 翻译修改：2026-05-20, 修改人: zls3434
#!/bin/bash
# Claude Code PostToolUse hook：在 Write/Edit 之后验证资产文件
# 检查 assets/ 目录中文件的命名规范
#
# 退出行为：
#   exit 0 = 成功或仅建议性警告（非阻塞）
#   exit 1 = 阻塞性错误（构建中断问题：无效 JSON、缺少必需字段）
#
# 输入 schema（Write/Edit 的 PostToolUse）：
# { "tool_name": "Write", "tool_input": { "file_path": "assets/data/foo.json", "content": "..." } }

INPUT=$(cat)

# 解析文件路径 —— 优先使用 jq，备用 grep
if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# 规范化路径分隔符（Windows 反斜杠转正斜杠）
FILE_PATH=$(echo "$FILE_PATH" | sed 's|\\|/|g')

# 仅检查 assets/ 中的文件
if ! echo "$FILE_PATH" | grep -qE '(^|/)assets/'; then
    exit 0
fi

FILENAME=$(basename "$FILE_PATH")
WARNINGS=""   # 风格/规范问题 —— exit 0 附带建议消息
ERRORS=""     # 构建中断问题 —— exit 1 阻止操作

# 建议：检查命名规范（仅小写字母和下划线）
# 命名问题是风格违规 —— 警告但不阻止
# 使用 grep -E（POSIX）而非 grep -P（Perl），以兼容 Windows Git Bash
if echo "$FILENAME" | grep -qE '[A-Z[:space:]-]'; then
    WARNINGS="$WARNINGS\n  命名：$FILE_PATH 必须使用小写字母和下划线（当前为：$FILENAME）"
fi

# 阻塞：检查数据文件的 JSON 有效性
# 无效 JSON 将导致运行时加载失败 —— 这是构建中断错误
if echo "$FILE_PATH" | grep -qE '(^|/)assets/data/.*\.json$'; then
    if [ -f "$FILE_PATH" ]; then
        # 查找可用的 Python 命令
        PYTHON_CMD=""
        for cmd in python python3 py; do
            if command -v "$cmd" >/dev/null 2>&1; then
                PYTHON_CMD="$cmd"
                break
            fi
        done

        if [ -n "$PYTHON_CMD" ]; then
            if ! "$PYTHON_CMD" -m json.tool "$FILE_PATH" > /dev/null 2>&1; then
                ERRORS="$ERRORS\n  格式：$FILE_PATH 不是有效的 JSON —— 请修复语法错误再继续"
            fi
        fi
    fi
fi

# 报告警告（建议性 —— 非阻塞）
if [ -n "$WARNINGS" ]; then
    echo -e "=== 资产验证：警告 ===$WARNINGS\n==================================\n（警告为建议性。请在最终提交前修复。）" >&2
fi

# 报告错误，如发现构建中断问题则阻止
if [ -n "$ERRORS" ]; then
    echo -e "=== 资产验证：错误（阻塞） ===$ERRORS\n===========================================\n请修复这些错误再继续。" >&2
    exit 1
fi

exit 0
