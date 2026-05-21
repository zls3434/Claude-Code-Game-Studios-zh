<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/architecture-decision

## Skill 摘要

`/architecture-decision` 引导用户逐节撰写一份新的架构决策记录（ADR）。必填章节包括：Status、Context、Decision、Consequences、Alternatives 和 Related ADRs。该 skill 还会将来自 `docs/engine-reference/` 的引擎版本引用印入 ADR 中以实现可追溯性。

在 `full` 审查模式下，TD-ADR（技术总监）和 LP-FEASIBILITY（首席程序员）门禁 Agent 会在草稿完成后生成。如果两个门禁均返回 APPROVED，则 ADR 状态设为 Accepted。在 `lean` 或 `solo` 模式下，两个门禁均被跳过，ADR 以 Status: Proposed 写入。该 skill 在撰写过程中会逐节询问"我可以将此写入吗？"。ADR 写入至 `docs/architecture/adr-NNN-[name].md`。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 — 无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含裁决关键词：ACCEPTED、PROPOSED、CONCERNS
- [ ] 包含"我可以将此写入吗？"协作协议用语（逐节审批）
- [ ] 末尾包含下一步交接
- [ ] 记录了门禁行为：full 模式下 TD-ADR + LP-FEASIBILITY；lean/solo 模式下跳过
- [ ] 记录了 ADR 状态为 Accepted（full 模式，门禁审批通过）或 Proposed（其他情况）
- [ ] 提及来自 `docs/engine-reference/` 的引擎版本印记

---

## 总监门禁检查

在 `full` 模式下：TD-ADR（技术总监）和 LP-FEASIBILITY（首席程序员）在 ADR 草稿完成后生成。如果两者均返回 APPROVED，则 ADR 状态设为 Accepted。如果任一返回 CONCERNS 或 FAIL，则 ADR 保持 Proposed。

在 `lean` 模式下：两个门禁均被跳过。ADR 以 Status: Proposed 写入。输出注明："TD-ADR 已跳过 — lean 模式"和"LP-FEASIBILITY 已跳过 — lean 模式"。

在 `solo` 模式下：两个门禁均被跳过。ADR 以 Status: Proposed 写入。

---

## 测试用例

### 用例 1：理想路径 — 新建渲染方案的 ADR，full 模式，门禁审批通过

