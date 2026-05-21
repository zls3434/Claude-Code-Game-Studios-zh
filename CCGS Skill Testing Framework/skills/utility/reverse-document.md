<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/reverse-document

## Skill 摘要

`/reverse-document` 根据现有源代码生成设计或架构文档。它读取指定的源文件，从类结构、方法名称、常量和注释中推断设计意图，并生成 GDD 骨架（用于游戏系统）或架构概览（用于技术系统）。输出是最佳推断——魔法数字和未记录的逻辑可能导致 PARTIAL 判决。

该 skill 在创建文档前询问 "May I write to [inferred path]?"。不适用 director gate。判决：COMPLETE（干净推断）、PARTIAL（某些字段模糊，需要人工审查）。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：COMPLETE、PARTIAL
- [ ] 在写入文档前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，`/design-review` 验证生成的文档）

---

## Director Gate 检查

无。`/reverse-document` 是一个文档工具。不适用 director gate。

---

## 测试用例

### 用例 1：结构良好的源代码 — 生成准确的设计文档骨架

**Fixture：**
- `src/gameplay/health_system.gd` 存在，包含：
  - `@export var max_health: int = 100`
  - 带钳制逻辑的 `func take_damage(amount: int)`
  - `signal health_changed(new_value: int)`
  - 所有公共方法均有文档字符串

**输入：** `/reverse-document src/gameplay/health_system.gd`

**预期行为：**
1. Skill 读取源文件并识别生命系统
2. Skill 推断设计意图：最大生命值、take_damage 行为、生命信号
3. Skill 生成生命系统的 GDD 骨架，包含 8 个必需 section：Overview、Player Fantasy、Detailed Rules、Formulas、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria
4. Formulas section 包含推断的钳制公式
5. Tuning Knobs 注明 `max_health = 100` 为可配置值
6. Skill 询问 "May I write to `design/gdd/health-system.md`?"
7. 文件写入；判决为 COMPLETE

**断言：**
- [ ] 输出中存在所有 8 个必需 GDD section
- [ ] `max_health = 100` 作为 Tuning Knob 出现
- [ ] 钳制公式在 Formulas section 中捕获
- [ ] "May I write" 以推断的路径询问
- [ ] 判决为 COMPLETE

---

### 用例 2：模糊的源代码 — 魔法数字，PARTIAL 判决

**Fixture：**
- `src/gameplay/enemy_ai.gd` 存在，包含：
  - 内联魔法数字：`if distance < 150:`、`speed = 3.5`
  - 无注释或文档字符串
  - 复杂的、非自解释的状态机逻辑

**输入：** `/reverse-document src/gameplay/enemy_ai.gd`

**预期行为：**
1. Skill 读取文件，检测到魔法数字且无上下文
2. Skill 生成 GDD 骨架，附说明："AMBIGUOUS VALUE: 150 (unknown units — is this pixels, world units, or tiles?)"
3. Skill 将 Formulas 和 Tuning Knobs section 标记为需要人工审查
4. Skill 询问 "May I write to `design/gdd/enemy-ai.md`?" 附 PARTIAL 建议
5. 文件以 PARTIAL 标记写入；判决为 PARTIAL

**断言：**
- [ ] 魔法数字出现 AMBIGUOUS VALUE 注释
- [ ] 需要人工审查的 section 被明确标记
- [ ] 判决为 PARTIAL（非 COMPLETE）
- [ ] 文件仍然写入 — PARTIAL 不是阻塞性失败

---

### 用例 3：多个相互依赖的文件 — 生成跨系统概览

**Fixture：**
- 用户提供 2 个源文件：`combat_system.gd` 和 `damage_resolver.gd`
- 文件互相引用（combat 调用 damage_resolver）

**输入：** `/reverse-document src/gameplay/combat_system.gd src/gameplay/damage_resolver.gd`

**预期行为：**
1. Skill 读取两个文件并检测依赖关系
2. Skill 生成跨系统架构概览（非单独的 GDD）
3. 概览描述：Combat System → Damage Resolver 交互、共享接口、两者之间的数据流
4. Skill 询问 "May I write to `docs/architecture/combat-damage-overview.md`?"
5. 批准后写入概览；判决为 COMPLETE（或 PARTIAL，如果模糊）

**断言：**
- [ ] 两个文件一起分析（非两个独立文档）
- [ ] 跨系统依赖关系在输出中记录
- [ ] 输出文件写入 `docs/architecture/`（非 `design/gdd/`）
- [ ] 判决为 COMPLETE 或 PARTIAL

---

### 用例 4：源文件未找到 — 错误

**Fixture：**
- `src/gameplay/inventory_system.gd` 不存在

**输入：** `/reverse-document src/gameplay/inventory_system.gd`

**预期行为：**
1. Skill 尝试读取指定文件 — 未找到
2. Skill 输出："Source file not found: src/gameplay/inventory_system.gd"
3. Skill 建议检查路径或运行 `/map-systems` 识别正确的源文件
4. 不创建文档

**断言：**
- [ ] 错误消息以完整路径命名缺失文件
- [ ] 提供替代建议（检查路径或 `/map-systems`）
- [ ] 不调用写入工具
- [ ] 无判决发出（错误状态）

---

### 用例 5：Director Gate 检查 — 无 gate；reverse-document 是一个工具

**Fixture：**
- 存在结构良好的源文件

**输入：** `/reverse-document src/gameplay/health_system.gd`

**预期行为：**
1. Skill 生成并写入设计文档
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 COMPLETE 或 PARTIAL — 不涉及 gate 判决

---

## 协议合规性

- [ ] 在生成任何内容前读取源文件
- [ ] 当目标是游戏系统时生成全部 8 个必需 GDD section
- [ ] 用 AMBIGUOUS VALUE 标记注释模糊值
- [ ] 多文件时生成跨系统概览（非单独的 GDD）
- [ ] 创建任何输出文件前询问 "May I write"
- [ ] 判决为 COMPLETE（干净推断）或 PARTIAL（模糊字段）

---

## 覆盖说明

- 架构概览格式（用于技术/基础设施系统）与 GDD 格式不同；推断的输出类型由源文件性质决定（游戏逻辑 → GDD；引擎/基础设施代码 → 架构文档）。
- 源文件可读但仅包含自动生成的样板代码（无有意义逻辑）的情况不测试；skill 可能会生成近乎空的骨架且判决为 PARTIAL。
- C# 和 Blueprint 源文件遵循与 GDScript 相同的推断模式；语言特定差异在 skill 正文中处理。
