<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/brainstorm

## Skill 摘要

`/brainstorm` 引导式游戏概念构思。它展示 2-4 个概念选项及其优缺点，让用户选择并完善一个概念，并生成结构化的 `design/gdd/game-concept.md` 文档。此 skill 是协作式的——它在提出选项之前先提问，并持续迭代直到用户批准概念方向。

在 `full` 审查模式下，概念草案完成后，四个 director gate 并行生成：CD-PILLARS（创意总监）、AD-CONCEPT-VISUAL（美术总监）、TD-FEASIBILITY（技术总监）和 PR-SCOPE（制作人）。在 `lean` 模式下，所有 4 个内联 gate 均被跳过（lean 模式仅运行 PHASE-GATE，而 brainstorm 没有 PHASE-GATE）。在 `solo` 模式下，所有 gate 均被跳过。skill 在写入 `design/gdd/game-concept.md` 之前询问 "May I write"。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：APPROVED、REJECTED、CONCERNS
- [ ] 包含 "May I write" 协作协议语言（用于 game-concept.md）
- [ ] 结尾有下一步交接（`/map-systems`）
- [ ] 记录 full 模式下的 4 个 director gate：CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY、PR-SCOPE
- [ ] 记录 lean 和 solo 模式下所有 4 个 gate 均被跳过

---

## Director Gate 检查

在 `full` 模式下：CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY 和 PR-SCOPE 在用户批准概念草案后并行生成。

在 `lean` 模式下：所有 4 个内联 gate 均被跳过（brainstorm 没有 PHASE-GATE，因此 lean 模式跳过所有内容）。输出中每个均标注为："[GATE-ID] skipped — lean mode"。

在 `solo` 模式下：所有 4 个 gate 均被跳过。输出中每个均标注为："[GATE-ID] skipped — solo mode"。

---

## 测试用例

### 用例 1：Happy Path — Full 模式，3 个概念，用户选择一个，所有 4 个 director 均批准

**Fixture：**
- 不存在 `design/gdd/game-concept.md`
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/brainstorm`

**预期行为：**
1. Skill 询问用户关于类型、范围和目标感受的问题
2. Skill 展示 3 个概念选项，每个附有优缺点
3. 用户选择一个概念
4. Skill 将选定概念细化为结构化草案
5. 所有 4 个 director gate 并行生成：CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY、PR-SCOPE
6. 所有 4 个返回 APPROVED
7. Skill 询问 "May I write `design/gdd/game-concept.md`?"
8. 批准后写入概念

**断言：**
- [ ] 恰好展示 3 个概念选项（非 1 个，非 5+ 个）
- [ ] 所有 4 个 director gate 并行生成（非顺序）
- [ ] 所有 4 个 gate 在 "May I write" 询问之前完成
- [ ] 在写入之前询问 "May I write `design/gdd/game-concept.md`?"
- [ ] 未经用户批准不写入概念文件
- [ ] 存在到 `/map-systems` 的下一步交接

---

### 用例 2：失败路径 — CD-PILLARS 返回 REJECT

**Fixture：**
- 概念草案已完成
- `production/session-state/review-mode.txt` 包含 `full`
- CD-PILLARS gate 返回 REJECT："The concept has no identifiable creative pillar"

**输入：** `/brainstorm`

**预期行为：**
1. CD-PILLARS gate 返回 REJECT 并附具体反馈
2. Skill 将拒绝信息展示给用户
3. 概念不写入文件
4. 询问用户：重新考虑概念方向，或覆盖拒绝
5. 如果重新考虑：skill 返回概念选项阶段

**断言：**
- [ ] CD-PILLARS 返回 REJECT 时不写入概念
- [ ] 拒绝反馈原样展示给用户
- [ ] 用户可选择重新考虑或覆盖
- [ ] 如果用户选择重新考虑，skill 返回概念构思阶段

---

### 用例 3：Lean 模式 — 所有 4 个 gate 跳过；用户确认后写入概念

**Fixture：**
- 不存在游戏概念
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/brainstorm`

**预期行为：**
1. 展示概念选项，用户选择一个
2. 概念细化为结构化草案
3. 所有 4 个 director gate 均被跳过 — 每个均标注："[GATE-ID] skipped — lean mode"
4. Skill 要求用户确认概念已准备好写入
5. 确认后询问 "May I write `design/gdd/game-concept.md`?"
6. 批准后写入概念

**断言：**
- [ ] 所有 4 个 gate 跳过说明均出现："CD-PILLARS skipped — lean mode"、"AD-CONCEPT-VISUAL skipped — lean mode"、"TD-FEASIBILITY skipped — lean mode"、"PR-SCOPE skipped — lean mode"
- [ ] 概念仅在用户确认后写入（lean 模式无需 director 批准）
- [ ] 写入前仍询问 "May I write"

---

### 用例 4：Solo 模式 — 所有 gate 跳过；仅需用户批准即可写入概念

**Fixture：**
- 不存在游戏概念
- `production/session-state/review-mode.txt` 包含 `solo`

**输入：** `/brainstorm`

**预期行为：**
1. 展示概念选项，用户选择一个
2. 概念草案展示给用户
3. 所有 4 个 director gate 均被跳过 — 每个均标注 "solo mode"
4. 询问 "May I write `design/gdd/game-concept.md`?"
5. 用户批准后写入概念

**断言：**
- [ ] 所有 4 个跳过说明以 "solo mode" 标签出现
- [ ] 不生成任何 director agent
- [ ] 仅需用户批准即可写入概念
- [ ] 行为在其他方面与此 skill 的 lean 模式等效

---

### 用例 5：Director Gate — PR-SCOPE 返回 CONCERNS（范围过大）

**Fixture：**
- 概念草案已完成
- `production/session-state/review-mode.txt` 包含 `full`
- PR-SCOPE gate 返回 CONCERNS："The concept scope would require 18+ months for a solo developer"

**输入：** `/brainstorm`

**预期行为：**
1. PR-SCOPE gate 返回 CONCERNS 并附具体范围反馈
2. Skill 将范围顾虑展示给用户
3. 写入前将范围顾虑记录在概念草案中
4. 询问用户：缩小范围、接受顾虑并记录、或重新考虑
5. 如果接受顾虑：概念写入时嵌入 "Scope Risk" 说明

**断言：**
- [ ] PR-SCOPE 顾虑在 "May I write" 询问之前展示给用户
- [ ] Skill 不会在未展示范围顾虑的情况下写入概念
- [ ] 如果用户接受：范围顾虑记录在概念文件中
- [ ] Skill 不会因 PR-SCOPE CONCERNS 自动拒绝概念（由用户决定）

---

## 协议合规性

- [ ] 在用户承诺之前展示 2-4 个概念选项及其优缺点
- [ ] 用户确认概念方向后才调用 director gate
- [ ] Full 模式下所有 4 个 director gate 并行生成
- [ ] Lean 和 solo 模式下所有 4 个 gate 均被跳过 — 每个按名称标注
- [ ] 写入前询问 "May I write `design/gdd/game-concept.md`?"
- [ ] 以下一步交接结束：`/map-systems`

---

## 覆盖说明

- AD-CONCEPT-VISUAL gate（美术总监可行性）与其他 3 个 gate 一起在并行生成中分组 — 不独立 fixture 测试。
- 迭代式概念完善循环（用户拒绝所有选项，skill 生成新选项）不进行 fixture 测试 — 它遵循与选项选择阶段相同的模式。
- game-concept.md 文档结构（必需 section）在 skill 正文中定义，不在测试断言中重新枚举。
