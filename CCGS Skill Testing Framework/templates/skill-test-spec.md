<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill Spec：/[skill-name]

> **Category**：[gate | review | authoring | readiness | pipeline | analysis | team | sprint | utility]
> **Priority**：[critical | high | medium | low]
> **Spec 编写日期**：[YYYY-MM-DD]

## Skill 摘要

[一段描述此 skill 做什么、接受什么输入、产出什么输出的文字。]

---

## 静态断言

这些应在任何行为测试之前通过：

- [ ] Frontmatter 包含所有必需字段（`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`）
- [ ] 找到 2 个以上 phase 标题
- [ ] 至少存在一个裁决关键词（`PASS`, `FAIL`, `CONCERNS`, `APPROVED`, `BLOCKED`, `COMPLETE`, `READY`）
- [ ] 如果 `allowed-tools` 包含 Write/Edit：存在`"May I write"`表述
- [ ] 末尾存在下一步交接 section

---

## Director Gate 检查

[描述此 skill 触发哪些 director gate（如有），以及在什么 review mode 条件下触发。]

- **Full mode**：[触发的 gate — 例如 CD-PHASE-GATE, TD-PHASE-GATE, PR-PHASE-GATE, AD-PHASE-GATE]
- **Lean mode**：[仅 phase gate — 例如仅 CD-PHASE-GATE，或无]
- **Solo mode**：[无 gate — skill 在无 director review 的情况下运行]
- **N/A**：[如果此 skill 从不触发 gate，请解释原因]

---

## 测试用例

### Case 1：Happy Path — [简短名称]

**Fixture**（假设的项目状态）：
- [文件/条件 1]
- [文件/条件 2]

**预期行为**：
1. [步骤 1]
2. [步骤 2]
3. [步骤 3]

**断言**：
- [ ] [断言 1]
- [ ] [断言 2]
- [ ] [断言 3]

**Case Verdict**：PASS / FAIL / PARTIAL

---

### Case 2：Failure / Blocked — [简短名称]

**Fixture**：
- [缺失或无效的条件]

**预期行为**：
1. [Skill 检测到问题]
2. [Skill 报告 FAIL/BLOCKED]
3. [Skill 不继续执行]

**断言**：
- [ ] Skill 提前停止且不产出输出
- [ ] 显示正确的 error/block 消息
- [ ] 未经用户批准不写入文件

**Case Verdict**：PASS / FAIL / PARTIAL

---

### Case 3：Mode Variant — [简短名称]

**Fixture**：
- [标准项目状态]
- [设置了特定 mode 或 flag]

**预期行为**：
1. [行为因 mode 不同而与 happy path 不同]

**断言**：
- [ ] [Mode 特定的断言]
- [ ] [输出与 Case 1 正确不同]

**Case Verdict**：PASS / FAIL / PARTIAL

---

### Case 4：Edge Case — [简短名称]

**Fixture**：
- [异常或边界条件]

**预期行为**：
1. [Skill 优雅处理]

**断言**：
- [ ] [Edge case 被处理，无崩溃或静默失败]
- [ ] [正确的输出或消息]

**Case Verdict**：PASS / FAIL / PARTIAL

---

### Case 5：Director Gate — [简短名称]

**Fixture**：
- [触发 gate 检查的项目状态]
- Review mode：[full | lean | solo]

**预期行为**：
1. [Gate 根据 mode 触发 / 不触发]
2. [正确的 director agent 被 spawn 或跳过]

**断言**：
- [ ] 在 full mode 下：[特定 gate 被 spawn]
- [ ] 在 lean mode 下：[仅 phase gate，或跳过]
- [ ] 在 solo mode 下：不 spawn 任何 director gate
- [ ] Skill 不自动推进越过 CONCERNS 或 FAIL 裁决

**Case Verdict**：PASS / FAIL / PARTIAL

---

## 协议合规性

- [ ] 在任何文件写入之前使用`"May I write"`（或为只读类型，跳过此项）
- [ ] 在请求批准之前向用户呈现发现/草稿
- [ ] 以推荐的下一步或后续操作结束
- [ ] 不未经用户批准自动创建文件

---

## 覆盖说明

[任何覆盖缺口、未测试的已知 edge case，或需要
进行 live skill 运行才能验证的条件。]
