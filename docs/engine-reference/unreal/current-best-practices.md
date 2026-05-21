<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Unreal Engine 5.7 — 当前最佳实践

**最后验证日期：** 2026-02-13

现代 UE5 模式，这些内容可能不在 LLM 的训练数据中。
以下为截至 UE 5.7 的生产就绪建议。

---

## 项目设置

### 新项目请使用 UE 5.7
- 最新特性：Megalights、生产就绪的 Substrate 和 PCG
- 更优的性能和稳定性

### 选择合适的渲染特性
- **Lumen**：实时全局光照（大多数项目推荐使用）
- **Nanite**：高面数网格体的虚拟化几何体（细节丰富的环境推荐使用）
- **Megalights**：百万级动态光源（复杂光照场景推荐使用）
- **Substrate**：模块化材质系统（新项目推荐使用）

---

## C++ 编码

### 使用现代 C++ 特性（UE5.7 中的 C++20）

```cpp
// ✅ 使用 TObjectPtr<T>（UE5 类型安全指针）
UPROPERTY()
TObjectPtr<UStaticMeshComponent> MeshComp;

// ✅ 结构化绑定
if (auto [bSuccess, Value] = TryGetValue(); bSuccess) {
    // 使用 Value
}

// ✅ Concepts 与约束（C++20）
template<typename T>
concept Damageable = requires(T t, float damage) {
    { t.TakeDamage(damage) } -> std::same_as<void>;
};
```

### 使用 UPROPERTY() 进行垃圾回收

```cpp
// ✅ UPROPERTY 确保 GC 不会删除此对象
UPROPERTY()
TObjectPtr<AActor> MyActor;

// ❌ 裸指针可能变为悬空指针
AActor* MyActor; // 危险！可能被垃圾回收
```

### 使用 UFUNCTION() 暴露给 Blueprint

```cpp
// ✅ 可从 Blueprint 调用
UFUNCTION(BlueprintCallable, Category="Combat")
void TakeDamage(float Damage);

// ✅ 可在 Blueprint 中实现
UFUNCTION(BlueprintImplementableEvent, Category="Combat")
void OnDeath();
```

---

## Blueprint 最佳实践

### Blueprint vs C++ 的使用场景

- **C++**：核心游戏系统、性能关键代码、底层引擎交互
- **Blueprint**：快速原型、内容创建、数据驱动逻辑、设计师工作流

### Blueprint 性能提示

```cpp
// ✅ 谨慎使用 Event Tick（开销很大）
// 优先使用 Timer 或 Event

// ✅ 使用 Blueprint 原生化（Blueprint → C++）
// 项目设置 > 打包 > Blueprint 原生化

// ✅ 缓存频繁访问的组件
// 不要在每帧都调用 GetComponent
```

---

## 渲染（UE 5.7）

### 使用 Lumen 实现全局光照

```cpp
// 启用：项目设置 > 引擎 > 渲染 > 动态全局光照方法 = Lumen
// 实时 GI，无需烘焙光照贴图（推荐）
```

### 使用 Nanite 处理高面数网格体

```cpp
// 在静态网格体上启用：详情 > Nanite 设置 > 启用 Nanite 支持
// 自动为百万级三角形生成 LOD（高细节网格体推荐使用）
```

### 使用 Megalights 处理复杂光照（UE 5.5+）

```cpp
// 启用：项目设置 > 引擎 > 渲染 > Megalights = Enabled
// 支持百万级动态光源，成本极低
```

### 使用 Substrate 材质（5.7 中生产就绪）

```cpp
// 启用：项目设置 > 引擎 > Substrate > 启用 Substrate
// 模块化、物理精确的材质（新项目推荐使用）
```

---

## Enhanced Input 系统

### 设置 Enhanced Input

```cpp
// 1. 创建 Input Action（IA_Jump）
// 2. 创建 Input Mapping Context（IMC_Default）
// 3. 添加映射：IA_Jump → Space Bar

// C++ 设置：
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"

void AMyCharacter::BeginPlay() {
    Super::BeginPlay();

    if (APlayerController* PC = Cast<APlayerController>(GetController())) {
        if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
            ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer())) {
            Subsystem->AddMappingContext(DefaultMappingContext, 0);
        }
    }
}

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
    EIC->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AMyCharacter::Move);
}

void AMyCharacter::Move(const FInputActionValue& Value) {
    FVector2D MoveVector = Value.Get<FVector2D>();
    AddMovementInput(GetActorForwardVector(), MoveVector.Y);
    AddMovementInput(GetActorRightVector(), MoveVector.X);
}
```

---

## Gameplay Ability System (GAS)

### 使用 GAS 实现复杂玩法

