<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/propagate-design-change

## Skill 摘要

`/propagate-design-change` 处理 GDD 修订的级联影响。当 GDD 被更新时，该 Skill 追踪所有引用它的下游产物：ADR、TR-registry 条目、story 和 epic。它产出一份结构化的影响报告，显示需要变更的内容及原因。该 Skill 不会自动应用变更——它为每个受影响的产物提出编辑建议，并在做任何修改之前按产物逐一询问 "May I write"。

该 Skill 在分析阶段是只读的，在更新阶段按产物进行写入门控。没有总监关卡——因为分析本身就是机械性的追踪，而非创意性审查。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证——不需要 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判定关键词：COMPLETE、BLOCKED、NO IMPACT
- [ ] 包含 "May I write" 协作协议语言（按产物批准）
- [ ] 末尾有下一步引导
- [ ] 记录变更是被提议而非自动应用的

---

## 总监关卡检查

无总监关卡——此 Skill 在分析期间不启动任何总监关卡 Agent。影响报告是一个机械性的追踪操作；不需要创意或技术总监在分析阶段进行审查。

---

## 测试用例

### 用例 1：正常路径 — GDD 修订影响 2 个 story 和 1 个 epic

**测试环境配置（Fixture）：**
- `design/gdd/[system].md` 存在且最近被修订（git diff 显示变更）
- `production/epics/[layer]/EPIC-[system].md` 引用了此 GDD
- 2 个 story 文件引用了此 GDD 中的 TR-ID
- 变更的 GDD 章节影响了两个 story 的验收标准

**输入：** `/propagate-design-change design/gdd/[system].md`

**预期行为：**
1. Skill 读取修订后的 GDD 并识别变更内容（git diff 或内容比较）
2. Skill 扫描 ADR、TR-registry、epic 和 story 中对此 GDD 的引用
3. Skill 产出影响报告：1 个 epic 受影响，2 个 story 受影响
4. Skill 展示每个产物的拟议变更
5. 对每个产物：分别询问 "May I update [filepath]?"
6. 仅在按产物批准后才应用变更

**断言：**
- [ ] 影响报告识别了所有 3 个受影响产物（1 epic + 2 stories）
- [ ] 每个受影响产物的拟议变更在要求写入之前已展示
- [ ] "May I write" 按产物询问（不是一次性对全部产物）
- [ ] Skill 未经按产物批准不应用任何变更
- [ ] 在所有已批准的变更应用后，判定结果为 COMPLETE

---

### 用例 2：无影响 — 变更的 GDD 没有下游引用

**测试环境配置（Fixture）：**
- `design/gdd/[system].md` 存在且已被修订
- 没有 ADR、story 或 epic 引用此 GDD 的 TR-ID 或 GDD 路径

**输入：** `/propagate-design-change design/gdd/[system].md`

**预期行为：**
1. Skill 读取修订后的 GDD
2. Skill 扫描所有 ADR、story 和 epic 以查找引用
3. 未找到引用
4. Skill 输出："对 [system].md 未发现下游影响——没有产物引用此 GDD。"
5. 不执行任何写入操作

**断言：**
- [ ] Skill 输出"未发现下游影响"消息
- [ ] 判定结果为 NO IMPACT
- [ ] 不发出 "May I write" 询问（没有需要更新的内容）
- [ ] 当未找到引用时，Skill 不会出错或崩溃

---

### 用例 3：进行中的 Story 警告 — 引用的 story 正在开发中

**测试环境配置（Fixture）：**
- 引用此 GDD 的某个 story 状态为 `Status: In Progress`
- 开发者已经开始实施此 story

**输入：** `/propagate-design-change design/gdd/[system].md`

**预期行为：**
1. Skill 将进行中的 story 识别为受影响产物
2. Skill 输出升级警告："注意：[story-file] 当前处于 In Progress 状态——可能有开发者正在开发。请先协调再进行更新。"
3. 该警告在影响报告中、对该 story 的 "May I write" 询问之前出现
4. 用户仍然可以批准或跳过该 story 的更新

**断言：**
- [ ] 进行中的 story 被标记升级警告（区别于普通的受影响产物条目）
- [ ] 警告在对该 story 的 "May I write" 询问之前出现
- [ ] Skill 仍然提供更新该 story 的选项——警告不阻止该选项
- [ ] 其他（非 In Progress）产物不受此警告影响

---

### 用例 4：边界情况 — 未提供参数

**测试环境配置（Fixture）：**
- `design/gdd/` 中存在多个 GDD

**输入：** `/propagate-design-change`（无参数）

**预期行为：**
1. Skill 检测到未提供参数
2. Skill 输出用法错误："未指定 GDD。用法：/propagate-design-change design/gdd/[system].md"
3. Skill 列出最近修改的 GDD 作为建议（git log）
4. 不执行任何分析

**断言：**
- [ ] 当未提供参数时，Skill 输出用法错误
- [ ] 显示包含正确路径格式的用法示例
- [ ] 没有目标 GDD 时不执行影响分析
- [ ] Skill 不会在没有用户输入的情况下静默选择一个 GDD

---

### 用例 5：总监关卡 — 无论审查模式如何，均不启动关卡

**测试环境配置（Fixture）：**
- 一个 GDD 已修订且存在下游引用
- `production/session-state/review-mode.txt` 存在，内容为 `full`

**输入：** `/propagate-design-change design/gdd/[system].md`

**预期行为：**
1. Skill 读取 GDD 并追踪下游引用
2. Skill 不读取 `production/session-state/review-mode.txt`
3. 任何时候都不启动总监关卡 Agent
4. 影响报告正常产出，按产物批准正常进行

**断言：**
- [ ] 不启动任何总监关卡 Agent（无 CD-、TD-、PR-、AD- 前缀的关卡）
- [ ] Skill 不读取 `production/session-state/review-mode.txt`
- [ ] 输出不包含任何"关卡: [GATE-ID]"或关卡跳过的条目
- [ ] 审查模式对此 Skill 的行为没有影响

---

## 协议合规

- [ ] 在产出影响报告之前读取修订的 GDD 和所有可能受影响的产物
- [ ] 在任何 "May I write" 询问之前完整展示影响报告
- [ ] "May I write" 按产物询问——永远不一次性询问全部
- [ ] 在进行中的 story 的批准询问之前标记升级警告
- [ ] 无总监关卡——不读取 review-mode.txt
- [ ] 根据判定结果（COMPLETE 或 NO IMPACT）以适当的下一步引导结束

---

## 覆盖说明

- ADR 影响（当 GDD 变更需要 ADR 更新或新增 ADR 时）遵循与 story/epic 更新相同的按产物批准模式——不单独进行 fixture 测试。
- TR-registry 影响（当变更的 GDD 需要新的或更新的 TR-ID 时）是分析阶段的一部分，但不单独进行 fixture 测试。
- git diff 比较方法（检测 GDD 中的变更内容）是运行时关注点——fixture 使用预先安排的内容差异。
