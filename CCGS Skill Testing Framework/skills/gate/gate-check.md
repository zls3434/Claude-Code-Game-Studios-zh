<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/gate-check

## Skill 概要

`/gate-check` 验证项目是否准备好进入下一个开发阶段。它检查必需的产物、运行质量检查、向用户询问无法自动验证的项目，并生成 PASS/CONCERNS/FAIL 判定。当判定为 PASS 且获得用户确认后，它将新阶段名称写入 `production/stage.txt`。它管理全部6个阶段转换，是流水线中最关键的守门 skill。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题（编号为 Phase N 或 ## 章节）
- [ ] 包含判定关键词：PASS、CONCERNS、FAIL
- [ ] 包含"我可以写入"协作协议用语
- [ ] 末尾有下一步交接（后续操作章节）

---

## 测试用例

### 用例1：Happy Path — 所有 Concept 产物均已就位，进入 Systems Design 阶段

**Fixture：**
- `design/gdd/game-concept.md` 存在，内容包含所有必需章节
- `design/gdd/game-pillars.md` 存在（或游戏支柱在概念文档中已定义）
- 尚无系统索引（该阶段正确状态）

**输入：** `/gate-check systems-design`

**预期行为：**
1. Skill 读取 `design/gdd/game-concept.md` 并验证其包含内容
2. Skill 检查游戏支柱（在概念文档中或单独文件中）
3. Skill 检查质量项（核心循环已描述、目标受众已确定）
4. Skill 输出结构化检查清单，所有项目均已标记
5. Skill 给出 PASS/CONCERNS/FAIL 判定
6. 若 PASS：skill 询问"我可以将 `production/stage.txt` 更新为 'Systems Design' 吗？"

**断言：**
- [ ] Skill 使用 Glob 或 Read 验证 `design/gdd/game-concept.md` 存在再标记为已检查
- [ ] 输出包含"必需产物"章节，逐项显示检查状态
- [ ] 输出包含"质量检查"章节，逐项显示检查状态
- [ ] 输出包含"判定"行，值为 PASS / CONCERNS / FAIL 之一
- [ ] Skill 对无法自动验证的质量项（如"此项是否已评审？"），采用向用户提问方式而非假定 PASS
- [ ] Skill 在更新 `production/stage.txt` 前询问"我可以写入"
- [ ] Skill 未经用户明确确认不写入 `production/stage.txt`

---

### 用例2：失败路径 — Concept → Systems Design 所需产物缺失

**Fixture：**
- `design/gdd/game-concept.md` 不存在
- 无游戏支柱文档
- `design/gdd/` 目录为空或不存在

**输入：** `/gate-check systems-design`

**预期行为：**
1. Skill 尝试读取 `design/gdd/game-concept.md` — 文件未找到
2. Skill 将必需产物标记为缺失（不存在）
3. Skill 输出 FAIL 判定
4. Skill 列出阻塞项："未找到游戏概念文档"
5. Skill 建议补救措施：运行 `/brainstorm` 创建一个

**断言：**
- [ ] 当必需产物缺失时，判定为 FAIL（而非 PASS 或 CONCERNS）
- [ ] 输出明确指明 `design/gdd/game-concept.md` 缺失
- [ ] 输出包含"阻塞项"章节，至少1项
- [ ] 输出建议 `/brainstorm` 作为补救操作
- [ ] 当判定为 FAIL 时，Skill 不写入 `production/stage.txt`

---

### 用例3：无参数 — 自动检测当前阶段

**Fixture：**
- `production/stage.txt` 内容为 `Concept`
- `design/gdd/game-concept.md` 存在且有内容
- 尚无系统索引

**输入：** `/gate-check`（无参数）

**预期行为：**
1. Skill 读取 `production/stage.txt` 确定当前阶段
2. Skill 确定下一个关卡是 Concept → Systems Design
3. Skill 继续进行 Systems Design 关卡检查
4. 输出明确指出正在验证哪个阶段转换

**断言：**
- [ ] Skill 读取 `production/stage.txt`（或使用 project-stage-detect 启发式方法）确定当前阶段
- [ ] 输出头部同时列出当前和目标阶段（例如"关卡检查：Concept → Systems Design"）
- [ ] 若可确定当前阶段，Skill 不询问用户要检查哪个关卡

