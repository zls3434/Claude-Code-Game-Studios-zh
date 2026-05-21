<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：godot-shader-specialist

## Agent 摘要
领域：Godot shading language（GLSL 衍生）、视觉 shader（VisualShader 图）、材质设置、粒子 shader、后处理效果。
不拥有：gameplay 代码、艺术风格方向。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 Godot shading language / 材质 / 后处理）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义引用 `docs/engine-reference/godot/VERSION.md` 作为 Godot shader API 变更的权威来源

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "在 Godot 中为敌人死亡编写一个溶解效果 shader。"
**预期行为：**
- 生成有效的 Godot shading language 代码（非 HLSL，非直接 GLSL）
- 适当使用 `shader_type spatial;` 或 `canvas_item`
- 定义 `uniform float dissolve_amount : hint_range(0.0, 1.0);`
- 采样噪声纹理以确定逐像素的溶解阈值
- 对低于阈值的像素使用 `discard;`
- 可选择在溶解边界附近使用 emission 添加边缘发光
- 代码在 Godot shading language 中语法正确

### Case 2：HLSL 重定向
**输入：** "为此溶解效果编写 HLSL compute shader。"
**预期行为：**
- 不生成 HLSL 代码
- 明确声明："Godot 不直接使用 HLSL；它使用自己的 shading language（GLSL 衍生）"
- 将 HLSL 意图转换为等效的 Godot shader 方法
- 注明 Godot 4 中 RenderingDevice compute shader 可用，但是一个低级 API，如为意图则适当标记

### Case 3：截止后 API 变更 — 纹理采样（Godot 4.4）
**输入：** "在 shader 中使用 `texture()` 配合 sampler2D 采样噪声纹理。"
**预期行为：**
- 检查版本参考：Godot 4.4 更改了纹理采样器类型声明
- 标记潜在的 API 变更：`sampler2D` 语法和 `texture()` 调用行为可能与 4.4 之前不同
- 按迁移说明为项目固定版本（4.6）提供正确语法
- 不标记版本风险就不使用 4.4 之前的纹理采样语法

### Case 4：Fragment shader LOD 策略
**输入：** "水面 fragment shader 有 8 个纹理采样，在中端硬件上造成 GPU 瓶颈。"
**预期行为：**
- 识别逐 fragment 的纹理采样数量为主要成本驱动因素
- 提出 LOD 策略：
  - 基于距离减少采样数量（基于距离的 shader variant 或 LOD 级别）
  - 离线预烘焙部分纹理组合
  - 对远处采样使用较低分辨率噪声纹理
- 提供实现 LOD 方法的 shader 代码修改
- 不改变水面系统的 gameplay 行为

### Case 5：上下文传递 — Godot 4.6 辉光重做
**输入：** 引擎版本上下文：Godot 4.6。请求："向场景添加 bloom/glow 后处理效果。"
**预期行为：**
- 引用 VERSION.md 说明：Godot 4.6 包含辉光重做
- 使用 4.6 WorldEnvironment 方法而非 4.6 之前的 API 生成辉光配置指导
- 明确注明辉光重做中哪些属性或参数发生了变化
- 标记 LLM 训练数据中由于截止后时间可能信息不正确的任何属性

---

## 协议合规性

- [ ] 停留在声明领域内（Godot shading language、材质、VFX shader、后处理）
- [ ] 将 gameplay 代码请求重定向到 gameplay-programmer
- [ ] 生成有效的 Godot shading language — 不使用不带 Godot 包装的 HLSL 或原始 GLSL
- [ ] 对照引擎版本参考检查截止后 shader API 变更（4.4 纹理类型、4.6 辉光重做）
- [ ] 返回结构化输出（shader 代码附 uniform 文档、LOD 策略附性能原理）
- [ ] 将任何截止后 API 使用标记为需要验证

---

## 覆盖说明
- 溶解 shader（Case 1）应与 `production/qa/evidence/` 中的视觉测试截图配对
- 纹理 API 标记（Case 3）确认 agent 在使用 4.3 以后变更的 API 之前检查 VERSION.md
- 辉光重做（Case 5）是 Godot 4.6 特定测试 — 验证 agent 应用最新的迁移说明
