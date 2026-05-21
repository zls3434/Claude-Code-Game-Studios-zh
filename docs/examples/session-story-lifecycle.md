<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 示例会话：完整故事生命周期 —— /story-readiness → 实现 → /story-done

**上下文：** 独立开发者，制作中期 sprint。移动系统的 GDD 和架构已经完成。`/create-stories` 已生成了一个移动核心实现的故事。

**初始状态：**
- `design/gdd/movement-system.md` —— 完整，全部 8 节
- `docs/architecture/movement-adr-001.md` —— 状态：Accepted
- `production/sprints/sprint-03.md` —— 积压中列出了 STORY-MOV-001
- `production/stories/STORY-MOV-001.md` —— 存在但尚未验证
- 尚无实现代码

**会话时长：** 约 50 分钟
**轮次：** 13
**结果：** 故事已验证就绪、已实现、已通过 `/story-done` 验证完成

---

## 阶段 1：故事就绪检查

### 第 1 轮：用户运行就绪检查

**用户：**
> /story-readiness production/stories/STORY-MOV-001.md

### 第 2 轮：Agent 验证故事

**Agent（通过 /story-readiness）：**
> 正在读取 `production/stories/STORY-MOV-001.md`……
>
> **STORY-MOV-001：实现带地形修正器的 CharacterBody2D 移动**
>
> 运行 4 项验证检查：
>
> **1. 设计完整性**
> - 引用的 GDD：`design/gdd/movement-system.md` ✅
> - GDD 节覆盖：详细规则 ✅，公式 ✅，边界情况 ✅
> - 嵌入的 TR-ID：TR-MOV-001 到 TR-MOV-008 ✅
>
> **2. 架构完整性**
> - 引用的 ADR：`docs/architecture/movement-adr-001.md` ✅
> - ADR 状态：**Accepted** ✅ *（如果为 Proposed 则会被 BLOCKED）*
> - 故事中的 Control Manifest 版本：`2026-03-10` —— 当前 manifest 为 `2026-03-10` ✅
>
> **3. 范围清晰度**
> - 验收标准：9 条，全部可度量 ✅
> - 已列出超出范围项：游泳、攀爬 ✅
> - 发现的歧义：**1 个**
>   - ⚠️ 故事说"翻滚方向跟随上一个输入方向"，但 GDD 说"朝移动方向翻滚"—— 当玩家停止后立即翻滚时这两者会冲突。在拾取故事前澄清。
>
> **4. 完成定义**
> - 需要测试：公式函数的单元测试 ✅
> - 集成信号：`on_stamina_event` 必须正确触发 ✅
>
> ---
> **判定：NEEDS WORK**
>
> 有一个歧义必须在实现开始前解决。你想现在解决它，以便我可以标记此故事为就绪吗？

### 第 3 轮：用户解决歧义

**用户：**
> 翻滚使用上一个移动方向。如果玩家站立不动，翻滚改为使用面朝方向。

### 第 4 轮：Agent 更新故事

**Agent：**
> 正在更新故事的详细规则节：
>
> > 翻滚方向：上一个移动方向。如果在翻滚输入时速度为零，翻滚使用当前面朝方向。
>
> 我可以将此写入 `production/stories/STORY-MOV-001.md` 并将状态设置为 `ready-for-dev` 吗？

**用户：**
> 可以

**Agent 写入更新。故事状态：`ready-for-dev`。**

> **判定：READY**
> 故事已可进入实现。准备好构建时即可拾取。

---

## 阶段 2：实现

### 第 5 轮：用户开始实现

**用户：**
> 让我们实现 STORY-MOV-001。我准备好开始编码了。

### 第 6 轮：Agent 读取故事和 ADR

**Agent（gameplay-programmer）：**
> 正在读取 `production/stories/STORY-MOV-001.md`、`design/gdd/movement-system.md` 和 `docs/architecture/movement-adr-001.md`……
>
> **架构（来自 ADR-001）：**
> - `MovementComponent.gd` —— 附加到玩家场景，非单例
> - 地形修正器查找通过 `TerrainLayer.get_modifier(tile_position)` 辅助函数
> - 耐力事件通过信号（非直接调用 StaminaSystem）
>
> **我提议的文件结构：**
> ```
> src/gameplay/movement/
>   movement_component.gd       # CharacterBody2D 逻辑、状态机
>   terrain_modifier_table.gd   # 常量表：terrain_type -> {speed_mod, drain_mod}
> tests/unit/
>   test_movement_formulas.gd   # 速度/消耗计算的单元测试
> ```
>
> 我可以按此结构继续吗？

**用户：**
> 可以

### 第 7 轮：Agent 实现并展示关键代码

**Agent：**
> 正在实现 `movement_component.gd`。在写入文件之前，供你审查的关键摘录：
>
> ```gdscript
> class_name MovementComponent
> extends Node
>
> signal stamina_event(type: String, amount: float)
>
> @export var base_walk_speed: float = 120.0
> @export var run_multiplier: float = 1.7
> @export var stamina_drain_walk: float = 2.0
> @export var stamina_drain_run: float = 6.0
> @export var stamina_cost_roll: float = 15.0
>
> var _is_carrying_heavy: bool = false
>
> func _physics_process(delta: float) -> void:
>     var terrain_mod := _get_terrain_modifier()
>     var effective_speed := _calculate_speed(terrain_mod)
>     # ...
> ```
>
> 所有值都是 `@export` —— 无硬编码。这是你想要的方向吗？

