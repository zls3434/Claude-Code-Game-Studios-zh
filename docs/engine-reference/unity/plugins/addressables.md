<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Unity 6.3 — Addressables

**最后验证时间：** 2026-02-13
**状态：** 生产就绪
**包名：** `com.unity.addressables`（Package Manager）

---

## 概述

**Addressables** 是 Unity 的高级资源管理系统，替代 `Resources.Load()`，
提供异步加载、远程内容分发和更好的内存控制。

**适用于 Addressables 的场景：**
- 异步资源加载（非阻塞）
- DLC 和远程内容
- 内存优化（按需加载/卸载）
- 资源依赖管理
- 拥有大量资源的大型项目

**不适用于 Addressables 的场景：**
- 微型项目（开销不值得）
- 启动时立即需要的资源（使用直接引用）

---

## 安装

### 通过 Package Manager 安装

1. `Window > Package Manager`
2. Unity Registry > 搜索 "Addressables"
3. 安装 `Addressables`

---

## 核心概念

### 1. **可寻址资源（Addressable Assets）**
- 标记为 "Addressable" 的资源（分配唯一键）
- 可在运行时通过键加载

### 2. **资源组（Asset Groups）**
- 组织资源（如 "UI"、"Weapons"、"Level1"）
- 组决定构建设置（本地 vs 远程）

### 3. **异步加载（Async Loading）**
- 所有加载均为异步（非阻塞）
- 返回 `AsyncOperationHandle`

### 4. **引用计数（Reference Counting）**
- Addressables 追踪资源使用情况
- 完成后必须手动释放资源

---

## 设置

### 1. 将资源标记为 Addressable

1. 在 Project 窗口中选择资源
2. Inspector > 勾选 "Addressable"
3. 分配键（如 "Enemies/Goblin"）

**或通过脚本：**
```csharp
#if UNITY_EDITOR
using UnityEditor.AddressableAssets;
using UnityEditor.AddressableAssets.Settings;

AddressableAssetSettings.AddAssetEntry(guid, "MyAssetKey", "Default Local Group");
#endif
```

---

### 2. 创建组

`Window > Asset Management > Addressables > Groups`

- **Default Local Group**：随构建打包
- **Remote Group**：托管在服务器（CDN）

---

## 基础加载

### 异步加载资源

```csharp
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class AssetLoader : MonoBehaviour {
    async void Start() {
        // ✅ 异步加载资源
        AsyncOperationHandle<GameObject> handle = Addressables.LoadAssetAsync<GameObject>("Enemies/Goblin");
        await handle.Task;

        if (handle.Status == AsyncOperationStatus.Succeeded) {
            GameObject prefab = handle.Result;
            Instantiate(prefab);
        } else {
            Debug.LogError("加载资源失败");
        }

        // ⚠️ 重要：完成后释放
        Addressables.Release(handle);
    }
}
```

---

### 加载并实例化

```csharp
async void SpawnEnemy() {
    // ✅ 一步加载并实例化
    AsyncOperationHandle<GameObject> handle = Addressables.InstantiateAsync("Enemies/Goblin");
    await handle.Task;

    GameObject enemy = handle.Result;
    // 使用 enemy...

    // ✅ 销毁时释放
    Addressables.ReleaseInstance(enemy);
}
```

---

### 加载多个资源

```csharp
async void LoadAllWeapons() {
    // 加载标签为 "Weapons" 的所有资源
    AsyncOperationHandle<IList<GameObject>> handle = Addressables.LoadAssetsAsync<GameObject>("Weapons", null);
    await handle.Task;

    foreach (var weapon in handle.Result) {
        Debug.Log($"已加载：{weapon.name}");
    }

    Addressables.Release(handle);
}
```

---

## 资源标签（Tags）

### 分配标签

1. `Window > Asset Management > Addressables > Groups`
2. 选择资源 > Inspector > Labels > 添加标签（如 "Level1"、"UI"）

### 按标签加载

```csharp
// 加载标签为 "Level1" 的所有资源
Addressables.LoadAssetsAsync<GameObject>("Level1", null);
```

---

## 远程内容（DLC）

### 设置远程组

1. 创建新组：`Window > Addressables > Groups > Create New Group > Packed Assets`
2. 组设置：
   - **Build Path**：`ServerData/[BuildTarget]`
   - **Load Path**：`http://yourcdn.com/content/[BuildTarget]`

### 构建远程内容

