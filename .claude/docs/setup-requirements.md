<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# 设置要求

此模板需要安装一些工具才能实现完整功能。
所有 Hook 在缺少工具时都会优雅降级 — 不会出现故障，
但你将失去验证功能。

## 必需

| 工具 | 用途 | 安装方式 |
| ---- | ---- | ---- |
| **Git** | 版本控制、分支管理 | [git-scm.com](https://git-scm.com/) |
| **Claude Code** | AI Agent CLI | `npm install -g @anthropic-ai/claude-code` |

## 推荐

| 工具 | 使用方 | 用途 | 安装方式 |
| ---- | ---- | ---- | ---- |
| **jq** | Hook（12 个中的 7 个） | commit/push/asset/agent Hook 中的 JSON 解析 | 见下方 |
| **Python 3** | Hook（12 个中的 2 个） | 数据文件的 JSON 验证 | [python.org](https://www.python.org/) |
| **Bash** | 所有 Hook | Shell 脚本执行 | Git for Windows 已包含 |

### 安装 jq

**Windows**（任选其一）：
```
winget install jqlang.jq
choco install jq
scoop install jq
```

**macOS**：
```
brew install jq
```

**Linux**：
```
sudo apt install jq     # Debian/Ubuntu
sudo dnf install jq     # Fedora
sudo pacman -S jq       # Arch
```

## 平台说明

### Windows
- Git for Windows 包含 **Git Bash**，它提供了 `settings.json` 中所有 Hook
  使用的 `bash` 命令
- 确保 Git Bash 在你的 PATH 中（通过 Git 安装程序安装时默认如此）
- Hook 使用 `bash .claude/hooks/[name].sh` — 这在 Windows 上可以工作，
  因为 Claude Code 通过可以找到 `bash.exe` 的 Shell 来执行命令

### macOS / Linux
- Bash 原生可用
- 通过你的包管理器安装 `jq` 可获得完整的 Hook 支持

## 验证你的设置

运行以下命令检查先决条件：

```bash
git --version          # 应显示 git 版本
bash --version         # 应显示 bash 版本
jq --version           # 应显示 jq 版本（可选）
python3 --version      # 应显示 python 版本（可选）
```

## 缺少可选工具时的影响

| 缺少的工具 | 影响 |
| ---- | ---- |
| **jq** | 提交验证、推送保护、资源验证和 Agent 审计 Hook 将静默跳过检查。提交和推送仍然可以正常工作。 |
| **Python 3** | 提交和资源 Hook 中的 JSON 数据文件验证被跳过。无效 JSON 可能在无警告的情况下被提交。 |
| **两者都缺** | 所有 Hook 仍然无错误执行（exit 0），但不提供验证。你在无安全网的情况下工作。 |

## 推荐 IDE

Claude Code 可以与任何编辑器配合使用，但此模板针对以下工具进行了优化：
- **VS Code** 搭配 Claude Code 扩展
- **Cursor**（Claude Code 兼容）
- 基于终端的 Claude Code CLI
