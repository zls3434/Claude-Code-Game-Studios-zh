<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# 总监关卡 — 共享审查模式

本文档定义了所有总监和负责人审查的标准化关卡提示，涵盖每个工作流阶段。
技能通过引用本文档中的关卡 ID 来使用，而不是内嵌完整的提示文本 — 从而消除
提示需要更新时产生的版本漂移。

**适用范围**：全部 7 个生产阶段（概念阶段 → 发布阶段）、全部 3 个第一层总监、
所有关键的第二层负责人。任何技能、团队编排器或工作流都可调用这些关卡。

---

## 如何使用本文档

在任意技能中，将内联的总监提示替换为引用：

```
通过 Task 启动 `creative-director`，使用关卡 **CD-PILLARS**，来源为
`.claude/docs/director-gates.md`。
```

传递该关卡下 **待传递的上下文** 字段中列出的上下文，然后使用下方的
**判定处理** 规则处理判定结果。

---

## 审查模式

审查强度控制总监关卡是否运行。可全局设置（跨会话持久）或按技能运行覆盖。

**全局配置**：`production/review-mode.txt` — 一个单词：`full`、`lean` 或 `solo`。
在 `/start` 期间设置一次。直接编辑该文件可随时更改。

**单次覆盖**：任何使用关卡的技能都接受 `--review [full|lean|solo]` 作为参数。
此参数仅对本次运行覆盖全局配置。

示例：
```
/brainstorm 太空恐怖           → 使用全局模式
/brainstorm 太空恐怖 --review full   → 本次强制使用 full 模式
/architecture-decision --review solo     → 本次跳过所有关卡
```

| 模式 | 运行内容 | 最适合 |
|------|-----------|----------|
| `full` | 所有关卡激活 — 每个工作流步骤都经过审查 | 团队、学习型用户，或希望在每一步获得总监全面反馈时 |
| `lean` | 仅阶段关卡（`/gate-check`）— 跳过每个技能的关卡 | **默认** — 独立开发者和小团队；总监仅在里程碑处审查 |
| `solo` | 不运行任何总监关卡 | 游戏 Jam、原型、追求极致速度 |

**检查模式 — 在每次启动关卡前应用：**

```
在启动关卡 [GATE-ID] 之前：
1. 如果技能以 --review [mode] 调用，使用该模式
2. 否则读取 production/review-mode.txt
3. 否则默认为 lean

应用解析后的模式：
- solo → 跳过所有关卡。注明："[GATE-ID] 已跳过 — Solo 模式"
- lean → 跳过，除非这是阶段关卡（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
         注明："[GATE-ID] 已跳过 — Lean 模式"
- full → 正常启动
```

---

## 调用模式（复制到任意技能中）

**强制要求：在每次启动关卡前解析审查模式。** 绝不未经检查就启动关卡。解析后的模式在每次技能运行中确定一次：
1. 如果技能以 `--review [mode]` 调用，使用该模式
2. 否则读取 `production/review-mode.txt`
3. 否则默认为 `lean`

应用解析后的模式：
- `solo` → **跳过所有关卡**。在输出中注明：`[GATE-ID] 已跳过 — Solo 模式`
- `lean` → **跳过，除非这是阶段关卡**（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）。注明：`[GATE-ID] 已跳过 — Lean 模式`
- `full` → 正常启动

```
# 首先应用模式检查，然后：
通过 Task 启动 `[agent-name]`：
- 关卡：[GATE-ID]（参见 .claude/docs/director-gates.md）
- 上下文：[该关卡下列出的字段]
- 等待判定后再继续。
```

并行启动（同一关卡点启动多位总监）：

```
# 首先对每个关卡应用模式检查，然后启动所有存活的关卡：
同时启动所有 [N] 个 Agent — 在等待任何结果之前发出所有 Task 调用。
收集所有判定后再继续。
```

---

## 标准判定格式

所有关卡返回三种判定之一。技能必须处理全部三种：

