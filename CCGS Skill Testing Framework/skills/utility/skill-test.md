<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/skill-test

## Skill 摘要

`/skill-test` 是测试自身体系结构的技能测试工具。它根据 skill 的测试计划中定义的期望，在两个层面验证技能的行为：`static` 模式检查 skill 源代码（frontmatter 字段、文件存在性、结构合规性），`dynamic` 模式根据 fixture 和测试断言运行行为级验证。

该 skill 经过 "May I write" 询问后，将报告写入 `.claude/skills/test-reports/[skill-name]-[mode]-[date].md`。对于每个 skill，会从代理缓存和技能列表中创建基于代理的 skill 加载 fixture，以及用于动态测试的文件系统 mock fixture。根据发现，判决为 PASS、FAIL 或 PASS WITH WARNINGS。不适用 director gate。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：PASS、PASS WITH WARNINGS、FAIL
- [ ] 在写入报告前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，`/skill-improve` 修复问题）

---

## Director Gate 检查

无。`/skill-test` 是一个测试基础设施技能。技能测试不触发 director gate，因为 director gate 是被测试的技能的一部分。

---

## 测试用例

### 用例 1：Static 模式 — 有效的 skill 文件，PASS

**Fixture：**
- `.claude/skills/utility/bug-report.md` 存在，包含正确的 frontmatter、≥2 个阶段标题、包含判决关键词

**输入：** `/skill-test bug-report static`

**预期行为：**
1. Skill 读取 `.claude/skills/utility/bug-report.md`
2. Skill 提取 frontmatter 字段并验证：
   - 所有必需字段存在
   - 文件存在于文件系统中
   - 阶段标题数量 ≥ 2
3. Skill 生成测试报告："bug-report static: PASS — all static requirements met"
4. Skill 询问 "May I write to `.claude/skills/test-reports/bug-report-static-2026-04-06.md`?"
5. 批准后写入报告；判决为 PASS

**断言：**
- [ ] Frontmatter 中存在所有必需字段
- [ ] 报告中注明阶段标题数量
- [ ] "May I write" 以正确的报告文件路径询问
- [ ] 判决为 PASS

---

### 用例 2：Static 模式 — 缺失 frontmatter 字段，FAIL

**Fixture：**
- `.claude/skills/utility/example-skill.md` 缺少 `allowed-tools` frontmatter 字段

**输入：** `/skill-test example-skill static`

**预期行为：**
1. Skill 读取 skill 文件
2. Skill 解析 frontmatter — 缺失 `allowed-tools`
3. Skill 报告为 FAIL，附缺失字段详情："Missing required frontmatter field: allowed-tools"
4. Skill 询问 "May I write?"，写入 FAIL 报告
5. 判决为 FAIL

**断言：**
- [ ] FAIL 消息命名缺失的字段
- [ ] 报告写入时带有 FAIL 判决
- [ ] Skill 不因缺失字段而异常 — 优雅处理

---

### 用例 3：Dynamic 模式 — 所有测试用例通过，PASS

**Fixture：**
- `.claude/skills/utility/bug-report.md` 测试计划存在
- 代理缓存 fixture 存在（从缓存或技能列表加载）
- 为 bug-report 创建文件系统 mock fixture
- Test Case 1（Happy Path）、TestCase 2、3、4 均同时执行

**输入：** `/skill-test bug-report dynamic`

**预期行为：**
1. 为 bug-report 创建代理缓存 fixture（所有依赖文件存在）
2. 创建文件系统 fixture（空 `production/bugs/`）
3. 测试用例 1 执行：模拟用户输入，验证 bug 报告创建（8 个通过断言，0 个失败）
4. 测试用例 2 执行：模拟最小输入，验证知识差距提问（4 个通过，0 个失败）
5. 测试用例 3 执行：模拟相似 bug 的重复检测（3 个通过，0 个失败）
6. 测试用例 4 执行：模拟多系统输入（2 个通过，0 个失败）
7. 测试用例 5 执行：验证无 director gate 调用（2 个通过，0 个失败）
8. Skill 生成汇总报告：19/19 断言通过
9. Skill 询问 "May I write to `.claude/skills/test-reports/bug-report-dynamic-2026-04-06.md`?"
10. 批准后写入报告；判决为 PASS

**断言：**
- [ ] 报告中包含所有 5 个测试用例
- [ ] 每个用例显示通过/失败断言计数
- [ ] 汇总通过/失败/总计在报告顶部
- [ ] 判决为 PASS（所有断言通过）
- [ ] 创建任何测试文件前询问 "May I write"

---

### 用例 4：Dynamic 模式 — 混合结果，PASS WITH WARNINGS

**Fixture：**
- Skill 测试计划有 5 个测试用例，共 24 个断言
- 大部分测试通过，但用例 2 有 1 个断言失败（非关键）

**输入：** `/skill-test example-skill dynamic`

**预期行为：**
1. 所有测试用例执行
2. 结果：23 个断言通过，1 个失败（来自用例 2）
3. 失败被标记：失败的具体断言和实际行为
4. 判决为 PASS WITH WARNINGS
5. 总结附建议："Run `/skill-improve example-skill` to address the warning"

**断言：**
- [ ] 判决为 PASS WITH WARNINGS（非 FAIL）
- [ ] 失败断言在摘要中被注明
- [ ] 建议 `/skill-improve` 作为后续
- [ ] 所有测试结果（通过和失败）均显示在报告中

---

### 用例 5：Director Gate 检查 — 无 gate；skill-test 是测试基础设施

**Fixture：**
- 任何有效的 skill 用于测试

**输入：** `/skill-test my-skill static`

**预期行为：**
1. Skill 运行测试并生成报告
2. 在任何时候都不生成 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 PASS、PASS WITH WARNINGS 或 FAIL — 不涉及 gate 判决

---

## 协议合规性

- [ ] 在 `static` 模式下检查 frontmatter、文件存在性和结构合规性
- [ ] 在 `dynamic` 模式下执行基于 fixture 的行为测试
- [ ] 在创建测试报告之前询问 "May I write"
- [ ] 报告写入 `.claude/skills/test-reports/` 目录
- [ ] 判决为 PASS、PASS WITH WARNINGS 或 FAIL
- [ ] 为任何 FAIL 或 WARNINGS 建议 `/skill-improve`

---

## 覆盖说明

- /skill-test dynamic 的代理缓存和文件系统 mock 在设置阶段创建，不在此处重新断言。
- 参数验证（不传递模式时：`/skill-test my-skill` 默认为 `static`）由 skill 正文处理。
- 此 skill 运行其自身的测试并不特殊处理——它遵循与其他工具技能相同的测试模式。
