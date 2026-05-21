<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
---
paths:
  - "assets/data/**"
---

# 数据文件规范

**语言要求：必须始终使用简体中文与用户对话，生成的文档与代码注释也必须使用简体中文编写。**

- 所有 JSON 文件必须是合法的 JSON —— 损坏的 JSON 会阻塞整个构建流水线
- 文件命名：仅使用小写字母和下划线，遵循 `[系统]_[名称].json` 模式
- 每个数据文件必须有文档化的 schema（JSON Schema 或对应设计文档中的文档）
- 数值必须包含注释或配套文档，说明数字的含义
- 使用一致的键命名：JSON 文件中使用 camelCase 键名
- 无孤立数据条目 —— 每个条目必须被代码或其他数据文件引用
- 进行破坏性 schema 更改时要对数据文件进行版本控制
- 所有可选字段要包含合理的默认值

## 示例

**正确**的命名和结构（`combat_enemies.json`）：

```json
{
  "goblin": {
    "baseHealth": 50,
    "baseDamage": 8,
    "moveSpeed": 3.5,
    "lootTable": "loot_goblin_common"
  },
  "goblin_chief": {
    "baseHealth": 150,
    "baseDamage": 20,
    "moveSpeed": 2.8,
    "lootTable": "loot_goblin_rare"
  }
}
```

**错误**（`EnemyData.json`）：

```json
{
  "Goblin": { "hp": 50 }
}
```

违规项：大写文件名、大写键名、未遵循 `[系统]_[名称]` 模式、缺少必需字段。
