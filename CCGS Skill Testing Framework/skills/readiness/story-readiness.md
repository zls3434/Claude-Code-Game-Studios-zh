<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/story-readiness

## Skill 概要

`/story-readiness` 验证一个 story 文件是否已准备好供开发者领取并实现。它从四个维度进行检查：Design（内嵌的 GDD 需求）、Architecture（ADR 引用及状态）、Scope（清晰的边界和 DoD）以及 Definition of Done（可测试的验收标准）。它生成 READY / NEEDS WORK / BLOCKED 判定。这是一个只读 skill，在开发者领取任何 story 之前运行。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题或编号检查章节
- [ ] 包含判定关键词：READY、NEEDS WORK、BLOCKED
- [ ] 不需要"我可以写入"用语（只读 skill）
- [ ] 有下一步交接（判定后应做什么）

---

## 测试用例

### 用例1：Happy Path — 完全就绪的 story

**Fixture：**
- Story 文件存在于 `production/epics/core/story-light-pickup.md`
- Story 包含：
  - `TR-ID: TR-light-001`（GDD 需求引用）
  - `ADR: docs/architecture/adr-003-inventory.md`
  - 引用的 ADR 存在且状态为 `Accepted`
  - 引用的 TR-ID 在 `docs/architecture/tr-registry.yaml` 中存在
  - Story 有 `## Acceptance Criteria` 章节，包含 ≥3 条可测试项
  - Story 有 `## Definition of Done` 章节
  - Story 状态为 `Status: Ready for Dev`
  - Story 头部中的 Manifest version 与当前 `docs/architecture/control-manifest.md` 一致

**输入：** `/story-readiness production/epics/core/story-light-pickup.md`

**预期行为：**
1. Skill 读取 story 文件
2. Skill 读取引用的 ADR — 验证状态为 `Accepted`
3. Skill 读取 `docs/architecture/tr-registry.yaml` — 验证 TR-ID 存在
4. Skill 读取 `docs/architecture/control-manifest.md` — 验证 manifest version 一致
5. Skill 评估全部4个维度（Design、Architecture、Scope、DoD）
6. Skill 输出 READY 判定，所有检查通过

**断言：**
- [ ] Skill 读取引用的 ADR 文件（而非仅用 story 中的引用）
- [ ] Skill 验证 ADR 状态为 `Accepted`（非 `Proposed`）
- [ ] Skill 读取 `tr-registry.yaml` 验证 TR-ID 存在
- [ ] 输出包含全部4个维度的检查结果
- [ ] 所有检查通过时判定为 READY
- [ ] Skill 不写入任何文件

---

### 用例2：阻塞路径 — 引用的 ADR 为 Proposed（未 Accepted）

**Fixture：**
- Story 文件存在，包含 `ADR: docs/architecture/adr-005-light-system.md`
- `adr-005-light-system.md` 存在但状态为 `Status: Proposed`
- Story 的其他所有内容均已完备

**输入：** `/story-readiness production/epics/core/story-light-system.md`

**预期行为：**
1. Skill 读取 story
2. Skill 读取 `adr-005-light-system.md` — 发现 `Status: Proposed`
3. Skill 将此标记为 BLOCKING 问题（不能基于未接受的 ADR 进行实现）
4. Skill 输出 BLOCKED 判定
5. Skill 建议：在领取 story 前先接受或拒绝该 ADR

**断言：**
- [ ] 当 ADR 为 Proposed 时，判定为 BLOCKED（非 NEEDS WORK 或 READY）
- [ ] 输出明确指明该 Proposed ADR 为阻塞项
- [ ] 输出建议在继续之前解决 ADR 状态问题
- [ ] 无论其他检查是否通过，Skill 不输出 READY

---

### 用例3：需要改进 — 缺少验收标准

**Fixture：**
- Story 文件存在但没有 `## Acceptance Criteria` 章节
- ADR 引用存在且状态为 `Accepted`
- TR-ID 在 registry 中存在
- Manifest version 一致

**输入：** `/story-readiness production/epics/core/story-oxygen-drain.md`

**预期行为：**
1. Skill 读取 story
2. Skill 未找到 Acceptance Criteria 章节
3. Skill 将此标记为 NEEDS WORK 问题（story 不完整，非阻塞）
4. Skill 输出 NEEDS WORK 判定
5. Skill 指明缺失的章节并建议添加可衡量的标准

