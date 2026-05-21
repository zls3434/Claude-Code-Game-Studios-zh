<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格: /create-stories

## Skill 概要

`/create-stories` 将单个 epic 拆分为可供开发者直接使用的故事（story）文件。它读取 EPIC.md、相应的 GDD、管辖 ADR、控制清单（control manifest）以及 TR 注册表。每个故事获得结构化的前置元数据，包括：Title、Epic、Layer、Priority、Status、TR-ID、ADR 引用、Acceptance Criteria 和 Definition of Done。故事按类型分类（Logic / Integration / Visual/Feel / UI / Config/Data），类型决定了所需的测试证据路径。

在 `full` 审查模式下，每个故事创建后会运行 QL-STORY-READY 检查。在 `lean` 或 `solo` 模式下，QL-STORY-READY 被跳过。Skill 在写入每个故事文件前询问"May I write"。故事文件写入至 `production/epics/[layer]/story-[name].md`。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 —— 无需测试夹具。

- [ ] 包含必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含判定关键词：COMPLETE、BLOCKED、NEEDS WORK
- [ ] 包含"May I write"协作协议用语（每个故事独立审批）
- [ ] 末尾包含下一步交接指引（`/story-readiness`、`/dev-story`）
- [ ] 文档说明当管辖 ADR 为 Proposed 时，故事 Status 为 Blocked
- [ ] 文档说明 QL-STORY-READY 关卡：在 full 模式下活跃，在 lean/solo 模式下跳过

---

## 导演关卡检查

在 `full` 模式下：每个故事创建后运行 QL-STORY-READY 检查。未通过检查的故事在"May I write"询问前标注为 NEEDS WORK。

在 `lean` 模式下：QL-STORY-READY 被跳过。输出中逐故事注明："QL-STORY-READY skipped — lean mode"。

在 `solo` 模式下：QL-STORY-READY 被跳过，附带等效注释。

---

## 测试用例

### 用例 1：正常流程 —— Epic 包含 3 个故事，所有 ADR 均为 Accepted

