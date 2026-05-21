<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/story-done

## Skill 概要

`/story-done` 在设计实现之间建立闭环。在实现一个 story 的末尾运行，它读取 story 文件并逐条验证每个验收标准是否符合实现。它检查 GDD 和 ADR 偏差，提示进行代码评审，将 story 状态更新为 `Complete`，记录所有技术债，并展示 sprint 中下一条就绪的 story。它生成 COMPLETE / COMPLETE WITH NOTES / BLOCKED 判定，并将结果写入 story 文件，可选写入 `docs/tech-debt-register.md`。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥5 个阶段标题（复杂 skill，若适用则需 `context: fork`）
- [ ] 包含判定关键词：COMPLETE、BLOCKED
- [ ] 包含"我可以写入"协作协议用语（需写入 story 文件和技术债登记表）
- [ ] 有下一步交接（展示 sprint 中下一条 story）

---

## 测试用例

### 用例1：Happy Path — 所有验收标准均已满足，无偏差

**Fixture：**
- Story 文件位于 `production/epics/core/story-light-pickup.md`，包含：
  - 3条验收标准，全部按描述实现
  - `TR-ID: TR-light-001` 引用一条 GDD 需求
  - `ADR: docs/architecture/adr-003-inventory.md`（状态为 Accepted）
  - `Status: In Progress`
- Story 中列出的实现文件在 `src/` 中存在
- TR-light-001 处的 GDD 需求文本与功能实现方式一致
- ADR 指南已被遵循（无偏差）

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. Skill 读取 story 文件并提取所有关键字段
2. Skill 从 `tr-registry.yaml` 重新读取 GDD 需求（而非使用 story 中引用的文本）
3. Skill 读取引用的 ADR 以了解实现约束
4. Skill 评估每条验收标准（可自动评估的自动处理，无法自动评估的提示用户手动确认）
5. Skill 检查 GDD 需求偏差
6. Skill 检查 ADR 指南偏差
7. Skill 提示用户："请提供此 story 的代码评审结果"
8. Skill 给出 COMPLETE 判定
9. Skill 询问"我可以将 story Status 更新为 Complete 并添加 Completion Notes 吗？"
10. 若同意：skill 更新 story 文件
11. Skill 展示 sprint 中下一条 `Ready for Dev` 的 story

**断言：**
- [ ] Skill 读取 `docs/architecture/tr-registry.yaml` 获取 TR-ID 需求文本（而非仅用 story 中的）
- [ ] Skill 读取引用的 ADR 文件（而非仅用 story 中的引用）
- [ ] 每条验收标准列出 VERIFIED / DEFERRED / FAILED 状态
- [ ] Skill 提示用户提供代码评审结果（不跳过此步骤）
- [ ] 当所有标准已验证且无偏差时，判定为 COMPLETE
- [ ] Skill 在更新 story 文件前询问"我可以写入"
- [ ] Skill 未经用户确认不自动更新 story 状态
- [ ] 完成后，Skill 展示 `production/sprints/` 中下一条就绪的 story

---

### 用例2：阻塞路径 — 验收标准无法验证

**Fixture：**
- Story 文件中有一条验收标准："玩家拾取时显示正确动画"
- 该标准无自动化测试
- 尚未执行手动验证
- 其他所有标准均已满足

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. Skill 处理所有验收标准
2. 到达动画标准 — 无法自动验证
3. Skill 询问用户："验收标准'玩家拾取时显示正确动画'无法自动验证。此项是否已经过手动测试？"
4. 若用户回答否：该标准标记为 DEFERRED，判定变为 COMPLETE WITH NOTES
5. Skill 在 Completion Notes 中记录该延期标准
6. 询问"我可以写入更新后的 story（已注明延期标准）吗？"

**断言：**
- [ ] Skill 向用户询问无法验证的标准，而非假定 PASS
- [ ] 延期标准导致 COMPLETE WITH NOTES（而非 COMPLETE 或 BLOCKED）
- [ ] 延期标准在 Completion Notes 中明确命名
- [ ] Skill 在更新 story 文件前仍然询问"我可以写入"

---

### 用例3：阻塞路径 — 检测到 GDD 偏差

**Fixture：**
- Story TR-ID 指向需求："玩家最多可携带3个光源"
- `src/` 中的实现使用了变量 `MAX_CARRIED_LIGHTS = 5`
- 这是对 GDD 的有意偏离

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. Skill 读取 GDD 需求文本（最多3个）
2. Skill 检测到需求与实现值（5）之间的差异
3. Skill 将此标记为 GDD 偏差，要求用户分类：
   - INTENTIONAL：记录偏差及原因
   - ERROR：实现必须在 story 标记为 Complete 之前修复
   - OUT OF SCOPE：需求已变更，GDD 需要更新
