<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Unity 6.3 — 输入模块参考

**最后验证时间：** 2026-02-13
**知识差距：** Unity 6 使用新 Input System（旧版 Input 已弃用）

---

## 概述

Unity 6 输入系统：
- **Input System 包**（推荐）：跨平台、可重绑定、现代化
- **旧版 Input Manager**：已弃用，新项目避免使用

---

## 相对于 2022 LTS 的主要变更

### 旧版 Input 在 Unity 6 中已弃用

```csharp
// ❌ 已弃用：Input 类
if (Input.GetKeyDown(KeyCode.Space)) { }

// ✅ 新版：Input System 包
using UnityEngine.InputSystem;
if (Keyboard.current.spaceKey.wasPressedThisFrame) { }
```

**需要迁移：** 安装 `com.unity.inputsystem` 包。

---

## Input System 包设置

### 安装
1. `Window > Package Manager`
2. 搜索 "Input System"
3. 安装包
4. 提示时重启 Unity

### 启用新 Input System
`Edit > Project Settings > Player > Active Input Handling`：
- **Input System Package（New）** ✅ 推荐
- **Both**（迁移期间使用）

---

## Input Actions（推荐模式）

### 创建 Input Actions 资源

1. `Assets > Create > Input Actions`
2. 命名（如 "PlayerControls"）
3. 打开资源，定义 Action：

```
Action Maps：
  Gameplay
    Actions：
      - Move（Value，Vector2）
      - Jump（Button）
      - Fire（Button）
      - Look（Value，Vector2）
```

4. **生成 C# 类**：在 Inspector 中勾选 "Generate C# Class"
5. 点击 "Apply"

### 使用生成的输入类

```csharp
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour {
    private PlayerControls controls;

    void Awake() {
        controls = new PlayerControls();

        // 订阅 Action
        controls.Gameplay.Jump.performed += ctx => Jump();
        controls.Gameplay.Fire.performed += ctx => Fire();
    }

    void OnEnable() => controls.Enable();
    void OnDisable() => controls.Disable();

    void Update() {
        // 读取连续输入
        Vector2 move = controls.Gameplay.Move.ReadValue<Vector2>();
        transform.Translate(new Vector3(move.x, 0, move.y) * Time.deltaTime);

        Vector2 look = controls.Gameplay.Look.ReadValue<Vector2>();
        // 应用相机旋转
    }

    void Jump() {
        Debug.Log("跳跃！");
    }

    void Fire() {
        Debug.Log("开火！");
    }
}
```

---

## 直接设备访问（快速但不推荐）

### Keyboard

```csharp
using UnityEngine.InputSystem;

void Update() {
    // 当前状态
    if (Keyboard.current.spaceKey.isPressed) { }

    // 本帧刚按下
    if (Keyboard.current.spaceKey.wasPressedThisFrame) { }

    // 本帧刚释放
    if (Keyboard.current.spaceKey.wasReleasedThisFrame) { }
}
```

### Mouse

```csharp
using UnityEngine.InputSystem;

void Update() {
    // 鼠标位置
    Vector2 mousePos = Mouse.current.position.ReadValue();

    // 鼠标增量（移动量）
    Vector2 mouseDelta = Mouse.current.delta.ReadValue();

    // 鼠标按键
    if (Mouse.current.leftButton.wasPressedThisFrame) { }
    if (Mouse.current.rightButton.isPressed) { }

    // 滚轮
    Vector2 scroll = Mouse.current.scroll.ReadValue();
}
```

### Gamepad

```csharp
using UnityEngine.InputSystem;

void Update() {
    Gamepad gamepad = Gamepad.current;
    if (gamepad == null) return; // 未连接手柄

    // 按键
    if (gamepad.buttonSouth.wasPressedThisFrame) { } // A/Cross
    if (gamepad.buttonWest.wasPressedThisFrame) { }  // X/Square

    // 摇杆
    Vector2 leftStick = gamepad.leftStick.ReadValue();
    Vector2 rightStick = gamepad.rightStick.ReadValue();

    // 扳机键
    float leftTrigger = gamepad.leftTrigger.ReadValue();
    float rightTrigger = gamepad.rightTrigger.ReadValue();

    // 方向键（D-Pad）
    Vector2 dpad = gamepad.dpad.ReadValue();
}
```