---

### 用例4：边界情况 — 人工检查项正确标记

**Fixture：**
- Concept → Systems Design 所需的所有产物均已就位
- 不存在试玩或评审记录（无法自动验证质量检查）

**输入：** `/gate-check systems-design`

**预期行为：**
1. Skill 验证所有产物文件存在
2. Skill 遇到质量检查项："游戏概念已评审（非 MAJOR REVISION NEEDED）"
3. 由于不存在评审记录，Skill 将该项标记为 MANUAL CHECK NEEDED
4. Skill 询问用户："游戏概念的设计质量是否已经过评审？"
5. Skill 等待用户输入后再最终确定判定

**断言：**
- [ ] 无法自动验证的项目标记为 `[?] MANUAL CHECK NEEDED`，而非假定 PASS
- [ ] Skill 对至少一个无法验证的质量项向用户提问
- [ ] Skill 不默认将无法验证的项目标记为 PASS

---

---

### 用例5：Director Gate — lean vs full vs solo 模式

**Fixture：**
- `production/session-state/review-mode.txt` 存在（或等效状态文件）
- 目标关卡的所有必需产物均已就位
- `design/gdd/game-concept.md` 存在

**用例5a — full 模式：**
- `review-mode.txt` 内容为 `full`

**输入：** `/gate-check systems-design`（full 模式激活）

**预期行为：**
1. Skill 读取 review mode — 确定为 `full`
2. Skill 并行启动全部4个 PHASE-GATE director 提示：
   - CD-PHASE-GATE（创意总监）
   - TD-PHASE-GATE（技术总监）
   - PR-PHASE-GATE（制作人）
   - AD-PHASE-GATE（美术总监）
3. 若任一 director 返回 CONCERNS → 整体关卡判定至少为 CONCERNS
4. 收集全部4个判定后再生成最终输出

**断言（5a）：**
- [ ] Skill 在决定启动哪些 director 之前读取 review-mode
- [ ] 全部4个 PHASE-GATE director 提示均被启动（非仅1或2个）
- [ ] Director 并行启动（同时执行，非顺序执行）
- [ ] 任一 director 的 CONCERNS 判定会传递到整体判定
- [ ] 若任一 director 返回 CONCERNS 或 REJECT，判定不会自动为 PASS

**用例5b — solo 模式：**
- `review-mode.txt` 内容为 `solo`

**输入：** `/gate-check systems-design`（solo 模式激活）

**预期行为：**
1. Skill 读取 review mode — 确定为 `solo`
2. 每个 director 均标注为跳过："[CD-PHASE-GATE] 已跳过 — Solo 模式"
3. 关卡判定仅基于产物/质量检查得出
4. 不启动任何 director gate

**断言（5b）：**
- [ ] solo 模式下不启动任何 director gate
- [ ] 每个跳过的 gate 在输出中明确标注："[GATE-ID] 已跳过 — Solo 模式"
- [ ] 判定仅基于产物和质量检查

**关于用例3的修正说明：**
用例3的断言中此前指出"若可确定当前阶段，Skill 不询问用户要检查哪个关卡。"这是正确的。然而，Skill 确实会使用 AskUserQuestion 在执行完整检查之前确认自动检测到的阶段转换 — 这是一个确认步骤，而非关卡选择。用例3的断言不应将此确认视为失败。

---

## 协议合规

- [ ] 在更新 `production/stage.txt` 前使用"我可以写入"
- [ ] 在请求写入批准前展示完整的检查清单报告
- [ ] 末尾包含"后续操作"章节，按判定列出下一步
- [ ] 未经用户明确确认绝不推进阶段
- [ ] 若 `production/stage.txt` 不存在，未经询问绝不自动创建

---

## 覆盖范围说明

- Production → Polish 和 Polish → Release 关卡未在此覆盖，因它们需要复杂的多产物设置（sprint 计划、试玩数据、QA 签字确认）；这些将推迟到后续专门的规范中。
- "CONCERNS"判定路径（轻微差距，非阻塞性）未在此显式测试；它介于用例1和用例2之间，遵循相同模式。
- 垂直切片验证块（Pre-Production → Production 关卡）未覆盖，因为它需要可运行的构建上下文，无法用文档 fixture 表达。