4. 若 INTENTIONAL：skill 在 Completion Notes 中记录偏差，判定为 COMPLETE WITH NOTES
5. 若 ERROR：判定为 BLOCKED，直到实现修正

**断言：**
- [ ] Skill 检测到 GDD 需求与实现值之间的不匹配
- [ ] Skill 要求用户对偏差进行分类（不自作主张假定任一类型）
- [ ] INTENTIONAL 偏差 → COMPLETE WITH NOTES（非 BLOCKED）
- [ ] ERROR 偏差 → BLOCKED 判定直至修复
- [ ] 检测到的偏差记录在 Completion Notes 或技术债登记表中

---

### 用例4：边界情况 — 无参数，自动检测当前 story

**Fixture：**
- `production/session-state/active.md` 包含引用 `production/epics/core/story-oxygen-drain.md` 作为当前活跃 story
- 该 story 文件存在且 `Status: In Progress`

**输入：** `/story-done`（无参数）

**预期行为：**
1. Skill 读取 `production/session-state/active.md`
2. Skill 找到活跃 story 引用
3. Skill 读取该 story 文件并按正常流程继续
4. 输出确认自动检测到的是哪个 story

**断言：**
- [ ] 无参数时 Skill 读取 `production/session-state/active.md`
- [ ] Skill 在继续之前识别并确认自动检测到的 story
- [ ] 若 session state 中未找到 story，Skill 要求用户提供路径

---

---

### 用例5：Director Gate — LP-CODE-REVIEW 在不同评审模式下的行为

**Fixture：**
- Story 文件位于 `production/epics/core/story-light-pickup.md`
- 所有验收标准已验证，无 GDD 偏差
- `production/session-state/review-mode.txt` 存在

**用例5a — full 模式：**
- `review-mode.txt` 内容为 `full`

**输入：** `/story-done production/epics/core/story-light-pickup.md`（full 模式）

**预期行为：**
1. Skill 读取 review mode — 确定为 `full`
2. 实现验证完成后，Skill 调用 LP-CODE-REVIEW gate
3. 主程评审实现
4. 若 LP 判定为 NEEDS CHANGES → story 不能标记为 Complete
5. 若 LP 判定为 APPROVED → Skill 继续将 story 标记为 Complete

**断言（5a）：**
- [ ] Skill 在决定是否调用 LP-CODE-REVIEW 之前读取 review mode
- [ ] full 模式下，在实现检查后调用 LP-CODE-REVIEW gate
- [ ] LP NEEDS CHANGES 判定阻止 story 标记为 Complete
- [ ] Gate 结果在输出中标注："Gate: LP-CODE-REVIEW — [结果]"
- [ ] 即使 LP 批准，Skill 仍会在更新 story 状态前询问"我可以写入"

**用例5b — lean 或 solo 模式：**
- `review-mode.txt` 内容为 `lean` 或 `solo`

**预期行为：**
1. Skill 读取 review mode — 确定为 `lean` 或 `solo`
2. LP-CODE-REVIEW gate 被跳过
3. 输出标注跳过："[LP-CODE-REVIEW] 已跳过 — Lean/Solo 模式"
4. Story 完成仅基于验收标准检查

**断言（5b）：**
- [ ] lean 或 solo 模式下不启动 LP-CODE-REVIEW gate
- [ ] 跳过操作在输出中明确标注
- [ ] Skill 在标记 story 为 Complete 前仍需"我可以写入"批准

---

## 协议合规

- [ ] 在更新 story 文件前使用"我可以写入"
- [ ] 在向 `docs/tech-debt-register.md` 添加条目前使用"我可以写入"
- [ ] 在请求批准前展示完整发现（标准检查、偏差检查）
- [ ] 结束时展示 sprint 计划中下一条就绪的 story
- [ ] 若任一标准处于 ERROR 状态，不将 story 标记为 Complete
- [ ] 不跳过代码评审提示

---

## 覆盖范围说明

- Skill 的完整8阶段流程在用例1-3中得到演练；但各阶段内的所有边界情况未全部覆盖。
- 技术债记录（延期项目写入 `docs/tech-debt-register.md`）在用例2中提及但非主要断言焦点；专项覆盖推迟。
- `sprint-status.yaml` 更新（skill 中的 Phase 7）在用例1中隐含但非主要断言；假定遵循相同的"我可以写入"模式。
- 带有多个 TR-ID 或多个 ADR 的 story 未显式测试。