### Touch（移动端）

```csharp
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.EnhancedTouch;

void OnEnable() {
    EnhancedTouchSupport.Enable();
}

void Update() {
    foreach (var touch in UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches) {
        Debug.Log($"触摸位置 {touch.screenPosition}");
    }
}
```

---

## Input Action 回调

### Action 回调（事件驱动）

```csharp
// started：输入开始（如扳机被轻按）
controls.Gameplay.Fire.started += ctx => Debug.Log("开火开始");

// performed：输入动作触发（如按键完全按下）
controls.Gameplay.Fire.performed += ctx => Debug.Log("开火执行");

// canceled：输入释放或中断
controls.Gameplay.Fire.canceled += ctx => Debug.Log("开火取消");
```

### 上下文数据（Context Data）

```csharp
controls.Gameplay.Move.performed += ctx => {
    Vector2 value = ctx.ReadValue<Vector2>();
    float duration = ctx.duration; // 输入持续时长
    InputControl control = ctx.control; // 触发输入的是哪个设备/控件
};
```

---

## 控制方案与设备切换

### 在 Input Actions 资源中定义控制方案

```
Control Schemes：
  - Keyboard&Mouse（Keyboard，Mouse）
  - Gamepad（Gamepad）
  - Touch（Touchscreen）
```

### 设备变更时自动切换

```csharp
controls.Gameplay.Move.performed += ctx => {
    if (ctx.control.device is Keyboard) {
        Debug.Log("使用键盘");
    } else if (ctx.control.device is Gamepad) {
        Debug.Log("使用手柄");
    }
};
```

---

## 重绑定（运行时按键映射）

### 交互式重绑定

```csharp
using UnityEngine.InputSystem;

public void RebindJumpKey() {
    var rebindOperation = controls.Gameplay.Jump.PerformInteractiveRebinding()
        .WithControlsExcluding("Mouse") // 排除鼠标绑定
        .OnComplete(operation => {
            Debug.Log("重绑定完成");
            operation.Dispose();
        })
        .Start();
}
```

### 保存/加载绑定

```csharp
// 保存
string rebinds = controls.SaveBindingOverridesAsJson();
PlayerPrefs.SetString("InputBindings", rebinds);

// 加载
string rebinds = PlayerPrefs.GetString("InputBindings");
controls.LoadBindingOverridesFromJson(rebinds);
```

---

## Action 类型

### Button（按下/释放）
- 单次按下/释放
- 示例：Jump、Fire

### Value（连续值）
- 连续值（float、Vector2）
- 示例：Move、Look、Aim

### Pass-Through（直通）
- 无处理，立即传值
- 示例：鼠标位置

---

## 处理器（Processors / 输入修饰器）

### Scale（缩放）

```csharp
// 在 Input Actions 资源中：Action > Properties > Processors > Add > Scale
// 将输入值乘以缩放系数（如反转 Y 轴）
```

### Invert（取反）

```csharp
// 在 Input Actions 资源中：Action > Properties > Processors > Add > Invert
// 翻转输入符号
```

### Dead Zone（死区）

```csharp
// 在 Input Actions 资源中：Action > Properties > Processors > Add > Stick Deadzone
// 忽略摇杆微小移动
```

---

## PlayerInput 组件（简化设置）

### 自动输入设置

```csharp
// 添加组件：Player Input
// 分配 Input Actions 资源
// Behavior：Send Messages / Invoke Unity Events / Invoke C# Events

// Send Messages 示例：
public class Player : MonoBehaviour {
    public void OnMove(InputValue value) {
        Vector2 move = value.Get<Vector2>();
        // 处理移动
    }

    public void OnJump(InputValue value) {
        if (value.isPressed) {
            Jump();
        }
    }
}
```

---

## 调试

### Input Debugger
- `Window > Analysis > Input Debugger`
- 查看活动设备、输入值、Action 状态

---

## 来源
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/QuickStartGuide.html
