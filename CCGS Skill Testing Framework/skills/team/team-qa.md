<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/team-qa

## Skill 摘要

编排 QA 团队通过七阶段结构化测试周期。协调 qa-lead（策略、测试计划、签收报告）和 qa-tester（测试用例编写、bug 报告编写）。覆盖范围检测、story 分类、QA 计划生成、冒烟检查关卡、测试用例编写、附带 bug 提交的手动 QA 执行，以及带有 APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED 裁定的最终签收报告。阶段 5 中对独立 story 使用并行 qa-tester 启动。

---

## 静态断言（结构）

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁定关键词：COMPLETE、BLOCKED
- [ ] 包含签收报告的裁定关键词：APPROVED、APPROVED WITH CONDITIONS、NOT APPROVED
- [ ] 对 QA 计划和签收报告均包含 "May I write" 语言
- [ ] 错误恢复协议章节存在
- [ ] 阶段转换处使用 `AskUserQuestion` 获取用户审批后再继续
- [ ] 阶段 4（冒烟检查）是硬关卡：FAIL 则停止周期
- [ ] Bug 报告写入 `production/qa/bugs/`，命名格式为 `BUG-[NNN]-[short-slug].md`
- [ ] 下一步指导因裁定而异（APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED）
- [ ] 阶段 5 中独立的 qa-tester 任务并行启动

---

## 测试用例

### 用例 1：正常路径 — 所有 story 通过手动 QA，APPROVED 裁定

**测试环境配置（Fixture）：**
- `production/sprints/sprint-03/` 存在，包含 4 个 story 文件
- Story 类型混合：1 Logic、1 Integration、2 Visual/Feel
- 所有 story 已填充验收标准
- `tests/smoke/` 包含冒烟测试列表；所有项目可验证
- `production/qa/bugs/` 中无现有 bug

**输入：** `/team-qa sprint-03`

**预期行为：**
1. 阶段 1：读取 `production/sprints/sprint-03/` 中所有 story 文件；读取 `production/stage.txt`；报告"发现 4 个 story。当前阶段：[stage]。准备开始 QA 策略？"
2. 阶段 2：通过 Task 启动 `qa-lead`；产出对所有 4 个 story 进行分类的策略表；无阻塞项标记；展示给用户；AskUserQuestion：用户选择"看起来不错——继续测试计划"
3. 阶段 3：产出 QA 计划文档；询问 "May I write the QA plan to `production/qa/qa-plan-sprint-03-[date].md`?"；批准后写入
4. 阶段 4：通过 Task 启动 `qa-lead`；审查 `tests/smoke/`；返回 PASS；报告"冒烟检查通过。继续测试用例编写。"
5. 阶段 5：对每个 Visual/Feel 和 Integration story 通过 Task 启动 `qa-tester`（2–3 个 story）；并行运行；按 story 分组展示测试用例；每组 AskUserQuestion；用户批准
6. 阶段 6：逐一查看每个已批准的 story；用户全部标记为 PASS；结果摘要："Stories PASS: 4, FAIL: 0, BLOCKED: 0"
7. 阶段 7：通过 Task 启动 `qa-lead` 产出签收报告；报告显示所有 story PASS；无 bug 提交；裁定：APPROVED；询问 "May I write this QA sign-off report to `production/qa/qa-signoff-sprint-03-[date].md`?"；批准后写入
8. 裁定：COMPLETE — QA 周期完成

**断言：**
- [ ] 阶段 1 正确计数并报告 4 个 story 及当前阶段
- [ ] 阶段 2 策略表以正确类型对所有 4 个 story 进行分类
- [ ] QA 计划仅在 "May I write?" 批准后写入
- [ ] 冒烟检查 PASS 允许流水线无需用户干预即可继续
- [ ] 阶段 5 中独立 story 的 qa-tester 任务并行发出
- [ ] 签收报告包含测试覆盖摘要表和裁定：APPROVED
- [ ] 签收报告仅在 "May I write?" 批准后写入
- [ ] 最终输出显示裁定：COMPLETE
- [ ] 下一步："运行 `/gate-check` 验证推进。"

---

### 用例 2：冒烟检查失败 — QA 周期在阶段 4 停止

**测试环境配置（Fixture）：**
- `production/sprints/sprint-04/` 存在，包含 3 个 story 文件
- `tests/smoke/` 存在，包含 5 个冒烟测试项目；2 个项目无法验证（例如构建不稳定、核心导航损坏）

**输入：** `/team-qa sprint-04`

