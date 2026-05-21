<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Unreal Engine 5.7 — 输入模块参考

**最后验证：** 2026-02-13
**知识差距：** UE 5.7 默认使用 Enhanced Input（旧版输入已弃用）

---

## 概述

UE 5.7 输入系统：
- **Enhanced Input**（推荐，UE5 默认）：模块化、可重新绑定、基于上下文
- **Legacy Input**：已弃用，新项目避免使用

---

## Enhanced Input 系统

### 设置 Enhanced Input

1. **启用插件**：`Edit > Plugins > Enhanced Input`（UE5 中默认启用）
2. **项目设置**：`Engine > Input > Default Classes > Default Player Input Class = EnhancedPlayerInput`

---

### 创建 Input Actions

1. Content Browser > Input > Input Action
2. 命名（例如 `IA_Jump`、`IA_Move`）
3. 配置：
   - **Value Type**：Digital（bool）、Axis1D（float）、Axis2D（Vector2D）、Axis3D（Vector）

示例 Input Actions：
- `IA_Jump`：Digital（bool）
- `IA_Move`：Axis2D（Vector2D）
- `IA_Look`：Axis2D（Vector2D）
- `IA_Fire`：Digital（bool）

---

### 创建 Input Mapping Context

1. Content Browser > Input > Input Mapping Context
2. 命名（例如 `IMC_Default`）
3. 添加映射：
   - `IA_Jump` → Space Bar
   - `IA_Move` → W/A/S/D 键（组合 X/Y）
   - `IA_Look` → Mouse XY
   - `IA_Fire` → Left Mouse Button

---

### 在 C++ 中绑定输入

```cpp
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"
#include "InputActionValue.h"

class AMyCharacter : public ACharacter {
public:
    // Input Actions（在 Blueprint 中分配）
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputAction> MoveAction;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputAction> LookAction;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputAction> JumpAction;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputMappingContext> DefaultMappingContext;

protected:
    virtual void BeginPlay() override {
        Super::BeginPlay();

        // 添加 Input Mapping Context
        if (APlayerController* PC = Cast<APlayerController>(Controller)) {
            if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
                ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer())) {
                Subsystem->AddMappingContext(DefaultMappingContext, 0);
            }
        }
    }

    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override {
        Super::SetupPlayerInputComponent(PlayerInputComponent);

        UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
        if (EIC) {
            // 绑定操作
            EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
            EIC->BindAction(JumpAction, ETriggerEvent::Completed, this, &ACharacter::StopJumping);

            EIC->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AMyCharacter::Move);
            EIC->BindAction(LookAction, ETriggerEvent::Triggered, this, &AMyCharacter::Look);
        }
    }

    void Move(const FInputActionValue& Value) {
        FVector2D MoveVector = Value.Get<FVector2D>();

        if (Controller) {
            AddMovementInput(GetActorForwardVector(), MoveVector.Y);
            AddMovementInput(GetActorRightVector(), MoveVector.X);
        }
    }

    void Look(const FInputActionValue& Value) {
        FVector2D LookVector = Value.Get<FVector2D>();

        if (Controller) {
            AddControllerYawInput(LookVector.X);
            AddControllerPitchInput(LookVector.Y);
        }
    }
};
```

---

## Input Triggers（输入触发器）

### 触发器类型

Input Actions 可以具有触发器来控制触发时机：
- **Pressed**：输入开始时
- **Released**：输入结束时
- **Hold**：按住指定时长
- **Tap**：快速按下
- **Pulse**：按住期间重复触发

### 在编辑器中添加触发器

1. 打开 Input Action 资产
2. Triggers > Add > 选择触发器类型（例如 `Hold`）
3. 配置（例如 Hold Time = 0.5s）

---

## Input Modifiers（输入修改器）

### 修改器类型

修改器用于转换输入值：
- **Negate**：翻转符号（-1 ↔ 1）
- **Dead Zone**：忽略微小输入
- **Scalar**：乘以数值
- **Smooth**：随时间平滑

### 在编辑器中添加修改器

1. 打开 Input Action 资产
2. Modifiers > Add > 选择修改器（例如 `Negate`）
3. 配置

---

## Input Mapping Contexts（上下文切换）

### 多上下文

```cpp
// 定义上下文
UPROPERTY(EditAnywhere, Category = "Input")
TObjectPtr<UInputMappingContext> DefaultContext;

UPROPERTY(EditAnywhere, Category = "Input")
TObjectPtr<UInputMappingContext> VehicleContext;

// 切换上下文
void EnterVehicle() {
    if (APlayerController* PC = Cast<APlayerController>(Controller)) {
        if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
            ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer())) {
            Subsystem->RemoveMappingContext(DefaultContext);
            Subsystem->AddMappingContext(VehicleContext, 0);
        }
    }
}
```

---

## Legacy Input（已弃用）

### 旧版输入绑定

```cpp
// ❌ 已弃用：新项目请勿使用

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    // 旧版操作绑定
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);

    // 旧版轴绑定
    PlayerInputComponent->BindAxis("MoveForward", this, &AMyCharacter::MoveForward);
}

void MoveForward(float Value) {
    AddMovementInput(GetActorForwardVector(), Value);
}
```

**迁移：** 请改用 Enhanced Input。

---

## 手柄输入

### 使用 Enhanced Input 的手柄

```cpp
// Input Mapping Context：
// - IA_Move → Gamepad Left Thumbstick
// - IA_Look → Gamepad Right Thumbstick
// - IA_Jump → Gamepad Face Button Bottom（A/Cross）

// 无需修改代码，只需向 Input Mapping Context 添加手柄映射
```

---

## 触控输入（移动端）

### 使用 Enhanced Input 的触控

```cpp
// Input Mapping Context：
// - IA_Move → Touch（虚拟摇杆）
// - IA_Look → Touch（滑动）

// 使用 Touch Interface 资产来实现虚拟控件
```

---

## 运行时重新绑定输入

### 更改按键映射

```cpp
#include "PlayerMappableInputConfig.h"

// 获取子系统
UEnhancedInputLocalPlayerSubsystem* Subsystem = /* 获取子系统 */;

// 获取玩家可映射按键
FPlayerMappableKeySlot KeySlot = FPlayerMappableKeySlot(/*..*/);
FKey NewKey = EKeys::F; // 重新绑定到 F 键

// 应用新映射
Subsystem->AddPlayerMappedKey(/*..*/);
```

---

## 输入调试

### 调试输入

```cpp
// Console commands:
// showdebug input - 显示输入调试信息

// 记录输入值：
UE_LOG(LogTemp, Warning, TEXT("Move Input: %s"), *MoveVector.ToString());
```

---

## 常见模式

### 检查按键是否按下（快速但不严谨的方式）

```cpp
// 仅用于调试（不建议用于游戏逻辑）
if (GetWorld()->GetFirstPlayerController()->IsInputKeyDown(EKeys::SpaceBar)) {
    // Space Bar 被按下
}
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/enhanced-input-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/enhanced-input-action-and-input-mapping-context-in-unreal-engine/
