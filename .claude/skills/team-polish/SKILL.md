---
name: team-polish
description: "编排打磨团队：协调 performance-analyst、technical-artist、sound-designer 和 qa-tester 来优化、打磨和硬化一个功能或区域以达到发布质量。"
argument-hint: "[要打磨的功能或区域] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

如果未提供参数，输出用法指导并退出而不生成任何 Agent：
> 用法：`/team-polish [功能或区域]` — 指定要打磨的功能或区域（例如 `combat`、`main menu`、`inventory system`、`level-1`）。不要在此使用 `AskUserQuestion`；直接输出指导。

当此 Skill 以参数调用时，通过结构化流水线编排打磨团队。

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

**主管关卡跳过规则**：在生成任何 Tier 1 主管或牵头进行审查（在 PHASE-GATE 触发器之外）之前，应用解析后的模式：如果是 solo 模式则跳过；如果是 lean 模式且这不是 PHASE-GATE 则跳过。

## 团队组成
- **performance-analyst** — 性能分析、优化、内存分析、帧预算
- **engine-programmer** — 引擎级瓶颈：渲染管线、内存、资源加载（当 performance-analyst 识别出低层根本原因时调用）
- **technical-artist** — VFX 打磨、着色器优化、视觉质量
- **sound-designer** — 音频打磨、混音、环境层、反馈音效
- **tools-programmer** — 内容管线工具验证、编辑器工具稳定性、自动化修复（当内容创作工具涉及打磨区域时调用）
- **qa-tester** — 边缘情况测试、回归测试、浸泡测试

## 如何委托

使用 Task 工具将每个团队成员作为子 Agent 生成：
- `subagent_type: performance-analyst` — 性能分析、优化、内存分析
- `subagent_type: engine-programmer` — 渲染、内存、资源加载的引擎级修复
- `subagent_type: technical-artist` — VFX 打磨、着色器优化、视觉质量
- `subagent_type: sound-designer` — 音频打磨、混音、环境层
- `subagent_type: tools-programmer` — 内容管线和编辑器工具验证
- `subagent_type: qa-tester` — 边缘情况测试、回归测试、浸泡测试

始终向每个 Agent 的提示提供完整上下文（目标功能/区域、性能预算、已知问题）。在流水线允许的地方并行启动独立 Agent（例如第 3 和第 4 阶段可以同时运行）。

## 流水线

### 第 1 阶段：评估
委托给 **performance-analyst**：
- 使用 `/perf-profile` 对目标功能/区域进行性能分析
- 识别性能瓶颈和帧预算违规
- 测量内存使用并检查泄漏
- 对照目标硬件规格进行基准测试
- 输出：附优先级优化列表的性能报告

### 第 2 阶段：优化
委托给 **performance-analyst**（根据需要加上相关程序员）：
- 修复第 1 阶段识别出的性能热点
- 优化绘制调用、减少过度绘制
- 修复内存泄漏并减少分配压力
- 验证优化不会改变玩法行为
- 输出：附前后对比指标的优化后代码

如果第 1 阶段识别出引擎级根本原因（渲染管线、资源加载、内存分配器），将这些修复并行委托给 **engine-programmer**：
- 优化引擎系统热路径
- 修复核心循环中的分配压力
- 输出：经过性能分析器验证的引擎级修复

### 第 3 阶段：视觉打磨（与第 2 阶段并行）
委托给 **technical-artist**：
- 审查 VFX 的质量和与美术圣经的一致性
- 优化粒子系统和着色器效果
- 在适当的地方添加屏幕震动、镜头效果和视觉冲击力
- 确保效果在较低设置下优雅降级
- 输出：经过打磨的视觉效果

### 第 4 阶段：音频打磨（与第 2 阶段并行）
委托给 **sound-designer**：
- 审查音频事件的完整性（是否有任何动作缺少声音反馈？）
- 检查音频混音水平 — 相对于混音，没有任何声音过响或过轻
- 为氛围添加环境音频层
- 验证音频正确播放并带空间定位
- 输出：音频打磨列表和混音说明

### 第 5 阶段：硬化
委托给 **qa-tester**：
- 测试所有边缘情况：边界条件、快速输入、异常序列
- 浸泡测试：长时间运行功能检查是否有退化
- 压力测试：最大实体数、最坏情况场景
- 回归测试：验证打磨变更没有破坏已有功能
- 在最低规格硬件上测试（如果可用）
- 输出：附任何剩余问题的测试结果

### 第 6 阶段：签收
- 收集所有团队成员的结果
- 将性能指标与预算进行比较
- 报告：READY FOR RELEASE / NEEDS MORE WORK
- 列出任何剩余问题及其严重性和建议

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

所有文件写入（性能报告、测试结果、证据文档）都委托给通过 Task 生成的子 Agent。每个子 Agent 强制执行"我可以写入 [path] 吗？"协议。此编排器不直接写入文件。

## 输出

一份摘要报告，涵盖：性能前后对比指标、视觉打磨变更、音频打磨变更、测试结果和发布就绪评估。

## 后续步骤

- 如果 READY FOR RELEASE：运行 `/release-checklist` 进行最终发布前验证。
- 如果 NEEDS MORE WORK：在 `/sprint-plan update` 中排期剩余问题，修复后重新运行 `/team-polish`。
- 运行 `/gate-check` 在移交发布前获取正式的阶段关卡判定。
