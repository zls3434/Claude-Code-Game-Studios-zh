<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Unreal Engine 5.7 — 物理模块参考

**最后验证日期：** 2026-02-13
**知识盲区：** UE 5.7 Chaos 物理改进

---

## 概述

UE 5 使用 **Chaos Physics**（替代了 UE 4 中的 PhysX）：
- 更优的性能
- 破坏效果支持
- 载具物理改进

---

## 刚体物理

### 在静态网格体上启用物理

```cpp
UStaticMeshComponent* MeshComp = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
MeshComp->SetSimulatePhysics(true);
MeshComp->SetEnableGravity(true);
MeshComp->SetMassOverrideInKg(NAME_None, 50.0f); // 50 千克
```

### 施加力

```cpp
// 施加冲量（瞬时速度变化）
MeshComp->AddImpulse(FVector(0, 0, 1000), NAME_None, true);

// 施加力（持续作用）
MeshComp->AddForce(FVector(0, 0, 500));

// 施加扭矩（旋转）
MeshComp->AddTorqueInRadians(FVector(0, 0, 100));
```

---

## 碰撞

### 碰撞通道

```cpp
// 项目设置 > 引擎 > 碰撞
// 定义自定义碰撞通道和响应

// 在 C++ 中设置碰撞
MeshComp->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
MeshComp->SetCollisionObjectType(ECollisionChannel::ECC_Pawn);
MeshComp->SetCollisionResponseToAllChannels(ECR_Block);
MeshComp->SetCollisionResponseToChannel(ECC_Camera, ECR_Ignore);
```

### 碰撞事件

```cpp
// 启用碰撞事件
MeshComp->SetNotifyRigidBodyCollision(true);

// 绑定 OnComponentHit
MeshComp->OnComponentHit.AddDynamic(this, &AMyActor::OnHit);

UFUNCTION()
void AMyActor::OnHit(UPrimitiveComponent* HitComp, AActor* OtherActor,
    UPrimitiveComponent* OtherComp, FVector NormalImpulse, const FHitResult& Hit) {
    UE_LOG(LogTemp, Warning, TEXT("命中 %s"), *OtherActor->GetName());
}
```

### 重叠事件

```cpp
// 启用重叠事件
MeshComp->SetGenerateOverlapEvents(true);

// 绑定 OnComponentBeginOverlap
MeshComp->OnComponentBeginOverlap.AddDynamic(this, &AMyActor::OnOverlapBegin);

UFUNCTION()
void AMyActor::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, AActor* OtherActor,
    UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult& SweepResult) {
    UE_LOG(LogTemp, Warning, TEXT("重叠于 %s"), *OtherActor->GetName());
}
```

---

## 射线检测（Line Traces）

### 单线检测

```cpp
FHitResult HitResult;
FVector Start = GetActorLocation();
FVector End = Start + GetActorForwardVector() * 1000.0f;

FCollisionQueryParams QueryParams;
QueryParams.AddIgnoredActor(this);

// 执行射线检测
bool bHit = GetWorld()->LineTraceSingleByChannel(
    HitResult,
    Start,
    End,
    ECC_Visibility,
    QueryParams
);

if (bHit) {
    UE_LOG(LogTemp, Warning, TEXT("命中：%s"), *HitResult.GetActor()->GetName());
    DrawDebugLine(GetWorld(), Start, HitResult.Location, FColor::Red, false, 2.0f);
}
```

### 多线检测

```cpp
TArray<FHitResult> HitResults;
bool bHit = GetWorld()->LineTraceMultiByChannel(
    HitResults,
    Start,
    End,
    ECC_Visibility,
    QueryParams
);

for (const FHitResult& Hit : HitResults) {
    UE_LOG(LogTemp, Warning, TEXT("命中：%s"), *Hit.GetActor()->GetName());
}
```

### 扫描检测（厚检测）

```cpp
FHitResult HitResult;
FCollisionShape Sphere = FCollisionShape::MakeSphere(50.0f);

bool bHit = GetWorld()->SweepSingleByChannel(
    HitResult,
    Start,
    End,
    FQuat::Identity,
    ECC_Visibility,
    Sphere,
    QueryParams
);
```

---

## Character 移动

### Character Movement Component

```cpp
// 内置于 ACharacter 类中
UCharacterMovementComponent* MoveComp = GetCharacterMovement();

// 配置移动参数
MoveComp->MaxWalkSpeed = 600.0f;
MoveComp->JumpZVelocity = 600.0f;
MoveComp->AirControl = 0.2f;
MoveComp->GravityScale = 1.0f;
MoveComp->bOrientRotationToMovement = true;
```

### 添加移动输入

```cpp
// 在 Character 类中
void AMyCharacter::MoveForward(float Value) {
    if (Value != 0.0f) {
        AddMovementInput(GetActorForwardVector(), Value);
    }
}

void AMyCharacter::MoveRight(float Value) {
    if (Value != 0.0f) {
        AddMovementInput(GetActorRightVector(), Value);
    }
}
```

---

## 物理材质

### 创建物理材质

1. 内容浏览器 > 右键 > 物理 > 物理材质
2. 配置属性：
   - Friction（摩擦力）：0.0 - 1.0
   - Restitution（弹性/弹跳）：0.0 - 1.0

### 分配物理材质

```cpp
// 在静态网格体编辑器中：物理 > 物理材质覆盖
// 或在 C++ 中：
MeshComp->SetPhysMaterialOverride(PhysicalMaterial);
```

---

## 约束（物理关节）

### Physics Constraint Component

```cpp
UPhysicsConstraintComponent* Constraint = CreateDefaultSubobject<UPhysicsConstraintComponent>(TEXT("Constraint"));
Constraint->SetConstrainedComponents(ComponentA, NAME_None, ComponentB, NAME_None);

// 配置约束
Constraint->SetLinearXLimit(ELinearConstraintMotion::LCM_Limited, 100.0f);
Constraint->SetLinearYLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
Constraint->SetLinearZLimit(ELinearConstraintMotion::LCM_Free, 0.0f);

Constraint->SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Limited, 45.0f);
```

---

## 破坏效果（Chaos Destruction）

### 启用 Chaos Destruction

```cpp
// 插件：启用 "Chaos" 插件
// 为可破坏物体创建 Geometry Collection 资产
```

### 破坏 Geometry Collection

```cpp
// 在 Chaos 编辑器中破碎网格体
// 在游戏中，施加伤害：
UGeometryCollectionComponent* GeoComp = /* 获取组件 */;
GeoComp->ApplyPhysicsField(/* Field 参数 */);
```

---

## 性能提示

### 物理优化

```cpp
// 简化碰撞形状（使用简单图元）
MeshComp->SetCollisionEnabled(ECollisionEnabled::NoCollision); // 不需要时禁用

// 对骨骼网格体使用 Physics Asset（简化碰撞）
// 不对远处的物体模拟物理

// 减少物理子步：
// 项目设置 > 引擎 > 物理 > 最大子步 Delta Time
```

---

## 调试

### 物理调试可视化

```cpp
// 控制台命令：
// show collision - 显示碰撞形状
// p.Chaos.DebugDraw.Enabled 1 - 显示 Chaos 调试
// pxvis collision - 可视化碰撞

// 绘制调试形状：
DrawDebugSphere(GetWorld(), Location, Radius, 12, FColor::Green, false, 2.0f);
DrawDebugBox(GetWorld(), Location, Extent, FColor::Red, false, 2.0f);
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/physics-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/chaos-physics-overview-in-unreal-engine/
