<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：devops-engineer

## Agent 摘要
- **领域**：CI/CD 管道配置、构建脚本、版本控制工作流执行、部署基础设施、分支策略、环境管理、CI 中的自动化测试集成
- **不拥有**：游戏逻辑或 gameplay 系统、安全审计（security-engineer）、QA 测试策略（qa-lead）、游戏网络逻辑（network-programmer）
- **Model tier**：Sonnet
- **Gate ID**：无；将部署阻塞升级到 producer

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 CI/CD、构建、部署、版本控制）
- [ ] `allowed-tools:` 列表匹配 agent 角色（Read/Write 用于管道配置文件、shell 脚本、YAML；无游戏源编辑工具）
- [ ] Model tier 为 Sonnet（operations specialist 默认）
- [ ] Agent 定义不声称对游戏逻辑、安全审计或 QA 测试设计拥有权限

---

## 测试用例

### Case 1：域内请求 — Godot 项目的 CI 设置
**输入**："为我们的 Godot 4 项目设置 CI 管道。它应在每次 push 到 main 和每个 pull request 时运行测试，并在测试失败时使构建失败。"
**预期行为**：
- 产出 GitHub Actions workflow YAML（`.github/workflows/ci.yml` 或等效文件）
- 使用 coding-standards.md 中的 Godot headless 测试运行器命令：`godot --headless --script tests/gdunit4_runner.gd`
- 配置 `push` 到 main 和 `pull_request` 上的触发器
- 设置作业在测试失败时失败（`exit 1` 或非零退出）— 不配置管道在测试失败时继续
- 在输出或注释中引用项目的 coding standards CI 规则

### Case 2：领域外请求 — 游戏网络实现
**输入**："为我们的多人游戏实现服务器权威的移动系统。"
**预期行为**：
- 不产出游戏网络或移动代码
- 明确声明："游戏网络实现由 network-programmer 拥有；我处理构建、测试和部署游戏的基础设施"
- 不将 CI 管道配置与游戏内网络架构混淆

### Case 3：构建失败诊断
**输入**："我们的 CI 管道在合并步骤失败。错误是：'Asset import failed: texture compression format unsupported in headless mode.'"
**预期行为**：
- 诊断根本原因：headless CI 环境不支持 GPU 依赖的纹理压缩
- 提出具体修复：要么在 CI 运行前本地预导入资产（将 .import 文件提交到 VCS），配置 Godot 导入设置在 CI 中使用 CPU 兼容的压缩格式，或使用带 GPU 模拟的 Docker 镜像（如果可用）
- 不宣布管道不可修复 — 提供至少一个可操作路径
- 注明任何权衡（提交 .import 文件增加仓库大小；CPU 压缩可能与 GPU 输出不同）

### Case 4：分支策略冲突
**输入**："团队一半人想用带长期 feature 分支的 GitFlow。另一半想用基于主干的开发。我们应该如何设置？"
**预期行为**：
- 根据项目约定推荐基于主干的开发（CLAUDE.md / coordination-rules.md 指定 Git 采用基于主干的开发）
- 在此项目上下文中为推荐提供具体理由：团队较小、集成冲突更少、更快的 CI 反馈
- 如果项目有既定约定，不呈现 50/50 选择
- 解释如何通过短期 feature 分支和 feature flag（如需要）实现基于主干的开发
- 不未经标记覆盖项目约定（这样做需要更新 CLAUDE.md）

### Case 5：上下文传递 — 平台特定构建矩阵
**输入上下文**：项目目标平台为 PC（Windows、Linux）、Nintendo Switch 和 PlayStation 5。
**输入**："设置我们的 CI 构建矩阵，以便在每次 release 分支 push 时为每个目标平台获得构建产物。"
**预期行为**：
- 产出包含三个平台条目的构建矩阵配置：Windows、Linux、Switch、PS5
- 应用平台适当的构建步骤：PC 使用标准 Godot 导出模板；Switch 和 PS5 需要平台特定的导出模板（注明控制台模板需要许可 SDK 访问，不公开分发）
- 不假设所有平台可以使用相同构建运行器 — 标记控制台构建可能需要带许可 SDK 的自托管运行器
- 在管道输出中按平台名称组织产物

---

## 协议合规性

- [ ] 停留在声明领域内（CI/CD、构建脚本、版本控制、部署）
- [ ] 将游戏逻辑和网络请求重定向到适当程序员
- [ ] 在分支策略有争议时根据项目约定推荐基于主干的开发
- [ ] 返回结构化管道配置（YAML、脚本）而非自由形式建议
- [ ] 标记控制台构建的平台 SDK 许可约束而非静默产生错误配置

---

## 覆盖说明
- Case 1（Godot CI）引用 coding-standards.md CI 规则 — 运行此测试前验证此文件存在且当前
- Case 4（分支策略）是约定执行测试 — agent 必须知道项目约定，而非仅给出中立建议
- Case 5 要求项目目标平台记录在案（在 technical-preferences.md 或等效文件中）
- 无自动化运行器；手动审查或通过 `/skill-test`
