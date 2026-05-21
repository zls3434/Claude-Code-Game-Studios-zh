<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Spec：[agent-name]

> **Tier**：[directors | leads | specialists | godot | unity | unreal | operations | creative]
> **Category**：[director | lead | specialist | engine | operations | creative]
> **Spec 编写日期**：[YYYY-MM-DD]

## Agent 摘要

[一段描述此 agent 的领域、它拥有哪些决策权、以及它转交什么 vs. 直接处理什么。
包含它触发哪些 gate（如有）。]

**领域**：[此 agent 拥有的文件/目录]
**升级到**：[父级 agent — 例如 creative-director 处理设计冲突]
**委托给**：[此 agent 通常 spawn 的子 agent]

---

## 静态断言

- [ ] Agent 文件存在于 `.claude/agents/[name].md`
- [ ] Frontmatter 包含 `name`, `description`, `model`, `tools` 字段
- [ ] 领域明确声明
- [ ] 升级路径已记录
- [ ] 不做出其领域之外的决策

---

## 测试用例

### Case 1：域内请求 — [简短名称]

**Scenario**：一个明确在此 agent 领域内的请求。

**Fixture**：
- [相关项目状态]
- [提供给 agent 的输入]

**预期行为**：
1. Agent 接受请求
2. Agent 产出[特定输出类型]
3. Agent 在写入文件之前询问（如适用）

**断言**：
- [ ] Agent 在其领域内处理请求，无需升级
- [ ] 输出格式匹配预期结构
- [ ] 遵循协作协议（ask → draft → approve）

**Case Verdict**：PASS / FAIL / PARTIAL

---

### Case 2：领域外重定向 — [简短名称]

**Scenario**：一个在此 agent 领域外的请求。

**Fixture**：
- [属于不同 agent 的请求]

**预期行为**：
1. Agent 识别该请求超出其领域
2. Agent 重定向到正确的 agent
3. Agent 不尝试处理它

**断言**：
- [ ] Agent 拒绝并重定向（不静默处理跨领域工作）
- [ ] 重定向中命名了正确的 agent

**Case Verdict**：PASS / FAIL / PARTIAL

---

### Case 3：Gate 裁决 — [简短名称]

**Scenario**：Agent 作为 director gate 检查的一部分被 invoke。

**Fixture**：
- [提交审查的项目状态]
- [gate ID：例如 CD-PHASE-GATE]

**预期行为**：
1. Agent 读取相关文档
2. Agent 产出 PASS / CONCERNS / FAIL 裁决
3. Agent 在 CONCERNS 或 FAIL 上不自动推进

**断言**：
- [ ] 输出中存在裁决关键词（PASS, CONCERNS, FAIL）
- [ ] 为裁决提供了推理说明
- [ ] 在 CONCERNS/FAIL 上：工作被阻止，而非静默继续

**Case Verdict**：PASS / FAIL / PARTIAL

---

### Case 4：冲突升级 — [简短名称]

**Scenario**：此 agent 的领域与另一个 agent 的决策发生冲突。

**Fixture**：
- [来自同一层级两个 agent 的冲突决策]

**预期行为**：
1. Agent 识别冲突
2. Agent 升级到共享父级（或 creative-director / technical-director）
3. Agent 不单方面解决跨领域冲突

**断言**：
- [ ] 冲突被明确浮现
- [ ] 遵循了正确的升级路径
- [ ] 未做出单方面跨领域变更

**Case Verdict**：PASS / FAIL / PARTIAL

---

### Case 5：上下文传递 — [简短名称]

**Scenario**：Agent 收到一个带有来自父 agent 的完整上下文的任务。

**Fixture**：
- [从父级传递的上下文块]
- [要执行的特定子任务]

**预期行为**：
1. Agent 读取并使用提供的上下文
2. Agent 完成子任务
3. Agent 将结果返回给父级（不向用户发出不必要的提示）

**断言**：
- [ ] Agent 使用提供的上下文，而非重新询问
- [ ] 结果限定在子任务范围内，不扩展到其外
- [ ] 输出格式适合父 agent 消费

**Case Verdict**：PASS / FAIL / PARTIAL

---

## 协议合规性

- [ ] 保持在声明领域内 — 不做单方面跨领域变更
- [ ] 将冲突升级到正确的父级
- [ ] 在文件写入之前使用`"May I write"`（或为只读类型）
- [ ] 在请求批准之前呈现发现结果
- [ ] 不跳过委托层级中的层级

---

## 覆盖说明

[任何覆盖缺口、未测试的已知 edge case，或需要
live agent 调用才能验证的行为。]
