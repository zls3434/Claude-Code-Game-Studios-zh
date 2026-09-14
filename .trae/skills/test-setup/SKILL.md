---
name: test-setup
description: "通过创建目录结构、安装测试框架、编写测试运行器脚本和生成引擎适应的示例测试，为项目搭建完整的测试基础设施。当游戏准备好接受测试时，从空白状态运行。"
argument-hint: "[engine | configure | all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: claude-sonnet-4
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 测试设置

没有测试的游戏项目就像没有安全绳走钢丝 — 一切顺利，直到出现第一次轻微失误。此 Skill 从空白状态搭建所需的测试基础设施，使其准备好在游戏中运行自动化测试。

**输出：** `tests/` 目录树、测试运行器、示例测试文件和 CI 配置。

**何时运行：**
- 项目初始化后（生产前）
- 生成第一个故事之前
- 当现有测试套件需要迁移到新框架时
- 当 CI 尚未为项目配置时

**运行前提条件：**
- 引擎必须已配置（运行 `/setup-engine` 首先设置引擎）

---

## 第 1 阶段：解析参数并检测环境

### 解析参数

**子命令：**
- `all` — 完整的测试设置（默认），引擎从 `technical-preferences.md` 检测。创建目录、安装框架、编写运行器、生成示例。
- `configure` — 仅配置模式：跳过框架安装和示例生成。用于在 CI 环境或框架已安装的环境中设置测试结构。
- `[engine]` — 覆盖引擎检测。使用 `godot`、`unity` 或 `unreal`。

如果指定了 `configure`：跳过第 2 阶段和第 4 阶段。仅执行第 3 阶段（目录）和第 5 阶段（CI 配置）。

### 检测引擎

通过以下方式确定引擎：
1. 如果参数是 `godot`、`unity` 或 `unreal` 引擎名称，使用该引擎
2. 读取 `.claude/docs/technical-preferences.md` 并提取 `Engine:` 字段
3. 如果未找到引擎，停止并提示："在搭建测试之前先使用 `/setup-engine` 设置你的游戏引擎。"

确定引擎后，通过签出 `Engine:` 字段后的版本字符串（如果在 `technical-preferences.md` 中可用）或检查引擎参考文件来检测引擎版本。如果版本未知，提示用户或推断为检测到的最新稳定版本。

### 检查现有基础设施

Glob `tests/` 目录。如果找到文件：
- 不要自动覆盖或修改任何现有测试文件
- 报告："发现现有测试基础设施：[N] 个文件，[N] 个目录。"
- 提示："你想添加缺失的部分还是重新初始化？" 附带选项：`[A] 添加缺失的部分（默认）` / `[B] 重新初始化所有内容` / `[C] 取消`
- 在 B 模式下，询问："我可以首先备份现有 `tests/` 目录吗？"如果同意，在重新初始化前将其重命名为 `tests.backup/`。如果拒绝，停止。

在继续任何写入之前报告检测结果。

---

## 第 2 阶段：安装测试框架

根据引擎安装适当的测试框架：

| 引擎 | 框架 | 安装方式 |
|--------|----------|-----------|
| Godot | GdUnit4 | 通过 Asset Library 手动安装 或 按用户指南添加到 `addons/` |
| Unity | Unity Test Framework | 内置 — 编辑器中 Window → General → Test Runner |
| Unreal | Unreal Automation System | 内置 — AutomationTool, Gauntlet, 和 Session Frontend |

### Godot + GdUnit4

GdUnit4 通过 AssetLib 安装。帮助用户完成手动步骤：

```
在 Godot 编辑器中：
1. 打开 AssetLib 选项卡
2. 搜索 "GdUnit4"（作者：Mike Schulze）
3. 下载 → 安装 → 仅选择 "addons/gdunit4/"
4. 项目 → 项目设置 → 插件 → 启用 GdUnit4

验证安装：
- 重新打开项目（如果 GdUnit4 图标未出现在主编辑器标签旁则必需）
- 确认底部面板出现 GdUnit4 标签
- 点击 GdUnit4 → Test Explorer（测试资源管理器应显示无测试——预期为新创建）
```

不要尝试通过命令行安装 GdUnit4 — 它需要编辑器 GUI。

检查安装：
- `ls addons/gdunit4/plugin.cfg 2>/dev/null && echo "GdUnit4: installed" || echo "GdUnit4: not installed"`
- 如果已安装，跳过。如果未安装，指示用户："请从 AssetLib 安装 GdUnit4。以上步骤之后继续。"
- 如果用户表示 GdUnit4 已安装但插件文件路径不存在：不要争论。接受他们的确认，警告其限值，并继续。

### Unity + Unity Test Framework

