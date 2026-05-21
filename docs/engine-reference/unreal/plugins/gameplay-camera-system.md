<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Unreal Engine 5.7 — Gameplay Camera System

**最后验证：** 2026-02-13
**状态：** ⚠️ 实验性（UE 5.5 引入）
**插件：** `GameplayCameras`（内置，在 Plugins 中启用）

---

## 概述

**Gameplay Camera System** 是 UE 5.5 引入的模块化摄像机管理框架。
它通过灵活的、基于节点的系统替代了传统的摄像机设置，可处理
摄像机模式、混合以及上下文感知的摄像机行为。

**适用于 Gameplay Cameras 的场景：**
- 动态摄像机行为（第三人称、瞄准、载具、过场）
- 上下文感知的摄像机切换（战斗、探索、对话）
- 不同模式间的平滑摄像机混合
- 程序化摄像机运动（摄像机震动、滞后、偏移）

**⚠️ 警告：** 此插件在 UE 5.5-5.7 中为实验性。后续版本可能会有 API 变更。

---

## 核心概念

### 1. **Camera Rig**
- 定义摄像机配置（位置、旋转、FOV 等）
- 模块化节点图（类似 Material Editor）

### 2. **Camera Director**
- 管理哪个 Camera Rig 处于活跃状态
- 处理 Camera Rig 之间的混合

### 3. **Camera Nodes**
- 摄像机行为的构建块：
  - **Position Nodes**：Orbit、Follow、Fixed Position
  - **Rotation Nodes**：Look At、Match Actor Rotation
  - **Modifiers**：Camera Shake、Lag、Offset

---

## 设置

### 1. 启用插件

`Edit > Plugins > Gameplay Cameras > Enabled > Restart`

### 2. 添加 Camera Component

```cpp
#include "GameplayCameras/Public/GameplayCameraComponent.h"

UCLASS()
class AMyCharacter : public ACharacter {
    GENERATED_BODY()

public:
    AMyCharacter() {
        // 创建 Camera Component
        CameraComponent = CreateDefaultSubobject<UGameplayCameraComponent>(TEXT("GameplayCamera"));
        CameraComponent->SetupAttachment(RootComponent);
    }

protected:
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Camera")
    TObjectPtr<UGameplayCameraComponent> CameraComponent;
};
```

---

## 创建 Camera Rig

### 1. 创建 Camera Rig 资产

1. Content Browser > Gameplay > Gameplay Camera Rig
2. 打开 Camera Rig Editor（基于节点的图）

### 2. 构建 Camera Rig（示例：第三人称）

**节点设置：**
```
Actor Position（Character）
  ↓
Orbit Node（围绕 Character 旋转）
  ↓
Offset Node（肩部偏移）
  ↓
Look At Node（看向 Character）
  ↓
Camera Output
```

---

## Camera Nodes

### Position Nodes

#### Orbit Node（第三人称）
- 围绕目标 Actor 旋转
- 配置：
  - **Orbit Distance**：与目标的距离（例如 300 单位）
  - **Pitch Range**：最小/最大俯仰角度
  - **Yaw Range**：最小/最大偏航角度

#### Follow Node（平滑跟随）
- 带滞后的目标跟随
- 配置：
  - **Lag Speed**：摄像机追上的速度
  - **Offset**：与目标的固定偏移

#### Fixed Position Node
- 世界空间中的静态摄像机位置

---

### Rotation Nodes

#### Look At Node
- 将摄像机指向目标
- 配置：
  - **Target**：要看向的 Actor 或 Component
  - **Offset**：看向偏移（例如瞄准头部而非脚部）

#### Match Actor Rotation
- 匹配目标 Actor 的旋转
- 适用于第一人称或载具摄像机

---

### Modifier Nodes

#### Camera Shake
- 添加程序化震动（例如脚步、爆炸）
- 配置：
  - **Shake Pattern**：Perlin noise、正弦波、自定义
  - **Amplitude**：震动强度

#### Camera Lag
- 摄像机移动的平滑阻尼
- 配置：
  - **Lag Speed**：阻尼因子（0 = 即时，越高越滞后）

