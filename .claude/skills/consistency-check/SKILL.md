---
name: consistency-check
description: "扫描所有 GDD 与实体注册表以检测跨文档不一致：同一实体有不同的属性值、同一物品有不同的数值、同一公式有不同的变量。Grep 优先的方法——先读取注册表，然后仅针对冲突的 GDD 部分进行定向搜索，而非完整读取文档。"
argument-hint: "[full | since-last-review | entity:<名称> | item:<名称>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---
<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 一致性检查

通过将所有 GDD 与实体注册表 (`design/registry/entities.yaml`) 进行比较，
来检测跨文档不一致。采用 Grep 优先的方法：
先读取一次注册表，然后仅针对提到已注册名称的 GDD 部分进行定向搜索——
无需完整读取文档，除非冲突需要深入调查。

**本 Skill 是写入时的安全网。** 它捕获 `/design-system` 的
逐节检查可能遗漏的内容，以及 `/review-all-gdds` 的整体审查
发现已晚的内容。

**何时运行：**
- 在编写每个新 GDD 之后（在移到下一个系统之前）
- 在 `/review-all-gdds` 之前（这样该 Skill 从干净的基线开始）
- 在 `/create-architecture` 之前（不一致会毒害下游 ADR）
- 按需运行：`/consistency-check entity:[名称]` 专门检查一个实体

**输出：** 冲突报告 + 可选的注册表修正

---

## 阶段 1：解析参数和加载注册表

**模式：**
- 无参数 / `full` — 检查所有注册条目与所有 GDD
- `since-last-review` — 仅检查自上次审查报告以来修改过的 GDD
- `entity:<名称>` — 在所有 GDD 中检查一个特定实体
- `item:<名称>` — 在所有 GDD 中检查一个特定物品

**加载注册表：**

```
Read path="design/registry/entities.yaml"
```

如果文件不存在或没有条目：
> "实体注册表为空。运行 `/design-system` 编写 GDD——注册表
> 在每个 GDD 完成后自动填充。目前没有需要检查的内容。"

停止并退出。

从注册表构建四个查找表：
- **entity_map**：`{ 名称 → { source, attributes, referenced_by } }`
- **item_map**：`{ 名称 → { source, value_gold, weight, ... } }`
- **formula_map**：`{ 名称 → { source, variables, output_range } }`
- **constant_map**：`{ 名称 → { source, value, unit } }`

统计总注册条目数。报告：
```
注册表已加载：[N] 个实体，[N] 个物品，[N] 个公式，[N] 个常量
范围：[full | since-last-review | entity:名称]
```

---

## 阶段 2：定位范围内的 GDD

```
Glob pattern="design/gdd/*.md"
```

排除：`game-concept.md`、`systems-index.md`、`game-pillars.md`——这些不是
系统 GDD。

对于 `since-last-review` 模式：
```bash
git log --name-only --pretty=format: -- design/gdd/ | grep "\.md$" | sort -u
```
限制到自最近的 `design/gdd/gdd-cross-review-*.md`
文件创建日期以来修改过的 GDD。

在扫描前报告范围内的 GDD 列表。

---

## 阶段 3：Grep 优先冲突扫描

对于每个已注册的条目，在所有范围内的 GDD 中 grep 搜索条目名称。
不要做完整读取——仅提取匹配行及其直接
上下文（-C 3 行）。

这是核心优化：不是读取 10 个 GDD × 每个 400 行
（4,000 行），而是 grep 50 个实体名称 × 10 个 GDD（50 次定向搜索，
每次命中约返回 ~10 行）。

### 3a：实体扫描

对于 entity_map 中的每个实体：

```
Grep pattern="[entity_name]" glob="design/gdd/*.md" output_mode="content" -C 3
```

对于每个 GDD 命中，提取实体名称附近提到的值：
- 任何数值属性（计数、成本、持续时间、范围、速率）
- 任何分类属性（类型、等级、类别）
- 任何派生值（总计、输出、结果）
- entity_map 中注册的任何其他属性

将提取的值与注册表条目进行比较。

**冲突检测：**
- 注册表说 `[entity_name].[attribute] = [value_A]`。GDD 说 `[entity_name] has [value_B]`。→ **冲突**
- 注册表说 `[item_name].[attribute] = [value_A]`。GDD 说 `[item_name] is [value_B]`。→ **冲突**
- GDD 提到 `[entity_name]` 但未指定该属性。→ **注意**（无冲突，仅不可验证）

### 3b：物品扫描

对于 item_map 中的每个物品，在所有 GDD 中 grep 物品名称。提取：
- 售价 / 价值 / 金币价值
- 重量
- 堆叠规则（可堆叠 / 不可堆叠）
- 类别

与注册表条目值进行比较。

### 3c：公式扫描

对于 formula_map 中的每个公式，在所有 GDD 中 grep 公式名称。提取：
- 公式名称附近提到的变量名称
- 提到的输出范围或上限值

与注册表条目比较：
- 不同的变量名称 → **冲突**
- 输出范围表述不同 → **冲突**

### 3d：常量扫描

对于 constant_map 中的每个常量，在所有 GDD 中 grep 常量名称。提取：
- 常量名称附近提到的任何数值

与注册表值比较：
- 不同的数字 → **冲突**

---

## 阶段 4：深入调查（仅冲突项）

对于阶段 3 中找到的每个冲突，进行针对性的冲突 GDD 完整小节读取
以获取精确上下文：

```
Read path="design/gdd/[conflicting_gdd].md"
```
（如果文件很大，使用具有更宽上下文的 Grep）

