<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 技能测试规范：/test-evidence-review

## 技能摘要

`/test-evidence-review` 对 `tests/` 中的测试文件执行质量审查，检查测试命名规范、确定性、隔离性以及是否存在硬编码的魔法数字——所有这些都依据 `coding-standards.md` 中定义的项目测试标准。发现结果可能会被标记以供 QA 负责人审查。不会调用任何导演门禁。该技能未经用户批准不会写入。判决词：PASS、WARNINGS 或 FAIL。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：PASS、WARNINGS、FAIL
- [ ] 不要求包含 "May I write" 相关表述（只读；写入是可选的标记报告）
- [ ] 具有后续步骤交接（发现结果审查后的操作指引）

---

## 导演门禁检查

无。测试证据审查是一个建议性质的质量技能；QL-TEST-COVERAGE 门禁是一个独立的技能调用，不会在此处触发。

---

## 测试用例

### 用例 1：正常路径——测试遵循所有标准

**Fixture：**
- `tests/unit/combat/health_system_take_damage_test.gd` 存在，具有：
  - 命名：`test_health_system_take_damage_reduces_health()`（遵循 `test_[system]_[scenario]_[expected]`）
  - 存在 Arrange/Act/Assert 结构
  - 没有 `sleep()`、带时间值的 `await` 或随机种子
  - 没有外部 API 调用或文件 I/O
  - 没有内联魔法数字（使用 `tests/unit/combat/fixtures/` 中的常量）

**输入：** `/test-evidence-review tests/unit/combat/`

**预期行为：**
1. 技能从 `coding-standards.md` 读取测试标准
2. 技能读取测试文件；检查全部 5 项标准
3. 所有检查通过：命名、结构、确定性、隔离性、无硬编码数据
4. 判决为 PASS

**断言：**
- [ ] 5 项测试标准均被检查并报告
- [ ] 符合标准时所有检查显示 PASS
- [ ] 判决为 PASS
- [ ] 不写入任何文件

---

### 用例 2：失败——检测到时间依赖

**Fixture：**
- `tests/unit/ui/hud_update_test.gd` 包含：
  ```gdscript
  await get_tree().create_timer(1.0).timeout
  assert_eq(label.text, "Ready")
  ```
- 使用了 1 秒的实时等待，而非 mock 或基于信号的断言

**输入：** `/test-evidence-review tests/unit/ui/hud_update_test.gd`

**预期行为：**
1. 技能读取测试文件
2. 技能检测到实时等待（`create_timer(1.0)`）——非确定性的时间依赖
3. 技能将其标记为 FAIL 级别的发现
4. 判决为 FAIL
5. 技能建议将定时器替换为基于信号的断言或 mock

**断言：**
- [ ] 实时等待使用被检测为非确定性的时间依赖
- [ ] 发现被分类为 FAIL 严重性（阻塞——违反确定性标准）
- [ ] 判决为 FAIL
- [ ] 修复建议引用了基于信号或 mock 的方法
- [ ] 技能不编辑测试文件

---

### 用例 3：失败——测试直接调用外部 API

**Fixture：**
- `tests/unit/networking/auth_test.gd` 包含：
  ```gdscript
  var result = HTTPRequest.new().request("https://api.example.com/auth")
  ```
- 直接 HTTP 调用外部 API，未使用 mock

**输入：** `/test-evidence-review tests/unit/networking/auth_test.gd`

**预期行为：**
1. 技能读取测试文件
2. 技能检测到直接的外部 API 调用（HTTPRequest 到真实 URL）
3. 技能将其标记为 FAIL 级别的发现——违反隔离性标准
4. 判决为 FAIL
5. 技能建议注入 mock HTTP 客户端

**断言：**
- [ ] 直接外部 API 调用被检测并标记
- [ ] 发现被分类为 FAIL 严重性（违反隔离性标准）
- [ ] 判决为 FAIL
- [ ] 修复建议引用了通过依赖注入使用 mock HTTP 客户端
- [ ] 技能不修改测试文件

---

### 用例 4：边界情况——未找到测试文件

**Fixture：**
- 用户调用 `/test-evidence-review tests/unit/audio/`
- `tests/unit/audio/` 目录不存在

**输入：** `/test-evidence-review tests/unit/audio/`

**预期行为：**
1. 技能尝试读取 `tests/unit/audio/` 中的文件——未找到
2. 技能输出："在 `tests/unit/audio/` 未找到测试文件——运行 `/test-setup` 来搭建测试目录"
3. 不发出任何判决

**断言：**
- [ ] 当路径不存在时，技能不会崩溃
- [ ] 输出在消息中指明尝试的路径
- [ ] 输出建议 `/test-setup` 进行搭建
- [ ] 当没有内容可供审查时，不发出任何判决

---

### 用例 5：门禁合规——无门禁；QL-TEST-COVERAGE 是独立技能

**Fixture：**
- 测试文件有 1 个 WARNINGS 级别的发现（非边界测试中的魔法数字）
- `review-mode.txt` 包含 `full`

**输入：** `/test-evidence-review tests/unit/combat/`

**预期行为：**
1. 技能审查测试；发现 1 个 WARNINGS 级别的发现
2. 不会调用任何导演门禁（QL-TEST-COVERAGE 是单独调用的，不在此处）
3. 判决为 WARNINGS
4. 输出注明："如需完整测试覆盖门禁，请运行 `/gate-check`，它会调用 QL-TEST-COVERAGE"
5. 技能提供可选报告写入；如果用户选择，则询问 "May I write"

**断言：**
- [ ] 在任何审查模式下均不会调用导演门禁
- [ ] 输出将此技能与 QL-TEST-COVERAGE 门禁调用区分开来
- [ ] 可选报告在写入前需要 "May I write"
- [ ] 建议性级别的测试质量问题的判决为 WARNINGS

---

## 协议合规

- [ ] 在审查测试文件前读取 `coding-standards.md` 的测试标准
- [ ] 检查命名、Arrange/Act/Assert 结构、确定性、隔离性、无硬编码数据
- [ ] 不编辑任何测试文件（只读技能）
- [ ] 不调用任何导演门禁
- [ ] 判决为以下之一：PASS、WARNINGS、FAIL

---

## 覆盖说明

- 批量审查 `tests/` 中所有测试文件的情况未显式测试；行为假定为逐文件应用相同检查并聚合判决。
- QL-TEST-COVERAGE 导演门禁（检查测试覆盖率百分比）是一个独立的关注点，有意不由此技能调用。
