<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/team-polish

## Skill 摘要

编排打磨团队通过六阶段流水线：性能评估（performance-analyst）→ 优化（performance-analyst，当发现引擎级别根因时可选配 engine-programmer）→ 视觉打磨（technical-artist，与阶段 2 并行）→ 音频打磨（sound-designer，与阶段 2 并行）→ 加固（qa-tester）→ 签收（编排者收集所有结果并发布 READY FOR RELEASE 或 NEEDS MORE WORK）。在每个阶段转换处使用 `AskUserQuestion`。engine-programmer 仅在阶段 1 识别出引擎级别根因时有条件地启动。裁定为 READY FOR RELEASE 或 NEEDS MORE WORK。

---

## 静态断言（结构）

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁定关键词：READY FOR RELEASE、NEEDS MORE WORK
- [ ] 包含"文件写入协议"章节
- [ ] 文件写入委托给子 Agent——编排者不直接写入文件
- [ ] 子 Agent 在任何写入前执行 "May I write to [path]?" 协议
- [ ] 末尾有下一步交接（引用 `/release-checklist`、`/sprint-plan update`、`/gate-check`）
- [ ] 错误恢复协议章节存在
- [ ] 阶段转换前使用 `AskUserQuestion` 获取用户审批再继续
- [ ] 阶段 3（视觉打磨）和阶段 4（音频打磨）明确声明与阶段 2 并行运行
- [ ] engine-programmer 仅在阶段 1 识别出引擎级别根因时在阶段 2 中有条件地启动
- [ ] 阶段 6 签收在发布裁定前将指标与预算进行比较

---

## 测试用例

### 用例 1：正常路径 — 完整流水线完成，READY FOR RELEASE 裁定

**测试环境配置（Fixture）：**
- 功能存在且功能完整（例如 `combat` 系统）
- 性能预算在 technical-preferences.md 中已定义（例如目标 60fps、16ms 帧预算）
- 打磨开始前不存在帧预算违规
- 音频事件不缺失；VFX 资源完整
- 打磨变更未引入回归问题

**输入：** `/team-polish combat`

**预期行为：**
1. 阶段 1：启动 performance-analyst；对 combat 系统进行性能分析，测量帧预算，检查内存使用；输出：性能报告显示所有指标在预算内，无违规
2. `AskUserQuestion` 展示性能报告；用户在阶段 2、3、4 开始前批准
3. 阶段 2：performance-analyst 应用轻微优化（例如：draw call 批处理）；无需 engine-programmer（未识别出引擎级别根因）
4. 阶段 3 和 4 与阶段 2 并行启动：
   - 阶段 3：technical-artist 审查 VFX 质量，优化粒子系统，添加屏幕震动和视觉润色
   - 阶段 4：sound-designer 审查音频事件的完整性，检查混音水平，添加环境音频层
5. 三个并行阶段全部完成；`AskUserQuestion` 展示结果；用户在阶段 5 开始前批准
6. 阶段 5：qa-tester 运行边界用例测试、浸泡测试、压力测试和回归测试；全部通过
7. `AskUserQuestion` 展示测试结果；用户在阶段 6 前批准
8. 阶段 6：编排者收集所有结果；对比打磨前后的性能指标与预算；所有指标通过
9. 子 Agent 在写入前询问 "May I write the polish report to `production/qa/evidence/polish-combat-[date].md`?"
10. 裁定：READY FOR RELEASE

**断言：**
- [ ] performance-analyst 在阶段 1 中先于其他 Agent 启动
- [ ] `AskUserQuestion` 在阶段 1 输出后、阶段 2/3/4 启动前出现
- [ ] 阶段 3 和 4 的 Task 调用与阶段 2 同时发出（非阶段 2 完成后）
- [ ] 当阶段 1 未发现引擎级别根因时，不启动 engine-programmer
- [ ] qa-tester（阶段 5）在并行阶段完成且用户批准后才启动
- [ ] 阶段 6 裁定基于指标与已定义预算的对比
- [ ] 总结报告包含：打磨前后的性能指标、视觉打磨变更、音频打磨变更、测试结果
- [ ] 编排者不直接写入任何文件
- [ ] 裁定：READY FOR RELEASE

---

### 用例 2：性能阻塞 — 帧预算违规无法完全解决

**测试环境配置（Fixture）：**
- 打磨目标功能：`particle-storm` VFX 系统
- 阶段 1 识别到帧预算违规：particle-storm 在目标硬件上花费 12ms（该系统的预算为 6ms）
- 阶段 2 performance-analyst 应用优化后将开销降至 9ms——仍超过 6ms 预算
- 阶段 2 在不进行根本性设计变更的情况下无法完全解决违规

