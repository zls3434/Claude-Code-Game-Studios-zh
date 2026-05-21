<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/prototype

## Skill 摘要

`/prototype` 管理快速原型制作工作流，用于在承诺完整生产实现之前验证游戏机制。原型创建在 `prototypes/[mechanic-name]/` 中，是有意可丢弃的——编码标准被放宽（无需 ADR，AC 可最小化，硬编码值可接受）。实现后，skill 生成一份发现文档，总结所学内容并建议下一步。

Skill 在创建文件前询问 "May I write to `prototypes/[name]/`?"。如果原型已存在，skill 提供扩展、替换或归档选项。不适用 director gate。判决：PROTOTYPE COMPLETE（原型已构建且发现已记录）或 PROTOTYPE ABANDONED（机制被发现不可行）。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：PROTOTYPE COMPLETE、PROTOTYPE ABANDONED
- [ ] 在创建原型文件前包含 "May I write" 语言
- [ ] 有下一步交接（例如，`/design-system` 正式化，或归档）

---

## Director Gate 检查

无。原型是可丢弃的验证工件。不适用 director gate。

---

## 测试用例

### 用例 1：Happy Path — 机制概念已原型化，发现已记录

**Fixture：**
- `prototypes/` 目录存在
- 不存在 "grapple-hook" 的现有原型

**输入：** `/prototype grapple-hook`

**预期行为：**
1. Skill 询问 "May I write to `prototypes/grapple-hook/`?"
2. 批准后：创建 `prototypes/grapple-hook/` 目录和基本实现骨架（主场景、玩家控制器扩展）
3. Skill 实现最小化的抓钩机制（有意粗糙——无需打磨，硬编码值可接受）
4. Skill 生成 `prototypes/grapple-hook/findings.md`，包含：
   - 测试了什么
   - 什么有效
   - 什么无效
   - 建议（继续 / 放弃 / 修订概念）
5. 判决为 PROTOTYPE COMPLETE

**断言：**
- [ ] 创建任何文件前询问 "May I write to `prototypes/grapple-hook/`?"
- [ ] 实现隔离在 `prototypes/` 中（非 `src/`）
- [ ] 创建 `findings.md`，至少包含：tested/worked/didn't-work/recommendation
- [ ] 判决为 PROTOTYPE COMPLETE

---

### 用例 2：原型已存在 — 提供扩展、替换或归档

**Fixture：**
- `prototypes/grapple-hook/` 已存在，来自之前的原型会话
- 它包含基本实现和 findings.md

**输入：** `/prototype grapple-hook`

**预期行为：**
1. Skill 检测到现有的 `prototypes/grapple-hook/` 目录
2. Skill 报告："Prototype already exists for grapple-hook"
3. Skill 展示 3 个选项：
   - 扩展：向现有原型添加新功能
   - 替换：重新开始（询问 "May I replace `prototypes/grapple-hook/`?"）
   - 归档：移动到 `prototypes/archive/grapple-hook/` 并重新开始
4. 用户选择；skill 相应继续

**断言：**
- [ ] 检测到并报告现有原型
- [ ] 恰好展示 3 个选项（扩展、替换、归档）
- [ ] 替换路径包含 "May I replace" 确认
- [ ] 归档路径移动（而非删除）现有原型

---

### 用例 3：原型验证机制 — 建议进入 Production

**Fixture：**
- 原型实现完成
- 发现：抓钩机制有趣且在技术上可行

**输入：** `/prototype grapple-hook`（原型会话完成）

**预期行为：**
1. 原型构建并测试后，总结发现
2. findings.md 中的建议："Mechanic validated — recommend proceeding to `/design-system` for full specification"
3. Skill 交接消息明确建议 `/design-system grapple-hook`
4. 判决为 PROTOTYPE COMPLETE

**断言：**
- [ ] `findings.md` 包含明确的建议
- [ ] 机制验证通过时建议引用 `/design-system`
- [ ] 交接消息呼应建议
- [ ] 判决为 PROTOTYPE COMPLETE（非 PROTOTYPE ABANDONED）

---

### 用例 4：原型揭示机制不可行 — PROTOTYPE ABANDONED

**Fixture：**
- 为 "procedural-dialogue" 实现了原型
- 测试后：该机制创建不连贯的对话树，游玩令人沮丧

**输入：** `/prototype procedural-dialogue`

**预期行为：**
1. 原型已构建
2. 发现记录了失败：输出不连贯、玩家困惑、技术复杂性
3. findings.md 中的建议："Mechanic not viable — abandoning"
4. `findings.md` 记录了该机制失败的具体原因
5. Skill 在交接中建议替代方案（例如，改用策划对话）
6. 判决为 PROTOTYPE ABANDONED

**断言：**
- [ ] 判决为 PROTOTYPE ABANDONED（非 PROTOTYPE COMPLETE）
- [ ] `findings.md` 记录了具体失败原因（非模糊）
- [ ] 交接中建议替代方法
- [ ] 原型文件保留（非删除）以供参考

---

### 用例 5：Director Gate 检查 — 无 gate；原型是验证工件

**Fixture：**
- 提供机制概念

**输入：** `/prototype wall-jump`

**预期行为：**
1. Skill 创建并记录原型
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 PROTOTYPE COMPLETE 或 PROTOTYPE ABANDONED — 无 gate 判决

---

## 协议合规性

- [ ] 创建任何文件前询问 "May I write to `prototypes/[name]/`?"
- [ ] 所有文件创建在 `prototypes/` 中（非 `src/`）
- [ ] 生成 `findings.md`，包含 tested/worked/didn't-work/recommendation
- [ ] 注明生产编码标准被有意放宽
- [ ] 原型已存在时提供扩展/替换/归档选项
- [ ] 判决为 PROTOTYPE COMPLETE 或 PROTOTYPE ABANDONED

---

## 覆盖说明

- 原型实现质量（代码风格）有意不测试——原型是可丢弃的工件，质量标准不适用。
- 归档机制在用例 2 中提及，但归档格式不进行详细的断言测试。
- 引擎特定的原型脚手架（GDScript 场景 vs. C# MonoBehaviour）遵循相同流程，使用引擎适用的文件类型。
