<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/team-narrative

## Skill 摘要

编排叙事团队通过五阶段流水线：叙事方向（narrative-director）→ 世界基础 + 对话起草（world-builder 和 writer 并行）→ 关卡叙事整合（level-designer）→ 一致性审查（narrative-director）→ 打磨 + 本地化合规（writer、localization-lead 和 world-builder 并行）。在每个阶段转换处使用 `AskUserQuestion` 将提案作为可选择项呈现。产出叙事总结报告，并通过每个执行 "May I write?" 协议的子 Agent 交付叙事文档。所有阶段成功时裁定为 COMPLETE，依赖未解决时裁定为 BLOCKED。

---

## 静态断言（结构）

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁定关键词：COMPLETE、BLOCKED
- [ ] 包含"文件写入协议"章节
- [ ] 文件写入委托给子 Agent——编排者不直接写入文件
- [ ] 子 Agent 在任何写入前执行 "May I write to [path]?" 协议
- [ ] 末尾有下一步交接（引用 `/design-review`、`/localize extract`、`/dev-story`）
- [ ] 错误恢复协议章节存在
- [ ] 阶段转换前使用 `AskUserQuestion` 获取用户审批再继续
- [ ] 阶段 2 明确并行启动 world-builder 和 writer
- [ ] 阶段 5 明确并行启动 writer、localization-lead 和 world-builder

---

## 测试用例

### 用例 1：正常路径 — 全部五个阶段完成，交付叙事文档

**测试环境配置（Fixture）：**
- 目标功能存在游戏概念和 GDD（例如 `design/gdd/faction-intro.md`）
- 角色语音档案存在（例如 `design/narrative/characters/`）
- 现有背景知识条目存在供交叉引用（例如 `design/narrative/lore/`）
- 现有条目与新内容之间不存在背景知识矛盾

**输入：** `/team-narrative faction introduction cutscene for the Ironveil faction`

**预期行为：**
1. 阶段 1：启动 narrative-director；产出叙事简报，定义故事节拍、涉及角色、情感基调和背景知识依赖
2. `AskUserQuestion` 展示叙事简报；用户在阶段 2 开始前批准
3. 阶段 2：并行启动 world-builder 和 writer；world-builder 产出 Ironveil 派系的背景知识条目；writer 使用角色语音档案起草对话行
4. `AskUserQuestion` 展示世界基础和对话草稿；用户在阶段 3 开始前批准
5. 阶段 3：启动 level-designer；产出环境叙事布局、触发器放置和节奏规划
6. `AskUserQuestion` 展示关卡叙事计划；用户在阶段 4 开始前批准
7. 阶段 4：narrative-director 对照语音档案审查所有对话，验证背景知识一致性，确认节奏；批准或标记问题
8. `AskUserQuestion` 展示审查结果；用户在阶段 5 开始前批准
9. 阶段 5：并行启动 writer、localization-lead 和 world-builder；writer 进行最终自我审查；localization-lead 验证 i18n 合规性；world-builder 最终确认 canon 级别
10. 展示最终总结报告；子 Agent 在写入前询问 "May I write the narrative document to [path]?"
11. 裁定：COMPLETE

**断言：**
- [ ] narrative-director 在阶段 1 中先于其他 Agent 启动
- [ ] `AskUserQuestion` 在阶段 1 输出后、阶段 2 启动前出现
- [ ] world-builder 和 writer 的 Task 调用在阶段 2 中同时发出（非顺序执行）
- [ ] level-designer 在阶段 2 的 `AskUserQuestion` 被批准后才启动
- [ ] narrative-director 在阶段 4 中为一致性审查重新启动
- [ ] 阶段 5 同时启动全部三个 Agent（writer、localization-lead、world-builder）
- [ ] 总结报告包含：叙事简报状态、已创建/更新的背景知识条目、已撰写的对话行、关卡叙事整合点、一致性审查结果
- [ ] 编排者不直接写入任何文件
- [ ] 交付后裁定为 COMPLETE

---

### 用例 2：发现背景知识矛盾 — world-builder 在 writer 继续前发现冲突