| 判定 | 含义 | 默认处理动作 |
|---------|---------|----------------|
| **APPROVE / READY** | 无问题。继续。 | 继续工作流 |
| **CONCERNS [列表]** | 存在问题但不阻塞。 | 通过 `AskUserQuestion` 呈现给用户 — 选项：`修订标记项` / `接受并继续` / `进一步讨论` |
| **REJECT / NOT READY [阻塞项]** | 阻塞性问题。不可继续。 | 将阻塞项呈现给用户。在解决前不可写入文件或推进阶段。 |

**升级规则**：当多位总监被并行启动时，应用最严格的判定 — 一个 NOT READY 覆盖所有 READY 判定。

---

## 记录关卡结果

关卡解决后，在相关文档的状态头中记录判定：

```markdown
> **[总监] 审查（[GATE-ID]）**：APPROVED [日期] / CONCERNS（已接受）[日期] / REVISED [日期]
```

对于阶段关卡，适当地记录在 `docs/architecture/architecture.md` 或
`production/session-state/active.md` 中。

---

## 第一层 — 创意总监关卡

Agent：`creative-director` | 模型层级：Opus | 领域：愿景、支柱、玩家体验

---

### CD-PILLARS — 支柱压力测试

**触发时机**：在游戏支柱和反支柱被定义后（脑暴第四阶段，或任何支柱修订时）

**待传递的上下文**：
- 完整的支柱集合，包含名称、定义和设计测试
- 反支柱列表
- 核心体验目标陈述
- 独特钩子（"像 X，而且还有 Y"）

**提示**：
> "审查这些游戏支柱。它们是否可被证伪 — 一个真实的设计决策是否真有可能无法通过这个支柱？它们之间是否产生了有意义的张力？它们是否将本游戏与最接近的竞品区分开来？在实践中，它们是否有助于解决设计分歧，还是过于模糊而毫无用处？对每个支柱返回具体反馈，并给出总体判定：APPROVE（坚实）、CONCERNS [列表]（需要打磨）或 REJECT（薄弱 — 支柱没有分量）。"

**判定**：APPROVE / CONCERNS / REJECT

---

### CD-GDD-ALIGN — GDD 支柱对齐检查

**触发时机**：在系统 GDD 编写完成后（design-system、quick-design 或任何生成 GDD 的工作流）

**待传递的上下文**：
- GDD 文件路径
- 游戏支柱（来自 `design/gdd/game-concept.md` 或 `design/gdd/game-pillars.md`）
- 本游戏的 MDA 美学目标
- 系统声明的玩家体验目标章节

**提示**：
> "审查此系统 GDD 的支柱对齐度。每个章节是否服务于声明的支柱？是否存在与支柱相矛盾或削弱的机制或规则？玩家体验目标章节是否与游戏的核心体验目标匹配？返回 APPROVE、CONCERNS [存在问题的具体章节] 或 REJECT [必须重新设计才能实现此系统的支柱违规项]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### CD-SYSTEMS — 系统分解愿景检查

**触发时机**：在系统索引由 `/map-systems` 编写后 — 在 GDD 编写开始前验证完整的系统集合

**待传递的上下文**：
- 系统索引路径（`design/gdd/systems-index.md`）
- 游戏支柱和核心体验目标（来自 `design/gdd/game-concept.md`）
- 优先级层级分配（MVP / 垂直切片 / Alpha / 完整愿景）
- 依赖关系图中识别的任何高风险或瓶颈系统

**提示**：
> "对照游戏设计支柱审查此系统分解。MVP 层级系统的完整集合是否共同交付了核心体验目标？是否存在其机制不服务于任何声明支柱的系统 — 表明它们可能是范围蔓延？是否存在对支柱至关重要的玩家体验，但没有系统被分配来交付它们？核心循环是否缺少任何必要的系统？返回 APPROVE（系统服务于愿景）、CONCERNS [具体缺口或对齐偏差及其支柱影响] 或 REJECT [根本性缺口 — 此分解遗漏了关键设计意图，必须在 GDD 编写开始前修订]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### CD-NARRATIVE — 叙事一致性检查

**触发时机**：在叙事 GDD、背景文档、对白规范或世界观构建文档被编写后（team-narrative、设计故事系统的 design-system、writer 交付物）

