<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/patch-notes

## Skill 摘要

`/patch-notes` 是一个 Haiku 级别的 skill，从已有 changelog 内容生成面向玩家的 patch notes，剥离内部 task ID 和技术行话，替换为通俗语言。它过滤条目，仅保留与玩家相关的内容（可见功能和 bug 修复；内部重构被排除）。不使用任何 Director Gate。该 skill 在持久化前会询问 "May I write to `docs/patch-notes-vX.X.md`?"。Verdict 始终为 COMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含 verdict 关键字：COMPLETE
- [ ] 包含 "May I write" 用语（skill 会写入 patch notes 文件）
- [ ] 包含下一步移交指引（例如，与社区经理分享）

---

## Director Gate 检查

无。Patch notes 生成为快速编译任务，不调用任何 Gate。

---

## 测试用例

### 用例 1：正常路径 — Changelog 过滤为面向玩家的条目

**Fixture：**
- `docs/CHANGELOG.md` 存在，包含 5 个条目：
  - "新增双持近战系统"（Features — 面向玩家）
  - "修复关卡切换崩溃"（Fixes — 面向玩家）
  - "新增敌人巡逻 AI"（Features — 面向玩家）
  - "将输入处理器重构为使用事件总线"（Fixes — 仅内部）
  - "更新依赖：Godot 4.6"（仅内部）
- 版本为 `v0.4.0`

**输入：** `/patch-notes v0.4.0`

**预期行为：**
1. Skill 读取 `docs/CHANGELOG.md`
2. Skill 过滤为 3 个面向玩家的条目；排除 2 个内部条目
3. Skill 将条目改写为通俗语言（无 task ID，无技术行话）
4. Skill 向用户展示草稿
5. Skill 询问 "May I write to `docs/patch-notes-v0.4.0.md`?"
6. 用户批准；文件写入；verdict 为 COMPLETE

**断言：**
- [ ] patch notes 中仅显示 3 个条目（2 个内部条目被排除）
- [ ] 条目以通俗语言编写，不含内部 task ID
- [ ] 文件路径匹配 `docs/patch-notes-v0.4.0.md`
- [ ] "May I write" 提示在文件写入前出现
- [ ] 写入后 verdict 为 COMPLETE

---

### 用例 2：未找到 Changelog — 引导运行 /changelog

**Fixture：**
- `docs/CHANGELOG.md` 不存在

**输入：** `/patch-notes v0.4.0`

**预期行为：**
1. Skill 尝试读取 `docs/CHANGELOG.md` — 未找到
2. Skill 输出："未找到 changelog — 请先运行 /changelog 生成一个"
3. 不生成 patch notes；不写入任何文件

**断言：**
- [ ] changelog 不存在时 skill 不崩溃
- [ ] 输出明确引导用户运行 `/changelog`
- [ ] 不出现 "May I write" 提示（无内容可写）
- [ ] Verdict 为 BLOCKED（依赖未满足）

---

### 用例 3：来自 Design 文件夹的语气指南 — 融入输出

**Fixture：**
- `docs/CHANGELOG.md` 存在，包含面向玩家的条目
- `design/community/tone-guide.md` 存在，包含指南："乐观、鼓励性语气；避免被动语态"

**输入：** `/patch-notes v0.4.0`

**预期行为：**
1. Skill 读取 changelog
2. Skill 检测到 `design/community/tone-guide.md` 语气指南
3. Skill 在改写为通俗语言时应用语气指南
4. Patch notes 使用乐观、主动语态的措辞
5. Skill 展示草稿，请求写入，批准后写入

**断言：**
- [ ] Skill 检查 `design/` 中是否存在 community 或语气指南文件
- [ ] 语气指南内容影响 patch note 条目的措辞
- [ ] 输出在适用处体现主动语态和乐观语气
- [ ] Skill 注明已应用语气指南

---

### 用例 4：存在 Patch Note 模板 — 使用模板替代自动生成结构

**Fixture：**
- `.claude/docs/templates/patch-notes-template.md` 存在，包含结构化头部格式
- `docs/CHANGELOG.md` 存在，包含面向玩家的条目

**输入：** `/patch-notes v0.4.0`

**预期行为：**
1. Skill 读取 changelog，检测到模板存在
2. Skill 将面向玩家的条目填充到模板中
3. 模板头部/尾部结构在输出中得以保留
4. Skill 询问 "May I write" 并在批准后写入

**断言：**
- [ ] Skill 在从头生成前检查是否存在 patch notes 模板
- [ ] 找到模板时使用模板结构（不被默认格式覆盖）
- [ ] 面向玩家的条目被插入正确的模板分组
- [ ] 输出注明已使用模板

---

### 用例 5：Gate 合规 — 无 Gate；社区经理为独立步骤

**Fixture：**
- `docs/CHANGELOG.md` 存在，包含面向玩家的条目
- `review-mode.txt` 内容为 `full`

**输入：** `/patch-notes v0.4.0`

**预期行为：**
1. Skill 在 full 模式下编译 patch notes
2. 不调用任何 Director Gate（社区审查为独立的手动步骤）
3. Skill 在 Haiku 模型上运行 — 快速编译
4. Skill 在输出中注明："建议在发布前将草稿分享给社区经理审阅"
5. Skill 请求用户批准并在确认后写入

**断言：**
- [ ] 无论 review mode 如何，均不调用任何 Director Gate
- [ ] 输出建议（但不强制）社区经理审查
- [ ] Skill 直接从编译进入到 "May I write" 提示
- [ ] Verdict 为 COMPLETE

---

## 协议合规

- [ ] 生成 patch notes 前读取 `docs/CHANGELOG.md`
- [ ] 仅过滤面向玩家的条目
- [ ] 将条目改写为通俗语言，不含内部 ID
- [ ] 始终在写入 patch notes 文件前询问 "May I write"
- [ ] 不调用任何 Director Gate
- [ ] 在 Haiku 模型级别运行（快速、低成本）

---

## 覆盖说明

- 所有 changelog 条目均为内部（零个面向玩家条目）的场景未测试；行为为空的 patch notes 草稿并附警告。
- 从 changelog 头部解析版本号为实现细节，此处不验证。
- 用例 5 中提到的社区经理咨询为建议性质；由单独的 skill 或手动审查处理该步骤。
