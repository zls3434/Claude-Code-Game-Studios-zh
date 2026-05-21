<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/team-release

## Skill 摘要

编排发布团队通过七阶段流水线，从发布候选版本到部署和发布后监控。协调 release-manager、qa-lead、devops-engineer、producer、security-engineer（可选，在线/多人游戏必需）、network-programmer（可选，多人游戏必需）、analytics-engineer 和 community-manager。阶段 3 Agent 并行运行。以 go/no-go 决策结束；若 producer 宣布 NO-GO，部署（阶段 6）将跳过。以发布后监控计划收尾。

---

## 静态断言（结构）

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁定关键词：COMPLETE、BLOCKED
- [ ] 在文件写入协议章节中包含 "May I write" 语言（委托给子 Agent）
- [ ] 文件写入协议章节声明编排者不直接写入文件
- [ ] 错误恢复协议章节存在，包含四个恢复选项（呈现 / 评估 / 提供选项 / 部分报告）
- [ ] 末尾有下一步交接，引用发布后监控、`/retrospective` 和 `production/stage.txt`
- [ ] 在需要用户审批才能继续的阶段转换处使用 `AskUserQuestion`
- [ ] 阶段 3 Agent（qa-lead、devops-engineer，可选 security-engineer、network-programmer）明确声明并行运行
- [ ] 阶段 6（部署）以阶段 5 的 GO 决策为条件
- [ ] security-engineer 描述为以在线功能/玩家数据为条件——非始终启动

---

## 测试用例

### 用例 1：正常路径（单机） — 所有阶段完成，版本已部署

**测试环境配置（Fixture）：**
- `production/stage.txt` 存在且包含 Production 或更高阶段
- 里程碑验收标准全部满足（producer 可确认）
- 无在线功能、无多人游戏、无玩家数据收集
- 当前分支上所有 CI 构建干净
- 无未关闭的 S1/S2 bug
- `production/sprints/` 包含此里程碑已完成的 sprint story

**输入：** `/team-release v1.0.0`

**预期行为：**
1. 阶段 1：通过 Task 启动 `producer`；确认所有里程碑验收标准满足；识别任何推迟范围；产出发布授权；展示给用户；AskUserQuestion：用户在阶段 2 前批准
2. 阶段 2：通过 Task 启动 `release-manager`；从约定提交创建发布分支；递增版本号；调用 `/release-checklist`；冻结分支；输出：分支名称和检查清单；AskUserQuestion：用户在阶段 3 前批准
3. 阶段 3（并行）：同时发出 Task 调用启动 `qa-lead`（回归套件、关键路径签收）和 `devops-engineer`（构建产物、CI 验证）；不启动 security-engineer（无在线功能）；不启动 network-programmer（无多人游戏）；两者均成功完成
4. 阶段 4：验证本地化字符串全部已翻译；`analytics-engineer` 验证遥测在发布构建上正确触发；性能基准测试通过；签收产出
5. 阶段 5：通过 Task 启动 `producer`；收集 qa-lead、release-manager、devops-engineer 的签收；无未关闭的阻塞问题；producer 宣布 GO；AskUserQuestion：用户看到 GO 决策并确认部署
6. 阶段 6：启动 `release-manager` + `devops-engineer`（并行）；在版本控制中打标签；调用 `/changelog`；部署到预发布环境；冒烟测试通过；部署到生产环境；同时启动 `community-manager` 通过 `/patch-notes v1.0.0` 完成补丁说明并准备发布公告
7. 阶段 7：release-manager 生成发布报告；producer 更新里程碑跟踪；qa-lead 开始监控回归；community-manager 发布沟通；analytics-engineer 确认实时仪表盘正常
8. 裁定：COMPLETE — 发布已执行并部署

**断言：**
- [ ] 阶段 3 中 qa-lead 和 devops-engineer 的 Task 调用同时发出，非顺序执行
- [ ] 当游戏无在线功能、多人游戏或玩家数据时，不启动 security-engineer
- [ ] 阶段 5 producer 在宣布 GO 前收集所有必需方的签收
- [ ] 阶段 6 部署仅在 GO 决策被用户确认后开始
- [ ] 阶段 6 中 `/changelog` 由 release-manager 调用（非直接写入）
- [ ] 阶段 6 中 `/patch-notes v1.0.0` 由 community-manager 调用
- [ ] 阶段 7 监控计划包含 48 小时发布后监控承诺
- [ ] 下一步建议成功部署后将 `production/stage.txt` 更新为 `Live`
- [ ] 最终输出显示裁定：COMPLETE

---

### 用例 2：Go/No-Go: NO — 阶段 3 发现 S1 bug，部署跳过

**测试环境配置（Fixture）：**
- v0.9.0 发布候选分支存在
- qa-lead 在阶段 3 回归测试期间发现一个先前未报告的主菜单 S1 崩溃
- devops-engineer 构建干净、产物就绪
- producer 知晓该 S1 bug

**输入：** `/team-release v0.9.0`

