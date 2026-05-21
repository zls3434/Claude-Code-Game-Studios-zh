<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格: /dev-story

## Skill 概要

`/dev-story` 读取一个故事文件，加载所有必需的上下文（引用的 ADR、TR-ID（来自注册表）、控制清单、引擎偏好设置），实现该故事，验证所有验收标准均已满足，并将故事标记为 Complete。该 skill 根据引擎和文件类型将实现任务路由至相应的专家 Agent —— 它自身不直接编写源代码。

在 `full` 审查模式下，LP-CODE-REVIEW 关卡在故事标记为 Complete 之前运行。在 `lean` 或 `solo` 模式下，LP-CODE-REVIEW 被跳过，用户在确认所有标准均已满足后故事即标记为 Complete。Skill 在更新故事状态和写入代码文件前询问"May I write"。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证 —— 无需测试夹具。

- [ ] 包含必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含判定关键词：COMPLETE、BLOCKED、IN PROGRESS、NEEDS CHANGES
- [ ] 包含"May I write"协作协议用语（故事状态 + 代码文件）
- [ ] 末尾包含下一步交接指引（`/story-done`）
- [ ] 文档说明 LP-CODE-REVIEW 关卡：在 full 模式下活跃，在 lean/solo 模式下跳过
- [ ] 注明实现任务委托给专家 Agent（非直接完成）

---

## 导演关卡检查

在 `full` 模式下：LP-CODE-REVIEW 关卡在实现完成且所有标准验证完毕后、故事标记为 Complete 之前运行。

在 `lean` 模式下：LP-CODE-REVIEW 被跳过。输出注明："LP-CODE-REVIEW skipped — lean mode"。用户在确认后故事即标记为 Complete。

在 `solo` 模式下：LP-CODE-REVIEW 被跳过，附带等效注释。

---

## 测试用例

### 用例 1：正常流程 —— 故事实现并标记为 Complete（full 模式）

**测试夹具：**
- 故事文件存在于 `production/epics/[layer]/story-[name].md`，包含：
  - `Status: Ready`
  - 一个 TR-ID，引用注册表中的需求
  - 至少 2 条 Given-When-Then 验收标准
  - 测试证据路径
