<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/create-architecture

## Skill 摘要

`/create-architecture` 引导用户逐节撰写一份技术架构文档。它采用骨架优先的方式 — 在填充任何内容之前，先创建包含所有必填章节标题的文件。每个章节逐一讨论、起草，并在用户批准后单独写入。如果架构文档已存在，该 skill 提供改造模式以更新特定章节。

在 `full` 审查模式下，TD-ARCHITECTURE（技术总监）和 LP-FEASIBILITY（首席程序员）在完整草稿完成后生成。在 `lean` 或 `solo` 模式下，两个门禁均被跳过。该 skill 写入至 `docs/architecture/architecture.md`。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 — 无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含裁决关键词：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 包含"我可以将此写入吗？"协作协议用语（逐节审批）
- [ ] 末尾包含下一步交接（`/architecture-review` 或 `/create-control-manifest`）
- [ ] 记录了骨架优先方式
- [ ] 记录了门禁行为：full 模式下 TD-ARCHITECTURE + LP-FEASIBILITY；lean/solo 模式下跳过
- [ ] 记录了对已有架构文档的改造模式

---

## 总监门禁检查

在 `full` 模式下：TD-ARCHITECTURE（技术总监）和 LP-FEASIBILITY（首席程序员）在所有章节起草完成后、最终批准写入前并行生成。

在 `lean` 模式下：两个门禁均被跳过。输出注明："TD-ARCHITECTURE 已跳过 — lean 模式"和"LP-FEASIBILITY 已跳过 — lean 模式"。

在 `solo` 模式下：两个门禁均被跳过，带有相同备注。

---

## 测试用例

### 用例 1：理想路径 — 新建架构文档，骨架优先，full 模式门禁审批通过

**夹具：**
- 不存在 `docs/architecture/architecture.md`
- `docs/architecture/` 包含可供参考的 Accepted ADR
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/create-architecture`

**预期行为：**
1. Skill 创建骨架文件 `docs/architecture/architecture.md`，包含所有必填章节标题
2. 对每个章节：起草内容、展示草稿、询问"我可以写入 [章节] 吗？"、批准后写入
3. 所有章节起草完成后：TD-ARCHITECTURE 和 LP-FEASIBILITY 并行生成
4. 两个门禁均返回 APPROVED
5. 询问最终的"我可以确认架构已完成吗？"
6. 更新会话状态

**断言：**
- [ ] 骨架文件在写入任何内容之前已创建并包含所有章节标题
- [ ] 撰写过程中逐节询问"我可以写入 [章节] 吗？"
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 并行生成（非顺序执行）
- [ ] 两个门禁均在最终完成确认之前完成
- [ ] 当两个门禁均返回 APPROVED 时，裁决为 APPROVED
- [ ] 存在指向 `/architecture-review` 或 `/create-control-manifest` 的下一步交接

---

### 用例 2：失败路径 — TD-ARCHITECTURE 返回 MAJOR REVISION

**夹具：**
- 架构文档已完全起草（所有章节）
- `production/session-state/review-mode.txt` 包含 `full`
- TD-ARCHITECTURE 门禁返回 MAJOR REVISION："[具体结构性问题]"

**输入：** `/create-architecture`

**预期行为：**
1. 所有章节已起草并写入
2. TD-ARCHITECTURE 门禁运行并返回 MAJOR REVISION 及具体反馈
3. Skill 将反馈展示给用户
4. 架构不会被标记为已完成
5. 询问用户：修订被标记的章节，或以草稿形式接受该文档

**断言：**
- [ ] 当 TD-ARCHITECTURE 返回 MAJOR REVISION 时，架构不会被标记为已完成
- [ ] 门禁反馈展示给用户，附带具体问题描述
- [ ] 用户被给予修订特定章节的选项
- [ ] Skill 不会在收到 MAJOR REVISION 反馈后自动完成

---

### 用例 3：Lean 模式 — 两个门禁均跳过；架构仅以用户批准写入

**夹具：**
- 不存在架构文档
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/create-architecture`

**预期行为：**
1. 创建骨架文件
2. 所有章节逐节撰写并在用户批准后写入
3. 完成后：TD-ARCHITECTURE 和 LP-FEASIBILITY 被跳过
4. 输出注明："TD-ARCHITECTURE 已跳过 — lean 模式"和"LP-FEASIBILITY 已跳过 — lean 模式"
5. 仅基于用户批准即认为架构已完成

**断言：**
- [ ] 两个门禁跳过提示均出现在输出中
- [ ] 在 lean 模式下架构文档仅以用户批准写入
- [ ] Skill 不会因为门禁被跳过而阻止完成
- [ ] 下一步交接仍然存在

---

### 用例 4：改造模式 — 已有架构文档，用户更新某个章节

**夹具：**
- `docs/architecture/architecture.md` 已存在且所有章节已填充

**输入：** `/create-architecture`

**预期行为：**
1. Skill 检测到已有架构文档并读取其当前内容
2. Skill 提供改造模式："架构文档已存在。您想更新哪个章节？"
3. 用户选择一个章节
4. Skill 仅撰写该章节，询问"我可以写入 [章节] 吗？"
5. 仅所选章节被更新 — 其他章节不变

**断言：**
- [ ] Skill 在提供改造选项前检测并读取已有架构文档
- [ ] 用户被询问要更新哪个章节 — 而非被要求重写整个文档
- [ ] 仅所选章节被更新
- [ ] 在改造会话中其他章节不被修改

---

### 用例 5：总监门禁 — 架构引用了一份 Proposed 状态的 ADR；标记为风险

**夹具：**
- 正在撰写架构文档
- 某个章节引用或依赖一份 `Status: Proposed` 的 ADR
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/create-architecture`

**预期行为：**
1. Skill 撰写所有章节
2. 在撰写过程中，skill 检测到对 Proposed 状态 ADR 的引用
3. Skill 标记："注意：[章节] 引用了 ADR-NNN，该 ADR 状态为 Proposed — 在该 ADR 被接受前此为风险项"
4. 风险标记嵌入到相关章节的内容中
5. TD-ARCHITECTURE 和 LP-FEASIBILITY 仍然运行 — 它们会被告知 Proposed ADR 的风险

**断言：**
- [ ] 在章节撰写过程中检测到 Proposed ADR 引用并标记
- [ ] 风险提示嵌入到架构文档章节中
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 仍然生成（风险不阻止门禁）
- [ ] 风险标记指明具体的 ADR 编号和标题

---

## 协议合规

- [ ] 骨架文件在写入任何内容之前已创建并包含所有章节标题
- [ ] 撰写过程中逐节询问"我可以写入 [章节] 吗？"
- [ ] 在 full 模式下 TD-ARCHITECTURE 和 LP-FEASIBILITY 并行生成
- [ ] 在 lean/solo 输出中按名称和模式注明跳过的门禁
- [ ] Proposed 状态 ADR 引用在文档中标记为风险
- [ ] 以下一步交接结束：`/architecture-review` 或 `/create-control-manifest`

---

## 覆盖说明

- 架构文档的必填章节列表定义在 skill 主体和 `/architecture-review` skill 中 — 此处不再重新枚举。
- 架构文档中的引擎版本印记（与 ADR 印记并行）是撰写工作流的一部分 — 通过用例 1 隐式测试。
- 在单个会话中更新多个章节的改造模式遵循相同的逐节审批模式 — 未对多章节改造进行独立测试。
