<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/start

## Skill 摘要

`/start` 是项目入口点。它指导用户完成引导式入职序列：(1) 运行 `/project-stage-detect`，(2) 根据检测到的阶段建议 `/adopt`（棕地）或进入配置，(3) 通过 `/setup-engine` 配置引擎，(4) 通过 `/brainstorm` 构思游戏概念，(5) 运行 `/map-systems`，以及 (6) 通过阶段 gate（TD-SETUP）推进到下一阶段。

`/start` 本身不执行任何 skill——它提示用户，确认，然后指示运行指定的 skills。它是一个引导式导航器，在 Haiku 模型上运行，没有 director gate。判决始终为 READY —— `/start` 不自己执行任何操作，它帮助用户到达正确的工作流入口。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：READY
- [ ] 不包含 "May I write" 语言（skill 只读，仅用于指示）
- [ ] 有下一步交接（例如，`/adopt` 用于棕地项目，`/setup-engine` 用于新项目）
- [ ] 在 Haiku 模型上下文限制内运行

---

## Director Gate 检查

无。`/start` 不执行任何 skill。它导航用户到正确的入口点。不适用 director gate。

---

## 测试用例

### 用例 1：新项目（Concept 阶段）— 引导序列，引擎选择，概念构思

**Fixture：**
- `CLAUDE.md` 存在，包含默认内容
- 无 `production/stage.txt`
- `technical-preferences.md` 仅包含占位符
- 无设计文档，无源代码

**输入：** `/start`

**预期行为：**
1. Skill 检测到新项目：无工件、无引擎、无概念
2. Skill 欢迎用户，简要解释工作室工作流
3. Skill 询问："I'll guide you through the setup. Ready to begin?"
4. 步骤 1：技能指示运行 `/project-stage-detect` → 返回 Concept
5. 步骤 2：由于无先前工件，skill 跳过 adopt。询问用户确认引擎选择 → 指示运行 `/setup-engine godot`（或用户偏好）
6. 步骤 3：引擎配置后，指示运行 `/brainstorm`
7. 步骤 4：概念完成后，指示运行 `/map-systems`
8. 步骤 5：系统映射后，指示运行 `/gate-check` 推进到 Technical Setup
9. 未自行运行任何 skill；完全通过指示模式
10. 判决为 READY

**断言：**
- [ ] Skill 在步骤 1 中指示运行 `/project-stage-detect`
- [ ] Skill 为棕地路径提供 `/adopt`（不适用但会提及）
- [ ] Skill 指示运行 `/setup-engine`（用户表明引擎选择后）
- [ ] Skill 指示运行 `/brainstorm`
- [ ] Skill 指示运行 `/gate-check` 用于阶段推进
- [ ] 判决为 READY
- [ ] 没有执行任何 skill（仅指示）

---

### 用例 2：棕地项目（Production 阶段）— 建议 adopt 而非新设置

**Fixture：**
- `CLAUDE.md` 存在
- `production/stage.txt` 不存在
- `design/gdd/` 包含 2 个 GDD 文件
- `src/` 包含源代码
- `production/sprints/sprint-003.md` 存在
- 引擎已在 `technical-preferences.md` 中配置

**输入：** `/start`

**预期行为：**
1. 步骤 1：Skill 指示运行 `/project-stage-detect` → 推断阶段为 Production
2. Skill 检测到现有工件 → 走过棕地路径
3. 步骤 2：Skill 建议运行 `/adopt` 审核现有工件与模板的兼容性
4. Skill 解释：引擎已配置，概念已存在 — 不需设置步骤
5. Skill 建议运行 `/sprint-status` 查看当前冲刺活动
6. 判决为 READY

**断言：**
- [ ] Skill 指示运行 `/project-stage-detect` 以确认阶段
- [ ] `/adopt` 被推荐（而非 `/setup-engine` 或 `/brainstorm`）
- [ ] Skill 识别到引擎和概念已存在
- [ ] Skill 建议生产路径后续（`/sprint-status`）
- [ ] 判决为 READY

---

### 用例 3：部分配置 — 引擎已设置但无概念

**Fixture：**
- `production/stage.txt` 包含 `Technical Setup`
- 引擎已在 `technical-preferences.md` 中配置
- 无 `design/gdd/game-concept.md`

**输入：** `/start`

**预期行为：**
1. 步骤 1：Skill 指示运行 `/project-stage-detect` → 检测到 Technical Setup
2. Skill 检测到引擎已配置但无概念
3. 步骤 2：Skill 跳过 `/setup-engine`（已配置）。跳过 `/adopt`（无要迁移的工件）
4. 步骤 3：Skill 指示运行 `/brainstorm` 创建游戏概念
5. Skill 指示运行 `/gate-check` 推进到 Systems Design 阶段
6. 判决为 READY

**断言：**
- [ ] 已配置引擎时 Skill 不指示运行 `/setup-engine`
- [ ] Skill 指示运行 `/brainstorm`（概念缺失）
- [ ] 不存在要审核的工件时 Skill 不指示运行 `/adopt`
- [ ] 判决为 READY

---

### 用例 4：缺少 CLAUDE.md — 引导式恢复

**Fixture：**
- `CLAUDE.md` 不存在

**输入：** `/start`

**预期行为：**
1. Skill 读取 CLAUDE.md — 文件未找到
2. Skill 输出："CLAUDE.md not found. This is the root project configuration file."
3. 询问用户："The default CLAUDE.md contains the project structure and coordination rules. May I create CLAUDE.md from the studio template?"
4. 用户确认后：Skill 指示将默认 CLAUDE.md 写入磁盘，然后正常继续

**断言：**
- [ ] 缺失文件被明确命名（CLAUDE.md）
- [ ] 针对 CLAUDE.md 创建提出明确的是/否问题
- [ ] 解决 CLAUDE.md 问题后才继续执行序列
- [ ] 判决为 READY（CLAUDE.md 创建后）

---

### 用例 5：Director Gate 检查 — 无 gate；start 是引导式导航器

**Fixture：**
- 新项目，无工件

**输入：** `/start`

**预期行为：**
1. Skill 引导用户完成入职工作流
2. 技能自身不生成任何 director agent
3. 输出中不出现 gate ID
4. 提到 `/gate-check`，但由用户自行运行

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] `/gate-check` 作为推荐提及，但不由 `/start` 运行
- [ ] 判决为 READY — 无 gate 判决

---

## 协议合规性

- [ ] 在建议 skills 之前先检测项目状态（新 vs. 棕地）
- [ ] 始终从 `/project-stage-detect` 开始
- [ ] 根据检测到的状态建议 `/adopt` 或 `/setup-engine`
- [ ] 不执行任何 skills（`/start` 是只读导航器）
- [ ] 如果同时存在未完成的 setup 步骤和棕地材料，提供过渡说明
- [ ] 判决始终为 READY

---

## 覆盖说明

- `/start` skill 的迭代性（用户可重新运行以跟进部分完成的设置）与初始运行使用相同的路径检测逻辑；不单独进行 fixture 测试。
- CLAUDE.md 恢复路径仅处理文件不存在的情况；如果文件存在但为空或格式错误，skill 的行为由正文处理。
- 阶段特定引导文本因检测到的阶段而异；确切的措辞不进行断言测试——仅检查推荐的 skill 名称。
