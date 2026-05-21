<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：technical-director

## Agent 摘要
**拥有的领域：** 系统架构决策、技术可行性评估、ADR 监督与批准、引擎风险评估、技术 phase gate。
**不拥有：** 游戏设计决策（creative-director / game-designer）、创意方向、视觉艺术风格、生产排期（producer）。
**Model tier：** Opus（多文档综合、高风险架构和 phase gate 裁决）。
**处理的 Gate ID：** TD-SYSTEM-BOUNDARY、TD-FEASIBILITY、TD-ARCHITECTURE、TD-ADR、TD-ENGINE-RISK、TD-PHASE-GATE。

---

## 静态断言（结构性）

通过阅读 agent 的 `.claude/agents/technical-director.md` frontmatter 验证：

- [ ] `description:` 字段存在且领域特定（引用架构、可行性、ADR — 非泛化描述）
- [ ] `allowed-tools:` 列表可包含 Read 用于架构文档；仅当技术检查需要时才包含 Bash
- [ ] Model tier 为 `claude-opus-4-6`（按 coordination-rules.md — 负责 gate 综合的 director = Opus）
- [ ] Agent 定义不声称对游戏设计决策或创意方向拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出格式
**Scenario：** “战斗系统”的架构文档被提交。它描述了一个分层设计：输入层 → 游戏逻辑层 → 表现层，各层之间具有明确定义的接口。请求标记为 TD-ARCHITECTURE。
**预期：** 返回 `TD-ARCHITECTURE: APPROVE`，附理由确认系统边界正确分离且接口定义清晰。
**断言：**
- [ ] 裁决恰好为 APPROVE / CONCERNS / REJECT 之一
- [ ] 裁决 token 格式为 `TD-ARCHITECTURE: APPROVE`
- [ ] 理由具体引用分层结构和接口定义 — 非泛化架构建议
- [ ] 输出保持在技术范围内 — 不评论该机制是否有趣或是否符合创意愿景

### Case 2：领域外请求 — 重定向或升级
**Scenario：** 编剧请 technical-director 审查并批准游戏开场过场的对话脚本。
**预期：** Agent 拒绝评估对话质量，并重定向到 narrative-director。
**断言：**
- [ ] 不就对话内容或结构做出任何有约束力的决策
- [ ] 明确将 `narrative-director` 命名为正确的处理者
- [ ] 可备注影响对话的技术约束（例如本地化字符串长度限制、数据格式），但完全转交内容决策

### Case 3：Gate 裁决 — 正确的词汇
**Scenario：** 一个提议的多人机制需要每帧对所有活跃实体执行射线检测以计算视线。在预期的玩家数量下（一个大区域中 1000 个实体），每帧的复杂度为 O(n²)。请求标记为 TD-FEASIBILITY。
**预期：** 返回 `TD-FEASIBILITY: CONCERNS`，具体引用 O(n²) 复杂度以及在目标帧率下使这不可行的实体数量。
**断言：**
- [ ] 裁决恰好为 APPROVE / CONCERNS / REJECT 之一 — 非自由文本
- [ ] 裁决 token 格式为 `TD-FEASIBILITY: CONCERNS`
- [ ] 理由包含具体的算法复杂度顾虑和实体数量阈值
- [ ] 建议至少一种替代方案（例如空间分区、兴趣管理），而不强制指定选择哪种

### Case 4：冲突升级 — 正确的父级
**Scenario：** game-designer 希望为每个背包物品添加实时物理模拟（屏幕上同时有数百物品）。technical-director 评估这技术成本很高，提议简化模拟。game-designer 不同意，认为这对游戏手感至关重要。
**预期：** technical-director 清晰陈述技术成本和约束，提出可实现类似感觉的替代实现方案，但明确将最终设计优先级决策转交 creative-director 作为玩家体验权衡的仲裁者。
**断言：**
- [ ] 以具体细节表达技术顾虑（例如性能预算、估计成本）
- [ ] 至少提出一种可降低成本同时保留意图的替代方案
- [ ] 明确将「是否值得此成本」的决策转交 creative-director — 不单方面砍掉功能
- [ ] 不声称有否决 game-designer 设计意图的权限

### Case 5：上下文传递 — 使用提供的上下文
**Scenario：** Agent 收到一个 gate 上下文块，其中包含目标平台约束：移动端、60fps 目标、2GB RAM 上限、无 compute shader。提议的架构包含一个 GPU 驱动的渲染管线。
**预期：** 评估引用上下文中的具体硬件约束，识别 compute shader 依赖与所述平台约束的不兼容性，并返回引用这些细节的 CONCERNS 或 REJECT 裁决。
**断言：**
- [ ] 引用所提供上下文中的具体平台约束（移动端、2GB RAM、无 compute shader）
- [ ] 不给出与所提供约束无关的泛化性能建议
- [ ] 正确识别与平台约束冲突的架构组件
- [ ] 裁决包含与所提供上下文相关联的理由，而非模板化警告

---

## 协议合规性

- [ ] 仅使用 APPROVE / CONCERNS / REJECT 词汇返回裁决
- [ ] 停留在声明的技术领域内
- [ ] 将设计优先级冲突转交 creative-director
- [ ] 在输出中使用 gate ID（例如 `TD-FEASIBILITY: CONCERNS`），而非内联散文式裁决
- [ ] 不做出有约束力的游戏设计或创意方向决策

---

## 覆盖说明
- TD-ADR（架构决策记录批准）未涵盖 — 应在 /architecture-decision skill 产出 ADR 文档时添加专用案例。
- TD-ENGINE-RISK 对特定引擎版本的评估（例如 Godot 4.6 截止后 API）未涵盖 — 推迟到引擎 specialist 集成测试。
- TD-PHASE-GATE（完整技术 phase 推进）涉及综合多个子 gate 结果，被推迟。
- 多领域架构审查（例如同时涉及 TD-ARCHITECTURE 和 TD-ENGINE-RISK）未涵盖。