```cpp
// ✅ GAS 适用场景：技能、增益、伤害计算、冷却时间
// 模块化、可扩展、多人就绪

// 安装：启用 "Gameplay Abilities" 插件

// 示例技能：
UCLASS()
class UGA_Fireball : public UGameplayAbility {
    GENERATED_BODY()

public:
    virtual void ActivateAbility(...) override {
        // 技能逻辑
        SpawnFireball();
        CommitAbility(); // 提交消耗/冷却
    }
};
```

---

## World Partition（大世界）

### 使用 World Partition 处理开放世界

```cpp
// 启用：世界设置 > 启用 World Partition
// 根据玩家位置自动流式加载世界区块

// Data Layers：组织内容（例如 "Gameplay"、"Audio"、"Lighting"）
// Runtime Data Layers：运行时加载/卸载
```

---

## Niagara（VFX）

### 使用 Niagara（而非 Cascade）

```cpp
// 创建：内容浏览器 > 右键 > FX > Niagara 系统
// GPU 加速的节点式粒子系统（推荐）

// 生成粒子：
UNiagaraComponent* NiagaraComp = UNiagaraFunctionLibrary::SpawnSystemAtLocation(
    GetWorld(),
    ExplosionSystem,
    GetActorLocation()
);
```

---

## MetaSounds（音频）

### 使用 MetaSounds 实现程序化音频

```cpp
// 创建：内容浏览器 > 右键 > 声音 > MetaSound 源
// 基于节点的音频，用于替代复杂逻辑的 Sound Cue（推荐）

// 播放 MetaSound：
UAudioComponent* AudioComp = UGameplayStatics::SpawnSound2D(
    GetWorld(),
    MetaSoundSource
);
```

---

## 复制（多人游戏）

### 服务器权威模式

```cpp
// ✅ 客户端发送输入，服务器验证并复制
UFUNCTION(Server, Reliable)
void Server_Move(FVector Direction);

void AMyCharacter::Server_Move_Implementation(FVector Direction) {
    // 服务器验证并应用移动
    AddMovementInput(Direction);
}

// ✅ 复制重要状态
UPROPERTY(Replicated)
int32 Health;

void AMyCharacter::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);
    DOREPLIFETIME(AMyCharacter, Health);
}
```

---

## 性能优化

### 使用对象池

```cpp
// ✅ 复用对象，避免 Spawn/Destroy
TArray<AActor*> ProjectilePool;

AActor* GetPooledProjectile() {
    for (AActor* Proj : ProjectilePool) {
        if (!Proj->IsActive()) {
            Proj->SetActive(true);
            return Proj;
        }
    }
    // 对象池耗尽，生成新对象
    return SpawnNewProjectile();
}
```

### 使用实例化静态网格体

```cpp
// ✅ 层级实例化静态网格体组件 (HISM)
// 在单次绘制调用中渲染数千个相同网格体
UHierarchicalInstancedStaticMeshComponent* HISM = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("Trees"));
for (int i = 0; i < 1000; i++) {
    HISM->AddInstance(FTransform(RandomLocation));
}
```

---

## 调试

### 使用日志

```cpp
// ✅ 结构化日志
UE_LOG(LogTemp, Warning, TEXT("玩家生命值：%d"), Health);

// 自定义日志分类
DECLARE_LOG_CATEGORY_EXTERN(LogMyGame, Log, All);
DEFINE_LOG_CATEGORY(LogMyGame);
UE_LOG(LogMyGame, Error, TEXT("严重错误！"));
```

### 使用可视化日志

```cpp
// ✅ 可视化调试
#include "VisualLogger/VisualLogger.h"

UE_VLOG_SEGMENT(this, LogTemp, Log, StartPos, EndPos, FColor::Red, TEXT("Raycast"));
UE_VLOG_LOCATION(this, LogTemp, Log, TargetLocation, 50.f, FColor::Green, TEXT("Target"));
```

---

## 总结：UE 5.7 推荐技术栈

| 特性 | 推荐使用（2026年） | 备注 |
|---------|------------------|-------|
| **光照** | Lumen + Megalights | 实时 GI，百万级光源 |
| **几何体** | Nanite | 高面数网格体，自动 LOD |
| **材质** | Substrate | 模块化，物理精确 |
| **输入** | Enhanced Input | 可重新绑定，模块化 |
| **VFX** | Niagara | GPU 加速 |
| **音频** | MetaSounds | 程序化音频 |
| **世界流式加载** | World Partition | 大型开放世界 |
| **游戏玩法** | Gameplay Ability System | 复杂技能、增益效果 |

---

**来源：**
- https://docs.unrealengine.com/5.7/en-US/
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
