<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规格：/team-audio

## Skill 摘要

编排音频团队通过四步流水线：音频方向（audio-director） → 音效设计 + 无障碍审查并行（sound-designer + accessibility-specialist） → 技术实现 + 引擎验证并行（technical-artist + 主引擎 specialist） → 代码集成（gameplay-programmer）。在生成子 agent 之前读取相关 GDD、sound bible（如果存在）以及现有音频资源清单。将所有输出编译为一份音频设计文档，保存至 `design/gdd/audio-[feature].md`。在每个步骤转换点使用 `AskUserQuestion`。当音频设计文档生成后，verdict 为 COMPLETE。当未配置引擎时优雅跳过引擎 specialist 生成。

---

## 静态断言（结构层面）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含 ≥2 个 step/phase 标题
- [ ] 包含 verdict 关键字：COMPLETE、BLOCKED
- [ ] 包含 "File Write Protocol" 部分
- [ ] 文件写入委托给子 agent — 编排者不直接写入文件
- [ ] 子 agent 在任何写入前执行 "May I write to [path]?" 协议
- [ ] 包含下一步移交指引（引用 `/dev-story`、`/asset-audit`）
- [ ] 包含 Error Recovery Protocol 部分
- [ ] 在步骤转换点使用 `AskUserQuestion`，待批准后方可继续
- [ ] Step 2 显式并行生成 sound-designer 和 accessibility-specialist
- [ ] Step 3 显式并行生成 technical-artist 和 engine specialist（当引擎已配置时）
- [ ] Skill 在上下文收集阶段读取 `design/gdd/sound-bible.md`（如果存在）
- [ ] 输出文档保存至 `design/gdd/audio-[feature].md`

---

## 测试用例

### 用例 1：正常路径 — 所有步骤完成，音频设计文档已保存

**Fixture：**
- 目标功能的 GDD 存在于 `design/gdd/combat.md`
- Sound bible 存在于 `design/gdd/sound-bible.md`
- 现有音频资源在 `assets/audio/` 中列出
- 引擎已在 `.claude/docs/technical-preferences.md` 中配置
- 计划音频事件列表中没有无障碍缺陷

**输入：** `/team-audio combat`

**预期行为：**
1. 上下文收集：编排者在生成任何 agent 之前读取 `design/gdd/combat.md`、`design/gdd/sound-bible.md` 和 `assets/audio/` 资源列表
2. Step 1：生成 audio-director；定义战斗的声音特质、情感基调、自适应音乐方向、混音目标以及自适应音频规则
3. `AskUserQuestion` 展示音频方向；用户批准后 Step 2 开始
4. Step 2：并行生成 sound-designer 和 accessibility-specialist；sound-designer 生成 SFX 规格、含触发条件的音频事件列表和混音组；accessibility-specialist 识别关键玩法音频事件并指定视觉回退和字幕需求
5. `AskUserQuestion` 展示 SFX 规格和无障碍需求；用户批准后 Step 3 开始
6. Step 3：并行生成 technical-artist 和主引擎 specialist；technical-artist 设计总线结构、中间件集成、内存预算和流式传输策略；引擎 specialist 验证集成方式是否符合已配置引擎的惯用方法
7. `AskUserQuestion` 展示技术方案；用户批准后 Step 4 开始
8. Step 4：生成 gameplay-programmer；将音频事件连接到玩法触发器，实现自适应音乐，设置遮挡区域，为音频事件触发器编写单元测试
9. 编排者将所有输出编译为单一音频设计文档
10. 子 agent 在写入前询问 "May I write the audio design document to `design/gdd/audio-combat.md`?"
11. 摘要输出列出：音频事件数量、预估资源数量、实现任务及任何未决问题
12. Verdict：COMPLETE