**输入：** `/team-polish particle-storm`

**预期行为：**
1. 阶段 1：performance-analyst 识别到 12ms 帧开销 vs 6ms 预算；报告"帧预算违规：particle-storm 花费 12ms，预算为 6ms"
2. `AskUserQuestion` 展示违规；用户选择继续尝试优化
3. 阶段 2：performance-analyst 应用优化；达到 9ms——已降低但仍超预算；报告"优化将开销降至 9ms（原 12ms）——超预算 3ms。不做设计变更无法进一步改善。"
4. 阶段 3 和 4 与阶段 2 并行运行（视觉和音频打磨）
5. 阶段 5：qa-tester 运行回归和边界用例测试；全部通过
6. 阶段 6：编排者收集结果；帧预算违规（9ms vs 6ms 预算）仍未解决
7. 裁定：NEEDS MORE WORK
8. 报告列出具体未解决问题："particle-storm 帧开销（9ms）超出预算（6ms）3ms——需要范围缩减或预算重新协商"
9. 下一步：在 `/sprint-plan update` 中安排剩余问题；修复后重新运行 `/team-polish`

**断言：**
- [ ] 阶段 1 中使用具体数字标记帧预算违规（实际值 vs 预算值）
- [ ] 阶段 2 明确报告优化后的指标（达到 9ms，仍超 3ms）
- [ ] 当预算违规仍然存在时，裁定为 NEEDS MORE WORK（非 READY FOR RELEASE）
- [ ] 具体未解决问题按名称列出，并量化剩余差距
- [ ] 下一步引用 `/sprint-plan update` 来安排剩余修复
- [ ] 阶段 3 和 4 仍然运行（打磨工作不因阶段 2 部分解决而放弃）
- [ ] 阶段 5 qa-tester 仍然运行（回归测试独立于性能结果）

---

### 用例 3：无参数 — 显示使用说明

**测试环境配置（Fixture）：**
- 任意项目状态

**输入：** `/team-polish`（无参数）

**预期行为：**
1. Skill 检测到未提供参数
2. 输出使用说明：例如 "用法：`/team-polish [功能或区域]` — 指定需要打磨的功能或区域（例如 `combat`、`main menu`、`inventory system`、`level-1`）"
3. Skill 退出，不启动任何 Agent

**断言：**
- [ ] 无参数时 Skill 不启动任何 Agent
- [ ] 使用消息包含正确的调用格式和参数示例
- [ ] Skill 不尝试从项目文件中猜测功能名称
- [ ] 不使用 `AskUserQuestion`——输出是直接指导

---

### 用例 4：引擎级瓶颈 — engine-programmer 在阶段 2 中有条件启动

**测试环境配置（Fixture）：**
- 打磨目标功能：`open-world` 环境流式加载
- 阶段 1 识别到一个性能瓶颈，根因在渲染流水线中："draw call 开销由引擎空间索引器的场景树遍历导致——这是一个引擎级问题，而非游戏代码问题"
- 性能预算已定义；渲染开销超出目标帧预算

**输入：** `/team-polish open-world`

**预期行为：**
1. 阶段 1：performance-analyst 对环境进行性能分析；识别到帧预算违规；根因分析指向引擎级渲染流水线（空间索引器遍历开销）
2. 阶段 1 输出明确将根因归类为引擎级
3. `AskUserQuestion` 展示包含引擎级根因的性能报告；用户在阶段 2 前批准
4. 阶段 2：同时启动 performance-analyst（用于游戏代码级优化）和 engine-programmer（用于引擎级渲染修复）
5. 阶段 3 和 4 也与阶段 2 并行运行（视觉和音频打磨）
6. engine-programmer 解决空间索引器遍历问题；提供性能分析验证，显示修复降低了开销
7. 阶段 5：qa-tester 运行回归测试，包括对引擎级修复的测试
8. 阶段 6：编排者收集所有结果；若指标现在在预算内，裁定为 READY FOR RELEASE；否则为 NEEDS MORE WORK

**断言：**
- [ ] 除非阶段 1 明确识别了引擎级根因，否则阶段 2 中不启动 engine-programmer
- [ ] 当阶段 1 识别引擎级根因时，阶段 2 中启动 engine-programmer
- [ ] 阶段 2 中 engine-programmer 和 performance-analyst 的 Task 调用同时发出（非顺序执行）
- [ ] 阶段 3 和 4 也与阶段 2 并行运行（非推迟到阶段 2 完成后）
- [ ] engine-programmer 的输出包含修复的性能分析验证
- [ ] 阶段 5 中 qa-tester 运行覆盖引擎级变更的回归测试
- [ ] 裁定正确反映包括引擎修复在内的所有指标是否满足预算

