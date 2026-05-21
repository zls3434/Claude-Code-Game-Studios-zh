<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/architecture-review

## Skill 摘要

`/architecture-review` 是一个 Opus 级别的 Skill，用于验证技术架构文档是否满足项目的 8 个必需架构章节，并检查文档内部一致性、是否与现有 ADR 存在冲突以及是否正确锁定引擎版本。该 Skill 产出 APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED 判定结果。

在 `full` 审查模式下，该 Skill 并行启动两个总监关卡 Agent：TD-ARCHITECTURE（technical-director）和 LP-FEASIBILITY（lead-programmer）。在 `lean` 或 `solo` 模式下，两个关卡均被跳过并记录。该 Skill 为只读——不写入任何文件。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证——不需要 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判定关键词：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 不要求 "May I write" 语言（只读 Skill）
- [ ] 末尾有下一步引导
- [ ] 记录关卡行为：full 模式下 TD-ARCHITECTURE + LP-FEASIBILITY；lean/solo 模式下跳过

---

## 总监关卡检查

在 `full` 模式下：Skill 读取架构文档后，并行启动 TD-ARCHITECTURE（technical-director）和 LP-FEASIBILITY（lead-programmer）。

在 `lean` 模式下：两个关卡均跳过。输出记录："TD-ARCHITECTURE 已跳过 — lean 模式"和"LP-FEASIBILITY 已跳过 — lean 模式"。

在 `solo` 模式下：两个关卡均跳过，输出等效的记录。

---

## 测试用例

### 用例 1：正常路径 — full 模式下完整的架构文档

**测试环境配置（Fixture）：**
- `docs/architecture/architecture.md` 存在，所有 8 个必需章节已填充
- 所有章节引用的引擎版本与 `docs/engine-reference/` 一致
- 与 `docs/architecture/` 中现有的已接受 ADR 没有冲突
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/architecture-review docs/architecture/architecture.md`

**预期行为：**
1. Skill 读取架构文档
2. Skill 读取现有 ADR 进行交叉引用
3. Skill 读取引擎版本参考
4. TD-ARCHITECTURE 和 LP-FEASIBILITY 关卡 Agent 并行启动
5. 两个关卡均返回 APPROVED
6. Skill 输出逐章节完整性检查（8/8 个章节存在）
7. 判定结果：APPROVED

**断言：**
- [ ] 所有 8 个必需章节被检查并报告
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 并行启动（非顺序执行）
- [ ] 当所有章节存在且无冲突时，判定结果为 APPROVED
- [ ] Skill 不写入任何文件
- [ ] 存在指向 `/create-control-manifest` 或 `/create-epics` 的下一步引导

---

### 用例 2：失败路径 — 缺少必需章节

**测试环境配置（Fixture）：**
- `docs/architecture/architecture.md` 存在，但缺少至少 2 个必需章节（例如：没有数据模型章节、没有错误处理章节）
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/architecture-review docs/architecture/architecture.md`

**预期行为：**
1. Skill 读取文档并识别缺失的章节
2. 章节完整性检查显示少于 8/8 个章节存在
3. 缺失章节按名称列出，并附带具体的修复指导
4. 判定结果：MAJOR REVISION NEEDED（≥2 个缺失章节）

**断言：**
- [ ] 对于 ≥2 个缺失章节，判定结果为 MAJOR REVISION NEEDED（不是 APPROVED 或 NEEDS REVISION）
- [ ] 每个缺失章节在输出中明确命名
- [ ] 修复指导是具体的（说明需要添加什么，而不仅仅是"添加缺失章节"）
- [ ] Skill 不会放行缺少必需章节的文档

---

### 用例 3：部分路径 — 架构与现有 ADR 冲突

**测试环境配置（Fixture）：**
- `docs/architecture/architecture.md` 存在，包含所有 8 个章节
- `docs/architecture/` 中存在一条已接受的 ADR，该 ADR 建立的约束被架构文档违背（例如：ADR-001 要求使用 ECS 模式；architecture.md 对同一系统描述了不同的模式）

**输入：** `/architecture-review docs/architecture/architecture.md`

**预期行为：**
1. Skill 读取架构文档和所有现有 ADR
2. 检测到架构文档与指定 ADR 之间的冲突
3. 冲突条目命名：ADR 编号/标题、冲突的章节、以及影响
4. 判定结果：NEEDS REVISION（存在冲突但结构上可接受）

**断言：**
- [ ] 对于单一冲突，判定结果为 NEEDS REVISION（不是 MAJOR REVISION NEEDED）
- [ ] 冲突条目中命名了具体的 ADR 编号和标题
- [ ] 识别了两个文档中冲突的章节
- [ ] Skill 不会自动解决冲突

---

### 用例 4：边界情况 — 文件未找到

**测试环境配置（Fixture）：**
- 提供的路径在项目中不存在

**输入：** `/architecture-review docs/architecture/nonexistent.md`

**预期行为：**
1. Skill 尝试读取文件
2. 文件未找到
3. Skill 输出明确的错误，指出缺失的文件名
4. Skill 建议检查 `docs/architecture/` 或运行 `/create-architecture`
5. Skill 不产出判定结果

**断言：**
- [ ] 当文件未找到时，Skill 输出明确的错误
- [ ] 不产出判定结果（APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED）
- [ ] Skill 建议一个纠正措施
- [ ] Skill 不会崩溃或产出部分报告

---

### 用例 5：总监关卡 — full 模式启动两个关卡；solo 模式跳过两个关卡

**测试环境配置（full 模式）：**
- `docs/architecture/architecture.md` 存在，包含所有 8 个章节
- `production/session-state/review-mode.txt` 包含 `full`

**Full 模式预期行为：**
1. TD-ARCHITECTURE 关卡启动
2. LP-FEASIBILITY 关卡与 TD-ARCHITECTURE 并行启动
3. 两个关卡均在判定结果发布前完成

**断言（full 模式）：**
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 均作为已完成的关卡出现在输出中
- [ ] 两个关卡并行启动（非前后顺序）
- [ ] 判定结果反映关卡反馈

**测试环境配置（solo 模式）：**
- 相同的架构文档
- `production/session-state/review-mode.txt` 包含 `solo`

**Solo 模式预期行为：**
1. Skill 读取架构文档
2. 关卡不会启动
3. 输出记录："TD-ARCHITECTURE 已跳过 — solo 模式"和"LP-FEASIBILITY 已跳过 — solo 模式"
4. 判定结果仅基于结构检查

**断言（solo 模式）：**
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 均不作为活跃关卡出现
- [ ] 两个跳过的关卡在输出中被记录
- [ ] 判定结果仍然仅基于结构检查产出

---

## 协议合规

- [ ] 不写入任何文件（只读 Skill）
- [ ] 在发布判定结果前展示章节完整性检查
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 在 full 模式下并行启动
- [ ] 在 lean/solo 输出中按名称和模式记录跳过的关卡
- [ ] 判定结果仅限于：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 根据判定结果以适当的下一步引导结束

---

## 覆盖说明

- 8 个必需架构章节是项目特定的；测试使用 Skill 正文中定义的章节列表——此处不重新枚举。
- 引擎版本兼容性检查（交叉引用 `docs/engine-reference/`）是用例 1 正常路径的一部分，但没有独立的 fixture 测试。
- RTM（需求可追溯性矩阵）模式由 `/architecture-review` Skill 自身的 `rtm` 参数模式处理，此处不测试。
