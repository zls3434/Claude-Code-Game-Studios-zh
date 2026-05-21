---
name: test-helpers
description: "为各引擎生成测试辅助函数（模拟器、工厂函数、固定装置、存根）。创建适合项目引擎和测试框架的辅助函数。在设置测试基础设施时运行。"
argument-hint: "[类别]（例如 'input'、'ai'、'physics'、'network'）"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
model: opus
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 测试辅助函数生成

测试辅助函数使测试变得可行。模拟预测不到的物理、注入虚拟输入、隔离不应该运行完整游戏循环的系统，并以可预测的方式构建测试对象。

此 Skill 为特定类别的游戏系统创建或更新适应引擎的测试辅助函数。

**输出：** 辅助函数文件写入 `tests/helpers/[category].gd` 或等价文件。

**何时运行：**
- 在 `/test-setup` 创建基础测试基础设施后
- 当编写新系统类别的测试发现没有可用于隔离的辅助函数时
- 当现有辅助函数覆盖了错误的责任范围（覆盖太多或太少）

---

## 第 1 阶段：解析参数

第一个参数是**类别**（必需）。有效的类别：

| 类别 | 用途 | 示例辅助函数 |
|----------|---------|---------------------|
| `input` | 模拟玩家输入 | `simulate_press("jump")`、`simulate_motion(controller_id, vector)` |
| `ai` | 存根 AI 决策 | `stub_decision(tree, returns="aggro")`、`stub_pathfind(path)` |
| `physics` | 强制物理状态 | `set_body_state(body, pos, vel)`、`force_collision(body_a, body_b)` |
| `network` | 模拟网络条件 | `simulate_latency(ms)`、`drop_packets(probability)` |
| `rng` | 注入确定性随机性 | `seed_rng(value)`、`stub_randf_sequence([values])` |
| `time` | 加速/冻结游戏时间 | `freeze_time()`、`advance_timer(name, delta)`、`set_time_scale(scale)` |
| `data` | 构建测试对象 | 生成默认填充测试对象的工厂函数 |
| `state` | 保存/加载/重置 | `save_state()`、`load_state(path)`、`reset_to_main_menu()` |
| `render` | 截图比较 | `capture_viewport()`、`compare_screenshots(a, b, tolerance)` |

如果类别缺失或无效，向用户显示此表并停止。

---

## 第 2 阶段：加载项目配置

1. 读取 `.claude/docs/technical-preferences.md` 获取：
   - 引擎（Godot / Unity / Unreal）
   - 依赖注入模式（如果已记录）
   - 已配置的测试框架（例如 `GDUnit4`、`GUT v9.x`、`NUnit`、`Unreal Automation`）

2. 检查现有辅助函数文件：
   - Glob `tests/helpers/` 查找现有辅助函数
   - 读取现有的辅助函数文件（如果有）以避免重复

3. 加载引擎特定架构背景：
   - 对于 Godot：搜索常见的模拟点（`Input.is_action_pressed`、`get_tree().create_timer`、`randf()`）
   - 对于 Unity：搜索 `Input.GetKey` / `Input.GetButton`、`Random.value`、`Physics.Raycast`
   - 对于 Unreal：搜索 `UInputComponent`、`FMath::RandRange`、`GetWorld()->GetTimerManager()`

---

## 第 3 阶段：设计辅助函数 API

设计特定于所选类别、引擎和测试框架的辅助函数。每个辅助函数必须：

1. 在其职责范围内**可组合**（多个辅助函数可以串联使用，无副作用）
2. **隔离良好** — 不影响未设计测试的区域
3. **可逆** — 测试可以重置辅助函数修改的任何状态
4. **IDE 可发现** — 命名遵循项目约定

输出设计摘要：
```
为 [类别] 设计的辅助函数（[引擎] + [框架]）：
- [函数名] — 做什么，为什么需要它
- [函数名] — 做什么，为什么需要它
- reset_test_[category]() — 撤销所有模拟/存根
```

向用户展示设计。这应该是一个快速的模式检查——如果有人为的因素，最好在编写之前捕获。

询问："接受此辅助函数设计吗？"接受：判定：**设计已批准** — 继续。拒绝：询问用户要更改什么。

---

## 第 4 阶段：生成辅助函数代码

使用引擎适当的模式和约定编写辅助函数。

### Godot / GDScript 模式

```gdscript
# tests/helpers/[category].gd
extends Node

## 辅助：[类别特定描述]
## 示例：uses [engine-specific pattern]
class_name [Category]TestHelper

# [每个辅助函数的文档化方法]
```

**关键模式：**
- 使用 `class_name` 使辅助函数可全局访问
- 场景级可访问性使用 `autoload`（对于影响 InputMap 等的辅助函数 — 不要使用 `autoload` 作为通用全局测试状态）
- 使用 `static func` 提取不需要场景树的纯逻辑辅助函数
- 通过 `var _original_was_handled = handler.is_connected(...)` 模式提供显式清理
- 使用 `add_child()` 实例化辅助函数，用 `remove_child()` 清理

