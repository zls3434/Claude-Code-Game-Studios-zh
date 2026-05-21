<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/bug-triage

## Skill 摘要

`/bug-triage` 读取 `production/bugs/` 中的所有开放 bug 报告，并按严重程度排序生成优先级分类表（CRITICAL → HIGH → MEDIUM → LOW）。它在 Haiku 模型上运行（只读、格式化/排序任务），不产生文件写入——分类输出为对话形式。该 skill 标记缺少重现步骤的 bug，并通过对比标题和受影响的系统来识别可能的重复项。

判决始终为 TRIAGED——该 skill 是建议性的、信息性的。不适用 director gate。输出旨在帮助制作人或 QA 负责人确定接下来要处理哪些 bug。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：TRIAGED
- [ ] 不包含 "May I write" 语言（skill 是只读的）
- [ ] 有下一步交接（例如，`/bug-report` 创建新报告，`/hotfix` 用于严重 bug）

---

## Director Gate 检查

无。`/bug-triage` 是一个只读建议 skill。不适用 director gate。

---

## 测试用例

### 用例 1：Happy Path — 5 个不同严重程度的 bug，生成排序表

**Fixture：**
- `production/bugs/` 包含 5 个 bug 报告文件：
  - bug-2026-03-10-audio-crash.md（CRITICAL）
  - bug-2026-03-12-score-overflow.md（HIGH）
  - bug-2026-03-14-ui-overlap.md（MEDIUM）
  - bug-2026-03-15-typo-tutorial.md（LOW）
  - bug-2026-03-16-vfx-flicker.md（HIGH）

**输入：** `/bug-triage`

**预期行为：**
1. Skill 读取所有 5 个 bug 报告文件
2. Skill 从每个文件中提取严重程度、标题、系统和重现状态
3. Skill 生成分类表，排序为：CRITICAL 优先，然后 HIGH、MEDIUM、LOW
4. 相同严重程度内，bug 按日期排序（最早优先）
5. 判决为 TRIAGED

**断言：**
- [ ] 分类表恰好有 5 行
- [ ] CRITICAL bug 出现在两个 HIGH bug 之前
- [ ] HIGH bug 出现在 MEDIUM 和 LOW bug 之前
- [ ] 判决为 TRIAGED
- [ ] 没有文件被写入

---

### 用例 2：无 Bug 报告 — 引导运行 /bug-report

**Fixture：**
- `production/bugs/` 目录存在但为空（或不存在）

**输入：** `/bug-triage`

**预期行为：**
1. Skill 扫描 `production/bugs/` 未发现报告
2. Skill 输出："No open bug reports found in production/bugs/"
3. Skill 建议运行 `/bug-report` 创建 bug 报告
4. 不生成分类表

**断言：**
- [ ] 输出明确说明未发现 bug
- [ ] 建议 `/bug-report` 作为下一步
- [ ] Skill 不出错 — 优雅处理空目录
- [ ] 判决为 TRIAGED（附 "no bugs found" 上下文）

---

### 用例 3：Bug 缺少重现步骤 — 标记为 NEEDS REPRO INFO

**Fixture：**
- `production/bugs/` 包含 3 个 bug 报告；其中一个 "Repro Steps" section 为空

**输入：** `/bug-triage`

**预期行为：**
1. Skill 读取所有 3 个报告
2. Skill 检测到无重现步骤的报告
3. 该 bug 在分类表中带 `NEEDS REPRO INFO` 标签出现
4. 其他 bug 正常分类
5. 判决为 TRIAGED

**断言：**
- [ ] `NEEDS REPRO INFO` 标签出现在缺失重现步骤的 bug 旁边
- [ ] 被标记的 bug 仍包含在表中（不被排除）
- [ ] 其他 bug 不受影响
- [ ] 判决为 TRIAGED

---

### 用例 4：可能重复的 Bug — 在分类输出中标记

**Fixture：**
- `production/bugs/` 包含 2 个标题相似的 bug 报告：
  - bug-2026-03-18-player-fall-through-floor.md
  - bug-2026-03-20-player-clips-through-floor.md
  - 两者都影响 "Physics" 系统，严重程度相同

**输入：** `/bug-triage`

**预期行为：**
1. Skill 读取两个报告，检测到相似标题 + 相同系统 + 相同严重程度
2. 两个 bug 均包含在分类表中
3. 每个均标记为 `POSSIBLE DUPLICATE` 并交叉引用另一个报告
4. 不合并或删除 bug — 标记仅为建议性
5. 判决为 TRIAGED

**断言：**
- [ ] 两个 bug 均出现在表中（不合并）
- [ ] 两者均标记为 `POSSIBLE DUPLICATE`
- [ ] 每个均交叉引用另一个（通过文件名或标题）
- [ ] 判决为 TRIAGED

---

### 用例 5：Director Gate 检查 — 无 gate；分类是建议性的

**Fixture：**
- `production/bugs/` 包含任意数量的报告

**输入：** `/bug-triage`

**预期行为：**
1. Skill 生成分类表
2. 不生成任何 director agent
3. 输出中不出现 gate ID
4. 不调用写入工具

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不调用写入工具
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 TRIAGED，无任何 gate 检查

---

## 协议合规性

- [ ] 在生成表格前读取 `production/bugs/` 中的所有文件
- [ ] 按严重程度排序（CRITICAL → HIGH → MEDIUM → LOW）
- [ ] 标记缺少重现步骤的 bug
- [ ] 通过标题/系统相似性标记可能的重复项
- [ ] 不写入任何文件
- [ ] 所有情况下判决均为 TRIAGED（即使为空）

---

## 覆盖说明

- 格式错误的 bug 报告（完全缺少严重程度字段）不进行 fixture 测试；skill 会将其标记为 `UNKNOWN SEVERITY` 并排在表末。
- 状态转换（将 bug 标记为已解决）超出此 skill 的范围 — bug-triage 是只读的。
- 重复检测启发式方法（标题相似性 + 相同系统）是近似值；精确匹配逻辑在 skill 正文中定义。
