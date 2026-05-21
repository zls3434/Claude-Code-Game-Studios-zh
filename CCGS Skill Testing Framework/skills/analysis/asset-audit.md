<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 技能测试规范：/asset-audit

## 技能摘要

`/asset-audit` 审计 `assets/` 目录，检查命名规范合规性、缺少的元数据以及格式/大小问题。它根据 `technical-preferences.md` 中定义的规范和预算来读取资产文件。不会调用任何导演门禁。该技能未经用户批准不会写入。判决词：COMPLIANT、WARNINGS 或 NON-COMPLIANT。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：COMPLIANT、WARNINGS、NON-COMPLIANT
- [ ] 不要求包含 "May I write" 相关表述（只读；可选报告需要审批）
- [ ] 具有后续步骤交接（审计结果后的操作指引）

---

## 导演门禁检查

无。资产审计是只读分析技能；不会调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——所有资产遵循命名规范

**Fixture：**
- `technical-preferences.md` 指定命名规范：`snake_case`，例如 `enemy_grunt_idle.png`
- `assets/art/characters/` 包含：`enemy_grunt_idle.png`、`enemy_sniper_run.png`
- `assets/audio/sfx/` 包含：`sfx_jump_land.ogg`、`sfx_item_pickup.ogg`
- 所有文件均在大小预算内（纹理 ≤2MB，音频 ≤500KB）

**输入：** `/asset-audit`

**预期行为：**
1. 技能从 `technical-preferences.md` 中读取命名规范和大小预算
2. 技能递归扫描 `assets/`
3. 所有文件符合 `snake_case` 规范；均在预算内
4. 审计表显示所有行均为 PASS
5. 判决为 COMPLIANT

**断言：**
- [ ] 审计覆盖美术和音频资产目录
- [ ] 每个文件都针对命名规范和大小预算进行了检查
- [ ] 合规时所有行显示 PASS
- [ ] 判决为 COMPLIANT
- [ ] 不写入任何文件

---

### 用例 2：不合规——纹理超出大小预算

**Fixture：**
- `assets/art/environment/` 包含 5 个纹理文件
- 3 个纹理文件各为 4MB（预算：≤2MB）
- 2 个纹理文件在预算内

**输入：** `/asset-audit`

**预期行为：**
1. 技能从 `technical-preferences.md` 中读取大小预算（纹理为 2MB）
2. 技能扫描 `assets/art/environment/`——发现 3 个超尺寸纹理
3. 审计表列出每个超尺寸文件及其实际大小和预算
4. 判决为 NON-COMPLIANT
5. 技能建议对被标记的文件进行压缩或分辨率缩减

**断言：**
- [ ] 所有 3 个超尺寸文件按名称列出，并标注实际大小和预算大小
- [ ] 当任何文件超出其预算时，判决为 NON-COMPLIANT
- [ ] 为超尺寸文件提供了优化建议
- [ ] 预算内文件也被列出（显示 PASS）以确保完整性

---

### 用例 3：格式问题——音频格式错误

**Fixture：**
- `technical-preferences.md` 指定音频格式：OGG
- `assets/audio/music/theme_main.wav` 存在（WAV 格式）
- `assets/audio/sfx/sfx_footstep.ogg` 存在（正确的 OGG 格式）

**输入：** `/asset-audit`

**预期行为：**
1. 技能读取音频格式要求：OGG
2. 技能扫描 `assets/audio/`——发现 `theme_main.wav` 格式错误
3. 审计表将 `theme_main.wav` 标记为 FORMAT ISSUE（期望 OGG，实际为 WAV）
4. `sfx_footstep.ogg` 显示 PASS
5. 判决为 WARNINGS（格式问题可修正）

**断言：**
- [ ] `theme_main.wav` 被标记为 FORMAT ISSUE，并注明期望格式和实际格式
- [ ] 格式问题的判决为 WARNINGS（而非 NON-COMPLIANT），因为格式问题可修正
- [ ] 格式正确的资产显示为 PASS
- [ ] 技能不修改或转换任何资产文件

---

### 用例 4：缺少资产——GDD 引用了但 assets/ 中不存在的资产

**Fixture：**
- `design/gdd/enemies.md` 引用了 `enemy_boss_idle.png`
- `assets/art/characters/boss/` 目录为空——文件不存在

**输入：** `/asset-audit`

**预期行为：**
1. 技能读取 GDD 引用以查找预期的资产（与 `/content-audit` 的范围交叉引用）
2. 技能扫描 `assets/art/characters/boss/`——未找到文件
3. 审计表将 `enemy_boss_idle.png` 标记为 MISSING ASSET
4. 判决为 NON-COMPLIANT（缺少关键美术资产）

**断言：**
- [ ] 技能检查 GDD 引用以识别预期资产
- [ ] 缺少的资产被标记为 MISSING ASSET，并注明 GDD 引用
- [ ] 当关键资产缺失时，判决为 NON-COMPLIANT
- [ ] 技能不创建或添加占位资产

---

### 用例 5：门禁合规——无门禁；技术美术可单独咨询

**Fixture：**
- 2 个文件存在命名规范违规（CamelCase 而非 snake_case）
- `review-mode.txt` 包含 `full`

**输入：** `/asset-audit`

**预期行为：**
1. 技能扫描资产并发现 2 个命名违规
2. 无论审查模式如何，均不会调用导演门禁
3. 判决为 WARNINGS
4. 输出注明："考虑让技术美术（Technical Artist）审查命名规范"
5. 技能呈现发现结果；提供可选审计报告写入
6. 如果用户选择写入："我可以写入 `production/qa/asset-audit-[date].md` 吗？"

**断言：**
- [ ] 在任何审查模式下均不会调用导演门禁
- [ ] 技术美术咨询是建议性的（非强制）
- [ ] 发现结果表在任何写入提示之前呈现
- [ ] 可选审计报告写入在写入前询问 "May I write"

---

## 协议合规

- [ ] 从 `technical-preferences.md` 中读取命名规范、格式和大小预算
- [ ] 递归扫描 `assets/` 目录
- [ ] 审计表显示文件名、检查类型、期望值、实际值和结果
- [ ] 不修改任何资产文件
- [ ] 不调用任何导演门禁
- [ ] 判决为以下之一：COMPLIANT、WARNINGS、NON-COMPLIANT

---

## 覆盖说明

- 元数据检查（例如，Godot `.import` 文件中缺少的纹理导入设置）在此未显式测试；它们遵循相同的 FORMAT ISSUE 标记模式。
- `/asset-audit` 与 `/content-audit` 之间的交互（两者均检查 GDD 引用与资产）是有意的重叠；`/asset-audit` 侧重合规性，而 `/content-audit` 侧重完整性。