---

### 用例 5：发现回归 — 打磨变更破坏了现有功能

**测试环境配置（Fixture）：**
- 打磨目标功能：`inventory-ui`
- 阶段 1–4 成功完成；性能和打磨变更已应用
- 阶段 5：qa-tester 运行回归测试，发现阶段 3 中应用的着色器优化破坏了物品悬停高亮发光效果——一个在打磨前正常工作的现有功能

**输入：** `/team-polish inventory-ui`（阶段 5 场景）

**预期行为：**
1. 阶段 1–4 完成；打磨变更包括 technical-artist 的着色器优化
2. 阶段 5：qa-tester 运行回归测试并检测到"物品悬停高亮发光不再渲染——回归由阶段 3 的着色器优化引入"
3. qa-tester 返回包含此回归说明的测试结果
4. 编排者立即呈现此回归："qa-tester：发现回归 — `item-highlight-hover` 发光被阶段 3 着色器优化破坏"
5. 子 Agent 在写入前询问 "May I write the bug report to `production/qa/evidence/bug-polish-inventory-ui-[date].md`?"
6. 批准后写入 bug 报告；包含：损坏的行为、导致问题的打磨变更、复现步骤、严重程度
7. `AskUserQuestion` 展示回归并提供选项：
   - 回滚着色器优化并寻找替代方案
   - 修复着色器优化以保留发光效果
   - 接受回归并在下一 sprint 中安排修复
8. 裁定：NEEDS MORE WORK（无论用户选择何种解决路径，只要修复未在当前会话中应用，回归即存在）

**断言：**
- [ ] 回归在阶段 6 签收前被呈现
- [ ] 具体损坏行为和导致问题的变更在报告中均被命名
- [ ] 子 Agent 在提交前询问 "May I write the bug report to [path]?"
- [ ] Bug 报告包含：损坏行为、因果关系变更、复现步骤、严重程度
- [ ] `AskUserQuestion` 提供包括回滚、就地修复和稍后安排在内的选项
- [ ] 当存在未解决的回归时，裁定为 NEEDS MORE WORK
- [ ] 仅当回归在当前打磨会话中修复且 qa-tester 重新运行确认后，裁定才可能变为 READY FOR RELEASE

---

## 协议合规

- [ ] 阶段 1（评估）必须在其他任何阶段开始前完成
- [ ] 每个阶段输出后使用 `AskUserQuestion`，再进入下一阶段
- [ ] 阶段 3 和 4 始终与阶段 2 并行启动（非推迟）
- [ ] engine-programmer 仅在阶段 1 明确识别引擎级根因时启动
- [ ] 编排者不直接写入任何文件——所有写入委托给子 Agent
- [ ] 每个子 Agent 在任何写入前执行 "May I write to [path]?" 协议
- [ ] 任何 Agent 的 BLOCKED 状态立即呈现——不静默跳过
- [ ] 当部分 Agent 完成而其他 Agent 阻塞时，始终产出部分报告
- [ ] 裁定仅限于 READY FOR RELEASE 或 NEEDS MORE WORK——不使用其他裁定值
- [ ] NEEDS MORE WORK 裁定始终列出带严重程度的具体剩余问题
- [ ] 下一步交接引用 `/release-checklist`（成功时）和 `/sprint-plan update` + `/gate-check`（失败时）

---

## 覆盖说明

- tools-programmer 可选 Agent（用于内容流水线工具验证）未单独测试——它遵循与 engine-programmer 相同的条件启动模式，仅在打磨区域涉及内容创作工具时调用。
- 错误恢复协议中的"以更窄范围重试"和"跳过此 Agent"解决路径未单独测试——它们遵循与 Cases 2 和 5 中验证过的相同 `AskUserQuestion` + 部分报告模式。
- 阶段 6 签收逻辑（收集和对比所有指标）通过 Cases 1 和 2 隐式验证。READY FOR RELEASE 与 NEEDS MORE WORK 的区别在这些用例中以两个方向得到覆盖。
- 浸泡测试和压力测试（阶段 5）通过 Case 1 的 qa-tester 输出隐式验证。Case 5 聚焦于阶段 5 的回归检测方面。
- 阶段 5 中的"最低规格硬件"测试路径未单独测试——当硬件可用时，它遵循相同的 qa-tester 委托模式。
