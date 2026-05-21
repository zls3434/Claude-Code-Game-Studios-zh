<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/sprint-status

## Skill 摘要

`/sprint-status` 是一个 Haiku 级别的只读 skill，读取当前活跃 sprint 文件和会话状态，生成简洁的 sprint 健康摘要。它按状态（Complete / In Progress / Blocked / Not Started）报告 story 计数，并发出三种 sprint 健康 verdict 之一：ON TRACK、AT RISK 或 BLOCKED。该 skill 永不写入文件，也不调用任何 Director Gate。它专为会话期间快速、低成本的 status 检查而设计。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题或编号检查分组
- [ ] 包含 verdict 关键字：ON TRACK、AT RISK、BLOCKED
- [ ] 不要求 "May I write" 用语（只读 skill）
- [ ] 包含下一步移交指引（根据 verdict 应采取的行动）

---

## Director Gate 检查

无。`/sprint-status` 是只读报告 skill；不调用任何 Gate。

---

## 测试用例

### 用例 1：正常路径 — 混合 sprint，AT RISK 且附带具体阻塞项名称

**Fixture：**
- `production/sprints/sprint-004.md` 存在（活跃 sprint，在 `active.md` 中链接）
- Sprint 包含 6 个 story：
  - 3 个 `Status: Complete`
  - 2 个 `Status: In Progress`
  - 1 个 `Status: Blocked`（阻塞原因："等待力学 ADR 通过"）
- Sprint 截止日期还有 2 天

**输入：** `/sprint-status`

**预期行为：**
1. Skill 读取 `production/session-state/active.md` 以找到活跃 sprint 引用
2. Skill 读取 `production/sprints/sprint-004.md`
3. Skill 按状态统计 story：3 Complete、2 In Progress、1 Blocked
4. Skill 检测到 Blocked story 以及即将到来的截止日期
5. Skill 输出 AT RISK verdict，并明确列出阻塞项名称

**断言：**
- [ ] 输出包含按状态统计的 story 计数明细
- [ ] 输出列出具体被阻塞的 story 名称及阻塞原因
- [ ] 当有 story 处于 Blocked 状态时，verdict 为 AT RISK（非 BLOCKED，非 ON TRACK）
- [ ] Skill 不写入任何文件

---

### 用例 2：所有 Story 均完成 — Sprint COMPLETE verdict

**Fixture：**
- `production/sprints/sprint-004.md` 存在
- 全部 5 个 story 均为 `Status: Complete`

**输入：** `/sprint-status`

**预期行为：**
1. Skill 读取 sprint 文件 — 所有 story 均为 Complete
2. Skill 输出 ON TRACK verdict 或 SPRINT COMPLETE 标签
3. Skill 建议下一步运行 `/milestone-review` 或 `/sprint-plan`

**断言：**
- [ ] 全部 story 完成时，verdict 为 ON TRACK 或 SPRINT COMPLETE
- [ ] 输出注明 sprint 已全部完成
- [ ] 下一步建议引用 `/milestone-review` 或 `/sprint-plan`
- [ ] 不写入任何文件

---

### 用例 3：无活跃 Sprint 文件 — 引导运行 /sprint-plan

**Fixture：**
- `production/session-state/active.md` 未引用活跃 sprint
- `production/sprints/` 目录为空或不存在

**输入：** `/sprint-status`

**预期行为：**
1. Skill 读取 `active.md` — 未发现活跃 sprint 引用
2. Skill 检查 `production/sprints/` — 未发现文件
3. Skill 输出信息性消息：未检测到活跃 sprint
4. Skill 建议运行 `/sprint-plan` 创建 sprint

**断言：**
- [ ] 不存在 sprint 文件时 skill 不出错或崩溃
- [ ] 输出明确说明未找到活跃 sprint
- [ ] 输出推荐 `/sprint-plan` 作为下一步行动
- [ ] 不发出任何 verdict 关键字（无可评估的 sprint）

---

### 用例 4：边界情况 — 过期的 In Progress Story（标记）

**Fixture：**
- `production/sprints/sprint-004.md` 存在
- 一个 story 状态为 `Status: In Progress`，在 `active.md` 中有一条注释：
  `上次更新：2026-03-30`（距今天会话日期超过 2 天）
- 无 Blocked story

**输入：** `/sprint-status`

**预期行为：**
1. Skill 读取 sprint 文件和会话状态
2. Skill 检测到该 story 已处于 In Progress 超过 2 天未更新
3. Skill 在输出中将该 story 标记为"过期"
4. Verdict 为 AT RISK（过期的进行中 story 表明存在隐藏阻塞项）

**断言：**
- [ ] Skill 将 story 的"上次更新"元数据与会话日期进行比较
- [ ] 过期的 In Progress story 在输出中按名称标记
- [ ] 检测到过期 story 时，verdict 为 AT RISK，非 ON TRACK
- [ ] 输出不将"过期"与"Blocked"混淆 — 标签区分明确

---

### 用例 5：Gate 合规 — 只读；不调用任何 Gate

**Fixture：**
- `production/sprints/sprint-004.md` 存在，包含 4 个 story（2 Complete、2 In Progress）
- `production/session-state/review-mode.txt` 内容为 `full`

**输入：** `/sprint-status`

**预期行为：**
1. Skill 读取 sprint 并生成状态摘要
2. Skill 无论 review mode 如何均不调用任何 Director Gate
3. 输出为纯状态报告，包含 ON TRACK、AT RISK 或 BLOCKED verdict
4. Skill 不提示用户批准，也不请求写入任何文件

**断言：**
- [ ] 在任何 review mode 下均不调用任何 Director Gate
- [ ] 输出不包含任何 "May I write" 提示
- [ ] Skill 在不需用户交互的情况下完成并返回 verdict
- [ ] 此 skill 忽略（或确认不相关）review mode 文件

---

## 协议合规

- [ ] 不使用 Write 或 Edit 工具（只读 skill）
- [ ] 在发出 verdict 之前展示 story 计数明细
- [ ] 不请求批准
- [ ] 以基于 verdict 的推荐下一步行动结尾
- [ ] 在 Haiku 模型级别运行（快速、低成本）

---

## 覆盖说明

- 同时存在多个活跃 sprint 的场景未测试；skill 读取 `active.md` 所引用的任何 sprint。
- Sprint 部分完成百分比未被显式验证；按状态计数输出已隐含该信息。
- `solo` 模式下的 review-mode 变体不单独测试；用例 5 中的 Gate 行为同样适用于所有模式。
