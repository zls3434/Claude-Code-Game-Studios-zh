<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
---
paths:
  - "src/gameplay/**"
---

# 游戏性代码规范

- 所有游戏性数值必须来自外部配置/数据文件，绝不可硬编码
- 所有依赖时间的计算必须使用 delta time（确保帧率无关）
- 禁止直接引用 UI 代码 —— 使用事件/信号进行跨系统通信
- 每个游戏性系统必须实现明确的接口
- 状态机必须具有显式的转换表，并附有文档化的状态说明
- 为所有游戏性逻辑编写单元测试 —— 将逻辑与表现分离
- 在代码注释中记录每个功能实现了哪个设计文档
- 不允许多例模式的游戏状态 —— 使用依赖注入

## 示例

**正确**（数据驱动）：

```gdscript
var damage: float = config.get_value("combat", "base_damage", 10.0)
var speed: float = stats_resource.movement_speed * delta
```

**错误**（硬编码）：

```gdscript
var damage: float = 25.0   # 违规：硬编码游戏性数值
var speed: float = 5.0      # 违规：非来自配置，未使用 delta
```
