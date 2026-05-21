<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# settings.local.json 模板

创建 `.claude/settings.local.json` 用于不应提交到版本控制的个人覆盖设置。
将其添加到 `.gitignore`。

## 示例 settings.local.json

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm *)",
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)"
    ]
  }
}
```

## 权限模式

Claude Code 支持不同的权限模式。游戏开发的推荐设置：

### 开发阶段（默认）
使用 **normal 模式** — Claude 在执行大多数命令前会询问。这是生产代码最安全的选择。

### 原型阶段
使用 **auto-accept 模式**，但限制范围 — 在一次性代码上更快迭代。
仅当在 `prototypes/` 目录下工作时使用此模式。

### 代码审查阶段
使用 **read-only** 权限 — Claude 可以读取和搜索，但不能修改文件。

## 本地自定义 Hook

你可以在 `settings.local.json` 中添加个人 Hook，这会扩展（而非覆盖）项目 Hook。
例如，在构建完成时添加通知：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'echo Session ended at $(date)'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```