**预期行为：**
1. 阶段 1–3 正常完成；QA 计划已写入
2. 阶段 4：通过 Task 启动 `qa-lead`；冒烟检查返回 FAIL；识别出两个具体失败项
3. Skill 报告："冒烟检查失败。QA 在这些问题解决之前无法开始：[列出 2 个失败项]。修复后重新运行 `/smoke-check`，或解决后重新运行 `/team-qa`。"
4. Skill 在阶段 4 后立即停止——不执行阶段 5、6、7
5. 不产出签收报告；不发出签收的 "May I write?"

**断言：**
- [ ] 冒烟检查 FAIL 导致流水线在阶段 4 停止——不执行阶段 5、6、7
- [ ] 失败列表明确展示给用户（非含糊总结）
- [ ] Skill 推荐 `/smoke-check` 和重新运行 `/team-qa` 作为补救步骤
- [ ] 不写入或提供 QA 签收报告
- [ ] Skill 不产出 COMPLETE 裁定
- [ ] 阶段 3 中已写入的 QA 计划被保留（不删除）

---

### 用例 3：发现 Bug — Visual/Feel story 手动 QA 失败，提交 bug 报告

**测试环境配置（Fixture）：**
- `production/sprints/sprint-05/` 存在，包含 2 个 story：1 Logic（通过自动测试）、1 Visual/Feel
- `tests/smoke/` 冒烟检查通过
- Visual/Feel story 的动画时间明显错误（验收标准未满足）
- `production/qa/bugs/` 目录存在（空或已有 bug）

**输入：** `/team-qa sprint-05`

**预期行为：**
1. 阶段 1–5 正常完成；为 Visual/Feel story 编写测试用例
2. 阶段 6：用户将 Visual/Feel story 标记为 FAIL；AskUserQuestion 收集失败描述："动画以 2 倍速播放 — 每次循环可见抖动"
3. 阶段 6：通过 Task 启动 `qa-tester` 编写正式 bug 报告；写入 `production/qa/bugs/BUG-001-animation-speed-jitter.md`（或根据已有 bug 递增编号）；报告包含严重程度字段
4. 结果摘要："Stories PASS: 1, FAIL: 1 — 已提交 bug: BUG-001"
5. 阶段 7：启动 `qa-lead` 产出签收报告；Bug 发现表列出 BUG-001 及其严重程度和状态 Open；裁定：NOT APPROVED（S1/S2 bug 未关闭，或无记录解决方法的 FAIL）
6. 提供签收报告写入；批准后写入
7. 下一步："解决 S1/S2 bug 并重新运行 `/team-qa` 或目标手动 QA 后再推进。"

**断言：**
- [ ] 阶段 6 的 FAIL 结果触发 AskUserQuestion 收集失败描述，再写入 bug 报告
- [ ] `qa-tester` 通过 Task 启动来写入 bug 报告——编排者不直接写入
- [ ] Bug 报告遵循命名约定：`BUG-[NNN]-[short-slug].md` 位于 `production/qa/bugs/`
- [ ] Bug 报告 NNN 根据目录中已有 bug 正确递增
- [ ] 阶段 7 签收报告 Bug 发现表包含 bug ID、story 名称、严重程度和状态
- [ ] 签收报告裁定为 NOT APPROVED
- [ ] 下一步明确提及重新运行 `/team-qa`
- [ ] 编排者仍发布裁定：COMPLETE（QA 周期完成——裁定为 NOT APPROVED，但 Skill 完成了其流水线）

---

### 用例 4：无参数 — Skill 推断活跃 sprint 或询问用户

**测试环境配置（变体 A — 状态文件存在）：**
- `production/session-state/active.md` 存在且包含对 `sprint-06` 的引用
- `production/sprint-status.yaml` 存在且将 `sprint-06` 标识为活跃

**测试环境配置（变体 B — 状态文件不存在）：**
- `production/session-state/active.md` 不存在
- `production/sprint-status.yaml` 不存在

**输入：** `/team-qa`（无参数）

**预期行为（变体 A）：**
1. 阶段 1：未提供参数；读取 `production/session-state/active.md`；读取 `production/sprint-status.yaml`
2. 从两个来源检测到 `sprint-06` 为活跃 sprint
3. 按 `/team-qa sprint-06` 输入继续；报告"未提供 sprint 参数——从会话状态推断为 sprint-06。发现 [N] 个 story。"

**预期行为（变体 B）：**
1. 阶段 1：未提供参数；尝试读取 `production/session-state/active.md`——文件缺失；尝试读取 `production/sprint-status.yaml`——文件缺失
2. 无法推断 sprint；使用 AskUserQuestion："QA 应覆盖哪个 sprint 或功能？" 并提供输入 sprint 标识或取消的选项