**断言：**
- [ ] 在上下文收集期间（Step 1 之前），当 sound bible 存在时读取它
- [ ] audio-director 在 sound-designer 或 accessibility-specialist 之前生成
- [ ] `AskUserQuestion` 在 Step 1 输出之后、Step 2 启动之前出现
- [ ] sound-designer 和 accessibility-specialist 的 Task 调用在 Step 2 中同时发出
- [ ] technical-artist 和 engine specialist 的 Task 调用在 Step 3 中同时发出
- [ ] gameplay-programmer 在 Step 3 的 `AskUserQuestion` 被批准后才启动
- [ ] 音频设计文档写入到 `design/gdd/audio-combat.md`（非其他路径）
- [ ] 摘要包含音频事件数量和预估资源数量
- [ ] 编排者不直接写入任何文件
- [ ] 文档交付后 verdict 为 COMPLETE

---

### 用例 2：无障碍缺陷 — 关键玩法音频事件无视觉回退

**Fixture：**
- 目标功能的 GDD 存在
- Step 1 和 Step 2 正在进行中
- sound-designer 的音频事件列表中包含 "EnemyNearbyAlert" — 一个空间音频提示，在敌人从屏幕外接近时警告玩家
- accessibility-specialist 审查事件列表，发现 "EnemyNearbyAlert" 无视觉回退（无屏幕指示器、无字幕、无手柄振动指定）

**输入：** `/team-audio stealth`（Step 2 场景）

**预期行为：**
1. Steps 1–2 继续；accessibility-specialist 和 sound-designer 并行生成
2. accessibility-specialist 返回审查结果，包含一项 BLOCKING 关切："`EnemyNearbyAlert` 是一项关键玩法音频事件（警告玩家屏幕外威胁）无视觉回退 — 听障玩家无法检测到这一威胁。这是一项 BLOCKING 无障碍缺陷。"
3. 编排者在展示 `AskUserQuestion` 之前立即在会话中呈现该关切
4. `AskUserQuestion` 将无障碍关切作为 BLOCKING 事项展示，并提供选项：
   - 为 EnemyNearbyAlert 添加视觉指示器（例如 HUD 上的方向箭头）并继续
   - 添加手柄触觉反馈作为回退并继续
   - 在此停止，先解决所有无障碍缺陷再进入 Step 3
5. Step 3（technical-artist + engine specialist）在用户解决或明确接受该缺陷之前不启动
6. 如果未解决，该无障碍缺陷将纳入最终音频设计文档中的"开放无障碍问题"部分

**断言：**
- [ ] 无障碍缺陷在报告中标记为 BLOCKING（非建议性质）
- [ ] 列出具体事件名称（"EnemyNearbyAlert"）及缺陷性质
- [ ] `AskUserQuestion` 在 Step 3 启动前呈现该缺陷
- [ ] 至少提供一个解决方案选项（添加视觉回退、添加触觉回退）
- [ ] 缺陷未解决且未经用户明确授权时，Step 3 不启动
- [ ] 如果缺陷未解决而继续，将在音频设计文档中记录为开放问题

---

### 用例 3：无参数 — 显示使用指南

**Fixture：**
- 任何项目状态

**输入：** `/team-audio`（无参数）

**预期行为：**
1. Skill 检测到未提供参数
2. 输出使用指南：例如 "Usage: `/team-audio [feature or area]` — 指定要设计音频的功能或区域（例如 `combat`、`main menu`、`forest biome`、`boss encounter`）"
3. Skill 退出，不生成任何 agent

**断言：**
- [ ] 未提供参数时 skill 不生成任何 agent
- [ ] 使用消息包含正确的调用格式及参数示例
- [ ] Skill 不会在未经用户指示的情况下尝试从现有设计文档推断功能
- [ ] 不使用 `AskUserQuestion` — 输出为直接指引

---

### 用例 4：缺少 Sound Bible — Skill 标注缺陷并在缺少它的情况下继续

**Fixture：**
- 目标功能的 GDD 存在于 `design/gdd/main-menu.md`
- `design/gdd/sound-bible.md` 不存在
- 引擎已配置；其他上下文文件存在

**输入：** `/team-audio main menu`

**预期行为：**
1. 上下文收集：编排者读取 `design/gdd/main-menu.md` 并检查 `design/gdd/sound-bible.md`
2. 未找到 sound bible；编排者在会话中标注该缺陷："注意：未找到 `design/gdd/sound-bible.md` — 音频方向将在没有项目级声音特质参考的情况下进行。如果这是一个持续进行的项目，建议创建一个 sound bible。"
3. 流水线在没有 sound bible 作为输入的情况下正常通过全部四个步骤
4. Step 1 中的 audio-director 被告知不存在 sound bible，必须仅从功能 GDD 建立声音特质
5. 缺少 sound bible 在最终摘要中作为推荐的下一步提及