**断言：**
- [ ] 当 Acceptance Criteria 章节缺失时，判定为 NEEDS WORK（非 BLOCKED 或 READY）
- [ ] 输出明确指出缺失的 Acceptance Criteria 章节
- [ ] 输出建议添加可测试/可衡量的标准
- [ ] Skill 区分 NEEDS WORK（无需外部依赖即可修复）和 BLOCKED（需要外部操作）

---

### 用例4：边界情况 — Manifest version 过时

**Fixture：**
- Story 文件头部包含 `Manifest Version: 2026-01-15`
- `docs/architecture/control-manifest.md` 中为 `Manifest Version: 2026-03-10`
- 版本不一致（story 创建于 manifest 更新之前）

**输入：** `/story-readiness production/epics/core/story-mirror-rotation.md`

**预期行为：**
1. Skill 读取 story 并提取 manifest version `2026-01-15`
2. Skill 读取 control manifest 头部并提取当前版本 `2026-03-10`
3. Skill 检测到版本不匹配
4. Skill 将此标记为 ADVISORY 问题（非阻塞，但值得注意）
5. 判定为 NEEDS WORK，附带 manifest 过时说明

**断言：**
- [ ] Skill 读取 `docs/architecture/control-manifest.md` 获取当前版本
- [ ] Skill 比较 story 内嵌的 manifest version 与当前 manifest version
- [ ] Manifest version 过时导致 NEEDS WORK（非 BLOCKED，非 READY）
- [ ] 输出说明 story 的内嵌指引可能已过时

---

---

### 用例5：Director Gate — QL-STORY-READY 在不同评审模式下的行为

**Fixture：**
- Story 文件存在且处于 READY 状态（4个维度全部通过、ADR 为 Accepted、验收标准齐全）
- `production/session-state/review-mode.txt` 存在

**用例5a — full 模式：**
- `review-mode.txt` 内容为 `full`

**输入：** `/story-readiness production/epics/core/story-light-pickup.md`（full 模式）

**预期行为：**
1. Skill 读取 review mode — 确定为 `full`
2. 完成自身的4维度检查后，Skill 调用 QL-STORY-READY gate
3. QA 负责人评审 story 的就绪状态
4. 若 QA 负责人判定为 INADEQUATE → story 判定为 BLOCKED，无论4维度结果如何
5. 若 QA 负责人判定为 ADEQUATE → 判定正常进行

**断言（5a）：**
- [ ] Skill 在决定是否调用 QL-STORY-READY 之前读取 review mode
- [ ] full 模式下，4维度检查完成后调用 QL-STORY-READY gate
- [ ] QA 负责人 INADEQUATE 判定覆盖 READY 的4维度结果 → 最终判定 BLOCKED
- [ ] Gate 调用在输出中标注："Gate: QL-STORY-READY — [结果]"

**用例5b — lean 或 solo 模式：**
- `review-mode.txt` 内容为 `lean` 或 `solo`

**预期行为：**
1. Skill 读取 review mode — 确定为 `lean` 或 `solo`
2. QL-STORY-READY gate 被跳过
3. 输出标注跳过："[QL-STORY-READY] 已跳过 — Lean/Solo 模式"
4. 判定仅基于4维度检查

**断言（5b）：**
- [ ] lean 或 solo 模式下不启动 QL-STORY-READY gate
- [ ] 跳过操作在输出中明确标注
- [ ] 判定仅基于4维度检查

---

## 协议合规

- [ ] 不使用 Write 或 Edit 工具（只读 skill）
- [ ] 在判定前展示完整检查结果
- [ ] 不请求批准（无文件写入操作）
- [ ] 结束时给出推荐的下一步（修复问题或进入实现阶段）
- [ ] 清晰区分三个判定级别（READY vs NEEDS WORK vs BLOCKED）

---

## 覆盖范围说明

- TR-ID 在 registry 中完全缺失的情况未在此显式测试；它遵循与用例3相同的 NEEDS WORK 模式。
- "无参数"路径（skill 自动检测当前 story）未测试，因为它依赖于 `production/session-state/active.md` 内容，难以可靠地构造 fixture。
- 带有多个 ADR 引用的 story 未测试；假定行为为叠加（所有 ADR 必须均为 Accepted 才能得到 READY 判定）。