**用户：**
> 看起来不错。写吧。

### 第 8–9 轮：Agent 写入文件并测试

**Agent 写入：**
- `src/gameplay/movement/movement_component.gd`
- `src/gameplay/movement/terrain_modifier_table.gd`
- `tests/unit/test_movement_formulas.gd`

**Agent：**
> 文件已写入。正在运行可用的 linting 检查……
>
> 无错误。测试文件已创建，包含 6 个单元测试，覆盖：
> - 行走速度公式（3 种地形类型）
> - 奔跑速度公式
> - 耐力消耗计算
> - 翻滚耐力消耗（含零速度边界情况和不含零速度边界情况）
>
> 需要手动测试：无敌帧、坡度阻止、地形集成（需要运行场景）。

---

## 阶段 3：故事完成

### 第 10 轮：用户手动测试并运行 /story-done

**用户：**
> 我在场景中测试过了 —— 一切正常。/story-done production/stories/STORY-MOV-001.md

### 第 11 轮：Agent 运行完成审查

**Agent（通过 /story-done）：**
> 正在读取故事、GDD、ADR……
>
> **阶段 1：故事已定位** ✅ `production/stories/STORY-MOV-001.md`
>
> **阶段 2：验收标准验证**
>
> | # | 标准 | 验证方式 | 状态 |
> |---|-----------|--------------|--------|
> | 1 | 普通地面行走速度正确 | 自动：公式单元测试通过 | ✅ AUTO |
> | 2 | 奔跑速度正确 | 自动：公式单元测试通过 | ✅ AUTO |
> | 3 | 耐力为 0 时奔跑取消 | 手动：用户已确认 | ✅ MANUAL |
> | 4 | 翻滚无敌帧有效 | 手动：用户已确认 | ✅ MANUAL |
> | 5 | 地形修正器正确应用 | 手动：用户已确认 | ✅ MANUAL |
> | 6 | 重物携带禁用奔跑 | 自动：暂时无法测试（背包未集成） | ⏳ DEFERRED |
> | 7 | 耐力信号正确触发 | 自动：集成测试待定 | ⏳ DEFERRED |
> | 8 | 无硬编码值 | 自动：grep 魔法数字 → 找到 0 个 | ✅ AUTO |
> | 9 | 坡度 >45° 阻止移动 | 手动：用户已确认 | ✅ MANUAL |
>
> **阶段 3：GDD/ADR 偏差**
>
> 正在对照 TR-ID 扫描实现……
>
> - TR-MOV-001 到 TR-MOV-007：✅ 按规格实现
> - TR-MOV-008（重物携带信号）：⚠️ ADVISORY —— 推迟到背包集成故事。非偏差，只是当前无法验证。
>
> **阶段 4：Manifest 过期检查**
>
> 故事 Control Manifest 版本 `2026-03-10` 匹配当前 manifest `2026-03-10`。✅
>
> **阶段 5：代码审查提示**
>
> 建议在标记完成前运行 `/code-review src/gameplay/movement/`。非阻塞。
>
> ---
> **完成报告：COMPLETE WITH NOTES**
>
> 故事已完成。有两条标准延至背包集成 —— 记录为延后，非阻塞。
>
> 我可以将故事状态更新为 `Status: Complete` 并添加完成备注，并更新 `production/sprint-status.yaml` 吗？

**用户：**
> 可以

### 第 12 轮：Agent 关闭故事

**Agent 写入：**
- 故事 `Status: Complete` + 完成备注（已记录延期标准）
- `production/sprint-status.yaml` —— STORY-MOV-001 设为 `done`

**Agent：**
> STORY-MOV-001 已关闭。
>
> **已记录延期标准**（将在背包集成故事中自动浮现）：
> - 重物携带禁用奔跑（需要背包信号）
> - 耐力信号集成测试（需要耐力系统）
>
> **Sprint 中下一个就绪的故事：**
> - STORY-MOV-002：耐力系统 —— 这是逻辑上接下来的故事（下游依赖现已解锁）
> - STORY-HUD-001：移动 HUD 指示器 —— 也已解锁
>
> 对你接下来拾取的故事运行 `/story-readiness`。

---

## 本示例展示了什么

- **就绪门禁捕获真实问题**：如果不使用 `/story-readiness`，翻滚方向歧义会在实现后期才被迫做出决策
- **ADR 状态是硬门禁**：如果 `movement-adr-001.md` 是 `Proposed` 而不是 `Accepted`，故事会被 `BLOCKED`，实现不会开始
- **延期标准**：并非每条验收标准都能在故事关闭时验证 —— `/story-done` 跟踪延期项而非阻塞完成
- **TR-ID 引用**：故事存储 `TR-MOV-001` ID，而非引用的 GDD 文本 —— 当 GDD 文字日后清理时避免产生虚假偏差标记
- **sprint-status.yaml**：sprint 状态的单一真实来源，由 `/story-done` 更新，由 `/sprint-status` 读取
- **Manifest 版本检查**：确保故事的实现指导未偏离当前架构决策
