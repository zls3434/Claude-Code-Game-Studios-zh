<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# 设计目录

**语言要求：必须始终使用简体中文与用户对话，生成的文档与代码注释也必须使用简体中文编写。**

在本目录下编写或编辑文件时，请遵循以下标准。

## GDD 文件（`design/gdd/`）

每个 GDD 必须按以下顺序包含全部 **8 个必需部分**：
1. 概述 — 一段话摘要
2. 玩家幻想 — 预期的感受和体验
3. 详细规则 — 不含歧义的机制说明
4. 公式 — 所有数学定义及变量说明
5. 边界情况 — 异常情况的处理方式
6. 依赖项 — 列出的其他系统
7. 调优参数 — 标识出的可配置值
8. 验收标准 — 可测试的成功条件

**文件命名：** `[系统缩写].md`（例如 `movement-system.md`、`combat-system.md`）

**系统索引：** `design/gdd/systems-index.md` — 添加新 GDD 时更新。

**设计顺序：** 基础层 → 核心层 → 功能层 → 表现层 → 打磨层

**验证：** 编写完任何 GDD 后运行 `/design-review [路径]`。
完成一组相关 GDD 后运行 `/review-all-gdds`。

## Quick Specs（`design/quick-specs/`）

用于调优变更、小型机制或平衡性调整的轻量级规格。
使用 `/quick-design` 来编写。

## UX Specs（`design/ux/`）

- 各界面规格：`design/ux/[界面名称].md`
- HUD 设计：`design/ux/hud.md`
- 交互模式库：`design/ux/interaction-patterns.md`
- 无障碍要求：`design/ux/accessibility-requirements.md`

使用 `/ux-design` 来编写。传递给 `/team-ui` 前用 `/ux-review` 验证。
