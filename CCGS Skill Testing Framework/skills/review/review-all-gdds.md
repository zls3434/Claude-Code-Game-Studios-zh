<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/review-all-gdds

## Skill 摘要

`/review-all-gdds` 是一个 Opus 级别的 Skill，对 `design/gdd/` 中的所有文件进行整体的跨 GDD 审查。它并行运行两个互补的审查阶段：阶段 1 检查一致性（矛盾、公式不匹配、过时引用、竞争归属），阶段 2 检查设计理论（主导策略、支柱偏离、认知过载、经济失衡）。由于两个阶段相互独立，它们被同时启动以节省时间。该 Skill 产出 CONSISTENT / MINOR ISSUES / MAJOR ISSUES 判定结果，且为只读——未经用户明确批准不写入任何文件。

该 Skill 自身就是管道中的整体审查关卡。它在各个 GDD 完成之后、架构工作开始之前被调用。它不会启动任何总监关卡 Agent（它本身就是总监级别的审查）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证——不需要 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥5 个阶段标题（复杂的多阶段 Skill）
- [ ] 包含判定关键词：CONSISTENT、MINOR ISSUES、MAJOR ISSUES
- [ ] 不包含 "May I write" 语言（只读 Skill）
- [ ] 末尾有下一步引导
- [ ] 记录并行阶段启动（阶段 1 和阶段 2 是独立的）

---

## 总监关卡检查

无总监关卡——此 Skill 不启动任何总监关卡 Agent。它本身就是整体审查；委托给总监关卡会形成循环依赖。

---

## 测试用例

### 用例 1：正常路径 — 干净的 GDD 集合，无任何冲突

**测试环境配置（Fixture）：**
- `design/gdd/` 包含 ≥3 个系统 GDD
- 所有 GDD 内部一致：无公式矛盾、无竞争归属、无过时引用
- 所有 GDD 与 `design/gdd/game-pillars.md` 中定义的支柱保持一致

**输入：** `/review-all-gdds`

**预期行为：**
1. Skill 读取 `design/gdd/` 中的所有 GDD 文件
2. 阶段 1（一致性扫描）和阶段 2（设计理论检查）并行启动
3. 阶段 1 未发现矛盾、公式不匹配、归属冲突
4. 阶段 2 未发现支柱偏离、主导策略、认知过载
5. Skill 输出结构化的发现表，其中 0 个阻塞性问题
6. 判定结果：CONSISTENT

**断言：**
- [ ] 两个审查阶段并行启动（非顺序执行）
- [ ] 输出包含发现表（即使为空——显示"未发现问题"）
- [ ] 当无冲突发现时，判定结果为 CONSISTENT
- [ ] Skill 未经用户批准不写入任何文件
- [ ] 存在指向 `/architecture-review` 或 `/create-architecture` 的下一步引导

---

### 用例 2：失败路径 — 两个 GDD 之间的规则冲突

**测试环境配置（Fixture）：**
- GDD-A 定义了一个下限值（例如："最小 [output] 为 [N]"）
- GDD-B 描述了一个绕过该下限的机制（例如："[mechanic] 可以将 [output] 降低到 0"）
- 两个 GDD 在其他方面是完整且有效的

**输入：** `/review-all-gdds`

**预期行为：**
1. 阶段 1（一致性扫描）检测到 GDD-A 和 GDD-B 之间的矛盾
2. 冲突报告包含：两个文件名、具体冲突规则、严重程度 HIGH
3. 判定结果：MAJOR ISSUES
4. 引导指示用户在继续之前解决冲突并重新运行

**断言：**
- [ ] 判定结果为 MAJOR ISSUES（不是 CONSISTENT 或 MINOR ISSUES）
- [ ] 冲突条目中命名了两个 GDD 文件名
- [ ] 矛盾规则被引用或描述（不是含糊的"发现冲突"）
- [ ] 问题被归类为严重程度 HIGH（阻塞性）
- [ ] Skill 不会自动解决冲突

---

