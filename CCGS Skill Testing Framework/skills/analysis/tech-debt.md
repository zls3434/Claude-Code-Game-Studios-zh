<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 技能测试规范：/tech-debt

## 技能摘要

`/tech-debt` 跟踪、分类和排序代码库中的技术债务。它读取 `docs/tech-debt-register.md` 中的现有债务登记表，并扫描 `src/` 源文件中的内联 `TODO` 和 `FIXME` 注释。它合并并按严重性排序。不会调用任何导演门禁。该技能在更新前会询问 "May I write to `docs/tech-debt-register.md`？"。判决词：REGISTER UPDATED 或 NO NEW DEBT FOUND。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：REGISTER UPDATED、NO NEW DEBT FOUND
- [ ] 包含 "May I write" 相关表述（技能会写入债务登记表）
- [ ] 具有后续步骤交接（登记表更新后的操作指引）

---

## 导演门禁检查

无。技术债务跟踪是内部代码库分析技能；不会调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——内联 TODO 加上现有登记项合并

**Fixture：**
- `docs/tech-debt-register.md` 存在，包含 2 个条目（LOW 和 MEDIUM 严重性）
- `src/gameplay/combat.gd` 有 2 个 `# TODO` 注释和 1 个 `# FIXME` 注释
- `src/ui/hud.gd` 没有内联债务注释

**输入：** `/tech-debt`

**预期行为：**
1. 技能读取 `docs/tech-debt-register.md`——找到 2 个现有条目
2. 技能扫描 `src/`——找到 3 个内联注释（2 个 TODO，1 个 FIXME）
3. 技能检查内联注释是否已存在于登记表中（去重）
4. 技能呈现按严重性排序的合并列表（FIXME 默认排在 TODO 之前）
5. 技能询问 "我可以写入 `docs/tech-debt-register.md` 吗？"
6. 用户批准；登记表更新；判决为 REGISTER UPDATED

**断言：**
- [ ] 通过递归扫描 `src/` 找到内联注释
- [ ] 现有登记项不被重复添加
- [ ] 合并列表按严重性排序
- [ ] "May I write" 提示在任何写入之前出现
- [ ] 判决为 REGISTER UPDATED

---

### 用例 2：登记表不存在——提供创建选项

**Fixture：**
- `docs/tech-debt-register.md` 不存在
- `src/` 包含 4 个内联 TODO/FIXME 注释

**输入：** `/tech-debt`

**预期行为：**
1. 技能尝试读取 `docs/tech-debt-register.md`——未找到
2. 技能通知用户："未找到 tech-debt-register.md"
3. 技能提供用其找到的内联项创建登记表的选项
4. 技能询问 "我可以写入 `docs/tech-debt-register.md` 吗？"（创建）
5. 用户批准；创建包含 4 个条目的登记表；判决为 REGISTER UPDATED

**断言：**
- [ ] 当登记文件不存在时，技能不会崩溃
- [ ] 用户被提供创建登记表的选项（而非悄悄跳过）
- [ ] "May I write" 提示反映的是文件创建（而非更新）
- [ ] 创建后判决为 REGISTER UPDATED

---

### 用例 3：检测到已解决项——在登记表中标记为已解决

**Fixture：**
- `docs/tech-debt-register.md` 有 3 个条目；一个引用了 `src/gameplay/legacy_input.gd`
- `src/gameplay/legacy_input.gd` 已被删除（重构移除）
- 在源代码中，引用的 TODO 注释已不再存在

**输入：** `/tech-debt`

**预期行为：**
1. 技能读取登记表——找到 3 个条目
2. 技能扫描 `src/`——未找到条目 2 引用的源代码位置
3. 技能将条目 2 标记为 RESOLVED（源代码已不存在）
4. 技能将已解决的条目呈现给用户确认
5. 批准后，登记表更新，条目 2 标记为 `Status: Resolved`

**断言：**
- [ ] 技能检查每个登记项的源代码引用是否仍然存在
- [ ] 缺少源代码位置导致条目被标记为 RESOLVED
- [ ] 写入已解决条目之前，用户进行确认
- [ ] RESOLVED 条目保留在登记表中（而非删除）以保留审计历史

---

### 用例 4：边界情况——CRITICAL 债务项突出显示

**Fixture：**
- `src/core/network_sync.gd` 有注释：`# FIXME(CRITICAL): race condition in sync buffer — can corrupt save data`
- `docs/tech-debt-register.md` 存在，包含 5 个较低严重性的条目

**输入：** `/tech-debt`

**预期行为：**
1. 技能扫描源代码并找到 CRITICAL 标记的 FIXME
2. 技能在输出顶部呈现 CRITICAL 项——在完整表格之前
3. 技能要求用户在进行下一步之前确认该关键项
4. 确认后，技能呈现完整的债务表并询问是否写入
5. 登记表更新，CRITICAL 项位于顶部；判决为 REGISTER UPDATED

**断言：**
- [ ] CRITICAL 项出现在输出顶部，而非淹没在表格中
- [ ] 技能在询问写入之前将 CRITICAL 项突出显示
- [ ] 要求用户确认 CRITICAL 项
- [ ] CRITICAL 严重性在写入的登记条目中被保留

---

### 用例 5：门禁合规——无门禁；登记表仅在批准后更新

**Fixture：**
- 内联扫描找到 2 个新的 TODO；登记表有 3 个现有条目
- `review-mode.txt` 包含 `full`

**输入：** `/tech-debt`

**预期行为：**
1. 技能扫描源代码并读取登记表；编译合并的债务列表
2. 无论审查模式如何，均不会调用导演门禁
3. 技能向用户呈现排序后的债务表
4. 技能询问 "我可以写入 `docs/tech-debt-register.md` 吗？"
5. 用户批准；登记表更新；判决为 REGISTER UPDATED

**断言：**
- [ ] 在任何审查模式下均不会调用导演门禁
- [ ] 债务表在任何写入提示之前呈现
- [ ] "May I write" 提示在文件更新前出现
- [ ] 仅在用户明确批准后才进行写入

---

## 协议合规

- [ ] 在编译前读取 `docs/tech-debt-register.md` 并扫描 `src/`
- [ ] 将内联注释与现有登记项进行去重
- [ ] 按严重性排序合并列表
- [ ] 在更新登记表之前始终询问 "May I write"
- [ ] 不调用任何导演门禁
- [ ] 判决为 REGISTER UPDATED 或 NO NEW DEBT FOUND

---

## 覆盖说明

- `src/` 为空或不存在的情况未测试；对内联扫描而言，行为遵循 NO NEW DEBT FOUND 路径，但登记项仍会被读取和呈现。
- 没有严重性标签的 TODO 注释默认被视为 LOW 严重性；此分类细节是实现层面的关注点，未在此测试。
