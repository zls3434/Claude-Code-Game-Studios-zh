<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# 引擎参考文档

本目录包含项目中使用的游戏引擎的精编、版本锁定文档快照。
这些文件的存在是因为 **LLM 知识有截止日期**，而游戏引擎更新频繁。

## 为什么存在这些文件

Claude 的训练数据有知识截止日期（当前为 2025 年 5 月）。像 Godot、Unity、Unreal
这样的游戏引擎发布的更新会引入破坏性 API 变更、新功能和已废弃的模式。
如果没有这些参考文件，Agent 会建议过时的代码。

## 目录结构

每个引擎拥有自己的目录：

```
<引擎>/
├── VERSION.md              # 锁定版本、验证日期、知识缺口窗口
├── breaking-changes.md     # 版本间的 API 变更，按风险等级组织
├── deprecated-apis.md      # "不要用 X → 用 Y" 查找表
├── current-best-practices.md  # 不在模型训练数据中的新实践
└── modules/                # 各子系统快速参考（每个最多约 150 行）
    ├── rendering.md
    ├── physics.md
    └── ...
```

## Agent 如何使用这些文件

引擎专家 Agent 被指示：

1. 读取 `VERSION.md` 确认当前引擎版本
2. 在建议任何引擎 API 之前检查 `deprecated-apis.md`
3. 查阅 `breaking-changes.md` 了解版本特定的关注点
4. 读取相关的 `modules/*.md` 用于子系统特定工作

## 维护

### 何时更新

- 升级引擎版本后
- 当 LLM 模型更新时（新的知识截止日期）
- 运行 `/refresh-docs` 后（如果可用）
- 当你发现一个模型答错的 API 时

### 如何更新

1. 更新 `VERSION.md`，填入新引擎版本和日期
2. 在 `breaking-changes.md` 中为版本过渡添加新条目
3. 将新弃用的 API 移入 `deprecated-apis.md`
4. 用新模式更新 `current-best-practices.md`
5. 用 API 变更更新相关的 `modules/*.md`
6. 在所有修改的文件上设置 "最后验证" 日期

### 质量规范

- 每个文件必须有 "最后验证：YYYY-MM-DD" 日期
- 模块文件保持在 150 行以内（上下文预算）
- 包含展示正确/错误模式的代码示例
- 链接到官方文档 URL 以便验证
- 只记录与模型训练数据不同的内容
