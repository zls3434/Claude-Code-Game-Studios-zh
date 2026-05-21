---
name: skill-improve
description: "使用测试-修复-重测循环改进一个 Skill。运行静态检查，提出针对性修复，重写 Skill，重新测试，根据分数变化决定保留或回滚。"
argument-hint: "[skill-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 改进

对单个 Skill 运行改进循环：
测试 → 修复 → 重测 → 保留或回滚。

---

## 第 1 阶段：解析参数

从第一个参数读取 Skill 名称。如果缺失，输出用法并停止：

```
用法：/skill-improve [skill-name]
示例：/skill-improve tech-debt
```

验证 `.claude/skills/[name]/SKILL.md` 是否存在。如果不存在，停止并提示："Skill '[name]' 未找到。"

---

## 第 2 阶段：基线测试

运行 `/skill-test static [name]` 并记录基线分数：
- FAIL 计数
- WARN 计数
- 哪些具体检查失败（检查 1–7）

向用户展示：
```
静态基线：   [N] 个失败，[M] 个警告
失败项：检查 4（无写入前询问）、检查 5（无后续交接）
```

如果基线为 0 个 FAIL 和 0 个 WARN，记录下来并进入第 2b 阶段。

### 第 2b 阶段：分类基线

在 `CCGS Skill Testing Framework/catalog.yaml` 中查找 Skill 的 `category:` 字段。

如果未找到 `category:` 字段，显示："分类：尚未分配 — 跳过分类检查。"并跳至第 3 阶段。

如果找到分类，运行 `/skill-test category [name]` 并记录分类基线：
- FAIL 计数
- WARN 计数
- 哪些具体分类评分指标失败

向用户展示：
```
分类基线：[N] 个失败，[M] 个警告（[category] 评分标准）
```

如果静态和分类基线**均为** 0 个 FAIL 和 0 个 WARN，停止："此 Skill 已通过所有静态和分类检查。无需改进。"

---

## 第 3 阶段：诊断

完整读取 Skill 文件：`.claude/skills/[name]/SKILL.md`。

对于每个失败或警告的**静态**检查，识别确切的缺陷：

- **检查 1 失败** → 缺少哪个 frontmatter 字段
- **检查 2 失败** → 找到了多少个阶段 vs. 最低要求
- **检查 3 失败** → Skill 正文中没有任何判定关键字
- **检查 4 失败** → allowed-tools 包含 Write 或 Edit 但没有写入前询问的语言
- **检查 5 警告** → 末尾没有后续步骤部分
- **检查 6 警告** → 设置了 `context: fork` 但发现的阶段少于 5 个
- **检查 7 警告** → argument-hint 为空或不匹配已文档化的模式

对于每个失败或警告的**分类**检查（如果在第 2b 阶段分配了分类），识别 Skill 文本中的确切缺陷。例如：
- 如果 G2 失败（gate 模式，未生成完整的主管）：Skill 正文从未引用所有 4 个 PHASE-GATE 主管提示
- 如果 A2 失败（authoring，没有每节的写入前询问）：Skill 仅在末尾询问一次，而非在每节写入之前
- 如果 T3 失败（team，BLOCKED 未呈现）：Skill 在被阻塞 Agent 上未停止依赖工作

在提出任何更改之前，向用户展示完整的综合诊断。

---

## 第 4 阶段：提出修复方案

为每个失败和警告编写针对性修复。将建议的更改展示为清晰标记的前后对比块。仅更改失败的部分——不要重写通过的部分。

询问："我可以将此改进版本写入 `.claude/skills/[name]/SKILL.md` 吗？"

如果用户拒绝，在此停止。

---

## 第 5 阶段：写入并重测

记录 Skill 文件的当前内容（以备需要回滚时使用）。

将改进后的 Skill 写入 `.claude/skills/[name]/SKILL.md`。

重新运行 `/skill-test static [name]` 并记录新的静态分数。
如果分配了分类，也重新运行 `/skill-test category [name]` 并记录新的分类分数。

显示对比：
```
静态：   修复前 [N] 个失败，[M] 个警告  →  修复后 [N'] 个失败，[M'] 个警告
分类：   修复前 [N] 个失败，[M] 个警告  →  修复后 [N'] 个失败，[M'] 个警告（如适用）
综合变化：改善 / 无变化 / 变差
```

---

## 第 6 阶段：判定

计算综合失败总数：静态 FAIL + 分类 FAIL + 静态 WARN + 分类 WARN。

**如果综合分数改善（综合失败计数低于基准线）：**
报告："分数改善。内容已保留。"
展示每个维度修复内容的摘要。

**如果综合分数相同或更差：**
报告："综合分数未改善。"
展示变化内容以及为什么可能没有效果。
询问："我可以使用 git checkout 回滚 `.claude/skills/[name]/SKILL.md` 吗？"
如果同意：运行 `git checkout -- .claude/skills/[name]/SKILL.md`

---

## 第 7 阶段：后续步骤

- 运行 `/skill-test static all` 查找下一个有失败的 Skill。
- 运行 `/skill-improve [next-name]` 继续对另一个 Skill 的循环。
- 运行 `/skill-test audit` 查看整体覆盖率进度。
