<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/onboard

## Skill 摘要

`/onboard` 为新团队成员生成定制化的项目入职摘要。它读取 CLAUDE.md、`technical-preferences.md`、活动冲刺文件、最近的 git 提交和 `production/stage.txt`，生成结构化的入职文档。该 skill 在 Haiku 模型上运行（只读、格式化任务），不产生文件写入——所有输出为对话形式。

该 skill 可选接受角色参数（例如 `/onboard artist`）以针对特定职责定制摘要。当项目处于早期阶段或未配置时，输出会相应调整以反映已知的少量信息。判决始终为 ONBOARDING COMPLETE——该 skill 是纯信息性的。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：ONBOARDING COMPLETE
- [ ] 不包含 "May I write" 语言（skill 是只读的）
- [ ] 有下一步交接，建议相关的后续 skill

---

## Director Gate 检查

无。`/onboard` 是一个只读入职 skill。不适用 director gate。

---

## 测试用例

### 用例 1：Happy Path — 已配置项目，Production 阶段，有活动冲刺

**Fixture：**
- `production/stage.txt` 包含 `Production`
- `technical-preferences.md` 已填充引擎、语言和专家
- `production/sprints/sprint-005.md` 存在，有进行中的故事
- Git log 包含 5 个最近提交

**输入：** `/onboard`

**预期行为：**
1. Skill 读取 stage.txt、technical-preferences.md、活动冲刺和 git log
2. Skill 生成入职摘要，包含 section：Project Overview、Tech Stack、Current Stage、Active Sprint Summary、Recent Activity
3. 摘要格式便于阅读（标题、项目符号）
4. 下一步建议适用于 Production 阶段（例如 `/sprint-status`、`/dev-story`）
5. 陈述判决 ONBOARDING COMPLETE

**断言：**
- [ ] 输出包含 stage.txt 中的当前阶段名称
- [ ] 输出包含 technical-preferences.md 中的引擎和语言
- [ ] 活动冲刺故事被摘要（不仅仅是冲刺文件名）
- [ ] 存在最近提交上下文
- [ ] 判决为 ONBOARDING COMPLETE
- [ ] 没有文件被写入

---

### 用例 2：新项目 — 无引擎、无冲刺，建议 /start

**Fixture：**
- `technical-preferences.md` 仅包含占位符（`[TO BE CONFIGURED]`）
- 无 `production/stage.txt`
- 无冲刺文件
- 无超出默认的 CLAUDE.md 覆盖

**输入：** `/onboard`

**预期行为：**
1. Skill 读取所有配置文件并检测到未配置状态
2. Skill 生成最小摘要："This project has not been configured yet"
3. 输出解释入职工作流：`/start` → `/setup-engine` → `/brainstorm`
4. Skill 建议运行 `/start` 作为立即下一步
5. 判决为 ONBOARDING COMPLETE（信息性的，非失败）

**断言：**
- [ ] 输出明确提及项目尚未配置
- [ ] 建议 `/start` 作为下一步
- [ ] Skill 不出错 — 优雅处理空项目状态
- [ ] 判决仍为 ONBOARDING COMPLETE

---

### 用例 3：缺少 CLAUDE.md — 错误附补救措施

**Fixture：**
- `CLAUDE.md` 文件不存在（已删除或从未创建）
- 其他文件可能存在也可能不存在

**输入：** `/onboard`

**预期行为：**
1. Skill 尝试读取 CLAUDE.md 但失败
2. Skill 输出错误："CLAUDE.md not found — cannot generate onboarding summary"
3. Skill 提供补救措施："Run `/start` to initialize the project configuration"
4. 不生成部分摘要

**断言：**
- [ ] 错误消息清楚标识缺失文件为 CLAUDE.md
- [ ] 补救步骤（`/start`）被明确命名
- [ ] Skill 在缺少根配置时不产生部分输出
- [ ] 判决为 ONBOARDING COMPLETE（附错误上下文，非崩溃）

---

### 用例 4：角色特定入职 — 用户指定 "artist" 角色

**Fixture：**
- 完全配置的项目，Production 阶段
- `design/` 中存在 `art-bible.md`
- 活动冲刺有视觉类型故事（animation、VFX）

**输入：** `/onboard artist`

**预期行为：**
1. Skill 读取所有标准文件以及任何美术相关文档（art bible、asset specs）
2. 摘要针对美术师角色定制：art bible 概述、资产管线、活动冲刺中当前视觉故事
3. 技术架构细节（代码结构、ADR）被淡化
4. 摘要中强调美术/音频的专家 agent
5. 判决为 ONBOARDING COMPLETE

**断言：**
- [ ] 角色参数在输出中确认（"Onboarding for: Artist"）
- [ ] 如果文件存在，包含 art bible 摘要
- [ ] 显示活动冲刺中当前视觉故事
- [ ] 技术实现细节不是主要焦点
- [ ] 判决为 ONBOARDING COMPLETE

---

### 用例 5：Director Gate 检查 — 无 gate；onboard 是只读入职

**Fixture：**
- 任何已配置的项目状态

**输入：** `/onboard`

**预期行为：**
1. Skill 完成完整入职摘要
2. 在任何时候都不生成 director agent
3. 输出中不出现 gate ID
4. 不出现 "May I write" 提示

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不调用写入工具
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 ONBOARDING COMPLETE，无任何 gate 检查

---

## 协议合规性

- [ ] 在生成输出前读取所有源文件（无虚构的项目状态）
- [ ] 根据项目阶段调整输出（Production ≠ Concept）
- [ ] 尊重提供的角色参数
- [ ] 不写入任何文件
- [ ] 所有路径下以 ONBOARDING COMPLETE 判决结束

---

## 覆盖说明

- `technical-preferences.md` 完全缺失（而非仅占位符）的情况不单独测试；行为遵循用例 3 的优雅错误模式。
- Git 历史读取假定可用；离线/无 git 场景此处不测试。
- 除 "artist" 以外的学科角色（例如 programmer、designer、producer）遵循与用例 4 相同的定制模式，不单独测试。
