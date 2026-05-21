<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：producer

## Agent 摘要
**拥有的领域：** 范围管理、sprint 规划验证、milestone 追踪、epic 优先级排序、生产 phase gate。
**不拥有：** 游戏设计决策（creative-director / game-designer）、技术架构（technical-director）、创意方向。
**Model tier：** Opus（多文档综合、高风险 phase gate 裁决）。
**处理的 Gate ID：** PR-SCOPE、PR-SPRINT、PR-MILESTONE、PR-EPIC、PR-PHASE-GATE。

---

## 静态断言（结构性）

通过阅读 agent 的 `.claude/agents/producer.md` frontmatter 验证：

- [ ] `description:` 字段存在且领域特定（引用范围、sprint、milestone、生产 — 非泛化描述）
- [ ] `allowed-tools:` 列表主要以读取为主；仅当需解析 sprint/milestone 文件时才包含 Bash
- [ ] Model tier 为 `claude-opus-4-6`（按 coordination-rules.md — 负责 gate 综合的 director = Opus）
- [ ] Agent 定义不声称对设计决策或技术架构拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出格式
**Scenario：** Sprint 7 的 sprint 计划被提交。该计划包含 12 个 story point，分配给 4 名团队成员，为期 2 周。过去 3 个 sprint 的历史速度平均为 11.5 点。请求标记为 PR-SPRINT。
**预期：** 返回 `PR-SPRINT: REALISTIC`，附理由说明计划在历史速度的一个标准差内，且容量匹配。
**断言：**
- [ ] 裁决恰好为 REALISTIC / CONCERNS / UNREALISTIC 之一
- [ ] 裁决 token 格式为 `PR-SPRINT: REALISTIC`
- [ ] 理由引用具体的 story point 数量和历史速度数据
- [ ] 输出保持在生产范围内 — 不评论 story 设计是否良好或技术是否可行

### Case 2：领域外请求 — 重定向或升级
**Scenario：** 团队成员请 producer 评估游戏的「重量制背包」机制是否有趣且引人入胜。
**预期：** Agent 拒绝评估游戏手感，并重定向到 game-designer 或 creative-director。
**断言：**
- [ ] 不就该机制的设计质量做出任何有约束力的评估
- [ ] 明确将 `game-designer` 或 `creative-director` 命名为正确的处理者
- [ ] 可备注该机制的范围是否有生产影响（例如对其他系统的依赖），但完全转交所有设计评估

### Case 3：Gate 裁决 — 正确的词汇
**Scenario：** 一个新功能提案向一个原本仅包含两个系统的 milestone 中新增三个系统（crafting、weather 和 faction reputation）。这些新增都不在当前 milestone 计划中。请求标记为 PR-SCOPE。
**预期：** 返回 `PR-SCOPE: CONCERNS`，具体标识三个未规划的系统及其在 milestone 范围文档中的缺失。
**断言：**
- [ ] 裁决恰好为 REALISTIC / CONCERNS / UNREALISTIC 之一 — 非自由文本
- [ ] 裁决 token 格式为 `PR-SCOPE: CONCERNS`
- [ ] 理由命名三个具体超出范围的系统
- [ ] 不评估这些系统是否是好的设计 — 仅评估它们是否符合计划

### Case 4：冲突升级 — 正确的父级
**Scenario：** game-designer 希望添加一个晚期机制（影响所有 gameplay 系统的动态天气），technical-director 警告这将需要额外 3 个 sprint。game-designer 与 technical-director 就该是否推进存在分歧。
**预期：** producer 不就该机制是否值得添加（设计决策）或是否可行（技术决策）做出偏向。producer 量化生产影响（3 个 sprint 的延迟、milestone 滑动风险），向用户呈现权衡，并遵循 coordination-rules.md 的冲突解决：升级到共享父级（在此情况下，因 creative-director 和 technical-director 均为顶级，将冲突浮现给用户决策）。
**断言：**
- [ ] 以具体条款量化生产影响（sprint 数量、milestone 日期滑动）
- [ ] 不做出有约束力的设计或技术决策
- [ ] 向用户浮现冲突，并明确说明范围影响
- [ ] 引用 coordination-rules.md 冲突解决协议（升级到共享父级或用户）

### Case 5：上下文传递 — 使用提供的上下文
**Scenario：** Agent 收到一个 gate 上下文块，其中包含当前 milestone 截止日期（8 周后）和过去 4 个 sprint 的速度数据（8, 10, 9, 11 点）。提交了一个 14 story point 的 sprint 计划。
**预期：** 评估使用提供的速度数据来预测 14 点是否可实现，并引用 8 周的 milestone 窗口来评估当前 sprint 的范围是否留出足够缓冲。
**断言：**
- [ ] 使用所提供上下文中的具体速度数据（非泛化估计）
- [ ] 在容量评估中引用 8 周截止日期
- [ ] 计算或估计 milestone 窗口内的剩余 sprint 数量
- [ ] 不给出与所提供截止日期和速度数据无关的泛化范围建议

---

## 协议合规性

- [ ] 仅使用 REALISTIC / CONCERNS / UNREALISTIC 词汇返回裁决
- [ ] 停留在声明的生产领域内
- [ ] 通过量化范围影响并向用户呈现来升级设计/技术冲突
- [ ] 在输出中使用 gate ID（例如 `PR-SPRINT: REALISTIC`），而非内联散文式裁决
- [ ] 不做出有约束力的游戏设计或技术架构决策

---

## 覆盖说明
- PR-EPIC（epic 级别优先级排序）未涵盖 — 应在 /create-epics skill 产出结构化 epic 文档时添加专用案例。
- PR-MILESTONE（milestone 健康度审查）未涵盖 — 推迟到与 /milestone-review skill 的集成测试。
- PR-PHASE-GATE（完整生产 phase 推进）涉及综合多个子 gate 结果，被推迟。
- 多 sprint 燃尽图和速度趋势分析未涵盖。
