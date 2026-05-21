<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Hook：pre-commit-design-check

## 触发条件

在任何修改 `design/` 或 `assets/data/` 中文件的提交之前运行。

## 用途

确保设计文档和游戏数据文件在进入版本控制之前保持一致性和完整性。
在缺失章节、断开的交叉引用和无效数据传播之前捕获它们。

## 实现

```bash
#!/bin/bash
# Pre-commit hook：设计文档和游戏数据验证
# 放置在 .git/hooks/pre-commit 或通过你的 Hook 管理器配置

DESIGN_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '^design/')
DATA_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '^assets/data/')

EXIT_CODE=0

# 检查设计文档的必要章节
if [ -n "$DESIGN_FILES" ]; then
    for file in $DESIGN_FILES; do
        if [[ "$file" == *.md ]]; then
            # 检查 GDD 文档的必要章节
            if [[ "$file" == design/gdd/* ]]; then
                for section in "Overview" "Detailed" "Edge Cases" "Dependencies" "Acceptance Criteria"; do
                    if ! grep -qi "$section" "$file"; then
                        echo "ERROR: $file 缺少必要章节：$section"
                        EXIT_CODE=1
                    fi
                done
            fi
        fi
    done
fi

# 验证 JSON 数据文件
if [ -n "$DATA_FILES" ]; then
    for file in $DATA_FILES; do
        if [[ "$file" == *.json ]]; then
            # 找到可用的 Python 命令
            PYTHON_CMD=""
            for cmd in python python3 py; do
                if command -v "$cmd" >/dev/null 2>&1; then
                    PYTHON_CMD="$cmd"
                    break
                fi
            done
            if [ -n "$PYTHON_CMD" ] && ! "$PYTHON_CMD" -m json.tool "$file" > /dev/null 2>&1; then
                echo "ERROR: $file 不是有效的 JSON"
                EXIT_CODE=1
            fi
        fi
    done
fi

exit $EXIT_CODE
```

## Agent 集成

当此 Hook 失败时，提交者应：
1. 缺少设计章节：调用 `game-designer` Agent 来完成文档
2. 无效 JSON：调用 `tools-programmer` Agent 或手动修复
