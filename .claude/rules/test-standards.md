<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
---
paths:
  - "tests/**"
---

# 测试标准

- 测试命名：遵循 `test_[系统]_[场景]_[预期结果]` 模式
- 每个测试必须具有清晰的 Arrange（准备）/Act（执行）/Assert（断言）结构
- 单元测试不得依赖外部状态（文件系统、网络、数据库）
- 集成测试必须在执行后清理自身
- 性能测试必须指定可接受的阈值，超出阈值则失败
- 测试数据必须在测试内部或专用 fixtures 中定义，绝不可共享可变状态
- 对外部依赖进行 Mock —— 测试应快速且确定
- 每个 Bug 修复必须包含一个能捕获该原始 Bug 的回归测试

## 示例

**正确**（恰当的命名 + Arrange/Act/Assert）：

```gdscript
func test_health_system_take_damage_reduces_health() -> void:
    # Arrange
    var health := HealthComponent.new()
    health.max_health = 100
    health.current_health = 100

    # Act
    health.take_damage(25)

    # Assert
    assert_eq(health.current_health, 75)
```

**错误**：

```gdscript
func test1() -> void:  # 违规：无描述性名称
    var h := HealthComponent.new()
    h.take_damage(25)  # 违规：无 Arrange 步骤，无明确 Assert
    assert_true(h.current_health < 100)  # 违规：断言不够精确
```