**预期行为：**
1. 阶段 1–2 正常完成；发布候选已创建
2. 阶段 3（并行）：devops-engineer 返回干净构建签收；qa-lead 返回一个识别的 S1 bug 且回归套件失败；qa-lead 声明质量关卡：NOT PASSED
3. 编排者立即呈现 qa-lead 结果："QA-LEAD：发现 S1 bug — [崩溃描述]。质量关卡：NOT PASSED。"
4. 阶段 4 谨慎继续或暂停（AskUserQuestion：继续阶段 4 还是跳到阶段 5 进行 go/no-go？）
5. 阶段 5：通过 Task 启动 `producer`；producer 收到 qa-lead 的 NOT PASSED 裁定；无 S1 签收可用；producer 宣布 NO-GO 并附理由："S1 bug [ID] 未关闭且未解决。发布不安全。"
6. AskUserQuestion：向用户展示 NO-GO 决策和 S1 bug 详情；选项：修复 bug 并重新运行、推迟发布、或覆盖（附文档化理由）
7. 阶段 6（部署）完全跳过 — 不分支标记、不部署到预发布、不部署到生产
8. 阶段 6 中不启动 community-manager（无部署可公告）
9. Skill 以部分报告结束，总结已完成内容（阶段 1–5）和被跳过的内容（阶段 6）及原因
10. 裁定：BLOCKED — 发布未部署

**断言：**
- [ ] qa-lead S1 bug 发现立即在阶段 3 完成后展示给用户 — 不压制到阶段 5
- [ ] producer 的 NO-GO 决策明确引用 S1 bug 和质量关卡结果
- [ ] 当 producer 宣布 NO-GO 时，阶段 6 部署完全跳过
- [ ] NO-GO 时不启动 community-manager 进行补丁说明或发布公告
- [ ] 部分报告清楚说明哪些阶段已完成、哪些被跳过及原因
- [ ] 裁定：BLOCKED（非 COMPLETE）当部署因 NO-GO 被跳过时
- [ ] AskUserQuestion 向用户提供解决选项（修复并重新运行 / 推迟 / 附理由覆盖）
- [ ] 覆盖路径（若选择）要求用户在进入阶段 6 前提供文档化理由

---

### 用例 3：在线游戏安全审计 — 阶段 3 中启动 security-engineer

**测试环境配置（Fixture）：**
- 游戏具有多人功能并存储玩家账户数据
- v2.1.0 发布候选存在
- qa-lead 和 devops-engineer 均返回干净签收
- 根据团队组成规则，需要 security-engineer 审计

**输入：** `/team-release v2.1.0`

**预期行为：**
1. 阶段 1–2 正常完成
2. 阶段 3（并行）：编排者检测到游戏具有在线/多人功能和玩家数据；同时发出 Task 调用启动 `qa-lead`、`devops-engineer` 和 `security-engineer`；还启动 `network-programmer` 进行网络代码稳定性签收
3. security-engineer 进行发布前安全审计：审查认证流程、反作弊存在性、数据隐私合规；返回签收
4. network-programmer 验证延迟补偿、重连处理和带宽负载下的表现；返回签收
5. 全部四个阶段 3 Agent 完成；在阶段 4 开始前收集其结果
6. 阶段 5：producer 在做出 go/no-go 决定前收集全部四个阶段 3 Agent 的签收（qa-lead、devops-engineer、security-engineer、network-programmer）
7. 剩余阶段正常进行至 COMPLETE

**断言：**
- [ ] 当游戏具有在线功能、多人游戏或玩家数据时，阶段 3 中启动 security-engineer——此项不被跳过
- [ ] 当游戏具有多人游戏时，阶段 3 中启动 network-programmer
- [ ] 全部四个阶段 3 Task 调用同时发出（qa-lead、devops-engineer、security-engineer、network-programmer）
- [ ] security-engineer 审计覆盖认证、反作弊和数据隐私合规
- [ ] 阶段 5 producer 签收收集包含 security-engineer（四方，非两方）
- [ ] security-engineer 签收前阶段 6 部署不开始
- [ ] Skill 不将 security-engineer 视为对具有玩家数据的游戏是可选的

---

### 用例 4：本地化遗漏 — 未翻译字符串阻止发布

**测试环境配置（Fixture）：**
- v1.2.0 发布候选存在
- 阶段 3（qa-lead、devops-engineer）完成，签收干净
- 阶段 4：本地化验证检测到法语本地化中有 47 个未翻译字符串（游戏本地化范围中支持的语言）
- localization-lead 可作为可委托 Agent 使用

**输入：** `/team-release v1.2.0`

**预期行为：**
1. 阶段 1–3 完成，签收干净
2. 阶段 4：本地化验证步骤检测到未翻译字符串；识别法语本地化中 47 个字符串；如可用则启动 localization-lead 评估严重程度
3. 编排者呈现："本地化遗漏：法语本地化中发现 47 个未翻译字符串。发布前需要本地化签收。"
4. AskUserQuestion：提供选项 — (a) 修复翻译并重新运行阶段 4、(b) 从此发布中移除法语本地化、(c) 按原样发布并附已知问题说明
5. 若用户选择 (a)：翻译提供后重新运行阶段 4；Skill 等待本地化签收
6. 本地化签收未完成时阶段 5 go/no-go 不进行
7. 本地化问题解决或明确豁免前发布被阻止（不进入阶段 6）

