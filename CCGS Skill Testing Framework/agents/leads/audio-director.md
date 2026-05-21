<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：audio-director

## Agent 摘要
**拥有的领域：** 音乐方向和调色板、声音设计理念、音频实现策略、混音平衡、phase gate 的音频方面。
**不拥有：** 视觉设计（art-director）、代码实现（lead-programmer）、叙事故事内容（narrative-director）、UX 交互流程（ux-designer）。
**Model tier：** Sonnet（单个系统分析 — 音频方向和规范审查）。
**处理的 Gate ID：** AD-VISUAL（phase gate 的音频方面；可作为 AD-PHASE-GATE 在音频维度中引用）。

---

## 静态断言（结构性）

通过阅读 agent 的 `.claude/agents/audio-director.md` frontmatter 验证：

- [ ] `description:` 字段存在且领域特定（引用音乐方向、声音设计、混音、音频实现 — 非泛化描述）
- [ ] `allowed-tools:` 列表以读取为主；除非音频资产管道检查合理，否则不包含 Bash
- [ ] Model tier 按 coordination-rules.md 为 `claude-sonnet-4-6`
- [ ] Agent 定义不声称对视觉设计、代码实现或叙事内容拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出格式
**Scenario：** 为游戏「探索」音乐层提交了一份音频规范文档。该规范定义了一个使用分层 stem 的生成式环境系统，根据环境密度在 stem 间切换，旨在强化支柱「有人情味的世界」。音色调色板（稀疏、有机、略带忧郁）与已确立的设计支柱相匹配。
**预期：** 返回 `APPROVED`，附理由确认基于 stem 的方法支持动态响应性，且音色调色板与支柱词汇对齐。
**断言：**
- [ ] 裁决恰好为 APPROVED / NEEDS REVISION 之一
- [ ] 理由引用具体支柱（「有人情味的世界」）以及音频规范如何支持它
- [ ] 输出保持在音频范围内 — 不评论环境的视觉设计或 UI 布局
- [ ] 裁决清晰标有上下文（例如"Audio Spec Review: APPROVED"）

### Case 2：领域外请求 — 重定向或升级
**Scenario：** 开发者请 audio-director 评估音频设置菜单的 UI 流程（屏幕和选项的序列）是否直观且组织良好。
**预期：** Agent 拒绝评估 UI 交互流程，并重定向到 ux-designer。
**断言：**
- [ ] 不就 UI 流程或信息架构做出任何有约束力的决策
- [ ] 明确命名 `ux-designer` 为正确的处理者
- [ ] 可备注设置菜单的音频特定要求（例如"必须包含单独的主音量、音乐和 SFX 滑块"），但将流程和布局决策转交 ux-designer

### Case 3：Gate 裁决 — 正确的词汇
**Scenario：** 最终 Boss 遭遇战的音乐 cue 被提交。该 cue 是一个欢快的大调管弦乐作品，节奏较快。该遭遇战的游戏支柱和叙事背景指定了「恐惧、宿命和悲剧性牺牲」。音频 cue 的情绪基调直接与预期的情绪节拍相矛盾。
**预期：** 返回 `NEEDS REVISION`，具体引用情绪不匹配：cue 欢快/大调/快节奏的特征 vs. 支柱和叙事背景中预期的恐惧/宿命/牺牲情绪目标。
**断言：**
- [ ] 裁决恰好为 APPROVED / NEEDS REVISION 之一 — 非自由文本
- [ ] 理由识别与情绪目标冲突的具体音乐特征
- [ ] 引用游戏支柱或叙事背景中的具体情绪目标
- [ ] 提供可操作的修改方向（例如"转为小调、更慢节奏、减少合奏密度"）

### Case 4：冲突升级 — 正确的父级
**Scenario：** sound-designer 提议使用基于实时射线检测物理查询的音频遮挡（技术方法）。technical-artist 认为这太昂贵，提议使用基于区域触发器的系统。双方同意遮挡效果是可取的；冲突纯粹在于实现方法。
**预期：** audio-director 决定期望的音频行为（遮挡应听起来如何以及何时激活），然后将实现方法决策转交 technical-artist 或 lead-programmer 作为实现专家。audio-director 不做出技术实现选择。
**断言：**
- [ ] 清晰定义期望的音频行为（玩家应听到什么以及何时）
- [ ] 明确将实现方法（射线检测 vs. 区域触发）转交 `lead-programmer` 或 `technical-artist`
- [ ] 不单方面选择技术实现方法
- [ ] 清晰框定交接："audio-director 拥有 what，technical lead 拥有 how"

### Case 5：上下文传递 — 使用提供的上下文
**Scenario：** Agent 收到一个 gate 上下文块，其中包含游戏的三个支柱：「突现故事」「有意义的牺牲」和「有人情味的世界」。一份环境音频的声音设计规范被提交。
**预期：** 评估针对所有三个支柱具体评估环境音频规范 — 音频如何支持（或削弱）每个支柱？在理由中直接使用支柱词汇。
**断言：**
- [ ] 在评估中按名称引用所有三个提供的支柱
- [ ] 明确评估音频规范对每个支柱的贡献
- [ ] 不生成泛化的音频方向建议 — 所有反馈都与提供的支柱词汇相关联
- [ ] 识别当前音频规范是否有未支持的支柱并标记

---

## 协议合规性

- [ ] 仅使用 APPROVED / NEEDS REVISION 词汇返回裁决
- [ ] 停留在声明的音频领域内
- [ ] 将实现方法决策转交技术主管
- [ ] 不使用与 director 层 agent 相同的 gate ID 前缀格式（audio-director 内联使用 APPROVED / NEEDS REVISION，但应仍引用 gate 上下文）
- [ ] 不做出有约束力的视觉设计、UX、叙事或代码实现决策

---

## 覆盖说明
- 混音平衡审查（音乐、SFX 和对白之间的相对电平）未涵盖 — 应添加专用案例。
- 音频实现策略审查（中间件选择、流式传输方法）未涵盖。
- audio-director 与音频 specialist agent（如果存在）之间的实现委托交互未涵盖。
- 本地化音频影响（VO 录制方向、语言特定的音乐时间）未涵盖。
