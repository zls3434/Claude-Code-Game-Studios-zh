<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/team-level

## Skill 摘要

为单个关卡或区域编排完整的关卡设计团队。通过五个顺序步骤（含一个并行阶段——步骤 4）协调 narrative-director、world-builder、level-designer、systems-designer、art-director、accessibility-specialist 和 qa-tester。将所有团队输出编译为一份统一的关卡设计文档，保存至 `design/levels/[level-name].md`。在每个步骤转换处使用 `AskUserQuestion`。将所有文件写入委托给子 Agent。产出带有裁定 COMPLETE / BLOCKED 的总结报告，并向 `/design-review`、`/dev-story`、`/qa-plan` 移交。

---

## 静态断言（结构）

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段/步骤标题（步骤 1 到步骤 5 全部存在）
- [ ] 包含裁定关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 或 "文件写入协议"——写入委托给子 Agent，编排者不直接写入文件
- [ ] 末尾有下一步交接（引用 `/design-review`、`/dev-story`、`/qa-plan`）
- [ ] 错误恢复协议章节存在，包含全部四个恢复步骤
- [ ] 步骤转换处使用 `AskUserQuestion` 获取用户批准再继续
- [ ] 步骤 4 明确标记为并行（art-director 和 accessibility-specialist 同时运行）
- [ ] 上下文收集读取：`design/gdd/game-concept.md`、`design/gdd/game-pillars.md`、`design/levels/`、`design/narrative/` 及相关世界构建文档
- [ ] 团队组成列出全部七个角色（narrative-director、world-builder、level-designer、systems-designer、art-director、accessibility-specialist、qa-tester）
- [ ] accessibility-specialist 输出包含严重程度分级（BLOCKING / RECOMMENDED / NICE TO HAVE）
- [ ] 最终关卡设计文档保存至 `design/levels/[level-name].md`

---

## 测试用例

### 用例 1：正常路径 — 所有团队成员产出输出，文档编译并保存

**测试环境配置（Fixture）：**
- `design/gdd/game-concept.md` 存在且已填充
- `design/gdd/game-pillars.md` 存在
- `design/levels/` 目录存在（可能包含其他关卡文档）
- `design/narrative/` 目录存在，包含相关叙事文档

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 上下文收集——编排者读取 game-concept.md、game-pillars.md、`design/levels/` 中的已有关卡文档、`design/narrative/` 中的叙事文档、以及森林区域的世界构建文档
2. 步骤 1——启动 narrative-director：定义叙事目的、关键角色、对话触发器、情感弧线；启动 world-builder：提供世界观背景、环境叙事机会、世界规则；`AskUserQuestion` 在步骤 2 前确认步骤 1 输出
3. 步骤 2——启动 level-designer：设计空间布局（关键路径、可选路径、秘密区域）、节奏曲线、遭遇战、谜题、入口/出口点及与相邻区域的连接；`AskUserQuestion` 在步骤 3 前确认布局
4. 步骤 3——启动 systems-designer：指定敌人组合、掉落表、难度平衡、区域特定机制、资源分布；`AskUserQuestion` 在步骤 4 前确认系统
5. 步骤 4——art-director 和 accessibility-specialist 并行启动；art-director：视觉主题、调色板、光照、资源清单、VFX 需求；accessibility-specialist：导航清晰度、色盲安全性、认知负荷检查——每项关注分级为 BLOCKING / RECOMMENDED / NICE TO HAVE；`AskUserQuestion` 在步骤 5 前展示两个输出
6. 步骤 5——启动 qa-tester：关键路径测试用例、边界/边缘情况（序列中断、软锁）、试玩检查清单、验收标准
7. 编排者将所有团队输出编译为关卡设计文档格式；子 Agent 询问 "May I write to `design/levels/forest-dungeon.md`?"；文件保存
8. 总结报告：区域概述、遭遇战数量、预估资源清单、叙事节拍、跨团队依赖项，裁定：COMPLETE
9. 列出下一步：`/design-review design/levels/forest-dungeon.md`、`/dev-story`、`/qa-plan`

