<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/project-stage-detect

## Skill 摘要

`/project-stage-detect` 自动分析项目工件以确定当前开发阶段。它在 Haiku 模型上运行（只读），检查 `production/stage.txt`（如存在）、`design/` 中的设计文档、`src/` 中的源代码、`production/` 中的冲刺和里程碑文件，以及引擎配置的存在情况，将项目归类为七个阶段之一：Concept、Systems Design、Technical Setup、Pre-Production、Production、Polish 或 Release。

该 skill 是建议性的——它从不写入 `stage.txt`。该文件仅在 `/gate-check` 通过且用户确认推进时更新。该 skill 报告其置信度（如果直接读取 stage.txt 则为 HIGH，如果从工件推断则为 MEDIUM，如果发现冲突信号则为 LOW）。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含所有七个阶段名称：Concept、Systems Design、Technical Setup、Pre-Production、Production、Polish、Release
- [ ] 不包含 "May I write" 语言（skill 仅用于检测）
- [ ] 有下一步交接（例如，`/gate-check` 正式推进阶段）

---

## Director Gate 检查

无。`/project-stage-detect` 是一个只读检测工具。不适用 director gate。

---

## 测试用例

### 用例 1：stage.txt 存在 — 直接读取并交叉检查工件

**Fixture：**
- `production/stage.txt` 包含 `Production`
- `design/gdd/` 有 4 个 GDD 文件
- `src/` 有源代码文件
- `production/sprints/sprint-002.md` 存在

**输入：** `/project-stage-detect`

**预期行为：**
1. Skill 读取 `production/stage.txt` — 检测到阶段 `Production`
2. Skill 交叉检查工件：GDD 存在、源代码存在、冲刺存在
3. 工件与 Production 阶段一致
4. Skill 报告：Stage = Production，Confidence = HIGH（来自 stage.txt，由工件确认）
5. 下一步：继续 `/sprint-plan` 或 `/dev-story`

**断言：**
- [ ] 检测到的阶段为 Production
- [ ] stage.txt 存在时置信度报告为 HIGH
- [ ] 交叉检查结果（一致 vs. 不一致）被注明
- [ ] 没有文件被写入
- [ ] 判决清楚说明检测到的阶段

---

### 用例 2：无 stage.txt 但 GDD 和 Epics 存在 — 推断为 Production

**Fixture：**
- 无 `production/stage.txt`
- `design/gdd/` 有 3 个 GDD 文件
- `production/epics/` 有 2 个 epic 文件
- `src/` 有源代码文件
- `production/sprints/sprint-001.md` 存在

**输入：** `/project-stage-detect`

**预期行为：**
1. Skill 未找到 stage.txt — 切换到工件推断模式
2. Skill 发现 GDD（Systems Design 完成）、epics（Pre-Production 完成）、源代码和冲刺（Production 活动中）
3. Skill 推断：Stage = Production
4. 置信度为 MEDIUM（从工件推断，非来自 stage.txt）
5. Skill 建议运行 `/gate-check` 以正式确认并写入 stage.txt

**断言：**
- [ ] 推断的阶段为 Production
- [ ] 置信度为 MEDIUM（非 HIGH，因为 stage.txt 缺失）
- [ ] 存在运行 `/gate-check` 的建议
- [ ] 此 skill 不写入任何 stage.txt

---

### 用例 3：无 stage.txt，无文档，无源代码 — 推断为 Concept

**Fixture：**
- 无 `production/stage.txt`
- `design/` 目录存在但为空
- `src/` 存在但不包含代码文件
- `technical-preferences.md` 仅为占位符

**输入：** `/project-stage-detect`

**预期行为：**
1. Skill 未找到 stage.txt
2. 工件扫描：无 GDD、无源代码、无 epics、无冲刺、引擎未配置
3. Skill 推断：Stage = Concept
4. 置信度为 MEDIUM
5. Skill 建议 `/start` 开始入职工作流

**断言：**
- [ ] 推断的阶段为 Concept
- [ ] 输出列出已检查（且发现缺失）的工件
- [ ] 建议 `/start` 作为下一步
- [ ] 没有文件被写入

---

### 用例 4：不一致 — stage.txt 显示 Production 但无源代码

**Fixture：**
- `production/stage.txt` 包含 `Production`
- `design/gdd/` 有 GDD 文件
- `src/` 目录存在但不包含源代码文件
- 无冲刺文件存在

**输入：** `/project-stage-detect`

**预期行为：**
1. Skill 读取 stage.txt — 检测到 `Production`
2. 交叉检查发现：无源代码、无冲刺 — 与 Production 不一致
3. Skill 标记不一致："stage.txt says Production but no source code or sprints found"
4. Skill 报告检测阶段为 Production（遵循 stage.txt），但置信度因工件不匹配降至 LOW
5. Skill 建议手动审查 stage.txt 或运行 `/gate-check`

**断言：**
- [ ] 输出中明确标记不一致
- [ ] 工件与 stage.txt 矛盾时置信度为 LOW
- [ ] stage.txt 值不被静默覆盖
- [ ] 建议用户手动验证差异

---

### 用例 5：Director Gate 检查 — 无 gate；检测是建议性的

**Fixture：**
- 任何有或无 stage.txt 的项目状态

**输入：** `/project-stage-detect`

**预期行为：**
1. Skill 完成完整的阶段检测
2. 在任何时候都不生成 director agent
3. 输出中不出现 gate ID
4. 不调用写入工具

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不调用写入工具
- [ ] 检测输出纯为建议性
- [ ] 判决命名检测到的阶段而不触发任何 gate

---

## 协议合规性

- [ ] 如果 stage.txt 存在则读取；如果不存在则回退到工件推断
- [ ] 始终报告置信度（HIGH / MEDIUM / LOW）
- [ ] 交叉检查 stage.txt 与工件并标记不一致
- [ ] 不写入 stage.txt（这是 `/gate-check` 的职责）
- [ ] 以适用于检测到的阶段的下一步建议结束

---

## 覆盖说明

- Technical Setup 阶段（引擎已配置，尚无 GDD）和 Pre-Production 阶段（GDD 完成，尚无 epics）遵循与用例 2 和 3 相同的工件推断模式，不单独 fixture 测试。
- Polish 和 Release 阶段此处不进行 fixture 测试；它们遵循相同的高置信度（stage.txt 存在）或推断逻辑。
- 置信度是建议性的——该 skill 不基于它们进行任何操作的门控。
