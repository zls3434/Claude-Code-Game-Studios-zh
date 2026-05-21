<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：narrative-director

## Agent 摘要
**拥有的领域：** 故事架构、角色设计方向、世界观建设监督、ND-CONSISTENCY gate、对话质量审查。
**不拥有：** 视觉艺术风格（art-director）、技术系统或代码（lead-programmer）、生产排期（producer）、游戏机制规则（game-designer）。
**Model tier：** Sonnet（单个系统分析 — 叙事一致性和叙事设定审查）。
**处理的 Gate ID：** ND-CONSISTENCY。

---

## 静态断言（结构性）

通过阅读 agent 的 `.claude/agents/narrative-director.md` frontmatter 验证：

- [ ] `description:` 字段存在且领域特定（引用故事、角色、世界观建设、一致性 — 非泛化描述）
- [ ] `allowed-tools:` 列表以读取为主；包含 Read 用于叙事设定文件、GDD 和叙事文档；除非合理，不包含 Bash
- [ ] Model tier 按 coordination-rules.md 为 `claude-sonnet-4-6`
- [ ] Agent 定义不声称对视觉风格、技术系统或生产排期拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出格式
**Scenario：** 一份关于「沉没档案馆」地点的新叙事设定文件被提交。该文件确立档案馆在 200 年前大崩塌期间被淹没，与 world-bible 中已确立的时间线一致。所有引用的具名角色与其已确立的背景故事一致。请求标记为 ND-CONSISTENCY。
**预期：** 返回 `ND-CONSISTENCY: CONSISTENT`，附理由确认时间线对齐和角色引用准确。
**断言：**
- [ ] 裁决恰好为 CONSISTENT / INCONSISTENT 之一
- [ ] 裁决 token 格式为 `ND-CONSISTENCY: CONSISTENT`
- [ ] 理由引用已验证的具体已确立事实（200 年时间线、大崩塌事件）
- [ ] 输出保持在叙事范围内 — 不评论该地点的视觉设计或技术实现

### Case 2：领域外请求 — 重定向或升级
**Scenario：** 开发者请 narrative-director 审查并优化用于档案遗物上「古老光芒」视觉效果的 shader 代码。
**预期：** Agent 拒绝评估 shader 代码，并重定向到适当的引擎 specialist（godot-gdscript-specialist 或等效 shader specialist）。
**断言：**
- [ ] 不就 shader 代码或视觉实现做出任何有约束力的决策
- [ ] 明确命名适当的引擎或 shader specialist 为正确的处理者
- [ ] 可备注该效果应传达的预期叙事氛围（例如"应感觉古老和神圣，而非技术化"），但将所有技术视觉实现转交

### Case 3：Gate 裁决 — 正确的词汇
**Scenario：** 一份关于角色「Aldric Vorne」的新角色背景故事文件被提交。该文件指出 Aldric 在 150 年前出生于首都，并亲眼见证了大崩塌。然而，已确立的 world-bible 指出 Aldric 在大崩塌 50 年后出生于一个乡镇，而非首都。请求标记为 ND-CONSISTENCY。
**预期：** 返回 `ND-CONSISTENCY: INCONSISTENT`，具体引用两个矛盾事实：出生时间（150 年前 vs. 崩塌后 50 年）和出生地点（首都 vs. 乡镇）。
**断言：**
- [ ] 裁决恰好为 CONSISTENT / INCONSISTENT 之一 — 非自由文本
- [ ] 裁决 token 格式为 `ND-CONSISTENCY: INCONSISTENT`
- [ ] 理由具体引用两个矛盾，而非仅「与叙事设定不匹配」
- [ ] 引用已确立事实的权威来源（world-bible）

### Case 4：冲突升级 — 正确的父级
**Scenario：** 一位编剧在最新对话中确立古代文明「仅以歌谣交流」。world-builder 现有的叙事设定条目描述同一文明通过书面象形文字沟通。两者都在叙事领域内，且两位创作者对哪个是正典存在分歧。
**预期：** narrative-director 在其领域内做出有约束力的正典决策。他们不需要将叙事内部冲突升级到更高权威 — 这在其声明的领域权限内。他们发布裁决（例如"象形文字书写是正典的主要沟通方式；歌谣可以是仪式/典礼用途"）并指导 writer 和 world-builder 使各自作品与裁决对齐。
**断言：**
- [ ] 做出有约束力的正典决策 — 不将此叙事内部冲突转交 creative-director
- [ ] 决策清晰陈述，并提供了双方的调和路径
- [ ] 指导双方（writer 和 world-builder）更新各自文档以对齐
- [ ] 以可添加到 world-bible 作为正典事实的方式记录该决策

### Case 5：上下文传递 — 使用提供的上下文
**Scenario：** Agent 收到一个 gate 上下文块，其中包含三份现有的叙事设定文件：world-bible（确立大崩塌的时间线和原因）、角色登记册（列出正典角色年龄、出身和所属）和一份派系文件（描述沉没档案馆守护者）。一个引入了一个此前未登记角色的新故事章节被提交。
**预期：** 评估将新角色与角色登记册交叉引用（无冲突），将章节的时间线引用与 world-bible 核对，并将章节对档案守护者的描绘与派系文件对比评估。在评估中使用三份提供文件中的具体事实。
**断言：**
- [ ] 将新角色与提供的角色登记册交叉引用
- [ ] 将时间线引用与提供的 world-bible 事实核对
- [ ] 将派系描绘与提供的派系文件对比评估
- [ ] 不生成泛化的叙事反馈 — 所有断言都可追溯到提供的文件

---

## 协议合规性

- [ ] 仅使用 CONSISTENT / INCONSISTENT 词汇返回裁决
- [ ] 停留在声明的叙事领域内
- [ ] 对叙事内部冲突做出有约束力的决策，无需不必要升级
- [ ] 在输出中使用 gate ID（例如 `ND-CONSISTENCY: INCONSISTENT`），而非内联散文式裁决
- [ ] 不做出有约束力的视觉设计、技术或生产决策

---

## 覆盖说明
- 对话质量审查（区别于世界观建设一致性）未涵盖 — 应添加专用案例。
- 跨完整章节集的多文件一致性检查未涵盖 — 推迟到 /review-all-gdds 集成。
- 机制变更的叙事影响（例如破坏故事张力的游戏机制）需要与 game-designer 协调，此处未涵盖。
- 角色弧线审查（进展、动机连贯性随时间变化）未涵盖。
