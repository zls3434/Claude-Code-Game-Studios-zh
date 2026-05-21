<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：creative-director

## Agent 摘要
**拥有的领域：** 创意愿景、游戏支柱、GDD 对齐、系统分解反馈、叙事方向、试玩反馈解读、phase gate（创意方面）。
**不拥有：** 技术架构或实现细节（委托给 technical-director）、生产排期（producer）、视觉艺术风格执行（委托给 art-director）。
**Model tier：** Opus（多文档综合、高风险 phase gate 裁决）。
**处理的 Gate ID：** CD-PILLARS、CD-GDD-ALIGN、CD-SYSTEMS、CD-NARRATIVE、CD-PLAYTEST、CD-PHASE-GATE。

---

## 静态断言（结构性）

通过阅读 agent 的 `.claude/agents/creative-director.md` frontmatter 验证：

- [ ] `description:` 字段存在且领域特定（引用创意愿景、支柱、GDD 对齐 — 非泛化描述）
- [ ] `allowed-tools:` 列表以读取为主；除非创意工作流需要，不应包含 Bash
- [ ] Model tier 为 `claude-opus-4-6`（按 coordination-rules.md — 负责 gate 综合的 director = Opus）
- [ ] Agent 定义不声称对技术架构或生产排期拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出格式
**Scenario：** 一份游戏概念文档被提交进行支柱审查。该概念描述了一款围绕三个支柱构建的叙事生存游戏：「突现故事」「有意义的牺牲」和「有人情味的世界」。请求标记为 CD-PILLARS。
**预期：** 返回 `CD-PILLARS: APPROVE`，附理由说明每个支柱在概念中如何体现，以及在文档中发现的任何强化或削弱信号。
**断言：**
- [ ] 裁决恰好为 APPROVE / CONCERNS / REJECT 之一
- [ ] 裁决 token 格式为 `CD-PILLARS: APPROVE`（gate ID 前缀、冒号、裁决关键词）
- [ ] 理由按名称引用三个具体支柱，而非泛化创意建议
- [ ] 输出保持在创意范围内 — 不评论引擎可行性或 sprint 排期

### Case 2：领域外请求 — 重定向或升级
**Scenario：** 开发者请 creative-director 审查一个用于存储玩家存档数据的 PostgreSQL schema 方案。
**预期：** Agent 拒绝评估 schema 并将请求重定向到 technical-director。
**断言：**
- [ ] 不就 schema 设计做出任何有约束力的决策
- [ ] 明确将 `technical-director` 命名为正确的处理者
- [ ] 可备注数据模型是否具有创意影响（例如追踪哪些玩家数据），但完全转交结构决策

### Case 3：Gate 裁决 — 正确的词汇
**Scenario：** “制作”系统的 GDD 被提交。第 4 节（公式）定义了一个惩罚探索的资源衰减公式 — 与 Player Fantasy 节中“自由漫游无惧”的要求相矛盾。请求标记为 CD-GDD-ALIGN。
**预期：** 返回 `CD-GDD-ALIGN: CONCERNS`，具体引用公式行为与 Player Fantasy 声明之间的矛盾。
**断言：**
- [ ] 裁决恰好为 APPROVE / CONCERNS / REJECT 之一 — 非自由文本
- [ ] 裁决 token 格式为 `CD-GDD-ALIGN: CONCERNS`
- [ ] 理由引用或直接引用 GDD 第 4 节（Formulas）和 Player Fantasy 节
- [ ] 不指定具体的公式修复方案 — 这属于 systems-designer

### Case 4：冲突升级 — 正确的父级
**Scenario：** technical-director 提出一项顾虑，认为核心循环机制（实时分支对话）实现成本过高，建议砍掉。creative-director 基于创意理由反对。
**预期：** creative-director 承认技术约束，不否决 technical-director 的可行性评估，但保留定义创意目标的权力。对于冲突本身，creative-director 是顶级创意升级点，并将实现可行性的决策转交 technical-director，同时主张设计意图。解决路径是双方共同向用户呈现权衡方案。
**断言：**
- [ ] 不单方面否决 technical-director 的可行性顾虑
- [ ] 清晰区分「我们创意上想要什么」与「如何构建」
- [ ] 提议向用户呈现权衡方案，而非单方面解决
- [ ] 不声称拥有实现决策权

### Case 5：上下文传递 — 使用提供的上下文
**Scenario：** Agent 收到一个 gate 上下文块，其中包含游戏支柱文档（`design/gdd/pillars.md`）和一项待审查的新机制 spec。支柱文档将「玩家创作权」「后果持久性」「世界响应性」定义为三个核心支柱。
**预期：** 评估使用所提供文档中的精确支柱词汇，而非泛化创意启发。任何批准或顾虑都与三个命名支柱中的一个或多个相关联。
**断言：**
- [ ] 使用所提供上下文文档中的精确支柱名称
- [ ] 不生成与所提供支柱无关的泛化创意反馈
- [ ] 引用与所审查机制最相关的特定支柱
- [ ] 不引用所提供文档中不存在的支柱

---

## 协议合规性

- [ ] 仅使用 APPROVE / CONCERNS / REJECT 词汇返回裁决
- [ ] 停留在声明的创意领域内
- [ ] 通过向用户呈现权衡而非单方面否决来升级冲突
- [ ] 在输出中使用 gate ID（例如 `CD-PILLARS: APPROVE`），而非内联散文式裁决
- [ ] 不做出有约束力的跨领域决策（技术、生产、艺术执行）

---

## 覆盖说明
- 多 gate 场景（例如单次提交同时触发 CD-PILLARS 和 CD-GDD-ALIGN）未涵盖 — 推迟到集成测试。
- CD-PHASE-GATE（完整 phase 推进）涉及综合多个子 gate 结果；此复杂案例被推迟。
- 试玩报告解读（CD-PLAYTEST）未涵盖 — 应在 playtest-report skill 产出结构化输出时添加专用案例。
- 与 art-director 在视觉支柱对齐上的交互未涵盖。
