<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：unity-dots-specialist

## Agent 摘要
领域：ECS 架构（IComponentData、ISystem、SystemAPI）、Jobs system（IJob、IJobEntity、Burst）、Burst 编译器约束、DOTS gameplay 系统、混合渲染器。
不拥有：MonoBehaviour gameplay 代码（gameplay-programmer）、UI 实现（unity-ui-specialist）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 ECS / Jobs / Burst / IComponentData）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对 MonoBehaviour gameplay 或 UI 系统拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "将玩家移动系统转换为 ECS。"
**预期行为：**
- 生成：
  - `PlayerMovementData : IComponentData` 结构体，包含速度、速度和输入向量字段
  - `PlayerMovementSystem : ISystem`，其 `OnUpdate()` 使用 `SystemAPI.Query<>` 或 `IJobEntity`
  - 通过 `IBaker` 从 authoring MonoBehaviour 烘焙玩家初始状态
- 使用 `RefRW<LocalTransform>` 进行位置更新（非已弃用的 `Translation`）
- 将 job 标记为 `[BurstCompile]`，并注明必须为 unmanaged 才能与 Burst 兼容
- 不修改输入轮询系统 — 从现有的 `PlayerInputData` 组件读取

### Case 2：MonoBehaviour 抵制
**输入：** "直接用 MonoBehaviour 做玩家移动 — 更简单。"
**预期行为：**
- 承认简单性论点
- 解释 DOTS 权衡：更多前期设置，但 ECS/Burst 方法提供了项目 ADR 或需求中记录的性能特性
- 如果项目已承诺使用 DOTS，则不实现 MonoBehaviour 版本
- 如果没有承诺，将架构决策标记给 `lead-programmer` / `technical-director` 解决
- 不单方面做出 MonoBehaviour 与 DOTS 的决策

### Case 3：Burst 不兼容的托管内存
**输入：** "此 Burst job 访问 `List<EnemyData>` 以查找最近的敌人。"
**预期行为：**
- 标记 `List<T>` 是与 Burst 编译不兼容的托管类型
- 不批准带有托管内存访问的 Burst job
- 提供正确的替换：`NativeArray<EnemyData>`、`NativeList<EnemyData>` 或 `NativeHashMap<>`（视用例而定）
- 注明 `NativeArray` 必须显式释放或通过 `[DeallocateOnJobCompletion]` 释放
- 使用 unmanaged 原生容器生成修正后的 job

### Case 4：混合访问 — DOTS 系统需要 MonoBehaviour 数据
**输入：** "DOTS 移动系统需要读取由 MonoBehaviour CameraController 管理的摄像机变换。"
**预期行为：**
- 识别这是一个混合访问场景
- 提供正确的混合模式：将摄像机变换存储在单例 `IComponentData` 中（每帧从 MonoBehaviour 侧通过 `EntityManager.SetComponentData` 更新）
- 或者建议 `CompanionComponent` / 托管组件方法
- 不从 Burst job 内部访问 MonoBehaviour — 标记为不安全
- 在两侧提供桥接代码：MonoBehaviour 侧（写入 ECS）和 DOTS 系统侧（从 ECS 读取）

### Case 5：上下文传递 — 性能目标
**输入：** 来自上下文的 Technical preferences：60fps 目标，每帧最大 2ms CPU 脚本预算。请求："设计 10,000 个敌人实体的 ECS chunk 布局。"
**预期行为：**
- 在设计原理中明确引用 2ms CPU 预算
- 针对缓存效率设计 `IComponentData` chunk 布局：
  - 将频繁一同查询的组件分组在同一 archetype 中
  - 将很少使用的数据分离到单独组件中，保持热数据紧凑
  - 对照 2ms 预算估计实体迭代时间
- 提供内存布局分析（每个实体字节数、每个 chunk 在 16KB chunk 大小下的实体数）
- 不设计明显超出所述 2ms 预算而不标记的布局

---

## 协议合规性

- [ ] 停留在声明领域内（ECS、Jobs、Burst、DOTS gameplay 系统）
- [ ] 将纯 MonoBehaviour gameplay 重定向到 gameplay-programmer
- [ ] 返回结构化输出（IComponentData 结构体、ISystem 实现、IBaker authoring 类）
- [ ] 标记 Burst job 中的托管内存访问为编译错误并提供 unmanaged 替代方案
- [ ] 在 DOTS 系统需要与 MonoBehaviour 系统交互时提供混合访问模式
- [ ] 根据提供的性能预算设计 chunk 布局

---

## 覆盖说明
- ECS 转换（Case 1）必须包含使用 ECS 测试框架（`World`、`EntityManager`）的单元测试
- Burst 不兼容（Case 3）为安全关键 — agent 必须在代码编写之前捕获此问题
- Chunk 布局（Case 5）验证 agent 将定量性能推理应用于架构决策
