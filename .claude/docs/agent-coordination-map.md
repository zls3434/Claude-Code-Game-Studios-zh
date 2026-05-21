<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Agent 协调与委派关系图

## 组织层级

```
                           [人类开发者]
                                 |
                 +---------------+---------------+
                 |               |               |
         creative-director  technical-director  producer
                 |               |               |
        +--------+--------+     |        (协调所有)
        |        |        |     |
  game-designer art-dir  narr-dir  lead-programmer  qa-lead  audio-dir
        |        |        |         |                |        |
     +--+--+     |     +--+--+  +--+--+--+--+--+   |        |
     |  |  |     |     |  |  |  |  |  |  |  |  |   |        |
    sys lvl eco  ta   wrt wrld gp ep  ai net tl ui qa-t    snd
                                 |
                             +---+---+
                             |       |
                          perf-a   devops   analytics

  其他负责人（向 producer/director 汇报）：
    release-manager         -- 发布管线、版本管理、部署
    localization-lead       -- 国际化、字符串表、翻译管线
    prototyper              -- 快速一次性原型、概念验证
    security-engineer       -- 反作弊、漏洞防护、数据隐私、网络安全
    accessibility-specialist -- WCAG、色盲适配、按键重映射、文字缩放
    live-ops-designer       -- 赛季、活动、通行证、留存、线上经济
    community-manager       -- 更新说明、玩家反馈、危机沟通

  引擎专业 Agent（使用与你的引擎匹配的集合）：
    unreal-specialist  -- UE5 负责人：Blueprint/C++、GAS 概览、UE 子系统
      ue-gas-specialist         -- GAS：技能、效果、属性、标签、预测
      ue-blueprint-specialist   -- Blueprint：BP/C++ 边界、图表规范、优化
      ue-replication-specialist -- 网络：同步复制、RPC、预测、带宽
      ue-umg-specialist         -- UI：UMG、CommonUI、组件层级、数据绑定

    unity-specialist   -- Unity 负责人：MonoBehaviour/DOTS、Addressables、URP/HDRP
      unity-dots-specialist         -- DOTS/ECS：Jobs、Burst、混合渲染器
      unity-shader-specialist       -- Shader：Shader Graph、VFX Graph、SRP 定制
      unity-addressables-specialist -- 资源：异步加载、Bundle、内存、CDN
      unity-ui-specialist           -- UI：UI Toolkit、UGUI、UXML/USS、数据绑定

    godot-specialist   -- Godot 4 负责人：GDScript、节点/场景、信号、资源
      godot-gdscript-specialist    -- GDScript：静态类型、模式、信号、性能
      godot-csharp-specialist      -- C#：.NET 模式、[Signal] 委托、async、类型安全节点访问
      godot-shader-specialist      -- Shader：Godot 着色语言、可视化 Shader、VFX
      godot-gdextension-specialist -- 原生：C++/Rust 绑定、GDExtension、构建系统
```

### 图例
```
sys  = systems-designer       gp  = gameplay-programmer
lvl  = level-designer         ep  = engine-programmer
eco  = economy-designer       ai  = ai-programmer
ta   = technical-artist       net = network-programmer
wrt  = writer                 tl  = tools-programmer
wrld = world-builder          ui  = ui-programmer
snd  = sound-designer         qa-t = qa-tester
narr-dir = narrative-director perf-a = performance-analyst
art-dir = art-director
```

## 委派规则

### 谁可以委派给谁

