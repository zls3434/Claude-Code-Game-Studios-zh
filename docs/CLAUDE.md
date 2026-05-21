<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# 文档目录

在本目录下编写或编辑文件时，请遵循以下标准。

## 架构决策记录（`docs/architecture/`）

使用 ADR 模板：`.claude/docs/templates/architecture-decision-record.md`

**必需部分：** 标题、状态、上下文、决策、后果、
ADR 依赖项、引擎兼容性、GDD 需求覆盖

**状态生命周期：** `Proposed` → `Accepted` → `Superseded`
- 绝不跳过 `Accepted` — 引用 `Proposed` 状态 ADR 的故事会被自动阻止
- 使用 `/architecture-decision` 通过引导流程创建 ADR

**TR 注册表：** `docs/architecture/tr-registry.yaml`
- 稳定的需求 ID（例如 `TR-MOV-001`），将 GDD 需求与故事链接
- 绝不重新编号现有 ID — 仅追加新 ID
- 由 `/architecture-review` 第 8 阶段更新

**控制清单：** `docs/architecture/control-manifest.md`
- 扁平化的程序员规则表：按层级列出必须 / 禁止 / 警戒线
- 头部带日期的 `Manifest Version:`
- 故事嵌入此版本号；`/story-done` 检查过期

**验证：** 完成一组 ADR 后运行 `/architecture-review`。

## 引擎参考（`docs/engine-reference/`）

锁定版本的引擎 API 快照。**在使用任何引擎 API 之前
务必检查此处** — LLM 的训练数据早于锁定的引擎版本。

当前引擎：见 `docs/engine-reference/godot/VERSION.md`
