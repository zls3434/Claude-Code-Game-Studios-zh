<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：ue-gas-specialist

## Agent 摘要
领域：Gameplay Ability System（GAS）— `UAbilitySystemComponent`、Gameplay Abilities、Gameplay Effects、Gameplay Tags、Attribute Sets、Gameplay Cues、Prediction。
不拥有：非 GAS gameplay 逻辑（gameplay-programmer）、UI 系统（ue-umg-specialist）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 GAS / Ability System / Gameplay Effects / Tags）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对非 GAS gameplay 或 UI 系统拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "使用 GAS 实现冲刺能力。"
**预期行为：**
- 生成：
  - 从 `UGameplayAbility`（非 `UAbilitySystemComponent` 方法）继承的 `UDashAbility` C++ 类
  - 带有 `FGameplayTag` 的 `AbilityTag` 用于识别
  - 带有 `FGameplayTagContainer` 的 `CancelAbilitiesWithTag` 用于冲突解决
  - `ActivateAbility()` 实现：应用移动 gameplay effect、播放冲刺 montage、在完成的委托上 `EndAbility()`
- 使用 `UGameplayEffect` 修改 `MovementSpeed` attribute，而非原始修改
- 注明 `Cooldown` 标签和效果，而非手动定时器

### Case 2：领域外重定向
**输入：** "为冲刺能力 UI 冷却计时器创建 UMG 控件。"
**预期行为：**
- 不生成 UMG 控件实现代码
- 明确声明 UI 实现属于 `ue-umg-specialist`
- 将请求重定向到 `ue-umg-specialist`
- 可描述 GAS 如何通过 `FGameplayAbilitySpec.CooldownTags` 或 `UAbilitySystemComponent::GetCooldownRemainingForTag()` 暴露所需数据以驱动 UI

### Case 3：Prediction 和滚动回退
**输入：** "冲刺能力应在客户端即时激活，且服务器应稍后纠正。"
**预期行为：**
- 在 `UDashAbility` C++ 中启用 `InstancingPolicy = EGameplayAbilityInstancingPolicy::InstancedPerActor` 并添加 prediction
- 生成正确的滚动回退模式：
  - 在 `ActivateAbility()` 中调用 `CommitAbility()` — 不跳过
  - 通过 `APawn::GetReplicatedMovementMode()` 或手动 prediction 处理移动 replication
  - 对预测效果使用 `ScopedPredictionWindow`
- 标记 common pitfall：不能纯在 Blueprint 中做客户端预测 — 需要 C++ `CommitAbility()` 调用
- 使用 `AddGameplayCue` 在 correct prediction 后触发 VFX，而非在 activate

### Case 4：Attribute 修改器溢出 — Gameplay Effect 堆叠
**输入：** "攻击速度属性不断攀升，无上限，使角色攻击速度快得不合理。"
**预期行为：**
- 诊断原因：Gameplay Effects 修改攻击速度而没有 `MMC`（Modifier Magnitude Calculation）上限或 `GE` 堆叠限制
- 添加阻挡性的 `Attribute Based` magnitude calculation with ceiling 来禁止超出上限
- 或者应用带有 `StackingType = AggregateByTarget` 和/或 `StackLimitCount` 限制栈数的 GE
- 不改变 gameplay 平衡 — 仅添加属性约束

### Case 5：上下文传递 — 网络模型
**输入：** 项目上下文：Listen Server 模型（无专用服务端），最多 4 名玩家。请求："为此合作 PvE 游戏设计能力 prediction 策略。"
**预期行为：**
- 考虑 Listen Server 模型：主机具有权威性；客户端 prediction 仍然需要但延迟配置文件不同
- 设计 prediction 策略：
  - 对移动能力使用 `LocalPredicted`（客户端即时，服务器稍后验证）
  - 对伤害能力使用 `ServerInitiated`（仅服务器授权伤害，客户端获得 prediction 密钥进行预播放）
- 注明 Listen Server 特定问题：主机 0 延迟，但客户端 1-3 仍需要 prediction；主机可以作为不预测的执行
- 显式引用提供的项目模型（Listen Server / 4 名玩家 / PvE）

---

## 协议合规性

- [ ] 停留在声明领域内（GAS — Abilities、Effects、Tags、Cues、Prediction）
- [ ] 将非 GAS gameplay 重定向到 gameplay-programmer
- [ ] 将 UI 实现重定向到 ue-umg-specialist
- [ ] 返回结构化输出（.h 和 .cpp 类定义，带有正确的 GAS 模式）
- [ ] 为客户端 prediction 要求使用 `CommitAbility()` + `ScopedPredictionWindow`
- [ ] 将无限属性修改器 stack 标记为需要上限或 stack 限制
- [ ] 使 prediction 策略适应提供的网络模型（Dedicated vs. Listen Server）

---

## 覆盖说明
- 冲刺能力（Case 1）需要 `production/qa/evidence/` 中的测试验证（关卡中播放测试验证冲刺）
- 滚动回退（Case 3）可能需要视觉证据或客户端-服务器行为验证的确定性重放
- 属性溢出（Case 4）验证 agent 识别 GAS 特定的修改器堆叠问题
