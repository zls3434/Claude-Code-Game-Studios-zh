---
name: gate-check
description: "阶段门禁评估——关于项目是否准备好进入下一个开发阶段的正式裁决。检查每个阶段的设计完整性。"
argument-hint: "[阶段 或 门禁名称] [--check-only] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
model: sonnet
---

<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

## 阶段 0：解析审查模式

解析一次，存储以供本次运行所有门禁生成使用：

1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认 `lean`

参见 `.claude/docs/director-gates.md` 了解完整的检查模式。

---

## 概念 → 系统设计

**检查目的：** 确保艺术意图和体验目标在转向系统分解之前已经完善。

检查内容：
1. `design/gdd/game-concept.md` 是否存在？如果缺失，裁决：**失败**——"游戏概念文档未找到。运行 `/quick-design [概念]` 或 `/design-review` 以完成设计意图规范。"
2. `design/gdd/game-pillars.md` 是否存在？如果缺失，裁决：**失败**——"游戏支柱未找到。在定义系统之前运行 `/design-review` 以建立设计约束。"
3. 概念文档中是否定义了核心幻想、目标受众、平台、类型？缺少任何一项 → **疑虑**

**审查模式检查：**
- `solo` → 跳过导演门禁。应用阶段 3 的自动裁决。
- `lean` → 跳过导演门禁。应用阶段 3 的自动裁决。
- `full` → 生成 `creative-director` 进行正式审查（门禁 **CD-CONCEPT**，来自 `.claude/docs/director-gates.md`）

将导演的鉴定结果与基于产物的检查结果结合。

如果通过：裁决：**通过**——"概念阶段完成。准备进入系统设计。将项目阶段推进到系统设计并运行 `/map-systems` 以分解为系统。"

---

## 系统设计 → 技术设置

**检查目的：** 确保在技术决策之前有一个完整的系统分解。

检查内容：
1. `design/gdd/systems-index.md` 是否存在？如果缺失，裁决：**失败**——"系统索引未找到。运行 `/map-systems` 以将游戏概念分解为单独的系统。"
2. 索引中列出的每个系统都有 `design/gdd/[system-name].md` 吗？列出缺失的。如果任何系统缺失 → **疑虑**"在 [缺失的 GDD] 中尝试运行 `/map-systems` 以完成系统规范。"
3. 是否有任何系统 GDD 缺少 `Status` 字段？高亮它们。如果一个或多个关键系统缺少 `Status: Accepted` → **疑虑**。

**审查模式检查：**
- `solo` → 跳过导演门禁。应用阶段 3 的自动裁决。
- `lean` → 跳过导演门禁。应用阶段 3 的自动裁决。
- `full` → 生成 `creative-director`（门禁 **CD-SYSTEMS**）审查系统索引中所有系统的完整性

将导演的鉴定结果与基于产物的检查结果结合。

如果通过：裁决：**通过**——"系统设计完成。准备设置技术。将项目阶段推进到技术设置并运行 `/select-engine`。"

---

## 技术设置 → 前期制作

**检查目的：** 确保引擎选择、工具配置以及所有 ADR 在垂直切片之前都已归档。

检查内容：
1. 引擎标志文件是否存在（例如 `project.godot`、`*.uproject`、Assets 中的 `.unity` 文件）？如果缺失，裁决：**失败**——"未检测到引擎配置。运行 `/select-engine` 设置引擎和工具链。"
2. 引擎版本参考文件是否在 `docs/engine-reference/` 中？如果缺失 → **失败**。
3. 是否存在任何 ADR？如果缺失，裁决：**疑虑**——"未找到架构决策记录（`docs/architecture/adr-*.md`）。建议运行 `/architecture-decision` 来捕获关键决策。"
4. `.claude/docs/technical-preferences.md` 是否填充了命名规范、性能预算和已批准的库？
5. `docs/architecture/control-manifest.md` 是否存在？如果缺失 → **疑虑**"在编写故事之前运行 `/create-control-manifest`——程序员需要清单才能实现。"

**审查模式检查：**
- `solo` → 跳过导演门禁。结合基于产物的检查结果，并也生成 `lead-programmer` 进行代码审查（门禁 **LP-TECH-SETUP**）
- `lean` → 跳过导演门禁。结合基于产物的检查结果。
- `full` → 生成：
  1. `lead-programmer`（门禁 **LP-TECH-SETUP**）检查 ADR、引擎配置、工具设置
  2. `technical-director`（门禁 **TD-TECH-SETUP**）审查架构决策

将导演的鉴定结果与基于产物的检查结果结合。

如果通过：裁决：**通过**——"技术设置完成。准备进入前期制作。将项目阶段推进到前期制作并运行 `/create-epics` 来规划开发。"

---

## 前期制作 → 制作

**检查目的：** 确保垂直切片证明核心循环，在扩展到完整制作之前有可工作的系统。

检查内容：
1. 至少一个具有核心循环的垂直切片（`## 垂直切片` 部分存在，`Status: demonstrated`）
2. 在 `design/gdd/systems-index.md` 中列出的任何系统中没有 `Status: not-designed`
3. 至少 1 个故事文件通过了 `/story-readiness` 检查（`production/stories/*.md` 存在）
4. 冲刺计划已发布（`production/sprint-status.yaml` 存在）
5. `docs/architecture/control-manifest.md` 存在且清单版本未早于所有相关的系统 GDD 和 ADR

如果通过前 5 个基于产物的检查：

