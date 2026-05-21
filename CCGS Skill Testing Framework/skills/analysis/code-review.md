<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 技能测试规范：/code-review

## 技能摘要

`/code-review` 对 `src/` 中的源文件执行架构代码审查，检查 `CLAUDE.md` 中的编码标准（公共 API 的文档注释、依赖注入优于单例、数据驱动值、可测试性）。发现结果为建议性。不会调用任何导演门禁。不进行任何代码编辑。判决词：APPROVED、CONCERNS 或 NEEDS CHANGES。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：APPROVED、CONCERNS、NEEDS CHANGES
- [ ] 不要求包含 "May I write" 相关表述（只读；发现结果为建议性输出）
- [ ] 具有后续步骤交接（发现结果的处理指引）

---

## 导演门禁检查

无。代码审查是只读建议技能；不会调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——源文件遵循所有编码标准

**Fixture：**
- `src/gameplay/health_component.gd` 存在，具有：
  - 所有公共方法都有文档注释（`##` 标记法）
  - 未使用单例；依赖通过构造函数注入
  - 无硬编码值；所有常量引用 `assets/data/`
  - 文件头部有 ADR 引用：`# ADR: docs/architecture/adr-004-health.md`
  - 引用的 ADR 状态为 `Status: Accepted`

**输入：** `/code-review src/gameplay/health_component.gd`

**预期行为：**
1. 技能读取源文件
2. 技能检查所有编码标准：文档注释、依赖注入、数据驱动、ADR 状态
3. 所有检查通过
4. 技能输出发现结果摘要，所有检查显示 PASS
5. 判决为 APPROVED

**断言：**
- [ ] 每项编码标准检查都在输出中列出
- [ ] 符合标准时所有检查显示 PASS
- [ ] 技能读取引用的 ADR 以确认其状态
- [ ] 判决为 APPROVED
- [ ] 不对任何文件进行编辑

---

### 用例 2：需要修改——缺少文档注释和使用单例

**Fixture：**
- `src/ui/inventory_ui.gd` 具有：
  - 2 个公共方法缺少文档注释
  - 使用 `GameManager.instance`（单例模式）
  - 所有其他标准已满足

**输入：** `/code-review src/ui/inventory_ui.gd`

**预期行为：**
1. 技能读取源文件
2. 技能检测到：2 个缺少文档注释的公共方法
3. 技能检测到：在特定行使用单例（例如，第 42 行、第 87 行）
4. 发现结果列出确切的方法名称和行号
5. 判决为 NEEDS CHANGES

**断言：**
- [ ] 缺少的文档注释与对应方法名称一同列出
- [ ] 单例使用被标记，并指明文件和行号
- [ ] 当存在 BLOCKING 级别标准违规时，判决为 NEEDS CHANGES
- [ ] 技能不编辑文件——发现结果供开发者处理
- [ ] 输出建议将单例替换为依赖注入

---

### 用例 3：架构风险——ADR 引用为 Proposed 而非 Accepted

**Fixture：**
- `src/core/save_system.gd` 有头部注释：`# ADR: docs/architecture/adr-010-save.md`
- `adr-010-save.md` 存在但状态为 `Status: Proposed`
- 代码本身遵循所有其他编码标准

**输入：** `/code-review src/core/save_system.gd`

**预期行为：**
1. 技能读取源文件
2. 技能读取引用的 ADR——发现 `Status: Proposed`
3. 技能将其标记为 ARCHITECTURE RISK（代码实现了一个未被接受的 ADR）
4. 其他编码标准检查通过
5. 判决为 CONCERNS（风险标记是建议性的，而非硬性的 NEEDS CHANGES）

**断言：**
- [ ] 技能读取引用的 ADR 文件以检查其状态
- [ ] 当 ADR 状态为 Proposed 时，标记 ARCHITECTURE RISK
- [ ] ADR 风险的判决为 CONCERNS（而非 NEEDS CHANGES）——建议性严重级别
- [ ] 输出建议在代码上线前解决该 ADR

---

### 用例 4：边界情况——在指定路径未找到源文件

**Fixture：**
- 用户调用 `/code-review src/networking/`
- `src/networking/` 目录不存在

**输入：** `/code-review src/networking/`

**预期行为：**
1. 技能尝试读取 `src/networking/` 中的文件
2. 目录或文件未找到
3. 技能输出错误："在 `src/networking/` 未找到源文件"
4. 技能建议检查 `src/` 中的有效目录
5. 不发出任何判决（没有审查任何内容）

**断言：**
- [ ] 当路径不存在时，技能不会崩溃
- [ ] 输出在错误消息中指明尝试的路径
- [ ] 输出建议检查 `src/` 中的有效文件路径
- [ ] 当没有内容可供审查时，不发出任何判决

---

### 用例 5：门禁合规——无门禁；主程（LP）可单独咨询

**Fixture：**
- 源文件遵循大多数标准，但有 1 个 CONCERNS 级别的发现（一个魔法数字）
- `review-mode.txt` 包含 `full`

**输入：** `/code-review src/gameplay/loot_system.gd`

**预期行为：**
1. 技能读取并审查源文件
2. 不会调用任何导演门禁（代码审查发现结果是建议性的）
3. 技能呈现发现结果，判决为 CONCERNS
4. 输出注明："考虑请求主程（Lead Programmer）审查架构问题"
5. 技能不会自动调用任何 Agent

**断言：**
- [ ] 在任何审查模式下均不会调用导演门禁
- [ ] LP 咨询在输出中是建议性的（非强制）
- [ ] 不进行任何代码编辑
- [ ] 建议性级别的发现结果判决为 CONCERNS

---

## 协议合规

- [ ] 在审查前读取源文件和编码标准
- [ ] 在发现结果输出中列出每项编码标准检查
- [ ] 不编辑任何源文件（只读技能）
- [ ] 不调用任何导演门禁
- [ ] 判决为以下之一：APPROVED、CONCERNS、NEEDS CHANGES

---

## 覆盖说明

- 批量审查目录中所有文件的情况未在此显式测试；行为假定为逐文件应用相同的检查并聚合判决。
- 测试覆盖检查（验证对应的测试文件是否存在）是一个未在此测试的延伸目标；这主要是 `/test-evidence-review` 的领域。
