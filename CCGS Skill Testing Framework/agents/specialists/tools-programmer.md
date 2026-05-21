<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：tools-programmer

## Agent 摘要
领域：内部工具和编辑器 — 关卡编辑器工具、数据转换工具、管线自动化、资产处理脚本
不拥有：游戏机制或功能、视觉资产创建、设计决策
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（编辑器工具、管线、脚本）
- [ ] `allowed-tools:` 列表匹配 agent 角色（读写工具脚本，Bash — 如适用）
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对游戏机制拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "需要一个脚本将物品数据的 CSV 转换为引擎资源文件。CSV 包含物品 ID、名称、稀有度、属性。"
**预期行为：**
- 产出 CSV → 引擎资源转换脚本：
  - 读取 CSV 头映射到资源字段
  - 验证必需字段 (ID、名称、稀有度)
  - 输出引擎格式的资源文件 (.tres 或等效)
  - 错误处理：字段缺失、重复 ID

### Case 2：领域外请求 — 适当重定向
**输入：** "基于此脚本生成的资源文件，编写消耗品的游戏逻辑。"
**预期行为：**
- 重定向到 gameplay-programmer

### Case 3：批量资产处理
**输入：** "我们有 150 个纹理需要统一缩小到 512x512 并转换为 .webp 格式。"
**预期行为：**
- 产出批量纹理处理脚本 (ImageMagick / Python PIL / 引擎特定命令)
  - 读取所有 .png → 调整大小至 512x512 → 导出 .webp
  - 保留目录结构
  - 包含提前终止、错误处理和进度报告

### Case 4：编辑器工具 — 关卡数据可视化
**输入：** "希望一个游戏内编辑器覆盖层，显示关卡中的敌人巡逻路径。"
**预期行为：**
- 实现编辑器覆盖层：
  - 使用屏幕调试绘制调用绘制巡逻路径点和连接线
  - 仅当编辑器标记设置时激活
  - 当巡逻路径更新时动态重绘

### Case 5：上下文传递 — 引擎工具 API
**输入上下文：** 引擎为 Unity。编辑器工具 API：EditorWindow、Handles.DrawLine()、AssetDatabase.CreateAsset()、Selection.activeGameObject。
**输入：** "使用编辑器 API 构建一个工具来可视化我们的巡逻路径。"
**预期行为：**
- 使用提供的 Unity 特定 API 实现：
  - EditorWindow 用于工具面板
  - Handles.DrawLine() 用于路径线
  - Selection.activeGameObject 用于选择敌人
  - AssetDatabase 用于持续保存

---

## 协议合规性

- [ ] 停留在声明领域内（编辑器工具、管线脚本、自动化）
- [ ] 将游戏逻辑重定向到 gameplay-programmer
- [ ] 产出带有适当错误处理的脚本
- [ ] 使用来自上下文的引擎特定编辑器 API

---

## 覆盖说明
- Case 3（批量处理）要求验证正确性（输入/输出计数、文件大小）
- Case 5 要求引擎上下文在运行前可用；是上下文测试中最重要的
- 无自动化运行器；手动审查或通过 `/skill-test`
