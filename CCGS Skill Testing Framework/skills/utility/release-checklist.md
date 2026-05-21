<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/release-checklist

## Skill 摘要

`/release-checklist` 生成内部发布就绪检查清单，涵盖：冲刺故事完成情况、开放 bug 严重程度、QA 签字状态、构建稳定性和变更日志就绪性。它是一个内部关卡——不是平台/商店检查清单（那是 `/launch-checklist`）。当之前的发布检查清单存在时，它显示已解决的问题和新引入的问题的差异。

该 skill 在经过 "May I write" 询问后将其检查清单报告写入 `production/releases/release-checklist-[date].md`。不适用 director gate — `/gate-check` 处理正式的阶段 gate 逻辑。判决：RELEASE READY、RELEASE BLOCKED 或 CONCERNS。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：RELEASE READY、RELEASE BLOCKED、CONCERNS
- [ ] 在写入报告前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，`/launch-checklist` 用于外部或 `/gate-check` 用于阶段）

---

## Director Gate 检查

无。`/release-checklist` 是一个内部审核工具。正式的阶段推进由 `/gate-check` 管理。

---

## 测试用例

### 用例 1：Happy Path — 所有冲刺故事完成，QA 通过，RELEASE READY

**Fixture：**
- `production/sprints/sprint-008.md` — 所有故事均为 `Status: Done`
- `production/bugs/` 中无 HIGH 或 CRITICAL 严重程度的开放 bug
- `production/qa/qa-plan-sprint-008.md` 有 QA 签字注释
- 此版本的变更日志条目存在
- `production/stage.txt` 包含 `Polish`

**输入：** `/release-checklist`

**预期行为：**
1. Skill 读取 sprint-008：所有故事 Done
2. Skill 读取 bugs：无 HIGH 或 CRITICAL 开放 bug
3. Skill 确认 QA 计划有签字
4. Skill 确认变更日志条目存在
5. 所有检查通过；skill 询问 "May I write to `production/releases/release-checklist-2026-04-06.md`?"
6. 写入报告；判决为 RELEASE READY

**断言：**
- [ ] 评估了所有 4 个检查类别（stories、bugs、QA、changelog）
- [ ] 所有项以 PASS 标记出现
- [ ] 判决为 RELEASE READY
- [ ] 写入前询问 "May I write"

---

### 用例 2：存在开放的 HIGH 严重程度 Bug — RELEASE BLOCKED

**Fixture：**
- 所有冲刺故事 Done
- `production/bugs/` 包含 2 个 HIGH 严重程度的开放 bug

**输入：** `/release-checklist`

**预期行为：**
1. Skill 读取冲刺 — 故事完成
2. Skill 读取 bugs — 2 个 HIGH 严重程度 bug 开放
3. Skill 报告："RELEASE BLOCKED — 2 open HIGH severity bugs must be resolved"
4. 报告中列出两个 bug 文件名
5. 判决为 RELEASE BLOCKED

**断言：**
- [ ] 判决为 RELEASE BLOCKED（非 CONCERNS）
- [ ] 两个 bug 文件名被明确列出
- [ ] Skill 明确说明 HIGH 严重程度 bug 是阻塞性的（非建议性）

---

### 用例 3：变更日志未生成 — CONCERNS

**Fixture：**
- 所有故事 Done，无 HIGH/CRITICAL bug
- 当前版本/冲刺未找到变更日志条目

**输入：** `/release-checklist`

**预期行为：**
1. Skill 检查所有项
2. 变更日志检查失败：未找到变更日志条目
3. Skill 报告："CONCERNS — Changelog not generated for this release"
4. Skill 建议运行 `/changelog` 生成变更日志
5. 判决为 CONCERNS（建议性 — 非硬阻塞）

**断言：**
- [ ] 判决为 CONCERNS（非 RELEASE BLOCKED — 变更日志是建议性的）
- [ ] 建议 `/changelog` 作为补救措施
- [ ] 报告中显示其他通过的检查
- [ ] 缺失的变更日志被描述为建议性的，非阻塞

---

### 用例 4：之前发布检查清单存在 — 与上次发布的差异

**Fixture：**
- `production/releases/release-checklist-2026-03-20.md` 存在
- 之前：1 个故事不完整，1 个 HIGH bug 开放
- 当前：所有故事 Done，HIGH bug 已解决，但现在出现了 1 个 MEDIUM bug

**输入：** `/release-checklist`

**预期行为：**
1. Skill 找到先前的检查清单并加载
2. 生成新检查清单并比较：
   - 新解决："Story [X] — was open, now Done"
   - 新解决："HIGH bug [filename] — was open, now closed"
   - 新项："1 MEDIUM bug appeared (advisory)"
3. 差异 section 显著显示所有更改
4. 判决为 CONCERNS（MEDIUM bug 是建议性的，非阻塞）

**断言：**
- [ ] 差异 section 出现在报告中，包含已解决项和新项
- [ ] 先前检查清单中新解决的项被注明
- [ ] 先前检查清单中不存在的新项被突出显示
- [ ] 判决反映当前状态（非先前状态）

---

### 用例 5：Director Gate 检查 — 无 gate；release-checklist 是内部审核

**Fixture：**
- 活动冲刺包含故事和 bug 报告

**输入：** `/release-checklist`

**预期行为：**
1. Skill 运行完整检查清单并写入报告
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 RELEASE READY、RELEASE BLOCKED 或 CONCERNS — 无 gate 判决

---

## 协议合规性

- [ ] 检查冲刺故事完成状态
- [ ] 检查开放 bug 严重程度（CRITICAL/HIGH = BLOCKED；MEDIUM/LOW = CONCERNS）
- [ ] 检查 QA 计划签字状态
- [ ] 检查变更日志是否存在
- [ ] 存在先前检查清单时进行比较
- [ ] 写入报告前询问 "May I write"
- [ ] 判决为 RELEASE READY、RELEASE BLOCKED 或 CONCERNS

---

## 覆盖说明

- 构建稳定性验证（无失败的 CI 运行）列为检查类别，但依赖于外部 CI 系统状态；如果 CI 集成未配置，skill 将其记录为 MANUAL CHECK。
- CRITICAL bug 始终导致 RELEASE BLOCKED，无论其他项如何；这与用例 2 中的 HIGH 严重程度情况等效。
- `Status: In Review`（非 Done）的故事被视为不完整，导致 RELEASE BLOCKED；此边缘情况遵循与 HIGH bug 情况相同的模式。