**断言：**
- [ ] 无参数时 Skill 不默认使用硬编码 sprint 名称
- [ ] Skill 在询问用户前读取 `production/session-state/active.md` 和 `production/sprint-status.yaml`（变体 A）
- [ ] 当两个状态文件都不存在时，Skill 使用 AskUserQuestion 而非猜测（变体 B）
- [ ] 推断的 sprint 在继续前报告给用户（变体 A 透明度）
- [ ] 状态文件缺失时 Skill 不出错——回退到询问（变体 B）

---

### 用例 5：混合结果 — 部分 PASS，一个 S1 bug FAIL，一个 BLOCKED

**测试环境配置（Fixture）：**
- `production/sprints/sprint-07/` 存在，包含 4 个 story 文件
- 冒烟检查通过
- Story A（Logic）：自动测试通过 — PASS
- Story B（UI）：手动 QA — PASS WITH NOTES（轻微文本溢出）
- Story C（Visual/Feel）：手动 QA — FAIL；测试人员识别到技能激活时 S1 崩溃
- Story D（Integration）：无法测试 — BLOCKED（依赖系统尚未实现）

**输入：** `/team-qa sprint-07`

**预期行为：**
1. 阶段 1–5 继续；阶段 5 测试用例覆盖 story B、C、D
2. 阶段 6：用户将 Story A 标记为隐含 PASS（已自动化）；Story B：PASS WITH NOTES；Story C：FAIL；Story D：BLOCKED
3. Story C FAIL 后：启动 qa-tester 写入 bug 报告 `BUG-001-crash-ability-activation.md`，严重程度 S1
4. 呈现结果摘要："Stories PASS: 1, PASS WITH NOTES: 1, FAIL: 1 — 已提交 bug: BUG-001 (S1), BLOCKED: 1"
5. 阶段 7：qa-lead 产出覆盖全部 4 个 story 的签收报告；BUG-001 列为 S1/Open；Story D 列为 BLOCKED；裁定：NOT APPROVED
6. "May I write?" 批准后写入签收报告
7. 下一步："解决 S1/S2 bug 并重新运行 `/team-qa` 或目标手动 QA 后再推进。"

**断言：**
- [ ] 全部 4 个 story 出现在阶段 7 签收报告测试覆盖摘要表中——无一静默遗漏
- [ ] Story D（BLOCKED）在报告中以 BLOCKED 状态列出，不静默丢弃
- [ ] S1 bug 导致裁定：NOT APPROVED，与其他 story 通过无关
- [ ] PASS WITH NOTES story 不降级为 FAIL——被单独跟踪
- [ ] BUG-001 严重程度在 Bug 发现表中列为 S1
- [ ] 部分结果被保留——即使有失败和阻塞，签收报告仍然产出
- [ ] 编排者发布裁定：COMPLETE（流水线已完成）；签收裁定为 NOT APPROVED

---

## 协议合规

- [ ] 在阶段 2（策略审查）、阶段 5（每组测试用例批准）和阶段 6（每个 story 手动 QA 结果）使用 `AskUserQuestion`
- [ ] 阶段 4 冒烟检查是硬关卡：FAIL 在阶段 4 停止流水线，无例外
- [ ] "May I write?" 对 QA 计划（阶段 3）和签收报告（阶段 7）分别询问
- [ ] Bug 报告始终通过 Task 由 `qa-tester` 写入——编排者不直接写入
- [ ] 阶段 5 中独立 story 的 qa-tester 任务尽可能并行发出
- [ ] 错误恢复：任何 BLOCKED Agent 立即呈现并提供 AskUserQuestion 选项
- [ ] 始终产出部分报告——不因一个 story 失败或阻塞而丢弃工作
- [ ] 签收裁定规则严格应用：任何 S1/S2 bug 未关闭 = NOT APPROVED；无例外
- [ ] 编排者级裁定：COMPLETE 与签收报告的 APPROVED/NOT APPROVED 裁定不同

---

## 覆盖说明

- APPROVED WITH CONDITIONS 裁定路径（S3/S4 bug、PASS WITH NOTES）通过 Case 5 的 PASS WITH NOTES story（Story B）隐式覆盖——如果不存在 S1/S2 bug，该用例将产出 APPROVED WITH CONDITIONS。裁定逻辑是表驱动的，不需要专用用例。
- `feature: [system-name]` 参数形式未单独测试——它遵循与 sprint 形式相同的阶段 1 逻辑，使用 glob 而非目录读取。无参数推断路径（Case 4）为检测逻辑提供了充分覆盖。
- 自动测试通过的 Logic story 不需要手动 QA——通过 Case 5（Story A）隐式验证，其中 Logic story 不经过手动 QA 阶段。
- 阶段 5 中并行 qa-tester 启动通过 Case 1 隐式验证（多个 Visual/Feel story 同时发出）；除静态断言检查外不需要专用并行性用例。