**测试环境配置（Fixture）：**
- `design/narrative/lore/ironveil-history.md` 中的现有背景知识条目指出 Ironveil 派系成立于 200 年前
- 新的叙事简报（来自阶段 1）指出 Ironveil 成立于 50 年前
- writer 已在阶段 2 中与 world-builder 并行启动

**输入：** `/team-narrative ironveil faction introduction cutscene`

**预期行为：**
1. 阶段 1–2 正常开始
2. 阶段 2 world-builder 检测到叙事简报与现有背景知识之间的事实矛盾：成立日期冲突
3. world-builder 返回 BLOCKED 原因："发现背景知识矛盾——成立日期与 `design/narrative/lore/ironveil-history.md` 冲突"
4. 编排者立即呈现矛盾："world-builder：BLOCKED——背景知识矛盾：叙事简报中的成立日期（50 年前）与 `ironveil-history.md` 中的现有 canon（200 年前）冲突"
5. 编排者评估依赖关系：writer 的对话依赖于 canon 背景知识——不解决矛盾 writer 的草稿无法最终确定
6. `AskUserQuestion` 展示选项：
   - 修订叙事简报以匹配现有 canon（200 年前）
   - 更新现有背景知识条目以反映新的 canon（50 年前）
   - 在此停止，先在背景知识文档中解决矛盾
7. Writer 输出被保留但标记为等待 canon 解决——工作不被丢弃
8. 编排者在矛盾解决或用户明确选择跳过之前不进入阶段 3

**断言：**
- [ ] 矛盾在阶段 3 开始前被呈现
- [ ] 编排者不通过选择其一来静默解决矛盾
- [ ] `AskUserQuestion` 至少提供 3 个选项，包括"停止并先解决"
- [ ] writer 的草稿输出在部分报告中被保留，不被丢弃
- [ ] 阶段 3（level-designer）在用户解决矛盾前不启动
- [ ] 若用户停止以解决矛盾，裁定为 BLOCKED（非 COMPLETE）

---

### 用例 3：无参数 — 显示使用说明

**测试环境配置（Fixture）：**
- 任意项目状态

**输入：** `/team-narrative`（无参数）

**预期行为：**
1. Skill 检测到未提供参数
2. 输出使用说明：例如 "用法：`/team-narrative [叙事内容描述]` — 描述要处理的剧情内容、场景或叙事区域（例如 `boss encounter cutscene`、`faction intro dialogue`、`tutorial narrative`）"
3. Skill 退出，不启动任何 Agent

**断言：**
- [ ] 无参数时 Skill 不启动任何 Agent
- [ ] 使用消息包含正确的调用格式和参数示例
- [ ] Skill 不尝试从项目文件中猜测或推断叙事主题
- [ ] 不使用 `AskUserQuestion`——输出是直接指导

---

### 用例 4：本地化合规 — localization-lead 标记不可翻译的字符串

**测试环境配置（Fixture）：**
- 阶段 1–4 成功完成
- 阶段 5 开始；writer 和 world-builder 无问题完成
- localization-lead 发现一个对话行使用了硬编码的格式化日期字符串（例如 `"On March 12th, Year 3"`），该字符串在没有区域感知格式化器的情况下无法在不同语言环境中正确翻译

**输入：** `/team-narrative ironveil faction introduction cutscene`（阶段 5 场景）

**预期行为：**
1. 阶段 5 并行启动 writer、localization-lead 和 world-builder
2. localization-lead 完成审查并标记："字符串键 `dialogue.ironveil.intro.003` 包含硬编码日期格式（`March 12th, Year 3`），无法正确本地化——需要区域感知日期占位符"
3. 编排者在总结报告中呈现本地化阻塞项
4. 本地化问题在最终报告中被标记为 BLOCKING（非建议性）
5. `AskUserQuestion` 展示选项：
   - 立即修复字符串（writer 修订该行）
   - 记录此差距并交付叙事文档，问题已标记
   - 在最终确定前停止并解决
6. 若用户选择在问题已标记的情况下继续，裁定为 COMPLETE 并注明本地化技术债务；若用户停止，裁定为 BLOCKED

