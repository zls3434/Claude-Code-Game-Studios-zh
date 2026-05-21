<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Unity 6.3 LTS — 破坏性变更

**最后验证时间：** 2026-02-13

本文档追踪 Unity 2022 LTS（模型训练可能覆盖的版本）与 Unity 6.3 LTS（当前版本）之间
的 API 破坏性变更和行为差异。按风险等级组织。

## 高风险 — 会破坏现有代码

### Entities/DOTS API 完全重构
**版本：** Entities 1.0+（Unity 6.0+）

```csharp
// ❌ 旧版（Unity 6 之前，GameObjectEntity 模式）
public class HealthComponent : ComponentData {
    public float Value;
}

// ✅ 新版（Unity 6+，IComponentData）
public struct HealthComponent : IComponentData {
    public float Value;
}

// ❌ 旧版：ComponentSystem
public class DamageSystem : ComponentSystem { }

// ✅ 新版：ISystem（非托管，兼容 Burst）
public partial struct DamageSystem : ISystem {
    public void OnCreate(ref SystemState state) { }
    public void OnUpdate(ref SystemState state) { }
}
```

**迁移方案：** 遵循 Unity 的 ECS 迁移指南。需要进行重大架构变更。

---

### Input System — 旧版 Input 已弃用
**版本：** Unity 6.0+

```csharp
// ❌ 旧版：Input 类（已弃用）
if (Input.GetKeyDown(KeyCode.Space)) { }

// ✅ 新版：Input System 包
using UnityEngine.InputSystem;
if (Keyboard.current.spaceKey.wasPressedThisFrame) { }
```

**迁移方案：** 安装 Input System 包，将所有 `Input.*` 调用替换为新 API。

---

### URP/HDRP Renderer Feature API 变更
**版本：** Unity 6.0+

```csharp
// ❌ 旧版：ScriptableRenderPass.Execute 签名
public override void Execute(ScriptableRenderContext context, ref RenderingData data)

// ✅ 新版：使用 RenderGraph API
public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
```

**迁移方案：** 将自定义渲染 Pass 更新为使用 RenderGraph API。

---

## 中风险 — 行为变更

### Addressables — 资源加载返回值
**版本：** Unity 6.2+

资源加载失败现在默认抛出异常，而非返回 null。
添加适当的异常处理或使用 `TryLoad` 变体。

```csharp
// ❌ 旧版：失败时静默返回 null
var handle = Addressables.LoadAssetAsync<Sprite>("key");
var sprite = handle.Result; // 失败时返回 null

// ✅ 新版：失败时抛出异常，使用 try/catch 或 TryLoad
try {
    var handle = Addressables.LoadAssetAsync<Sprite>("key");
    var sprite = await handle.Task;
} catch (Exception e) {
    Debug.LogError($"加载失败：{e}");
}
```

---

### 物理 — 默认求解器迭代次数已更改
**版本：** Unity 6.0+

为提高稳定性，默认求解器迭代次数已增加。
如依赖旧行为，请检查 `Physics.defaultSolverIterations`。

---

## 低风险 — 弃用（仍可使用）

### UGUI（旧版 UI）
**状态：** 已弃用但仍受支持
**替代方案：** UI Toolkit

UGUI 仍可使用，但新项目推荐使用 UI Toolkit。

---

### 旧版 Particle System
**状态：** 已弃用
**替代方案：** Visual Effect Graph（VFX Graph）

---

### 旧版 Animation System
**状态：** 已弃用
**替代方案：** Animator Controller（Mecanim）

---

## 平台特定的破坏性变更

### WebGL
- **Unity 6.0+**：WebGPU 现为默认方案（支持 WebGL 2.0 回退）
- 更新着色器以确保 WebGPU 兼容性

### Android
- **Unity 6.0+**：最低 API 级别提升至 24（Android 7.0）

### iOS
- **Unity 6.0+**：最低部署目标提升至 iOS 13

---

## 迁移检查清单

从 2022 LTS 升级至 Unity 6.3 LTS 时：

- [ ] 审计所有 DOTS/ECS 代码（可能需要完全重写）
- [ ] 将 `Input` 类替换为 Input System 包
- [ ] 将自定义渲染 Pass 更新为 RenderGraph API
- [ ] 为 Addressables 调用添加异常处理
- [ ] 测试物理行为（求解器迭代次数已更改）
- [ ] 考虑将新 UI 的 UGUI 迁移至 UI Toolkit
- [ ] 更新 WebGL 着色器以支持 WebGPU
- [ ] 验证最低平台版本（Android/iOS）

---

**来源：**
- https://docs.unity3d.com/6000.0/Documentation/Manual/upgrade-guides.html
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/upgrade-guide.html
