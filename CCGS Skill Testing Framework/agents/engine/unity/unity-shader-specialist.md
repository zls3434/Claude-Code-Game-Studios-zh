<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：unity-shader-specialist

## Agent 摘要
领域：Unity Shader Graph、自定义 HLSL、VFX Graph、URP/HDRP 管线自定义、后处理效果。
不拥有：gameplay 代码、艺术风格方向。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 Shader Graph / HLSL / VFX Graph / URP / HDRP）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对 gameplay 代码或艺术方向拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "使用 URP 中的 Shader Graph 为角色创建描边效果。"
**预期行为：**
- 生成 Shader Graph 节点设置描述：
  - 倒置外壳法：顶点阶段缩放法线 → 顶点偏移，Cull Front
  - 或使用深度/法线边缘检测的屏幕空间后处理描边
- 根据 URP 能力推荐适当方法（倒置外壳适合 URP 兼容性，后处理适合 HDRP）
- 注明 URP 限制：不支持几何 shader（排除了几何 shader 描边方法）
- 不确认渲染管线就不生成 HDRP 特定节点

### Case 2：领域外重定向
**输入：** "在代码中实现角色生命条 UI。"
**预期行为：**
- 不生成 UI 实现代码
- 明确声明 UI 实现属于 `ui-programmer`（或 `unity-ui-specialist`）
- 适当重定向请求
- 可备注如果视觉效果本身就是 shader 驱动的，则基于 shader 的生命条填充效果（例如溶解/填充渐变）在其领域内

### Case 3：HDRP 自定义 pass 用于描边
**输入：** "我们在 HDRP 上，希望描边作为后处理效果。"
**预期行为：**
- 生成 HDRP `CustomPassVolume` 模式：
  - 继承 `CustomPass` 的 C# 类
  - `Execute()` 方法使用 `CoreUtils.SetRenderTarget()` 和全屏 shader blit
  - 深度/法线缓冲采样用于边缘检测
- 注明 CustomPass 需要 HDRP 包，在 URP 中不工作
- 在提供 HDRP 特定代码之前确认项目使用 HDRP

### Case 4：VFX Graph 性能 — GPU 事件批处理
**输入：** "爆炸 VFX Graph 每个事件有 10,000 个粒子，同时生成 20 个爆炸导致 GPU 帧尖峰。"
**预期行为：**
- 将 GPU 粒子生成识别为成本驱动因素（200,000 个同时粒子）
- 提出 GPU 事件批处理：在多帧上延迟生成事件，交错初始化
- 建议每个活跃爆炸的粒子预算上限（例如每个爆炸 3,000 个，将超出部分排队）
- 注明 VFX Graph Event Batcher 模式和用于跨帧分发的 Output Event API
- 不改变 gameplay 事件系统 — 仅提出 VFX 侧预算解决方案

### Case 5：上下文传递 — 渲染管线（URP 或 HDRP）
**输入：** 项目上下文：URP 渲染管线，Unity 2022.3。请求："添加景深后处理。"
**预期行为：**
- 使用 URP Volume 框架：`DepthOfField` Volume Override 组件
- 不使用 HDRP Volume 组件（例如参数名称不同的 HDRP `DepthOfField`）
- 注明 URP 特定 DOF 限制与 HDRP 的差异（例如 Bokeh 质量差异）
- 生成与 Unity 2022.3 URP 包版本兼容的 C# Volume 配置文件设置代码

---

## 协议合规性

- [ ] 停留在声明领域内（Shader Graph、HLSL、VFX Graph、URP/HDRP 自定义）
- [ ] 将 gameplay 和 UI 代码重定向到适当的 agent
- [ ] 返回结构化输出（节点图描述、HLSL 代码、CustomPass 模式）
- [ ] 区分 URP 和 HDRP 方法 — 绝不交叉污染管线特定 API
- [ ] 在相关时标记几何 shader 方法与 URP 不兼容
- [ ] 生成不改变 gameplay 行为的 VFX 优化

---

## 覆盖说明
- 描边效果（Case 1）应与 `production/qa/evidence/` 中的视觉截图测试配对
- HDRP CustomPass（Case 3）确认 agent 生成正确的 Unity 模式，而非通用后处理方法
- 管线分离（Case 5）验证 agent 从不在无上下文的情况下假设渲染管线
