<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Skill 测试规格：/design-review

## Skill 摘要

`/design-review` 读取游戏设计文档（GDD），并对照项目的 8 章节设计标准（概述、玩家幻想、详细规则、公式、边界情况、依赖项、调优参数、验收标准）进行评估。它检查内部一致性、可实施性以及跨系统冲突。产出 APPROVED、NEEDS REVISION 或 MAJOR REVISION NEEDED 判定结果。这是一个只读 Skill（不写入任何文件），作为 `context: fork` 子 Agent 运行。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证——不需要 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题或编号步骤
- [ ] 包含判定关键词：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 不包含 "May I write" 语言（只读 Skill——`allowed-tools` 不包含 Write/Edit）
- [ ] 输出格式已记录（审查模板在 Skill 正文中展示）

---

## 测试用例

### 用例 1：正常路径 — 完整 GDD，所有 8 个章节均存在

**测试环境配置（Fixture）：**
- `design/gdd/light-manipulation.md` 存在（使用 `_fixtures/minimal-game-concept.md` 作为替代——代表一个包含所有必需内容的完整文档）
- 所有 8 个必需章节已填充实质性内容
- 公式章节至少包含一个带有已定义变量的公式
- 验收标准章节包含至少 3 个可测试的标准

**输入：** `/design-review design/gdd/light-manipulation.md`

**预期行为：**
1. Skill 完整读取目标文档
2. Skill 读取 CLAUDE.md 以获取项目上下文和标准
3. Skill 评估所有 8 个必需章节（存在/缺失检查）
4. Skill 检查内部一致性（公式与描述的行为匹配）
5. Skill 检查可实施性（规则足够清晰，可供编码）
6. Skill 输出结构化审查报告，包含逐章节状态
7. Skill 输出 APPROVED 判定结果

**断言：**
- [ ] Skill 在产生任何输出前读取目标文件
- [ ] 输出包含一个"完整性"章节，显示 X/8 个章节存在
- [ ] 输出包含一个"内部一致性"章节
- [ ] 输出包含一个"可实施性"章节
- [ ] 输出以判定行结束：APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED
- [ ] 当所有 8 个章节都存在且一致时，给出 APPROVED 判定结果

---

### 用例 2：失败路径 — 不完整 GDD（4/8 个章节）

**测试环境配置（Fixture）：**
- `design/gdd/light-manipulation.md` 存在，使用 `tests/skills/_fixtures/incomplete-gdd.md` 的内容（8 个章节中 4 个已填充；公式、边界情况、调优参数、验收标准缺失）

**输入：** `/design-review design/gdd/light-manipulation.md`

**预期行为：**
1. Skill 读取文档
2. Skill 识别 4 个缺失章节
3. Skill 输出"完整性：4/8 个章节存在"
4. Skill 具体列出哪 4 个章节缺失
5. Skill 输出 MAJOR REVISION NEEDED 判定结果（非 APPROVED 或 NEEDS REVISION）

**断言：**
- [ ] 输出在完整性章节中显示"4/8"（非更高数字）
- [ ] 输出明确命名每个缺失章节（公式、边界情况、调优参数、验收标准）
- [ ] 当 ≥3 个章节缺失时，判定结果为 MAJOR REVISION NEEDED（非 APPROVED 或 NEEDS REVISION）
- [ ] 输出不会暗示文档已准备好进入实施阶段
- [ ] Skill 不写入任何文件（只读执行）

---

### 用例 3：部分路径 — 7/8 个章节，轻微不一致

**测试环境配置（Fixture）：**
- GDD 包含除公式之外的所有章节
- 描述的行为提到数值，但没有定义公式
- 验收标准存在但含糊不清（"感觉良好"而非可量化指标）

**输入：** `/design-review design/gdd/[document].md`

**预期行为：**
1. Skill 识别缺失的公式章节
2. Skill 将含糊的验收标准标记为可实施性问题
3. Skill 输出 NEEDS REVISION 判定结果（非 APPROVED，非 MAJOR REVISION NEEDED）
4. Skill 为每个问题提供具体的修复说明

**断言：**
- [ ] 对于 7/8 且有问题的状态，判定结果为 NEEDS REVISION（非 APPROVED，非 MAJOR REVISION NEEDED）
- [ ] 输出具体标识缺失的公式章节
- [ ] 输出将含糊的验收标准标记为可实施性缺陷
- [ ] 每个标记的问题都有一个具体的、可操作的修复说明

---

### 用例 4：边界情况 — 文件未找到

**测试环境配置（Fixture）：**
- 提供的路径在项目中不存在

**输入：** `/design-review design/gdd/nonexistent.md`

**预期行为：**
1. Skill 尝试读取文件
2. 文件未找到
3. Skill 输出错误消息，指出缺失的文件名
4. Skill 建议检查路径或列出 `design/gdd/` 中的文件
5. Skill 不产出判定结果

**断言：**
- [ ] 当文件未找到时，Skill 输出明确的错误
- [ ] 当文件缺失时，Skill 不输出 APPROVED、NEEDS REVISION 或 MAJOR REVISION NEEDED
- [ ] Skill 建议一个纠正措施（检查路径、列出可用 GDD）

---

---

### 用例 5：总监关卡 — 无论审查模式如何，均不启动关卡

**测试环境配置（Fixture）：**
- `design/gdd/light-manipulation.md` 存在，包含所有 8 个章节
- `production/session-state/review-mode.txt` 存在，包含 `full`（最宽松的模式）

**输入：** `/design-review design/gdd/light-manipulation.md`（full 审查模式活跃）

**预期行为：**
1. Skill 读取 GDD 文档
2. Skill 不读取 `review-mode.txt`——此 Skill 没有总监关卡
3. Skill 正常产出审查输出
4. 任何时候都不启动总监关卡 Agent
5. 判定结果为 APPROVED（fixture 中所有 8 个章节均存在）

**断言：**
- [ ] Skill 不启动任何总监关卡 Agent（CD-、TD-、PR-、AD- 前缀的 Agent）
- [ ] Skill 不读取 `review-mode.txt` 或等效的模式文件
- [ ] `--review` 标志或 `full` 模式状态对总监是否启动没有影响
- [ ] 输出不包含任何"关卡: [GATE-ID]"条目
- [ ] Skill 自身就是审查——它不将审查委托给总监

---

## 协议合规

- [ ] 不使用 Write 或 Edit 工具（只读 Skill）
- [ ] 在任何判定结果之前展示完整的发现
- [ ] 在产出输出之前不请求批准（没有写入需要批准）
- [ ] 以推荐的下一步结束（例如：修复问题并重新运行，或进入 `/map-systems`）

---

## 覆盖说明

- 跨系统一致性检查（Skill 自身阶段列表中的用例 3）未在此直接测试，因为需要多个 GDD 文件来比较；此项由 `/review-all-gdds` 规格覆盖。
- Skill 的 `context: fork` 行为（作为子 Agent 运行）不在规格层面测试——此为手动验证的运行时行为。
- 涉及非常大的 GDD 文件的性能和边界情况不在本文范围之内。