**断言：**
- [ ] localization-lead 在阶段 5 中与 writer 和 world-builder 同时启动
- [ ] 硬编码日期格式被识别为本地化阻塞项（非静默放过）
- [ ] 具体字符串键和原因包含在问题报告中
- [ ] `AskUserQuestion` 提供立即修复 vs 标记并继续的选项
- [ ] 若用户不修复即继续，裁定注明本地化技术债务
- [ ] Skill 不未经用户批准自动重写问题行

---

### 用例 5：Writer 阻塞 — 缺失角色语音档案

**测试环境配置（Fixture）：**
- 阶段 1 narrative-director 产出引用两个角色的叙事简报：Commander Varek 和 Advisor Selene
- `design/narrative/characters/` 中两个角色均无语音档案存在
- 阶段 2 开始；world-builder 正常进行

**输入：** `/team-narrative ironveil surrender negotiation scene`

**预期行为：**
1. 阶段 1 完成；叙事简报列出 Commander Varek 和 Advisor Selene 为角色
2. 阶段 2：writer 与 world-builder 并行启动
3. writer 返回 BLOCKED："无法产出对话——`design/narrative/characters/` 中未找到 Commander Varek 或 Advisor Selene 的语音档案。需要语音档案以匹配合适的角色语调和说话模式。"
4. 编排者立即呈现阻塞："writer：BLOCKED——缺失先决条件：Commander Varek 和 Advisor Selene 的角色语音档案"
5. world-builder 输出被保留；产出带有背景知识条目的部分报告
6. `AskUserQuestion` 展示选项：
   - 先创建语音档案（重定向到 narrative-director 或设计工作流）
   - 提供内联的最小语音方向，让 writer 在该上下文中重试
   - 在此停止，先创建语音档案再继续
7. 编排者在没有 writer 输出的情况下不进入阶段 3（level-designer）

**断言：**
- [ ] writer 阻塞在阶段 3 开始前被呈现
- [ ] world-builder 已完成的背景知识输出在部分报告中被保留
- [ ] 缺失的先决条件（语音档案）被具体命名（角色名称和预期文件路径）
- [ ] `AskUserQuestion` 至少提供一个解决缺失先决条件的选项
- [ ] 编排者不凭空创造语音档案或虚构角色声音
- [ ] 阶段 3 在 writer 处于 BLOCKED 状态且无用户明确授权时不启动

---

## 协议合规

- [ ] 每个阶段输出后使用 `AskUserQuestion`，再进入下一阶段
- [ ] 并行启动：阶段 2（world-builder + writer）和阶段 5（writer + localization-lead + world-builder）在等待结果前发出所有 Task 调用
- [ ] 编排者不直接写入任何文件——所有写入委托给子 Agent
- [ ] 每个子 Agent 在任何写入前执行 "May I write to [path]?" 协议
- [ ] 任何 Agent 的 BLOCKED 状态立即呈现——不静默跳过
- [ ] 当部分 Agent 完成而其他 Agent 阻塞时，始终产出部分报告
- [ ] 裁定仅限于 COMPLETE 或 BLOCKED——不使用其他裁定值
- [ ] 下一步交接引用 `/design-review`、`/localize extract` 和 `/dev-story`

---

## 覆盖说明

- 阶段 3（level-designer）和阶段 4（narrative-director 审查）的正常路径行为通过 Case 1 隐式验证。这些阶段不需要单独的边界用例，因为其失败模式遵循标准错误恢复协议。
- 错误恢复协议中的"以更窄范围重试"和"跳过此 Agent"解决路径未单独测试——它们遵循与 Cases 2 和 5 中验证的相同 `AskUserQuestion` + 部分报告模式。
- 本地化问题中的建议性问题（例如 German/Finnish +30% 扩展警告）vs 阻塞性问题（硬编码格式）在 Case 4 中做了区分；仅建议性场景遵循相同的模式但不改变裁定。
- 阶段 5 中 writer 的"所有行在 120 字符以内"和"字符串键非原始字符串"检查通过 Case 4 的本地化合规场景隐式覆盖。
