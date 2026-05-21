<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/art-bible

## Skill 摘要

`/art-bible` 是一个引导式的、逐节撰写的美术圣经创作 skill。它产出一份全面的视觉方向文档，涵盖：Visual Style 概述、Color Palette、Typography、Character Design Rules、Environment Style 和 UI Visual Language。该 skill 遵循骨架优先模式：立即创建包含所有章节标题的文件，然后通过讨论逐一填充每个章节，并在用户批准后将每个章节写入磁盘。

在 `full` 审查模式下，AD-ART-BIBLE 总监门禁（美术总监）在草稿完成后、任何章节写入前运行。在 `lean` 和 `solo` 模式下，AD-ART-BIBLE 被跳过，仅需用户批准。当所有章节写入后，裁决为 COMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 — 无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含逐节的"我可以将此写入吗？"用语
- [ ] 记录了 AD-ART-BIBLE 总监门禁及其模式行为
- [ ] 包含下一步交接（如 `/asset-spec` 或 `/design-system`）

---

## 总监门禁检查

| 门禁 ID      | 触发条件                      | 模式守卫              |
|--------------|-------------------------------|-----------------------|
| AD-ART-BIBLE | 草稿完成后                    | 仅 full 模式（非 lean/solo） |

---

## 测试用例

### 用例 1：理想路径 — Full 模式，美术圣经草稿完成，AD-ART-BIBLE 审批通过

**夹具：**
- 不存在 `design/art-bible.md`
- `production/session-state/review-mode.txt` 包含 `full`
- `design/gdd/game-concept.md` 存在且描述了视觉基调

**输入：** `/art-bible`

**预期行为：**
1. Skill 创建骨架文件 `design/art-bible.md`，包含所有章节标题
2. Skill 与用户协作讨论并起草每个章节
3. 所有章节起草完成后，调用 AD-ART-BIBLE 门禁（美术总监审查）
4. AD-ART-BIBLE 返回 APPROVED
5. Skill 逐节询问"我可以将第 [N] 节写入 `design/art-bible.md` 吗？"
6. 所有章节在批准后写入；裁决为 COMPLETE

**断言：**
- [ ] 骨架文件最先创建（在任何章节内容写入之前）
- [ ] 在 full 模式下，AD-ART-BIBLE 门禁在草稿完成后调用
- [ ] 门禁批准先于逐节的"我可以将此写入吗？"询问
- [ ] 所有章节均出现在最终文件中
- [ ] 裁决为 COMPLETE

---

### 用例 2：AD-ART-BIBLE 返回 CONCERNS — 写入前修订相关章节

**夹具：**
- 美术圣经草稿已完成
- `production/session-state/review-mode.txt` 包含 `full`
- AD-ART-BIBLE 门禁返回 CONCERNS："调色板与游戏概念中描述的暗黑氛围基调冲突"

**输入：** `/art-bible`

**预期行为：**
1. AD-ART-BIBLE 门禁返回 CONCERNS 及关于调色板的具体反馈
2. Skill 将反馈展示给用户："美术总监对调色板有顾虑"
3. Skill 返回 Color Palette 章节进行修订
4. 用户与 skill 修订调色板以符合游戏概念基调
5. AD-ART-BIBLE 不会被重新调用（用户决定修订后继续）
6. 修订后的章节在"我可以将此写入吗？"批准后写入；裁决为 COMPLETE

**断言：**
- [ ] CONCERNS 在任何章节写入前展示给用户
- [ ] Skill 返回受影响的章节进行修订（而非所有章节）
- [ ] 修订后的内容（而非原始内容）被写入文件
- [ ] 裁决在修订和批准后为 COMPLETE

---

### 用例 3：Lean 模式 — AD-ART-BIBLE 跳过，仅以用户批准写入

**夹具：**
- 不存在美术圣经
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/art-bible`

**预期行为：**
1. Skill 读取审查模式 — 确定为 `lean`
2. Skill 与用户协作起草所有章节
3. AD-ART-BIBLE 门禁被跳过：输出注明"[AD-ART-BIBLE] 已跳过 — lean 模式"
4. Skill 逐节请求用户直接批准
5. 章节在用户确认后写入；裁决为 COMPLETE

**断言：**
- [ ] 在 lean 模式下不会调用 AD-ART-BIBLE 门禁
- [ ] 跳过被明确注明："[AD-ART-BIBLE] 已跳过 — lean 模式"
- [ ] 仍需逐节获得用户批准（门禁跳过 ≠ 批准跳过）
- [ ] 裁决为 COMPLETE

---

### 用例 4：已有美术圣经 — 改造模式

**夹具：**
- `design/art-bible.md` 已存在且所有章节已填充
- 用户想要更新 Character Design Rules 章节

**输入：** `/art-bible`

**预期行为：**
1. Skill 读取现有美术圣经并检测所有章节已填充
2. Skill 提供改造选项："美术圣经已存在 — 您想更新哪个章节？"
3. 用户选择 Character Design Rules
4. Skill 起草更新内容；在 full 模式下，AD-ART-BIBLE 在写入前对修订章节进行调用
5. Skill 询问"我可以将 Character Design Rules 写入 `design/art-bible.md` 吗？"
6. 仅该章节被更新；其他章节保持不变；裁决为 COMPLETE

**断言：**
- [ ] 检测到现有美术圣经并提供改造选项
- [ ] 仅所选章节被更新
- [ ] 在 full 模式下：即使仅改造单个章节，AD-ART-BIBLE 门禁仍运行
- [ ] 其他章节保持不变
- [ ] 裁决为 COMPLETE

---

### 用例 5：Solo 模式 — AD-ART-BIBLE 跳过，输出中注明

**夹具：**
- 不存在美术圣经
- `production/session-state/review-mode.txt` 包含 `solo`

**输入：** `/art-bible`

**预期行为：**
1. Skill 读取审查模式 — 确定为 `solo`
2. 美术圣经在仅用户批准下起草并写入
3. AD-ART-BIBLE 门禁被跳过：输出注明"[AD-ART-BIBLE] 已跳过 — solo 模式"
4. 不会生成任何总监 Agent
5. 裁决为 COMPLETE

**断言：**
- [ ] 在 solo 模式下不会调用 AD-ART-BIBLE 门禁
- [ ] 跳过被明确注明，带有"solo 模式"标签
- [ ] 不会生成任何类型的总监 Agent
- [ ] 裁决为 COMPLETE

---

## 协议合规

- [ ] 立即创建骨架文件，包含所有章节标题
- [ ] 每次讨论并起草一个章节
- [ ] 在 full 模式下所有章节起草完成后运行 AD-ART-BIBLE 门禁
- [ ] 在 lean 和 solo 模式下跳过 AD-ART-BIBLE — 按名称注明
- [ ] 逐节询问"我可以将第 [N] 节写入吗？"
- [ ] 当所有章节写入后，裁决为 COMPLETE

---

## 覆盖说明

- AD-ART-BIBLE 返回 REJECT（而非仅 CONCERNS）的情况未单独测试；此时 skill 会阻止写入并询问用户如何处理（修订或覆盖）。
- Typography 章节被列为美术圣经必填章节，但其具体内容要求未在此进行断言测试。
- 美术圣经将输入到 `/asset-spec` — 此关系在交接中注明，但不作为本 skill 规格的测试内容。
