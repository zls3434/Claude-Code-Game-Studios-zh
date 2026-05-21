<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Unreal Engine 5.7 — PCG（程序化内容生成）

**最后验证：** 2026-02-13
**状态：** 生产就绪（自 UE 5.7 起）
**插件：** `PCG`（内置，在 Plugins 中启用）

---

## 概述

**程序化内容生成 (PCG)** 是 Unreal 的基于节点的框架，用于大规模生成
程序化内容。它专为在大型开放世界中生成植被、岩石、道具、建筑和其他环境细节而设计。

**适用于 PCG 的场景：**
- 程序化植被放置（树木、草地、岩石）
- 基于生物群落的环境生成
- 道路/路径生成
- 建筑/结构放置
- 世界细节填充（道具、杂物）

**不适合 PCG 的场景：**
- 游戏逻辑（使用 Blueprint/C++）
- 单次手动放置（使用编辑器工具）

**⚠️ 注意：** PCG 在 UE 5.0-5.6 中为实验性，在 UE 5.7 中变为生产就绪。

---

## 核心概念

### 1. **PCG Graph**
- 基于节点的图（类似 Material Editor）
- 定义生成规则

### 2. **PCG Component**
- 放置在关卡中，执行 PCG Graph
- 在定义的体积内生成内容

### 3. **PCG Data**
- 点数据（位置、旋转、缩放）
- 样条线数据（路径、道路、河流）
- 体积数据（密度、生物群落遮罩）

### 4. **Nodes**
- **Samplers**：生成点（Grid、Poisson、Surface）
- **Filters**：根据规则移除点（Density、Tag、Bounds）
- **Modifiers**：变换点（Offset、Rotate、Scale）
- **Spawners**：在点位置实例化网格体/Actor

---

## 设置

### 1. 启用插件

`Edit > Plugins > PCG > Enabled > Restart`

### 2. 创建 PCG Volume

1. Place Actors > Volumes > PCG Volume
2. 将 Volume 缩放至所需的生成区域大小

### 3. 创建 PCG Graph

1. Content Browser > PCG > PCG Graph
2. 打开 PCG Graph Editor

---

## 基础工作流

### 示例：森林生成

#### 1. 创建 PCG Graph

**节点设置：**
```
Input（Volume）
  ↓
Surface Sampler（采样体积表面，points per m²: 0.5）
  ↓
Density Filter（使用纹理遮罩或噪声）
  ↓
Static Mesh Spawner（树木网格体）
  ↓
Output
```

#### 2. 将 Graph 分配给 Volume

1. 选中 PCG Volume
2. Details Panel > PCG Component > Graph = Your PCG Graph
3. 点击 "Generate" 按钮

---

## 关键节点类型

### Samplers（点生成）

#### Grid Sampler
- 规则的网格点
- 配置：
  - **Grid Size**：点之间的距离
  - **Offset**：每点的随机偏移

#### Poisson Disk Sampler
- 带最小距离的随机点
- 配置：
  - **Points Per m²**：密度
  - **Min Distance**：点之间的间距

#### Surface Sampler
- 在网格体表面或地形上采样点
- 配置：
  - **Points Per m²**：密度
  - **Surface Only**：仅表面，非体积

---

### Filters（点移除）

#### Density Filter
- 根据密度值移除点
- 输入：纹理或噪声
- 用于：生物群落遮罩、空地、路径

#### Tag Filter
- 按标签过滤点
- 用于：条件生成

#### Bounds Filter
- 仅保留边界内的点
- 用于：将生成限制在特定区域

---

### Modifiers（点变换）

#### Rotate
- 随机化点的旋转
- 配置：
  - **Min/Max Rotation**：每轴的旋转范围

#### Scale
- 随机化点的缩放
- 配置：
  - **Min/Max Scale**：缩放范围

#### Project to Ground
- 将点捕捉到地形表面

---

### Spawners（网格体/Actor 实例化）

