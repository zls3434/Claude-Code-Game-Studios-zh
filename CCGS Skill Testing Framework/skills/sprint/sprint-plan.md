<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/sprint-plan

## Skill 摘要

`/sprint-plan` 读取当前 milestone 文件和 backlog story，然后按实现层级和优先级分数排序，生成一个新的编号 sprint。在 full 模式下，sprint 草稿编译完成后会运行 PR-SPRINT Director Gate（Producer 审查计划）。在 lean 和 solo 模式下跳过该 Gate。该 skill 在持久化前会询问 "May I write to `production/sprints/sprint-NNN.md`?"。Verdict：COMPLETE（sprint 已生成并写入）或 BLOCKED（因缺少数据或 Gate 失败而无法继续）。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含 verdict 关键字：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 用语（skill 会写入 sprint 文件）
- [ ] 包含下一步移交指引（sprint 写入后应做什么）

---

## Director Gate 检查

| Gate ID   | 触发条件               | 模式限制         |
|-----------|------------------------|------------------|
| PR-SPRINT | sprint 草稿构建完成后  | 仅 full（非 lean/solo） |

---

## 测试用例

### 用例 1：正常路径 — 包含 story 的 Backlog 生成 sprint

**Fixture：**
- `production/milestones/milestone-02.md` 存在，capacity 为 `10 story points`
- Backlog 包含 5 个未开始的 story，跨越 2 个 epic，优先级混合
- `production/session-state/review-mode.txt` 内容为 `full`
- 下一个 sprint 编号为 `003`（sprint 001 和 002 已存在）

**输入：** `/sprint-plan`

**预期行为：**
1. Skill 读取当前 milestone 以获取 capacity 和目标
2. Skill 从 backlog 中读取所有未开始的 story；按层级 + 优先级排序
3. Skill 草拟 sprint-003，story 适配在 capacity 范围内
4. Skill 在调用 Gate 之前向用户展示草稿
5. Skill 调用 PR-SPRINT Gate（full 模式）；Producer 批准
6. Skill 询问 "May I write to `production/sprints/sprint-003.md`?"
7. 用户批准；文件写入

**断言：**
- [ ] Story 在优先级之前按实现层级排序
- [ ] Sprint 草稿在任何写入或 Gate 调用之前展示
- [ ] 在 full 模式下，草稿就绪后调用 PR-SPRINT Gate
- [ ] Skill 在写入 sprint 文件前询问 "May I write"
- [ ] 写入文件路径匹配 `production/sprints/sprint-003.md`
- [ ] 写入成功后 verdict 为 COMPLETE

---

### 用例 2：受阻路径 — Backlog 为空

**Fixture：**
- `production/milestones/milestone-02.md` 存在
- 任何 epic backlog 中均无未开始的 story

**输入：** `/sprint-plan`

**预期行为：**
1. Skill 读取 backlog — 未发现未开始的 story
2. Skill 输出 "Backlog 中无未开始的 story"
3. Skill 建议运行 `/create-stories` 来填充 backlog
4. 不调用任何 Gate；不写入任何文件

**断言：**
- [ ] Verdict 为 BLOCKED
- [ ] 输出包含 "无未开始的 story" 或等效消息
- [ ] 输出推荐 `/create-stories`
- [ ] 不调用 PR-SPRINT Gate
- [ ] 不调用任何写入工具

---

### 用例 3：Gate 返回 CONCERNS — Sprint 超载，写入前修订

**Fixture：**
- Backlog 有 8 个 story，合计 16 points；milestone capacity 为 10 points
- `review-mode.txt` 内容为 `full`

**输入：** `/sprint-plan`

**预期行为：**
1. Skill 草拟 sprint，包含全部 8 个 story（超出 capacity）
2. PR-SPRINT Gate 运行；Producer 返回 CONCERNS：sprint 超载
3. Skill 向用户展示关切事项，询问应延期哪些 story
4. 用户选择延期 3 个 story；sprint 修订为 5 story / 10 points
5. Skill 询问 "May I write" 并写入修订后的 sprint；批准后写入

**断言：**
- [ ] PR-SPRINT Gate 的 CONCERNS 在任何写入前向用户展示
- [ ] Skill 允许根据 Gate 反馈修订 sprint
- [ ] 写入文件的是修订后的 sprint（非原始版本）
- [ ] 修订并写入后 verdict 为 COMPLETE

---

### 用例 4：Lean 模式 — 跳过 PR-SPRINT Gate

**Fixture：**
- Backlog 有 4 个 story；milestone capacity 为 8 points
- `review-mode.txt` 内容为 `lean`

**输入：** `/sprint-plan`

**预期行为：**
1. Skill 读取 review mode — 确定为 `lean`
2. Skill 草拟 sprint 并向用户展示
3. 跳过 PR-SPRINT Gate；输出注明 "[PR-SPRINT] 已跳过 — Lean 模式"
4. Skill 请求用户直接批准 sprint
5. 用户批准；sprint 文件写入

**断言：**
- [ ] 在 lean 模式下不调用 PR-SPRINT Gate
- [ ] 跳过操作在输出中明确注明
- [ ] 写入前仍需要用户批准（Gate 跳过 ≠ 批准跳过）
- [ ] 写入后 verdict 为 COMPLETE

---

### 用例 5：边界情况 — 上一 sprint 仍有开放 story

**Fixture：**
- `production/sprints/sprint-002.md` 存在，包含 2 个状态为 `Status: In Progress` 的 story
- Backlog 有 5 个新的未开始 story
- `review-mode.txt` 内容为 `full`

**输入：** `/sprint-plan`

**预期行为：**
1. Skill 读取 sprint-002，检测到 2 个开放（进行中）story
2. Skill 标记："Sprint 002 有 2 个开放 story — 在规划 sprint 003 前确认是否结转"
3. Skill 向用户展示选择：结转 story、延期或取消
4. 用户确认结转；结转的 story 以 `[CARRY]` 标签置入新 sprint
5. Sprint 草稿构建完成；PR-SPRINT Gate 运行；sprint 经批准后写入

**断言：**
- [ ] Skill 检查最近 sprint 文件中是否有开放 story
- [ ] 在 sprint 规划继续之前，询问用户确认结转
- [ ] 结转的 story 以区分标签出现在新 sprint 草稿中
- [ ] Skill 不会静默忽略上一 sprint 中的开放 story

---

## 协议合规

- [ ] 在调用 PR-SPRINT Gate 或请求写入前展示 sprint 草稿
- [ ] 始终在写入 sprint 文件前询问 "May I write"
- [ ] PR-SPRINT Gate 仅在 full 模式下运行
- [ ] 在 lean 和 solo 模式输出中显示跳过消息
- [ ] Verdict 在 skill 输出末尾明确声明

---

## 覆盖说明

- 不存在 milestone 文件的场景未显式测试；行为遵循 BLOCKED 模式，并建议运行 `/gate-check` 推进 milestone。
- Solo 模式行为等同于 lean（跳过 Gate，需要用户批准），不单独测试。
- 并行的 story 选择算法此处不测试；那些是 sprint-plan 子 agent 的单元关注点。