#### Offset Node
- 相对于计算位置的静态偏移
- 适用于肩摄偏移

---

## Camera Director（在 Rig 之间切换）

### 分配 Camera Rig

```cpp
#include "GameplayCameras/Public/GameplayCameraComponent.h"

void AMyCharacter::SetCameraMode(UGameplayCameraRig* NewRig) {
    if (CameraComponent) {
        CameraComponent->SetCameraRig(NewRig);
    }
}
```

### 在 Camera Rig 之间混合

```cpp
// 在 0.5 秒内混合到瞄准摄像机
CameraComponent->BlendToCameraRig(AimingCameraRig, 0.5f);
```

---

## 示例：第三人称 + 瞄准

### 1. 创建两个 Camera Rig

**第三人称 Rig：**
```
Actor Position → Orbit（distance: 300）→ Look At → Output
```

**瞄准 Rig：**
```
Actor Position → Orbit（distance: 150）→ Offset（shoulder）→ Look At → Output
```

### 2. 瞄准时切换

```cpp
UPROPERTY(EditAnywhere, Category = "Camera")
TObjectPtr<UGameplayCameraRig> ThirdPersonRig;

UPROPERTY(EditAnywhere, Category = "Camera")
TObjectPtr<UGameplayCameraRig> AimingRig;

void StartAiming() {
    CameraComponent->BlendToCameraRig(AimingRig, 0.3f); // 0.3 秒混合
}

void StopAiming() {
    CameraComponent->BlendToCameraRig(ThirdPersonRig, 0.3f);
}
```

---

## 常见模式

### 越肩摄像机

```
Actor Position
  ↓
Orbit Node（distance: 250, yaw offset: 30°）
  ↓
Offset Node（X: 0, Y: 50, Z: 50） // 肩部偏移
  ↓
Look At Node（target: Character head）
  ↓
Output
```

---

### 载具摄像机

```
Vehicle Position
  ↓
Follow Node（lag: 0.2）
  ↓
Offset Node（载具后方：X: -400, Z: 150）
  ↓
Look At Node（target: Vehicle）
  ↓
Output
```

---

### 第一人称摄像机

```
Character Head Socket
  ↓
Match Actor Rotation
  ↓
Output
```

---

## Camera Shake

### 触发摄像机震动

```cpp
#include "GameplayCameras/Public/GameplayCameraShake.h"

void TriggerExplosionShake() {
    if (APlayerController* PC = GetWorld()->GetFirstPlayerController()) {
        if (UGameplayCameraComponent* CameraComp = PC->FindComponentByClass<UGameplayCameraComponent>()) {
            CameraComp->PlayCameraShake(ExplosionShakeClass, 1.0f);
        }
    }
}
```

---

## 性能提示

- 限制摄像机震动频率（不要每帧都触发）
- 谨慎使用摄像机滞后（高滞后值开销大）
- 缓存 Camera Rig 引用（不要每帧都搜索）

---

## 调试

### 摄像机调试可视化

```cpp
// Console commands:
// GameplayCameras.Debug 1 - 显示活跃 Camera Rig 信息
// showdebug camera - 显示摄像机调试信息
```

---

## 从旧版摄像机迁移

### Old Spring Arm + Camera Component

```cpp
// ❌ 旧版：Spring Arm Component
USpringArmComponent* SpringArm;
UCameraComponent* Camera;

// ✅ 新版：Gameplay Camera Component
UGameplayCameraComponent* CameraComponent;
// 在 Camera Rig 资产中构建 orbit + look-at rig
```

---

## 限制（实验性状态）

- **API 不稳定**：UE 5.8+ 可能存在破坏性变更
- **文档有限**：官方文档仍在完善中
- **Blueprint 支持**：主要面向 C++（Blueprint 支持正在改善）
- **生产风险**：发布前请充分测试

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/gameplay-cameras-in-unreal-engine/
- UE 5.5+ Release Notes
- **注意：** 此系统为实验性。请始终查阅最新官方文档了解 API 变更。
