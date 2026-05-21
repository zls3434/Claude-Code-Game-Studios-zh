<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/hotfix

## Skill 摘要

`/hotfix` 管理紧急修复工作流：它从 main 创建 hotfix 分支，对识别的文件应用针对性修复，运行 `/smoke-check` 验证修复不会引入回归，并提示用户确认合并回 main。每次代码修改需要 "May I write to [filepath]?" 询问。Git 操作（分支创建、合并）以 Bash 命令形式呈现，待用户确认后执行。

该 skill 具有时间敏感性 — director 审查是可选的事后步骤，而非阻塞性 gate。判决：HOTFIX COMPLETE（修复已应用，冒烟检查通过，已合并）或 HOTFIX BLOCKED（修复引入回归或用户拒绝）。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：HOTFIX COMPLETE、HOTFIX BLOCKED
- [ ] 包含用于代码修改的 "May I write" 语言
- [ ] 有下一步交接（例如，`/bug-report` 记录问题，或版本号升级）

---

## Director Gate 检查

无。Hotfix 具有时间关键性。Director 审查可作为事后步骤单独进行。此 skill 内不调用任何 gate。

---

## 测试用例

### 用例 1：Happy Path — 严重崩溃 bug 已修复，冒烟检查通过

**Fixture：**
- `main` 分支干净
- Bug 在 `src/gameplay/arena.gd` 中识别（进入 boss 竞技场时崩溃）
- 用户提供重现步骤

**输入：** `/hotfix`（用户描述崩溃和受影响文件）

**预期行为：**
1. Skill 提议创建 hotfix 分支：`hotfix/boss-arena-crash`
2. 用户确认；显示分支创建的 Bash 命令并确认
3. Skill 识别 `arena.gd` 中的修复位置并起草修改
4. Skill 询问 "May I write to `src/gameplay/arena.gd`?"，批准后应用修复
5. Skill 运行 `/smoke-check` — PASS
6. Skill 呈现合并命令并要求用户确认合并到 `main`
7. 用户确认；执行合并；判决为 HOTFIX COMPLETE

**断言：**
- [ ] Hotfix 分支在任何代码修改之前创建
- [ ] 修改任何源文件之前询问 "May I write"
- [ ] 修复应用后运行 `/smoke-check`
- [ ] 合并需要明确的用户确认（非自动）
- [ ] 成功合并后判决为 HOTFIX COMPLETE

---

### 用例 2：冒烟检查失败 — HOTFIX BLOCKED

**Fixture：**
- 修复已应用于 `src/gameplay/arena.gd`
- `/smoke-check` 返回 FAIL："Player health clamping regression detected"

**输入：** `/hotfix`

**预期行为：**
1. Skill 应用修复并运行 `/smoke-check`
2. 冒烟检查返回 FAIL，识别出具体回归
3. Skill 报告："HOTFIX BLOCKED — smoke check failed: [regression detail]"
4. Skill 提供选项：尝试修订修复、回滚更改、或接受已知回归并合并（用户确认风险）
5. 冒烟检查失败时不自动合并

**断言：**
- [ ] 判决为 HOTFIX BLOCKED
- [ ] 冒烟检查失败原样展示给用户
- [ ] 冒烟检查失败时不自动执行合并
- [ ] 用户获得明确的后续操作选项

---

### 用例 3：修复已发布版本 — 版本标签被注明，提示补丁版本号升级

**Fixture：**
- 最新 git tag 为 `v1.2.0`
- Hotfix 针对 v1.2.0 版本中的 bug

**输入：** `/hotfix`

**预期行为：**
1. Skill 检测到当前 HEAD 是已标记版本（v1.2.0）
2. Skill 注明："Hotfix targeting tagged release v1.2.0"
3. 冒烟检查通过后，skill 提示："Should version be bumped to v1.2.1?"
4. 如果用户确认版本升级：skill 询问 "May I write to VERSION or equivalent?"
5. 版本更新和合并后：判决为 HOTFIX COMPLETE，附版本说明

**断言：**
- [ ] 版本标签上下文被检测并向用户展示
- [ ] 合并后建议（非强制）补丁版本号升级
- [ ] 版本升级需要单独的 "May I write" 确认
- [ ] 判决为 HOTFIX COMPLETE

---

### 用例 4：无重现步骤 — Skill 在应用修复前询问

**Fixture：**
- 用户以模糊描述调用 `/hotfix`："something is broken on level 3"
- 未提供重现步骤

**输入：** `/hotfix`（模糊描述）

**预期行为：**
1. Skill 检测到信息不足以识别修复位置
2. Skill 询问："Please provide reproduction steps and the affected file or system"
3. 在提供重现步骤之前，skill 不创建分支或修改任何文件
4. 用户提供重现步骤后：正常 hotfix 流程开始

**断言：**
- [ ] 无重现步骤时不创建分支
- [ ] 无明确识别的修复位置时不进行代码修改
- [ ] 重现步骤请求是具体的（非泛化的 "please provide more info"）
- [ ] 用户提供重现步骤后恢复正常 hotfix 流程

---

### 用例 5：Director Gate 检查 — 无 gate；hotfix 具有时间关键性

**Fixture：**
- 已识别严重 bug 及重现步骤

**输入：** `/hotfix`

**预期行为：**
1. Skill 完成 hotfix 工作流
2. 执行期间不生成 director agent
3. 输出中不出现 gate ID
4. 事后 director 审查（如需要）是手动跟进，此处不调用

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 HOTFIX COMPLETE 或 HOTFIX BLOCKED — 无 gate 判决

---

## 协议合规性

- [ ] 在任何代码修改之前创建 hotfix 分支
- [ ] 修改任何源文件之前询问 "May I write"
- [ ] 应用修复后运行 `/smoke-check`
- [ ] 合并前需要明确的用户确认
- [ ] 冒烟检查失败时为 HOTFIX BLOCKED — 不自动合并
- [ ] 判决为 HOTFIX COMPLETE 或 HOTFIX BLOCKED

---

## 覆盖说明

- 单个修复需要修改多个文件的情况遵循相同的 "May I write" 逐文件模式，不单独测试。
- Hotfix 后步骤（创建 bug 报告、更新变更日志）在交接中建议，但不作为此 skill 执行的一部分测试。
- 合并期间的冲突解决（如果 main 已分叉）不测试；skill 会展示冲突并要求用户手动解决。