**待传递的上下文**：
- 文档文件路径
- 游戏支柱
- 叙事方向简报或基调指南（如果存在于 `design/narrative/` 中）
- 新文档引用的任何已有背景设定

**提示**：
> "审查此叙事内容与游戏支柱和已有世界规则的一致性。基调是否与游戏已确立的语调匹配？是否与已有背景设定或世界观构建存在矛盾？内容是否服务于玩家体验支柱？返回 APPROVE、CONCERNS [具体不一致之处] 或 REJECT [破坏世界连贯性的矛盾]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### CD-PLAYTEST — 玩家体验验证

**触发时机**：在试玩报告生成后（`/playtest-report`），或在任何产生玩家反馈的会话之后

**待传递的上下文**：
- 试玩报告文件路径
- 游戏支柱和核心体验目标陈述
- 被测试的具体假设

**提示**：
> "对照游戏的设计支柱和核心体验目标审查此试玩报告。玩家体验是否与预期体验目标匹配？是否存在代表支柱漂移的系统性问题 — 即单独感觉良好的机制实际上削弱了预期体验？返回 APPROVE（核心体验目标达成）、CONCERNS [预期与实际体验之间的差距] 或 REJECT [核心体验目标不存在 — 在进一步试玩前需要重新设计]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### CD-PHASE-GATE — 阶段转换时的创意就绪度

**触发时机**：始终在 `/gate-check` 时 — 与 TD-PHASE-GATE 和 PR-PHASE-GATE 并行启动

**待传递的上下文**：
- 目标阶段名称
- 所有存在产出物的列表（文件路径）
- 游戏支柱和核心体验目标

**提示**：
> "从创意方向的角度审查当前项目状态对于 [目标阶段] 的关卡就绪度。游戏支柱是否在所有设计产出物中得到忠实体现？当前状态是否保留了核心体验目标？GDD 或架构中是否存在损害预期玩家体验的设计决策？返回 READY、CONCERNS [列表] 或 NOT READY [阻塞项]。"

**判定**：READY / CONCERNS / NOT READY

---

## 第一层 — 技术总监关卡

Agent：`technical-director` | 模型层级：Opus | 领域：架构、引擎风险、性能

---

### TD-SYSTEM-BOUNDARY — 系统边界架构审查

**触发时机**：在 `/map-systems` 第三阶段依赖映射达成一致后，但在 GDD 编写开始前 — 验证系统结构在团队投入编写 GDD 之前架构上是否合理

**待传递的上下文**：
- 系统索引路径（或依赖映射摘要，如果索引尚未写出）
- 层级分配（Foundation / Core / Feature / Presentation / Polish）
- 完整的依赖关系图（每个系统依赖哪些系统）
- 任何被标记的瓶颈系统（有众多依赖方）
- 任何发现的循环依赖及其提议的解决方案

**提示**：
> "在 GDD 编写开始前，从架构角度审查此系统分解。系统边界是否清晰 — 每个系统是否拥有一个独立的关注点且重叠最小？是否存在 God Object 风险（系统承担太多）？依赖排序是否会导致实现顺序问题？提议的边界中是否存在隐式共享状态问题，会在实现时导致紧耦合？Foundation 层系统是否存在实际依赖 Feature 层系统的情况（依赖倒置）？返回 APPROVE（边界在架构上合理 — 可以开始编写 GDD）、CONCERNS [需要在 GDD 中解决的具体边界问题] 或 REJECT [根本性边界问题 — 系统结构将导致架构问题，必须在任何 GDD 编写前重新构建]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### TD-FEASIBILITY — 技术可行性评估

**触发时机**：在范围/可行性阶段识别出最大技术风险后（脑暴第六阶段、quick-design 或任何存在技术未知的早期概念）

**待传递的上下文**：
- 概念的核心循环描述
- 目标平台
- 引擎选择（或"未定"）
- 已识别的技术风险列表

**提示**：
> "审查这些面向 [平台] 的 [类型] 游戏的技术风险，使用 [引擎 或 '未定引擎']。标记任何可能使所述概念无法实现的高风险项、任何引擎特定且应影响引擎选择的风险、以及任何常被独立开发者低估的风险。返回 VIABLE（风险可控）、CONCERNS [列表及缓解建议] 或 HIGH RISK [需要修改概念或范围的阻塞项]。"

