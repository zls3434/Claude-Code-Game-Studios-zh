<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 技能测试规范：/test-flakiness

## 技能摘要

`/test-flakiness` 通过分析测试历史日志（如果有）或扫描测试源代码中的常见不稳定模式（无种子的随机数、实时等待、外部 I/O）来检测非确定性测试。不会调用任何导演门禁。该技能未经用户批准不会写入。判决词：NO FLAKINESS、SUSPECT TESTS FOUND 或 CONFIRMED FLAKY。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：NO FLAKINESS、SUSPECT TESTS FOUND、CONFIRMED FLAKY
- [ ] 不要求包含 "May I write" 相关表述（只读；可选报告需要审批）
- [ ] 具有后续步骤交接（不稳定发现结果后的操作指引）

---

## 导演门禁检查

无。不稳定检测是一个面向 QA 负责人的建议性质的质量技能；不会调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——干净的测试历史，无不稳定性

**Fixture：**
- `production/qa/test-history/` 包含 10 次测试运行的日志
- 所有测试在所有 10 次运行中均一致通过（每个测试的通过率为 100%）
- 没有任何测试有失败模式

**输入：** `/test-flakiness`

**预期行为：**
1. 技能从 `production/qa/test-history/` 读取测试历史日志
2. 技能计算每个测试在 10 次运行中的通过率
3. 所有测试在 10 次运行中全部通过——未检测到不一致性
4. 判决为 NO FLAKINESS

**断言：**
- [ ] 技能在有测试历史日志时读取它们
- [ ] 每个测试的通过率在所有可用运行中计算
- [ ] 当所有测试一致通过时，判决为 NO FLAKINESS
- [ ] 不写入任何文件

---

### 用例 2：发现可疑测试——测试在历史中间歇性失败

**Fixture：**
- `production/qa/test-history/` 包含 10 次测试运行的日志
- `test_combat_damage_applies_crit_multiplier` 通过 7 次，失败 3 次
- 失败消息不同（有时超时，有时值错误）

**输入：** `/test-flakiness`

**预期行为：**
1. 技能读取测试历史日志——计算通过率
2. `test_combat_damage_applies_crit_multiplier` 的通过率为 70%（阈值：95%）
3. 技能将其标记为 SUSPECT，标注通过率（7/10）和已记录的失败模式
4. 判决为 SUSPECT TESTS FOUND
5. 技能建议调查测试中的时间或状态依赖

**断言：**
- [ ] 低于通过率阈值的测试被按名称标记
- [ ] 每个可疑测试显示通过率（分数和百分比）
- [ ] 如果可检测，失败模式（例如不一致的错误消息）被记录
- [ ] 判决为 SUSPECT TESTS FOUND
- [ ] 技能建议调查步骤

---

### 用例 3：源代码模式——使用无种子的随机数

**Fixture：**
- 不存在测试历史日志
- `tests/unit/loot/loot_drop_test.gd` 包含：
  ```gdscript
  var roll = randf()  # 未设种子的随机数——非确定性
  assert_gt(roll, 0.5, "Loot should drop above 50%")
  ```

**输入：** `/test-flakiness`

**预期行为：**
1. 技能未找到测试历史日志
2. 技能回退到源代码分析
3. 技能检测到 `randf()` 调用前没有 `seed()` 调用
4. 技能将测试标记为 FLAKINESS RISK（源代码模式，未确认）
5. 判决为 SUSPECT TESTS FOUND（检测到模式，未通过历史确认）
6. 技能建议在随机调用前设种子，或 mock 随机函数

**断言：**
- [ ] 当没有历史日志时，使用源代码分析作为回退
- [ ] 未设种子的随机数使用被检测为不稳定风险
- [ ] 判决为 SUSPECT TESTS FOUND（非 CONFIRMED FLAKY——无历史记录确认）
- [ ] 修复建议推荐设种子或 mock

---

### 用例 4：无测试历史——仅源代码分析，使用常见模式

**Fixture：**
- `production/qa/test-history/` 不存在
- `tests/` 包含 15 个测试文件
- 扫描发现 2 个测试使用 `OS.get_ticks_msec()` 进行时间断言
- 未发现其他不稳定模式

**输入：** `/test-flakiness`

**预期行为：**
1. 技能检查测试历史——未找到
2. 技能注明："无可用的测试历史——仅分析源代码中的不稳定模式"
3. 技能扫描所有测试文件中的已知模式：未设种子的随机数、实时等待、系统时钟使用
4. 发现 2 个测试使用 `OS.get_ticks_msec()`——标记为 FLAKINESS RISK
5. 判决为 SUSPECT TESTS FOUND

**断言：**
- [ ] 技能明确注明正在执行仅源代码分析（无历史记录）
- [ ] 扫描常见不稳定模式：随机数、基于时间的断言、外部 I/O
- [ ] 用于断言的 `OS.get_ticks_msec()` 使用被标记为不稳定风险
- [ ] 当发现源代码模式时，判决为 SUSPECT TESTS FOUND

---

### 用例 5：门禁合规——无门禁；不稳定报告是建议性的

**Fixture：**
- 测试历史显示 1 个 CONFIRMED FLAKY 测试（10 次运行中失败 6 次）
- `review-mode.txt` 包含 `full`

**输入：** `/test-flakiness`

**预期行为：**
1. 技能分析测试历史；识别出 1 个已确认的不稳定测试
2. 无论审查模式如何，均不会调用导演门禁
3. 判决为 CONFIRMED FLAKY
4. 技能呈现发现结果并提供可选书面报告
5. 如果用户选择："我可以写入 `production/qa/flakiness-report-[date].md` 吗？"

**断言：**
- [ ] 在任何审查模式下均不会调用导演门禁
- [ ] CONFIRMED FLAKY 判决需要基于历史的证据（而非仅源代码模式）
- [ ] 可选报告在写入前需要 "May I write"
- [ ] 不稳定报告对 qa-lead 是建议性的；技能不会自动禁用测试

---

## 协议合规

- [ ] 有测试历史日志时读取；没有时回退到源代码分析
- [ ] 清楚注明正在使用哪种分析模式（历史 vs. 仅源代码）
- [ ] 不稳定阈值（例如，95% 通过率）用于 SUSPECT 分类
- [ ] CONFIRMED FLAKY 需要历史证据；SUSPECT 仅覆盖源代码模式
- [ ] 不禁用或修改任何测试文件
- [ ] 不调用任何导演门禁
- [ ] 判决为以下之一：NO FLAKINESS、SUSPECT TESTS FOUND、CONFIRMED FLAKY

---

## 覆盖说明

- SUSPECT 分类的通过率阈值（上文建议 95%）是实现细节；测试验证的是间歇性失败被标记，而非精确的阈值数值。
- 因环境问题（缺少资产、错误平台）而失败的测试不属于不稳定——技能区分环境失败与测试本身的非确定性；此区分未在此显式测试。
