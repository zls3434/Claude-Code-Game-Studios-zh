<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/quick-design

## Skill 摘要

`/quick-design` 为规模不足以需要完整 8 章节 GDD 的功能产出轻量级设计规格。目标范围是单个系统功能、设计时间在 4 小时以内。quick-design 规格使用精简的 3 章节格式（Overview、Rules 和 Acceptance Criteria），而非完整的 8 章节 GDD 格式。

该 skill 没有总监门禁 — 添加门禁开销会违背轻量级设计工具的目的。该 skill 在将设计笔记写入 `design/quick-notes/[name].md` 之前会询问"我可以将此写入吗？"。如果功能范围过大不适合 quick-design，则该 skill 会重定向至 `/design-system`。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 — 无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含裁决关键词：CREATED、BLOCKED、REDIRECTED
- [ ] 包含"我可以将此写入吗？"协作协议用语（针对 quick-note 文件）
- [ ] 末尾包含下一步交接
- [ ] 明确注明：无总监门禁（按设计此为轻量级 skill）
- [ ] 提及范围检查：若范围超出 4 小时阈值，则重定向至 `/design-system`

---

## 总监门禁检查

无总监门禁 — 此 skill 不会生成任何总监门禁 Agent。quick-design 的轻量特性意味着有意免除了总监门禁开销。对于 4 小时以内的单一系统功能，无需完整的 GDD 审查。

---

## 测试用例

### 用例 1：理想路径 — 小型 UI 变更产出 3 章节规格

**夹具：**
- 不存在目标功能的 quick-note
- 功能范围明确：单个 UI 元素变更，无跨系统影响

**输入：** `/quick-design [feature-name]`

**预期行为：**
1. Skill 询问范围问题：是什么系统、什么变更、验收信号是什么
2. Skill 判定范围在 4 小时阈值以内
3. Skill 起草 3 章节规格：Overview、Rules、Acceptance Criteria
4. 草稿展示给用户
5. 询问"我可以将 `design/quick-notes/[name].md` 写入吗？"
6. 批准后写入文件

**断言：**
- [ ] 规格恰好包含 3 个章节：Overview、Rules、Acceptance Criteria
- [ ] 在询问"我可以将此写入吗？"之前先展示草稿
- [ ] 在写入前询问"我可以将 `design/quick-notes/[name].md` 写入吗？"
- [ ] 文件写入到正确的路径：`design/quick-notes/[name].md`
- [ ] 成功写入后裁决为 CREATED

---

### 用例 2：失败路径 — 范围检查失败；重定向至 /design-system

**夹具：**
- 所描述的功能跨越多个系统，或设计时间将超过 4 小时（例如"重新设计整个战斗系统"或"影响所有职业的新成长机制"）

**输入：** `/quick-design [large-feature]`

**预期行为：**
1. Skill 询问范围问题
2. Skill 判定范围超出 4 小时 / 单一系统阈值
3. Skill 输出："此功能规模过大，不适合 quick-design。请使用 `/design-system [name]` 获取完整 GDD。"
4. Skill 不会写入 quick-note 文件
5. 裁决为 REDIRECTED

**断言：**
- [ ] Skill 检测到范围超出并在起草前停止
- [ ] 消息明确指出 `/design-system` 为正确的替代方案
- [ ] 不写入 quick-note 文件
- [ ] 裁决为 REDIRECTED（而非 CREATED 或 BLOCKED）

---

### 用例 3：边界情况 — 文件已存在；提供更新选项

**夹具：**
- `design/quick-notes/[name].md` 已从之前的会话中存在

**输入：** `/quick-design [name]`

**预期行为：**
1. Skill 检测到已有 quick-note 文件并读取其当前内容
2. Skill 询问："[name].md 已存在。是更新它，还是创建新版本？"
3. 用户选择更新
4. Skill 展示现有规格并询问要修订哪个章节
5. 展示更新后的规格，询问"我可以将此写入吗？"，批准后更新文件

**断言：**
- [ ] Skill 在提供更新选项前检测并读取已有文件
- [ ] 用户被提供更新或新建选项 — 不会自动覆盖
- [ ] 仅修订的章节被更新（或用户选择完全重写时更新整个规格）
- [ ] 在覆盖现有文件前询问"我可以将此写入吗？"

---

### 用例 4：边界情况 — 未提供参数

**夹具：**
- `design/quick-notes/` 目录可能存在也可能不存在

**输入：** `/quick-design`（无参数）

**预期行为：**
1. Skill 检测到未提供参数
2. Skill 输出用法错误："未指定功能名称。用法：/quick-design [feature-name]"
3. Skill 提供示例：`/quick-design pause-menu-settings`
4. 不创建任何文件

**断言：**
- [ ] 当未提供参数时 Skill 输出用法错误
- [ ] 以正确格式展示用法示例
- [ ] 不写入 quick-note 文件
- [ ] Skill 不会静默选择一个功能名称或默认执行任何操作

---

### 用例 5：总监门禁 — 不生成门禁；对 4 小时以内的功能明确注明

**夹具：**
- 功能在 quick-design 范围以内
- `production/session-state/review-mode.txt` 存在且包含 `full`

**输入：** `/quick-design [feature-name]`

**预期行为：**
1. Skill 询问范围问题并判定范围在阈值以内
2. Skill 不会读取 `production/session-state/review-mode.txt`
3. Skill 不会生成任何总监门禁 Agent
4. 起草规格，询问"我可以将此写入吗？"，批准后写入文件
5. 输出明确注明："无总监门禁审查 — quick-design 适用于 4 小时以内的功能"

**断言：**
- [ ] 不会生成任何总监门禁 Agent（无 CD-、TD-、PR-、AD- 前缀的门禁）
- [ ] Skill 不会读取 `production/session-state/review-mode.txt`
- [ ] 输出包含解释为何不需要门禁审查的说明
- [ ] 审查模式对此 skill 的行为没有影响
- [ ] 完整 GDD 审查路径（`/design-system`）作为更大功能的替代方案被提及

---

## 协议合规

- [ ] 在起草前运行范围检查（若范围过大则重定向至 `/design-system`）
- [ ] 使用 3 章节格式（Overview、Rules、Acceptance Criteria）— 而非 8 章节 GDD 格式
- [ ] 在询问"我可以将此写入吗？"之前先展示草稿
- [ ] 在写入前询问"我可以将 `design/quick-notes/[name].md` 写入吗？"
- [ ] 无总监门禁 — 不读取 review-mode.txt
- [ ] 以下一步交接结束（例如继续实施或 `/dev-story`）

---

## 覆盖说明

- 范围阈值启发式判定（4 小时内、单一系统）是一种判断性调用 — 该 skill 的内部检查是权威定义，不通过计时方式独立测试。
- `design/quick-notes/` 目录如果不存在会自动创建 — 此文件系统行为不在此独立测试。
- 与 story 管线的集成（quick-design 能否直接生成 story？）超出本规格范围 — quick-design 是独立的。