**判定**：VIABLE / CONCERNS / HIGH RISK

---

### TD-ARCHITECTURE — 架构签收

**触发时机**：在主架构文档起草后（`/create-architecture` 第七阶段），以及任何重大架构修订后

**待传递的上下文**：
- 架构文档路径（`docs/architecture/architecture.md`）
- 技术需求基线（TR-ID 及数量）
- 带状态的 ADR 列表
- 引擎知识差距清单

**提示**：
> "审查此主架构文档的技术合理性。检查：(1) 基线中的每个技术需求是否都对应一个架构决策？(2) 所有高风险引擎领域是否都被明确处理或标记为待解决问题？(3) API 边界是否清晰、最少且可实现？(4) Foundation 层 ADR 差距是否在实现开始前解决？返回 APPROVE、CONCERNS [列表] 或 REJECT [必须在编码开始前解决的阻塞项]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### TD-ADR — 架构决策审查

**触发时机**：在单个 ADR 编写后（`/architecture-decision`），标记为 Accepted 之前

**待传递的上下文**：
- ADR 文件路径
- 引擎版本及该领域的知识差距风险等级
- 相关 ADR（如有）

**提示**：
> "审查此架构决策记录。它是否有清晰的问题陈述和理由？被拒绝的替代方案是否经过真正的考虑？"后果"章节是否坦诚地承认了权衡？是否标注了引擎版本？是否标记了截止日期后的 API 风险？是否链接到其所覆盖的 GDD 需求？返回 APPROVE、CONCERNS [具体缺口] 或 REJECT [决策不够具体或存在不合理的技��假设]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### TD-ENGINE-RISK — 引擎版本风险审查

**触发时机**：当做出的架构决策涉及截止日期后的引擎 API 时，或在最终确定任何引擎特定的实现方案之前

**待传递的上下文**：
- 正在使用的具体 API 或功能
- 引擎版本和 LLM 知识截止日期（来自 `docs/engine-reference/[engine]/VERSION.md`）
- breaking-changes 或 deprecated-apis 文档的相关摘录

**提示**：
> "对照版本参考审查此引擎 API 的使用。此 API 在 [引擎版本] 中存在吗？自 LLM 知识截止日期以来，其签名、行为或命名空间是否发生了变化？是否存在已知的弃用项或截止日期后的替代方案？返回 APPROVE（按所述安全使用）、CONCERNS [在实现前需验证] 或 REJECT [API 已变更 — 提供修正后方案]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### TD-PHASE-GATE — 阶段转换时的技术就绪度

**触发时机**：始终在 `/gate-check` 时 — 与 CD-PHASE-GATE 和 PR-PHASE-GATE 并行启动

**待传递的上下文**：
- 目标阶段名称
- 架构文档路径（如果存在）
- 引擎参考路径
- ADR 列表

**提示**：
> "从技术方向的角度审查当前项目状态对于 [目标阶段] 的关卡就绪度。架构对此阶段是否合理？所有高风险引擎领域是否得到处理？性能预算是否现实并文档化？Foundation 层决策是否足够完整以开始实现？返回 READY、CONCERNS [列表] 或 NOT READY [阻塞项]。"

**判定**：READY / CONCERNS / NOT READY

---

## 第一层 — 制作人关卡

Agent：`producer` | 模型层级：Opus | 领域：范围、时间线、依赖、生产风险

---

### PR-SCOPE — 范围和时间线验证

**触发时机**：在范围层级定义后（脑暴第六阶段、quick-design 或任何产生 MVP 定义和时间线估算的工作流）

**待传递的上下文**：
- 完整愿景的范围描述
- MVP 定义
- 时间线估算
- 团队规模（独立开发者 / 小团队 / 等）
- 范围层级（如果时间不够的情况下交付什么）

