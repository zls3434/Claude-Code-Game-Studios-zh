<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# 活跃 Hook

Hook 在 `.claude/settings.json` 中配置，自动触发：

| Hook | 事件 | 触发条件 | 动作 |
| ---- | ----- | ------- | ------ |
| `validate-commit.sh` | PreToolUse (Bash) | `git commit` 命令 | 验证设计文档章节、JSON 数据文件、硬编码值、TODO 格式 |
| `validate-push.sh` | PreToolUse (Bash) | `git push` 命令 | 对向受保护分支（develop/main）的推送发出警告 |
| `validate-assets.sh` | PostToolUse (Write/Edit) | 资源文件变更 | 检查 `assets/` 中文件的命名约定和 JSON 有效性 |
| `session-start.sh` | SessionStart | 会话开始 | 加载 Sprint 上下文、里程碑、Git 活动；检测并预览活跃会话状态文件以支持恢复 |
| `detect-gaps.sh` | SessionStart | 会话开始 | 检测全新项目（建议运行 /start），以及有代码/原型但缺少文档时建议运行 /reverse-document 或 /project-stage-detect |
| `pre-compact.sh` | PreCompact | 上下文压缩 | 在压缩前将会话状态（active.md、已修改文件、进行中的设计文档）转储到对话中，确保其在摘要后依然存在 |
| `post-compact.sh` | PostCompact | 压缩后 | 提醒 Claude 从 `active.md` 检查点恢复会话状态 |
| `notify.sh` | Notification | 通知事件 | 通过 PowerShell 显示 Windows Toast 通知 |
| `session-stop.sh` | Stop | 会话结束 | 总结成果并更新会话日志 |
| `log-agent.sh` | SubagentStart | Agent 启动 | 审计追踪开始 — 记录子 Agent 调用及时间戳 |
| `log-agent-stop.sh` | SubagentStop | Agent 停止 | 审计追踪结束 — 完成子 Agent 记录 |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | 技能文件变更 | 建议在 `.claude/skills/` 文件被写入或编辑后运行 `/skill-test` |

Hook 参考文档：`.claude/docs/hooks-reference/`
Hook 输入 Schema 文档：`.claude/docs/hooks-reference/hook-input-schemas.md`
