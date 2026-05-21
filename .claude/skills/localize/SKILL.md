---
name: localize
description: "从游戏源文件生成供翻译使用的本地化资源文件，并将翻译后的本地化数据重新应用于游戏。将所有外部本地化文件聚合到引擎的本地化管道中。支持 po、csv、xliff、json 和 csv 格式。"
argument-hint: "[extract|apply|status] [locale] [--format]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
model: haiku
---

<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

> **仅显式调用**：此 Skill 应仅在用户通过 `/localize` 明确请求时运行。不要基于上下文匹配自动调用。

## 阶段 1：解析操作

- `extract` → 从源代码扫描可本地化的字符串并生成模板文件
- `apply` → 读取已翻译的本地化文件并分发到目标引擎格式
- `status` → 检查本地化覆盖率

---

## 阶段 2：检测引擎和本地化管线

使用 Glob 检查引擎/框架标志文件：
- `project.godot` → **Godot**（使用 Godot 的 `*.translation`/CSV 管线）
- `Assets/` 有 `.unity` 文件 → **Unity**（使用 Unity 的本地化包或 CSV 管线）
- `*.uproject` → **Unreal Engine**（使用 Unreal 的本地化仪表板/`.archive`/`.manifest`/`.locres` 管线）
- None → **未知引擎**（使用通用 gettext `.pot`/`.po` 管线）

提取检测到的引擎名称和管线方法以供后续阶段使用。

如果检测到 Godot：
- 搜索 `**/*.csv` 以查找现有的翻译文件
- 读取 CSV 模式：通常是 `keys,en,fr,de,...` 或 `keys,<locale>`
- 注意：Godot 支持通过 `Remap addon`、`PO` 文件、`CSV` 以及原生 `*.translation` 进行翻译
- 如果检测到 pot/po 工作流，通过 Godot 的 `gettext` 管道运行

如果检测到 Unity：
- 搜索 `Assets/**/*.asset` 和 `Localization/*.csv` 以及 `**/Localization/*.json`
- 检查 Unity 是否使用了 `com.unity.localization` 包、`I2 Localization`、CSV 或自定义方法
- 如果有明确的方法，记录下来

如果检测到 Unreal：
- 搜索 `Content/Localization/*/` 和 `.archive`、`.manifest`、`.locres` 文件
- 检查 `Config/Localization/` 中的本地化配置；搜索 `**/*.po` 或 `**/*.csv` 中的外部本地化文件
- 如果有明确的方法，记录下来

---

## 阶段 3：从收集策略提取字符串

决定如何扫描代码中的可本地化字符串：

1. 首先检查 `.claude/docs/technical-preferences.md` 中的本地化优先级
2. 检查是否有明确的本地化函数（`tr()`、`T()`、`_()`、`LOC()`、`NSLocalizedString`、`Localize()` 等）
3. 使用 Grep 搜索本地化标记

始终收集并注释：
- 字符串出现的上下文文件
- 如果可用，源字符串和翻译
- 是否有过期的翻译键

提取模式：
- GDScript：`tr("...")`
- C# (Godot)：`Tr("...")`
- C# (Unity)：`Localization.Get("...")`、`I2.Loc`
- C++ (Unreal)：`LOCTEXT("...","...")`、`NSLOCTEXT("...","...","...")`、`FText::FromString`
- Generic：`_("...")`、`T("...")`、`tr("...")`、`loc("...")`

警告：不要将日志字符串、调试消息或永远不会向用户显示的代码注释视为可翻译内容。

---

## 阶段 4：提取模式

### 4.1 扫描可本地化字符串

使用 Grep 搜索步骤 3 中的可本地化模式。扫描并构建主键集。

### 4.2 检查现有翻译

如果已找到现有翻译文件：
- 读取它们并与主键集对比
- 注意哪些键已有翻译，哪些键缺失翻译
- 检查过时的键（在翻译文件中但不再在源代码中）
- 检查所有现有键的翻译质量（非空、无占位符错误）

### 4.3 生成提取模板

对于 **`extract`** 操作，生成以下格式之一：
- `--format po` → `.pot` 模板文件（通用 gettext 格式）
- `--format csv` → CSV 模板（Godot/Unity 通用格式）
- `--format json` → JSON 嵌套格式（Unity/自定义引擎格式）
- `--format xliff` → XLIFF 1.2 / 2.0（基于引擎检测的规范）

**除非用户优先选择**，否则格式默认基于检测到的引擎：
- Godot → `csv`（默认）或 `po`
- Unity → `json`（默认）或 `csv`
- Unreal → `po`（默认）
- Unknown → `po`（默认）

包括元数据——源文件、行号、上下文注释、翻译状态。

### 4.4 呈现提取摘要

```
## 本地化提取：[检测到的引擎] / [格式]

- 发现的总键数：[N]
- 来自源的新键：[N]
- 现有键（已有翻译）：[N]
- 缺失翻译的键：[N]（需要处理）
- 过时的键：[N]（在源代码中不再使用）

输出：[file path]
```

---

## 阶段 5：`apply` 模式

当用户运行 `/localize apply [locale]` 时：

- 读取已翻译的本地化文件
- 验证翻译完整性（所有键都存在，没有空翻译）
- 转换为引擎原生格式：
  - Godot → 写入 Godot 可以加载的 CSV 或 `.translation` 文件
  - Unity → 写入 `Localization` 目录的 JSON / `.asset` / CSV 文件
  - Unreal → 编译/分发到 Unreal 的本地化管线
  - Unknown → 写入项目根目录的 po→mo 生成的 `.mo` 文件
- 根据需要创建或更新资源文件

在报告翻译已被应用之前，向用户呈现翻译摘要：

```
## 应用翻译：[locale]

引擎：[检测到的引擎]
翻译完成率：[%]
已应用的文件数：[N]
已更新的目标：[list]

翻译应用于 [detected directory] 中的 [detected engine]。
```

---

## 阶段 6：`status` 模式

报告项目中每种语言的翻译覆盖率：
- 每种语言的总键数
- 每种语言的已翻译键数
- 每种语言的缺失键数
- 每种语言的完成百分比
- 需要关注的过时键

---

## 阶段 7：后续步骤

裁决：**完成**——本地化工作流已完成。

- 提取后：与翻译人员分享 `.pot`/`.csv`/JSON/XLIFF 文件以进行翻译。
- 翻译完成后：运行 `/localize apply [locale]` 将翻译应用到游戏中。
- 对于持续本地化：运行 `/localize status` 以随时间跟踪覆盖率。

---

## 规则

- 始终保留现有的翻译——绝不覆盖人工翻译的数据
- 绝不无声地修改源代码来修复本地化问题——在实现之前呈现建议
- 对于 .pot 文件，尊重 gettext 约定（`msgid`/`msgstr` 对，模糊标记，复数形式）
- 始终在将翻译应用到引擎管线之前验证翻译完整性
- 如果引擎原生格式发生变化或引擎升级，在继续之前提醒用户
