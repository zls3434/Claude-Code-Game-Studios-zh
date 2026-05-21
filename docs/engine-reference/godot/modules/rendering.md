<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 4.5 — 渲染参考

> 最后验证：2026-02-13
> Godot 文档 — [Rendering](https://docs.godotengine.org/en/4.5/tutorials/rendering/index.html)

## RenderingServer

核心渲染系统。通过 `RenderingServer` 单例访问。

| 方法 | 用途 | 备注 |
|--------|---------|-------|
| `set_default_clear_color(color)` | 背景色 | 默认 Viewport 的背景色 |
| `global_shader_parameter_set(name, value)` | 设置全局着色器 uniform | 所有着色器可见 |
| `get_rendering_device()` | 获取 Vulkan 设备 | 用于底层 compute |
| `create_local_rendering_device()` | 独立 Vulkan 设备 | 用于 compute shader |

## Viewport

渲染目标。

| 属性/方法 | 用途 | 备注 |
|---------------|---------|-------|
| `transparent_bg` | 透明背景 | 用于 UI 叠加层 |
| `msaa_3d` | 多重采样 | `VIEWPORT_MSAA_2X`、`4X`、`8X` |
| `screen_space_aa` | 屏幕空间抗锯齿 | `SCREEN_SPACE_AA_FXAA` |
| `use_occlusion_culling` | 遮挡剔除 | 大场景性能关键 |
| `disable_3d` | 跳过 3D 渲染 | 用于 2D 游戏 |
| `get_texture()` | 获取 Viewport 纹理 | 用于 3D 中的画中画效果 |
| `set_use_xr(use)` | 启用 XR | VR/AR 渲染 |
| `scaling_3d_mode` | 分辨率缩放 | `VIEWPORT_SCALING_3D_MODE_FSR2` 等 |
| `scaling_3d_scale` | 缩放因子 | 0.5 = 半分辨率 |

## Camera3D

视角控制。

| 属性/方法 | 用途 | 备注 |
|---------------|---------|-------|
| `fov` | 垂直视野 | 度数 |
| `near` / `far` | 裁剪平面 | `near` ≥ 0.01 |
| `projection` | 透视/正交 | `PROJECTION_PERSPECTIVE` 或 `PROJECTION_ORTHOGONAL` |
| `current` | 活动摄像头 | 如果多个摄像头，启用设为 true |
| `h_offset` / `v_offset` | 镜头偏移 | 用于倾斜位移或副屏分屏 |
| `cull_mask` | 渲染层掩码 | 用于分层渲染 |
| `environment` | 覆盖环境 | 每个摄像头的天空/后处理/雾 |
| `doppler_tracking` | 多普勒效应 | `DOPPLER_TRACKING_IDLE_STEP` 等 |
| `frustum_offset` | 非对称视锥体 | 用于 CAVE/多投影 |
| `attributes` | CameraAttributes | 自动曝光、DOF 等 |

## 环境（Environment）

全局氛围和后处理。

| 属性 | 用途 |
|----------|---------|
| `background` | 天空设置（Sky、颜色、自定义） |
| `ambient_light_source` | 天空贡献/颜色/禁用 |
| `tonemap` | HDR 色调映射器（ACES、Filmic、Linear） |
| `glow` | 泛光后处理（强度、混合模式、阈值） |
| `ssr` | 屏幕空间反射 |
| `ssao` | 屏幕空间环境光遮蔽 |
| `ssil` | 屏幕空间间接光照 |
| `fog` | 雾模式（指数、深度）和颜色 |
| `volumetric_fog` | 体积雾（密度、反照率、全局注入） |
| `adjustments` | 后处理调整（亮度、对比度、饱和度） |

## 灯光（Light3D）

| 类型 | 主要用途 |
|------|---------|
| `DirectionalLight3D` | 太阳/月亮（平行光，无限远） |
| `OmniLight3D` | 点光源（火把、灯泡） |
| `SpotLight3D` | 聚光灯（手电筒、舞台灯光） |

| 通用属性 | 用途 | 备注 |
|----------|---------|-------|
| `light_color` | 灯光颜色 | 黑色 = 关 |
| `light_energy` | 亮度倍率 | 支持 HDR（> 1.0） |
| `light_size` | 软阴影半径 | 更大的值 = 更柔和的阴影 |
| `shadow_enabled` | 投射阴影 | 性能成本 |
| `shadow_bias` | 阴影偏移 | 修复阴影痤疮 |
| `cull_mask` | 渲染层掩码 | 按层选择性光照 |

## 着色器（GDScript 侧）

| 方法 | 用途 | 备注 |
|--------|---------|-------|
| `set_shader_parameter(name, value)` | 设置 material uniform | 每个实例的材质覆盖 |
| `get_shader_parameter(name)` | 读取 material uniform | 动态效果 |
| `ShaderMaterial` / `material_override` | 每个对象的材质 | 用于自定义着色器 |

## 常见模式

```gdscript
# 自定义分辨率缩放
func _ready() -> void:
    get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
    get_viewport().scaling_3d_scale = 0.75  # 75% 分辨率

# 全局着色器参数
func _process(delta: float) -> void:
    var t: float = Time.get_ticks_msec() / 1000.0
    RenderingServer.global_shader_parameter_set("time", t)

# 多摄像头设置
func _ready() -> void:
    $PlayerView.current = true   # 游戏视角
    $MinimapView.current = false  # 小地图摄像头
    $MinimapView.set_world_3d(get_viewport().world_3d)  # 共享世界
```
