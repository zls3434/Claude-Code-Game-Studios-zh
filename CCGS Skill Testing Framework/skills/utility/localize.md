<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/localize

## Skill 摘要

`/localize` 管理完整的本地化流水线：它从源文件中提取所有面向玩家的字符串，管理 `assets/localization/` 中的翻译文件，并验证所有语言环境文件的完整性。对于新语言，它创建一个包含所有当前字符串键和空值的语言环境文件骨架。对于现有语言环境文件，它生成差异报告，显示新增、删除和更改的键。

翻译文件在经过 "May I write" 询问后写入 `assets/localization/[locale-code].csv`（或引擎适用的格式）。不适用 director gate。判决：LOCALIZATION COMPLETE（所有语言环境均完整）或 GAPS FOUND（至少一个语言环境缺少字符串键）。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：LOCALIZATION COMPLETE、GAPS FOUND
- [ ] 在写入语言环境文件前包含 "May I write" 协作协议语言
- [ ] 有下一步交接（例如，将语言环境骨架发送给翻译人员）

---

## Director Gate 检查

无。`/localize` 是一个流水线工具。不适用 director gate。本地化主管 agent 可单独审查，但不在本 skill 内调用。

---

## 测试用例

### 用例 1：新语言 — 字符串提取并创建语言环境骨架

**Fixture：**
- `src/` 中的源代码包含面向玩家的字符串（UI 文本、教程消息）
- 现有语言环境：`assets/localization/en.csv`
- 不存在法语语言环境

**输入：** `/localize fr`

**预期行为：**
1. Skill 从源文件中提取所有面向玩家的字符串
2. Skill 在 `en.csv` 中找到相同字符串作为参考
3. Skill 生成包含所有字符串键和空值的 `fr.csv` 骨架
4. Skill 询问 "May I write to `assets/localization/fr.csv`?"
5. 批准后写入文件；判决为 GAPS FOUND（文件已创建但值为空）
6. Skill 备注："fr.csv created — send to translator to fill values"

**断言：**
- [ ] `en.csv` 中的所有字符串键均出现在 `fr.csv` 中
- [ ] `fr.csv` 中的所有值均为空（非从英文复制）
- [ ] 创建文件前询问 "May I write"
- [ ] 判决为 GAPS FOUND（文件已创建但未翻译）

---

### 用例 2：现有语言环境差异 — 列出新增、删除和更改

**Fixture：**
- `assets/localization/fr.csv` 存在，包含 20 个已翻译的字符串键
- 源代码已更改：新增 3 个字符串，删除 1 个字符串，2 个字符串的英文源文本已更改

**输入：** `/localize fr`

**预期行为：**
1. Skill 从源代码中提取当前字符串
2. Skill 与现有 `fr.csv` 进行差异对比
3. Skill 生成差异报告：
   - 3 个新键（需要翻译 — 在 fr.csv 中列为空）
   - 1 个已删除键（标记为 obsolete — 建议移除）
   - 2 个已更改键（英文源已更改 — 法文可能需要更新，已标记）
4. Skill 询问 "May I update `assets/localization/fr.csv`?"
5. 更新的文件添加了新的空键，标记了废弃键；判决为 GAPS FOUND

**断言：**
- [ ] 新键在更新文件中显示为空值（非自动翻译）
- [ ] 已删除键被标记为 obsolete（非静默删除）
- [ ] 更改的源字符串被标记供翻译审查
- [ ] 判决为 GAPS FOUND（存在新的空键）

---

### 用例 3：一个语言环境缺少字符串 — GAPS FOUND，附缺失键列表

**Fixture：**
- 存在 3 个语言环境文件：`en.csv`、`fr.csv`、`de.csv`
- `de.csv` 缺少 4 个同时存在于 `en.csv` 和 `fr.csv` 的键

**输入：** `/localize`

**预期行为：**
1. Skill 读取全部 3 个语言环境文件并进行键交叉引用
2. `de.csv` 缺少 4 个键
3. Skill 生成 GAPS FOUND 报告，按语言环境列出 4 个缺失键："de.csv missing: [key1], [key2], [key3], [key4]"
4. Skill 提供将缺失键以空值添加到 `de.csv` 的选项
5. 批准后：文件更新；判决仍为 GAPS FOUND（值仍为空）

**断言：**
- [ ] 缺失键被明确列出（不仅仅是计数）
- [ ] 缺失键归属于特定的语言环境文件
- [ ] 判决为 GAPS FOUND（非 LOCALIZATION COMPLETE）
- [ ] 缺失键以空值添加（非从英文自动翻译）

---

### 用例 4：翻译文件有语法错误 — 错误附行号引用

**Fixture：**
- `assets/localization/fr.csv` 在第 47 行有格式错误的行（缺少引号闭合）

**输入：** `/localize fr`

**预期行为：**
1. Skill 读取 `fr.csv` 并在第 47 行遇到解析错误
2. Skill 输出："Parse error in fr.csv at line 47: [error detail]"
3. Skill 在错误修复前无法进行差异或验证文件
4. Skill 不尝试覆盖或自动修复格式错误的文件
5. Skill 建议手动修复文件并重新运行 `/localize`

**断言：**
- [ ] 错误消息包含行号（line 47）
- [ ] 错误详情描述了解析错误的性质
- [ ] Skill 不覆盖或修改格式错误的文件
- [ ] 建议手动修复 + 重新运行作为补救措施

---

### 用例 5：Director Gate 检查 — 无 gate；localization 是一个流水线工具

**Fixture：**
- 包含面向玩家字符串的源代码

**输入：** `/localize fr`

**预期行为：**
1. Skill 提取字符串并管理语言环境文件
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 LOCALIZATION COMPLETE 或 GAPS FOUND — 无 gate 判决

---

## 协议合规性

- [ ] 在操作语言环境文件之前从源代码中提取字符串
- [ ] 创建新语言环境文件时所有键为空值（非自动翻译）
- [ ] 对现有语言环境文件与当前源字符串进行差异对比
- [ ] 按语言环境和键名称标记缺失键
- [ ] 创建或更新任何语言环境文件前询问 "May I write"
- [ ] 判决为 LOCALIZATION COMPLETE（所有语言环境完全翻译）或 GAPS FOUND

---

## 覆盖说明

- LOCALIZATION COMPLETE 仅在所有语言环境文件包含全部非空值键时才可实现；新语言骨架创建始终导致 GAPS FOUND。
- 引擎特定的语言环境格式（Godot `.translation`、Unity `.po` 文件）由 skill 正文处理；`.csv` 在测试中用作规范格式。
- 源字符串以极高频率更改的情况（新 UI 文本的持续集成）不测试；差异逻辑可处理此情况。
