<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 技能测试规范：/consistency-check

## 技能摘要

`/consistency-check` 扫描 `design/gdd/` 中的所有 GDD，并检查各文档之间的内部冲突。它生成一个结构化的发现结果表，包含以下列：系统 A vs 系统 B、冲突类型、严重性（HIGH / MEDIUM / LOW）。冲突类型包括：公式不匹配、竞争所有权、过时引用和依赖缺口。

该技能在分析过程中是只读的。它没有导演门禁。如果用户请求，可以将可选的一致性报告写入 `design/consistency-report-[date].md`，但技能在写入前会询问 "May I write"。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：CONSISTENT、CONFLICTS FOUND、DEPENDENCY GAP
- [ ] 分析过程不要求包含 "May I write" 相关表述（只读扫描）
- [ ] 在结尾处具有后续步骤交接
- [ ] 记录了报告写入是可选的且需要审批

---

## 导演门禁检查

无导演门禁——此技能不会生成任何导演门禁 Agent。一致性检查是机械性扫描；扫描本身不需要创意总监或技术总监审查。

---

## 测试用例

### 用例 1：正常路径——4 个 GDD 无冲突

**Fixture：**
- `design/gdd/` 恰好包含 4 个系统 GDD
- 所有 GDD 的公式一致（没有具有不同值的重叠变量）
- 没有两个 GDD 对同一游戏实体或机制声明所有权
- 所有依赖引用指向存在的 GDD

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取 `design/gdd/` 中的所有 4 个 GDD
2. 运行跨 GDD 一致性检查（公式、所有权、引用）
3. 未发现冲突
4. 输出结构化发现结果表，显示 0 个问题
5. 判决：CONSISTENT

**断言：**
- [ ] 所有 4 个 GDD 在产生输出之前都已被读取
- [ ] 发现结果表存在（即使为空——显示"未发现冲突"）
- [ ] 无冲突时判决为 CONSISTENT
- [ ] 技能未经用户批准不写入任何文件
- [ ] 存在后续步骤交接

---

### 用例 2：失败路径——两个 GDD 的伤害公式冲突

**Fixture：**
- GDD-A 定义伤害公式：`damage = attack * 1.5`
- GDD-B 对同一实体类型定义伤害公式：`damage = attack * 2.0`
- 两个 GDD 引用相同的 "attack" 变量

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取所有 GDD 并检测到公式不匹配
2. 发现结果表中包含条目：GDD-A vs GDD-B | Formula Mismatch | HIGH
3. 显示具体的冲突公式（而不仅仅是"存在公式冲突"）
4. 判决：CONFLICTS FOUND

**断言：**
- [ ] 判决为 CONFLICTS FOUND（而非 CONSISTENT）
- [ ] 冲突条目标明两个 GDD 的文件名
- [ ] 冲突类型为 "Formula Mismatch"
- [ ] 直接公式矛盾的严重性为 HIGH
- [ ] 两个冲突公式都显示在发现结果表中
- [ ] 技能不会自动解决冲突

---

### 用例 3：部分路径——GDD 引用了一个没有 GDD 的系统

**Fixture：**
- GDD-A 的依赖部分将 "system-B" 列为依赖
- `design/gdd/` 中不存在 system-B 的 GDD
- 所有其他 GDD 是一致的

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取所有 GDD 并检查依赖引用
2. GDD-A 对 "system-B" 的引用无法解析——不存在相应的 GDD
3. 发现结果表包含：GDD-A vs (missing) | Dependency Gap | MEDIUM
4. 判决：DEPENDENCY GAP（非 CONSISTENT，非 CONFLICTS FOUND）

**断言：**
- [ ] 判决为 DEPENDENCY GAP（与 CONSISTENT 和 CONFLICTS FOUND 相区别）
- [ ] 发现条目指明 GDD-A 和缺失的 system-B
- [ ] 未解析的依赖引用的严重性为 MEDIUM
- [ ] 技能建议运行 `/design-system system-B` 来创建缺失的 GDD

---

### 用例 4：边界情况——未找到任何 GDD

**Fixture：**
- `design/gdd/` 目录为空或不存在

**输入：** `/consistency-check`

**预期行为：**
1. 技能尝试读取 `design/gdd/` 中的文件
2. 未找到 GDD 文件
3. 技能输出错误："在 `design/gdd/` 中未找到 GDD。请先运行 `/design-system` 来创建 GDD。"
4. 不生成发现结果表
5. 不发出任何判决

**断言：**
- [ ] 当未找到任何 GDD 时，技能输出清晰的错误消息
- [ ] 不产生判决（CONSISTENT / CONFLICTS FOUND / DEPENDENCY GAP）
- [ ] 技能推荐正确的后续操作（`/design-system`）
- [ ] 技能不会崩溃或生成不完整的报告

---

### 用例 5：导演门禁——不生成门禁；不读取 review-mode.txt

**Fixture：**
- `design/gdd/` 包含 ≥2 个 GDD
- `production/session-state/review-mode.txt` 存在，内容为 `full`

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取所有 GDD 并运行一致性扫描
2. 技能不会读取 `production/session-state/review-mode.txt`
3. 在任何时候都不会生成导演门禁 Agent
4. 发现结果表和判决正常产生

**断言：**
- [ ] 不会生成任何导演门禁 Agent（无 CD-、TD-、PR-、AD- 前缀的门禁）
- [ ] 技能不会读取 `production/session-state/review-mode.txt`
- [ ] 输出不包含 "Gate: [GATE-ID]" 或门禁跳过条目
- [ ] 审查模式对此技能的行为没有影响

---

## 协议合规

- [ ] 在生成发现结果表之前读取所有 GDD
- [ ] 发现结果表在完整呈现后才进行任何写入询问（如果请求了报告）
- [ ] 判决精确为以下之一：CONSISTENT、CONFLICTS FOUND、DEPENDENCY GAP
- [ ] 无导演门禁——不读取 review-mode.txt
- [ ] 报告写入（如果请求）由 "May I write" 审批控制
- [ ] 以适合判决的后续步骤交接结束

---

## 覆盖说明

- 此技能检查 GDD 之间的结构一致性。深层设计理论分析（支柱漂移、主导策略）由 `/review-all-gdds` 处理。
- 公式冲突检测依赖于 GDD 之间一致的公式表示法——同一机制的非正式描述可能无法被检测到。
- 冲突严重性分类标准（HIGH / MEDIUM / LOW）在技能正文中定义，此处不再枚举。
