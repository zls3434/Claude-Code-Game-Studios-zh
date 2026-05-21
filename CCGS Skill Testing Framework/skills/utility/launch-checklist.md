<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/launch-checklist

## Skill 摘要

`/launch-checklist` 生成并评估完整的发布就绪检查清单，涵盖：法律合规（EULA、隐私政策、ESRB/PEGI 评级）、平台认证状态、商店页面完整性（截图、描述、元数据）、构建验证（版本标签、可复现构建）、分析和崩溃报告配置，以及首次运行体验验证。

该 skill 在经过 "May I write" 询问后生成写入 `production/launch/launch-checklist-[date].md` 的检查清单报告。如果之前的发布检查清单存在，它会将新结果与旧结果对比，突出显示新解决的项和新阻塞的项。不适用 director gate — `/team-release` 编排完整的发布流水线。判决：LAUNCH READY、LAUNCH BLOCKED 或 CONCERNS。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：LAUNCH READY、LAUNCH BLOCKED、CONCERNS
- [ ] 在写入检查清单前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，`/team-release` 或 `/day-one-patch`）

---

## Director Gate 检查

无。`/launch-checklist` 是一个就绪审核工具。完整发布流水线由 `/team-release` 管理。

---

## 测试用例

### 用例 1：Happy Path — 所有检查清单项已验证，LAUNCH READY

**Fixture：**
- 法律文档存在：EULA、隐私政策在 `production/legal/` 中
- 平台认证：在 production notes 中标记为已提交并批准
- 商店页面资产：截图、描述、元数据均存在于 `production/store/` 中
- 构建：版本标签 `v1.0.0` 存在，可复现构建已确认
- 崩溃报告：已在 `technical-preferences.md` 中配置

**输入：** `/launch-checklist`

**预期行为：**
1. Skill 检查所有检查清单类别
2. 所有项通过验证检查
3. Skill 生成检查清单报告，所有项标记为 PASS
4. Skill 询问 "May I write to `production/launch/launch-checklist-2026-04-06.md`?"
5. 批准后写入报告；判决为 LAUNCH READY

**断言：**
- [ ] 所有检查清单类别均被检查（legal、platform、store、build、analytics、UX）
- [ ] 所有项以 PASS 标记出现在报告中
- [ ] 判决为 LAUNCH READY
- [ ] "May I write" 以正确的日期文件名询问

---

### 用例 2：平台认证未提交 — LAUNCH BLOCKED

**Fixture：**
- 所有其他检查清单项均通过
- 平台认证 section："not submitted"（未找到提交记录）

**输入：** `/launch-checklist`

**预期行为：**
1. Skill 检查所有项
2. 平台认证检查失败：无提交记录
3. Skill 报告："LAUNCH BLOCKED — Platform certification not submitted"
4. 指明缺少认证的具体平台
5. 判决为 LAUNCH BLOCKED

**断言：**
- [ ] 判决为 LAUNCH BLOCKED（非 CONCERNS）
- [ ] 平台认证被识别为阻塞项
- [ ] 指明缺失的平台名称
- [ ] 报告中仍显示其他通过项

---

### 用例 3：需要手动检查 — CONCERNS 判决

**Fixture：**
- 所有关键检查清单项均通过
- 首次运行体验项："MANUAL CHECK NEEDED — human must play the first 5 minutes and verify tutorial completion flow"
- 商店截图项："MANUAL CHECK NEEDED — art team must verify screenshot quality matches current build"

**输入：** `/launch-checklist`

**预期行为：**
1. Skill 检查所有项
2. 2 项被标记为需要人工验证
3. Skill 报告："CONCERNS — 2 items require manual verification before launch"
4. 两项均列出需手动验证内容的说明
5. 判决为 CONCERNS（非 LAUNCH BLOCKED，因为这些是建议性的）

**断言：**
- [ ] 判决为 CONCERNS（非 LAUNCH READY 或 LAUNCH BLOCKED）
- [ ] 两个手动检查项均列出验证说明
- [ ] Skill 不因 MANUAL CHECK 项自动阻塞

---

### 用例 4：之前的检查清单存在 — 差异比较

**Fixture：**
- `production/launch/launch-checklist-2026-03-25.md` 存在，包含先前结果：
  - 2 项为 BLOCKED（platform cert、crash reporting）
  - 1 项有 MANUAL CHECK
- 新检查清单：platform cert 现为 PASS，crash reporting 现为 PASS，manual check 仍开放；1 个新项被标记（EULA 最后更新日期）

**输入：** `/launch-checklist`

**预期行为：**
1. Skill 找到先前的检查清单并加载以进行比较
2. Skill 生成新检查清单并比较：
   - 新解决："Platform cert — was BLOCKED, now PASS"
   - 新解决："Crash reporting — was BLOCKED, now PASS"
   - 仍开放：manual check（未变）
   - 新问题：EULA 最后更新日期（之前检查清单中无）
3. 差异在报告中显著显示
4. 判决为 CONCERNS（manual check + 新 EULA 问题）

**断言：**
- [ ] 差异 section 显示新解决的项
- [ ] 差异 section 显示新问题（之前检查清单中不存在）
- [ ] 之前检查清单中仍开放的项被标注为持续存在
- [ ] 判决反映当前状态（而非先前状态）

---

### 用例 5：Director Gate 检查 — 无 gate；launch-checklist 是一个审核工具

**Fixture：**
- 所有检查清单依赖项存在

**输入：** `/launch-checklist`

**预期行为：**
1. Skill 运行完整检查清单并写入报告
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 LAUNCH READY、LAUNCH BLOCKED 或 CONCERNS — 无 gate 判决

---

## 协议合规性

- [ ] 检查所有必需的类别（legal、platform、store、build、analytics、UX）
- [ ] 硬失败为 LAUNCH BLOCKED（未完成的认证、缺失的法律文档）
- [ ] 需要手动验证的建议项为 CONCERNS
- [ ] 存在先前检查清单时进行比较
- [ ] 创建检查清单报告前询问 "May I write"
- [ ] 判决为 LAUNCH READY、LAUNCH BLOCKED 或 CONCERNS

---

## 覆盖说明

- 区域特定合规（GDPR 数据处理、面向 13 岁以下受众的 COPPA）会被检查，但具体要求不在测试断言中枚举。
- 商店页面完整性检查（截图、描述）依赖于 `production/store/` 中存在文件；无法验证视觉质量。
- 构建可复现性检查验证版本标签和构建配置的存在，但不执行构建过程。
