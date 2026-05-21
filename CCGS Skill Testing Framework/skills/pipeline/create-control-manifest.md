<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格: /create-control-manifest

## Skill 概要

`/create-control-manifest` 读取 `docs/architecture/` 中所有状态为 Accepted 的 ADR，并生成一个控制清单（control manifest）—— 一份汇总文档，将所有架构约束、必需模式和禁止模式集中记录在一个地方。该清单是故事（story）作者编写故事文件时的参考文档，确保故事能正确继承架构规则，而无需逐个阅读所有 ADR。

该 skill 仅包含状态为 Accepted 的 ADR；状态为 Proposed 的 ADR 将被排除并予以注明。该 skill 不涉及任何导演关卡（director gate）。在写入 `docs/architecture/control-manifest.md` 之前，skill 会询问"May I write"。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 —— 无需测试夹具。

- [ ] 包含必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含判定关键词：CREATED、BLOCKED
- [ ] 包含"May I write"协作协议用语（针对 control-manifest.md）
- [ ] 末尾包含下一步交接指引（`/create-epics` 或 `/create-stories`）
- [ ] 文档明确说明仅包含 Accepted 状态的 ADR（不包含 Proposed）

---

## 导演关卡检查

不涉及导演关卡 —— 该 skill 不会派生任何导演关卡 Agent。控制清单是对 Accepted ADR 的机械性提取，无需创意或技术审查关卡。

---

## 测试用例

### 用例 1：正常流程 —— 4 个 Accepted ADR 生成正确的清单

**测试夹具：**
- `docs/architecture/` 包含 4 个 ADR 文件，状态均为 `Status: Accepted`
- 每个 ADR 均包含"Required Patterns"和/或"Forbidden Patterns"章节
- 不存在现有的 `docs/architecture/control-manifest.md`

**输入：** `/create-control-manifest`

**预期行为：**
1. Skill 读取 `docs/architecture/` 中所有 ADR 文件
2. 从每个 ADR 中提取 Required Patterns、Forbidden Patterns 和关键约束
3. 按正确的章节结构起草清单
4. 向用户展示清单草稿
5. 询问"May I write `docs/architecture/control-manifest.md`?"
6. 获得批准后写入清单

**断言：**
- [ ] 清单中涵盖了全部 4 个 Accepted ADR
- [ ] 清单包含 Required Patterns 和 Forbidden Patterns 的独立章节
- [ ] 清单为每条约束标注了来源 ADR 编号
- [ ] 写入前询问"May I write"
- [ ] Skill 在未获批准的情况下不执行写入
- [ ] 写入后判定结果为 CREATED

---

### 用例 2：失败路径 —— 未找到任何 ADR

**测试夹具：**
- `docs/architecture/` 目录存在但不包含任何 ADR 文件

**输入：** `/create-control-manifest`

**预期行为：**
1. Skill 读取 `docs/architecture/` 发现没有 ADR 文件
2. Skill 输出："No ADRs found. Run `/architecture-decision` to create ADRs before generating the control manifest."
3. Skill 退出，不创建任何文件
4. 判定结果为 BLOCKED

**断言：**
- [ ] Skill 在未找到 ADR 时输出清晰的错误信息
- [ ] 不写入任何控制清单文件
- [ ] Skill 建议 `/architecture-decision` 作为下一步操作
- [ ] 判定结果为 BLOCKED（非错误崩溃）

---

### 用例 3：混合 ADR 状态 —— 仅包含 Accepted ADR

**测试夹具：**
- `docs/architecture/` 包含 3 个 Accepted ADR 和 2 个 Proposed ADR

**输入：** `/create-control-manifest`

**预期行为：**
1. Skill 读取所有 ADR 文件并按 Status: Accepted 过滤
2. 仅基于 3 个 Accepted ADR 起草清单
3. 输出注明："2 Proposed ADRs were excluded: [adr-NNN-name, adr-NNN-name]"
4. 用户在批准写入前可以看到被排除的 ADR 列表
5. 询问"May I write `docs/architecture/control-manifest.md`?"

**断言：**
- [ ] 清单内容中仅出现 3 个 Accepted ADR
- [ ] 被排除的 Proposed ADR 在输出中按名称列出
- [ ] 用户在批准写入前可以看到排除列表
- [ ] Skill 不会静默忽略 Proposed ADR 而不加以注明

---

### 用例 4：边界情况 —— 清单已存在

**测试夹具：**
- `docs/architecture/control-manifest.md` 已存在（版本 1，日期为上周）
- `docs/architecture/` 包含 Accepted ADR（自上次生成清单后有新增）

**输入：** `/create-control-manifest`

**预期行为：**
1. Skill 检测到已有清单，读取其版本号/日期
2. Skill 提供重新生成选项："control-manifest.md already exists (v1, [date]). Regenerate with current ADRs?"
3. 若用户确认：skill 起草更新后的清单，递增版本号
4. 询问"May I write `docs/architecture/control-manifest.md`?"（覆盖模式）
5. 获得批准后写入更新后的清单

**断言：**
- [ ] Skill 在提供重新生成选项之前读取并报告已有清单的版本信息
- [ ] 为用户提供重新生成/跳过选择 —— 不自动覆盖
- [ ] 更新后的清单版本号已递增
- [ ] 覆盖已有文件前询问"May I write"

---

### 用例 5：导演关卡 —— 不派生关卡，不读取 review-mode.txt

**测试夹具：**
- 存在 4 个 Accepted ADR
- `production/session-state/review-mode.txt` 存在且内容为 `full`

**输入：** `/create-control-manifest`

**预期行为：**
1. Skill 读取 ADR 并起草清单
2. Skill 不读取 `production/session-state/review-mode.txt`
3. 全程不派生任何导演关卡 Agent
4. Skill 起草完成后直接进入"May I write"询问
5. 审查模式设置对该 skill 的行为无任何影响

**断言：**
- [ ] 不派生任何导演关卡 Agent（无 CD-、TD-、PR-、AD- 前缀的关卡）
- [ ] Skill 不读取 `production/session-state/review-mode.txt`
- [ ] 输出中不含任何"Gate: [GATE-ID]"或关卡跳过条目
- [ ] 清单仅基于 ADR 生成，无需外部关卡审查

---

## 协议合规性

- [ ] 起草清单前读取所有 ADR 文件
- [ ] 仅包含 Accepted ADR —— Proposed 的予以注明排除
- [ ] 清单草稿在"May I write"询问之前展示给用户
- [ ] 写入前询问"May I write `docs/architecture/control-manifest.md`?"
- [ ] 不涉及导演关卡 —— 不读取 review-mode.txt
- [ ] 末尾包含下一步交接指引：`/create-epics` 或 `/create-stories`

---

## 覆盖范围注释

- 生成清单的具体章节结构（约束表、模式列表）由 skill 主体定义，不在测试断言中重新枚举。
- `version` 字段递增逻辑（v1 → v2）通过用例 4 测试，但具体版本号格式不被测试夹具锁定。
- ADR 解析（提取 Required/Forbidden Patterns）依赖于一致的 ADR 结构 —— 通过用例 1 的测试夹具隐式验证。
