<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# 目录结构

```text
/
├── CLAUDE.md                    # 主配置文件
├── .claude/                     # Agent 定义、技能、Hook、规则、文档
├── src/                         # 游戏源代码（核心、玩法、AI、网络、UI、工具）
├── assets/                      # 游戏资源（美术、音频、VFX、Shader、数据）
├── design/                      # 游戏设计文档（GDD、叙事、关卡、数值）
├── docs/                        # 技术文档（架构、API、复盘）
│   └── engine-reference/        # 精选引擎 API 快照（版本锁定）
├── tests/                       # 测试套件（单元、集成、性能、试玩）
├── tools/                       # 构建和管线工具（CI、构建、资源管线）
├── prototypes/                  # 一次性原型（与 src/ 隔离）
└── production/                  # 制作管理（Sprint、里程碑、发布）
    ├── session-state/           # 临时会话状态（active.md —— 已 gitignore）
    └── session-logs/            # 会话审计日志（已 gitignore）
```
