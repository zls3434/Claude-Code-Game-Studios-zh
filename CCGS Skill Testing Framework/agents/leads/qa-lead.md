<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：qa-lead

## Agent 摘要
**拥有的领域：** 测试策略、QL-STORY-READY gate、QL-TEST-COVERAGE gate、bug 严重性分诊、发布质量 gate。
**不拥有：** 功能实现（程序员）、游戏设计决策、创意方向、生产排期。
**Model tier：** Sonnet（单个系统分析 — story 就绪状态和覆盖评估）。
**处理的 Gate ID：** QL-STORY-READY、QL-TEST-COVERAGE。

---

## 静态断言（结构性）

通过阅读 agent 的 `.claude/agents/qa-lead.md` frontmatter 验证：

- [ ] `description:` 字段存在且领域特定（引用测试策略、story 就绪、覆盖、bug 分诊 — 非泛化描述）
- [ ] `allowed-tools:` 列表以读取为主；可包含 Read 用于 story 文件、测试文件和 coding-standards；仅当需运行测试命令时才包含 Bash
- [ ] Model tier 按 coordination-rules.md 为 `claude-sonnet-4-6`
- [ ] Agent 定义不声称对实现决策或游戏设计拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出格式
**Scenario：** 一个关于「玩家受到危险格伤害」的 story 被提交进行就绪检查。该 story 有三个验收标准：(1) 玩家生命值减少危险格伤害值，(2) 播放伤害视觉反馈，(3) 玩家 0.5 秒内无法再次受伤（无敌窗口）。所有三个 AC 都是可衡量且具体的。请求标记为 QL-STORY-READY。
**预期：** 返回 `QL-STORY-READY: ADEQUATE`，附理由确认所有三个 AC 存在、具体且可测试。
**断言：**
- [ ] 裁决恰好为 ADEQUATE / INADEQUATE 之一
- [ ] 裁决 token 格式为 `QL-STORY-READY: ADEQUATE`
- [ ] 理由引用具体的 AC 数量（3）并确认每个可衡量
- [ ] 输出保持在 QA 范围内 — 不评论该机制是否设计得好

### Case 2：领域外请求 — 重定向或升级
**Scenario：** 开发者请 qa-lead 实现新物理系统的自动化测试框架。
**预期：** Agent 拒绝实现测试代码，并重定向到适当的程序员（gameplay-programmer 或 lead-programmer）。
**断言：**
- [ ] 不编写或提出代码实现
- [ ] 明确命名 `lead-programmer` 或 `gameplay-programmer` 为实现方面的正确处理者
- [ ] 可定义测试应验证什么（测试策略），但将代码编写转交程序员

### Case 3：Gate 裁决 — 正确的词汇
**Scenario：** 一个关于「战斗感到响应灵敏且有冲击力」的 story 被提交进行就绪检查。唯一的验收标准写着："战斗应对玩家感觉良好。"这是主观且不可衡量的。请求标记为 QL-STORY-READY。
**预期：** 返回 `QL-STORY-READY: INADEQUATE`，具体识别不可衡量的 AC，并提供如何使其可测试的指导（例如"输入到命中反馈延迟 ≤ 100ms"）。
**断言：**
- [ ] 裁决恰好为 ADEQUATE / INADEQUATE 之一 — 非自由文本
- [ ] 裁决 token 格式为 `QL-STORY-READY: INADEQUATE`
- [ ] 理由识别未能满足可衡量性要求的具体 AC
- [ ] 提供如何重写 AC 使其可测试的可操作指导

### Case 4：冲突升级 — 正确的父级
**Scenario：** gameplay-programmer 和 qa-lead 在一个测试上存在分歧，该测试断言「敌人巡逻路径在 5 秒内访问所有路径点」是否足够确定以成为有效的自动化测试。gameplay-programmer 认为时间可变性使其不稳定；qa-lead 认为可以接受。
**预期：** qa-lead 承认技术不稳定性的顾虑，并升级到 lead-programmer，请求对自动化测试可接受的确定性标准做出技术裁决。
**断言：**
- [ ] 升级到 `lead-programmer` 进行确定性标准的技术裁决
- [ ] 不单方面推翻 gameplay-programmer 的不稳定性顾虑
- [ ] 清晰框定升级："这是技术标准问题，不是 QA 覆盖问题"
- [ ] 不放弃覆盖要求 — 如果当前方法被裁定为不稳定，请求确定性的替代方案

### Case 5：上下文传递 — 使用提供的上下文
**Scenario：** Agent 收到一个 gate 上下文块，其中包含 coding-standards.md 的测试标准部分，规定：Logic story 需要阻塞式自动化单元测试，Visual/Feel story 需要截图 + lead 签字（建议性），Config/Data story 需要冒烟检查通过（建议性）。一个分类为"Logic"类型的 story 被提交，仅有一个手动走查文档作为证据。
**预期：** 评估引用 coding-standards.md 中具体的测试证据要求，识别"Logic"story 需要自动化单元测试（而非仅手动走查），并返回 INADEQUATE，附所引用的具体要求。
**断言：**
- [ ] 引用所提供上下文中具体的 story 类型分类（"Logic"）
- [ ] 引用 coding-standards.md 中 Logic story 的具体证据要求（自动化单元测试）
- [ ] 识别提交的证据类型（手动走查）对于此 story 类型不充分
- [ ] 不将建议性级别的要求作为阻塞式要求应用

---

## 协议合规性

- [ ] 仅使用 ADEQUATE / INADEQUATE 词汇返回 QL-STORY-READY 裁决
- [ ] 仅使用 ADEQUATE / INADEQUATE 词汇返回 QL-TEST-COVERAGE 裁决（或对于发布 gate 使用 PASS / FAIL）
- [ ] 停留在声明的 QA 和测试策略领域内
- [ ] 将技术标准争议升级到 lead-programmer
- [ ] 在输出中使用 gate ID（例如 `QL-STORY-READY: INADEQUATE`），而非内联散文式裁决
- [ ] 不做出有约束力的实现或游戏设计决策

---

## 覆盖说明
- QL-TEST-COVERAGE（对 sprint 或 milestone 的整体覆盖评估）未涵盖 — 当覆盖报告可用时应添加专用案例。
- Bug 严重性分诊（P0/P1/P2 分类）未涵盖 — 推迟到 /bug-triage skill 集成。
- 发布质量 gate 行为（PASS / FAIL 词汇变体）未涵盖。
- QL-STORY-READY 与 story Done 标准（/story-done skill）之间的交互未涵盖。
