<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Agent Test Spec：unity-addressables-specialist

## Agent 摘要
领域：Addressable Asset System — 分组、异步加载/卸载、句柄生命周期管理、内存预算、内容目录、远程内容交付。
不拥有：渲染系统（engine-programmer）、使用已加载资产的游戏逻辑（gameplay-programmer）。
Model tier：Sonnet（默认）。
未分配 Gate ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 Addressables / 资产加载 / 内容目录 / 远程交付）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] Model tier 为 Sonnet（specialist 默认）
- [ ] Agent 定义不声称对渲染系统或使用已加载资产的 gameplay 拥有权限

---

## 测试用例

### Case 1：域内请求 — 适当的输出
**输入：** "异步加载角色纹理并在角色销毁时释放它。"
**预期行为：**
- 生成 `Addressables.LoadAssetAsync<Texture2D>()` 调用模式
- 将返回的 `AsyncOperationHandle<Texture2D>` 存储在请求对象中
- 在角色销毁（`OnDestroy()`）时，使用存储的句柄调用 `Addressables.Release(handle)`
- 不使用 `Resources.Load()` 作为加载机制
- 注明使用 null 或未初始化的句柄释放会导致错误 — 包含有效性检查
- 注明释放句柄与释放资产之间的区别（应使用句柄释放）

### Case 2：领域外重定向
**输入：** "实现将加载的纹理应用到角色网格的渲染系统。"
**预期行为：**
- 不生成渲染或网格材质分配代码
- 明确声明渲染系统实现属于 `engine-programmer`
- 将请求重定向到 `engine-programmer`
- 可描述作为交接规范的 asset 类型和将要提供的 API 表面（例如句柄完成后提供的 `Texture2D` 引用）

### Case 3：内存泄漏 — 未释放的句柄
**输入：** "每次关卡加载后内存使用量持续攀升。我们使用 Addressables 加载关卡资产。"
**预期行为：**
- 诊断可能的原因：`AsyncOperationHandle` 对象在使用后未被释放
- 识别句柄泄漏模式：将资产加载到局部变量中，丢失引用，从不调用 `Addressables.Release()`
- 生成审计方法：搜索所有 `LoadAssetAsync` / `LoadSceneAsync` 调用并验证匹配的 `Release()` 调用
- 使用带有 `ReleaseAll()` 清理方法的跟踪句柄列表（`List<AsyncOperationHandle>`）提供修正后的模式
- 没有证据就不假设泄漏在其他地方

### Case 4：远程内容交付 — 目录版本控制
**输入：** "我们需要支持可下载内容更新，而不需要完整的应用重新安装。"
**预期行为：**
- 生成远程目录更新模式：
  - 启动时 `Addressables.CheckForCatalogUpdates()`
  - 对检测到的更新调用 `Addressables.UpdateCatalogs()`
  - `Addressables.DownloadDependenciesAsync()` 用于预加载更新内容
- 注明使用目录哈希检查进行变更检测
- 处理边缘情况：如果玩家开始会话，目录在会话中途更新 — 定义行为（在旧目录上完成当前会话，下次启动时重新加载）
- 不设计服务器端 CDN 基础设施（转交 devops-engineer）

### Case 5：上下文传递 — 平台内存约束
**输入：** 平台上下文：Nintendo Switch 目标，4GB RAM，实践资产内存上限 512MB。请求："为大型开放世界关卡设计 Addressables 加载策略。"
**预期行为：**
- 引用所提供上下文中的 512MB 内存上限
- 设计流式传输策略：
  - 将世界划分为基于玩家接近度加载/卸载的可寻址区域
  - 定义每个活动区域的内存预算（例如 128MB，最多 4 个活动区域）
  - 指定异步预加载触发距离和卸载距离（滞后）
- 注明 Switch 特定约束：从 SD 卡加载速度较慢，建议预加载相邻区域
- 不生成明显超出所述 512MB 上限而不标记的加载策略

---

## 协议合规性

- [ ] 停留在声明领域内（Addressables 加载、句柄生命周期、内存、目录、远程交付）
- [ ] 将渲染和 gameplay 资产使用代码重定向到 engine-programmer 和 gameplay-programmer
- [ ] 返回结构化输出（加载模式、句柄生命周期代码、流式区域设计）
- [ ] 始终将 `LoadAssetAsync` 与对应的 `Release()` 配对 — 将句柄泄漏标记为内存 bug
- [ ] 根据提供的内存上限设计加载策略
- [ ] 不设计 CDN/服务器基础设施 — 服务器侧转交 devops-engineer

---

## 覆盖说明
- 句柄生命周期（Case 1）必须包含验证释放后内存被回收的测试
- 句柄泄漏诊断（Case 3）应生成适合作为 bug 工单的发现报告
- 平台内存案例（Case 5）验证 agent 应用来自上下文的硬约束，而非默认假设
