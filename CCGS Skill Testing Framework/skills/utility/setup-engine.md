<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/setup-engine

## Skill 摘要

`/setup-engine` 通过填充 `technical-preferences.md` 来配置项目的引擎、语言、渲染后端、物理引擎、专家 agent 分配和命名约定。它可选接受引擎参数（例如 `/setup-engine godot`）以跳过引擎选择步骤。对于 `technical-preferences.md` 的每个 section，skill 会展示草稿并在更新前询问 "May I write to `technical-preferences.md`?"。

该 skill 还根据所选引擎填充专家路由表（文件扩展名 → agent 映射）。它没有 director gate——配置是一个技术工具任务。文件完全写入后判决始终为 COMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：COMPLETE
- [ ] 在更新 technical-preferences.md 前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，`/brainstorm` 或 `/start`，取决于流程）

---

## Director Gate 检查

无。`/setup-engine` 是一个技术配置 skill。不适用 director gate。

---

## 测试用例

### 用例 1：Godot 4 + GDScript — 完整引擎配置

**Fixture：**
- `technical-preferences.md` 仅包含占位符
- 提供引擎参数：`godot`

**输入：** `/setup-engine godot`

**预期行为：**
1. Skill 跳过引擎选择步骤（参数已提供）
2. Skill 展示 Godot 的语言选项：GDScript 或 C#
3. 用户选择 GDScript
4. Skill 起草所有引擎 section：engine/language/rendering/physics 字段、命名约定（GDScript 使用 snake_case）、专家分配（godot-specialist、gdscript-specialist、godot-shader-specialist 等）
5. Skill 填充路由表：`.gd` → gdscript-specialist、`.gdshader` → godot-shader-specialist、`.tscn` → godot-specialist
6. Skill 询问 "May I write to `technical-preferences.md`?"
7. 批准后写入文件；判决为 COMPLETE

**断言：**
- [ ] Engine 字段设为 Godot 4（非占位符）
- [ ] Language 字段设为 GDScript
- [ ] 命名约定适用于 GDScript（snake_case）
- [ ] 路由表包含 `.gd`、`.gdshader` 和 `.tscn` 条目
- [ ] 专家已分配（非占位符）
- [ ] 写入前询问 "May I write"
- [ ] 判决为 COMPLETE

---

### 用例 2：Unity + C# — Unity 特定配置

**Fixture：**
- `technical-preferences.md` 仅包含占位符
- 提供引擎参数：`unity`

**输入：** `/setup-engine unity`

**预期行为：**
1. Skill 将引擎设为 Unity，语言设为 C#
2. 命名约定适用于 C#（类用 PascalCase，字段用 camelCase）
3. 专家分配引用 unity-specialist、csharp-specialist
4. 路由表：`.cs` → csharp-specialist、`.asmdef` → unity-specialist、`.unity`（场景）→ unity-specialist
5. Skill 询问 "May I write to `technical-preferences.md`?"，批准后写入

**断言：**
- [ ] Engine 字段设为 Unity（非 Godot 或 Unreal）
- [ ] Language 字段设为 C#
- [ ] 命名约定反映 C# 约定
- [ ] 路由表包含 `.cs` 和 `.unity` 条目
- [ ] 判决为 COMPLETE

---

### 用例 3：Unreal + Blueprint — Unreal 特定配置

**Fixture：**
- `technical-preferences.md` 仅包含占位符
- 提供引擎参数：`unreal`

**输入：** `/setup-engine unreal`

**预期行为：**
1. Skill 将引擎设为 Unreal Engine 5，主要语言设为 Blueprint（Visual Scripting）
2. 专家分配引用 unreal-specialist、blueprint-specialist
3. 路由表：`.uasset` → blueprint-specialist 或 unreal-specialist、`.umap` → unreal-specialist
4. 性能预算预设为 Unreal 默认值（例如，更高的 draw call 预算）
5. Skill 询问 "May I write"，批准后写入；判决为 COMPLETE

**断言：**
- [ ] Engine 字段设为 Unreal Engine 5
- [ ] 路由表包含 `.uasset` 和 `.umap` 条目
- [ ] Blueprint 专家已分配
- [ ] 判决为 COMPLETE

---

### 用例 4：引擎已配置 — 提供重新配置特定 section 的选项

**Fixture：**
- `technical-preferences.md` 引擎设为 Godot 4，所有字段已填充
- 未提供引擎参数

**输入：** `/setup-engine`

**预期行为：**
1. Skill 读取 `technical-preferences.md` 并检测到已完整配置引擎（Godot 4）
2. Skill 报告："Engine already configured as Godot 4 + GDScript"
3. Skill 展示选项：全部重新配置、仅重新配置特定 section（Engine/Language、Naming Conventions、Specialists、Performance Budgets）
4. 用户选择 "Reconfigure Performance Budgets only"
5. 仅性能预算 section 被更新；所有其他字段不变
6. Skill 询问 "May I write to `technical-preferences.md`?"，批准后写入

**断言：**
- [ ] 仅请求 section 更新时 Skill 不覆盖所有字段
- [ ] 向用户提供 section 特定的重新配置选项
- [ ] 写入的文件中仅所选 section 被修改
- [ ] 判决为 COMPLETE

---

### 用例 5：Director Gate 检查 — 无 gate；setup-engine 是一个工具 skill

**Fixture：**
- 新项目，无引擎配置

**输入：** `/setup-engine godot`

**预期行为：**
1. Skill 完成完整引擎配置
2. 在任何时候都不生成 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 COMPLETE，无任何 gate 检查

---

## 协议合规性

- [ ] 在询问写入前展示配置草稿
- [ ] 写入前询问 "May I write to `technical-preferences.md`?"
- [ ] 提供引擎参数时尊重参数（跳过选择步骤）
- [ ] 检测现有配置并提供部分重新配置
- [ ] 为所选引擎的所有关键文件类型填充路由表
- [ ] 文件写入后判决为 COMPLETE

---

## 覆盖说明

- Godot 4 + C#（而非 GDScript）遵循与用例 1 相同的流程，使用不同的命名约定和 godot-csharp-specialist 分配。此变体不单独测试。
- 引擎版本特定引导（例如，来自 VERSION.md 的 Godot 4.6 知识差距警告）由 skill 展示，但不在此处断言测试。
- 每个引擎的性能预算默认值注明为引擎特定的，但确切的默认值不进行断言测试。
