<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
---
paths:
  - "src/core/**"
---

# 引擎代码规范

- 热路径（更新循环、渲染、物理）中零内存分配 —— 预分配、池化、复用
- 所有引擎 API 必须是线程安全的，或明确标注为仅限单线程使用
- 每次优化前后都要做性能剖析 —— 记录实测数据
- 引擎代码绝不可依赖游戏性代码（严格的依赖方向：引擎 ← 游戏性）
- 每个公开 API 必须在其文档注释中包含使用示例
- 对公开接口的更改需要设定弃用期和迁移指南
- 对所有资源使用 RAII / 确定性清理
- 所有引擎系统必须支持优雅降级
- 在编写引擎 API 代码之前，查阅 `docs/engine-reference/` 获取当前引擎版本，并根据参考文档验证 API

## 示例

**正确**（热路径零分配）：

```gdscript
# 每帧复用的预分配数组
var _nearby_cache: Array[Node3D] = []

func _physics_process(delta: float) -> void:
    _nearby_cache.clear()  # 复用，不重新分配
    _spatial_grid.query_radius(position, radius, _nearby_cache)
```

**错误**（热路径中分配）：

```gdscript
func _physics_process(delta: float) -> void:
    var nearby: Array[Node3D] = []  # 违规：每帧都分配
    nearby = get_tree().get_nodes_in_group("enemies")  # 违规：每帧都查询场景树
```
