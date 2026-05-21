<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/soak-test

## Skill 摘要

`/soak-test` 生成结构化的浸泡测试协议——一种扩展运行时测试计划，旨在发现内存泄漏、性能漂移和仅在持续游戏过程中才会出现的稳定性问题。该 skill 生成的文档指定了测试时长、被测系统、监控检查点（例如，每 30 分钟取样内存）、通过/失败阈值以及提前终止条件。

该 skill 在持久化前询问 "May I write to `production/qa/soak-[slug]-[date].md`?"。如果同一系统的先前浸泡测试已存在，该 skill 会提供延长时长或添加新条件的选项。不适用 director gate。浸泡测试协议写入后判决为 COMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：COMPLETE
- [ ] 在写入协议前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，`/regression-suite` 或 `/release-checklist`）

---

## Director Gate 检查

无。`/soak-test` 是一个 QA 计划工具。不适用 director gate。

---

## 测试用例

### 用例 1：Happy Path — 在线游戏功能，2 小时浸泡协议

**Fixture：**
- 用户指定：system = "online multiplayer lobby"，duration = "2 hours"
- `technical-preferences.md` 已配置引擎

**输入：** `/soak-test online-lobby 2h`

**预期行为：**
1. Skill 为在线大厅系统生成 2 小时浸泡测试协议
2. 协议包含：每 30 分钟监控检查点、需跟踪的指标（内存使用、连接数、丢包率）、通过阈值、提前终止条件（崩溃或内存增长 >20%）
3. 包含网络特定检查（会话断开率、重连处理）
4. Skill 询问 "May I write to `production/qa/soak-online-lobby-2026-04-06.md`?"
5. 批准后写入文件；判决为 COMPLETE

**断言：**
- [ ] 协议时长符合请求的 2 小时
- [ ] 监控检查点间隔合理（例如每 30 分钟）
- [ ] 包含网络特定检查（不仅是通用内存检查）
- [ ] "May I write" 以正确的文件路径询问
- [ ] 判决为 COMPLETE

---

### 用例 2：未指定目标 — 提示填写系统、时长和条件

**Fixture：**
- 未提供参数
- 会话状态中无浸泡测试配置

**输入：** `/soak-test`

**预期行为：**
1. Skill 检测到未指定目标系统或时长
2. Skill 询问："What system or feature should be soak-tested?"
3. 用户回复系统后：Skill 询问："What duration? (e.g., 1h, 4h, 8h)"
4. 用户回复时长后：Skill 询问特定条件或使用默认值（正常游戏循环、默认玩家数）
5. Skill 根据收集的输入生成协议并询问 "May I write"

**断言：**
- [ ] 至少提出 2 个后续问题（系统 + 时长）
- [ ] 用户未指定自定义条件时应用默认条件
- [ ] 在系统及时长确定之前不生成协议
- [ ] 文件写入后判决为 COMPLETE

---

### 用例 3：先前浸泡测试存在 — 提供延长或添加条件选项

**Fixture：**
- `production/qa/soak-online-lobby-2026-03-15.md` 存在，包含 1 小时协议
- 用户希望延长至 4 小时并添加新的内存阈值条件

**输入：** `/soak-test online-lobby 4h`

**预期行为：**
1. Skill 找到 online-lobby 的现有浸泡测试
2. Skill 报告："Previous soak test found: soak-online-lobby-2026-03-15.md (1h)"
3. Skill 展示选项：创建新协议（4h 独立）或延长现有协议至 4h 并添加新条件
4. 用户选择延长；现有检查点保留，新增的加入
5. Skill 询问 "May I write to `production/qa/soak-online-lobby-2026-04-06.md`?"（新文件，不覆盖旧文件）

**断言：**
- [ ] 展示并引用现有浸泡测试
- [ ] 向用户提供延长 vs. 新建选项
- [ ] 创建新文件（不覆盖旧文件）
- [ ] 延长后的协议包含新旧检查点
- [ ] 判决为 COMPLETE

---

### 用例 4：移动端目标平台 — 添加内存特定检查点

**Fixture：**
- `technical-preferences.md` 指定目标平台：Mobile
- 用户请求对 "gameplay session" 进行 30 分钟浸泡测试

**输入：** `/soak-test gameplay 30m`

**预期行为：**
1. Skill 读取 `technical-preferences.md` 并检测到移动端目标平台
2. 浸泡测试协议包含移动端特定的内存检查点：
   - 检查堆内存增长 vs. 设备基线
   - 在检查点间隔检查纹理内存
   - 添加 300MB 警告阈值（移动端上限）
3. 协议还包含热管理/电池消耗建议说明
4. Skill 询问 "May I write?"，批准后写入；判决为 COMPLETE

**断言：**
- [ ] 从 technical-preferences.md 检测到移动端平台
- [ ] 内存检查点包含移动端适用的阈值（非桌面端）
- [ ] 协议中存在热管理/电池说明
- [ ] 判决为 COMPLETE

---

### 用例 5：Director Gate 检查 — 无 gate；soak-test 是一个计划工具

**Fixture：**
- 提供有效的系统和时长

**输入：** `/soak-test combat 1h`

**预期行为：**
1. Skill 生成并写入浸泡测试协议
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] Skill 在无任何 gate 检查的情况下达到 COMPLETE

---

## 协议合规性

- [ ] 在生成协议前收集系统、时长和条件
- [ ] 包含定期监控检查点
- [ ] 包含通过/失败阈值和提前终止条件
- [ ] 根据目标平台调整检查点（移动端 vs. 桌面端）
- [ ] 创建协议文件前询问 "May I write"
- [ ] 文件写入后判决为 COMPLETE

---

## 覆盖说明

- 针对特定引擎子系统（渲染管线、物理模拟）的浸泡测试遵循相同的协议结构，不单独测试。
- 用户提供的时长短于最小有用浸泡周期（例如 5 分钟）的情况不测试；skill 会注明这对于有意义的结果来说太短。
- 浸泡测试协议的自动执行超出此 skill 的范围——此 skill 生成计划，而非运行器。
