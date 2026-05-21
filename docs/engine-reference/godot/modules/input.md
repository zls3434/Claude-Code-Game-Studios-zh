<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 4.5 — 输入参考

> 最后验证：2026-02-13
> Godot 文档 — [Input](https://docs.godotengine.org/en/4.5/classes/class_input.html)

## InputEvent 类型

现代 Godot 使用带类型的输入事件，而非通用字符串检查。

| 类型 | 使用场景 | 属性 |
|------|---------|------------|
| `InputEventKey` | 键盘按键 | `keycode`、`physical_keycode`、`echo`、`pressed` |
| `InputEventMouseButton` | 鼠标按钮 | `button_index`、`pressed`、`double_click` |
| `InputEventMouseMotion` | 鼠标移动 | `relative`、`velocity` |
| `InputEventJoypadButton` | 手柄按钮 | `button_index`、`pressed` |
| `InputEventJoypadMotion` | 手柄摇杆 | `axis`、`axis_value` |
| `InputEventScreenTouch` | 触摸屏按下 | `index`、`position`、`pressed` |
| `InputEventScreenDrag` | 触摸屏拖拽 | `index`、`position`、`relative` |
| `InputEventAction` | 输入映射动作 | `action`、`pressed`、`strength` |

## InputEventAction（首选方式）

```gdscript
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("jump"):
        _do_jump()
    elif event.is_action_released("jump"):
        _release_jump()
```

## Input Singleton

用于轮询当前状态。

```gdscript
# 检查当前是否按下
if Input.is_action_pressed("jump"):
    velocity.y = JUMP_VELOCITY

# 检查是否刚按下（沿）
if Input.is_action_just_pressed("attack"):
    _attack()

# 获取轴值（-1.0 到 1.0）
var direction: float = Input.get_axis("move_left", "move_right")

# 获取矢量方向
var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

# 鼠标位置和动作
var mouse_pos: Vector2 = get_viewport().get_mouse_position()
```

## 输入映射

通过 `InputMap` 可编程设置：

```gdscript
# 创建动作
InputMap.add_action("dash")
var event := InputEventKey.new()
event.keycode = KEY_SHIFT
InputMap.action_add_event("dash", event)
```

## 常见模式

```gdscript
# 标准平台游戏移动
func _physics_process(delta: float) -> void:
    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_dir * speed
    move_and_slide()

# 鼠标捕获/释放
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
```
