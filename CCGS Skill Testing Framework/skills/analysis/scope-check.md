<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 技能测试规范：/scope-check

## 技能摘要

`/scope-check` 是一个 Haiku 层级的只读技能，分析功能、冲刺或故事的范围蔓延风险。它读取冲刺和故事文件，并将其与当前活跃的里程碑目标进行对比。它专为在规划前或规划期间进行快速、低成本的检查而设计。不会调用任何导演门禁。不写入任何文件。判决词：ON SCOPE、CONCERNS 或 SCOPE CREEP DETECTED。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：ON SCOPE、CONCERNS、SCOPE CREEP DETECTED
- [ ] 不要求包含 "May I write" 相关表述（只读技能）
- [ ] 具有后续步骤交接（基于判决的操作指引）

---

## 导演门禁检查

无。范围检查是只读建议技能；不会调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——冲刺故事与里程碑目标对齐

**Fixture：**
- `production/milestones/milestone-03.md` 列出了 3 个目标：战斗系统、敌人 AI、关卡加载
- `production/sprints/sprint-006.md` 包含 5 个故事，全部标记到了 3 个目标之一
- `production/session-state/active.md` 引用 milestone-03 作为活跃里程碑

**输入：** `/scope-check`

**预期行为：**
1. 技能从 milestone-03 读取活跃里程碑目标
2. 技能读取 sprint-006 的故事，并逐一与里程碑目标核对
3. 所有 5 个故事均映射到了 3 个目标之一
4. 技能输出映射表：故事 → 里程碑目标
5. 判决为 ON SCOPE

**断言：**
- [ ] 输出中每个故事都映射到了一个里程碑目标
- [ ] 当所有故事均映射到里程碑目标时，判决为 ON SCOPE
- [ ] 不写入任何文件
- [ ] 技能不修改冲刺或里程碑文件

---

### 用例 2：检测到范围蔓延——故事引入了里程碑之外的系统

**Fixture：**
- `production/milestones/milestone-03.md` 目标：战斗、敌人 AI、关卡加载
- `production/sprints/sprint-006.md` 包含 5 个故事：
  - 3 个故事映射到里程碑目标
  - 2 个故事引用了 "online leaderboard" 和 "achievement system"（不在 milestone-03 中）

**输入：** `/scope-check`

**预期行为：**
1. 技能读取里程碑目标和冲刺故事
2. 技能识别出 2 个没有匹配里程碑目标的故事
3. 技能指名超出范围的故事："Online Leaderboard Feature"、"Achievement System Setup"
4. 判决为 SCOPE CREEP DETECTED

**断言：**
- [ ] 超出范围的故事在输出中被显式命名
- [ ] 当任何故事没有匹配的里程碑目标时，判决为 SCOPE CREEP DETECTED
- [ ] 技能不会自动移除这些故事——发现结果是建议性的
- [ ] 输出建议将超出范围的故事推迟到之后的里程碑

---

### 用例 3：未定义里程碑——CONCERNS；无法验证范围

**Fixture：**
- `production/session-state/active.md` 没有里程碑引用
- `production/milestones/` 目录存在但为空
- `production/sprints/sprint-006.md` 有 4 个故事

**输入：** `/scope-check`

**预期行为：**
1. 技能读取 active.md——未找到里程碑引用
2. 技能检查 `production/milestones/`——未找到里程碑文件
3. 技能输出："未定义活跃里程碑——无法验证范围"
4. 判决为 CONCERNS

**断言：**
- [ ] 当没有定义里程碑时，技能不会出错
- [ ] 输出显式声明范围验证需要里程碑引用
- [ ] 判决为 CONCERNS（在没有数据的情况下，非 ON SCOPE 也非 SCOPE CREEP DETECTED）
- [ ] 输出建议运行 `/milestone-review` 或创建一个里程碑

---

### 用例 4：单个故事检查——根据其父级 Epic 进行评估

**Fixture：**
- 用户针对单个故事：`production/epics/combat/story-parry-timing.md`
- 故事引用了父级 Epic：`epic-combat.md`
- `production/epics/combat/epic-combat.md` 的范围是："近战战斗机制"
- 故事标题："Implement parry timing window"——与 Epic 范围匹配

**输入：** `/scope-check production/epics/combat/story-parry-timing.md`

**预期行为：**
1. 技能读取指定的故事文件
2. 技能读取父级 Epic 以获取范围定义
3. 技能根据 Epic 范围评估故事——"parry timing" 匹配 "melee combat"
4. 判决为 ON SCOPE

**断言：**
- [ ] 接受单个文件参数（故事路径，而非冲刺）
- [ ] 技能读取故事文件中引用的父级 Epic
- [ ] 在单故事模式下，故事根据 Epic 范围（而非里程碑范围）进行评估
- [ ] 当故事匹配 Epic 范围时，判决为 ON SCOPE

---

### 用例 5：门禁合规——无门禁；制作人（PR）可单独咨询

**Fixture：**
- 冲刺有 2 个 SCOPE CREEP 故事和 3 个 ON SCOPE 故事
- `review-mode.txt` 包含 `full`

**输入：** `/scope-check`

**预期行为：**
1. 技能读取里程碑和冲刺；识别出 2 个范围蔓延项
2. 无论审查模式如何，均不会调用导演门禁
3. 技能呈现发现结果，判决为 SCOPE CREEP DETECTED
4. 输出注明："考虑在冲刺开始前与制作人（Producer）沟通范围问题"
5. 技能结束时不写入任何文件

**断言：**
- [ ] 在任何审查模式下均不会调用导演门禁
- [ ] 制作人咨询是建议性的（非强制）
- [ ] 不写入任何文件
- [ ] 判决为 SCOPE CREEP DETECTED

---

## 协议合规

- [ ] 在分析前读取里程碑目标和冲刺/故事文件
- [ ] 将每个故事映射到一个里程碑目标（或标记为未映射）
- [ ] 不写入任何文件
- [ ] 不调用任何导演门禁
- [ ] 在 Haiku 模型层级上运行（快速、低成本）
- [ ] 判决为以下之一：ON SCOPE、CONCERNS、SCOPE CREEP DETECTED

---

## 覆盖说明

- 冲刺文件本身不存在的情况未测试；技能会输出 CONCERNS 判决，并附带关于缺失冲刺数据的提示。
- 部分范围重叠（故事涉及里程碑目标但也引入了新范围）未显式测试；实现可能将其归类为 CONCERNS 而非 SCOPE CREEP DETECTED。
