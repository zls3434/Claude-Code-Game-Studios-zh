<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
---
paths:
  - "assets/shaders/**"
---

# 着色器代码标准

`assets/shaders/` 中的所有着色器文件必须遵循以下标准，以维持
视觉质量、性能和跨平台兼容性。

## 命名规范
- 文件命名：`[类型]_[类别]_[名称].[扩展名]`
  - `spatial_env_water.gdshader`（Godot）
  - `SG_Env_Water`（Unity Shader Graph）
  - `M_Env_Water`（Unreal Material）
- 使用描述性名称，能说明材质的用途
- 以着色器类型为前缀：`spatial_`、`canvas_`、`particles_`、`post_`

## 代码质量
- 所有 uniform/参数必须有描述性名称和恰当的 hint
- 对相关参数进行分组（Godot：`group_uniforms`，Unity：`[Header]`，Unreal：Category）
- 为不直观的计算添加注释（尤其是数学密集型部分）
- 禁止魔法数字 —— 使用命名常量或有文档的 uniform 值
- 每个着色器文件顶部必须包含作者和用途注释

## 性能要求
- 为每个着色器文档化目标平台和复杂度预算
- 在不需要全精度的移动端使用合适的精度：`half`/`mediump`
- 片段着色器中最小化纹理采样
- 避免片段着色器中的动态分支 —— 使用 `step()`、`mix()`、`smoothstep()`
- 循环内禁止纹理读取
- 模糊效果采用两遍方式（先水平再垂直）

## 跨平台
- 在最低规格目标硬件上测试着色器
- 为较低画质等级提供备用/简化版本
- 文档化着色器针对的渲染管线（Forward/Deferred、URP/HDRP、Forward+/Mobile/Compatibility）
- 不要在同一目录中混用不同渲染管线的着色器

## 变体管理
- 最小化着色器变体数量 —— 每个变体都是一个单独编译的着色器
- 文档化所有 keywords/变体及其用途
- 在可能的情况下使用 feature stripping 来减小构建体积
- 记录和监控每个着色器的总变体数