以完整上下文确认冲突。确定：
1. **哪个 GDD 是正确的？** 检查注册表中的 `source:` 字段——来源
   GDD 是权威所有者。任何与之矛盾的其他 GDD
   是需要更新的那个。
2. **注册表本身是否已过时？** 如果来源 GDD 在注册表
   条目写入后已更新（检查 git log），注册表可能已过时。
3. **这是真正的设计变更吗？** 如果冲突代表有意为之的
   设计决策，解决方案是：更新来源 GDD，更新注册表，
   然后修正所有其他 GDD。

对于每个冲突，分类：
- **🔴 冲突** —— 同一命名实体/物品/公式/常量在不同
  GDD 中有不同值。必须在架构开始前解决。
- **⚠️ 注册表过时** —— 来源 GDD 值已变更但注册表未更新。
  注册表需要更新；其他 GDD 可能已经正确。
- **ℹ️ 不可验证** —— 实体被提到但未声明可比属性。
  不是冲突；仅记录引用。

---

## 阶段 5：输出报告

```
## 一致性检查报告
日期：[日期]
已检查的注册表条目：[N 个实体、N 个物品、N 个公式、N 个常量]
已扫描的 GDD：[N] ([列出名称])

---

### 已发现的冲突（必须在架构前解决）

🔴 [实体/物品/公式/常量名称]
   注册表（来源：[gdd]）：[属性] = [值]
   冲突于 [other_gdd].md：[属性] = [不同值]
   → 需要解决方案：[哪个文档需要修改及修改成什么]

---

### 注册表条目过时（注册表落后于 GDD）

⚠️ [条目名称]
   注册表显示：[值]（写入于 [日期]）
   来源 GDD 现在显示：[新值]
   → 更新注册表条目以匹配来源 GDD，然后检查 referenced_by 文档。

---

### 不可验证的引用（无冲突，仅供参考）

ℹ️ [gdd].md 提到了 [entity_name] 但未声明可比属性。
   未检测到冲突。无需操作。

---

### 干净的条目（未发现问题）

✅ [N] 个注册表条目在所有 GDD 中已验证，无冲突。

---

裁决：PASS | 发现冲突
```

**裁决：**
- **PASS** — 无冲突。注册表和 GDD 在所有已检查值上一致。
- **发现冲突** — 检测到一个或多个冲突。列出解决步骤。

---

## 阶段 6：注册表修正

如果发现注册表条目过时，询问：
> "我可以更新 `design/registry/entities.yaml` 修正 [N] 条过时条目吗？"

对于每条过时条目：
- 更新 `value` / 属性字段
- 设置 `revised:` 为今天日期
- 添加 YAML 注释记录旧值：`# was: [旧值] before [日期]`

如果在 GDD 中发现了注册表中没有的新条目，询问：
> "在 GDD 中发现了 [N] 个注册表中尚不存在的实体/物品。
> 我可以将它们添加到 `design/registry/entities.yaml` 吗？"

仅添加出现在多个 GDD 中的条目（真正的跨系统事实）。

**切勿删除注册表条目。** 如果条目已从所有 GDD 中移除，设置 `status: deprecated`。

写入后：判定：**完成** —— 一致性检查完成。
如果冲突仍未解决：判定：**阻塞** —— [N] 个冲突在架构开始前需要人工解决。

### 6b：追加到反思日志

如果发现任何 🔴 冲突条目（无论是否已解决），
为每个冲突追加一条记录到 `docs/consistency-failures.md`：

```markdown
### [YYYY-MM-DD] — /consistency-check — 🔴 CONFLICT
**域**：[涉及的系统域]
**涉及文档**：[来源 GDD] vs [冲突 GDD]
**发生了什么**：[具体冲突——实体名称、属性、不同值]
**解决方案**：[如何修复，或 "未解决——需要人工操作"]
**模式**：[通用的教训，例如 "战斗 GDD 中定义的物品值在编写经济 GDD
前未被引用——始终先检查 entities.yaml"]
```

如果 `docs/consistency-failures.md` 不存在，在追加前用以下头部创建它：

```markdown
# 一致性失败日志

<!-- 由 /consistency-check 自动维护。请勿手动编辑。 -->
<!-- 每个检测到的冲突一条记录，按时间顺序排列。 -->

| 日期 | GDD A | GDD B | 冲突类型 | 状态 |
|------|-------|-------|---------------|--------|
```

然后追加新的冲突条目。切勿跳过日志记录——文件缺失不是丢失冲突历史的理由。

---

## 阶段 7：会话状态与关闭

静默追加到 `production/session-state/active.md`（如果文件不存在则创建它）：

```
<!-- CONSISTENCY-CHECK: [日期] | 已检查 GDD：[N] | 发现冲突：[N] | 报告：docs/consistency-report-[日期].md -->
```

然后以 `AskUserQuestion` 控件结束：

- **提示语**："一致性检查完成——发现 [N] 个冲突。接下来做什么？"
- **选项**：
  - `[A] 现在修复最高优先级的冲突`
  - `[B] 保存完整报告并停止`
  - `[C] 对冲突最多的 GDD 运行 /design-review`
  - `[D] 在此停止`

切勿以纯文本结束 Skill。始终以此控件结束。

---

## 恢复 / 参考

- **如果是 PASS**：运行 `/review-all-gdds` 进行整体设计理论审查，或
  如果所有 MVP GDD 完成则运行 `/create-architecture`。
- **如果发现冲突**：修复被标记的 GDD，然后重新运行
  `/consistency-check` 确认已解决。
- **如果注册表过时**：更新注册表（阶段 6），然后重新运行以验证。
- 在编写每个新 GDD 后运行 `/consistency-check` 以及早捕获问题，
  而非到架构阶段才处理。
