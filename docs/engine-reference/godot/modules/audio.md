<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 4.5 — 音频参考

> 最后验证：2026-02-13
> Godot 文档 — [Audio](https://docs.godotengine.org/en/4.5/tutorials/audio/audio_buses.html)

## AudioStreamPlayer

直接音频播放（SFX、一次性音效）。

| 方法/属性 | 用途 | 备注 |
|---------------|---------|-------|
| `play(from_position)` | 播放分配的声音 | 可选 `from_position` 起始点 |
| `stop()` | 停止播放 | 重置位置到 0 |
| `stream` | 要播放的 AudioStream | 赋值来更改声音 |
| `volume_db` | 分贝音量 | 范围：-80 到 24，默认 0 |
| `pitch_scale` | 播放速度倍率 | 1.0 = 正常，影响音高 |
| `playing` | 是否正在播放？ | 只读布尔属性 |
| `autoplay` | 加入场景时自动播放 | 布尔属性 |
| `bus` | 音频总线名称 | 路由到特定总线 |

## AudioStreamPlayer2D/3D

空间化音频（位置、衰减）。

| 方法/属性 | 用途 | 备注 |
|---------------|---------|-------|
| 继承上述所有 | + 位置衰减 | 空间化层 |
| `max_distance` | 衰减最大距离 | 超出则听不见 |
| `attenuation` | 衰减曲线 | `ATTENUATION_INVERSE_DISTANCE` 等 |
| `area_mask` | 音频区域掩码 | 区域音频逻辑 |

## AudioStreamPlayerInteractive

用于交互式音乐播放。多个音乐流之间的过渡。

| 方法 | 用途 | 备注 |
|--------|---------|-------|
| `switch_to_clip(clip_index)` | 过渡到指定索引 | 带平滑变换的立即过渡 |
| `transition_to_clip(clip_index, fade_from, fade_to)` | 渐变过渡 | 可选 `fade_from` 毫秒 |

## AudioBus

全局音频控制。

| 属性 | 用途 | 备注 |
|----------|---------|-------|
| `volume_db` | 总线音量 | 通过 `AudioServer` 访问 |
| `mute` | 静音总线 | 布尔属性 |
| `bypass_effects` | 旁路效果器 | 用于性能 |
| `send` | 发送目标 | 路由到另一总线 |
| `effect_count` | 效果器数量 | 检查链 |

## 常见模式

```gdscript
# 在 2D 位置播放 SFX
var player := AudioStreamPlayer2D.new()
player.stream = preload("res://audio/explosion.wav")
player.position = global_position
add_child(player)
player.play()
await player.finished
player.queue_free()

# 全局总线音量（主总线）
AudioServer.set_bus_volume_db(
    AudioServer.get_bus_index("Master"), -6.0
)
```
