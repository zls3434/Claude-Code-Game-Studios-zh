<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/map-systems

## Skill 摘要

`/map-systems` 将游戏概念分解为系统索引。它读取已批准的
游戏概念和支柱，枚举显式和隐式系统，映射系统间的依赖关系，
分配优先级层级（MVP / Vertical Slice / Alpha / Full Vision），
并将系统组织为分层设计顺序（Foundation → Core → Feature → Presentation）。
输出经用户批准后写入 `design/systems-index.md`。

此 Skill 是游戏概念批准与逐个系统 GDD 创建之间的必经环节 ——
它是流水线中的一个强制性关卡。在 `full` 审查模式下，CD-SYSTEMS
（creative-director）和 TD-SYSTEM-BOUNDARY（technical-director）
在系统分解草案完成后并行启动。在 `lean` 或 `solo` 模式下，两个关卡均跳过。
该 Skill 写入 `design/systems-index.md`。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 不需要 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁定关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 协作协议语言（用于 systems-index.md）
- [ ] 末尾有下一步交接（`/design-system`）
- [ ] 记录关卡行为：full 模式下 CD-SYSTEMS + TD-SYSTEM-BOUNDARY 并行启动

---

## 总监关卡检查

在 `full` 模式下：CD-SYSTEMS（creative-director）和 TD-SYSTEM-BOUNDARY
（technical-director）在系统分解草案完成后、`design/systems-index.md`
写入前并行启动。

在 `lean` 模式下：两个关卡均跳过。输出记录：
"CD-SYSTEMS 已跳过 — lean 模式"和"TD-SYSTEM-BOUNDARY 已跳过 — lean 模式"。

在 `solo` 模式下：两个关卡均跳过，输出等效的记录。

---

## 测试用例

### 用例 1：正常路径 — 游戏概念存在，识别到 5-8 个系统

