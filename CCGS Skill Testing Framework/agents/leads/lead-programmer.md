<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：lead-programmer

## Agent 摘要
**拥有的领域：** 代码架构决策、LP-FEASIBILITY gate、LP-CODE-REVIEW gate、编码规范执行、获批引擎内的技术栈决策。
**不拥有：** 游戏设计决策（game-designer）、创意方向（creative-director）、生产排期（producer）、视觉艺术方向（art-director）。
**Model tier：** Sonnet（单个系统的实现级分析）。
**处理的 Gate ID：** LP-FEASIBILITY、LP-CODE-REVIEW。

---

## 静态断言（结构性）

通过阅读 agent 的 `.claude/agents/lead-programmer.md` frontmatter 验证：

- [ ] `description:` 字段存在且领域特定（引用代码架构、可行性、代码审查、编码规范 — 非泛化描述）
- [ ] `allowed-tools:` 列表包含 Read 用于源文件；可包含 Bash 用于静态分析或测试运行；未经显式委托，不得在 `src/` 之外进行写访问
- [ ] Model tier 按 coordination-rules.md 为 `claude-sonnet-4-6`
- [ ] Agent 定义不声称对游戏设计、创意方向或生产排期拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出格式
**Scenario：** 一个新的 `CombatSystem` 实现被提交进行代码审查。该系统对所有外部引用使用依赖注入，所有公共 API 均有 doc 注释，遵循项目的命名约定，并包含所有公共方法的单元测试。请求标记为 LP-CODE-REVIEW。
**预期：** 返回 `LP-CODE-REVIEW: APPROVED`，附理由确认依赖注入使用、doc 注释覆盖率、命名约定合规性和测试覆盖率。
**断言：**
- [ ] 裁决恰好为 APPROVED / NEEDS CHANGES 之一
- [ ] 裁决 token 格式为 `LP-CODE-REVIEW: APPROVED`
- [ ] 理由引用具体的编码规范标准（DI、doc 注释、命名、测试）
- [ ] 输出保持在代码质量范围内 — 不评论该机制是否有趣或是否符合创意愿景

### Case 2：领域外请求 — 重定向或升级
**Scenario：** 团队成员请 lead-programmer 审查并批准 player damage 随等级缩放的平衡公式，检查数值是否「手感合适」。
**预期：** Agent 拒绝评估设计平衡，并重定向到 systems-designer。
**断言：**
- [ ] 不就公式平衡或手感做出任何有约束力的评估
- [ ] 明确命名 `systems-designer` 为正确的处理者
- [ ] 可备注关于该公式的代码实现顾虑（例如满级时的整数溢出风险），但将所有平衡评估转交 systems-designer

### Case 3：Gate 裁决 — 正确的词汇
**Scenario：** 一个提议的敌方 AI 寻路方法使用暴力最近邻搜索，每帧对所有其他实体进行搜索。在预期敌方数量 200+ 的情况下，以 60fps 运行时每帧复杂度为 O(n²)。请求标记为 LP-FEASIBILITY。
**预期：** 返回 `LP-FEASIBILITY: INFEASIBLE`，具体引用 O(n²) 复杂度、实体数量阈值以及相对于目标帧预算的每帧成本。
**断言：**
- [ ] 裁决恰好为 FEASIBLE / CONCERNS / INFEASIBLE 之一 — 非自由文本
- [ ] 裁决 token 格式为 `LP-FEASIBILITY: INFEASIBLE`
- [ ] 理由包含具体的算法复杂度和实体数量数字
- [ ] 建议至少一种替代方法（例如空间哈希、KD树），而不强制指定选择

### Case 4：冲突升级 — 正确的父级
**Scenario：** game-designer 希望每个 NPC 都维持完整的需求、日程和记忆模拟（类似于完整的生活模拟 AI）。lead-programmer 计算得出在目标 NPC 数量下这将超出帧预算 3 倍。game-designer 坚持该机制对游戏愿景至关重要。
**预期：** lead-programmer 以数字陈述具体的帧预算违规，提出替代方法（例如基于 LOD 的模拟、简化需求模型），但明确将「是否值得此成本或设计是否应更改」的决策转交 creative-director 作为创意仲裁者。
**断言：**
- [ ] 陈述具体的帧预算违规（例如在 N 个实体下超出预算 3 倍）
- [ ] 提出至少一个技术上可行的替代方案
- [ ] 明确将设计优先级决策转交 `creative-director`
- [ ] 不单方面砍掉或修改该机制设计

### Case 5：上下文传递 — 使用提供的上下文
**Scenario：** Agent 收到一个 gate 上下文块，其中包含项目的帧预算：每帧总计 16.67ms，其中 4ms 分配给 AI 系统。一个预估在正常条件下每帧消耗 7ms 的新 AI 行为系统被提交。
**预期：** 评估引用所提供上下文中的具体帧预算分配（4ms AI 预算），识别 7ms 估计超出分配 3ms，并返回引用这些具体数字的 CONCERNS 或 INFEASIBLE。
**断言：**
- [ ] 引用所提供上下文中的具体帧预算数字（总计 16.67ms，4ms AI 分配）
- [ ] 在比较中使用提交中的具体 7ms 估计
- [ ] 不给泛化的「这可能很慢」建议 — 引用具体数字
- [ ] 裁决理由可追溯到提供的预算约束

---

## 协议合规性

- [ ] 仅使用 APPROVED / NEEDS CHANGES 词汇返回 LP-CODE-REVIEW 裁决
- [ ] 仅使用 FEASIBLE / CONCERNS / INFEASIBLE 词汇返回 LP-FEASIBILITY 裁决
- [ ] 停留在声明的代码架构领域内
- [ ] 将设计优先级冲突转交 creative-director
- [ ] 在输出中使用 gate ID（例如 `LP-FEASIBILITY: INFEASIBLE`），而非内联散文式裁决
- [ ] 不做出有约束力的游戏设计或创意方向决策

---

## 覆盖说明
- 跨多个相互依赖系统的多文件代码审查未涵盖 — 推迟到集成测试。
- 技术债务评估和优先级排序未涵盖 — 推迟到 /tech-debt skill 集成。
- 编码规范文档更新（添加新的禁止模式）未涵盖。
- 与 qa-lead 就什么构成可测试单元（LP vs QL 边界）的交互未涵盖。
