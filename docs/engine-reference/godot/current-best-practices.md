<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 4.5 — 当前最佳实践

> 最后验证：2026-02-13
> 来源：[官方 Godot 4.5 文档](https://docs.godotengine.org/en/4.5/)

本文件记录模型训练数据中不存在的 **新最佳实践和模式**。

---

## 使用 await 和信号

在 Godot 4 中，`yield()` 已被完全移除。使用 `await`：

```gdscript
# 模型可能生成过时的代码：
yield(get_tree().create_timer(1.0), "timeout")

# Godot 4.5 的正确语法：
await get_tree().create_timer(1.0).timeout
```

## 类型化数组

在 `4.5` 中 Godot 引入了运行时类型检查的类型化数组。
总是为数组指定类型以提高性能并捕获类型相关的 bug。

```gdscript
# 推荐（类型化数组）：
var enemies: Array[Enemy] = []
var positions: Array[Vector2] = []

# 避免（无类型数组）：
var enemies := []  # Array[Variant]
```

## 节点引用

使用 `@onready` 和 `$` 简写代替显式的 `get_node()`：

```gdscript
# 首选：
@onready var player: CharacterBody3D = $Player
@onready var health_bar: ProgressBar = $UI/HealthBar

# 避免：
var player: CharacterBody3D
func _ready() -> void:
    player = get_node("Player") as CharacterBody3D
```

## 物理

使用 `_physics_process(delta: float)` 而非 `_process()` 进行游戏逻辑。
始终使用 `delta` 参数实现帧率无关的行为。

## 信号连接

使用 `Signal.connect()` 和 `Signal.emit()` 方法，而非无类型的字符串连接：

```gdscript
# 首选（Godot 4 风格）：
button.pressed.connect(_on_button_pressed)

# 避免（Godot 3 风格，已弃用）：
# button.connect("pressed", self, "_on_button_pressed")
```

## Tween 使用

旧 `SceneTreeTween` 已被新的 `Tween` API 取代：

```gdscript
# Godot 4.5 的正确语法（创建 Tween）：
var tween := create_tween()
tween.tween_property($Sprite, "position", Vector2(100, 0), 1.0)

# 避免 Godot 3.x 语法（已移除）：
# $Tween.interpolate_property(...)
```

## 着色器

着色器语言在 Godot 4.5 中使用新的结构特性引入了
`shader_type`。片段/顶点处理器在 `fragment()` 和 `vertex()` 函数中定义，
而非旧的 `void fragment()` 模式：

```glsl
shader_type spatial;

void fragment() {
    // 片段着色器逻辑
}

void vertex() {
    // 顶点着色器逻辑
}
```

## 资源预加载

对于频繁使用的资源，使用 `preload()` 作为常量以获得更好的性能：

```gdscript
const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const HIT_SOUND := preload("res://audio/hit.wav")
```

## 导出变量

使用新的 `@export` 注释和带类型的提示。Godot 4.5 中，
导出变量类型更为严格 —— 类型必须与提示匹配：

```gdscript
@export var speed: float = 10.0
@export var max_health: int = 100
@export_range(0.0, 1.0) var volume: float = 0.8
@export var enemy_scene: PackedScene
@export_multiline var description: String = ""
```
