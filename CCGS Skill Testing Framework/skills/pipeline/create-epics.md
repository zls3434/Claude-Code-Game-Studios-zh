<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格: /create-epics

## Skill 概要

`/create-epics` 读取所有已批准的 GDD，并将其转换为 EPIC.md 文件，每个系统对应一个。Epic 按层级（Foundation → Core → Feature → Presentation）组织，并在每个层级内按优先级顺序处理。每个 EPIC.md 包含范围、管辖 ADR、GDD 需求、引擎风险等级和 Definition of Done。该 skill 在创建每个 EPIC 文件之前会询问"May I write"。

在 `full` 审查模式下，PR-EPIC 关卡（producer）在起草 epic 之后、写入任何文件之前运行。在 `lean` 或 `solo` 模式下，PR-EPIC 被跳过并予以注明。Epic 文件写入至 `production/epics/[layer]/EPIC-[name].md`。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 —— 无需测试夹具。

- [ ] 包含必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含判定关键词：CREATED、BLOCKED
- [ ] 包含"May I write"协作协议用语（每个 epic 独立审批）
- [ ] 末尾包含下一步交接指引（`/create-stories`）
- [ ] 文档明确说明 PR-EPIC 关卡行为：在 full 模式下运行；在 lean/solo 模式下跳过

---

## 导演关卡检查

在 `full` 模式下：PR-EPIC（producer）关卡在 epic 起草完毕后、任何 epic 文件写入前运行。若 PR-EPIC 返回 CONCERNS，则在"May I write"询问之前对 epic 进行修订。

在 `lean` 模式下：PR-EPIC 被跳过。输出注明："PR-EPIC skipped — lean mode"。

在 `solo` 模式下：PR-EPIC 被跳过。输出注明："PR-EPIC skipped — solo mode"。

---

## 测试用例

### 用例 1：正常流程 —— 两个已批准 GDD 生成两个 EPIC 文件

