<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/playtest-report

## Skill 摘要

`/playtest-report` 根据会话笔记或用户输入生成结构化试玩报告。报告组织为四个 section：Feel/Accessibility、Bugs Observed、Design Feedback 和 Next Steps。当多名测试者参与时，skill 汇总反馈并区分多数意见与少数意见。当报告的 bug 与 `production/bugs/` 中的文件匹配时，skill 链接到现有 bug 报告。

报告在经过 "May I write" 询问后写入 `production/qa/playtest-[date].md`。此处不适用 director gate — CD-PLAYTEST director gate（如需要）是单独调用。报告写入后判决为 COMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：COMPLETE
- [ ] 在写入报告前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，`/bug-report` 用于发现的新问题，`/design-review` 用于反馈）

---

## Director Gate 检查

无。`/playtest-report` 是一个文档工具。CD-PLAYTEST gate 是单独调用，不属于此 skill。

---

## 测试用例

### 用例 1：Happy Path — 用户提供试玩笔记，生成结构化报告

**Fixture：**
- 用户提供来自单次会话的试玩笔记
- 笔记涵盖：游戏感受、一个 bug（帧率下降）和一个设计问题（教程太长）
- `production/bugs/` 存在但为空（bug 尚未报告）

**输入：** `/playtest-report`（用户粘贴会话笔记）

**预期行为：**
1. Skill 读取提供的笔记并将其结构化到 4-section 模板中
2. Feel/Accessibility：提取感受观察
3. Bugs：记录帧率下降及可用的重现详情
4. Design Feedback：记录教程长度问题
5. Next Steps：建议对帧率问题使用 `/bug-report`，对教程反馈使用 `/design-review`
6. Skill 询问 "May I write to `production/qa/playtest-2026-04-06.md`?"
7. 批准后写入报告；判决为 COMPLETE

**断言：**
- [ ] 报告中存在所有 4 个 section
- [ ] Bug 列在 Bugs section 中（而非 Design Feedback section）
- [ ] Next Steps 适当（bug report 用于崩溃，design review 用于反馈）
- [ ] 写入前询问 "May I write"
- [ ] 判决为 COMPLETE

---

### 用例 2：空输入 — 引导式逐一填写每个 section

**Fixture：**
- 调用时用户未提供笔记

**输入：** `/playtest-report`

**预期行为：**
1. Skill 检测到空输入
2. Skill 逐一引导填写每个 section：
   a. "Describe the overall feel and any accessibility observations"
   b. "Were any bugs observed? Describe them"
   c. "What design feedback did testers provide?"
3. 用户回答每个提示
4. Skill 根据回答汇编报告并询问 "May I write"
5. 批准后写入报告；判决为 COMPLETE

**断言：**
- [ ] 至少提出 3 个引导性问题（每个主要 section 一个）
- [ ] 在所有 section 获得输入（或用户明确跳过某个）之前不创建报告
- [ ] 文件写入后判决为 COMPLETE

---

### 用例 3：多名测试者 — 汇总反馈附多数/少数说明

**Fixture：**
- 用户提供 3 名测试者的笔记
- 2/3 测试者认为操控 "intuitive"
- 1/3 测试者认为 UI 字体太小
- 全部 3 名均发现同一 bug（玩家卡在平台上）

**输入：** `/playtest-report`（3 名测试者会话）

**预期行为：**
1. Skill 从输入中识别 3 个不同测试者视角
2. 操控直观性 → 标记为 "Majority (2/3): controls intuitive"
3. 字体大小 → 标记为 "Minority (1/3): UI font size concern"
4. 卡在平台上 bug → 标记为 "All testers: player stuck on ledge (confirmed)"
5. Skill 生成附多数/少数标签的汇总报告
6. 经 "May I write" 批准后写入报告；判决为 COMPLETE

**断言：**
- [ ] 多数意见（2/3）标记为 majority
- [ ] 少数意见（1/3）标记为 minority
- [ ] 所有测试者一致报告的 bug 标记为所有测试者确认
- [ ] 判决为 COMPLETE

---

### 用例 4：Bug 匹配现有报告 — 链接到现有文件

**Fixture：**
- `production/bugs/bug-2026-03-30-player-stuck-ledge.md` 存在
- 用户试玩笔记描述 "player gets stuck on ledges near walls"

**输入：** `/playtest-report`

**预期行为：**
1. Skill 结构化报告并识别出卡在平台上的 bug
2. Skill 扫描 `production/bugs/` 并找到 `bug-2026-03-30-player-stuck-ledge.md`
3. 在 Bugs section 中，报告包含："See existing report: production/bugs/bug-2026-03-30-player-stuck-ledge.md"
4. Skill 不建议为此问题创建新 bug 报告
5. 报告写入；判决为 COMPLETE

**断言：**
- [ ] 找到现有 bug 报告并在试玩报告中链接
- [ ] 对已报告问题不建议 `/bug-report`
- [ ] 交叉引用到现有文件出现在 Bugs section 中
- [ ] 判决为 COMPLETE

---

### 用例 5：Director Gate 检查 — 无 gate；CD-PLAYTEST 是单独调用

**Fixture：**
- 提供试玩笔记

**输入：** `/playtest-report`

**预期行为：**
1. Skill 生成并写入试玩报告
2. 不生成任何 director agent（此处不调用 CD-PLAYTEST）
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 CD-PLAYTEST gate 跳过消息
- [ ] 判决为 COMPLETE，无任何 gate 检查

---

## 协议合规性

- [ ] 将输出结构化为全部 4 个 section（Feel、Bugs、Design Feedback、Next Steps）
- [ ] 涉及多名测试者时标记多数 vs. 少数意见
- [ ] Bug 匹配时交叉引用现有 bug 报告
- [ ] 写入前询问 "May I write to `production/qa/playtest-[date].md`?"
- [ ] 报告写入后判决为 COMPLETE

---

## 覆盖说明

- CD-PLAYTEST director gate（创意总监审查试玩见解以获取设计意义）是单独调用，此处不测试。
- 视频录制或截图附件不测试；报告是纯文本文档。
- 测试者身份未知的情况（匿名反馈）遵循与用例 3 相同的汇总模式，无测试者标签。