**审查模式检查：**
- `solo` → 应用阶段 3 的自动裁决。也生成 `lead-programmer` 进行代码审查（门禁 **LP-VERTICAL-SLICE**）
- `lean` → 应用阶段 3 的自动裁决。
- `full` → 生成：
  1. `lead-programmer`（门禁 **LP-VERTICAL-SLICE**）审查垂直切片代码
  2. `creative-director`（门禁 **CD-VERTICAL-SLICE**）审查垂直切片体验和游戏感觉
  3. `game-designer`（门禁 **GD-VERTICAL-SLICE**）检查垂直切片有趣度

结合所有鉴定结果。如果获得批准：

裁决：**通过**——"前期制作完成。垂直切片已验证。将项目阶段推进到制作。运行 `/sync-priorities` 为制作阶段同步冲刺。现在将引入更多程序员——为即将到来的冲刺运行 `/sprint-plan` 设置冲刺。"

---

## 阶段门禁：制作流程

### 制作 → 打磨

**检查目的：** 确保在锁定功能之前达到核心内容完整性。

检查内容：
1. 所有 M1-M4 功能已完成
2. 所有冲刺/故事标记为完成（`production/sprint-status.yaml` 中没有 `in-progress` 状态）
3. 没有 S1 Bug，最多 [N] 个 S2 Bug（可配置）
4. 所有关键路径系统的性能在预算内
5. 所有已接受和强制性的 ADR 已实现
6. 垂直切片仍然可玩，没有回归

**审查模式检查：**
- `solo` → 结合基于产物的检查结果，并也生成 `lead-programmer` 进行代码审查（门禁 **LP-PRODUCTION**）
- `lean` → 应用阶段 3 的自动裁决。
- `full` → 生成：
  1. `lead-programmer`（门禁 **LP-PRODUCTION**）审查生产代码质量
  2. `technical-director`（门禁 **TD-PRODUCTION**）审查架构完整性
  3. `creative-director`（门禁 **CD-PRODUCTION**）审查内容完整性
  4. `qa-lead`（门禁 **QA-PRODUCTION**）审查质量指标

将导演的鉴定结果与基于产物的检查结果结合。

如果通过：裁决：**通过**——"内容完整。准备进入打磨阶段。将项目阶段推进到打磨。运行 `/retrospective [里程碑]` 获取生产经验教训，然后运行 `/sign-off` 启动打磨批准工作流。"

### 打磨 → 发布

**检查目的：** 确保体验光滑、无 Bug、经过优化，并准备好面向玩家。

检查内容：
1. 没有 S1 或 S2 Bug
2. 所有性能指标在目标内
3. 本地化完成（来自 `/localize status` 的所有语言完成率 ≥ 95%）
4. 面向玩家的文本已校对
5. 无障碍功能已实现并验证
6. 浸泡测试通过（4+ 小时没有崩溃或重大问题）
7. 构建大小在平台限制内

**审查模式检查：**
- `solo` → 结合基于产物的检查结果，并也生成 `lead-programmer` 进行代码审查（门禁 **LP-POLISH**）
- `lean` → 应用阶段 3 的自动裁决。
- `full` → 生成：
  1. `lead-programmer`（门禁 **LP-POLISH**）审查构建稳定性和性能
  2. `creative-director`（门禁 **CD-POLISH**）审查体验质量
  3. `qa-lead`（门禁 **QA-POLISH**）审查最终质量指标

将导演的鉴定结果与基于产物的检查结果结合。

如果通过：裁决：**通过**——"打磨完成。准备发布。将项目阶段推进到发布。运行 `/launch-checklist` 进行发布清单，然后运行 `/release-checklist [平台]` 进行最终签署确认。"

### 发布 → 发布后

**检查目的：** 制作后生命周期门禁——确保持续支持和下一阶段的规划。这不是第二阶段制作的开启；这是维护的进入。

检查内容：
1. 社区的 Bug 报告正在被分类（来自社区跟踪器的活跃指标）
2. 崩溃率在可接受范围内（低于 [可配置阈值]）
3. 支持管道已建立（支持邮件/工单系统已激活）
4. 实时运营仪表板已上线
5. 团队已排程进行发布后支持

**审查模式检查：**
- `solo` → 结合基于产物的检查结果，并也生成 `lead-programmer` 进行代码审查（门禁 **LP-POST-RELEASE**）
- `lean` → 应用阶段 3 的自动裁决。
- `full` → 生成 `lead-programmer`（门禁 **LP-POST-RELEASE**）审查发布后稳定性

将导演的鉴定结果与基于产物的检查结果结合。

如果通过：裁决：**通过**——"游戏已发布且稳定。准备进入发布后。将项目阶段推进到发布后。"

---
---

## 更新项目阶段

每次成功的门禁后，将当前阶段写入 `production/stage.txt`。此文件必须只包含阶段名称，后面没有额外的新行或空白。

写入的字符串是门禁输出中脚本可读的阶段名称。对于需要中文名称的命令，请参考下表：

| 阶段 | 写入 stage.txt 的值 |
|-------|-----------|
| 概念 | concept |
| 系统设计 | systems-design |
| 技术设置 | technical-setup |
| 前期制作 | pre-production |
| 制作 | production |
| 打磨 | polish |
| 发布 | release |
| 发布后 | post-release |

此文件由需要知道当前阶段的下游命令（如 `/help` 和 `/project-stage-detect`）按原样读取。不要在其中写入英文或中文名称。始终在写入前去除空白。

---

## 更新 sprint-status.yaml

每个成功的阶段门禁裁决 — 无论是 **PASS**、**PASS-AUTO**，还是导演门禁 - **PASS** — 必须将当前阶段键写入 `production/sprint-status.yaml` 的 `stage:` 字段。

将当前阶段键注入文件并记录裁决结果。