1. `Window > Asset Management > Addressables > Build > New Build > Default Build Script`
2. 将 `ServerData/` 文件夹上传到 CDN
3. 游戏从远程服务器加载资源

---

## 预加载/缓存

### 下载依赖项

```csharp
async void PreloadLevel() {
    // 下载组中的所有资源（不加载到内存）
    AsyncOperationHandle handle = Addressables.DownloadDependenciesAsync("Level1");
    await handle.Task;

    // 现在 "Level1" 资源已缓存，可以立即加载
    Addressables.Release(handle);
}
```

### 检查下载大小

```csharp
async void CheckDownloadSize() {
    AsyncOperationHandle<long> handle = Addressables.GetDownloadSizeAsync("Level1");
    await handle.Task;

    long sizeInBytes = handle.Result;
    Debug.Log($"下载大小：{sizeInBytes / (1024 * 1024)} MB");

    Addressables.Release(handle);
}
```

---

## 内存管理

### 释放资源

```csharp
// ✅ 完成后始终释放
Addressables.Release(handle);

// ✅ 对于实例化对象
Addressables.ReleaseInstance(gameObject);
```

### 检查引用计数

```csharp
// Addressables 使用引用计数
// 当 refCount == 0 时资源被卸载
```

---

## 资源引用（Inspector 分配）

### 使用 AssetReference

```csharp
using UnityEngine.AddressableAssets;

public class EnemySpawner : MonoBehaviour {
    // ✅ 在 Inspector 中分配（拖放）
    public AssetReference enemyPrefab;

    async void SpawnEnemy() {
        AsyncOperationHandle<GameObject> handle = enemyPrefab.InstantiateAsync();
        await handle.Task;

        GameObject enemy = handle.Result;
        // 使用 enemy...

        enemyPrefab.ReleaseInstance(enemy);
    }
}
```

---

## 场景

### 加载可寻址场景

```csharp
using UnityEngine.SceneManagement;

async void LoadScene() {
    AsyncOperationHandle<SceneInstance> handle = Addressables.LoadSceneAsync("MainMenu", LoadSceneMode.Additive);
    await handle.Task;

    SceneInstance sceneInstance = handle.Result;
    // 场景已加载

    // 卸载场景
    await Addressables.UnloadSceneAsync(handle).Task;
}
```

---

## 常见模式

### 延迟加载（按需加载）

```csharp
Dictionary<string, AsyncOperationHandle<GameObject>> loadedAssets = new();

async Task<GameObject> GetAsset(string key) {
    if (!loadedAssets.ContainsKey(key)) {
        var handle = Addressables.LoadAssetAsync<GameObject>(key);
        await handle.Task;
        loadedAssets[key] = handle;
    }
    return loadedAssets[key].Result;
}
```

---

### 场景卸载时清理

```csharp
void OnDestroy() {
    // 释放所有句柄
    foreach (var handle in loadedAssets.Values) {
        Addressables.Release(handle);
    }
    loadedAssets.Clear();
}
```

---

## Content Catalog Updates（在线更新）

### 检查 Catalog 更新

```csharp
async void CheckForUpdates() {
    AsyncOperationHandle<List<string>> handle = Addressables.CheckForCatalogUpdates();
    await handle.Task;

    if (handle.Result.Count > 0) {
        Debug.Log("有可用更新");
        await Addressables.UpdateCatalogs(handle.Result).Task;
    }

    Addressables.Release(handle);
}
```

---

## 性能提示

- 在启动时**预加载**常用资源
- 不再需要时立即**释放**资源
- 使用**标签**批量加载相关资源
- **缓存**远程内容以供离线使用

---

## 调试

### Addressables Event Viewer

`Window > Asset Management > Addressables > Event Viewer`

- 显示所有加载/释放操作
- 每个资源的内存使用量
- 引用计数

### Addressables Profiler

`Window > Asset Management > Addressables > Profiler`

- 实时资源使用情况
- 包加载统计

---

## 从 Resources 迁移

```csharp
// ❌ 旧版：Resources.Load（同步，阻塞帧）
GameObject prefab = Resources.Load<GameObject>("Enemies/Goblin");

// ✅ 新版：Addressables（异步，非阻塞）
var handle = await Addressables.LoadAssetAsync<GameObject>("Enemies/Goblin").Task;
GameObject prefab = handle.Result;
```

---

## 来源
- https://docs.unity3d.com/Packages/com.unity.addressables@2.0/manual/index.html
- https://learn.unity.com/tutorial/addressables
