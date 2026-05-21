<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/design-system

## Skill 摘要

`/design-system` 引导用户逐节撰写单个游戏系统的游戏设计文档（GDD）。所有 8 个必填章节必须撰写：Overview、Player Fantasy、Detailed Rules、Formulas、Edge Cases、Dependencies、Tuning Knobs 和 Acceptance Criteria。该 skill 采用骨架优先方式 — 在填充任何内容之前先创建包含全部 8 个章节标题的 GDD 文件 — 并在批准后逐个写入每个章节。

CD-GDD-ALIGN 门禁（创意总监）在 `full` 和 `lean` 两种模式下均运行。仅在 `solo` 模式下跳过。如果发现已有 GDD 文件，该 skill 提供改造模式以更新特定章节，而非重写整个文档。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 — 无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含裁决关键词：APPROVED、NEEDS REVISION、MAJOR REVISION
- [ ] 包含"我可以将此写入吗？"协作协议用语（逐节审批）
- [ ] 末尾包含下一步交接
- [ ] 记录了骨架优先方式（先创建包含标题的文件，再填充内容）
- [ ] 记录了 CD-GDD-ALIGN 门禁：在 full 和 lean 模式下均活跃；仅在 solo 模式下跳过
- [ ] 记录了对已有 GDD 文件的改造模式

---

## 总监门禁检查

在 `full` 模式下：CD-GDD-ALIGN（创意总监）门禁在每个章节起草后、写入前运行。如果返回 MAJOR REVISION，则该章节必须在继续之前重写。

在 `lean` 模式下：CD-GDD-ALIGN 仍然运行（此门禁在 lean 模式下不会被跳过 — 它在 full 和 lean 两种模式下均运行）。仅 solo 模式会跳过它。

在 `solo` 模式下：CD-GDD-ALIGN 被跳过。输出注明："CD-GDD-ALIGN 已跳过 — solo 模式"。章节仅需用户批准即可写入。

---

## 测试用例

### 用例 1：理想路径 — 新建 GDD，骨架优先，lean 模式下 CD-GDD-ALIGN 运行

