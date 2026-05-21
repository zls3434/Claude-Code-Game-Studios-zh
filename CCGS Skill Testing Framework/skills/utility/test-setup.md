<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Skill 测试规范：/test-setup

## Skill 摘要

`/test-setup` 为项目搭建测试基础设施。它创建 `tests/` 目录结构，安装所选引擎的测试框架（Godot = GDUnit4，Unity = Test Framework NUnit，Unreal = Automation Framework），生成单元、集成和性能测试的示例测试文件，并创建 `production/qa/ci-config.yaml` CI 配置文件。

该 skill 读取 `technical-preferences.md` 以确定引擎和语言，从而选择合适的框架。每种类型的示例测试文件在创建前需要 "May I write"。如果 `tests/` 目录已存在，skill 提供扩展选项而非覆盖。不适用 director gate。判决：SETUP COMPLETE（所有脚手架已创建）或 PARTIAL（某些文件已存在并跳过）。

---

## 静态断言（结构层面）

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判决关键词：SETUP COMPLETE、PARTIAL
- [ ] 包含 "May I write" 语言（用于测试框架和配置文件的创建）
- [ ] 有下一步交接（例如，`/qa-plan` 开始定义测试，`/smoke-check` 运行测试）

---

## Director Gate 检查

无。`/test-setup` 是一个测试基础设施 skill。不适用 director gate。

---

## 测试用例

### 用例 1：新项目，Godot + GDScript — GDUnit4 脚手架，SETUP COMPLETE

**Fixture：**
- `technical-preferences.md` 引擎设为 Godot 4，Language = GDScript
- `tests/` 目录不存在
- `production/qa/` 目录存在

**输入：** `/test-setup`

**预期行为：**
1. Skill 检测到引擎为 Godot 4
2. Skill 选择 GDUnit4 作为测试框架
3. Skill 创建目录结构：`tests/unit/`、`tests/integration/`、`tests/performance/`
4. Skill 询问 "May I write to `tests/gdunit4_runner.gd`?" 然后写入运行器脚本
5. Skill 询问 "May I write to `tests/unit/example_health_test.gd`?" 然后写入具有健康系统通用测试模式的示例单元测试
6. Skill 依次创建每个示例文件：unit (2 个 Example Pattern 文件)、integration (1 个 Example Pattern)、performance (1 个 Example Pattern)
7. Skill 询问 "May I write to `production/qa/ci-config.yaml`?" 然后写入配置 GDUnit4 的 CI 配置
8. 所有文件创建并写入后，判决为 SETUP COMPLETE

**断言：**
- [ ] GDUnit4 被选用于 Godot（非 NUnit 或 UE Automation）
- [ ] 创建了 tests/ 子目录结构：unit/、integration/、performance/
- [ ] 创建了运行器脚本和示例测试文件
- [ ] 每次文件写入前询问 "May I write"
- [ ] 判决为 SETUP COMPLETE

---

### 用例 2：Tests 目录已存在 — 提供扩展选项，PARTIAL

**Fixture：**
- `technical-preferences.md` 引擎设为 Godot
- `tests/unit/` 目录已存在，包含 1 个测试文件
- `tests/integration/` 和 `tests/performance/` 不存在

**输入：** `/test-setup`

**预期行为：**
1. Skill 检测到 `tests/` 已存在
2. Skill 报告："Tests directory already exists. Existing structure: [summary]"
3. Skill 展示选项：仅创建缺失的目录/文件（扩展）、替换全部、取消
4. 用户选择 "Create missing only"
5. Skill 创建缺失的 `tests/integration/` 和 `tests/performance/`
6. 在缺失目录中写入示例文件
7. 现有测试目录和文件不变
8. 判决为 PARTIAL（某些部分已存在）

**断言：**
- [ ] 检测到现有 tests/ 目录
- [ ] 提供扩展 vs. 替换选项
- [ ] 选择扩展时现有文件不变
- [ ] 判决为 PARTIAL

---

### 用例 3：Unity 引擎 + C# — NUnit 脚手架

**Fixture：**
- `technical-preferences.md` 引擎设为 Unity，Language = C#
- `tests/` 目录不存在

**输入：** `/test-setup`

**预期行为：**
1. Skill 检测到引擎为 Unity
2. Skill 选择 Unity Test Framework (NUnit)
3. 生成 C# 测试文件（.cs 文件）和 `.asmdef` 程序集定义文件
4. 命名约定默认使用 C# 标准（类用 PascalCase）
5. 创建文件前对每个文件询问 "May I write"
6. 判决为 SETUP COMPLETE

**断言：**
- [ ] NUnit 被选用于 Unity（非 GDUnit4）
- [ ] 生成 `.cs` 和 `.asmdef` 测试文件
- [ ] 命名约定遵循 C#（PascalCase）
- [ ] 判决为 SETUP COMPLETE

---

### 用例 4：Unreal Engine — UE Automation Framework 脚手架

**Fixture：**
- `technical-preferences.md` 引擎设为 Unreal Engine 5
- `tests/` 目录不存在

**输入：** `/test-setup`

**预期行为：**
1. Skill 检测到引擎为 Unreal
2. Skill 选择 UE Automation Framework
3. 生成 C++ 测试文件（.cpp 和 .h 文件）
4. 创建测试目录布局和示例文件
5. 判决为 SETUP COMPLETE

**断言：**
- [ ] UE Automation 被选用于 Unreal（非 GDUnit4 或 NUnit）
- [ ] 生成 `.cpp` 和 `.h` 测试文件
- [ ] 判决为 SETUP COMPLETE

---

### 用例 5：Director Gate 检查 — 无 gate；test-setup 是基础设施

**Fixture：**
- 任何引擎配置

**输入：** `/test-setup`

**预期行为：**
1. Skill 搭建测试基础设施
2. 在任何时候都不生成 director agent
3. 输出中不出现 gate ID

**断言：**
- [ ] 不调用任何 director gate
- [ ] 不出现 gate 跳过消息
- [ ] 判决为 SETUP COMPLETE 或 PARTIAL — 无 gate 判决

---

## 协议合规性

- [ ] 从 `technical-preferences.md` 确定引擎/语言
- [ ] 为所选引擎选择正确的框架（Godot=GDUnit4、Unity=NUnit、Unreal=UE Automation）
- [ ] 为每种测试类型生成示例文件
- [ ] 写入 CI 配置文件 `production/qa/ci-config.yaml`
- [ ] 创建文件前询问 "May I write"
- [ ] tests/ 已存在时提供扩展选项
- [ ] 判决为 SETUP COMPLETE 或 PARTIAL

---

## 覆盖说明

- 每个示例文件内容被标记为 `Example Pattern` — 这些不是功能测试，且不在此处更新验证。
- CI 配置内容根据引擎而异（Godot = `godot --headless` 命令，Unity = `unity-editor -runTests`）；确切的命令不进行断言测试。
- `production/qa/` 不存在时，skill 在写入 ci-config.yaml 之前创建它；不单独 fixture 测试。
