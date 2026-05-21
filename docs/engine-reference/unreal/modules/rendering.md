<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Unreal Engine 5.7 — 渲染模块参考

**最后验证：** 2026-02-13
**知识差距：** UE 5.7 具有 Megalights、生产就绪的 Substrate 以及 Lumen 改进

---

## 概述

UE 5.7 渲染栈：
- **Lumen**：实时全局光照（默认启用）
- **Nanite**：虚拟化几何体，支持数百万三角形
- **Megalights**：支持数百万动态光源（UE 5.5+ 新增）
- **Substrate**：生产就绪的模块化材质系统（UE 5.7 新增）

---

## Lumen（全局光照）

### 启用 Lumen

```cpp
// Project Settings > Engine > Rendering > Dynamic Global Illumination Method = Lumen
// 实时 GI，无需光照贴图烘焙
```

### Lumen 质量设置

```ini
; DefaultEngine.ini
[/Script/Engine.RendererSettings]
r.Lumen.DiffuseColorBoost=1.0
r.Lumen.ScreenProbeGather.RadianceCache.NumFramesToKeepCached=2
```

### 在 C++ 中使用 Lumen

```cpp
// 检查 Lumen 是否已启用
bool bIsLumenEnabled = IConsoleManager::Get().FindConsoleVariable(TEXT("r.DynamicGlobalIlluminationMethod"))->GetInt() == 1;
```

---

## Nanite（虚拟化几何体）

### 在 Static Mesh 上启用 Nanite

1. Static Mesh Editor
2. Details > Nanite Settings > Enable Nanite Support
3. 保存网格体（自动构建 Nanite 数据）

### 在 C++ 中使用 Nanite

```cpp
// 生成 Nanite 网格体
UStaticMeshComponent* MeshComp = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
MeshComp->SetStaticMesh(NaniteMesh); // 如果启用 Nanite，则自动使用
```

### Nanite 限制
- 不支持顶点动画（骨骼网格体）
- 材质中不支持世界位置偏移（WPO）
- 最适合静态高模几何体

---

## Megalights（UE 5.5+）

### 启用 Megalights

```cpp
// Project Settings > Engine > Rendering > Megalights = Enabled
// 支持数百万动态光源，性能损耗极低
```

### Megalights 用法

```cpp
// 像往常一样添加 Point Light
UPointLightComponent* Light = CreateDefaultSubobject<UPointLightComponent>(TEXT("Light"));
Light->SetIntensity(5000.0f);
Light->SetAttenuationRadius(500.0f);

// Megalights 自动处理成千上万乃至数百万个这样的光源
```

---

## Substrate 材质（UE 5.7 生产就绪）

### 启用 Substrate

```cpp
// Project Settings > Engine > Substrate > Enable Substrate
// 重启编辑器
```

### Substrate 材质节点
- **Substrate Slab**：物理材质层（漫反射、高光等）
- **Substrate Blend**：混合多个层
- **Substrate Thin Film**：彩虹色、肥皂泡效果
- **Substrate Hair**：头发专用着色

### Substrate 材质图示例

```
Substrate Slab（Diffuse）
  └─ Base Color：Texture Sample
  └─ Roughness：Constant（0.5）
  └─ Metallic：Constant（0.0）
  └─ Connect to Material Output
```

---

## 材质（C++ API）

### 动态材质实例

```cpp
// 创建动态材质实例
UMaterialInstanceDynamic* DynMat = UMaterialInstanceDynamic::Create(BaseMaterial, this);

// 设置参数
DynMat->SetVectorParameterValue(TEXT("BaseColor"), FLinearColor::Red);
DynMat->SetScalarParameterValue(TEXT("Metallic"), 0.8f);
DynMat->SetTextureParameterValue(TEXT("DiffuseTexture"), MyTexture);

// 应用到网格体
MeshComp->SetMaterial(0, DynMat);
```

---

## 后处理

### Post-Process Volume

```cpp
// 添加到关卡中
APostProcessVolume* PPV = GetWorld()->SpawnActor<APostProcessVolume>();
PPV->bUnbound = true; // 影响整个世界

// 配置设置
PPV->Settings.bOverride_MotionBlurAmount = true;
PPV->Settings.MotionBlurAmount = 0.5f;

PPV->Settings.bOverride_BloomIntensity = true;
PPV->Settings.BloomIntensity = 1.0f;
```