Unity Test Framework 内置于 Unity 编辑器中。帮助用户完成手动步骤：

```
在 Unity 编辑器中：
1. Window → General → Test Runner
2. 确保 PlayMode 和 EditMode 测试均已启用
3. 如果提示，创建测试程序集定义（Test Runner → 右上角菜单 → "Enable playmode tests for all assemblies"）

验证安装：
- Test Runner 窗口应显示无测试（预期——尚未创建）
```

不要尝试通过命令行安装 Unity Test Framework — 它需要编辑器 GUI。

检查安装：
- Glob `Assets/**/*.asmdef`，grep 查找包含 `"Test"` 或 `"Tests"` 的 `"name":` 字段
- 如果未找到测试程序集定义，告知用户 Test Runner 尚未配置

### Unreal + Automation System

Unreal Automation System 内置于引擎中。设置通过编辑器或命令行：

检查是否存在 `[ProjectName].Target.cs` 文件：
```bash
find Source -name "*.Target.cs" -exec grep -l "TargetType" {} \;
```

如果不存在，告知用户通过 UE 编辑器 Automation Tool 面板配置运行器。

帮助用户完成手动步骤：
```
在 Unreal 编辑器中：
1. Window → Test Automation
2. Automation 标签列出了所有已注册的测试
3. Session Frontend → Automation 显示带有过滤器的测试运行器

验证安装：
- Automation 面板应打开一个空的测试树——预期
```

---

## 第 3 阶段：搭建目录结构

根据引擎创建完整的测试目录结构：

### 对于 Godot

```
tests/
├── unit/
│   ├── gameplay/
│   ├── core/
│   └── ui/
├── integration/
│   ├── gameplay/
│   └── systems/
├── helpers/
│   ├── input.gd
│   └── state.gd
├── fixtures/
│   └── example-fixture.gd
├── evidence/
├── gdunit4_runner.gd
└── smoke/
```

### 对于 Unity

```
Assets/Tests/
├── EditMode/
│   ├── Unit/
│   │   ├── Gameplay/
│   │   └── Core/
│   └── Integration/
├── PlayMode/
│   ├── Unit/
│   └── Integration/
├── Helpers/
│   ├── InputHelper.cs
│   └── StateHelper.cs
├── Fixtures/
│   └── ExampleFixture.cs
└── Evidence/
```

### 对于 Unreal

```
Source/[Project]/Tests/
├── Unit/
│   ├── Gameplay/
│   └── Core/
├── Integration/
├── Helpers/
│   ├── InputTestHelper.h
│   └── InputTestHelper.cpp
├── Fixtures/
│   └── ExampleFixture.h
└── Evidence/
```

---

## 第 4 阶段：编写测试运行器和示例

### 对于 Godot + GdUnit4

#### 测试运行器脚本

创建 `tests/gdunit4_runner.gd`：

```gdscript
# GdUnit4 测试运行器 — 用于运行所有测试套件的无头入口点。
# 调用方式：godot --headless --script tests/gdunit4_runner.gd
#
# 注意：此脚本需要 GdUnit4 插件才能运行测试。
# 请确保插件已启用（Editor → Project Settings → Plugins → GdUnit4）。

extends SceneTree

func _init() -> void:
    GdUnit4TestRunner.run()
    await get_tree().process_frame
    quit()
```

#### 示例测试

创建 `tests/unit/gameplay/example_test.gd`：

```gdscript
# 示例测试套件展示 GdUnit4 测试模式。

extends GdUnitTestSuite

func before() -> void:
    # 在每个测试前运行。
    # 在此设置固定装置、模拟和必要状态。
    pass

func after() -> void:
    # 在每个测试后运行。
    # 在此清理任何残余状态。
    pass

func test_always_passes() -> void:
    assert_bool(true).is_true()

func test_basic_arithmetic() -> void:
    assert_int(1 + 1).is_equal(2)

func test_string_contains() -> void:
    assert_str("hello world").contains("world")
```

### 对于 Unity + Unity Test Framework

#### 示例测试

创建 `Assets/Tests/EditMode/Unit/Gameplay/ExampleTest.cs`：

```csharp
// 展示 Unity Test Framework 模式的示例测试。
using NUnit.Framework;

namespace Tests.EditMode.Unit.Gameplay
{
    [TestFixture]
    public class ExampleTest
    {
        [SetUp]
        public void SetUp()
        {
            // 在每个测试前运行。
        }

        [TearDown]
        public void TearDown()
        {
            // 在每个测试后运行。
        }

        [Test]
        public void AlwaysPasses()
        {
            Assert.IsTrue(true);
        }
    }
}
```

创建 `Assets/Tests/PlayMode/Unit/Gameplay/ExamplePlayModeTest.cs`：