**夹具：**
- `docs/architecture/` 存在，且无渲染相关的现有 ADR
- `docs/engine-reference/[engine]/VERSION.md` 存在
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/architecture-decision rendering-approach`

**预期行为：**
1. Skill 引导用户完成每个必填章节（Status、Context、Decision、Consequences、Alternatives、Related ADRs）
2. 从 `docs/engine-reference/` 将引擎版本印入 ADR
3. 对每个章节：展示草稿，询问"我可以写入此章节吗？"，获得批准
4. 所有章节完成后：TD-ADR 和 LP-FEASIBILITY 门禁并行生成
5. 两个门禁均返回 APPROVED
6. ADR 状态设为 Accepted
7. Skill 写入 `docs/architecture/adr-NNN-rendering-approach.md`
8. 若定义了新的 TR-ID，则更新 `docs/architecture/tr-registry.yaml`

**断言：**
- [ ] 所有 6 个必填章节均已撰写并写入
- [ ] 引擎版本引用已印入 ADR
- [ ] TD-ADR 和 LP-FEASIBILITY 并行生成（非顺序执行）
- [ ] 在 full 模式下两个门禁均返回 APPROVED 时，ADR 状态为 Accepted
- [ ] 撰写过程中逐节询问"我可以将此写入吗？"
- [ ] 文件写入至 `docs/architecture/adr-NNN-[name].md`

---

### 用例 2：失败路径 — TD-ADR 返回 CONCERNS

**夹具：**
- ADR 草稿已完成（所有章节已填写）
- `production/session-state/review-mode.txt` 包含 `full`
- TD-ADR 门禁返回 CONCERNS："该决策未处理 [具体关切问题]"

**输入：** `/architecture-decision [topic]`

**预期行为：**
1. TD-ADR 门禁生成并返回 CONCERNS 及具体反馈
2. Skill 将关切问题展示给用户
3. ADR 状态保持 Proposed（而非 Accepted）
4. 询问用户：修改决策以解决关切问题，或以 Proposed 状态接受
5. 若关切问题未解决，ADR 以 Status: Proposed 写入

**断言：**
- [ ] TD-ADR 的关切问题逐字展示给用户
- [ ] 当 TD-ADR 返回 CONCERNS 时，ADR 状态为 Proposed（而非 Accepted）
- [ ] 当 CONCERNS 未解决时，Skill 不会设置 Status: Accepted
- [ ] 用户被给予修改并重新运行门禁的选项

---

### 用例 3：Lean 模式 — 两个门禁均跳过；ADR 以 Proposed 写入

**夹具：**
- `production/session-state/review-mode.txt` 包含 `lean`
- 已为一项新的技术决策撰写了 ADR 草稿

**输入：** `/architecture-decision [topic]`

**预期行为：**
1. Skill 引导用户完成所有 6 个章节
2. 草稿完成后：TD-ADR 和 LP-FEASIBILITY 均被跳过
3. 输出注明："TD-ADR 已跳过 — lean 模式"和"LP-FEASIBILITY 已跳过 — lean 模式"
4. ADR 以 Status: Proposed 写入（而非 Accepted，因门禁未审批）
5. 在最终文件写入前仍会询问"我可以将此写入吗？"

**断言：**
- [ ] 两个门禁跳过提示均出现在输出中
- [ ] 在 lean 模式下 ADR 状态为 Proposed（而非 Accepted）
- [ ] 在写入文件前仍会询问"我可以将此写入吗？"
- [ ] Skill 在用户批准后写入 ADR

---

### 用例 4：边界情况 — 该主题的 ADR 已存在

**夹具：**
- `docs/architecture/` 包含一个覆盖同一主题的现有 ADR
- 该现有 ADR 的状态为 Accepted

**输入：** `/architecture-decision [same-topic]`

**预期行为：**
1. Skill 检测到已有覆盖同一主题的 ADR
2. Skill 询问："[主题] 的 ADR 已存在（[文件名]）。是更新它，还是创建一份新的替代 ADR？"
3. 用户选择更新或替代
4. Skill 不会静默创建重复的 ADR

**断言：**
- [ ] Skill 在开始撰写前检测到现有 ADR
- [ ] 用户被提供更新或替代选项 — 不会静默创建重复文件
- [ ] 若选择更新：skill 打开现有 ADR 进行逐节修订
- [ ] 若选择替代：新 ADR 在 Related ADRs 章节中引用被替代的 ADR

---

### 用例 5：总监门禁 — 根据模式和门禁结果正确设置状态

**夹具：**
- ADR 草稿已完成
- 两种场景：(a) full 模式，两个门禁均 APPROVED；(b) full 模式，一个门禁返回 CONCERNS

**Full 模式，两个门禁均 APPROVED：**
- ADR 状态设为 Accepted

**断言（两个门禁均通过）：**
- [ ] ADR frontmatter/头部显示 `Status: Accepted`
- [ ] TD-ADR 和 LP-FEASIBILITY 在输出中均显示为 APPROVED

**Full 模式，一个门禁返回 CONCERNS：**
- ADR 状态保持 Proposed

**断言（CONCERNS）：**
- [ ] ADR frontmatter/头部显示 `Status: Proposed`
- [ ] 关切问题列在输出中
- [ ] 当任一门禁返回 CONCERNS 时，Skill 不会设置 Status: Accepted

**Lean/solo 模式：**
- ADR 状态始终为 Proposed，无论内容质量如何

**断言（lean/solo）：**
- [ ] 在 lean 模式下 ADR 状态为 Proposed
- [ ] 在 solo 模式下 ADR 状态为 Proposed
- [ ] 在 lean 或 solo 模式中不出现门禁输出

---

## 协议合规

- [ ] 在门禁审查前完成所有 6 个必填章节的撰写
- [ ] 从 `docs/engine-reference/` 将引擎版本印入 ADR
- [ ] 撰写过程中逐节询问"我可以将此写入吗？"
- [ ] 在 full 模式下 TD-ADR 和 LP-FEASIBILITY 并行生成
- [ ] 在 lean/solo 输出中按名称和模式注明跳过的门禁
- [ ] ADR 状态：仅当 full 模式且两个门禁均 APPROVED 时为 Accepted
- [ ] 以下一步交接结束：`/architecture-review` 或 `/create-control-manifest`

---

## 覆盖说明

- ADR 编号（自动递增的 NNN）未单独进行夹具测试 — 该 skill 读取现有 ADR 文件名来分配下一个编号。
- Related ADRs 章节的链接（替代/关联）通过用例 4 进行了结构测试，但并非所有链接类型都单独验证。
- 当 ADR 中定义了新的 TR-ID 时，TR-registry 更新属于写入阶段的一部分 — 通过用例 1 隐式测试。
