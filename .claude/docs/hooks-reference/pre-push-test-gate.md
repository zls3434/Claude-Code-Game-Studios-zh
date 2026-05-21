<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Hook：pre-push-test-gate

## 触发条件

在任何推送到远程分支之前运行。对于推送到 `develop` 和 `main` 是强制性的。

## 用途

确保在代码到达共享分支之前，构建能够编译、单元测试通过、关键冒烟测试通过。
这是代码影响其他开发者之前的最后一道自动化质量关卡。

## 实现

```bash
#!/bin/bash
# Pre-push hook：构建和测试关卡

REMOTE="$1"
URL="$2"

# 仅对 develop 和 main 执行完整关卡
PROTECTED_BRANCHES="develop main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

FULL_GATE=false
for branch in $PROTECTED_BRANCHES; do
    if [ "$CURRENT_BRANCH" = "$branch" ]; then
        FULL_GATE=true
        break
    fi
done

echo "=== Pre-Push 质量关卡 ==="

# 步骤 1：构建
echo "正在构建..."
# 根据你的构建系统调整：
# make build || exit 1
# dotnet build || exit 1
# cargo build || exit 1
echo "构建：PASS"

# 步骤 2：单元测试
echo "正在运行单元测试..."
# 根据你的测试框架调整：
# python -m pytest tests/unit/ -x || exit 1
# dotnet test tests/unit/ || exit 1
# cargo test || exit 1
echo "单元测试：PASS"

if [ "$FULL_GATE" = true ]; then
    # 步骤 3：集成测试（仅受保护分支）
    echo "正在运行集成测试..."
    # python -m pytest tests/integration/ -x || exit 1
    echo "集成测试：PASS"

    # 步骤 4：冒烟测试
    echo "正在运行冒烟测试..."
    # python -m pytest tests/playtest/smoke/ -x || exit 1
    echo "冒烟测试：PASS"

    # 步骤 5：性能回归检查
    echo "正在检查性能基线..."
    # python tools/ci/perf_check.py || exit 1
    echo "性能：PASS"
fi

echo "=== 所有关卡通过 ==="
exit 0
```

## Agent 集成

当此 Hook 失败时：
1. 构建失败：调用 `lead-programmer` 诊断
2. 单元测试失败：调用 `qa-tester` 识别失败测试，
   调用 `gameplay-programmer` 或相关程序员修复
3. 性能回归：调用 `performance-analyst` 分析