**测试夹具：**
- `design/gdd/systems-index.md` 存在，列出 2 个系统
- 两个系统在 `design/gdd/` 中均有已批准的 GDD
- `docs/architecture/architecture.md` 存在且包含匹配的模块
- 每个系统至少有一个 Accepted ADR
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/create-epics`

**预期行为：**
1. Skill 读取系统索引和两个 GDD
2. 起草 2 个 EPIC 定义（层级、GDD 路径、ADR、需求、引擎风险）
3. PR-EPIC 关卡被跳过（lean 模式）—— 输出中注明
4. 对每个 epic 分别询问："May I write `production/epics/[layer]/EPIC-[name].md`?"
5. 获得批准后：写入两个 EPIC 文件
6. 创建或更新 `production/epics/index.md`

**断言：**
- [ ] Epic 摘要在任何写入询问之前展示
- [ ] "May I write"按每个 epic 分别询问（而非一次性针对所有 epic）
- [ ] 每个 EPIC.md 包含：层级、GDD 路径、管辖 ADR、需求表、Definition of Done
- [ ] PR-EPIC 跳过在输出中注明
- [ ] `production/epics/index.md` 在写入后更新
- [ ] Skill 在未按每个 epic 分别获批的情况下不写入 EPIC 文件

---

### 用例 2：失败路径 —— 未找到已批准的 GDD

**测试夹具：**
- `design/gdd/systems-index.md` 存在
- `design/gdd/` 中没有任何 GDD 处于已批准状态（全部为 Draft 或 In Progress）

**输入：** `/create-epics`

**预期行为：**
1. Skill 读取系统索引并尝试查找已批准的 GDD
2. 未找到已批准的 GDD
3. Skill 输出："No approved GDDs to convert. GDDs must be Approved before creating epics."
4. Skill 建议先运行 `/design-system` 并完成 GDD 审批
5. Skill 退出，不创建任何 EPIC 文件

**断言：**
- [ ] Skill 在无可批准 GDD 时干净停止并输出清晰消息
- [ ] 不写入任何 EPIC 文件
- [ ] Skill 建议正确的下一步操作
- [ ] 判定结果为 BLOCKED

---

### 用例 3：导演关卡 —— Full 模式在写入前派生 PR-EPIC

**测试夹具：**
- 存在 2 个已批准 GDD
- `production/session-state/review-mode.txt` 包含 `full`

**Full 模式预期行为：**
1. Skill 起草两个 epic
2. PR-EPIC 关卡派生并对 epic 草稿进行审查
3. 若 PR-EPIC 返回 APPROVED：正常进行"May I write"询问
4. Epic 文件在获批后写入

**断言（full 模式）：**
- [ ] PR-EPIC 关卡在输出中显示为活跃关卡
- [ ] PR-EPIC 在任何"May I write"询问之前运行
- [ ] EPIC 文件在 PR-EPIC 完成之前不被写入

**测试夹具（lean 模式）：**
- 相同的 GDD
- `production/session-state/review-mode.txt` 包含 `lean`

**Lean 模式预期行为：**
1. Epic 起草完成
2. PR-EPIC 被跳过 —— 输出中注明
3. 直接进行"May I write"询问

**断言（lean 模式）：**
- [ ] "PR-EPIC skipped — lean mode"出现在输出中
- [ ] Skill 直接进入"May I write"而不等待 PR-EPIC

---

### 用例 4：边界情况 —— Epic 已存在

**测试夹具：**
- `production/epics/[layer]/EPIC-[name].md` 已存在（对应某个已批准 GDD）
- 另一个 GDD 尚无对应的 EPIC 文件

**输入：** `/create-epics`

**预期行为：**
1. Skill 检测到第一个系统已有 EPIC 文件
2. Skill 提供更新而非覆盖："EPIC-[name].md already exists. Update it, or skip?"
3. 对第二个系统（无已有文件）：正常进行"May I write"

**断言：**
- [ ] Skill 在写入前检测已有 EPIC 文件
- [ ] 为用户提供"更新"或"跳过"选项 —— 不自动覆盖
- [ ] 新系统的 EPIC 无冲突地正常创建

---

### 用例 5：导演关卡 —— PR-EPIC 返回 CONCERNS

**测试夹具：**
- 存在 2 个已批准 GDD
- `production/session-state/review-mode.txt` 包含 `full`
- PR-EPIC 关卡返回 CONCERNS（例如某个 epic 的范围过大）

**输入：** `/create-epics`

**预期行为：**
1. PR-EPIC 关卡派生并返回 CONCERNS 及具体反馈
2. Skill 在任何写入询问前向用户呈现问题
3. 用户获得选项：修订 epic、接受问题继续、或停止
4. 若用户选择修订：更新后的 epic 草稿在"May I write"询问前展示
5. Skill 在 CONCERNS 未处理的情况下不写入 epic

**断言：**
- [ ] PR-EPIC 的 CONCERNS 在写入前展示给用户
- [ ] Skill 在返回 CONCERNS 时不自动写入 epic
- [ ] 用户获得明确的修订、继续或停止选择
- [ ] 修订后的 epic 草稿在最终批准前重新展示

---

## 协议合规性

- [ ] Epic 草稿在任何"May I write"询问之前展示给用户
- [ ] "May I write"按每个 epic 分别询问，而非一次性针对整批
- [ ] PR-EPIC 关卡（若活跃）在写入询问之前运行 —— 而非之后
- [ ] 跳过的关卡在输出中按名称和模式注明
- [ ] EPIC.md 内容仅来源于 GDD、ADR 和架构文档 —— 不凭空编造
- [ ] 末尾包含下一步交接指引：`/create-stories [epic-slug]`（按创建的 epic 分别给出）

---

## 覆盖范围注释

- Core、Feature 和 Presentation 层级的处理遵循与 Foundation 相同的按 epic 分别模式 —— 层级特定排序不独立测试。
- 引擎风险等级分配（LOW/MEDIUM/HIGH，来源于管辖 ADR）通过用例 1 的测试夹具结构隐式验证。
- `layer: [name]` 和 `[system-name]` 参数模式遵循与默认模式（全部系统）相同的审批模式。
