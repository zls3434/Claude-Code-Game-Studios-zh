<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 4.5 — 导航参考

> 最后验证：2026-02-13
> Godot 文档 — [Navigation](https://docs.godotengine.org/en/4.5/tutorials/navigation/navigation_introduction_3d.html)

## NavigationServer3D

核心导航服务器。Agent 应使用 `NavigationServer3D` 而非直接操作底层 API。

| 方法 | 用途 | 备注 |
|--------|---------|-------|
| `map_create()` | 创建导航地图 | 返回 RID |
| `map_set_active(rid, active)` | 激活/停用地图 | 性能优化 |
| `region_create()` | 创建导航区域 | 为导航网格返回 RID |
| `region_set_map(rid, map)` | 将区域分配到地图 | 使导航网格可用于寻路 |
| `region_set_transform(rid, transform)` | 设置区域变换 | 用于移动导航网格 |
| `region_set_navigation_mesh(rid, navigation_mesh)` | 设置导航网格 | 使用 NavigationMesh 资源 |
| `region_set_enabled(rid, enabled)` | 启用/禁用区域 | 临时移除 |
| `map_get_path(map, from, to, optimize, navigation_layers)` | 计算路径 | 返回 `PackedVector3Array` |
| `map_get_closest_point(map, point)` | 获取最近点 | 返回导航网格上的 Vector3 |

## NavigationAgent3D

基于节点的导航代理。方便使用和回调。

| 方法/属性 | 用途 | 备注 |
|---------------|---------|-------|
| `target_position` | 导航目标 | 设置目标世界坐标 |
| `set_target_position(position)` | 替代设置器 | 与上方属性相同 |
| `get_next_path_position()` | 下一个航点点 | 用于基于 steer 的移动 |
| `is_navigation_finished()` | 是否到达目标？ | 布尔查询 |
| `distance_to_target()` | 到目标的距离 | 浮点数，世界单位 |
| `navigation_finished` | 到达时发出信号 | 连接以获知何时到达 |
| `path_changed` | 路径更新时发出信号 | 用于可视化 |
| `velocity_computed` | 安全速度请求 | 用于 `_physics_process` |
| `avoidance_enabled` | 代理间避让 | 默认开启，布尔属性 |
| `max_speed` | 代理移动速度 | 由服务器用于避让 |
| `radius` / `height` | 代理尺寸 | 用于碰撞检查 |

## 常见模式

```gdscript
extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
    actor_setup()

func actor_setup() -> void:
    await get_tree().physics_frame  # 等待第一个物理帧
    set_movement_target(Vector3(10, 0, 10))

func set_movement_target(target: Vector3) -> void:
    nav_agent.target_position = target

func _physics_process(delta: float) -> void:
    if nav_agent.is_navigation_finished():
        return

    var next_pos: Vector3 = nav_agent.get_next_path_position()
    var direction: Vector3 = global_position.direction_to(next_pos)
    velocity = direction * 5.0
    move_and_slide()
```

Go To 行为模式 — 替代上文 `_physics_process`：

```gdscript
func _physics_process(delta: float) -> void:
    var target: Vector3 = nav_agent.get_next_path_position()
    var desired_velocity: Vector3 = global_position.direction_to(target) * speed
    var steering: Vector3 = (desired_velocity - velocity) * 4.0
    velocity += steering * delta
    move_and_slide()
```
