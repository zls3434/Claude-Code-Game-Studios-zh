<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 4.5 — 物理参考

> 最后验证：2026-02-13
> Godot 文档 — [Physics](https://docs.godotengine.org/en/4.5/tutorials/physics/physics_introduction.html)

## CharacterBody3D

玩家/角色运动学角色控制器。

| 方法 | 用途 | 备注 |
|--------|---------|-------|
| `move_and_slide()` | 移动角色并滑动 | 设置 `velocity` 后调用。返回是否发生碰撞 |
| `velocity` | 运动矢量 | 在调用 `move_and_slide()` 前赋值 |
| `up_direction` | 向上矢量 | 用于地板/天花板检测，默认 `Vector3(0,1,0)` |
| `floor_max_angle` | 最大坡度角（弧度） | 默认 0.785398（45°） |
| `is_on_floor()` | 是否站在地板上？ | 最后一次 `move_and_slide()` 后 |
| `is_on_wall()` | 是否碰到墙壁？ | 最后一次 `move_and_slide()` 后 |
| `is_on_ceiling()` | 是否碰到天花板？ | 最后一次 `move_and_slide()` 后 |
| `get_last_slide_collision()` | 最后一次滑动碰撞 | 返回 `KinematicCollision3D` |
| `floor_normal` | 最后一次地板法线 | 环境法线矢量 |
| `wall_normal` | 最后一次墙壁法线 | 环境法线矢量 |

## CharacterBody2D

2D 等效版本。API 与 3D 相同，使用 `Vector2`。

## RigidBody3D

全物理模拟物体。

| 属性 | 用途 | 备注 |
|----------|---------|-------|
| `mass` | 质量（kg） | 影响力和冲量 |
| `gravity_scale` | 重力倍率 | 0 = 无重力 |
| `linear_velocity` | 当前线速度 | 读/写 |
| `angular_velocity` | 当前角速度 | 读/写 |
| `freeze` | 冻结物理 | 停止模拟 |
| `freeze_mode` | 静态或运动学 | `FREEZE_MODE_STATIC` / `FREEZE_MODE_KINEMATIC` |
| `can_sleep` | 允许休眠 | 不移动时用于性能 |
| `sleeping` | 是否正在休眠？ | 只读 |

| 方法 | 用途 |
|--------|---------|
| `apply_force(force, position)` | 在位置（世界空间）施加力 |
| `apply_central_force(force)` | 在质心施加力 |
| `apply_impulse(impulse, position)` | 在位置施加瞬时力 |
| `apply_torque(torque)` | 施加扭矩（角力） |

## StaticBody3D

非移动的碰撞体（世界几何体）。

| 属性 | 用途 |
|----------|---------|
| `physics_material_override` | 覆盖碰撞体力/摩擦/弹性 |
| `collision_layer` / `collision_mask` | 碰撞过滤 |

## Area3D

检测重叠/进入/退出。无碰撞响应。

| 属性/方法 | 用途 | 备注 |
|---------------|---------|-------|
| `monitoring` | 启用重叠检测 | 布尔属性 |
| `monitorable` | 可被其他区域检测 | 布尔属性 |
| `body_entered` / `body_exited` | 物理体信号 | 携带物理体节点 |
| `area_entered` / `area_exited` | 区域信号 | 携带区域节点 |
| `get_overlapping_bodies()` | 当前重叠的所有物理体 | 返回数组 |
| `get_overlapping_areas()` | 当前重叠的所有区域 | 返回数组 |
| `overlaps_body(body)` | 是否与特定物理体重叠？ | 布尔查询 |

## RayCast3D

射线检测。

| 方法/属性 | 用途 | 备注 |
|---------------|---------|-------|
| `target_position` | 射线终点（本地空间） | 射线从节点原点发出 |
| `enabled` | 启用射线 | 或在 `_physics_process` 中手动调用 `force_raycast_update()` |
| `is_colliding()` | 是否碰撞？ | 布尔查询 |
| `get_collider()` | 碰撞了哪个节点？ | 返回 Object，用 `as` 转换 |
| `get_collision_point()` | 世界空间碰撞点 | Vector3 |
| `get_collision_normal()` | 碰撞法线 | 表面法线 |
| `force_raycast_update()` | 立即投射 | 在 _physics_process 中用于即时检查 |

## 常见模式

```gdscript
# 基本平台游戏移动
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    move_and_slide()

# 射线检测拾取物品
func _physics_process(delta: float) -> void:
    $RayCast3D.force_raycast_update()
    if $RayCast3D.is_colliding():
        var collider := $RayCast3D.get_collider()
        if collider is Pickup:
            collider.collect()
```
