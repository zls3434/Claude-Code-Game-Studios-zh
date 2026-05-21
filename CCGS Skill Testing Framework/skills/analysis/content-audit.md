<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# 技能测试规范：/content-audit

## 技能摘要

`/content-audit` 读取 `design/gdd/` 中的 GDD，并检查其中指定的所有内容项（敌人、物品、关卡等）是否在 `assets/` 中有对应的资产。它生成一个缺口表：内容类型 → 指定数量 → 已找到数量 → 缺失项。不会调用任何导演门禁。该技能未经用户批准不会写入。判决词：COMPLETE、GAPS FOUND 或 MISSING CRITICAL CONTENT。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：COMPLETE、GAPS FOUND、MISSING CRITICAL CONTENT
- [ ] 不要求包含 "May I write" 相关表述（只读输出；写入是可选报告）
- [ ] 具有后续步骤交接（缺口表审查后的操作指引）

---

## 导演门禁检查

无。内容审计是只读分析技能；不会调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——所有指定内容均存在

**Fixture：**
- `design/gdd/enemies.md` 指定了 4 种敌人类型：Grunt、Sniper、Tank、Boss
- `assets/art/characters/` 包含文件夹：`grunt/`、`sniper/`、`tank/`、`boss/`
- `design/gdd/items.md` 指定了 3 种物品类型；全部在 `assets/data/items/` 中找到

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 `design/gdd/` 中的所有 GDD
2. 技能扫描 `assets/` 中每个指定的内容项
3. 所有 4 种敌人类型和 3 种物品类型均被找到
4. 缺口表显示：所有行的已找到数量 = 指定数量，无缺失项
5. 判决为 COMPLETE

**断言：**
- [ ] 缺口表覆盖 GDD 中找到的所有内容类型
- [ ] 每行显示指定数量和已找到数量
- [ ] 数量匹配时无缺失项
- [ ] 判决为 COMPLETE
- [ ] 不写入任何文件

---

### 用例 2：发现缺口——资源中缺少敌人类型

**Fixture：**
- `design/gdd/enemies.md` 指定了 3 种敌人类型：Grunt、Sniper、Boss
- `assets/art/characters/` 仅包含：`grunt/`、`sniper/`（缺少 Boss 文件夹）

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 GDD——发现指定了 3 种敌人类型
2. 技能扫描 `assets/art/characters/`——只找到 2 种
3. 缺口表中敌人行：指定 3，已找到 2，缺失：Boss
4. 判决为 GAPS FOUND

**断言：**
- [ ] 缺口表行按名称将 "Boss" 标识为缺失项
- [ ] 指定数量（3）和已找到数量（2）均被显示
- [ ] 当任何内容项缺失时，判决为 GAPS FOUND
- [ ] 技能不会假设该资产之后会添加——现在就标记它

---

### 用例 3：未找到 GDD 内容规格——给出指导

**Fixture：**
- `design/gdd/` 仅包含 `core-loop.md`，其中没有内容清单部分
- 没有其他包含内容规格的 GDD

**输入：** `/content-audit`

**预期行为：**
1. 技能读取所有 GDD——未找到内容清单部分
2. 技能输出："在 GDD 中未找到内容规格——请先运行 /design-system 来定义内容列表"
3. 不生成缺口表
4. 判决为 GAPS FOUND（没有规格无法确认完整性）

**断言：**
- [ ] 当 GDD 中没有内容规格时，技能不生成缺口表
- [ ] 输出建议运行 `/design-system`
- [ ] 判决反映无法确认完整性

---

### 用例 4：边界情况——资产格式与目标平台不匹配

**Fixture：**
- `design/gdd/audio.md` 指定音频资产为 OGG 格式
- `assets/audio/sfx/jump.wav` 存在（WAV 格式，非 OGG）
- `assets/audio/sfx/land.ogg` 存在（正确格式）
- `technical-preferences.md` 指定音频格式：OGG

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 GDD 音频规格和技术偏好中的格式要求
2. 技能找到 `jump.wav`——存在但格式错误
3. 缺口表中音频行：指定 2，已找到 2（按名称），但 `jump.wav` 标记为 FORMAT ISSUE
4. 判决为 GAPS FOUND（格式合规是内容完整性的一部分）

**断言：**
- [ ] 当格式已指定时，技能根据 GDD 或技术偏好检查资产格式
- [ ] `jump.wav` 被标记为 FORMAT ISSUE，并注明期望格式（OGG）
- [ ] 格式问题在缺口表中与缺失内容区分开来
- [ ] 当存在格式问题时，判决为 GAPS FOUND

---

### 用例 5：门禁合规——只读；无门禁；缺口表供人工审查

**Fixture：**
- GDD 指定了 10 个内容项；在资源中找到 9 个；缺失 1 个
- `review-mode.txt` 包含 `full`

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 GDD 并扫描资源；生成缺口表
2. 无论审查模式如何，均不会调用任何导演门禁
3. 技能以只读输出形式向用户呈现缺口表
4. 判决为 GAPS FOUND
5. 技能提供写入审计报告的选项，但不会自动写入

**断言：**
- [ ] 在任何审查模式下均不会调用导演门禁
- [ ] 缺口表在不自动写入任何文件的情况下呈现
- [ ] 可选报告写入是提供的而非强制
- [ ] 技能不修改任何资产文件

---

## 协议合规

- [ ] 在生成缺口表之前读取 GDD 和资产目录
- [ ] 缺口表显示内容类型、指定数量、已找到数量、缺失项
- [ ] 未经用户明确批准不写入文件
- [ ] 不调用任何导演门禁
- [ ] 判决为以下之一：COMPLETE、GAPS FOUND、MISSING CRITICAL CONTENT

---

## 覆盖说明

- MISSING CRITICAL CONTENT 判决（与 GAPS FOUND 相对）在缺失项在 GDD 中被标记为关键项时触发；此处未显式测试，但遵循相同的检测路径。
- `assets/` 目录不存在的情况未测试；技能会对所有指定项产生 MISSING CRITICAL CONTENT 判决。
