<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：ue-replication-specialist

## Agent 摘要
领域：Actor/Component Replication、RPC（Server/Client/NetMulticast）、属性复制条件、网络相关性、带宽管理、复制图、Client Prediction。
不拥有：GAS prediction（ue-gas-specialist）、服务器基础设施（devops-engineer）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 Replication / RPC / 网络相关性 / 带宽）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对 GAS prediction 或服务器基础设施拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "为多人游戏中开枪的枪设计 replication 策略。"
**预期行为：**
- 生成角色和枪械的 replication 模型：
  - 枪的状态：`UPROPERTY(Replicated)` 用于 `AmmoCount`、`IsReloading`
  - 开枪：`UFUNCTION(Server, Reliable)` — 客户端请求开枪，服务器验证并执行
  - `UFUNCTION(NetMulticast, Reliable)` 用于开枪 VFX/SFX，以便所有客户端观看
- 使用 `COND_SkipOwner` 用于枪口闪光/声音（开枪者本地播放）
- 注明 `DOREPLIFETIME` 宏和 `.generated.h` include 要求

### Case 2：领域外重定向
**输入：** "在 AWS 上设置专用服务器。"
**预期行为：**
- 不生成服务器基础设施代码
- 将请求重定向到 `devops-engineer`
- 可描述连接流程（客户端如何发现并连接到专用服务器），但不构建基础设施

### Case 3：带宽优化 — 条件属性复制
**输入：** "健康条属性在场上所有 100 个敌人上每帧复制。"
**预期行为：**
- 诊断带宽浪费：`Health` 可能用 `COND_None` 复制给所有连接，每帧 tick
- 提供优化：
  - `DOREPLIFETIME_CONDITION(ACharacter, Health, COND_OwnerOnly)` … 等等，不对 — 仅所有者的可能性是错误建议，因为所有客户端都需要敌方生命条用于 UI
  - 正确的优化：`COND_SkipOwner` + 仅在被观察者更改或事件发生时复制，而非每帧
  - 使用 `AActor::SetReplicates(false)` 如果敌方是非复制 AI
- 具体估计带宽节省（100 个演员 × 每演员每次更新 8 字节 × tick 频率）

### Case 4：RPC 可靠性等级 — 错误选择
**输入：** "使用 Unreliable RPC 复制房间中所有物品的位置更新。"
**预期行为：**
- 标记 Unreliable RPC 用于位置更新的问题：
  - Unreliable RPC 可能被丢弃，导致客户端出现不同步的物品
  - 位置更新需要要么可靠（较新数据覆盖旧数据 — `Reliable` 会创建队列），要么通过 Actor replication（属性复制）处理，后者内置优先级/带宽管理
- 提供正确模式：对频繁更新使用带 `COND_SimulatedOnly` 的复制属性，而非 RPC
- 不批准位置更新的 Unreliable RPC — 解释为何它会导致客户端物品状态不可恢复地不同步

### Case 5：上下文传递 — 专用服务器带宽限制
**输入：** 项目上下文：专用服务器，每客户端 10KB/s 带宽上限，每服务器 64 名玩家。请求："为大型玩家大厅设计复制策略。"
**预期行为：**
- 引用 10KB/s 带宽上限和 64 名玩家
- 设计按比例缩放的复制策略：
  - 默认所有 actor `bRelevantForGameplay = false`；仅标记必要的用于复制
  - 使用 `NetUpdateFrequency` 上限（不频繁更新的数据 1-2Hz，关键数据最高 10Hz）
  - 使用 `NetCullDistanceSquared` 和相关性进行空间距离剔除
  - 使用 `Replication Graph`（`UReplicationGraph` 或 `UBasicReplicationGraph`）进行高效的每连接相关性
  - 使用 `FObjectReplicator` 条件属性和自定义 `ShouldReplicateTo()` 进行精细控制
- 估计每连接带宽：按玩家数划分连接的 actor，计算每位玩家预算内是否可行

---

## 协议合规性

- [ ] 停留在声明领域内（Actor/Component Replication、RPC、带宽、相关性）
- [ ] 将服务器基础设施重定向到 devops-engineer
- [ ] 返回结构化复制设计（属性复制、RPC 可靠性、复制条件）
- [ ] 使用正确的 RPC 可靠性 — 对属性更新推荐属性复制而非 RPC
- [ ] 标记 Unreliable RPC 用于有状态数据为危险（不同步风险）
- [ ] 根据提供的数值带宽约束设计复制策略（非泛化建议）
- [ ] 估计带宽消耗并将其与提供的约束进行比较

---

## 覆盖说明
- 枪械复制（Case 1）需要 `tests/unit/` 中的复制单元测试或至少手动多人测试
- 带宽估计（Case 3、Case 5）验证 agent 使用数值推理，而非模糊警告
- Unreliable RPC（Case 4）确认 agent 理解 UE 网络可靠性模型