#### Static Mesh Spawner
- 在点位置生成 Static Mesh
- 配置：
  - **Mesh List**：网格体数组（随机选择）
  - **Culling Distance**：LOD/剔除设置

#### Actor Spawner
- 在点位置生成 Blueprint Actor
- 用于：游戏 Actor、交互对象

---

## 数据源

### 地形
- 使用地形作为采样输入
- 自动投影到地形高度

### 样条线
- 沿样条线生成内容（道路、河流、路径）
- 示例：沿路径的树木

### 纹理
- 使用纹理作为密度遮罩
- 绘制生物群落、空地、区域

---

## 生物群落示例（混合森林）

### Graph 设置

```
Input（Landscape）
  ↓
Surface Sampler（density: 1.0）
  ↓
┌─────────────────┬─────────────────┐
│ Tree Biome      │ Rock Biome      │
│ （density > 0.5）│ （density < 0.5）│
├─────────────────┼─────────────────┤
│ Tree Spawner    │ Rock Spawner    │
└─────────────────┴─────────────────┘
  ↓
Merge
  ↓
Output
```

---

## 基于样条线的生成（带树木的道路）

### 1. 创建 PCG Graph

```
Spline Input
  ↓
Spline Sampler（沿样条线采样）
  ↓
Offset（从样条线路径偏移）
  ↓
Tree Spawner
  ↓
Output
```

### 2. 向 PCG Volume 添加 Spline Component

1. PCG Volume > Add Component > Spline
2. 绘制样条线路径
3. PCG Graph 读取样条线数据

---

## 运行时生成

### 从 C++ 触发生成

```cpp
#include "PCGComponent.h"

UPCGComponent* PCGComp = /* 获取 PCG Component */;
PCGComp->Generate(); // 执行 PCG Graph
```

### 流式生成（大型世界）

- PCG 自动随 World Partition 进行流式处理
- 仅在已加载的单元格中生成内容

---

## 性能

### 优化建议

- 在生成的网格体上使用 **culling distance**（LOD）
- 限制 **density**（点数越少 = 性能越好）
- 对重复的网格体使用 **Hierarchical Instanced Static Meshes (HISM)**
- 对大型世界启用 **streaming**

### 调试性能

```cpp
// Console commands:
// pcg.graph.debug 1 - 显示 PCG 调试信息
// stat pcg - 显示 PCG 性能统计
```

---

## 常见模式

### 带空地的森林

```
Surface Sampler
  ↓
Density Filter（带空地的噪声纹理）
  ↓
Tree Spawner（松树、橡树、桦树）
```

---

### 陡坡上的岩石

```
Landscape Input
  ↓
Surface Sampler
  ↓
Slope Filter（angle > 30°）
  ↓
Rock Spawner
```

---

### 沿道路的道具

```
Spline Input（道路样条线）
  ↓
Spline Sampler
  ↓
Offset（道路侧面）
  ↓
Street Light Spawner
```

---

## 调试

### PCG 调试可视化

```cpp
// Console commands:
// pcg.debug.display 1 - 显示点和生成边界
// pcg.debug.colormode points - 对点进行颜色编码
```

### Graph 调试

- PCG Graph Editor > Debug > Show Debug Points
- 在图中的每个节点处可视化点

---

## 从 UE 5.6（实验性）迁移到 5.7（生产就绪）

### API 变更

```cpp
// ❌ 旧版（5.6 实验性 API）：
// 部分节点更名，API 不稳定

// ✅ 新版（5.7 生产就绪 API）：
// 稳定的节点类型，文档化的 API
```

**迁移：** 使用稳定的 5.7 节点重建 PCG Graph。充分测试。

---

## 限制

- **不适用于游戏逻辑**：游戏规则请使用 Blueprint/C++
- **大型 Graph 可能变慢**：通过过滤器和密度降低进行优化
- **运行时生成开销**：尽可能预生成

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/procedural-content-generation-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/pcg-quick-start-in-unreal-engine/
- UE 5.7 Release Notes（PCG 生产就绪公告）