**提示**：
> "审查此范围估算。对于所述的团队规模，MVP 在所述的时间线内是否可实现？范围层级是否按风险正确排序 — 如果工作停止在该层级，每个层级是否都能交付一个可发布的产品？在时间压力下最可能的裁剪点是什么，它是一个优雅的回退方案还是一个破碎的产品？返回 REALISTIC（范围与产能匹配）、OPTIMISTIC [推荐的具体调整] 或 UNREALISTIC [阻塞项 — 时间线或 MVP 必须修订]。"

**判定**：REALISTIC / OPTIMISTIC / UNREALISTIC

---

### PR-SPRINT — Sprint 可行性审查

**触发时机**：在最终确定 Sprint 计划之前（`/sprint-plan`），以及任何 Sprint 中期范围变更之后

**待传递的上下文**：
- 提议的 Sprint Story 列表（标题、估算、依赖关系）
- 团队产能（可用工时）
- 当前 Sprint 积压债务（如有）
- 里程碑约束

**提示**：
> "审查此 Sprint 计划的可行性。Story 负载对于可用产能是否现实？Story 是否按依赖关系正确排序？Story 之间是否存在可能在 Sprint 中期造成阻塞的隐藏依赖？是否有 Story 考虑到其技术复杂度而被低估了？返回 REALISTIC（计划可实现）、CONCERNS [具体风险] 或 UNREALISTIC [Sprint 必须削减范围 — 识别哪些 Story 需要推迟]。"

**判定**：REALISTIC / CONCERNS / UNREALISTIC

---

### PR-MILESTONE — 里程碑风险评估

**触发时机**：在里程碑审查时（`/milestone-review`）、Sprint 中期回顾时，或当范围变更提议影响里程碑时

**待传递的上下文**：
- 里程碑定义和目标日期
- 当前完成百分比
- 被阻塞的 Story 数量
- Sprint 速率数据（如有）

**提示**：
> "审查此里程碑状态。基于当前速率和被阻塞的 Story 数量，此里程碑是否能达到目标日期？从现在到里程碑之间的前 3 大生产风险是什么？是否有应被裁剪以保护里程碑日期的范围项 vs 不可妥协的范围项？返回 ON TRACK、AT RISK [具体缓解措施] 或 OFF TRACK [日期必须推迟或范围必须裁剪 — 提供两种选项]。"

**判定**：ON TRACK / AT RISK / OFF TRACK

---

### PR-EPIC — Epic 结构可行性审查

**触发时机**：在 Epic 由 `/create-epics` 定义后，在 Story 被拆分之前 — 在 `/create-stories` 被调用前验证 Epic 结构是否可生产

**待传递的上下文**：
- Epic 定义文件路径（所有刚创建的 Epic）
- Epic 索引路径（`production/epics/index.md`）
- 里程碑时间线和目标日期
- 团队产能（独立开发者 / 小团队 / 规模）
- 正在被 Epic 化的层级（Foundation / Core / Feature / 等）

**提示**：
> "在 Story 拆分开始前审查此 Epic 结构的生产可行性。Epic 边界范围是否适当 — 每个 Epic 是否能在里程碑截止日期前现实地完成？Epic 是否按系统依赖关系正确排序 — 是否有 Epic 需要在另一个 Epic 的输出完成之后才能开始？是否有 Epic 范围过小（太小，应合并）或范围过大（太大，应拆分为 2-3 个聚焦的 Epic）？Foundation 层 Epic 的范围是否允许 Core 层 Epic 在 Foundation 完成后的下一个 Sprint 开始时启动？返回 REALISTIC（Epic 结构可生产）、CONCERNS [在编写 Story 之前需要的具体结构调整] 或 UNREALISTIC [Epic 必须拆分、合并或重新排序 — Story 拆分在问题解决前无法开始]。"

**判定**：REALISTIC / CONCERNS / UNREALISTIC

---

### PR-PHASE-GATE — 阶段转换时的制作就绪度

**触发时机**：始终在 `/gate-check` 时 — 与 CD-PHASE-GATE 和 TD-PHASE-GATE 并行启动

**待传递的上下文**：
- 目标阶段名称
- 存在的 Sprint 和里程碑产出物
- 团队规模和产能
- 当前被阻塞的 Story 数量

