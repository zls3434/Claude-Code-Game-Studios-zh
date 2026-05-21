<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Agent 协调规则

**语言要求：必须始终使用简体中文与用户对话，生成的文档与代码注释也必须使用简体中文编写。**

1. **纵向委派**：领导层 Agent 将任务委派给部门负责人，部门负责人再委派给专业 Agent。涉及复杂决策时，绝不可跨越层级。
2. **横向协商**：同级 Agent 可以互相协商，但不得在其领域之外做出具有约束力的决策。
3. **冲突解决**：当两个 Agent 意见不一致时，上报给共同的上级。如果没有共同的上级，设计冲突上报给 `creative-director`，技术冲突上报给 `technical-director`。
4. **变更传播**：当设计变更影响多个领域时，由 `producer` Agent 协调传播。
5. **禁止单方面跨领域变更**：Agent 未经明确委派，绝不能修改其指定目录之外的文件。

## 模型层级分配

技能和 Agent 根据任务复杂度分配到不同模型层级：

| 层级 | 模型 | 使用时机 |
|------|------|-------------|
| **Haiku** | `claude-haiku-4-5-20251001` | 只读状态检查、格式化、简单查找 — 无需创造性判断 |
| **Sonnet** | `claude-sonnet-4-6` | 实现、设计撰写、单系统分析 — 大多数工作的默认选择 |
| **Opus** | `claude-opus-4-6` | 多文档综合、高风险阶段关卡判定、跨系统整体审查 |

使用 `model: haiku` 的技能：`/help`、`/sprint-status`、`/story-readiness`、`/scope-check`、
`/project-stage-detect`、`/changelog`、`/patch-notes`、`/onboard`

使用 `model: opus` 的技能：`/review-all-gdds`、`/architecture-review`、`/gate-check`

所有其他技能默认使用 Sonnet。创建新技能时，如果该技能仅做读取和格式化，则分配 Haiku；
如果需要综合 5 个以上文档并产出高风险输出，则分配 Opus；否则不设置（默认 Sonnet）。

## 子 Agent vs Agent 团队

本项目使用两种不同的多 Agent 模式：

### 子 Agent（当前默认，始终启用）
通过单个 Claude Code 会话中的 `Task` 工具启动。所有 `team-*` 技能和编排类技能均使用此模式。
子 Agent 共享会话的权限上下文，在会话内顺序或并行运行，并将结果返回给父 Agent。

**何时并行启动**：如果两个子 Agent 的输入相互独立（互不依赖对方的输出即可开始），应同时发起两个 Task 调用，而非等待完成。示例：`/review-all-gdds` 第一阶段（一致性检查）和第二阶段（设计理论检查）相互独立 — 应同时启动。

### Agent 团队（实验性功能 — 需主动选择加入）
多个独立的 Claude Code *会话*同时运行，通过共享任务列表协调。每个会话有其自己的上下文窗口和 Token 预算。
需要设置环境变量 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`。

**使用 Agent 团队的情况**：
- 工作跨越多个子系统且不会触碰相同文件
- 每个工作流需要超过 30 分钟，且能从真正的并行处理中获益
- 高级 Agent（如 technical-director、producer）需要同时协调 3 个以上专业会话处理不同 Epic

**不使用 Agent 团队的情况**：
- 一个会话的输出是另一个会话的必要输入（应使用顺序子 Agent）
- 任务适合在单个会话上下文中完成（应使用子 Agent）
- 成本受限 — 每个团队成员都会独立消耗 Token

**当前状态**：通过 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 选择加入。正式采用时在此记录首次使用情况。

## 并行任务协议

当编排类技能启动多个独立 Agent 时：

1. 在等待任何结果之前，先发出所有独立的 Task 调用
2. 收集所有结果后再进入依赖阶段
3. 如果有任何 Agent 处于 BLOCKED 状态，立即上报 — 不可静默跳过
4. 如果部分 Agent 完成、部分 Agent 阻塞，始终产出部分报告
