<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/team-live-ops

## Skill 摘要

编排 live-ops 团队通过 7 阶段规划流水线产出赛季或活动计划。协调 live-ops-designer、economy-designer、analytics-engineer、community-manager、narrative-director 和 writer。阶段 3 和 4（经济设计和分析）同时运行。最终产出综合赛季计划，需要用户审批后方可交接给制作。

---

## 静态断言（结构）

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁定关键词：COMPLETE、BLOCKED
- [ ] 文件写入协议章节包含 "May I write" 语言（委托给子 Agent）
- [ ] 具有说明编排者不直接写入文件的"文件写入协议"章节
- [ ] 末尾有下一步交接，引用 `/design-review`、`/sprint-plan` 和 `/team-release`
- [ ] 阶段转换处使用 `AskUserQuestion` 获取用户审批再继续
- [ ] 明确声明阶段 3 和 4 可同时运行（并行启动）
- [ ] 错误恢复章节存在（或通过 BLOCKED 处理隐式存在）
- [ ] 输出文档章节指定路径在 `design/live-ops/seasons/` 下

---

## 测试用例

### 用例 1：正常路径 — 全部 7 个阶段完成，产出赛季计划

**测试环境配置（Fixture）：**
- `design/live-ops/economy-rules.md` 存在，包含当前经济配置
- `design/live-ops/ethics-policy.md` 存在，包含项目伦理政策
- 游戏概念文档存在于其标准路径
- 正在规划的新赛季名称无现有赛季文档

**输入：** `/team-live-ops "Season 2: The Frozen Wastes"`

**预期行为：**
1. 阶段 1：通过 Task 启动 `live-ops-designer`；收到包含范围、内容清单和留存机制的赛季简报；展示给用户
2. AskUserQuestion：用户在阶段 2 开始前批准阶段 1 输出
3. 阶段 2：通过 Task 启动 `narrative-director`；读取阶段 1 赛季简报；产出叙事框架文档（主题、故事钩子、背景知识关联）；展示给用户
4. 阶段 3 和 4（并行）：同时通过两个 Task 调用启动 `economy-designer` 和 `analytics-engineer`，无需等待任一结果；economy-designer 读取 `design/live-ops/economy-rules.md`
5. 阶段 5：并行启动 `narrative-director` 和 `writer`，产出游戏内叙事文本和面向玩家的文案；两者均读取阶段 2 叙事框架文档
6. 阶段 6：通过 Task 启动 `community-manager`；读取赛季简报、经济设计和叙事框架；产出通信日历及草稿文案
7. 阶段 7：收集所有阶段输出；展示综合赛季计划摘要，包括经济健康检查、分析就绪状态、伦理审查和未决问题
8. AskUserQuestion：用户批准完整赛季计划
9. 子 Agent 在写入前依次询问 "May I write to `design/live-ops/seasons/S2_The_Frozen_Wastes.md`?"、`...analytics.md` 和 `...comms.md`
10. 裁定：COMPLETE — 赛季计划已产出并交接给制作

**断言：**
- [ ] 全部 7 个阶段按顺序执行；阶段 3 和 4 作为并行 Task 调用发出
- [ ] 阶段 7 综合摘要包含全部六个部分（赛季简报、叙事框架、经济设计、分析计划、内容清单、通信日历）
- [ ] 阶段 7 中的伦理审查部分明确引用 `design/live-ops/ethics-policy.md`
- [ ] 三个输出文档以正确的命名约定写入 `design/live-ops/seasons/`
- [ ] 文件写入委托给子 Agent——编排者不直接写入
- [ ] 最终输出中出现裁定 COMPLETE
- [ ] 下一步引用 `/design-review`、`/sprint-plan` 和 `/team-release`

---

### 用例 2：发现伦理违规 — 奖励元素违反伦理政策

**测试环境配置（Fixture）：**
- 所有标准 live-ops 配置存在（economy-rules.md、ethics-policy.md）
- `design/live-ops/ethics-policy.md` 明确禁止针对 18 岁以下玩家的战利品箱
- economy-designer（阶段 3）提出了包含随机化高级奖励且无保底计时器的"Mystery Chest"机制

**输入：** `/team-live-ops "Season 3: Shadow Tournament"`

**预期行为：**
1. 阶段 1–4 正常进行；economy-designer 提出 Mystery Chest 机制
2. 阶段 7：编排者对照伦理政策审查阶段 3 输出；将 Mystery Chest 识别为违反伦理政策中"禁止不透明的随机高级奖励"规则
3. 阶段 7 摘要的伦理审查部分明确标记违规："伦理标记：阶段 3 经济设计中的 Mystery Chest 机制违反了 [政策规则]。在此问题解决之前审批被阻止。"
4. 在提供赛季计划审批之前，AskUserQuestion 展示解决方案选项
5. 在伦理违规被解决或用户明确豁免之前，Skill 不发布 COMPLETE 裁定或写入输出文档

**断言：**
- [ ] 阶段 7 伦理审查部分明确命名违规元素及其违反的政策规则
- [ ] 存在伦理违规时，Skill 不自动批准赛季计划
- [ ] 使用 AskUserQuestion 呈现违规并提供解决方案选项（修订经济设计、以书面理由覆盖、取消）
- [ ] 违规未解决时不写入输出文档
- [ ] 若用户选择修订：Skill 在返回阶段 7 审查前重新启动 economy-designer 产出修正后的设计
- [ ] 仅当伦理标记清除后才发布 COMPLETE 裁定