**提示**：
> "从制作角度审查当前项目状态对于 [目标阶段] 的关卡就绪度。范围对于所述时间线和团队规模是否现实？依赖关系是否被正确排序，使团队能够真正按顺序执行？是否存在可能在前两个 Sprint 内就使阶段偏离轨道的里程碑或 Sprint 风险？返回 READY、CONCERNS [列表] 或 NOT READY [阻塞项]。"

**判定**：READY / CONCERNS / NOT READY

---

## 第一层 — 美术总监关卡

Agent：`art-director` | 模型层级：Sonnet | 领域：视觉识别、美术圣经、视觉生产就绪度

---

### AD-CONCEPT-VISUAL — 视觉识别锚点

**触发时机**：在游戏支柱锁定后（脑暴第四阶段），与 CD-PILLARS 并行

**待传递的上下文**：
- 游戏概念（电梯演讲、核心体验目标、独特钩子）
- 完整的支柱集合，包含名称、定义和设计测试
- 目标平台（如果已知）
- 用户提及的任何参考游戏或视觉触点

**提示**：
> "基于这些游戏支柱和核心概念，提出 2-3 个不同的视觉识别方向。对每个方向提供：(1) 一个可指导所有视觉决策的一句话视觉法则（例如 '一切必须运动'、'美在于衰败'），(2) 氛围和气氛目标，(3) 形状语言（锐利/圆润/有机/几何的重点），(4) 色彩哲学（调色板方向，颜色在这个世界中的含义）。要具体 — 避免泛泛描述。其中一个方向应直接服务于主要设计支柱。为每个方向命名。推荐哪个最能服务于所述支柱并解释原因。"

**判定**：CONCEPTS（多个有效选项 — 用户选择）/ STRONG（一个方向明显占优）/ CONCERNS（支柱尚未提供足够方向以区分视觉识别）

---

### AD-ART-BIBLE — 美术圣经签收

**触发时机**：在美术圣经起草后（`/art-bible`），在资源制作开始前

**待传递的上下文**：
- 美术圣经路径（`design/art/art-bible.md`）
- 游戏支柱和核心体验目标
- 平台和性能约束（如果配置了，来自 `.claude/docs/technical-preferences.md`）
- 脑暴期间选定的视觉识别锚点（来自 `design/gdd/game-concept.md`）

**提示**：
> "审查此美术圣经的完整性和内部一致性。色彩系统是否匹配氛围目标？形状语言是否遵循视觉识别陈述？资源标准在平台约束下是否可实现？角色设计方向是否为美术师提供了足够的创作依据而又不过度规定？章节之间是否存在矛盾？外包团队是否能在没有额外简报的情况下根据此文档制作资源？返回 APPROVE（美术圣经已就绪可用于生产）、CONCERNS [需要澄清的具体章节] 或 REJECT [必须在资源制作开始前解决的根本性不一致问题]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### AD-PHASE-GATE — 阶段转换时的视觉就绪度

**触发时机**：始终在 `/gate-check` 时 — 与 CD-PHASE-GATE、TD-PHASE-GATE 和 PR-PHASE-GATE 并行启动

**待传递的上下文**：
- 目标阶段名称
- 所有美术/视觉产出物的列表（文件路径）
- 来自 `design/gdd/game-concept.md` 的视觉识别锚点（如果存在）
- 美术圣经路径（如果存在，`design/art/art-bible.md`）

**提示**：
> "从视觉方向的角度审查当前项目状态对于 [目标阶段] 的关卡就绪度。视觉识别是否在此阶段所需的级别上被建立和文档化？正确的视觉产出物是否到位？视觉团队是否能在没有视觉方向缺口（这些缺口会导致后期昂贵的返工）的情况下开始工作？是否有视觉决策被推迟到了其最晚负责时刻之后？返回 READY、CONCERNS [可能导致制作返工的具体视觉方向缺口] 或 NOT READY [必须在��阶段成功前存在的视觉阻塞项 — 说明缺少什么产出物以及为什么在此阶段重要]。"

**判定**：READY / CONCERNS / NOT READY

---

## 第二层 — 负责人关卡

