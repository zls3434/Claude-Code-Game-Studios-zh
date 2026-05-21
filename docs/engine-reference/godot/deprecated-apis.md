<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 4.5 — 已弃用 API 速查表

> 最后验证：2026-02-13

此表列出了已弃用的 GDScript API，以及你应该使用的替代方案。
**Agent：在编写任何 GDScript 代码时检查此表。**

---

## 节点操作

| 弃用 API | 替代方案 | 备注 |
|---------------|--------------|-------|
| `Node.set_name()` | `Node.name =` | 直接属性赋值 |
| `Node.get_name()` | `Node.name` | 直接属性访问 |
| `Node.is_a_parent_of()` | `Node.is_ancestor_of()` | 重命名更清晰 |
| `Node.remove_and_skip()` | 手动重新父节点逻辑 | 在 4.5 中移除 |
| `Node.get_child_count()` | `Node.get_child_count()`（保留） | 未弃用，仅验证用法 |

## 场景和资源加载

| 弃用 API | 替代方案 | 备注 |
|---------------|--------------|-------|
| `ResourceLoader.load_interactive()` | `ResourceLoader.load_threaded_request()` | 异步加载 |
| `ResourceLoader.exists()` | `ResourceLoader.has_cached()` | 检查已加载资源缓存 |
| `PackedScene.instance()` | `PackedScene.instantiate()` | 在 Godot 4.0 中重命名 |
| `ResourceSaver.save()` | `ResourceSaver.save()`（保留，签名已更改） | 路径现在是 `file_path` |

## 输入

| 弃用 API | 替代方案 | 备注 |
|---------------|--------------|-------|
| `Input.is_key_pressed()` | `Input.is_physical_key_pressed()` 或 `Input.is_key_pressed()` | 现在在 4.5 中同时存在 |
| `InputEventWithModifiers.mod` | `InputEventWithModifiers.modifiers` | 避免 Alt/Ctrl/Shift 掩码错误 |

## 数学和工具

| 弃用 API | 替代方案 | 备注 |
|---------------|--------------|-------|
| `Vector2.clamped()` | `Vector2.limit_length()` | 新方法 |
| `Vector3.clamped()` | `Vector3.limit_length()` | 新方法 |
| `AABB.has_no_surface()` | `AABB.has_volume()` | 反转语义 |
| `Transform3D.xform(Vector3)` | `Transform3D * Vector3` | 运算符重载 |
| `randi() % N` | `randi_range(0, N-1)` | 避免模偏差 |

## 信号

| 弃用 API | 替代方案 | 备注 |
|---------------|--------------|-------|
| `Object.connect(signal, callable)` | `signal.connect(callable)` | 新语法 |
| `Object.emit_signal(signal, args)` | `signal.emit(args)` | 新语法 |
| `Object.is_connected(signal, callable)` | `signal.is_connected(callable)` | 新语法 |

## 动画

| 弃用 API | 替代方案 | 备注 |
|---------------|--------------|-------|
| `AnimationPlayer.playback_speed` | `AnimationPlayer.speed_scale` | 已重命名 |
| `AnimationPlayer.is_playing()` | `AnimationPlayer.is_playing()`（保留） | 未弃用，仅验证用法 |
| `AnimationNodeBlendTree.connect_node()` | 使用 `AnimationNodeBlendTree.add_node()` 并手动连接 | API 简化 |
