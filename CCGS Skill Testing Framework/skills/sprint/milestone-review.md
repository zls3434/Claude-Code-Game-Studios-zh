<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/milestone-review

## Skill 摘要

`/milestone-review` 生成对已完成 milestone 的全面审查报告：包括已交付内容、velocity 指标、延期事项、浮现的风险和 retrospective 种子。在 full 模式下，审查文档编译完成后会运行 PR-MILESTONE Director Gate（Producer 审查范围交付情况）。在 lean 和 solo 模式下跳过该 Gate。该 skill 在持久化前会询问 "May I write to `production/milestones/review-milestone-N.md`?"。Verdict：MILESTONE COMPLETE 或 MILESTONE INCOMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含 verdict 关键字：MILESTONE COMPLETE、MILESTONE INCOMPLETE
- [ ] 包含 "May I write" 用语（skill 会写入审查文档）
- [ ] 包含下一步移交指引（审查写入后应做什么）

---

## Director Gate 检查

| Gate ID       | 触发条件                     | 模式限制              |
|---------------|------------------------------|-----------------------|
| PR-MILESTONE  | 审查文档编译完成后           | 仅 full（非 lean/solo） |

---

## 测试用例

### 用例 1：正常路径 — 接近完成的 milestone，有一项延期 story

**Fixture：**
- `production/milestones/milestone-03.md` 存在，包含 8 个 story
- 7 个 story 的 `Status: Complete`
- 1 个 story 的 `Status: Deferred`（延期至 milestone-04）
- `review-mode.txt` 内容为 `full`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. Skill 读取 `milestone-03.md` 及所有引用的 sprint 文件
2. Skill 编译：7 项已交付、1 项延期；velocity；无阻塞项
3. Skill 向用户展示审查草稿
4. 调用 PR-MILESTONE Gate；Producer 批准
5. Skill 询问 "May I write to `production/milestones/review-milestone-03.md`?"
6. 用户批准；文件写入；verdict 为 MILESTONE COMPLETE

**断言：**
- [ ] 审查中注明已延期的 story 及其目标 milestone
- [ ] 尽管有一项延期 story，verdict 仍为 MILESTONE COMPLETE
- [ ] 在 full 模式下，PR-MILESTONE Gate 在草稿编译后调用
- [ ] Skill 在写入审查文件前询问 "May I write"
- [ ] 审查文档路径匹配 `production/milestones/review-milestone-03.md`

---

### 用例 2：受阻 Milestone — 多个 blocked story

**Fixture：**
- `production/milestones/milestone-03.md` 存在，包含 5 个 story
- 2 个 story 的 `Status: Complete`
- 3 个 story 的 `Status: Blocked`（每个 story 中列出了具体阻塞原因）
- `review-mode.txt` 内容为 `full`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. Skill 读取 milestone 和 sprint 文件
2. Skill 发现 3 个 blocked story；编译阻塞详情
3. Verdict 为 MILESTONE INCOMPLETE
4. PR-MILESTONE Gate 运行；Producer 注明未解决的阻塞项
5. 经批准后写入审查文档，包含阻塞列表

**断言：**
- [ ] 当有 story 处于 Blocked 状态时，verdict 为 MILESTONE INCOMPLETE
- [ ] 审查中列出每个 blocked story 的名称和阻塞原因
- [ ] 即使是 INCOMPLETE verdict，在 full 模式下仍调用 PR-MILESTONE Gate
- [ ] "May I write" 提示在文件写入前仍然出现

---

### 用例 3：Full 模式 — PR-MILESTONE 返回 CONCERNS

**Fixture：**
- Milestone-03 有 6 个完成 story，但其中 2 个不在原始范围内（sprint 中期添加）
- `review-mode.txt` 内容为 `full`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. Skill 编译审查；注明 2 个超出原始范围的 story 已交付
2. 调用 PR-MILESTONE Gate；Producer 返回关于范围蔓延的 CONCERNS
3. Skill 向用户展示 CONCERNS，并在审查中追加"范围蔓延"注释
4. 用户批准修订后的审查；文件写入为 MILESTONE COMPLETE（附说明）

**断言：**
- [ ] PR-MILESTONE Gate 的 CONCERNS 在写入前向用户展示
- [ ] 范围蔓延在写入的审查文档中明确注明
- [ ] Verdict 为 MILESTONE COMPLETE（story 已交付）并附带 CONCERNS 注释
- [ ] Skill 不抑制 Gate 反馈

---

### 用例 4：边界情况 — 指定 milestone 对应的文件不存在

**Fixture：**
- 用户调用 `/milestone-review milestone-07`
- `production/milestones/milestone-07.md` 不存在

**输入：** `/milestone-review milestone-07`

**预期行为：**
1. Skill 尝试读取 `production/milestones/milestone-07.md`
2. 文件未找到；skill 输出错误消息
3. Skill 建议检查 `production/milestones/` 中可用的 milestone
4. 不调用任何 Gate；不写入任何文件

**断言：**
- [ ] milestone 文件不存在时 skill 不崩溃
- [ ] 输出在错误消息中注明期望的文件路径
- [ ] 输出建议检查 `production/milestones/` 中的有效 milestone 名称
- [ ] Verdict 为 BLOCKED（无法审查不存在的 milestone）

---

### 用例 5：Lean/Solo 模式 — 跳过 PR-MILESTONE Gate

**Fixture：**
- `production/milestones/milestone-03.md` 存在，包含 5 个完成 story
- `review-mode.txt` 内容为 `solo`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. Skill 读取 review mode — 确定为 `solo`
2. Skill 编译审查草稿
3. 跳过 PR-MILESTONE Gate；输出注明 "[PR-MILESTONE] 已跳过 — Solo 模式"
4. Skill 请求用户直接批准审查
5. 用户批准；审查文件写入；verdict 为 MILESTONE COMPLETE

**断言：**
- [ ] 在 solo（或 lean）模式下不调用 PR-MILESTONE Gate
- [ ] 跳过操作在 skill 输出中明确注明
- [ ] 写入前仍需要用户直接批准
- [ ] 写入成功后 verdict 为 MILESTONE COMPLETE

---

## 协议合规

- [ ] 在调用 PR-MILESTONE 或请求写入前展示编译后的审查草稿
- [ ] 始终在写入审查文档前询问 "May I write"
- [ ] PR-MILESTONE Gate 仅在 full 模式下运行
- [ ] 在 lean 和 solo 输出中显示跳过消息
- [ ] Verdict 明确声明为 MILESTONE COMPLETE 或 MILESTONE INCOMPLETE

---

## 覆盖说明

- milestone 包含零个 story 的场景未测试；该情况遵循 MILESTONE INCOMPLETE 模式，并附注提示该 milestone 可能未曾规划。
- Velocity 计算的具体细节（story points 与 story 数量）在此未验证；属于审查编译阶段的实现细节。
