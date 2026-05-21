<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Unreal Engine 5.7 — 音频模块参考

**最后验证日期：** 2026-02-13
**知识盲区：** UE 5.7 MetaSounds 生产就绪

---

## 概述

UE 5.7 音频系统：
- **MetaSounds**：基于节点的程序化音频（推荐，生产就绪）
- **Sound Cue**：旧版基于节点的音频（简单场景使用）
- **Audio Component**：在 actor 上播放声音

---

## 基础音频播放

### 在指定位置播放声音

```cpp
#include "Kismet/GameplayStatics.h"

// ✅ 播放 2D 声音（无空间化）
UGameplayStatics::PlaySound2D(GetWorld(), ExplosionSound);

// ✅ 在指定位置播放声音（3D 空间音频）
UGameplayStatics::PlaySoundAtLocation(GetWorld(), ExplosionSound, GetActorLocation());

// ✅ 带音量和音高参数
UGameplayStatics::PlaySoundAtLocation(GetWorld(), ExplosionSound, GetActorLocation(), 0.7f, 1.2f);
```

---

## Audio Component

### Audio Component（持续声音）

```cpp
// 创建音频组件
UAudioComponent* AudioComp = CreateDefaultSubobject<UAudioComponent>(TEXT("Audio"));
AudioComp->SetupAttachment(RootComponent);
AudioComp->SetSound(LoopingAmbience);

// 播放/停止
AudioComp->Play();
AudioComp->Stop();

// 淡入/淡出
AudioComp->FadeIn(2.0f); // 2 秒
AudioComp->FadeOut(1.5f, 0.0f); // 1.5 秒淡出到音量 0

// 调整音量/音高
AudioComp->SetVolumeMultiplier(0.5f);
AudioComp->SetPitchMultiplier(1.2f);
```

---

## 3D 空间音频

### Attenuation 设置

```cpp
// 创建 Sound Attenuation 资产：
// 内容浏览器 > 声音 > Sound Attenuation

// 配置：
// - Attenuation Shape：球体、胶囊体、盒子、锥体
// - Falloff Distance：声音变得听不到的距离
// - Attenuation Function：线性、对数、反比等

// 在 C++ 中分配：
AudioComp->AttenuationSettings = AttenuationAsset;
```

### 在代码中覆盖 Attenuation

```cpp
FSoundAttenuationSettings AttenuationOverride;
AttenuationOverride.AttenuationShape = EAttenuationShape::Sphere;
AttenuationOverride.FalloffDistance = 1000.0f;
AttenuationOverride.AttenuationShapeExtents = FVector(1000.0f);

AudioComp->AttenuationOverrides = AttenuationOverride;
AudioComp->bOverrideAttenuation = true;
```

---

## MetaSounds（程序化音频）

### 创建 MetaSound Source

1. 内容浏览器 > 声音 > MetaSound Source
2. 打开 MetaSound 编辑器
3. 构建节点图：
   - **输入**：触发器、参数
   - **生成器**：振荡器、噪声、采样
   - **调制器**：包络、LFO
   - **效果器**：滤波器、混响、延迟
   - **输出**：音频输出

### 播放 MetaSound

```cpp
// 像播放任何声音一样播放 MetaSound
UGameplayStatics::PlaySound2D(GetWorld(), MetaSoundSource);

// 或使用 Audio Component
AudioComp->SetSound(MetaSoundSource);
AudioComp->Play();
```

### 设置 MetaSound 参数

```cpp
// 在 MetaSound 中定义参数（带暴露参数的 Input 节点）
// 在 C++ 中设置参数：
AudioComp->SetFloatParameter(FName("Volume"), 0.8f);
AudioComp->SetIntParameter(FName("OctaveShift"), 2);
AudioComp->SetBoolParameter(FName("EnableReverb"), true);
```

---

## Sound Cue（旧版）

### 创建 Sound Cue

1. 内容浏览器 > 声音 > Sound Cue
2. 打开 Sound Cue 编辑器
3. 添加节点：Random、Modulator、Mixer 等

### 使用 Sound Cue

```cpp
// 像播放任何声音一样播放
UGameplayStatics::PlaySound2D(GetWorld(), SoundCue);
```

---

## Sound Class 与 Sound Mix

### Sound Class（音量分组）

```cpp
// 创建 Sound Class：内容浏览器 > 声音 > Sound Class
// 层级结构：Master > Music、SFX、Dialogue

// 分配给声音资产：
// Sound Wave > Sound Class = SFX

// 在 C++ 中设置音量：
UAudioSettings* AudioSettings = GetMutableDefault<UAudioSettings>();
// 通过 Sound Class 层级进行配置
```

### Sound Mix（动态混音）

```cpp
// 创建 Sound Mix 资产
// 定义调整项：对话时降低音乐音量等

// 压入 sound mix
UGameplayStatics::PushSoundMixModifier(GetWorld(), DuckedMusicMix);

// 弹出 sound mix
UGameplayStatics::PopSoundMixModifier(GetWorld(), DuckedMusicMix);
```

---

## 音频遮蔽与混响

### Audio Occlusion（墙壁阻挡声音）

```cpp
// 在 Audio Component 中启用：
AudioComp->bEnableOcclusion = true;

// 需要带有碰撞的几何体
```

### Reverb Volume

```cpp
// 在关卡中添加 Audio Volume（Volumes > Audio Volume）
// 在 Details 面板中配置混响设置
// Audio Component 在进入 volume 时会自动启用混响
```

---

## 常用模式

### 脚步声（随机变化）

```cpp
// 使用带 Random 节点的 Sound Cue，或：
UPROPERTY(EditAnywhere, Category = "Audio")
TArray<TObjectPtr<USoundBase>> FootstepSounds;

void PlayFootstep() {
    int32 Index = FMath::RandRange(0, FootstepSounds.Num() - 1);
    UGameplayStatics::PlaySoundAtLocation(GetWorld(), FootstepSounds[Index], GetActorLocation());
}
```

### 音乐交叉淡入淡出

```cpp
UAudioComponent* MusicA;
UAudioComponent* MusicB;

void CrossfadeMusic(float Duration) {
    MusicA->FadeOut(Duration, 0.0f);
    MusicB->FadeIn(Duration);
}
```

### 检查声音是否正在播放

```cpp
if (AudioComp->IsPlaying()) {
    // 声音正在播放
}
```

---

## 音频并发

### 限制并发声音

```cpp
// 创建 Sound Concurrency 资产：
// 内容浏览器 > 声音 > Sound Concurrency

// 配置：
// - Max Count：此声音的最大实例数
// - Resolution Rule：停止最旧的、最安静的等

// 分配给声音：
// Sound Wave > Concurrency Settings
```

---

## 性能提示

### 音频优化

```cpp
// 压缩设置（Sound Wave 资产）：
// - Compression Quality：40（平衡质量/大小）
// - Streaming：对大文件启用（音乐）

// 减少音频混音成本：
// - 通过 Sound Concurrency 限制并发声音
// - 使用简单的 attenuation 形状

// 对远处 actor 禁用音频：
if (Distance > MaxAudibleDistance) {
    AudioComp->Stop();
}
```

---

## 调试

### 音频调试命令

```cpp
// 控制台命令：
// au.Debug.Sounds 1 - 显示活跃的声音
// au.3dVisualize.Enabled 1 - 可视化 3D 音频
// stat soundwaves - 显示声音统计
// stat soundmixes - 显示活跃的 sound mix
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/audio-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/metasounds-in-unreal-engine/