### 用例 3：部分路径 — 单个 GDD 中存在孤立依赖引用

**测试环境配置（Fixture）：**
- GDD-A 在其"依赖项"章节中列出了一项依赖，指向"system-B"
- `design/gdd/` 中不存在 system-B 的 GDD
- 所有其他 GDD 均保持一致

**输入：** `/review-all-gdds`

**预期行为：**
1. 阶段 1 检测到 GDD-A 中的孤立依赖引用
2. 问题报告为：DEPENDENCY GAP — GDD-A 引用了 system-B，但 system-B 没有 GDD
3. 未发现其他冲突
4. 判定结果：MINOR ISSUES（依赖缺失是建议性的，本身不阻塞）

**断言：**
- [ ] 判定结果为 MINOR ISSUES（不是 MAJOR ISSUES，单个孤立引用）
- [ ] 报告了具体的 GDD 文件名和缺失的依赖名称
- [ ] Skill 建议运行 `/design-system system-B` 来解决缺失
- [ ] Skill 不会跳过或静默忽略缺失的依赖

---

### 用例 4：边界情况 — 未找到 GDD 文件

**测试环境配置（Fixture）：**
- `design/gdd/` 目录为空或不存在
- 没有 GDD 文件存在

**输入：** `/review-all-gdds`

**预期行为：**
1. Skill 尝试读取 `design/gdd/` 中的文件
2. 未找到文件——Skill 输出带有指导的错误
3. Skill 建议在重新运行之前运行 `/brainstorm` 和 `/design-system`
4. Skill 不产出判定结果（CONSISTENT / MINOR ISSUES / MAJOR ISSUES）

**断言：**
- [ ] 当未找到 GDD 时，Skill 输出明确的错误消息
- [ ] 当目录为空时，不产出判定结果
- [ ] Skill 推荐正确的下一步操作（`/brainstorm` 或 `/design-system`）
- [ ] Skill 不会崩溃或产出部分报告

---

### 用例 5：总监关卡 — 无论审查模式如何，均不启动关卡

**测试环境配置（Fixture）：**
- `design/gdd/` 包含 ≥2 个一致的系统 GDD
- `production/session-state/review-mode.txt` 存在，内容为 `full`

**输入：** `/review-all-gdds`

**预期行为：**
1. Skill 读取所有 GDD 并运行两个审查阶段
2. Skill 不读取 `review-mode.txt`
3. Skill 不启动任何总监关卡 Agent（CD-、TD-、PR-、AD- 前缀）
4. Skill 正常完成并输出判定结果
5. 审查模式设置对此 Skill 的行为没有影响

**断言：**
- [ ] 任何时候都不启动总监关卡 Agent
- [ ] Skill 不读取 `production/session-state/review-mode.txt`
- [ ] 输出不包含任何"关卡: [GATE-ID]"或"已跳过"的关卡条目
- [ ] 该 Skill 在所有模式下均产出判定结果
- [ ] R4 指标：此 Skill 在所有模式下的关卡数量 = 0

---

## 协议合规

- [ ] 阶段 1（一致性）和阶段 2（设计理论）并行启动——非顺序执行
- [ ] 未经 "May I write" 批准不写入任何文件
- [ ] 在任何写入请求之前展示发现表
- [ ] 判定结果仅限于：CONSISTENT、MINOR ISSUES、MAJOR ISSUES
- [ ] 以适当的引导结束：MAJOR ISSUES → 修复并重新运行；MINOR ISSUES → 可在注意问题的情况下继续；CONSISTENT → `/create-architecture`

---

## 覆盖说明

- 经济平衡分析（产出/消耗循环）需要跨 GDD 资源数据——在结构上被用例 2 覆盖（冲突检测模式相同）。
- 设计理论阶段（阶段 2）的检查，包括主导策略检测和认知过载分析，未单独进行 fixture 测试——它们遵循与一致性检查相同的检测模式，并通过支柱偏离用例结构进行验证。
- `since-last-review` 范围模式未在此测试——它是运行时关注点。
