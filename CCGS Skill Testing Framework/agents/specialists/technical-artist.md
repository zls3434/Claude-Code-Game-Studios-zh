<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：technical-artist

## Agent 摘要
领域：艺术与工程之间的桥梁 — shader 实现、VFX、rigging 和动画与代码之间的约束、性能 cost 评估、美术工作流优化、资产管线。
不拥有：纯粹美学决策（art-director）。纯引擎系统编程（engine-programmer）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（shader、VFX、资产管线）
- [ ] `allowed-tools:` 列表匹配 agent 角色（读写 shader 文件，资产处理脚本）
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对纯艺术或纯代码拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "创建一个带有可配置宽度、颜色和脉冲速度的轮廓 shader。用于标记可交互物体。"
**预期行为：**
- 产出 shader 代码：
  - 沿着物体边缘偏移并轮廓为单色的 Vertex Shader
  - Fragment Shader 应用描边颜色
  - uniform 参数：`outline_width`、`outline_color`、`pulse_speed`
  - 脉冲：颜色 alpha 按正弦时间调制
- 适用于任何 3D 物体的通用轮廓
- 不设计使用此 shader 的艺术风格或具体视觉

### Case 2：领域外请求 — 适当重定向
**输入：** "现在基于此 shader 为可交互宝箱设计视觉外观 — 它的颜色、风格、装饰。"
**预期行为：**
- 重定向到 art-director 进行视觉设计
- Technical artist 完成 shader 实现后，艺术的创建由 art-director 处理

### Case 3：资产管线 — 网格导入
**输入：** "我们有 200 个 FBX 网格。我们需要：
- 验证它们是否符合 poly count 限制（<5000 三角形）
- 自动生成碰撞 mesh 的低多边形 LOD
- 将材质从 .fbx 重新映射到引擎的材质实例"
**预期行为：**
- 产出资产处理脚本（Python/C# 用于 Unity 或 Godot）：
  - 读取 FBX → 检查三角形数 → 标记过量的
  - 为所有 200 个资产自动生成 LOD0（全细节）、LOD1（50% 减面）、LOD2（碰撞）
  - 重新映射材质引用到引擎特定格式

### Case 4：性能 cost — 透明度排序
**输入：** "场景有 20 个透明对象（玻璃窗、水坑、粒子）。在 forward 渲染器中绘制顺序不正确 — 远处的透明对象出现在近处透明对象前面。"
**预期行为：**
- 识别透明度排序问题：
  - 在 Forward 渲染中，透明对象必须不依赖于 depth buffer（它们不写入 depth）
  - 提出排序解决方案：
    - 如果引擎支持：设置渲染队列以从后到前排序
    - 如果不支持：分割透明对象为多个 pass，通过摄像机距离排序

### Case 5：上下文传递 — 引擎 shader 系统
**输入上下文：** 引擎为 Unity。着色器使用 Shader Graph 或 HLSL。提供 `Shader.GetGlobalVector()` 用于全局 uniform。
**输入：** "创建一个使用全局风 uniform 进行草地摇摆效果的 shader。"
**预期行为：**
- 使用提供的上下文 API：
  - Shader Graph 节点：`Position` → 添加全局 `_WindDirection` + `_WindStrength` uniform → 随时间正弦位移
  - 或 HLSL：`float3 windOffset = _WindDirection * _WindStrength * sin(_Time.y + vertex.y);`
  - 所有参数通过 `Shader.GetGlobalVector()` 从 C# 传入

---

## 协议合规性

- [ ] 停留在声明领域内（shader 实现、VFX、管线、性能）
- [ ] 将纯视觉决定重定向到 art-director
- [ ] 使用上下文中提供的引擎 shader API
- [ ] 产出带有正确渲染顺序的透明排序

---

## 覆盖说明
- Case 3（资产管线）是可量化的 — agent 必须处理 200 个 FBX 文件的检查
- Case 5 要求引擎上下文在运行前可用；是最重要的上下文测试
- 无自动化运行器；手动审查或通过 `/skill-test`
