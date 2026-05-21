<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 技能测试规范：/balance-check

## 技能摘要

`/balance-check` 读取平衡数据文件（`assets/data/` 中的 JSON 或 YAML），并将每个值与 `design/gdd/` 下 GDD 中定义的设计公式进行核对。它生成一个发现结果表，包含以下列：值 → 公式 → 偏差 → 严重性。不会调用任何导演门禁（只读分析）。该技能可以可选择地写入平衡报告，但在写入前会询问 "May I write"。判决词：BALANCED、CONCERNS 或 OUT OF BALANCE。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：BALANCED、CONCERNS、OUT OF BALANCE
- [ ] 包含 "May I write" 相关表述（可选报告写入）
- [ ] 具有后续步骤交接（发现结果审查后的操作指引）

---

## 导演门禁检查

无。平衡检查是只读分析技能；不会调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——所有平衡值均在公式容差范围内

**Fixture：**
- `assets/data/combat-balance.json` 存在，包含 6 个属性值
- `design/gdd/combat-system.md` 包含所有 6 个属性的公式，容差为 ±10%
- 所有 6 个值均在容差范围内

**输入：** `/balance-check`

**预期行为：**
1. 技能读取 `assets/data/` 中的所有平衡数据文件
2. 技能从 `design/gdd/` 读取 GDD 公式
3. 技能计算每个值与其公式之间的偏差
4. 所有偏差均在 ±10% 容差范围内
5. 技能输出发现结果表，所有行显示 PASS
6. 判决为 BALANCED

**断言：**
- [ ] 所有已检查的值都显示在发现结果表中
- [ ] 每行显示：属性名、公式目标值、实际值、偏差百分比
- [ ] 在容差范围内时，所有行显示 PASS 或等效标记
- [ ] 判决为 BALANCED
- [ ] 未经用户批准不写入任何文件

---

### 用例 2：失衡——玩家伤害高于公式目标值 40%

**Fixture：**
- `assets/data/combat-balance.json` 中 `player_damage_base: 140`
- `design/gdd/combat-system.md` 公式指定 `player_damage_base = 100`（±10%）
- 所有其他属性在容差范围内

**输入：** `/balance-check`

**预期行为：**
1. 技能读取 combat-balance.json 并计算 `player_damage_base` 的偏差
2. 偏差为 +40%——远超 ±10% 容差
3. 技能在发现结果表中将该行标记为严重性 HIGH
4. 判决为 OUT OF BALANCE
5. 技能在表格之前突出显示 HIGH 严重性项目

**断言：**
- [ ] `player_damage_base` 行显示偏差为 +40%
- [ ] 偏差超过容差 2 倍以上的项目，严重性为 HIGH
- [ ] 当任何属性具有 HIGH 严重性偏差时，判决为 OUT OF BALANCE
- [ ] HIGH 严重性项目被显式突出显示，而非淹没在表格行中

---

### 用例 3：无 GDD 公式——无法验证，给出指导

**Fixture：**
- `assets/data/economy-balance.yaml` 存在，包含 10 个属性值
- `design/gdd/` 中没有 GDD 包含经济属性的公式定义

**输入：** `/balance-check`

**预期行为：**
1. 技能读取平衡数据文件
2. 技能在 GDD 中搜索公式定义——未找到经济属性的公式
3. 技能输出："无法验证经济属性——未定义公式。请先运行 /design-system。"
4. 不为经济属性生成发现结果表
5. 判决为 CONCERNS（数据存在但无法验证）

**断言：**
- [ ] 当 GDD 中不存在公式时，技能不凭空编造公式目标值
- [ ] 输出显式指明缺失的公式来源
- [ ] 输出建议运行 `/design-system` 来定义公式
- [ ] 判决为 CONCERNS（非 BALANCED，因为无法进行验证）

---

### 用例 4：孤立引用——平衡文件引用了未定义的属性

**Fixture：**
- `assets/data/combat-balance.json` 包含属性 `legacy_armor_mult: 1.5`
- `design/gdd/combat-system.md` 中没有 `legacy_armor_mult` 的公式
- 所有其他属性都有公式定义并通过验证

**输入：** `/balance-check`

**预期行为：**
1. 技能从 combat-balance.json 读取所有属性
2. 技能在任何 GDD 中都找不到 `legacy_armor_mult` 的公式
3. 技能在发现结果表中将 `legacy_armor_mult` 标记为 ORPHAN REFERENCE
4. 其他属性正常评估；在容差范围内的显示 PASS
5. 判决为 CONCERNS（孤立引用阻止了完整验证）

**断言：**
- [ ] `legacy_armor_mult` 在发现结果表中以 ORPHAN REFERENCE 状态出现
- [ ] 孤立引用在表中与公式偏差区分开来
- [ ] 当发现任何孤立引用时，判决为 CONCERNS
- [ ] 技能不会悄悄跳过孤立属性

---

### 用例 5：门禁合规——只读；无门禁；可选报告需要审批

**Fixture：**
- 平衡数据和 GDD 公式存在；1 个属性具有 CONCERNS 级别的偏差（高于目标值 15%）
- `review-mode.txt` 包含 `full`

**输入：** `/balance-check`

**预期行为：**
1. 技能读取数据和 GDD；生成发现结果表
2. 判决为 CONCERNS（一个属性略微超出范围）
3. 不会调用任何导演门禁
4. 技能向用户呈现发现结果表
5. 技能提供写入可选平衡报告的选项
6. 如果用户同意：技能询问 "我可以写入 `production/qa/balance-report-[date].md` 吗？"
7. 如果用户不同意：技能结束而不写入

**断言：**
- [ ] 在任何审查模式下均不会调用导演门禁
- [ ] 发现结果表在不自动写入任何内容的情况下呈现
- [ ] 可选报告写入是提供的而非强制
- [ ] "May I write" 提示仅在用户选择写入报告时出现

---

## 协议合规

- [ ] 在分析前同时读取平衡数据文件和 GDD 公式
- [ ] 发现结果表显示值、公式、偏差和严重性列
- [ ] 未经用户明确批准不写入任何文件
- [ ] 不调用任何导演门禁
- [ ] 判决为以下之一：BALANCED、CONCERNS、OUT OF BALANCE

---

## 覆盖说明

- `assets/data/` 完全为空的情况未测试；行为遵循 CONCERNS 模式，并提示未找到数据文件。
- 容差阈值（±10%、±20%）是技能的实现细节；测试验证的是偏差能被检测和分类，而非精确的阈值数值。