**测试夹具：**
- `production/epics/[layer]/EPIC-[name].md` 存在，包含 3 条 GDD 需求
- 相应的 GDD 存在且包含匹配的验收标准
- 所有管辖 ADR 的 `Status: Accepted`
- `docs/architecture/control-manifest.md` 存在
- `docs/architecture/tr-registry.yaml` 包含所有 3 条需求的 TR-ID
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/create-stories [epic-name]`

**预期行为：**
1. Skill 读取 EPIC.md、GDD、管辖 ADR、控制清单和 TR 注册表
2. 将每条需求归类为故事类型（Logic / Integration / Visual/Feel / UI / Config/Data）
3. 按正确的前置元数据模式起草 3 个故事文件
4. QL-STORY-READY 被跳过（lean 模式）—— 输出中注明
5. 写入每个故事文件前询问"May I write"
6. 获批后写入全部 3 个故事文件

**断言：**
- [ ] 每个故事的前置元数据包含：Title、Epic、Layer、Priority、Status、TR-ID、ADR 引用、Acceptance Criteria、DoD
- [ ] 故事类型分类正确（测试夹具中至少包含一个 Logic 类型）
- [ ] "May I write"按每个故事分别询问（而非一次性针对整批）
- [ ] QL-STORY-READY 跳过在输出中注明
- [ ] 全部 3 个故事文件按正确命名格式 `story-[name].md` 写入
- [ ] Skill 不启动实现

---

### 用例 2：失败路径 —— 未找到 epic 文件

**测试夹具：**
- `production/epics/` 中不存在指定的 epic 路径

**输入：** `/create-stories nonexistent-epic`

**预期行为：**
1. Skill 尝试读取 EPIC.md 文件
2. 文件未找到
3. Skill 输出清晰的错误信息并附加上其搜索的路径
4. Skill 建议检查 `production/epics/` 或先运行 `/create-epics`
5. 不创建任何故事文件

**断言：**
- [ ] Skill 输出清晰错误信息，指明缺失文件的路径
- [ ] 不写入任何故事文件
- [ ] Skill 建议正确的下一步操作（`/create-epics`）
- [ ] Skill 在没有有效 EPIC.md 的情况下不创建故事

---

### 用例 3：被阻塞的故事 —— ADR 为 Proposed

**测试夹具：**
- EPIC.md 存在，包含 2 条需求
- 需求 1 由 Accepted ADR 覆盖
- 需求 2 由 `Status: Proposed` 的 ADR 覆盖

**输入：** `/create-stories [epic-name]`

**预期行为：**
1. Skill 读取需求 2 的 ADR，发现 Status: Proposed
2. 需求 2 的故事草案 `Status: Blocked`
3. 阻塞注释引用具体 ADR："BLOCKED: ADR-NNN is Proposed"
4. 需求 1 的故事草案正常，`Status: Ready`
5. 两个故事均在草稿中展示 —— 对两个故事分别询问"May I write"

**断言：**
- [ ] 故事 2 的前置元数据中 `Status: Blocked`
- [ ] 阻塞注释指明具体 ADR 编号并建议 `/architecture-decision`
- [ ] 故事 1 的 `Status: Ready` —— 阻塞状态不影响未被阻塞的故事
- [ ] 阻塞状态在写入前的草稿预览中展示
- [ ] 两个故事文件均被写入（被阻塞的故事仍会写入 —— 仅标记状态）

---

### 用例 4：边界情况 —— 未提供参数

**测试夹具：**
- `production/epics/` 目录存在且包含 ≥2 个 epic 子目录

**输入：** `/create-stories`（无参数）

**预期行为：**
1. Skill 检测到未提供参数
2. 输出使用错误："No epic specified. Usage: /create-stories [epic-name]"
3. Skill 列出 `production/epics/` 中可用的 epic
4. 不创建任何故事文件

**断言：**
- [ ] Skill 在无参数时输出使用错误
- [ ] Skill 列出可用 epic 以帮助用户选择
- [ ] 不写入任何故事文件
- [ ] Skill 不会在没有用户输入的情况下静默选择 epic

---

### 用例 5：导演关卡 —— Full 模式运行 QL-STORY-READY；未通过的故事标注为 NEEDS WORK

**测试夹具：**
- EPIC.md 存在，包含 2 条需求
- 两条需求的管辖 ADR 均为 Accepted
- `production/session-state/review-mode.txt` 包含 `full`
- QL-STORY-READY 检查发现其中一个故事存在模糊的验收标准

**输入：** `/create-stories [epic-name]`

**预期行为：**
1. 两个故事均被起草
2. 对每个故事运行 QL-STORY-READY 检查
3. 故事 1 通过 QL-STORY-READY
4. 故事 2 未通过 QL-STORY-READY —— 标注为 NEEDS WORK 并附带具体反馈
5. 两个故事在"May I write"之前均向用户展示通过/失败状态
6. 用户可选择继续（故事按原样写入并附带 NEEDS WORK 注释）或先修订

**断言：**
- [ ] QL-STORY-READY 结果在输出中逐故事展示
- [ ] 故事 2 被标注为 NEEDS WORK 并说明未通过的具体标准
- [ ] 故事 1 显示为通过 QL-STORY-READY
- [ ] 用户在写入前获得继续或修订的选择
- [ ] Skill 不会在未经用户输入的情况下自动阻止未通过 QL-STORY-READY 的故事写入

---

## 协议合规性

- [ ] 所有上下文（EPIC、GDD、ADR、清单、TR 注册表）在起草故事前加载完毕
- [ ] 故事草稿在任何"May I write"询问前完整展示
- [ ] "May I write"按每个故事分别询问（而非一次性针对整批）
- [ ] 被阻塞的故事在写入批准前标注 —— 而非写入后才发现
- [ ] TR-ID 引用注册表 —— 需求文本不内嵌在故事文件中
- [ ] 控制清单规则从清单中逐故事引用，而非凭空编造
- [ ] 末尾包含下一步交接指引：`/story-readiness` → `/dev-story`

---

## 覆盖范围注释

- Integration 故事测试证据（playtest 文档替代方案）遵循与 Logic 故事相同的审批模式 —— 不独立进行测试夹具测试。
- 故事排序（基础优先，UI 最后）通过用例 1 的多故事测试夹具隐式验证。
- 故事规模规则（拆分大型需求组）不在此处测试 —— 它属于 `/create-stories` skill 的内部逻辑。
