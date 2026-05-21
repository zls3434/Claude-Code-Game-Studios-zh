<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 4.5 — 动画参考

> 最后验证：2026-02-13
> Godot 文档 — [Animation](https://docs.godotengine.org/en/4.5/classes/class_animationplayer.html)

## AnimationPlayer

关键方法和属性。对于 Agent 而言，模型可能建议过时的 API。

| 方法 | 用途 | 备注 |
|--------|---------|-------|
| `play(name, custom_blend, custom_speed, from_end)` | 播放动画 | `custom_blend` 可平滑过渡 |
| `stop()` | 停止，重置到开始 | 确保动画重置 |
| `pause()` / `stop()` | 暂停/继续 | 调用 `pause()` 后调用 `play(false)` 可继续 |
| `seek(seconds, update)` | 跳转到时间点 | `update` 强制立即状态更新 |
| `advance(delta)` | 手动前进 | 在 `_process()` 中用于逐 delta 推进 |
| `speed_scale` | 播放速度倍率 | 0 = 停止，1 = 正常速度，负值 = 倒放 |
| `current_animation` | 当前播放的动画名称 | 只读属性 |
| `is_playing()` | 是否正在播放？ | 布尔查询 |
| `get_playing_speed()` | 当前速度 | 考虑 `speed_scale` |
| `assigned_animation` | 返回当前动画的 `Animation` 资源 | 可用于检查属性 |

## AnimationTree

状态机驱动的动画系统。

| 方法 | 用途 | 备注 |
|--------|---------|-------|
| `set("parameters/条件/current", value)` | 设置混合空间 | 字符串路径方法 |
| `get("parameters/条件/current")` | 获取当前值 | 通用 getter |
| `advance(delta)` | 手动前进树 | 用于手动处理 |
| `active` | 激活/停用处理 | 布尔属性 |

## Tween

用于值插值。

```gdscript
var tween := create_tween()
tween.tween_property($Sprite, "modulate:a", 0.0, 0.5)
tween.tween_callback(_on_fade_finished)
tween.set_parallel(true)  # 同时运行所有后续补间
```

## 常见模式

```gdscript
# 淡入淡出
var tween := create_tween()
tween.tween_property($Sprite, "modulate:a", 0.0, 0.5)
await tween.finished
$Sprite.queue_free()

# 连续动画
var tween := create_tween()
@warning_ignore("return_value_discarded")
tween.tween_property($Sprite, "position:x", 100, 1.0)
@warning_ignore("return_value_discarded")
tween.tween_property($Sprite, "position:y", 50, 0.5)
```