这些关卡由编排技能和高级技能在需要领域专家进行可行性签收时调用。第二层负责人使用 Sonnet（默认）。

---

### LP-FEASIBILITY — 首席程序员实现可行性

**触发时机**：在主架构文档编写后（`/create-architecture` 阶段 7b），或当新的架构模式被提议时

**待传递的上下文**：
- 架构文档路径
- 技术需求基线摘要
- 带状态的 ADR 列表

**提示**：
> "审查此架构的实现可行性。标记：(a) 任何在所述引擎和语言中难以或无法实现的决策，(b) 程序员需要自行发明的缺失接口定义，(c) 任何会产生可避免的技术债务或与标准 [引擎] 习惯用法相悖的模式。返回 FEASIBLE、CONCERNS [列表] 或 INFEASIBLE [使此架构按现有编写形式无法实现的阻塞项]。"

**判定**：FEASIBLE / CONCERNS / INFEASIBLE

---

### LP-CODE-REVIEW — 首席程序员代码审查

**触发时机**：在开发 Story 实现后（`/dev-story`、`/story-done`），或作为 `/code-review` 的一部分

**待传递的上下文**：
- 实现文件路径
- Story 文件路径（用于验收标准）
- 相关 GDD 章节
- 管辖此系统的 ADR

**提示**：
> "对照 Story 验收标准和管辖 ADR 审查此实现。代码是否匹配架构边界定义？是否存在违反编码规范或禁止模式的情况？公共 API 是否可测试并有文档？是否存在与 GDD 规则相关的正确性问题？返回 APPROVE、CONCERNS [具体问题] 或 REJECT [必须在合并前修订]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### QL-STORY-READY — QA 负责人 Story 就绪度检查

**触发时机**：在 Story 被纳入 Sprint 之前 — 由 `/create-stories`、`/story-readiness` 和 `/sprint-plan` 在 Story 选择期间调用

**待传递的上下文**：
- Story 文件路径
- Story 类型（逻辑类 / 集成类 / 视觉/手感类 / UI 类 / 配置/数据类）
- 验收标准列表（直接从 Story 复制）
- Story 覆盖的 GDD 需求（TR-ID 和文本）

**提示**：
> "在此 Story 进入 Sprint 之前审查其验收标准的可测试性。所有标准是否足够具体，使开发人员能够无歧义地知道何时完成？对于逻辑类 Story：每个标准是否可以通过自动化测试验证？对于集成类 Story：每个标准是否可在受控测试环境中观察到？标记过于模糊以至于无法实施的标准，并标记需要完整游戏构建才能测试的标准（标记为 DEFERRED，而非 BLOCKED）。返回 ADEQUATE（标准可按现有形式实现）、GAPS [需要细化的具体标准] 或 INADEQUATE [标准过于模糊 — Story 必须在纳入 Sprint 前修订]。"

**判定**：ADEQUATE / GAPS / INADEQUATE

---

### QL-TEST-COVERAGE — QA 负责人测试覆盖率审查

**触发时机**：在实现 Story 完成后，标记 Epic 完成之前，或在 `/gate-check` Production → Polish 时

**待传递的上下文**：
- 已实现 Story 的列表及其类型（逻辑类 / 集成类 / 视觉类 / UI 类 / 配置类）
- `tests/` 中的测试文件路径
- 系统的 GDD 验收标准

**提示**：
> "审查这些实现 Story 的测试覆盖率。所有逻辑类 Story 是否由通过的单元测试覆盖？集成类 Story 是否由集成测试或文档化的试玩覆盖？GDD 验收标准是否每个都映射到至少一个测试？GDD 边界情况章节中是否存在未测试的边界情况？返回 ADEQUATE（覆盖率符合标准）、GAPS [具体缺失的测试] 或 INADEQUATE [关键逻辑未经测试 — 不得推进]。"

**判定**：ADEQUATE / GAPS / INADEQUATE

---

### ND-CONSISTENCY — 叙事总监一致性检查

**触发时机**：在 writer 交付物（对白、背景设定、物品描述）被编写后，或当设计决策具有叙事影响时

