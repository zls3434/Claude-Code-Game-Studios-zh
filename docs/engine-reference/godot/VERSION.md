<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 引擎版本

> 最后验证：2026-02-13
> Godot 官方文档 — https://docs.godotengine.org/en/stable/

## 锁定版本

**引擎：** Godot 4.5.1（稳定版）

当 LLM 知识截止日期早于引擎发布日期时，
引擎参考文件具有权威性。

Agent 调用任何引擎 API 时，应提供官方文档链接
以进行验证和深入阅读。

## 知识缺口窗口

| 项目 | 日期 |
|------|------|
| LLM 知识截止日期 | 2025 年 5 月 |
| Godot 4.5 发布 | 2025 年 6 月 |
| Godot 4.5.1 发布 | 2025 年 9 月 |

**缺口：** 从 2025 年 5 月发布以来的所有 Godot 更新均在 LLM 数据之外。
下面的参考文件记录了模型无法知晓的 API、最佳实践和破坏性更改。

## 参考文件

```
engine-reference/godot/
├── VERSION.md              ← 你在这里
├── breaking-changes.md     ← 从 4.4 以来的 API 破坏性变更
├── deprecated-apis.md       ← 被替换的旧 API
├── current-best-practices.md ← 不在模型数据中的新实践
└── modules/                ← 快速子系统参考
    ├── animation.md
    ├── audio.md
    ├── input.md
    ├── navigation.md
    ├── networking.md
    ├── physics.md
    └── rendering.md
```
