<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# CLAUDE.local.md 模板

将此文件复制到项目根目录并命名为 `CLAUDE.local.md` 作为个人覆盖配置。
此文件已加入 gitignore，不会被提交。

```markdown
# 个人偏好

## 语言要求

**必须始终使用简体中文与用户对话，生成的文档与代码注释也必须使用简体中文编写。**

## 模型偏好
- 对复杂设计任务优先使用 Opus
- 对快速查找和简单编辑使用 Haiku

## 工作流偏好
- 代码变更后始终运行测试
- 在 60% 上下文用量时主动压缩
- 在不相关任务之间使用 /clear

## 本地环境
- Python 命令：python（或 py / python3）
- Shell：Windows 上的 Git Bash
- IDE：带 Claude Code 扩展的 VS Code

## 沟通风格
- 保持回复简洁
- 在所有代码引用中显示文件路径
- 简要解释架构决策

## 个人快捷键
- 当我说 "review" 时，对最近变更的文件运行 /code-review
- 当我说 "status" 时，显示 git status + Sprint 进度
```

## 设置

1. 将此模板复制到项目根目录：`cp .claude/docs/CLAUDE-local-template.md CLAUDE.local.md`
2. 编辑以匹配你的偏好
3. 验证 `CLAUDE.local.md` 已在 `.gitignore` 中（Claude Code 从项目根目录读取它）
