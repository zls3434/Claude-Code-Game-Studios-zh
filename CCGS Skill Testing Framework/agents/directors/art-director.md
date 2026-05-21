<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：art-director

## Agent 摘要
**拥有的领域：** 视觉标识、艺术圣经（art bible）编写与执行、资产质量标准、UI/UX 视觉设计、视觉 phase gate、概念艺术评估。
**不拥有：** UX 交互流程和信息架构（ux-designer 的领域）、音频方向（audio-director）、代码实现。
**Model tier：** Sonnet（注意：尽管有"director"头衔，art-director 按 coordination-rules.md 分配 Sonnet — 它处理单个系统分析，而非 Opus 级别的多文档 phase gate 综合）。
**处理的 Gate ID：** AD-CONCEPT-VISUAL、AD-ART-BIBLE、AD-PHASE-GATE。

---

## 静态断言（结构性）

通过阅读 agent 的 `.claude/agents/art-director.md` frontmatter 验证：

- [ ] `description:` 字段存在且领域特定（引用视觉标识、art bible、资产标准 — 非泛化描述）
- [ ] `allowed-tools:` 列表以读取为主；如图像审查功能支持则可包含；除非资产管道检查需要，不应包含 Bash
- [ ] Model tier 为 `claude-sonnet-4-6`（非 Opus — coordination-rules.md 将 Sonnet 分配给 art-director）
- [ ] Agent 定义不声称对 UX 交互流程或音频方向拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出格式
**Scenario：** Art bible 的色彩调色板 section 被提交审查。该 section 定义了一套低饱和度的泥土色调主色盘和与游戏支柱「衰败中的美」相关联的高对比度强调色。该调色板内部一致，并引用了支柱词汇。请求标记为 AD-ART-BIBLE。
**预期：** 返回 `AD-ART-BIBLE: APPROVE`，附理由确认调色板的内部一致性及其与所述支柱的对齐。
**断言：**
- [ ] 裁决恰好为 APPROVE / CONCERNS / REJECT 之一
- [ ] 裁决 token 格式为 `AD-ART-BIBLE: APPROVE`
- [ ] 理由引用具体调色板特性和支柱对齐 — 非泛化艺术建议
- [ ] 输出保持在视觉领域内 — 不评论 UX 交互模式或音频情绪

### Case 2：领域外请求 — 重定向或升级
**Scenario：** 音效设计师请 art-director 指定环境音频在玩家进入战斗区域时应如何分层和压音（duck）。
**预期：** Agent 拒绝定义音频行为，并重定向到 audio-director。
**断言：**
- [ ] 不就音频分层或压音行为做出任何有约束力的决策
- [ ] 明确将 `audio-director` 命名为正确的处理者
- [ ] 可备注音频是否具有视觉情绪影响（例如「音频应匹配区域的视觉张力」），但将所有音频规范转交给 audio-director

### Case 3：Gate 裁决 — 正确的词汇
**Scenario：** 主角的概念艺术被提交。该艺术使用鲜艳饱和的调色板（主色：#FF4500, #00BFFF），与已建立的 art bible 中「低饱和度泥土色调」调色板规范直接矛盾。请求标记为 AD-CONCEPT-VISUAL。
**预期：** 返回 `AD-CONCEPT-VISUAL: CONCERNS`，具体引用调色板差异，引用 art bible 中所述调色板值与提交概念的调色板之间的差异。
**断言：**
- [ ] 裁决恰好为 APPROVE / CONCERNS / REJECT 之一 — 非自由文本
- [ ] 裁决 token 格式为 `AD-CONCEPT-VISUAL: CONCERNS`
- [ ] 理由具体标识调色板冲突 — 非泛化「不匹配风格」评论
- [ ] 将 art bible 作为正确调色板的权威来源引用

### Case 4：冲突升级 — 正确的父级
**Scenario：** ux-designer 提议为 HUD 使用高对比度、亮色图标以提高可读性。art-director 认为这违反了 art bible 的柔和视觉语言，会削弱视觉标识。
**预期：** art-director 陈述视觉标识顾虑并引用 art bible，承认 ux-designer 的可读性目标是合理的，并升级到 creative-director 来仲裁视觉一致性与可用性之间的权衡。
**断言：**
- [ ] 升级到 `creative-director`（创意领域冲突的共享父级）
- [ ] 不单方面否决 ux-designer 的可读性建议
- [ ] 清晰地将冲突框定为两个合理目标之间的权衡
- [ ] 引用正在被违反的具体 art bible 规则

### Case 5：上下文传递 — 使用提供的上下文
**Scenario：** Agent 收到一个 gate 上下文块，其中包含现有 art bible，带有具体的调色板值（主色：#8B7355, #6B6B47；强调色：#C8A96E）和风格规则（「无纯白、无纯黑；所有阴影具有暖色调底色」）。一个新资产被提交审查。
**预期：** 评估引用所提供 art bible 中的具体十六进制值和风格规则，而非泛化色彩理论建议。任何顾虑都与所提供规则的具体违规相关联。
**断言：**
- [ ] 引用所提供 art bible 上下文中的具体调色板值
- [ ] 应用所提供文档中的具体风格规则（无纯白/黑、暖色调阴影底色）
- [ ] 不生成与所提供 art bible 无关的泛化艺术方向反馈
- [ ] 裁决理由可追溯到所提供上下文中的具体行或规则

---

## 协议合规性

- [ ] 仅使用 APPROVE / CONCERNS / REJECT 词汇返回裁决
- [ ] 停留在声明的视觉领域内
- [ ] 将 UX 与视觉冲突升级到 creative-director
- [ ] 在输出中使用 gate ID（例如 `AD-ART-BIBLE: APPROVE`），而非内联散文式裁决
- [ ] 不做出有约束力的 UX 交互、音频或代码实现决策

---

## 覆盖说明
- AD-PHASE-GATE（完整视觉 phase 推进）未涵盖 — 推迟到与 /gate-check skill 的集成测试。
- 资产管道标准（文件格式、分辨率、命名规范）合规性检查未涵盖。
- Shader 视觉输出审查未涵盖 — 与引擎 specialist 的交互被推迟。
- UI 组件视觉审查（区别于 UX 流程审查）可受益于额外用例。