| 委派方 | 可委派至 |
|------|----------------|
| creative-director | game-designer、art-director、audio-director、narrative-director |
| technical-director | lead-programmer、devops-engineer、performance-analyst、technical-artist（技术决策相关） |
| producer | 任意 Agent（仅限其领域内的任务分配） |
| game-designer | systems-designer、level-designer、economy-designer |
| lead-programmer | gameplay-programmer、engine-programmer、ai-programmer、network-programmer、tools-programmer、ui-programmer |
| art-director | technical-artist、ux-designer |
| audio-director | sound-designer |
| narrative-director | writer、world-builder |
| qa-lead | qa-tester |
| release-manager | devops-engineer（发布构建）、qa-lead（发布测试） |
| localization-lead | writer（字符串审查）、ui-programmer（文本适配） |
| prototyper | （独立工作，将发现报告给 producer 和相关负责人） |
| security-engineer | network-programmer（安全审查）、lead-programmer（安全模式） |
| accessibility-specialist | ux-designer（无障碍模式）、ui-programmer（实现）、qa-tester（无障碍测试） |
| [engine]-specialist | 引擎子专业 Agent（委派子系统特定工作） |
| [engine] 子专业 Agent | （向所有程序员提供引擎子系统模式和优化建议） |
| live-ops-designer | economy-designer（线上经济）、community-manager（活动沟通）、analytics-engineer（参与度指标） |
| community-manager | （与 producer 协调以获得批准，与 release-manager 协调更新说明发布时间） |

### 上报路径

| 场景 | 上报至 |
|-----------|------------|
| 两位设计师对某一机制意见不一 | game-designer |
| 游戏设计与叙事冲突 | creative-director |
| 游戏设计与技术可行性冲突 | producer（促进协调），然后 creative-director + technical-director |
| 美术与音频风格冲突 | creative-director |
| 代码架构分歧 | technical-director |
| 跨系统代码冲突 | lead-programmer，然后 technical-director |
| 部门间排期冲突 | producer |
| 范围超出产能 | producer，然后由 creative-director 进行裁剪决策 |
| 质量关卡分歧 | qa-lead，然后 technical-director |
| 性能预算违规 | performance-analyst 标记，technical-director 决策 |

## 常见工作流模式

### 模式 1：新功能（完整管线）

```
1. creative-director  -- 批准功能概念与愿景一致
2. game-designer      -- 创建包含完整规范的设计文档
3. producer           -- 安排工作，识别依赖关系
4. lead-programmer    -- 设计代码架构，创建接口草图
5. [专业程序员]         -- 实现功能
6. technical-artist   -- 实现视觉效果（如需要）
7. writer             -- 创建文本内容（如需要）
8. sound-designer     -- 创建音频事件列表（如需要）
9. qa-tester          -- 编写测试用例
10. qa-lead           -- 审查并批准测试覆盖率
11. lead-programmer   -- 代码审查
12. qa-tester         -- 执行测试
13. producer          -- 标记任务完成
```

### 模式 2：Bug 修复

```
1. qa-tester          -- 使用 /bug-report 提交 Bug 报告
2. qa-lead            -- 分类严重性和优先级
3. producer           -- 分配到 Sprint（如果不是 S1 级别）
4. lead-programmer    -- 识别根因，分配给程序员
5. [专业程序员]         -- 修复 Bug
6. lead-programmer    -- 代码审查
7. qa-tester          -- 验证修复并运行回归测试
8. qa-lead            -- 关闭 Bug
```

### 模式 3：数值平衡调整

```
1. analytics-engineer -- 从数据（或玩家报告）中识别不平衡
2. game-designer      -- 根据设计意图评估问题
3. economy-designer   -- 模拟调整
4. game-designer      -- 批准新数值
5. [数据文件更新]       -- 变更配置数值
6. qa-tester          -- 回归测试受影响的系统
7. analytics-engineer -- 监控变更后的指标
```

### 模式 4：新区域/关卡

```
1. narrative-director -- 定义该区域的叙事目的和节奏点
2. world-builder      -- 创建背景和环境上下文
3. level-designer     -- 设计布局、遭遇、节奏
4. game-designer      -- 审查遭遇的机制设计
5. art-director       -- 定义该区域的视觉方向
6. audio-director     -- 定义该区域的音频方向
7. [相关程序员和美术师进行实现]
8. writer             -- 创建区域特定文本内容
9. qa-tester          -- 测试完整区域
```

### 模式 5：Sprint 周期

```
1. producer           -- 使用 /sprint-plan new 规划 Sprint
2. [所有 Agent]        -- 执行分配的任务
3. producer           -- 使用 /sprint-plan status 进行每日状态检查
4. qa-lead            -- Sprint 期间持续测试
5. lead-programmer    -- Sprint 期间持续代码审查
6. producer           -- 使用 post-sprint Hook 进行 Sprint 回顾
7. producer           -- 纳入经验教训，规划下一个 Sprint
```