**夹具：**
- `design/gdd/` 中不存在目标系统的 GDD
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/design-system [system-name]`

**预期行为：**
1. Skill 创建骨架文件 `design/gdd/[system-name].md`，包含全部 8 个章节标题（正文为空）
2. 对每个章节：与用户讨论、起草内容、展示草稿
3. CD-GDD-ALIGN 门禁对每个章节草稿运行（lean 模式 — 门禁处于活跃状态）
4. 门禁对每个章节返回 APPROVED
5. 门禁批准后询问"我可以写入 [章节] 吗？"
6. 用户批准后将章节写入文件
7. 对所有 8 个章节重复此流程

**断言：**
- [ ] 骨架文件在写入任何内容之前已创建并包含全部 8 个章节标题
- [ ] 在 lean 模式下 CD-GDD-ALIGN 对每个章节运行（未被跳过）
- [ ] 逐节询问"我可以将此写入吗？"（而非一次性批准全部）
- [ ] 每个章节在门禁和用户批准后单独写入
- [ ] 全部 8 个章节均出现在最终 GDD 文件中

---

### 用例 2：改造模式 — 已有 GDD，更新特定章节

**夹具：**
- `design/gdd/[system-name].md` 已存在且全部 8 个章节已填充

**输入：** `/design-system [system-name]`

**预期行为：**
1. Skill 检测到已有 GDD 文件并读取其当前内容
2. Skill 提供改造模式："GDD 已存在。您想更新哪个章节？"
3. 用户选择特定章节（例如 Formulas）
4. Skill 仅撰写该章节，运行 CD-GDD-ALIGN，询问"我可以将此写入吗？"
5. 仅所选章节被更新 — 其他章节不被修改

**断言：**
- [ ] Skill 在提供改造模式前检测并读取已有 GDD
- [ ] 用户被询问要更新哪个章节 — 而非被要求重写整个文档
- [ ] 仅所选章节被重写 — 其他章节保持不变
- [ ] CD-GDD-ALIGN 仍然对更新后的章节运行
- [ ] 在更新章节前询问"我可以将此写入吗？"

---

### 用例 3：总监门禁 — CD-GDD-ALIGN 返回 MAJOR REVISION

**夹具：**
- 正在撰写新建 GDD
- `production/session-state/review-mode.txt` 包含 `lean`
- CD-GDD-ALIGN 门禁对 Player Fantasy 章节返回 MAJOR REVISION

**输入：** `/design-system [system-name]`

**预期行为：**
1. Player Fantasy 章节已起草
2. CD-GDD-ALIGN 门禁运行并返回 MAJOR REVISION 及具体反馈
3. Skill 将反馈展示给用户
4. 当 MAJOR REVISION 未解决时，章节不会被写入文件
5. 用户与 skill 协作重写该章节
6. CD-GDD-ALIGN 对修订后的章节再次运行
7. 若修订后的章节通过，询问"我可以将此写入吗？"并写入章节

**断言：**
- [ ] 当 CD-GDD-ALIGN 返回 MAJOR REVISION 时，章节不会被写入
- [ ] 门禁反馈在请求修订前展示给用户
- [ ] 章节修订后 CD-GDD-ALIGN 再次运行
- [ ] 当 MAJOR REVISION 未解决时，Skill 不会自动进入下一章节

---

### 用例 4：Solo 模式 — CD-GDD-ALIGN 跳过；章节仅以用户批准写入

**夹具：**
- 正在撰写新建 GDD
- `production/session-state/review-mode.txt` 包含 `solo`

**输入：** `/design-system [system-name]`

**预期行为：**
1. 创建包含 8 个章节标题的骨架文件
2. 对每个章节：起草、展示给用户
3. CD-GDD-ALIGN 被跳过 — 逐节注明："CD-GDD-ALIGN 已跳过 — solo 模式"
4. 用户审阅草稿后询问"我可以写入 [章节] 吗？"
5. 用户批准后写入章节
6. 任何阶段均无门禁审查

**断言：**
- [ ] 每个章节均注明"CD-GDD-ALIGN 已跳过 — solo 模式"
- [ ] 章节仅凭用户批准写入（无需门禁）
- [ ] 在 solo 模式下 Skill 不会生成任何 CD-GDD-ALIGN 门禁
- [ ] 在 solo 模式下完整 GDD 仅以用户批准写入

---

### 用例 5：总监门禁 — 空章节不写入文件

**夹具：**
- GDD 撰写正在进行中
- 用户与 skill 讨论了某个章节但未产出任何批准的内容（例如讨论未达成决策，或用户说"暂时跳过"）

**输入：** `/design-system [system-name]`

**预期行为：**
1. 章节讨论未产出批准的内容
2. Skill 不会向该章节写入空内容或占位符正文
3. 章节标题保留在骨架文件中，但正文保持为空
4. Skill 移至下一个章节而不写入空的章节
5. 在结束时，列出未完成的章节并提醒用户返回处理

**断言：**
- [ ] 空章节或未批准的章节不会被写入文件
- [ ] 骨架章节标题保留（保留结构）
- [ ] Skill 在会话结束时追踪并列出未完成的章节
- [ ] Skill 不会在未经用户批准的情况下写入"TBD"或占位符内容

---

## 协议合规

- [ ] 骨架文件在写入任何内容之前已创建并包含全部 8 个标题
- [ ] CD-GDD-ALIGN 在 full 和 lean 两种模式下均运行（而非仅 full）
- [ ] CD-GDD-ALIGN 仅在 solo 模式下跳过 — 逐节注明
- [ ] 逐节询问"我可以写入 [章节] 吗？"（而非一次性批准整个文档）
- [ ] 来自 CD-GDD-ALIGN 的 MAJOR REVISION 会阻止章节写入，直至问题解决
- [ ] 仅批准后的非空章节被写入文件
- [ ] 以下一步交接结束：`/review-all-gdds` 或 `/map-systems next`

---

## 覆盖说明

- 8 个必填章节根据 `CLAUDE.md` 中定义的项目设计文档标准进行验证 — 此处不再重新枚举。
- 该 skill 的内部章节排序逻辑（先撰写哪个章节）未独立测试 — 顺序遵循标准 GDD 模板。
- CD-GDD-ALIGN 中的支柱对齐检查由门禁 Agent 整体评估 — 具体的支柱检查不在此进行夹具测试。
