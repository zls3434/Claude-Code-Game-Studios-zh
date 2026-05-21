<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Hook：pre-commit-code-quality

## 触发条件

在任何修改 `src/` 中文件的提交之前运行。

## 用途

在代码进入版本控制之前强制执行编码规范。捕捉风格违规、缺少文档、
过于复杂的方法和应该由数据驱动的硬编码值。

## 实现

```bash
#!/bin/bash
# Pre-commit hook：代码质量检查
# 根据你的语言和工具调整具体检查项

CODE_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '^src/')

EXIT_CODE=0

if [ -n "$CODE_FILES" ]; then
    for file in $CODE_FILES; do
        # 检查玩法代码中的硬编码魔数
        if [[ "$file" == src/gameplay/* ]]; then
            # 查找可能是数值平衡参数的数值字面量
            # 根据你的语言调整匹配模式
            if grep -nE '(damage|health|speed|rate|chance|cost|duration)[[:space:]]*[:=][[:space:]]*[0-9]+' "$file"; then
                echo "WARNING: $file 可能包含硬编码的玩法数值。请使用数据文件。"
                # 仅警告，不阻塞
            fi
        fi

        # 检查没有负责人的 TODO/FIXME
        if grep -nE '(TODO|FIXME|HACK)[^(]' "$file"; then
            echo "WARNING: $file 中有没有负责人标记的 TODO/FIXME。请使用 TODO(名称) 格式。"
        fi

        # 运行语言特定的 Linter（取消相应行的注释）
        # 对于 GDScript：gdlint "$file" || EXIT_CODE=1
        # 对于 C#：dotnet format --check "$file" || EXIT_CODE=1
        # 对于 C++：clang-format --dry-run -Werror "$file" || EXIT_CODE=1
    done

    # 对修改的系统运行单元测试
    # 取消注释并根据你的测试框架调整
    # python -m pytest tests/unit/ -x --quiet || EXIT_CODE=1
fi

exit $EXIT_CODE
```

## Agent 集成

当此 Hook 失败时：
1. 风格违规：使用你的格式化工具自动修复或调用 `lead-programmer`
2. 硬编码值：调用 `gameplay-programmer` 将值外部化
3. 测试失败：调用 `qa-tester` 诊断，调用 `gameplay-programmer` 修复
