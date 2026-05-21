<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/day-one-patch

## Skill 摘要

`/day-one-patch` 为发布时已知但已从 v1.0 版本推迟的问题准备首日补丁计划。它读取 `production/bugs/` 中的开放 bug 报告、故事文件中被推迟的验收标准（标记为 `Status: Done` 但带有被推迟的 AC 备注），并生成按优先级排序的补丁计划，附每个问题的估计修复时间线。

补丁计划在经过 "May I write" 询问后写入 `production/releases/day-one-patch.md`。如果发现 P0（发布后严重）问题，skill 会触发引导运行 `/hotfix` 先于补丁。不适用 director gate。判决始终为 COMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：COMPLETE
- [ ] 在写入计划前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，`/hotfix` 用于 P0 问题，`/release-checklist` 用于后续跟踪）

---

## Director Gate 检查

无。`/day-one-patch` 是一个发布计划工具。不适用 director gate。

---

## 测试用例

### 用例 1：Happy Path — 3 个已知问题，补丁计划附修复评估

**Fixture：**
- `production/bugs/` 包含 3 个开放 bug，严重程度：1 MEDIUM、2 LOW
- 冲刺故事中没有被推迟的 AC
- 所有 bug 都有重现步骤和系统标识

**输入：** `/day-one-patch`

**预期行为：**
1. Skill 读取所有 3 个开放 bug
2. Skill 分配修复工作量估计：MEDIUM bug = 1-2 天，LOW bugs = 各 4 小时
3. Skill 生成补丁计划，优先处理 MEDIUM bug
4. 计划包含：优先级顺序、估计时间线、负责系统、修复描述
5. Skill 询问 "May I write to `production/releases/day-one-patch.md`?"
6. 文件写入；判决为 COMPLETE

**断言：**
- [ ] 计划中包含全部 3 个 bug
- [ ] Bug 按严重程度排序（MEDIUM 优先于 LOW）
- [ ] 每个问题均提供修复评估
- [ ] 写入前询问 "May I write"
- [ ] 判决为 COMPLETE

---

### 用例 2：发布后发现严重问题 — P0，触发 /hotfix 引导

**Fixture：**
- v1.0 发布后，`production/bugs/` 中发现一个 CRITICAL 严重程度的 bug
- 该 bug 导致所有存档文件数据丢失

**输入：** `/day-one-patch`

**预期行为：**
1. Skill 读取 bug 并识别出 CRITICAL 严重程度的问题
2. Skill 升级："P0 ISSUE DETECTED — data loss bug requires immediate hotfix before patch planning can proceed"
3. Skill 不将 P0 问题纳入补丁计划时间线
4. Skill 明确指示："Run `/hotfix` to resolve this issue first"
5. 发出 P0 引导后：仍为其余较低严重程度的 bug 生成并写入计划；判决为 COMPLETE

**断言：**
- [ ] P0 升级消息在补丁计划之前显著显示
- [ ] 对 P0 问题明确指示 `/hotfix`
- [ ] P0 问题未安排在补丁计划时间线中（需要立即行动）
- [ ] 非 P0 问题仍有计划；判决为 COMPLETE

---

### 用例 3：故事完成时推迟的 AC — 自动纳入补丁计划

**Fixture：**
- `production/sprints/sprint-008.md` 中有一个 `Status: Done` 的故事，附备注："DEFERRED AC: Gamepad vibration on damage — deferred to post-launch patch"
- 相同系统无开放 bug

**输入：** `/day-one-patch`

**预期行为：**
1. Skill 读取冲刺故事并检测到推迟的 AC 备注
2. 推迟的 AC 作为工作项自动纳入补丁计划
3. 计划条目："Deferred from sprint-008: Gamepad vibration on damage"
4. 分配修复评估；经 "May I write" 批准后写入补丁计划
5. 判决为 COMPLETE

**断言：**
- [ ] 故事文件中推迟的 AC 自动纳入计划
- [ ] 推迟项标记来源故事（sprint-008）
- [ ] 推迟的 AC 像 bug 条目一样获得修复评估
- [ ] 判决为 COMPLETE

---

### 用例 4：无已知问题 — 空计划附模板说明

**Fixture：**
- `production/bugs/` 为空
- 没有故事有推迟的 AC

**输入：** `/day-one-patch`

**预期行为：**
1. Skill 读取 bug — 未找到
2. Skill 读取故事推迟的 AC — 未找到
3. Skill 生成空补丁计划，附说明："No known issues at launch"
4. 模板结构保留（标题完好）供将来使用
5. Skill 询问 "May I write to `production/releases/day-one-patch.md`?"
6. 文件写入；判决为 COMPLETE

**断言：**
- [ ] 写入的文件中出现 "No known issues at launch" 说明
- [ ] 空计划中存在模板标题
- [ ] 无问题需要计划时 skill 不出错
- [ ] 判决为 COMPLETE

---

### 用例 5：Director Gate 检查 — 无 gate；day-one-patch 是一个计划工具

**Fixture：**
- production/bugs/ 中存在已知问题

**输入：** `/day-one-patch`

**预期行为：**
1. Skill 生成并写入补丁计划
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 COMPLETE，无任何 gate 检查

---

## 协议合规性

- [ ] 在生成计划前读取 `production/bugs/` 中的开放 bug
- [ ] 扫描故事文件中的推迟的 AC 备注
- [ ] 对 CRITICAL（P0）bug 升级并明确指示 `/hotfix`
- [ ] 无问题时生成空计划附说明（不出错）
- [ ] 写入前询问 "May I write to `production/releases/day-one-patch.md`?"
- [ ] 所有路径下判决均为 COMPLETE

---

## 覆盖说明

- 多个 CRITICAL bug 存在的情况与用例 2 相同处理；所有 P0 问题一并升级。
- 补丁的时间线估计（例如，"patch available in 3 days"）需要手动 QA 和构建时间估计；skill 使用基于严重程度的粗略估计，而非实际团队速度。
- 补丁说明玩家沟通文档（`/patch-notes`）是补丁计划执行后调用的独立 skill。