**断言：**
- [ ] 在启动任何 Agent 前，上下文收集阶段读取全部五个来源
- [ ] narrative-director 和 world-builder 均在步骤 1 中启动（可顺序或并行——两者均须在步骤 2 前完成）
- [ ] 每个步骤关卡调用 `AskUserQuestion`（最少：步骤 1、步骤 2、步骤 3、步骤 4 之后）
- [ ] 步骤 4 Agent（art-director、accessibility-specialist）同时启动
- [ ] 所有文件写入委托给子 Agent——编排者不直接写入
- [ ] 关卡文档保存至 `design/levels/forest-dungeon.md`（参数经 slug 化）
- [ ] 最终总结报告中裁定为 COMPLETE
- [ ] 下一步包含 `/design-review`、`/dev-story`、`/qa-plan`
- [ ] 总结报告包含：区域概述、遭遇战数量、预估资源清单、叙事节拍

---

### 用例 2：Agent 阻塞（world-builder）——产出带差距标注的部分报告

**测试环境配置（Fixture）：**
- `design/gdd/game-concept.md` 存在
- 森林区域的世界构建文档不存在
- world-builder Agent 返回 BLOCKED："未找到森林区域的世界构建文档——无法提供世界观背景"

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 上下文收集完成；标注了缺失的世界构建文档
2. 步骤 1——narrative-director 成功完成；启动 world-builder，返回 BLOCKED
3. 触发错误恢复协议："world-builder：BLOCKED — 无森林区域的世界构建文档"
4. `AskUserQuestion` 展示选项：
   - (a) 跳过 world-builder，在关卡文档中标注世界观差距
   - (b) 以更窄范围重试（world-builder 仅聚焦于可从 game-concept.md 推断的内容）
   - (c) 在此停止，先创建世界构建文档
5. 若用户选择 (a)：流水线继续步骤 2–5，仅使用 narrative-director 的上下文；编译关卡文档，附带有明确标记的差距章节："世界构建上下文：未提供 — 参见开放依赖项"
6. 产出最终报告：记录部分输出，world-builder 章节标记为 BLOCKED，总体裁定：BLOCKED

**断言：**
- [ ] world-builder 失败时立即出现 BLOCKED 呈现消息——步骤 2 不在无用户输入的情况下开始
- [ ] `AskUserQuestion` 提供至少三个选项（跳过 / 重试 / 停止）
- [ ] 产出部分报告——narrative-director 的已完成工作不被丢弃
- [ ] 关卡文档（若编译）包含对缺失世界构建上下文的明确差距标注
- [ ] 当 world-builder 未解决时，总体裁定为 BLOCKED（非 COMPLETE）
- [ ] Skill 不静默虚构世界观内容来填补差距

---

### 用例 3：无参数 — 显示使用说明

**测试环境配置（Fixture）：**
- 任意项目状态

**输入：** `/team-level`（无参数）

**预期行为：**
1. Skill 检测到未提供参数
2. 输出使用消息，解释必需参数（要设计的关卡名称或区域）
3. 提供示例调用：`/team-level tutorial`、`/team-level forest dungeon`、`/team-level final boss arena`
4. Skill 退出，不读取任何项目文件或启动任何子 Agent

**断言：**
- [ ] 无参数时 Skill 不启动任何子 Agent
- [ ] 使用消息包含 frontmatter 中的 argument-hint 格式
- [ ] 至少展示一个有效调用示例
- [ ] 失败前未读取 GDD 或关卡文件
- [ ] 不显示裁定（流水线从未开始）

---

### 用例 4：无障碍审查关卡 — 阻塞性关注在签收前浮现

**测试环境配置（Fixture）：**
- 步骤 1–3 成功完成
- `design/accessibility-requirements.md` 已承诺等级：Enhanced
- accessibility-specialist（步骤 4，并行）标记一个 BLOCKING 关注：玩家需要通过颜色区分两项环境危害（毒池 vs 浅水）但无形状、图标或音频提示加以区分

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 步骤 1–3 完成；步骤 4 并行阶段开始
2. accessibility-specialist 返回：BLOCKING 关注 — "关键路径危害区分仅依赖颜色（毒池 vs 浅水）。根据 Enhanced 无障碍等级，需要形状、图标或音频提示。"
3. art-director 返回步骤 4 输出（完成）
4. Skill 通过 `AskUserQuestion` 展示两个步骤 4 结果——BLOCKING 关注突出高亮
5. `AskUserQuestion` 提供：
   - (a) 返回 level-designer + art-director 在步骤 5 前重新设计危害视觉/音频语言
   - (b) 记录为已知无障碍差距，携带此关注继续步骤 5