- 引用的 ADR 状态为 `Status: Accepted`
- `docs/architecture/control-manifest.md` 存在
- `.claude/docs/technical-preferences.md` 已配置引擎和语言
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/dev-story production/epics/[layer]/story-[name].md`

**预期行为：**
1. Skill 读取故事文件及所有引用的上下文
2. Skill 验证 ADR 为 Accepted（无阻塞）
3. Skill 将实现任务路由至正确的专家 Agent
4. 所有验收标准验证为已满足
5. LP-CODE-REVIEW 关卡派生并返回 APPROVED
6. Skill 询问"May I update story status to Complete?"
7. 故事状态更新为 Complete

**断言：**
- [ ] Skill 在派生任何 Agent 前先读取故事
- [ ] ADR 状态在实现开始前检查
- [ ] 实现任务委托给专家 Agent（非内联完成）
- [ ] 所有验收标准在 LP-CODE-REVIEW 前确认已满足
- [ ] LP-CODE-REVIEW 在输出中显示为已完成的关卡
- [ ] 故事状态仅在关卡批准和用户同意后才更新为 Complete
- [ ] 测试文件作为实现的一部分写入（不延迟）

---

### 用例 2：失败路径 —— 引用的 ADR 为 Proposed

**测试夹具：**
- 故事文件存在，`Status: Ready`
- 故事中 TR-ID 指向由 `Status: Proposed` 的 ADR 覆盖的需求

**输入：** `/dev-story production/epics/[layer]/story-[name].md`

**预期行为：**
1. Skill 读取故事文件
2. Skill 解析 TR-ID 并读取管辖 ADR
3. ADR 状态为 Proposed —— skill 输出 BLOCKED 消息
4. Skill 指明阻塞故事的特定 ADR
5. Skill 建议运行 `/architecture-decision` 推进 ADR
6. 实现不启动

**断言：**
- [ ] Skill 在 ADR 为 Proposed 时不开始实现
- [ ] BLOCKED 消息指明具体的 ADR 编号和标题
- [ ] Skill 建议 `/architecture-decision` 作为下一步操作
- [ ] 故事状态保持不变（不设为 In Progress 或 Complete）

---

### 用例 3：模糊的验收标准 —— Skill 要求用户澄清

**测试夹具：**
- 故事文件存在，`Status: Ready`
- 引用的 ADR 为 Accepted
- 其中一条验收标准模糊不清（非 Given-When-Then 格式；使用主观性语言，如"feels responsive"）

**输入：** `/dev-story production/epics/[layer]/story-[name].md`

**预期行为：**
1. Skill 读取故事并识别模糊的标准
2. 在路由至专家 Agent 之前，skill 要求用户澄清该标准
3. 用户提供具体、可测试的重述
4. Skill 使用澄清后的标准继续实现
5. Skill 不猜测预期行为

**断言：**
- [ ] Skill 在实现开始前指出模糊的标准
- [ ] Skill 要求用户澄清（而非自动解释）
- [ ] 实现仅在澄清提供后才开始
- [ ] 澄清后的标准用于测试（而非原始模糊版本）

---

### 用例 4：边界情况 —— 无参数；从会话状态读取

**测试夹具：**
- 未提供参数
- `production/session-state/active.md` 引用了一个活跃的故事文件
- 该故事文件存在且 `Status: In Progress`

**输入：** `/dev-story`（无参数）

**预期行为：**
1. Skill 检测到未提供参数
2. Skill 读取 `production/session-state/active.md`
3. Skill 找到活跃的故事引用
4. Skill 与用户确认："Continuing work on [story title] — is that correct?"
5. 确认后，skill 继续处理该故事

**断言：**
- [ ] Skill 在无参数时读取会话状态
- [ ] Skill 在继续前与用户确认活跃故事
- [ ] Skill 不会在未经确认的情况下静默假设活跃故事
- [ ] 若会话状态中没有活跃故事，skill 询问要实现哪个故事

---

### 用例 5：导演关卡 —— LP-CODE-REVIEW 返回 NEEDS CHANGES；lean 模式跳过关卡

**测试夹具（full 模式）：**
- 故事已实现且所有标准看起来已满足
- `production/session-state/review-mode.txt` 包含 `full`
- LP-CODE-REVIEW 关卡返回 NEEDS CHANGES 及具体反馈

**Full 模式预期行为：**
1. LP-CODE-REVIEW 关卡在实现后派生
2. 关卡返回 NEEDS CHANGES 及 2 个具体问题
3. 故事状态保持 In Progress —— 不标记为 Complete
4. 向用户展示关卡反馈并询问如何处理

**断言（full 模式）：**
- [ ] 当 LP-CODE-REVIEW 返回 NEEDS CHANGES 时，故事不标记为 Complete
- [ ] 关卡反馈原文展示给用户
- [ ] 故事状态保持 In Progress 直到问题解决且关卡通过

**测试夹具（lean 模式）：**
- 相同故事，`production/session-state/review-mode.txt` 包含 `lean`

**Lean 模式预期行为：**
1. 实现完成
2. LP-CODE-REVIEW 关卡被跳过 —— 输出中注明
3. 要求用户确认所有标准已满足
4. 用户确认后故事标记为 Complete

**断言（lean 模式）：**
- [ ] "LP-CODE-REVIEW skipped — lean mode"出现在输出中
- [ ] 用户确认标准后故事标记为 Complete（无需关卡）
- [ ] Skill 不在已跳过的关卡上阻塞

---

## 协议合规性

- [ ] 不直接编写源代码 —— 委托给专家 Agent
- [ ] 在实现前读取所有上下文（故事、TR-ID、ADR、清单、引擎偏好设置）
- [ ] "May I write"在更新故事状态和写入代码文件前询问
- [ ] 跳过的关卡在输出中按名称和模式注明
- [ ] 故事完成后更新 `production/session-state/active.md`
- [ ] 末尾包含下一步交接指引：`/story-done`

---

## 覆盖范围注释

- 引擎路由逻辑（Godot vs Unity vs Unreal）不按引擎分别测试 —— 路由模式一致；引擎选择为配置事实。
- Visual/Feel 和 UI 故事类型（无需自动化测试）具有不同的证据要求，本文档未涵盖这些用例。
- Integration 故事类型遵循与 Logic 相同的模式，但证据路径不同 —— 不独立进行测试夹具测试。