**断言：**
- [ ] 编排者在上下文收集期间（Step 1 之前）检查 sound bible
- [ ] 缺少 sound bible 在会话中明确标注 — 不静默忽略
- [ ] 流水线不因缺少 sound bible 而停止
- [ ] audio-director 在其提示上下文中被告知不存在 sound bible
- [ ] 摘要或 Next Steps 部分建议创建 sound bible
- [ ] 如果其他步骤全部成功，verdict 仍为 COMPLETE

---

### 用例 5：引擎未配置 — 引擎 specialist 步骤优雅跳过

**Fixture：**
- 引擎在 `.claude/docs/technical-preferences.md` 中未配置（显示 `[TO BE CONFIGURED]`）
- 目标功能的 GDD 存在
- Sound bible 可能存在也可能不存在

**输入：** `/team-audio boss encounter`

**预期行为：**
1. 上下文收集：编排者读取 `.claude/docs/technical-preferences.md`，检测到未配置引擎
2. Steps 1–2 正常进行（audio-director、sound-designer、accessibility-specialist）
3. Step 3：technical-artist 正常生成；engine specialist 生成被跳过
4. 编排者在会话中注明："引擎 specialist 未生成 — technical-preferences.md 中未配置引擎。引擎集成验证将推迟到选择引擎之后进行。"
5. Step 4：gameplay-programmer 继续进行，并附注说明无法验证引擎特定的音频集成模式
6. 引擎 specialist 缺口纳入音频设计文档中的"推迟验证"部分
7. Verdict：COMPLETE（跳过为优雅行为，非阻塞项）

**断言：**
- [ ] 未配置引擎时不生成 engine specialist
- [ ] Skill 不因缺少引擎配置而出错
- [ ] 跳过操作在会话中明确注明 — 不静默省略
- [ ] technical-artist 在 Step 3 中仍然生成（仅跳过 engine specialist）
- [ ] gameplay-programmer 在 Step 4 中继续进行，并注明推迟验证
- [ ] 推迟的引擎验证记录在音频设计文档中
- [ ] Verdict 为 COMPLETE（引擎未配置为已知优雅场景）

---

## 协议合规

- [ ] 上下文收集（GDD、sound bible、资源列表）在任何 agent 生成之前运行
- [ ] 每个步骤输出后的下一步启动前使用 `AskUserQuestion`
- [ ] 并行生成：Step 2（sound-designer + accessibility-specialist）和 Step 3（technical-artist + engine specialist）在等待结果之前发出全部 Task 调用
- [ ] 编排者不直接写入任何文件 — 所有写入委托给子 agent
- [ ] 每个子 agent 在任何写入前执行 "May I write to [path]?" 协议
- [ ] 任何 agent 的 BLOCKED 状态立即展示 — 不静默跳过
- [ ] 当部分 agent 完成、部分受阻时始终生成部分报告
- [ ] 音频设计文档路径遵循模式 `design/gdd/audio-[feature].md`
- [ ] Verdict 严格为 COMPLETE 或 BLOCKED — 不使用其他 verdict 值
- [ ] Next Steps 移交引用 `/dev-story` 和 `/asset-audit`

---

## 覆盖说明

- 来自 Error Recovery Protocol 的"缩小范围重试"和"跳过此 agent"解决路径不单独测试 — 它们遵循用例 2 和用例 5 中已验证的相同 `AskUserQuestion` + partial-report 模式。
- Step 4（gameplay-programmer）的正常路径行为在用例 1 中隐式验证。此步骤的失败模式遵循标准 Error Recovery Protocol。
- accessibility-specialist 的字幕说明需求（视觉回退之外）在用例 1 中隐式验证。用例 2 聚焦于更严重的情况：关键玩法事件完全没有回退。
- Engine specialist 验证逻辑（惯用集成、版本特定变更）仅测试已配置和未配置两种状态。engine specialist 输出的具体内容不在本行为规格的范围内。
