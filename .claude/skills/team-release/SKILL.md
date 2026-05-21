---
name: team-release
description: "编排发布团队：协调 release-manager、qa-lead、devops-engineer 和 producer 将发布版本从候选版推向部署。"
argument-hint: "[版本号 或 'next'] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

**参数检查：** 如果未提供版本号：
1. 读取 `production/session-state/active.md` 和 `production/milestones/` 中最近的文件（如果存在）来推断目标版本。
2. 如果找到版本：报告"未提供版本参数 — 从里程碑数据推断为 [version]。继续。"然后使用 `AskUserQuestion` 确认："发布 [version]。正确吗？"
3. 如果无法发现版本：使用 `AskUserQuestion` 询问"应发布哪个版本号？（例如 v1.0.0）"并在继续前等待用户输入。不要默认为硬编码的版本号。

当此 Skill 被调用时，通过结构化流水线编排发布团队。

**决策点：** 在每个阶段过渡时，使用 `AskUserQuestion` 将子 Agent 的提案作为可选项展示给用户。将 Agent 的完整分析写到对话中，然后用简洁的标签捕获决策。用户必须在进入下一阶段前批准。

## 第 0 阶段：解析审查模式

1. 如果传入 `--review [mode]` 参数，使用该模式。
2. 否则读取 `production/review-mode.txt` — 使用其中写入的内容。
3. 否则默认 `lean`。

