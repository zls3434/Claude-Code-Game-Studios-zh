<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Unity 6.3 — Cinemachine

**最后验证时间：** 2026-02-13
**状态：** 生产就绪
**包名：** `com.unity.cinemachine` v3.0+（Package Manager）

---

## 概述

**Cinemachine** 是 Unity 的虚拟相机系统，无需手动编写脚本即可实现专业、动态的
相机行为。它是 Unity 相机工作的行业标准。

**适用于 Cinemachine 的场景：**
- 第三人称跟随相机
- 过场动画与电影化呈现
- 相机混合与过渡
- 动态相机取景
- 屏幕震动与相机效果

**⚠️ 知识差距：** Cinemachine 3.0（Unity 6）相较 2.x 是重大重写。
许多 API 名称和组件已更改。

---

## 安装

### 通过 Package Manager 安装

1. `Window > Package Manager`
2. Unity Registry > 搜索 "Cinemachine"
3. 安装 `Cinemachine`（版本 3.0+）

---

## 核心概念

### 1. **Virtual Cameras（虚拟相机）**
- 定义相机行为（位置、旋转、镜头）
- 可存在多个虚拟相机；同一时间只有一个处于"激活"状态

### 2. **Cinemachine Brain**
- 挂载在 Main Camera 上的组件
- 在虚拟相机之间进行混合
- 将虚拟相机设置应用到 Unity 相机

### 3. **优先级（Priorities）**
- 虚拟相机有优先级数值
- 优先级最高的相机处于活动状态
- 优先级变更时平滑混合

---

## 基础设置

### 1. 将 Cinemachine Brain 添加到 Main Camera

```csharp
// 创建第一个虚拟相机时自动添加
// 或手动：Add Component > Cinemachine Brain
```

### 2. 创建 Virtual Camera

`GameObject > Cinemachine > Cinemachine Camera`

这将创建一个带有默认设置的 **CinemachineCamera** GameObject。

---

## Virtual Camera 组件

### CinemachineCamera（Unity 6 / Cinemachine 3.0+）

```csharp
using Unity.Cinemachine;

public class CameraController : MonoBehaviour {
    public CinemachineCamera virtualCamera;

    void Start() {
        // 设置优先级（越高 = 活跃）
        virtualCamera.Priority = 10;

        // 设置跟随目标
        virtualCamera.Follow = playerTransform;

        // 设置注视目标
        virtualCamera.LookAt = playerTransform;
    }
}
```

---

## 跟随模式（Body 组件）

### 第三人称跟随（Orbital Follow）

```csharp
// 在 Inspector 中：
// CinemachineCamera > Body > 3rd Person Follow

// 配置：
// - Shoulder Offset：（0.5, 0, 0）实现越肩视角
// - Camera Distance：5.0
// - Vertical Damping：0.5（平滑上下移动）
```

### Framing Transposer（平滑跟随）

```csharp
// CinemachineCamera > Body > Position Composer

// 配置：
// - Screen Position：Center（0.5, 0.5）
// - Dead Zone：目标在区域内时不移动相机
// - Damping：平滑跟随
```

### Hard Lock（精确跟随）

```csharp
// CinemachineCamera > Body > Hard Lock to Target
// 相机精确匹配目标位置（无偏移或阻尼）
```

---

## 瞄准模式（Aim 组件）

### Composer（取景目标）

```csharp
// CinemachineCamera > Aim > Composer

// 配置：
// - Tracked Object Offset：瞄准目标头部而非脚部
// - Screen Position：目标在屏幕上的位置
// - Dead Zone：目标在区域内时不旋转
```

### Look At Target

```csharp
// CinemachineCamera > Aim > Rotate With Follow Target
// 相机旋转匹配目标旋转（如第一人称）
```

---

## 相机间混合

### 基于优先级的混合

```csharp
public CinemachineCamera normalCamera; // 优先级：10
public CinemachineCamera aimCamera;    // 优先级：5

void StartAiming() {
    // 将瞄准相机设为更高优先级
    aimCamera.Priority = 15; // 现在处于活动状态
    // Brain 自动从 normalCamera 混合到 aimCamera
}

void StopAiming() {
    aimCamera.Priority = 5; // 恢复正常
}
```

