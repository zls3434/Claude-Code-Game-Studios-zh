<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# 规则参考

`.claude/rules/` 中的规则在编辑匹配路径的文件时自动执行：

| 规则文件 | 路径匹配模式 | 强制执行内容 |
| ---- | ---- | ---- |
| `gameplay-code.md` | `src/gameplay/**` | 数据驱动数值、delta time、无 UI 引用 |
| `engine-code.md` | `src/core/**` | 热路径零分配、线程安全、API 稳定性 |
| `ai-code.md` | `src/ai/**` | 性能预算、可调试性、数据驱动参数 |
| `network-code.md` | `src/networking/**` | 服务器权威、版本化消息、安全性 |
| `ui-code.md` | `src/ui/**` | 无游戏状态所有权、支持本地化、无障碍 |
| `design-docs.md` | `design/gdd/**` | 必需的 8 个章节、公式格式、边界情况 |
| `narrative.md` | `design/narrative/**` | 背景一致性、角色声音、正典层级 |
| `data-files.md` | `assets/data/**` | JSON 有效性、命名约定、Schema 规则 |
| `test-standards.md` | `tests/**` | 测试命名、覆盖率要求、Fixture 模式 |
| `prototype-code.md` | `prototypes/**` | 放宽标准、必须含 README、需文档化假设 |
| `shader-code.md` | `assets/shaders/**` | 命名约定、性能目标、跨平台规则 |
