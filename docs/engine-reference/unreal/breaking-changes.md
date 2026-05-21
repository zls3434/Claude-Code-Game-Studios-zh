<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Unreal Engine 5.7 — 破坏性变更

**最后验证日期：** 2026-02-13

本文档记录 Unreal Engine 5.3（模型训练数据可能覆盖的版本）与 Unreal Engine 5.7（当前版本）之间的破坏性 API 变更和行为差异。按风险等级组织排列。

## 高风险 — 会破坏现有代码

### Substrate 材质系统（5.7 中生产就绪）
**适用版本：** UE 5.5+（实验性），5.7（生产就绪）

Substrate 以模块化、物理精确的框架替代旧版材质系统。

```cpp
// ❌ 旧版：旧版材质节点（仍可用但已弃用）
// 标准材质图，包含 Base Color、Metallic、Roughness 等

// ✅ 新版：Substrate 材质层
// 使用 Substrate 节点：Substrate Slab、Substrate Blend 等
// 模块化材质创作，具备真正的物理精确性
```

**迁移方式：** 在 `项目设置 > 引擎 > Substrate` 中启用 Substrate，并使用 Substrate 节点重建材质。

---

### PCG（程序化内容生成）API 大修
**适用版本：** UE 5.7（生产就绪）

PCG 框架已达到生产就绪状态，并伴随重大 API 变更。

```cpp
// ❌ 旧版：实验性 PCG API（5.7 之前）
// 旧节点类型，不稳定 API

// ✅ 新版：生产就绪 PCG API（5.7+）
// 使用 FPCGContext、IPCGElement、新节点类型
// 稳定 API，生产就绪工作流
```

**迁移方式：** 遵循 5.7 文档中的 PCG 迁移指南。实验性的 PCG 代码预期需要大量重构。

---

### Megalights 渲染系统
**适用版本：** UE 5.5+

全新光照系统，支持百万级动态光源。

```cpp
// ❌ 旧版：有限的动态光源（集群前向着色）
// 性能下降之前最多约 100-200 个动态光源

// ✅ 新版：Megalights（5.5+）
// 百万级动态光源，性能成本极低
// 启用方式：项目设置 > 引擎 > 渲染 > Megalights
```

**迁移方式：** 无需更改代码，但光照行为可能有所不同。启用后请测试场景。

---

## 中风险 — 行为变更

### Enhanced Input 系统（现为默认）
**适用版本：** UE 5.1+（推荐），5.7（默认）

Enhanced Input 现已成为默认输入系统。

```cpp
// ❌ 旧版：旧版输入绑定（已弃用）
InputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);

// ✅ 新版：Enhanced Input
SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
}
```

**迁移方式：** 用 Enhanced Input 动作替换旧版输入绑定。

---

### Nanite 默认为推荐启用
**适用版本：** UE 5.0+（可选），5.7（推荐）

Nanite 虚拟化几何体现在是静态网格体的推荐工作流。

```cpp
// 在静态网格体上启用 Nanite：
// 静态网格体编辑器 > 详情 > Nanite 设置 > 启用 Nanite 支持
```

**迁移方式：** 将高面数网格体转换为 Nanite。在目标平台上测试性能。

---

## 低风险 — 弃用项（仍可使用）

### 旧版材质系统
**状态：** 已弃用，但仍受支持
**替代方案：** Substrate 材质系统

旧版材质仍然可用，但新项目推荐使用 Substrate。

---

### 旧版 World Partition（UE4 风格）
**状态：** 已弃用
**替代方案：** World Partition（UE5+）

大世界场景请使用 UE5 的 World Partition 系统。

---

## 平台特定的破坏性变更

### Windows
- **UE 5.7**：DirectX 12 现为默认（旧版本为 DX11）
- 为 DX12 兼容性更新着色器

### macOS
- **UE 5.5+**：需要 Metal 3（最低 macOS 13）

### 移动端
- **UE 5.7**：Android 最低 API 级别提升至 26（Android 8.0）
- iOS 最低部署目标提升至 iOS 14

---

## 迁移检查清单

从 UE 5.3 升级到 UE 5.7 时：

- [ ] 审查 Substrate 材质（如准备好迁移至新系统则进行转换）
- [ ] 审计 PCG 使用情况（如使用实验版则更新至生产 API）
- [ ] 测试 Megalights 性能（启用并进行基准测试）
- [ ] 将旧版输入迁移至 Enhanced Input
- [ ] 将高面数网格体转换为 Nanite
- [ ] 为 DX12（Windows）或 Metal 3（macOS）更新着色器
- [ ] 验证最低平台版本（Android 8.0、iOS 14）
- [ ] 在目标硬件上测试 Lumen 和 Nanite 性能

---

**来源：**
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- https://dev.epicgames.com/documentation/en-us/unreal-engine/upgrading-projects-to-newer-versions-of-unreal-engine
