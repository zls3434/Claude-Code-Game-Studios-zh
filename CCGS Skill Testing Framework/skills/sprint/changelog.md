<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/changelog

## Skill 摘要

`/changelog` 是一个 Haiku 级别的 skill，通过读取自上一 release tag 以来的 git 提交历史及已关闭的 sprint story，自动生成面向开发者的 changelog。它会将条目组织为 features（新功能）、fixes（修复）和 known issues（已知问题）三大分类。不使用任何 Director Gate。该 skill 在持久化前会询问 "May I write to `docs/CHANGELOG.md`?"。Verdict 始终为 COMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含 verdict 关键字：COMPLETE
- [ ] 包含 "May I write" 用语（skill 会写入 changelog 文件）
- [ ] 包含下一步移交指引（例如：运行 /patch-notes 生成面向玩家的版本）

---

## Director Gate 检查

无。Changelog 生成为快速编译任务，不调用任何 Gate。

---

## 测试用例

### 用例 1：正常路径 — 自上次 release tag 以来跨越多个 sprint

**Fixture：**
- Git 历史中有一个 tag `v0.3.0`，位于三个 sprint 之前
- 自该 tag 以来：跨越 sprint 006、007、008 共有 12 个 commits
- Sprint story 文件引用了与 commit message 匹配的 task ID
- `docs/CHANGELOG.md` 尚不存在

**输入：** `/changelog`

**预期行为：**
1. Skill 读取自 `v0.3.0` tag 以来的 git log
2. Skill 读取 sprint story 以交叉引用 task ID
3. Skill 将条目编译为 Features、Fixes 和 Known Issues 分组
4. Skill 向用户展示草稿
5. Skill 询问 "May I write to `docs/CHANGELOG.md`?"
6. 用户批准；文件写入；verdict 为 COMPLETE

**断言：**
- [ ] changelog 覆盖自最近 git tag 以来的 commits
- [ ] 条目按 Features / Fixes / Known Issues 分组组织
- [ ] 使用 sprint story 引用丰富 commit 描述内容
- [ ] "May I write" 提示在文件写入前出现
- [ ] 写入后 verdict 为 COMPLETE

---

### 用例 2：未找到 Git Tag — 使用全部 commits，标注版本基线

**Fixture：**
- Git 仓库有 commits 但不存在任何 tag
- 历史中共 20 个 commits，跨越 3 个 sprint

**输入：** `/changelog`

**预期行为：**
1. Skill 检查 git tag — 未找到任何 tag
2. Skill 将历史中的所有 commits 作为基线
3. Skill 在输出中注明："未找到版本 tag — 使用完整提交历史；版本基线未设置"
4. Skill 仍然从可用 commits 中编译出有条理的 changelog
5. Skill 询问 "May I write" 并在批准后写入

**断言：**
- [ ] 没有 git tag 时 skill 不出错
- [ ] 输出明确注明未找到版本基线
- [ ] 将完整提交历史作为来源
- [ ] 尽管缺少 tag，changelog 仍按分组组织

---

### 用例 3：不含 Task ID 的 Commit Message — 按日期分组并标注

**Fixture：**
- 自上次 tag 以来的 git log 有 8 个 commits
- 其中 5 个 commits 的 message 不含 task ID（例如："fix typo"、"tweak values"）
- 其中 3 个 commits 引用了与 sprint story 匹配的 task ID

**输入：** `/changelog`

**预期行为：**
1. Skill 读取 commits 和 sprint story
2. 3 个 commits 匹配到 sprint story，归入相应分组
3. 5 个未标记的 commits 按日期分组，归入 "Misc" 或 "Other Changes" 分组
4. 输出注明："5 个 commit 无 task ID — 按日期分组"
5. Skill 经批准后写入 changelog

**断言：**
- [ ] 有 task ID 的 commits 放入相应分组（Features 或 Fixes）
- [ ] 无 task ID 的 commits 单独分组并附注
- [ ] 输出标注缺少 task 引用的 commit 数量
- [ ] 没有任何 commit 被静默丢弃

---

### 用例 4：已存在 CHANGELOG.md — 新内容前置，旧条目保留

**Fixture：**
- `docs/CHANGELOG.md` 已存在，包含 `v0.2.0` 和 `v0.3.0` 的分组
- 自 `v0.3.0` tag 以来有新的 commits

**输入：** `/changelog`

**预期行为：**
1. Skill 检测到 `docs/CHANGELOG.md` 已存在
2. Skill 编译自 `v0.3.0` 以来的新条目
3. Skill 展示草稿，新分组前置到已有内容之前
4. Skill 询问 "May I write to `docs/CHANGELOG.md`?"（确认前置策略）
5. 用户批准；新内容前置写入，旧条目完好；verdict 为 COMPLETE

**断言：**
- [ ] Skill 在写入前读取已有 changelog 以检测先前内容
- [ ] 新分组前置（非追加或覆盖）到已有条目之前
- [ ] v0.2.0 和 v0.3.0 的旧 changelog 条目在写入文件中得以保留
- [ ] "May I write" 提示反映前置操作

---

### 用例 5：Gate 合规 — 无 Gate；先读取再写入需审批

**Fixture：**
- Git 历史自上次 tag 以来有 commits
- `review-mode.txt` 内容为 `full`

**输入：** `/changelog`

**预期行为：**
1. Skill 在 full 模式下编译 changelog
2. 不调用任何 Director Gate（changelog 生成为编译任务，非交付关卡）
3. Skill 在 Haiku 模型上运行 — 快速编译
4. Skill 向用户请求审批并在确认后写入文件

**断言：**
- [ ] 无论 review mode 如何，均不调用任何 Director Gate
- [ ] 输出不引用任何 Gate 结果
- [ ] Skill 直接从编译进入到 "May I write" 提示
- [ ] Verdict 为 COMPLETE

---

## 协议合规

- [ ] 编译前读取 git log 和 sprint story 文件
- [ ] 始终在写入 changelog 前询问 "May I write"
- [ ] 不调用任何 Director Gate
- [ ] Verdict 始终为 COMPLETE
- [ ] 在 Haiku 模型级别运行（快速、低成本）

---

## 覆盖说明

- 仓库中 git 未初始化的场景未测试；行为将取决于 git 命令的失败处理。
- Merge commits 与 squash commits 在这些测试中不做显式区分；属于 git log 解析阶段的实现细节。
- 应在 `/changelog` 之后运行 `/patch-notes` 生成面向玩家的输出；该移交在 patch-notes 规格中验证。