```csharp
// 展示 Unity Test Framework 模式的示例 PlayMode 测试。
using System.Collections;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using UnityEngine.SceneManagement;

namespace Tests.PlayMode.Unit.Gameplay
{
    [TestFixture]
    public class ExamplePlayModeTest
    {
        [UnitySetUp]
        public IEnumerator SetUp()
        {
            // 在每个测试前运行。
            yield return null;
        }

        [UnityTearDown]
        public IEnumerator TearDown()
        {
            // 在每个测试后运行。
            yield return null;
        }

        [UnityTest]
        public IEnumerator AlwaysPasses()
        {
            yield return null;
            Assert.IsTrue(true);
        }
    }
}
```

### 对于 Unreal + Automation System

#### 示例测试

创建 `Source/[Project]/Tests/Unit/Gameplay/ExampleTest.h`：

```cpp
// 展示 Unreal Automation System 模式的示例测试。
#pragma once

#include "CoreMinimal.h"
#include "Misc/AutomationTest.h"

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FExampleAlwaysPassesTest,
    "Tests.Unit.Gameplay.ExampleAlwaysPasses",
    EAutomationTestFlags::ApplicationContextMask | EAutomationTestFlags::ProductFilter
)

bool FExampleAlwaysPassesTest::RunTest(const FString& Parameters)
{
    return true;
}
```

---

## 第 5 阶段：CI 配置

在 `.github/workflows/` 中生成 CI 测试工作流（如果目录存在或可以创建）：

**仅在用户同意后生成 CI 文件。"我应该为你生成 CI 配置吗？"**

### 对于 Godot + GdUnit4

创建 `.github/workflows/tests.yml` 或追加到已有文件：

```yaml
name: Run Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.4
    steps:
      - uses: actions/checkout@v4
      - name: Setup
        run: |
          mkdir -p ~/.config/godot
      - name: Run GdUnit4 Tests
        run: godot --headless --script tests/gdunit4_runner.gd
```

### 对于 Unity

```yaml
name: Run Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: game-ci/unity-test-runner@v4
        with:
          unityVersion: auto
          testMode: all
          githubToken: ${{ secrets.GITHUB_TOKEN }}
```

### 对于 Unreal

创建 `.github/workflows/tests.yml` 或追加到已有文件：

```yaml
name: Run Unreal Tests
on:
  push:
    branches: [main]
  pull_request:

jobs:
  AutomationTests:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Automation Tests
        run: |
          # UE 自动化测试需在 Windows 上运行。
          # 需安装 Unreal Engine 且项目已配置。
          Engine\Binaries\Win64\UnrealEditor-Cmd.exe `
            [ProjectName].uproject `
            -ExecCmds="Automation RunTests Tests" `
            -NullRHI -Unattended -NoSplash -Log
```

---

## 第 6 阶段：最终验证和摘要

总结已创建的结构：

```
## 测试基础设施设置完成

**引擎**：[engine] [version]
**框架**：[framework]
**CI**：[已配置 / 已跳过]

目录结构：
  tests/
  ├── unit/        — 系统级单元测试
  ├── integration/ — 跨系统集成测试
  ├── helpers/     — 测试辅助函数和模拟器（需要时运行 /test-helpers）
  ├── fixtures/    — 测试固定装置和数据
  ├── evidence/    — 手动测试证据（截图、日志）
  └── smoke/       — 冒烟测试（入口点 / 冒烟清单）

示例测试已就位以验证测试运行器功能。

后续步骤：
1. 运行测试套件以验证基础设施：
   - /smoke-check quick
2. 查看示例测试以了解框架模式
3. 为需要模拟的系统运行 /test-helpers
4. 在 CI 中运行测试以验证自动化

提示：首次 CI 测试运行需要启用 GitHub Actions
在你的仓库中（Settings → Actions → General → Allow all actions）。
```

---

## 协作协议

- **绝不覆盖已有测试文件** — 始终先报告已找到的测试文件并提供添加缺失部分或重新初始化的选项
- **绝不尝试通过命令行安装框架** — GdUnit4、Unity Test Framework 和 Unreal Automation 需要编辑器 GUI。向用户提供逐步手动说明并在继续前验证
- **写入前询问** — 所有文件写入（测试运行器、示例测试、CI 配置）在创建或修改任何内容前都需要明确批准。写入时：判定：**COMPLETE** — 测试基础设施已创建。被拒绝时：判定：**BLOCKED** — 用户拒绝写入。
- **CI 配置必须单独批准** — 绝不在未经用户询问的情况下生成 CI 工作流文件
- **在退出前始终提供摘要** — 让用户知道创建了什么以及下一步做什么
