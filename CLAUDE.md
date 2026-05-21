<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Claude Code Game Studios —— 游戏工作室 Agent 架构

## 语言要求

**必须始终使用简体中文与用户对话，生成的文档与代码注释也必须使用简体中文编写。**



通过 49 个协调的 Claude Code 子 Agent 管理独立游戏开发。
每个 Agent 负责一个特定领域，确保关注点分离和质量把控。

## 技术栈

- **引擎**：[选择：Godot 4 / Unity / Unreal Engine 5]
- **语言**：[选择：GDScript / C# / C++ / Blueprint]
- **版本控制**：Git，采用基于主干的开发模式
- **构建系统**：[选择引擎后指定]
- **资产管线**：[选择引擎后指定]

> **注意**：存在针对 Godot、Unity 和 Unreal 的引擎专业 Agent，并配有专属的子专家。请使用与您引擎匹配的集合。

## 项目结构

@.claude/docs/directory-structure.md

## 引擎版本参考

@docs/engine-reference/godot/VERSION.md

## 技术偏好

@.claude/docs/technical-preferences.md

## 协调规则

@.claude/docs/coordination-rules.md

## 协作协议

**用户驱动的协作，而非自主执行。**
每个任务都遵循：**提问 → 选项 → 决策 → 草稿 → 审批**

- Agent 在使用 Write/Edit 工具前必须询问："我可以将此写入 [文件路径] 吗？"
- Agent 在请求审批前必须展示草稿或摘要
- 多文件修改需要针对完整变更集的明确审批
- 未经用户指示不得进行提交

完整协议和示例请参见 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`。

> **首次使用？** 如果项目尚未配置引擎且没有游戏概念，
> 请运行 `/start` 开始引导式上手流程。

## 编码规范

@.claude/docs/coding-standards.md

## 上下文管理

@.claude/docs/context-management.md