### 模式 6：里程碑检查点

```
1. producer           -- 运行 /milestone-review
2. creative-director  -- 审查创意进度
3. technical-director -- 审查技术健康度
4. qa-lead            -- 审查质量指标
5. producer           -- 促进通过/不通过的讨论
6. [所有总监]          -- 就必要的范围调整达成一致
7. producer           -- 记录决策并更新计划
```

### 模式 7：发布管线

```text
1. producer             -- 声明候选发布版本，确认里程碑标准已满足
2. release-manager      -- 切出发布分支，生成 /release-checklist
3. qa-lead              -- 运行完整回归测试，签收质量
4. localization-lead    -- 验证所有字符串已翻译，文本适配通过
5. performance-analyst  -- 确认性能基准在目标范围内
6. devops-engineer      -- 构建发布产物，运行部署管线
7. release-manager      -- 生成 /changelog，标记版本，创建发布说明
8. technical-director   -- 重大版本最终签收
9. release-manager      -- 部署并监控 48 小时
10. producer            -- 标记发布完成
```

### 模式 8：概念原型（早期 — GDD 编写之前）

```text
1. game-designer        -- 定义假设和成功标准
2. prototyper           -- 使用 /prototype 搭建概念原型
3. prototyper           -- 构建最小实现（1-3 天）
4. game-designer        -- 根据标准评估原型
5. prototyper           -- 在 REPORT.md 中记录发现
6. creative-director    -- PROCEED / PIVOT / KILL 决策（仅 full 模式）
7. game-designer        -- 如果 PROCEED，将原型经验纳入 GDD 编写
```

### 模式 8b：垂直切片（预生产 — GDD 和架构之后）

```text
1. game-designer        -- 根据 GDD 确认切片范围
2. prototyper           -- 使用 /vertical-slice 构建生产级端到端构建
3. prototyper           -- 进行内部试玩会话（最少 1 次）
4. prototyper           -- 在 REPORT.md 中记录发现
5. creative-director    -- 决定是否进入 Production（仅 full 模式）
6. producer             -- 如果 PROCEED，排期 Production Epic/Sprint
```

### 模式 9：线上活动 / 赛季发布

```text
1. live-ops-designer     -- 设计活动/赛季内容、奖励、排期
2. game-designer         -- 验证活动玩法机制
3. economy-designer      -- 平衡活动经济和奖励价值
4. narrative-director    -- 提供赛季叙事主题
5. writer                -- 创建活动描述和背景
6. producer              -- 安排实现工作
7. [相关程序员进行实现]
8. qa-lead               -- 端到端测试活动流程
9. community-manager     -- 起草活动公告和更新说明
10. release-manager      -- 部署活动内容
11. analytics-engineer   -- 监控活动参与度和指标
12. live-ops-designer    -- 活动后分析和经验总结
```

## 跨领域沟通协议

### 设计变更通知

当设计文档发生变更时，game-designer 必须通知：
- lead-programmer（实现影响）
- qa-lead（需要更新测试计划）
- producer（排期影响评估）
- 根据变更内容，通知相关专业 Agent

### 架构变更通知

当 ADR 被创建或修改时，technical-director 必须通知：
- lead-programmer（需要代码变更）
- 所有受影响的专业程序员
- qa-lead（测试策略可能变更）
- producer（排期影响）

### 资源标准变更通知

当美术圣经或资源标准发生变更时，art-director 必须通知：
- technical-artist（管线变更）
- 所有使用受影响资源的内容创作者
- devops-engineer（如果构建管线受影响）

## 应避免的反模式

1. **绕过层级**：专业 Agent 绝不应在不咨询的情况下做出属于其上级的决策。
2. **跨领域实现**：Agent 绝不应未经相关所有者的明确委派就修改其指定领域之外的文件。
3. **影子决策**：所有决策必须文档化。没有书面记录的口头协议会导致矛盾。
4. **巨型任务**：分配给 Agent 的每个任务应在 1-3 天内可完成。如果更大，必须先分解。
5. **基于假设的实现**：如果规范模糊不清，实现者必须询问规范制定者，而不是猜测。错误的猜测比提问代价更高。