### 自定义混合时间

```csharp
// 创建 Custom Blends Asset：
// Assets > Create > Cinemachine > Cinemachine Blender Settings

// 在 Cinemachine Brain 中：
// - Custom Blends = 你的资源
// - 按相机对配置混合时间
```

---

## 相机震动

### Impulse Source（触发震动）

```csharp
using Unity.Cinemachine;

public class ExplosionShake : MonoBehaviour {
    public CinemachineImpulseSource impulseSource;

    void Explode() {
        // 触发相机震动
        impulseSource.GenerateImpulse();
    }
}
```

### Impulse Listener（接收震动）

```csharp
// 添加到 CinemachineCamera：
// Add Component > CinemachineImpulseListener

// Impulse Listener 自动接收来自附近 Impulse Source 的震动
```

---

## Freelook Camera（第三人称鼠标视角）

### Cinemachine Free Look

```csharp
// GameObject > Cinemachine > Cinemachine Free Look

// 创建 3 个 Rig（顶部、中部、底部），基于垂直输入混合
// 配置：
// - Orbit Radius：与目标的距离
// - Height Offset：每个 Rig 的相机高度
// - X/Y Axis：鼠标或手柄输入
```

---

## 状态驱动相机（基于 Animator）

### Cinemachine State-Driven Camera

```csharp
// GameObject > Cinemachine > Cinemachine State-Driven Camera

// 配置：
// - Animated Target：带有 Animator 的角色
// - Layer：要跟踪的 Animator 层
// - State：按动画状态分配相机（Idle、Run、Jump 等）

// 相机根据动画状态自动切换
```

---

## Dolly Tracks（移动轨道 / 过场动画）

### Cinemachine Dolly Track

```csharp
// 1. 创建 Spline：GameObject > Cinemachine > Cinemachine Spline

// 2. 创建 Dolly Camera：
//    GameObject > Cinemachine > Cinemachine Camera
//    Body > Spline Dolly
//    分配 Spline

// 3. 在 Spline 上动画化 Dolly 位置（通过 Timeline 或脚本）
```

---

## 常见模式

### 第三人称跟随相机

```csharp
// CinemachineCamera
// - Follow：玩家 Transform
// - Body：3rd Person Follow（越肩偏移，距离：5）
// - Aim：Composer（将玩家取景在中央）
```

---

### 瞄准相机（拉近）

```csharp
// Normal Camera（优先级 10）：
//   - Distance：5.0

// Aim Camera（优先级 5）：
//   - Distance：2.0
//   - FOV：更窄

// 脚本：
void StartAiming() {
    aimCamera.Priority = 15; // 混合到瞄准相机
}
```

---

### 过场动画相机序列

```csharp
// 使用 Timeline：
// 1. 创建 Timeline（Assets > Create > Timeline）
// 2. 添加 Cinemachine Track
// 3. 将虚拟相机作为 Clip 添加
// 4. Timeline 自动在相机间混合
```

---

## 从 Cinemachine 2.x 迁移（Unity 2021）

### API 变更（Unity 6 / Cinemachine 3.0）

```csharp
// ❌ 旧版（Cinemachine 2.x）：
CinemachineVirtualCamera vcam;
vcam.m_Follow = target;

// ✅ 新版（Cinemachine 3.0+）：
CinemachineCamera vcam;
vcam.Follow = target; // 更清晰的 API
```

**主要变更：**
- `CinemachineVirtualCamera` → `CinemachineCamera`
- `m_Follow`、`m_LookAt` → `Follow`、`LookAt`（无 "m_" 前缀）
- 组件重命名以提高清晰度
- 更好的性能

---

## 性能提示

- 限制活动虚拟相机数量（仅在需要时激活）
- 使用较低优先级的相机而非销毁/创建
- 远离玩家时禁用虚拟相机

---

## 调试

### Cinemachine Debug

```csharp
// Window > Analysis > Cinemachine Debugger
// 显示活动相机、混合信息、镜头质量
```

---

## 来源
- https://docs.unity3d.com/Packages/com.unity.cinemachine@3.0/manual/index.html
- https://learn.unity.com/tutorial/cinemachine
