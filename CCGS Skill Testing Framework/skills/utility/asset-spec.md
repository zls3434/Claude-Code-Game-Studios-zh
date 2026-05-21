<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/asset-spec

## Skill 摘要

`/asset-spec` 根据设计需求为每个资产生成可视规范文档。它读取相关的 GDD、美术圣经和设计系统，生成结构化的资产规范表，其中定义：尺寸、动画状态（如适用）、调色板引用、风格备注、技术约束（格式、文件大小预算）和交付检查清单。

规范表在经过 "May I write" 询问后写入 `assets/specs/[asset-name]-spec.md`。如果规范已存在，skill 会提供更新选项。当单次调用中请求多个资产时，会为每个资产分别进行 "May I write" 询问。不适用 director gate。当所有请求的规范都已写入时，判决为 COMPLETE。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：COMPLETE
- [ ] 包含 "May I write" 协作协议语言（每个资产）
- [ ] 有下一步交接（例如，分配给美术师，或之后运行 `/asset-audit`）

---

## Director Gate 检查

无。`/asset-spec` 是一个设计文档工具。技术美术师可能会单独审查规范，但这不属于此 skill 内的 gate。

---

## 测试用例

### 用例 1：Happy Path — 有完整 GDD 和美术圣经的敌人精灵规范

**Fixture：**
- `design/gdd/enemies.md` 存在，定义了敌人变体
- `design/art-bible.md` 存在，包含调色板和风格备注
- 不存在 "goblin-enemy" 的现有资产规范

**输入：** `/asset-spec goblin-enemy`

**预期行为：**
1. Skill 读取敌人 GDD 和美术圣经
2. Skill 生成哥布林敌人精灵规范：
   - 尺寸：从引擎默认值推断或从 GDD 中明确获取
   - 动画状态：idle、walk、attack、hurt、death
   - 调色板引用：链接到美术圣经调色板 section
   - 风格备注：来自美术圣经的角色设计规则
   - 技术约束：格式（PNG）、大小预算
   - 交付检查清单
3. Skill 询问 "May I write to `assets/specs/goblin-enemy-spec.md`?"
4. 批准后写入文件；判决为 COMPLETE

**断言：**
- [ ] 所有 6 个规范组件均存在（尺寸、动画、调色板、风格、技术、检查清单）
- [ ] 调色板引用链接到美术圣经（非复制内容）
- [ ] 动画状态来自 GDD（非凭空创建）
- [ ] "May I write" 以正确路径询问
- [ ] 判决为 COMPLETE

---

### 用例 2：无美术圣经 — 带占位风格备注的规范，依赖关系被标记

**Fixture：**
- `design/gdd/player.md` 存在
- `design/art-bible.md` 不存在

**输入：** `/asset-spec player-sprite`

**预期行为：**
1. Skill 读取玩家 GDD 但找不到美术圣经
2. Skill 生成带占位风格备注的规范："DEPENDENCY GAP: art bible not found — style notes are placeholders"
3. 调色板 section 使用："TBD — see art bible when created"
4. Skill 询问 "May I write to `assets/specs/player-sprite-spec.md`?"
5. 文件以占位符和依赖标记写入；判决为 COMPLETE 附建议说明

**断言：**
- [ ] 缺失美术圣经的 DEPENDENCY GAP 被标记
- [ ] 规范仍然生成（不被阻塞）
- [ ] 风格备注包含占位标记，而非凭空编造的风格
- [ ] 判决为 COMPLETE 附建议说明

---

### 用例 3：资产规范已存在 — 提供更新选项

**Fixture：**
- `assets/specs/goblin-enemy-spec.md` 已存在
- GDD 自规范编写后已更新（新增了攻击动画）

**输入：** `/asset-spec goblin-enemy`

**预期行为：**
1. Skill 检测到现有规范文件
2. Skill 报告："Asset spec already exists for goblin-enemy — checking for updates"
3. Skill 对比 GDD 与现有规范，识别出：GDD 中新增了 "charge-attack" 动画状态，但规范中没有
4. Skill 展示差异："1 new animation state found — offering to update spec"
5. Skill 询问 "May I update `assets/specs/goblin-enemy-spec.md`?"（非覆盖）
6. 规范更新；判决为 COMPLETE

**断言：**
- [ ] 检测到现有规范并提供 "update" 路径
- [ ] 显示 GDD 与现有规范之间的差异
- [ ] 使用 "May I update" 语言（而非 "May I write"）
- [ ] 现有规范内容被保留；仅应用差异部分
- [ ] 判决为 COMPLETE

---

### 用例 4：请求多个资产 — 每个资产分别进行 May-I-Write

**Fixture：**
- GDD 和美术圣经存在
- 用户请求 3 个资产的规范：goblin-enemy、orc-enemy、treasure-chest

**输入：** `/asset-spec goblin-enemy orc-enemy treasure-chest`

**预期行为：**
1. Skill 依次生成所有 3 个规范
2. 对每个资产，skill 展示草稿并逐一询问 "May I write to `assets/specs/[name]-spec.md`?"
3. 用户可批准全部 3 个或跳过个别资产
4. 所有批准的规范写入；判决为 COMPLETE

**断言：**
- [ ] "May I write" 被询问 3 次（每个资产一次），而非一次询问全部
- [ ] 用户可拒绝一个资产而不阻塞其他资产
- [ ] 批准的资产的所有 3 个规范文件均已写入
- [ ] 当所有批准的规范都写入时，判决为 COMPLETE

---

### 用例 5：Director Gate 检查 — 无 gate；asset-spec 是一个设计工具

**Fixture：**
- GDD 和美术圣经存在

**输入：** `/asset-spec goblin-enemy`

**预期行为：**
1. Skill 生成并写入资产规范
2. 不生成任何 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 COMPLETE，无任何 gate 检查

---

## 协议合规性

- [ ] 在生成规范前读取 GDD、美术圣经和设计系统
- [ ] 包含所有 6 个规范组件（尺寸、动画、调色板、风格、技术、检查清单）
- [ ] 用 DEPENDENCY GAP 备注标记缺失的依赖（美术圣经、GDD）
- [ ] 每个资产询问 "May I write"（或 "May I update"）
- [ ] 对多个资产进行逐个写入确认
- [ ] 当所有批准的规范都已写入时，判决为 COMPLETE

---

## 覆盖说明

- 音频资产规范（音效、音乐）遵循相同结构，使用不同的字段（时长、采样率、循环），不单独测试。
- UI 资产规范（图标、按钮状态）遵循相同流程，交互状态要求与 UX 规范对齐。
- GDD 也缺失的情况（GDD 和美术圣经都不存在）不单独测试；规范将生成并标记两个依赖差距。
