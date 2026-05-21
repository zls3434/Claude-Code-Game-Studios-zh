<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：engine-programmer

## Agent 摘要
- **领域**：引擎核心系统 — 渲染、低级系统、效能优化、引擎升级/迁移、平台特定问题
- **不拥有**：游戏逻辑（gameplay-programmer）、AI 系统（ai-programmer）、UI（ui-programmer）
- **Model tier**：Sonnet（单个系统的实现）
- **Gate ID**：无

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引擎系统、渲染、低级）
- [ ] `allowed-tools:` 列表匹配 agent 角色（引擎代码，Bash — 如必要）
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对游戏机制拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "我们的 GPU 在移动端做 particle 渲染很慢。粒子使用每个粒子的透明度混合，50 个粒子。优化。"
**预期预期：
- 分析 GPU 粒子瓶颈：透明混合 + overdraw 在移动 GPU 上很昂贵
- 提出优化：
  - 减少粒子数（如果可能）或合并到更少、更大的粒子
  - 从透明度混合切换到加法混合（降低混合复杂度）
  - 如果支持，使用 GPU 实例化批量渲染粒子
- 不触及 gameplay 代码 (gameplay-programmer)

### Case 2：领域外请求 — 适当重定向
**输入：** "编写使用新渲染管线的 gameplay 用法代码。"
**预期行为：**
- 重定向到 gameplay-programmer
- 不编写 gameplay 逻辑
- 可提供引擎端 API 文档供 gameplay-programmer 使用

### Case 3：平台特定优化
**输入：** "我们在 Nintendo Switch 上看到 draw call 瓶颈 — 2000 个 draw call 在帧中。必须降到 500。"
**预期行为：**
- 分析 draw call 问题：
  - 2000 draw call 对于 Switch 过高 — 移动 GPU 对每个 DC 的开销很高
  - 使用 SRP Batcher、Static Batching 或 GPU Instancing 减少到 500
  - 为移动 GPU 批处理动态对象

### Case 4：引擎升级 — 破坏性 API 变更
**输入：** "我们正在从 Unity 2022 迁移到 2023。渲染管线 API 有 deprecation：`OnRenderImage` → `RenderPipelineManager.endCameraRendering`。"
**预期行为：**
- 产出受影响的渲染代码的迁移脚本或修改
  - 扫描所有 `OnRenderImage` 引用
  - 替换为 `RenderPipelineManager.endCameraRendering` 订阅
  - 包含测试清单：验证场景渲染后表现不退化

### Case 5：上下文传递 — 引擎 API
**输入上下文：** 引擎 = Unity 2023。可用渲染 API：`CommandBuffer`、`RenderPipelineManager`、`ScriptableRenderContext`。
**输入：** "实现一个自定义渲染 pass，在 HDR 颜色校正之前添加一个屏幕空间轮廓效果。"
**预期行为：**
- 使用提供的 API 上下文：
  - 创建 `CommandBuffer` 执行后处理
  - 将 pass 注入到 `RenderPipelineManager.endCameraRendering` 之前的正确位置
  - 不假设 Unity 2023 中不存在的 API
- 产出渲染功能代码

---

## 协议合规性

- [ ] 停留在声明领域内（引擎系统、渲染、低级）
- [ ] 将 gameplay 代码重定向到 gameplay-programmer
- [ ] 使用引擎上下文中的特定 API
- [ ] 为平台约束做优化

---

## 覆盖说明
- Case 3 (Switch draw call) 是可量化测试 — agent 必须从 2000→500 产生具体步骤
- Case 5 要求引擎上下文在运行前可用；是最重要的上下文测试
- 无自动化运行器；手动审查或通过 `/skill-test`