6. Skill 不静默越过 BLOCKING 关注
7. 若用户选择 (a)：启动 level-designer 和 art-director 修订；重新运行步骤 4 无障碍检查
8. 无论用户选择如何，最终报告包含 BLOCKING 关注及其解决状态

**断言：**
- [ ] BLOCKING 无障碍关注不被视为建议——作为阻塞项呈现
- [ ] `AskUserQuestion` 展示具体关注文本（而不仅是"发现无障碍问题"）
- [ ] 步骤 5（qa-tester）在用户确认 BLOCKING 关注前不开始
- [ ] 提供修订路径：可在继续前将 level-designer + art-director 送回
- [ ] 最终报告包含无障碍关注及其解决状态
- [ ] accessibility-specialist 阻塞时不丢弃 art-director 的已完成输出

---

### 用例 5：关卡循环引用 — 标记相邻区域依赖

**测试环境配置（Fixture）：**
- 步骤 1–3 进行中
- level-designer（步骤 2）生成的布局指定了连接到 "the crystal caves"（相邻区域）的入口/出口
- `design/levels/crystal-caves.md` 不存在——crystal caves 区域尚未被设计

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 步骤 2——level-designer 产出布局，包含："西侧出口连接至 crystal-caves 入口点 A"
2. 编排者（或 level-designer 子 Agent）检查 `design/levels/` 中是否有 `crystal-caves.md`；文件未找到
3. 呈现依赖差距："关卡引用了 crystal-caves 作为相邻区域，但 `design/levels/crystal-caves.md` 不存在"
4. `AskUserQuestion` 展示选项：
   - (a) 使用占位引用继续——在关卡文档中标注依赖为 UNRESOLVED
   - (b) 暂停，先运行 `/team-level crystal caves` 建立该区域
5. Skill 不凭空创造 crystal caves 内容来满足引用
6. 若用户选择 (a)：编译关卡文档，西侧出口标记为 "→ crystal-caves（UNRESOLVED — 区域尚未设计）"；在总结报告的开放依赖章节中标记
7. 最终报告包含开放跨关卡依赖章节

**断言：**
- [ ] Skill 通过检查 `design/levels/` 检测到缺失的相邻区域——不假定之后会创建
- [ ] Skill 不凭空创造 crystal caves 内容（世界观、布局、连接）来解决引用
- [ ] `AskUserQuestion` 提供引用 `/team-level` 的"先设计 crystal caves"选项
- [ ] 若用户以占位引用继续，关卡文档明确将西侧出口标记为 UNRESOLVED
- [ ] 总结报告包含列出未解决引用的开放跨关卡依赖章节
- [ ] 循环或前向引用不会导致 Skill 循环或崩溃

---

## 协议合规

- [ ] 每个步骤转换处使用 `AskUserQuestion`——用户批准后再推进流水线
- [ ] 所有文件写入通过 Task 委托给子 Agent——编排者不直接调用 Write 或 Edit
- [ ] 遵循错误恢复协议：呈现 → 评估 → 提供选项 → 部分报告
- [ ] 步骤 4 Agent（art-director、accessibility-specialist）按 Skill 规范并行启动
- [ ] 即使 Agent 处于 BLOCKED 状态，始终产出部分报告
- [ ] 无障碍 BLOCKING 关注在签收前呈现，并需要明确的用户确认
- [ ] 裁定为 COMPLETE / BLOCKED 之一
- [ ] 末尾有下一步：`/design-review`、`/dev-story`、`/qa-plan`

---

## 覆盖说明

- 步骤 1 中 narrative-director 和 world-builder 可顺序或并行——Skill 规范启动两者但不强制同时启动；并行步骤 1 的覆盖需要一个明确的时间断言 fixture。
- 阻塞 world-builder 用例（Case 2）中的"以更窄范围重试"选项——重试行为本身未深度测试；其完整路径与其他 team-* 规格中的阻塞 Agent 模式类似。
- systems-designer（步骤 3）阻塞场景未单独测试；同样的错误恢复协议适用，模式由 Case 2 验证。
- 步骤 4 并行顺序（art-director 在 accessibility-specialist 之前或之后完成）不影响结果——无论顺序如何，两者都必须在步骤 5 前返回。
- 关卡文档 slug 约定（参数 → 文件名）由 Case 1 隐式测试（`forest dungeon` → `forest-dungeon.md`）；多词 slug 化边界情况（特殊字符、超长名称）未被覆盖。
