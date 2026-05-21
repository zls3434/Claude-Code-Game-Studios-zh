<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 4.5 — 破坏性变更

> 最后验证：2026-02-13
> 来源：[官方 Godot 4.5 迁移指南](https://docs.godotengine.org/en/4.5/about/upgrading_to_godot_4.5.html)

本文件记录模型训练数据之外引入的 **破坏性 API 变更**。
Agent 在编写任何 Godot 代码前应查阅此文件。

---

## 高风险变更（可能影响大多数代码）

| 变更 | 旧语法 | 新语法 | 影响 |
|--------|-----------|-----------|--------|
| `get_script()` 返回类型 | 返回 `Variant` | 现在返回 `Script` | 强制类型转换可能失败 |
| `Node.process_mode` 枚举 | `PROCESS_MODE_INHERIT` | `PROCESS_MODE_INHERIT`（不变） | 验证值未被硬编码 |
| `PackedScene.instantiate()` 返回类型 | 返回 `Variant` | 现在返回 `Node` | 显式 `as` 转换不再必需 |

## 中风险变更（可能影响专门代码）

| 变更 | 旧语法 | 新语法 | 影响 |
|--------|-----------|-----------|--------|
| `InputMap.action_erase_event()` | 接受 `InputEvent` | 现在需要 `InputEventKey` 的 `physical_keycode` | 检查键盘映射修改 |
| `FileAccess.open()` | `FileAccess.READ` | 枚举未变，但在构建解析器中弃用了 `COMPRESSION_FASTLZ` | 代码搜索 `READ_WRITE` 使用 |
| `ResourceLoader.load()` 线程安全 | 非线程安全 | `threaded = true` 默认值在后台线程中为单线程 | 使用 `ResourceLoader.load_threaded_request()` |

## 低风险变更（小众使用）

| 变更 | 旧语法 | 新语法 | 影响 |
|--------|-----------|-----------|--------|
| `RenderingDevice.draw_list_begin()` | 接受 `RID` | 现在需要 `RenderingDevice` | 仅 Vulkan compute shader 代码 |
| `TextServer.format_number()` | 默认 `language=""` | 现在需要明确 `language` 参数 | 检查数字格式化代码 |

---

## 验证清单

在升级到 Godot 4.5 之后：

- [ ] `rg "get_script\(\)"` — 验证返回值类型
- [ ] `rg "instantiate\(\)"` — 移除不必要的 `as` 转换
- [ ] `rg "action_erase_event"` — 检查 `physical_keycode` 参数
- [ ] `rg "format_number"` — 添加 `language` 参数
- [ ] 运行完整测试套件
- [ ] 在目标设备上测试