**测试环境配置（Fixture）：**
- `design/gdd/game-concept.md` 存在，包含核心机制和 MVP 定义章节
- `design/gdd/game-pillars.md` 存在，至少定义了 1 个支柱
- `design/systems-index.md` 尚不存在
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/map-systems`

**预期行为：**
1. Skill 读取 game-concept.md 和 game-pillars.md
2. 识别到 5-8 个系统（显式 + 隐式）
3. 映射系统间的依赖关系并分配层级
4. CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY 并行启动并返回 APPROVED
5. 询问 "May I write `design/systems-index.md`?"
6. 批准后写入 systems-index.md
7. 更新 `production/session-state/active.md`

**断言：**
- [ ] 识别到 5 到 8 个系统（不能少于 5 个，若无解释不能超过 8 个）
- [ ] CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY 并行启动（非顺序执行）
- [ ] 两个关卡均在 "May I write" 询问前完成
- [ ] "May I write `design/systems-index.md`?" 在写入前先询问
- [ ] systems-index.md 未经批准不被写入
- [ ] 写入后更新会话状态
- [ ] 裁定为 COMPLETE

---

### 用例 2：失败路径 — 未找到游戏概念

**测试环境配置（Fixture）：**
- `design/gdd/game-concept.md` 不存在
- `design/gdd/` 目录可能为空或不存在

**输入：** `/map-systems`

**预期行为：**
1. Skill 尝试读取 `design/gdd/game-concept.md`
2. 文件未找到
3. Skill 输出："未找到游戏概念。运行 `/brainstorm` 创建一个，然后回到 `/map-systems`。"
4. Skill 退出，不创建 systems-index.md

**断言：**
- [ ] Skill 输出明确的错误，指出缺失文件的路径
- [ ] Skill 建议 `/brainstorm` 作为下一步操作
- [ ] 不创建 systems-index.md
- [ ] 裁定为 BLOCKED

---

### 用例 3：总监关卡 — CD-SYSTEMS 返回 CONCERNS（缺失核心系统）

**测试环境配置（Fixture）：**
- 游戏概念存在
- `production/session-state/review-mode.txt` 包含 `full`
- CD-SYSTEMS 关卡返回 CONCERNS："[core-system] 在概念中隐含存在但未被识别"

**输入：** `/map-systems`

**预期行为：**
1. 系统草案生成（初始识别到 5-8 个系统）
2. CD-SYSTEMS 关卡返回 CONCERNS，指出缺失的核心系统
3. TD-SYSTEM-BOUNDARY 返回 APPROVED
4. Skill 向用户展示 CD-SYSTEMS 的关注问题
5. 向用户询问：修改系统列表以添加缺失的系统，或按当前状态继续
6. 如果修改：在 "May I write" 询问前展示更新后的系统列表

**断言：**
- [ ] CD-SYSTEMS 的关注问题在写入前向用户展示
- [ ] 当 CONCERNS 未解决时，Skill 不自动写入 systems-index.md
- [ ] 用户可以选择修改或继续
- [ ] 修改后的系统列表在最终 "May I write" 前再次展示

---

### 用例 4：边界情况 — systems-index.md 已存在

**测试环境配置（Fixture）：**
- `design/gdd/game-concept.md` 存在
- `design/systems-index.md` 已存在，包含 N 个系统

**输入：** `/map-systems`

**预期行为：**
1. Skill 读取现有的 systems-index.md 并展示其当前状态
2. Skill 询问："systems-index.md 已存在，包含 [N] 个系统。是否要添加新系统，还是审查并修订优先级？"
3. 用户选择一个操作
4. Skill 不会静默覆盖现有的索引

**断言：**
- [ ] Skill 在继续之前检测并读取现有的 systems-index.md
- [ ] 用户被提供更新/审查选项 —— 不会自动覆盖
- [ ] 现有系统数量展示给用户
- [ ] 若用户未选择，Skill 不执行完全重新分解

---

### 用例 5：总监关卡 — lean 模式和 solo 模式均跳过关卡并记录

**测试环境配置（lean 模式）：**
- 游戏概念存在
- `production/session-state/review-mode.txt` 包含 `lean`

**Lean 模式预期行为：**
1. 系统被分解并生成草案
2. CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY 均跳过
3. 输出记录："CD-SYSTEMS 已跳过 — lean 模式"和"TD-SYSTEM-BOUNDARY 已跳过 — lean 模式"
4. 直接进入 "May I write" 询问

**断言（lean 模式）：**
- [ ] 两个关卡跳过记录均出现在输出中
- [ ] Skill 在无关卡批准的情况下进入 "May I write"
- [ ] systems-index.md 在用户批准后写入

**测试环境配置（solo 模式）：**
- 相同的游戏概念，`production/session-state/review-mode.txt` 包含 `solo`

**Solo 模式预期行为：**
1. 相同的分解工作流
2. 两个关卡均跳过 —— 在输出中标注 "solo 模式"
3. 进入 "May I write" 询问

**断言（solo 模式）：**
- [ ] 两个跳过记录均带有 "solo 模式" 标签
- [ ] 此 Skill 在 solo 模式下行为与 lean 模式一致

---

## 协议合规

- [ ] 在任何分解之前读取 game-concept.md 和 game-pillars.md
- [ ] 写入前询问 "May I write `design/systems-index.md`?"
- [ ] systems-index.md 未经用户批准不被写入
- [ ] full 模式下 CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY 并行启动
- [ ] lean/solo 输出中按名称和模式记录跳过的关卡
- [ ] 以下一步交接结束：`/design-system [next-system]`

---

## 覆盖说明

- 循环依赖检测（系统 A 依赖系统 B，系统 B 又依赖系统 A）
  是依赖映射阶段的一部分 —— 此处不单独进行 fixture 测试。
- 优先级层级分配（MVP 启发式规则）作为用例 1 协作工作流的一部分
  进行评估，而非独立测试。
- `next` 参数模式（将最高优先级的未设计系统移交给 `/design-system`）
  此处不测试 —— 它是索引创建后的便利功能。