### 在 C++ 中后处理

```cpp
// 访问摄像机后处理设置
APlayerController* PC = GetWorld()->GetFirstPlayerController();
if (APlayerCameraManager* CamManager = PC->PlayerCameraManager) {
    CamManager->PostProcessBlendWeight = 1.0f;
    CamManager->PostProcessSettings.BloomIntensity = 2.0f;
}
```

---

## 光照

### Directional Light（太阳）

```cpp
ADirectionalLight* Sun = GetWorld()->SpawnActor<ADirectionalLight>();
Sun->SetActorRotation(FRotator(-45.f, 0.f, 0.f));
Sun->GetLightComponent()->SetIntensity(10.0f);
Sun->GetLightComponent()->bCastShadows = true;
```

### Point Light

```cpp
APointLight* Light = GetWorld()->SpawnActor<APointLight>();
Light->SetActorLocation(FVector(0, 0, 200));
Light->GetPointLightComponent()->SetIntensity(5000.0f);
Light->GetPointLightComponent()->SetAttenuationRadius(1000.0f);
Light->GetPointLightComponent()->SetLightColor(FLinearColor::Red);
```

### Spot Light

```cpp
ASpotLight* Spotlight = GetWorld()->SpawnActor<ASpotLight>();
Spotlight->GetSpotLightComponent()->SetInnerConeAngle(20.0f);
Spotlight->GetSpotLightComponent()->SetOuterConeAngle(40.0f);
```

---

## 渲染目标（渲染到纹理）

### 创建 Render Target

```cpp
// 创建 Render Target 资产（2D 纹理）
UTextureRenderTarget2D* RenderTarget = NewObject<UTextureRenderTarget2D>();
RenderTarget->InitAutoFormat(512, 512); // 512x512 分辨率
RenderTarget->UpdateResourceImmediate();

// 将场景渲染到纹理
UKismetRenderingLibrary::DrawMaterialToRenderTarget(
    GetWorld(),
    RenderTarget,
    MaterialToDraw
);
```

---

## 自定义渲染通道（高级）

### Render Dependency Graph (RDG)

```cpp
// UE5 使用 Render Dependency Graph 进行自定义渲染
// 示例：自定义后处理通道

#include "RenderGraphBuilder.h"

void RenderCustomPass(FRDGBuilder& GraphBuilder, const FViewInfo& View) {
    FRDGTextureRef SceneColor = /* 获取场景颜色纹理 */;

    // 定义通道参数
    struct FPassParameters {
        FRDGTextureRef InputTexture;
    };

    FPassParameters* PassParams = GraphBuilder.AllocParameters<FPassParameters>();
    PassParams->InputTexture = SceneColor;

    // 添加渲染通道
    GraphBuilder.AddPass(
        RDG_EVENT_NAME("CustomPass"),
        PassParams,
        ERDGPassFlags::Raster,
        [](FRHICommandList& RHICmdList, const FPassParameters* Params) {
            // 渲染命令
        }
    );
}
```

---

## 性能

### 渲染统计

```cpp
// 用于性能分析的 Console commands：
// stat fps - 显示 FPS
// stat unit - 显示帧时间分解
// stat gpu - 显示 GPU 时间
// profilegpu - 详细 GPU 性能分析
```

### 可扩展性设置

```cpp
// 获取当前可扩展性设置
UGameUserSettings* Settings = UGameUserSettings::GetGameUserSettings();
int32 ViewDistanceQuality = Settings->GetViewDistanceQuality(); // 0-4

// 设置可扩展性
Settings->SetViewDistanceQuality(3); // 高
Settings->SetShadowQuality(2); // 中
Settings->ApplySettings(false);
```

---

## 调试

### 可视化渲染特性

```
Console commands：
- r.Lumen.Visualize 1 - 显示 Lumen 调试
- r.Nanite.Visualize 1 - 显示 Nanite 三角形
- viewmode wireframe - 线框模式
- viewmode unlit - 禁用光照
- show collision - 显示碰撞网格体
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/lumen-global-illumination-and-reflections-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/nanite-virtualized-geometry-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/substrate-materials-in-unreal-engine/