**待传递的上下文**：
- 文档或内容文件路径
- 叙事圣经或基调指南路径（如果存在）
- 相关的世界观构建规则
- 受影响的角色或派系简档

**提示**：
> "审查此叙事内容的内部一致性及对已有世界规则的遵循。角色声音是否与其已有简档一致？背景设定是否与任何已有事实相矛盾？基调是否与游戏的叙事方向一致？返回 APPROVE、CONCERNS [需要修正的具体不一致] 或 REJECT [破坏叙事基础的矛盾]。"

**判定**：APPROVE / CONCERNS / REJECT

---

### AD-VISUAL — 美术总监视觉一致性审查

**触发时机**：在美术方向决策做出后、新资源类型被引入时，或技术美术决策影响视觉风格时

**待传递的上下文**：
- 美术圣经路径（如果存在于 `design/art/art-bible.md`）
- 正在被审查的具体资源类型、风格决策或视觉方向
- 参考图片或风格描述
- 平台和性能约束

**提示**：
> "审查此视觉方向决策与已有美术风格和制作约束的一致性。是否匹配美术圣经？在平台的性能预算内是否可实现？是否存在会造成技术风险的资源管线影响？返回 APPROVE、CONCERNS [具体调整建议] 或 REJECT [必须首先解决的风格违规或制作风险]。"

**判定**：APPROVE / CONCERNS / REJECT

---

## 并行关卡协议

当工作流需要在同一检查点启动多位总监时（最常见的是 `/gate-check`），同时启动所有 Agent：

```
并行启动（在等待任何结果之前发出所有 Task 调用）：
1. creative-director  → 关卡 CD-PHASE-GATE
2. technical-director → 关卡 TD-PHASE-GATE
3. producer           → 关卡 PR-PHASE-GATE
4. art-director       → 关卡 AD-PHASE-GATE

收集所有四个判定，然后应用升级规则：
- 任意 NOT READY / REJECT → 总判定最低为 FAIL
- 任意 CONCERNS → 总判定最低为 CONCERNS
- 全部 READY / APPROVE → 符合 PASS 条件（仍需进行产出物检查）
```

---

## 添加新关卡

当新技能或工作流需要新关卡时：

1. 分配一个关卡 ID：`[总监前缀]-[描述性短名称]`
   - 前缀：`CD-` `TD-` `PR-` `LP-` `QL-` `ND-` `AD-`
   - 为新 Agent 添加新前缀：`audio-director` → `AU-`、`ux-designer` → `UX-`
2. 在相应的总监章节下添加关卡，包含全部五个字段：
   触发时机、待传递的上下文、提示、判定以及任何特殊处理说明
3. 在技能中仅通过 ID 引用 — 绝不要将提示文本复制到技能中

---

## 按阶段的关卡覆盖

| 阶段 | 必需关卡 | 可选关卡 |
|-------|---------------|----------------|
| **概念阶段** | CD-PILLARS、AD-CONCEPT-VISUAL | TD-FEASIBILITY、PR-SCOPE |
| **系统设计阶段** | TD-SYSTEM-BOUNDARY、CD-SYSTEMS、PR-SCOPE、CD-GDD-ALIGN（每个 GDD） | ND-CONSISTENCY、AD-VISUAL |
| **技术设置阶段** | TD-ARCHITECTURE、TD-ADR（每个 ADR）、LP-FEASIBILITY、AD-ART-BIBLE | TD-ENGINE-RISK |
| **预生产阶段** | PR-EPIC、QL-STORY-READY（每个 Story）、PR-SPRINT、全部四个阶段关卡（通过 gate-check） | CD-PLAYTEST |
| **生产阶段** | LP-CODE-REVIEW（每个 Story）、QL-STORY-READY、PR-SPRINT（每个 Sprint）、QL-TEST-COVERAGE（每个 Sprint 收尾） | PR-MILESTONE、AD-VISUAL |
| **打磨阶段** | QL-TEST-COVERAGE、CD-PLAYTEST、PR-MILESTONE | AD-VISUAL |
| **发布阶段** | 全部四个阶段关卡（通过 gate-check） | QL-TEST-COVERAGE |
