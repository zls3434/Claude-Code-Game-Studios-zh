<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/retrospective

## Skill 摘要

`/retrospective` 生成一份结构化的 sprint 或 milestone retrospective（回顾），涵盖三大分类：进展顺利的事项、不顺利的事项以及行动事项。它通过读取 sprint 文件和会话日志来编译观察结果，然后生成 retrospective 文档。不使用任何 Director Gate — retrospective 是团队自我反思的产出物。该 skill 在持久化前会询问 "May I write to `production/retrospectives/retro-sprint-NNN.md`?"。Verdict 始终为 COMPLETE（retrospective 是结构化输出，并非通过/不通过的评估）。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含 verdict 关键字：COMPLETE
- [ ] 包含 "May I write" 用语（skill 会写入 retrospective 文档）
- [ ] 包含下一步移交指引（retrospective 写入后应做什么）

---

## Director Gate 检查

无。Retrospective 是团队自我反思文档，不调用任何 Gate。

---

## 测试用例

### 用例 1：正常路径 — 包含混合结果的 Sprint

**Fixture：**
- `production/sprints/sprint-005.md` 存在，包含 6 个 story（4 Complete、1 Blocked、1 Deferred）
- `production/session-logs/` 包含该 sprint 期间的日志条目
- 不存在 sprint-005 的先前 retrospective

**输入：** `/retrospective sprint-005`

**预期行为：**
1. Skill 读取 sprint-005 和会话日志
2. Skill 编译三个 retrospective 分类：进展顺利（4 个 story 已交付）、
   不顺利（1 个 blocked、1 个 deferred）以及行动事项（解决阻塞根因）
3. Skill 向用户展示 retrospective 草稿
4. Skill 询问 "May I write to `production/retrospectives/retro-sprint-005.md`?"
5. 用户批准；文件写入；verdict 为 COMPLETE

**断言：**
- [ ] retrospective 包含全部三个分类（进展顺利 / 不顺利 / 行动事项）
- [ ] Blocked 和 deferred story 出现在"不顺利"分类中
- [ ] 从 blocked story 中至少生成一项行动事项
- [ ] Skill 在写入文件前询问 "May I write"
- [ ] 写入成功后 verdict 为 COMPLETE

---

### 用例 2：无 Sprint 数据 — 手动输入回退

**Fixture：**
- 用户调用 `/retrospective sprint-009`
- `production/sprints/sprint-009.md` 不存在
- 没有引用 sprint-009 的会话日志

**输入：** `/retrospective sprint-009`

**预期行为：**
1. Skill 尝试读取 sprint-009 — 未找到
2. Skill 告知用户未找到 sprint-009 的数据
3. Skill 提示用户手动输入 retrospective 内容（进展顺利、不顺利、行动事项）
4. 用户提供输入；skill 将其格式化为 retrospective 结构
5. Skill 询问 "May I write" 并在批准后写入文档

**断言：**
- [ ] sprint 文件不存在时 skill 不崩溃或生成空文档
- [ ] 提示用户提供手动输入
- [ ] 手动输入被格式化为三个分类结构
- [ ] "May I write" 提示在文件写入前仍然出现

---

### 用例 3：先前 Retrospective 已存在 — 提供追加或替换选项

**Fixture：**
- `production/retrospectives/retro-sprint-005.md` 已存在并包含内容
- 用户在变更后重新运行 `/retrospective sprint-005`

**输入：** `/retrospective sprint-005`

**预期行为：**
1. Skill 检测到 `retro-sprint-005.md` 已存在
2. Skill 向用户展示选择：追加新观察内容或替换已有文件
3. 用户选择"替换"；skill 编译全新的 retrospective
4. Skill 询问 "May I write to `production/retrospectives/retro-sprint-005.md`?"（确认覆盖操作）
5. 文件被覆盖；verdict 为 COMPLETE

**断言：**
- [ ] Skill 在编译前检查已有 retrospective 文件是否存在
- [ ] 向用户提供追加或替换选择 — 而非静默覆盖
- [ ] "May I write" 提示反映覆盖场景
- [ ] 无论追加还是替换，写入后 verdict 为 COMPLETE

---

### 用例 4：边界情况 — 上一 retrospective 中的未解决行动事项

**Fixture：**
- `production/retrospectives/retro-sprint-004.md` 存在，包含 2 个标记为 `[ ]`（未完成）的行动事项
- 用户运行 `/retrospective sprint-005`

**输入：** `/retrospective sprint-005`

**预期行为：**
1. Skill 读取最近一次的先前 retrospective（retro-sprint-004）
2. Skill 检测到来自 sprint-004 的 2 个未勾选行动事项
3. Skill 在新的 retrospective 中包含"Sprint 004 遗留事项"分组
4. 未解决的事项列出并注明未曾跟进

**断言：**
- [ ] Skill 读取最近一次先前 retrospective 以检查开放的行动事项
- [ ] 未解决的行动事项以遗留分组的形态出现在新 retrospective 中
- [ ] 遗留事项与新生成的行动事项区分开
- [ ] 输出注明这些事项在上一个 sprint 中未被跟进

---

### 用例 5：Gate 合规 — 任何模式下均不调用 Gate

**Fixture：**
- `production/sprints/sprint-005.md` 存在，包含完成的 story
- `production/session-state/review-mode.txt` 内容为 `full`

**输入：** `/retrospective sprint-005`

**预期行为：**
1. Skill 在 full 模式下编译 retrospective
2. 不调用任何 Director Gate（retrospective 是团队自我反思，非交付关卡）
3. Skill 请求用户批准并在确认后写入文件
4. Verdict 为 COMPLETE

**断言：**
- [ ] 无论 review mode 如何，均不调用任何 Director Gate
- [ ] 输出不包含任何 Gate 调用或 Gate 结果标记
- [ ] Skill 直接从编译进入到 "May I write" 提示
- [ ] Review mode 文件内容与此 skill 行为无关

---

## 协议合规

- [ ] 始终在请求写入前展示 retrospective 草稿
- [ ] 始终在写入 retrospective 文件前询问 "May I write"
- [ ] 不调用任何 Director Gate
- [ ] Verdict 始终为 COMPLETE（非通过/不通过类型的 skill）
- [ ] 检查先前 retrospective 中的未解决行动事项

---

## 覆盖说明

- Milestone retrospective（相对于 sprint retrospective）遵循相同模式，但读取 milestone 文件而非 sprint 文件；此处不单独测试。
- 会话日志为空的场景类似用例 2（无数据）；两种情况下 skill 均回退至手动输入。