**断言：**
- [ ] 阶段 4 本地化验证检测到未翻译字符串并统计数量（不仅是"部分字符串缺失"）
- [ ] 支持语言中未翻译字符串在阶段 5 前阻止流水线
- [ ] 使用 AskUserQuestion 向用户提供解决选项 — Skill 不自动豁免
- [ ] 本地化签收待定时不调用阶段 5 go/no-go
- [ ] 若用户选择重新运行阶段 4：Skill 不需要从阶段 1 重新开始
- [ ] 若用户明确豁免（按原样发布）：豁免记录在发布报告（阶段 7）中作为已知问题
- [ ] Skill 不凭空翻译字符串来自行解除阻塞

---

### 用例 5：无参数 — Skill 推断版本或询问

**测试环境配置（变体 A — 里程碑数据存在）：**
- `production/milestones/` 存在，包含里程碑文件；最近里程碑为 "v1.1.0 — Gold"
- `production/session-state/active.md` 引用了一个版本或里程碑

**测试环境配置（变体 B — 无可发现的版本）：**
- `production/milestones/` 不存在
- `production/session-state/active.md` 不引用版本
- 无 git 标签可推断版本

**输入：** `/team-release`（无参数）

**预期行为（变体 A）：**
1. 阶段 1：未提供参数；读取 `production/session-state/active.md`；读取 `production/milestones/` 中最近里程碑文件
2. 推断 v1.1.0 为目标版本；报告"未提供版本参数——从里程碑数据推断为 v1.1.0。继续。"
3. 在开始阶段 1 正式流程前通过 AskUserQuestion 确认："发布 v1.1.0。是否正确？"
4. 按 `/team-release v1.1.0` 输入继续

**预期行为（变体 B）：**
1. 阶段 1：未提供参数；读取可用状态文件——无版本可发现
2. 使用 AskUserQuestion："应发布哪个版本号？（例如 v1.0.0）"
3. 等待用户输入后再继续

**断言：**
- [ ] 无参数时 Skill 不默认使用硬编码版本字符串
- [ ] Skill 在询问前读取 `production/session-state/active.md` 和里程碑文件（变体 A）
- [ ] 推断版本在继续前通过 AskUserQuestion 与用户确认（变体 A）
- [ ] 无版本可发现时使用 AskUserQuestion — Skill 不猜测（变体 B）
- [ ] 里程碑文件缺失时 Skill 不出错 — 回退到询问（变体 B）

---

## 协议合规

- [ ] 在每个阶段转换关卡使用 `AskUserQuestion`（阶段 1 后、阶段 2 后、阶段 3/4 有问题时后、阶段 5 go/no-go 后）
- [ ] 阶段 3 Agent 始终作为并行 Task 调用发出 — qa-lead 和 devops-engineer 永远不顺序执行
- [ ] security-engineer 基于游戏功能有条件启动 — 功能存在时永不静默跳过
- [ ] 文件写入协议：编排者从不直接调用 Write/Edit — 所有写入委托给子 Agent 或子 Skill
- [ ] 阶段 6 部署严格以阶段 5 GO 裁定为条件 — 永不自触发
- [ ] 错误恢复：任何 BLOCKED Agent 在进入依赖阶段前立即呈现
- [ ] 任何阶段失败或流水线停止时始终产出部分报告（Case 2）
- [ ] 裁定：仅部署完成时为 COMPLETE；go/no-go 为 NO 或硬阻塞未解决时为 BLOCKED
- [ ] 下一步始终包含 48 小时发布后监控、`/retrospective` 建议和 `production/stage.txt` 更新为 `Live`

---

## 覆盖说明

- 阶段 7 发布后操作（发布报告、里程碑跟踪、社区发布、仪表盘监控）通过 Case 1 隐式验证。阶段 7 是无关卡阶段且无阻塞性失败模式，不需要单独的边界用例。
- "devops-engineer 构建失败"路径未单独测试——它将在阶段 3 中以 BLOCKED 结果呈现，并遵循标准错误恢复协议（呈现 → 评估 → AskUserQuestion 选项）。此由静态断言错误恢复检查进行结构验证。
- 并行阶段 4 路径（本地化 + 性能 + 分析可与阶段 3 同时运行）是 Skill 中的文档化选项（"若资源允许可与阶段 3 并行运行"）。Case 4 将阶段 4 作为顺序关卡测试；并行变体留给 Skill 的实现判断。
- 多人游戏的 `network-programmer` 签收路径作为 Case 3 的一部分进行验证，而非单独用例，因为它遵循与 security-engineer 相同的并行启动模式。
- Case 2 中的"附文档化理由覆盖 NO-GO"路径被引用但未穷尽测试——它是 Skill 必须支持的逃生通道，其存在性由 Case 2 的 AskUserQuestion 选项断言进行验证。
