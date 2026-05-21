<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/bug-report

## Skill 摘要

`/bug-report` 根据用户描述创建结构化的 bug 报告文档。它生成的报告包含以下必需字段：Title、Repro Steps、Expected Behavior、Actual Behavior、Severity（CRITICAL/HIGH/MEDIUM/LOW）、Affected System(s) 和 Build/Version。如果用户初始描述缺少任何必需字段，skill 会在生成草稿之前追问以填补空缺。

该 skill 会检查可能重复的报告（通过对比 `production/bugs/` 中的现有文件），并提供关联而非创建新报告的选项。每份报告在经过 "May I write" 询问后写入 `production/bugs/bug-[date]-[slug].md`。不适用 director gate — bug 报告是一个操作性工具。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：COMPLETE
- [ ] 在写入报告前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，`/bug-triage` 重新排列优先级，`/hotfix` 用于严重问题）

---

## Director Gate 检查

无。`/bug-report` 是一个操作性文档 skill。不适用 director gate。

---

## 测试用例

### 用例 1：Happy Path — 用户描述一个崩溃，生成完整报告

**Fixture：**
- `production/bugs/` 目录存在且为空
- 无类似的现有报告

**输入：** `/bug-report`（用户描述："Game crashes when player enters the boss arena"）

**预期行为：**
1. Skill 提取：Title = "Game crashes when entering boss arena"
2. Skill 将崩溃报告识别为 CRITICAL 严重程度
3. Skill 与用户确认重现步骤、预期（无崩溃）、实际（崩溃）、受影响的系统（arena/boss）和构建版本
4. Skill 起草完整的结构化报告
5. Skill 询问 "May I write to `production/bugs/bug-2026-04-06-game-crashes-boss-arena.md`?"
6. 批准后写入文件；判决为 COMPLETE

**断言：**
- [ ] 报告中包含所有 7 个必需字段
- [ ] 崩溃报告的严重程度为 CRITICAL
- [ ] 文件名遵循 `bug-[date]-[slug].md` 约定
- [ ] 以完整文件路径询问 "May I write"
- [ ] 判决为 COMPLETE

---

### 用例 2：最小输入 — Skill 针对缺失字段追问

**Fixture：**
- 用户提供："Sometimes the audio cuts out"
- 无现有报告

**输入：** `/bug-report`

**预期行为：**
1. Skill 识别缺失的必需字段：重现步骤、预期 vs 实际、严重程度、受影响系统、构建版本
2. Skill 对每个缺失字段逐一追问（或通过结构化提示）
3. 用户提供答案
4. Skill 根据答案汇编完整报告
5. Skill 询问 "May I write?"，批准后写入

**断言：**
- [ ] 至少追问 3 个问题以填补缺失字段
- [ ] 在报告最终确定前所有必需字段均已填写
- [ ] 直到所有必需字段齐全后才写入报告
- [ ] 所有字段填写完成且文件写入后，判决为 COMPLETE

---

### 用例 3：可能重复 — 提供关联而非创建新报告

**Fixture：**
- `production/bugs/bug-2026-03-20-audio-cut-out.md` 已存在，标题相似，严重程度为 MEDIUM

**输入：** `/bug-report`（用户描述："Audio randomly stops working"）

**预期行为：**
1. Skill 扫描现有报告，找到相似的音频 bug
2. Skill 报告："A similar bug report exists: bug-2026-03-20-audio-cut-out.md"
3. Skill 提供选项：关联为重复（向现有文件添加备注）、仍然创建新的
4. 如果用户选择关联：skill 向现有文件添加交叉引用备注（询问 "May I update the existing report?"）
5. 如果用户选择创建新的：正常报告创建流程继续

**断言：**
- [ ] 创建新报告之前，先展示现有的相似报告
- [ ] 用户有选择权（不被强制关联或创建）
- [ ] 如果关联：在修改现有文件之前询问 "May I update"
- [ ] 两种路径下判决均为 COMPLETE

---

### 用例 4：多系统 Bug — 创建带有多个系统标签的报告

**Fixture：**
- 无现有报告

**输入：** `/bug-report`（用户描述："After finishing a level, the save system freezes and the UI doesn't show the completion screen"）

**预期行为：**
1. Skill 从描述中识别出 2 个受影响的系统：Save System 和 UI
2. 报告草案在 Affected System(s) 下列出两个系统
3. 评估严重程度（可能是 HIGH — 存档冻结有数据丢失风险）
4. Skill 以适当文件名询问 "May I write"
5. 报告以两个系统标签写入；判决为 COMPLETE

**断言：**
- [ ] 报告中列出两个受影响的系统
- [ ] 创建单一报告（而非每个系统一个）
- [ ] 严重程度反映影响最大的组件（存档冻结 → HIGH 或 CRITICAL）
- [ ] 判决为 COMPLETE

---

### 用例 5：Director Gate 检查 — 无 gate；bug 报告是操作性工具

**Fixture：**
- 提供了任何 bug 描述

**输入：** `/bug-report`

**预期行为：**
1. Skill 创建并写入 bug 报告
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] Skill 在无任何 gate 检查的情况下达到 COMPLETE

---

## 协议合规性

- [ ] 在起草报告前收集所有 7 个必需字段
- [ ] 对任何缺失的必需字段进行追问
- [ ] 创建新报告前检查相似的现有报告
- [ ] 写入前询问 "May I write to `production/bugs/bug-[date]-[slug].md`?"
- [ ] 报告文件写入后判决为 COMPLETE

---

## 覆盖说明

- 用户提供的严重程度对描述的影响而言似乎过低的情况（例如，LOW 用于崩溃）不测试；skill 可能建议更高严重程度但最终尊重用户输入。
- Build/version 字段是必需的，但如果用户不知道可以是 "unknown" — 这作为有效值接受，不单独测试。
- 报告 slug 生成（将标题清理为文件名）是实现细节，此处不进行断言测试。