模式：
- `full` — 按描述生成所有主管和牵头关卡
- `lean` — 跳过主管关卡，除非它们是 PHASE-GATE 类型（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo` — 完全跳过所有主管关卡生成；在没有任何 Agent 关卡的情况下运行 Skill

存储解析后的模式以供所有后续阶段使用。

## 团队组成
- **release-manager** — 发布分支、版本号、更新日志、部署
- **qa-lead** — 测试签收、回归套件、发布质量关卡
- **devops-engineer** — 构建流水线、产物、部署自动化
- **security-engineer** — 发布前安全审计（如果游戏有在线/多人功能或玩家数据则调用）
- **analytics-engineer** — 验证遥测事件正确触发且仪表盘已上线
- **community-manager** — 补丁说明、发布公告、面向玩家的消息
- **producer** — 进行/不进行决策、利益相关者沟通、排期

## 如何委托

使用 Task 工具将每个团队成员作为子 Agent 生成：
- `subagent_type: release-manager` — 发布分支、版本号、更新日志、部署
- `subagent_type: qa-lead` — 测试签收、回归套件、发布质量关卡
- `subagent_type: devops-engineer` — 构建流水线、产物、部署自动化
- `subagent_type: security-engineer` — 在线/多人/数据功能的安全审计
- `subagent_type: analytics-engineer` — 遥测事件验证和仪表盘就绪
- `subagent_type: community-manager` — 补丁说明和发布沟通
- `subagent_type: producer` — 进行/不进行决策、利益相关者沟通
- `subagent_type: network-programmer` — 网络代码稳定性签收（如果游戏有多人则调用）

始终向每个 Agent 的提示提供完整上下文（版本号、里程碑状态、已知问题）。在流水线允许的地方并行启动独立 Agent（例如第 3 阶段 Agent 可以同时运行）。

## 流水线

### 第 1 阶段：发布规划
委托给 **producer**：
- 确认所有里程碑验收标准已达成
- 识别本次发布中任何已推迟的范围项
- 设定目标发布日期并传达给团队
- 输出：附范围确认的发布授权

### 第 2 阶段：发布候选版
委托给 **release-manager**：
- 从约定提交点切出发布分支
- 在所有相关文件中升级版本号
- 使用 `/release-checklist` 生成发布检查清单
- 冻结分支 — 不允许功能变更，仅允许 Bug 修复
- 输出：发布分支名称和检查清单

### 第 3 阶段：质量关卡（并行）
并行委托：
- **qa-lead**：执行完整回归测试套件。测试所有关键路径。验证无 S1/S2 Bug。签收质量。
- **devops-engineer**：构建所有目标平台的发布产物。验证构建是干净的且可复现。在 CI 中运行自动化测试。
- **security-engineer** *（如果游戏有在线功能、多人或玩家数据）*：进行发布前安全审计。审查认证、反作弊、数据隐私合规。签收安全态势。
- **network-programmer** *（如果游戏有多人）*：签收网络代码稳定性。验证滞后补偿、重连处理和负载下的带宽使用。

### 第 4 阶段：本地化、性能和分析
委托（如果资源可用，可与第 3 阶段并行运行）：
- 验证所有字符串已翻译（如果有 localization-lead 则委托）
- 对照目标运行性能基准测试（如果有 performance-analyst 则委托）
- **analytics-engineer**：验证发布构建版本上所有遥测事件正确触发。确认仪表盘正在接收数据。检查关键漏斗（上手、进度、货币化如适用）已被仪器化。
- 输出：本地化、性能和分析签收

### 第 5 阶段：进行/不进行
委托给 **producer**：
- 收集来自以下方的签收：qa-lead、release-manager、devops-engineer、security-engineer（如果在第 3 阶段生成）、network-programmer（如果在第 3 阶段生成）和 technical-director
- 评估任何未决问题 — 它们是阻塞性的还是可以发布？
- 做出进行/不进行决定
- 输出：附理由的发布决定

**如果 producer 宣布不进行：**
- 立即呈现决定："PRODUCER：不进行 — [理由，例如第 3 阶段发现 S1 Bug]。"
- 使用 `AskUserQuestion` 提供选项：
  - 修复阻塞项并重新运行受影响的阶段
  - 将发布推迟到较晚日期
  - 以书面理由覆盖不进行决定（用户必须提供书面理由）
- **完全跳过第 6 阶段** — 不要打标签、部署到预发布环境、部署到生产环境或生成 community-manager。
- 生成部分报告，总结第 1–5 阶段以及哪些被跳过（第 6 阶段）及原因。
- 判定：**BLOCKED** — 发布未被部署。

用户选择"以书面理由覆盖不进行"之后：
- 询问（纯文本，不是小组件）："请描述覆盖不进行判定的理由。这将嵌入到发布记录中。"
- 等待用户的书面理由。
- 在第 6 阶段之前将理由文本嵌入部分批准记录：追加一个"⚠️ 覆盖理由：[用户文本]"字段。
- 然后才继续到第 6 阶段。

### 第 6 阶段：部署（如果进行）
委托给 **release-manager** + **devops-engineer**：
- 在版本控制中标记发布
- 使用 `/changelog` 生成更新日志
- 部署到预发布环境进行最终冒烟测试
- 部署到生产环境
- 人类团队行动：监控仪表盘和错误率 48 小时。在 48 小时标记处使用 `/retrospective` 安排后续回顾。

委托给 **community-manager**（与部署并行）：
- 使用 `/patch-notes [version]` 最终确定补丁说明
- 准备发布公告（商店页面更新、社交媒体、社区帖子）
- 如果有任何 S3+ 问题随发布附带，起草已知问题帖子
- 输出：所有面向玩家的发布沟通内容，在部署确认时即可发布

### 第 7 阶段：发布后
- **release-manager**：生成发布报告（发布了什么、推迟了什么、指标）
- **producer**：更新里程碑跟踪，向利益相关者传达
- **qa-lead**：监控传入的 Bug 报告中的回归
- **community-manager**：发布所有面向玩家的沟通内容，监控社区情绪
- **analytics-engineer**：确认线上仪表盘健康；如果任何关键事件丢失则发出告警
- 如果出现问题，安排发布后回顾

## 错误恢复协议

如果任何生成的 Agent（通过 Task）返回 BLOCKED、出错或无法完成：

1. **立即呈现**：在继续到依赖阶段之前报告"[AgentName]：BLOCKED — [reason]"
2. **评估依赖**：检查被阻塞 Agent 的输出是否被后续阶段所需。如果是，未经用户输入不得继续超过该依赖点。
3. **提供选项** 通过 AskUserQuestion 并提供选择：
   - 跳过此 Agent 并在最终报告中注明缺口
   - 以更窄范围重试
   - 在此停止并先解决阻塞项
4. **始终生成部分报告** — 输出已完成的内容。不要因为一个 Agent 阻塞就丢弃工作。

常见阻塞项：
- 输入文件缺失（故事未找到、GDD 缺失）→ 重定向到创建它的 Skill
- ADR 状态为 Proposed → 不要实现；先运行 `/architecture-decision`
- 范围太大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事之间的指令冲突 → 呈现冲突，不要猜测

## 文件写入协议

所有文件写入（发布检查清单、更新日志、补丁说明、部署脚本）都委托给子 Agent 和子 Skill。每个都强制执行"我可以写入 [path] 吗？"协议。此编排器不直接写入文件。

## 输出

一份摘要报告，涵盖：发布版本、范围、质量关卡结果、进行/不进行决定、部署状态和监控计划。

判定：**COMPLETE** — 发布已执行并部署。
判定：**BLOCKED** — 发布已停止；进行/不进行为不进行或存在未解决的硬阻塞项。

## 后续步骤

- 监控发布后仪表盘 48 小时。
- 如果发布期间出现重大问题，运行 `/retrospective`。
- 成功部署后将 `production/stage.txt` 更新为 `Live`。
