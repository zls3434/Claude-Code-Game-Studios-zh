<!-- Claude Code Game Studios -->
# 平台功能对照矩阵

| 功能 | Claude Code | Codex | DeepSeek Harness (dsh) | Trae IDE |
|---|---|---|---|---|
| 主配置文件 | CLAUDE.md（`@` 引用） | AGENTS.md | AGENTS.md（回退 CLAUDE.md） | AGENTS.md + .trae/rules/project_rules.md |
| 目录继承 | 支持（`@` 引用 + 子目录 CLAUDE.md） | 支持（子目录 AGENTS.md） | 支持（向上遍历至项目根） | 不支持（单文件内联） |
| 独立 Agent 定义 | 支持（49 个文件） | 不支持（AGENTS.md 花名册） | 原生支持子代理委派 | 支持（.trae/agents/，49 个文件） |
| 技能系统 | SKILL.md（原生） | Agent Skills 兼容 | Agent Skills 兼容 | Agent Skills 兼容（.trae/skills/） |
| 路径范围规则 | YAML paths frontmatter | 子目录 AGENTS.md | AGENTS.md 指令 | project_rules.md 内联标注 |
| Hook 系统 | 支持（12 个） | 不支持 | 不支持 | 不支持 |
| 权限控制 | settings.json | 不支持 | 平台原生审批策略 | 平台原生 |
| 模型层级分配 | YAML model（Opus/Sonnet/Haiku） | 不支持 | 不支持 | 不支持 |
| 审计日志 | Hook 支持 | 不支持 | 会话事件日志（内建） | 平台原生 |

## 功能降级说明

以下功能在非 Claude Code 平台上以降级形式提供：

| 功能 | 降级方式 |
|---|---|
| Hook 自动验证 | AGENTS.md 文档指令（提交前人工执行 `.claude/hooks/` 检查脚本） |
| 模型层级分配 | 所有任务使用平台默认模型 |
| 权限控制 | AGENTS.md"安全注意事项"文档指令 + 平台原生安全机制 |
| 子 Agent 派发 | 通过 `.claude/agents/` 定义 + 技能工作流模拟（dsh 原生支持子代理委派） |
| 审计日志 | 依赖平台原生日志或手动记录 |

## 同步入口

```bash
python tools/adapters/sync_all.py        # 全部平台
python tools/adapters/sync_all.py codex  # 仅 AGENTS.md（Codex + dsh）
python tools/adapters/sync_all.py trae   # 仅 .trae/
```

详见 `docs/platform-adaptation-guide.md`。