---

### 用例 3：无参数 — 显示使用说明

**测试环境配置（Fixture）：**
- 任意项目状态

**输入：** `/team-live-ops`（无参数）

**预期行为：**
1. 阶段 1：检测到无参数
2. 输出："用法：`/team-live-ops [赛季名称或活动描述]` — 提供要规划的赛季或 live 活动的名称或描述。"
3. Skill 立即退出，不启动任何子 Agent

**断言：**
- [ ] Skill 不猜测赛季名称或虚构范围
- [ ] 错误消息包含正确的用法格式和 argument-hint
- [ ] 参数检查失败前不发出任何 Task 调用
- [ ] 不读取或写入任何文件

---

### 用例 4：并行阶段验证 — 阶段 3 和 4 同时运行

**测试环境配置（Fixture）：**
- 所有标准 live-ops 配置存在
- 阶段 1（赛季简报）和阶段 2（叙事框架）已获批准
- 阶段 3（economy-designer）和阶段 4（analytics-engineer）的输入彼此独立

**输入：** `/team-live-ops "Season 1: The First Thaw"`（在阶段 3/4 转换处观察）

**预期行为：**
1. 阶段 2 被用户批准后，编排者在等待任一结果之前同时发出两个 Task 调用（economy-designer 和 analytics-engineer）
2. 两个 Agent 都收到赛季简报作为上下文；analytics-engineer 不等待 economy-designer 的输出即可开始
3. 阶段 5 开始前一起收集 economy-designer 和 analytics-engineer 的输出
4. 若两个并行 Agent 中的一个阻塞，另一个继续；报告部分结果

**断言：**
- [ ] 阶段 3 和 4 的两个 Task 调用在等待任一结果之前发出——非顺序执行
- [ ] analytics-engineer 提示不包含 economy-designer 输出作为必需输入（输入是独立的）
- [ ] 若 economy-designer 阻塞但 analytics-engineer 成功，analytics 输出被保留，阻塞通过 AskUserQuestion 呈现
- [ ] 阶段 5 在两个阶段 3 和 4 的结果都被收集后才开始
- [ ] Skill 文档明确声明"阶段 3 和 4 可同时运行"

---

### 用例 5：缺失伦理政策 — `design/live-ops/ethics-policy.md` 不存在

**测试环境配置（Fixture）：**
- `design/live-ops/economy-rules.md` 存在
- `design/live-ops/ethics-policy.md` 不存在
- 所有其他配置存在

**输入：** `/team-live-ops "Season 4: Desert Heat"`

**预期行为：**
1. 阶段 1–4 进行；economy-designer 和 analytics-engineer 收到伦理政策路径但文件缺失
2. 阶段 7：编排者尝试运行伦理审查；检测到 `design/live-ops/ethics-policy.md` 缺失
3. 阶段 7 摘要包含差距标记："伦理审查已跳过：未找到 `design/live-ops/ethics-policy.md`。经济设计未对照伦理政策审查。建议在进入制作前创建一份。"
4. Skill 仍完成赛季计划并达到 COMPLETE 裁定，但该差距在输出和赛季设计文档中被醒目标记
5. 下一步包括建议创建伦理政策文档

**断言：**
- [ ] Skill 在伦理政策文件缺失时不出错
- [ ] Skill 在文件缺失时不虚构伦理政策规则
- [ ] 阶段 7 摘要明确注明伦理审查已跳过及原因
- [ ] 裁定 COMPLETE 在文件缺失情况下仍可达成
- [ ] 差距标记出现在赛季设计输出文档中（不仅在对话中）
- [ ] 下一步推荐创建 `design/live-ops/ethics-policy.md`

---

## 协议合规

- [ ] 每个阶段转换处使用 `AskUserQuestion`——用户批准后再进入下一阶段
- [ ] 阶段 3 和 4 始终并行启动，非顺序执行
- [ ] 文件写入协议：编排者从不直接调用 Write/Edit——所有写入委托给子 Agent
- [ ] 每个输出文档获得相关子 Agent 的 "May I write to [path]?" 询问
- [ ] 阶段 7 伦理审查始终明确引用伦理政策文件路径
- [ ] 错误恢复：任何 BLOCKED Agent 立即通过 AskUserQuestion 选项（跳过 / 重试 / 停止）呈现
- [ ] 若任何阶段阻塞则产出部分报告——工作永不丢弃
- [ ] 裁定：仅当用户批准综合赛季计划后为 COMPLETE；若存在未解决的伦理违规则为 BLOCKED
- [ ] 下一步始终包含 `/design-review`、`/sprint-plan` 和 `/team-release`

---

## 覆盖说明

- 阶段 5 并行启动（narrative-director + writer）遵循与阶段 3/4 相同的模式，但此处未单独测试——它使用与 Case 4 中验证的相同并行 Task 协议。
- "economy-rules.md 缺失"边界情况未单独测试——它将作为 economy-designer 的 BLOCKED 结果呈现，遵循 Case 4 中隐式测试的标准错误恢复路径。
- 完整内容撰写流水线（阶段 5 输出验证）通过 Case 1 正常路径的综合摘要检查隐式验证。
- 社区经理通信日历格式（发布前、发布日、赛季中、最后一周）通过 Case 1 隐式验证；不需要单独的边界用例。
