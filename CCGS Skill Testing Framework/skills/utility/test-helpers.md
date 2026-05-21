<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/test-helpers

## Skill 摘要

`/test-helpers` 为项目生成测试辅助工具库。它分析 GDD 和源代码结构，识别重复的测试模式（例如设置测试玩家、模拟输入、安排关卡），并将模式例化为可复用的测试辅助函数。这些辅助函数在创建前经过 "May I write" 询问后写入 `tests/helpers/`。

辅助函数按类别组织：玩家工具（`spawn_player`、`teleport`、`equip_item`）、世界工具（`load_test_level`、`spawn_entities`、`configure_physics`）、模拟工具（`simulate_damage`、`set_stats`）和断言工具（`assert_player_at_position`、`assert_health_within`）。该 skill 不运行测试——它为测试生成基础设施工具。不适用 director gate。判决：HELPERS CREATED（新辅助函数已写入）或 DEPENDENCY CHECK（依赖项缺失——GDD 或测试基础设施未找到）。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：HELPERS CREATED、DEPENDENCY CHECK
- [ ] 包含 "May I write" 语言（用于辅助文件创建）
- [ ] 有下一步交接（例如，`/qa-plan` 或 `/smoke-check`）

---

## Director Gate 检查

无。`/test-helpers` 是一个测试基础设施工具。不适用 director gate。

---

## 测试用例

### 用例 1：从 GDD 生成玩家工具 — Helpers Created

**Fixture：**
- `design/gdd/player.md` 存在，定义玩家移动、生命值和战斗属性
- `tests/helpers/` 目录存在但为空
- Engine 已配置

**输入：** `/test-helpers`

**预期行为：**
1. Skill 读取 `design/gdd/player.md` 并提取玩家属性
2. Skill 识别重复测试模式：生成玩家、为测试设置生命值、装备物品
3. Skill 生成辅助函数：
   - `spawn_player(position)` — 在指定位置生成测试玩家
   - `set_player_health(value)` — 为测试设置玩家生命值
   - `equip_test_weapon(weapon_id)` — 为测试装备指定武器
4. 每个辅助函数创建前逐一询问 "May I write"
5. 辅助函数写入 `tests/helpers/player_tools.gd`
6. 判决为 HELPERS CREATED

**断言：**
- [ ] GDD 被解析并属性被提取
- [ ] 辅助函数反映 GDD 中的玩家属性
- [ ] 每个辅助文件询问 "May I write"
- [ ] 辅助函数写入 `tests/helpers/` 目录
- [ ] 判决为 HELPERS CREATED

---

### 用例 2：指定类别 — 仅为请求的类别生成辅助函数

**Fixture：**
- 用户指定：category = "simulation"
- GDD 和源代码结构存在

**输入：** `/test-helpers --category simulation`

**预期行为：**
1. Skill 仅为模拟工具类别生成辅助函数
2. 生成的辅助函数：`simulate_damage`、`set_stats`、`simulate_input`
3. 不生成玩家、世界或断言辅助函数
4. 判决为 HELPERS CREATED

**断言：**
- [ ] 仅生成模拟类别的辅助函数
- [ ] 不生成其他类别（玩家、世界、断言）的辅助函数
- [ ] 判决为 HELPERS CREATED

---

### 用例 3：无 GDD，无引擎配置 — DEPENDENCY CHECK

**Fixture：**
- `design/gdd/` 不存在或为空
- `technical-preferences.md` 仅为占位符

**输入：** `/test-helpers`

**预期行为：**
1. Skill 尝试读取 GDD — 未找到
2. Skill 进行依赖检查：
   - GDD：MISSING
   - Engine configuration：MISSING
   - Test directory：存在或不存在
3. Skill 输出："DEPENDENCY CHECK — cannot generate test helpers"
4. Skill 列出缺失的依赖并建议操作：
   - 运行 `/brainstorm` 创建游戏概念
   - 运行 `/setup-engine` 配置引擎
   - 运行 `/test-setup` 如果测试目录缺失
5. 不生成辅助函数
6. 判决为 DEPENDENCY CHECK

**断言：**
- [ ] 判决为 DEPENDENCY CHECK（非 HELPERS CREATED）
- [ ] 缺失的依赖被命名（GDD、Engine）
- [ ] 每个缺失依赖提供补救建议
- [ ] 不创建文件

---

### 用例 4：辅助函数已存在 — 提供更新选项

**Fixture：**
- `tests/helpers/player_tools.gd` 已存在，包含来自先前运行的辅助函数
- GDD 已更新：添加了新玩家属性（护甲、魔法值）

**输入：** `/test-helpers`

**预期行为：**
1. Skill 检测到 `tests/helpers/player_tools.gd` 已存在
2. Skill 读取现有辅助函数并比较当前 GDD
3. Skill 识别新增的玩家属性（护甲、魔法值）无对应辅助函数
4. Skill 提供选项：仅添加新属性的辅助函数、重新生成全部、取消
5. 选择添加新属性后：为 `set_player_armor`、`set_player_mana` 询问 "May I write"
6. 新生成了 2 个辅助函数，现有辅助函数保留
7. 判决为 HELPERS CREATED

**断言：**
- [ ] 检测到现有辅助文件
- [ ] 仅添加新辅助函数（现有辅助函数保留）
- [ ] 每个新辅助函数询问 "May I write"
- [ ] 判决为 HELPERS CREATED

---

### 用例 5：Director Gate 检查 — 无 gate；test-helpers 是一个工具

**Fixture：**
- GDD 和引擎配置存在

**输入：** `/test-helpers`

**预期行为：**
1. Skill 生成辅助函数文件
2. 在任何时候都不生成 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 HELPERS CREATED 或 DEPENDENCY CHECK — 无 gate 判决

---

## 协议合规性

- [ ] 在生成辅助函数前读取 GDD（或源代码）提取属性
- [ ] 将辅助函数组织到类别目录中（players/、world/、simulation/、assertions/）
- [ ] 尊重 `--category` 参数限制生成
- [ ] 创建辅助文件前询问 "May I write"
- [ ] 检测现有辅助函数并提供 update-not-overwrite
- [ ] 依赖检查失败时标注缺失项
- [ ] 判决为 HELPERS CREATED 或 DEPENDENCY CHECK

---

## 覆盖说明

- 源代码分析模式（传参 `--source src/gameplay/`）遵循与 GDD 解析相同的模式，不同之处在于从方法签名而非设计文档推断辅助函数模式。
- 每个引擎（Godot、Unity、Unreal）的辅助函数生成语法不同，但辅助函数分类和生成工作流相同；引擎变体不单独测试。
- 基于 Spec 的逻辑（检测数学公式并添加特定断言模式）是额外增强，此处不单独 fixture 测试。