**GdUnit4 语法：**
```gdscript
@warning_ignore("unused_parameter")
func before() -> void:
    helper = InputTestHelper.new()
    add_child(helper)

@warning_ignore("unused_parameter")
func after() -> void:
    helper.reset_test_input()
    remove_child(helper)

@warning_ignore("unused_parameter")
func test_simulate_press_triggers_action(
    test_parameter: GdUnitTestParameterDto,
    test_helpers: GdUnitTestHelpers
) -> void:
    helper.simulate_press("jump")
    assert_bool(get_parent().has_signal("jump_pressed")).is_true()
```

### Unity / C# 模式

```csharp
// tests/helpers/[Category]TestHelper.cs
namespace Tests.Helpers
{
    public static class InputTestHelper
    {
        // 纯静态逻辑辅助函数
        public static void SimulateAction(string actionName) { ... }
        // 需要拆卸的：继承 IDisposable
    }
}
```

**关键模式：**
- 纯逻辑辅助函数使用 `public static class`
- 有状态的辅助函数实现 `IDisposable`（在 `[TearDown]` 中使用 `using`）
- 对纯逻辑辅助函数使用 `[Test]` 带 `TestHelper` 后缀
- 在 `constants/` 中测试常量与在 `helpers/` 中的辅助函数不同

**Unity Test Framework 语法（NUnit 3.x）：**
```csharp
[TestFixture]
public class MovementTests
{
    private InputTestHelper _inputHelper;

    [SetUp]
    public void SetUp()
    {
        _inputHelper = new InputTestHelper();
    }

    [TearDown]
    public void TearDown()
    {
        _inputHelper.Dispose();
    }

    [Test]
    public void SimulateAction_TriggersMovement()
    {
        _inputHelper.SimulateAction("Jump");
        Assert.That(/* ... */);
    }
}
```

### Unreal Engine / C++ 模式

```cpp
// tests/helpers/[Category]TestHelper.h
#pragma once
#include "CoreMinimal.h"

class F[Category]TestHelper
{
public:
    void SimulatePress(const FName& ActionName);
    void Reset();
private:
    // 用于清理的原始状态
};
```

**关键模式：**
- `[SetUp]` 步骤创建 FATEST_HELPER 实例作为类成员
- `[TearDown]` 步骤在实例上调用 `.Reset()` 并置 null
- 对纯逻辑辅助函数使用 `static` 方法
- 通过 `IInputProcessor` 或自定义模拟接口模拟输入（不要继承 `PlayerController`）

**Unreal Automation Spec 语法：**
```cpp
BEGIN_DEFINE_SPEC(FCombatTestHelperSpec, "Helpers.Combat",
    EAutomationTestFlags::ProductFilter | EAutomationTestFlags::ApplicationContextMask)
FInputTestHelper InputHelper;
END_DEFINE_SPEC(FCombatTestHelperSpec)

void FCombatTestHelperSpec::Define()
{
    BeforeEach([this]()
    {
        InputHelper = FInputTestHelper();
    });

    AfterEach([this]()
    {
        InputHelper.Reset();
    });

    It("should trigger attack on button press", [this]()
    {
        InputHelper.SimulatePress("Attack");
        // ...验证
    });
}
```

---

## 第 5 阶段：写入文件

使用引擎适当的文件路径：

| Engine | Helper Path Format |
|--------|-------------------|
| Godot | `tests/helpers/[category].gd` |
| Unity | `tests/helpers/[Category]TestHelper.cs` |
| Unreal | `Source/[Project]/Tests/Helpers/[Category]TestHelper.h` + `.cpp` |

询问："我可以将 [类别] 辅助函数文件写入 [路径] 吗？"

在确认前等待，然后写入。判定：**COMPLETE** — 辅助函数文件已创建。

如果用户拒绝，在此停止。判定：**BLOCKED** — 用户拒绝写入。

---

## 第 6 阶段：编写用法示例

在辅助函数文件中包含内联示例，展示如何在测试中使用它们：

```gdscript
## Example usage in a test:
## ```gdscript
## func before() -> void:
##     helper = InputTestHelper.new()
##     add_child(helper)
##
## func test_double_jump_is_consumed() -> void:
##     helper.simulate_press("jump")
##     helper.simulate_hold("jump", frames=3)
##     helper.simulate_release("jump")
##     helper.simulate_press("jump")
##     # 第二个跳跃不应处理
##     assert_int(get_node("../Player").jump_count).is_equal(1)
## ```
```

---

## 协作协议

- **一个文件，一个类别** — 不要生成怪物辅助文件。当类别之间保持较小时，IDE 中的自动完成效果最好
- **保持隔离** — `simulate_input()` 不应需要运行完整的游戏循环。从创建它的测试场景运行它。
- **辅助函数在需要时模拟，绝不作为通用全局状态**。将辅助函数实例添加为测试场景的子节点（Godot）或测试夹具成员（Unity/Unreal）— 不要通过 `autoload` 或单例让所有内容可全局访问
- **先设计，后编写** — 展示设计草图以供快速反馈（第 3 阶段）
- **写入前询问**，然后仅在获得批准后写入
- **引擎中立** — 始终适应检测到的引擎模式；不要重复使用跨引擎代码片段
