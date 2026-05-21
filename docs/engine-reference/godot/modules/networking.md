<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Godot 4.5 — 网络参考

> 最后验证：2026-02-13
> Godot 文档 — [High-level multiplayer](https://docs.godotengine.org/en/4.5/tutorials/networking/high_level_multiplayer.html)

## ENetMultiplayerPeer

Godot 4.5 中默认的高层网络方案。

| 方法 | 用途 | 备注 |
|--------|---------|-------|
| `create_server(port, max_clients, max_channels, in_bandwidth, out_bandwidth)` | 主机游戏 | 返回错误码 |
| `create_client(address, port, channel_count, in_bandwidth, out_bandwidth, local_port)` | 加入游戏 | 连接到服务器 |
| `close()` | 断开连接 | 关闭对等体连接 |
| `get_peer(peer_id)` | 获取对等体信息 | 返回 `ENetPacketPeer` |
| `set_bind_ip(ip)` | 绑定到特定 IP | 多宿主时有用 |

## MultiplayerAPI

通过 `SceneTree` 或 `Node` 访问。

| 属性/方法 | 用途 | 备注 |
|---------------|---------|-------|
| `multiplayer_peer` | 设置活动 `MultiplayerPeer` | 分配 `ENetMultiplayerPeer` |
| `multiplayer.multiplayer_peer = peer` | 在节点上设置 | 通过 `Node.multiplayer` 访问 |
| `peer_connected` | 对等体加入信号 | `signal peer_connected(id: int)` |
| `peer_disconnected` | 对等体离开信号 | `signal peer_disconnected(id: int)` |
| `connected_to_server` | 连接成功信号 | 客户端事件 |
| `connection_failed` | 连接失败信号 | 重试或通知错误 |
| `server_disconnected` | 被服务器踢出信号 | 清理并返回菜单 |
| `get_peers()` | 返回已连接的对等体 ID | 整数数组 |
| `get_unique_id()` | 本地对等体 ID | 服务器为 1，客户端为大于 1 |

## RPC（远程过程调用）

Godot 4.5 使用 `@rpc` 注释，而非旧的 `rpc()` / `rset()` 函数。

```gdscript
# 服务器宣告的 RPC（在所有客户端上调用）
@rpc("authority", "call_remote", "reliable")
func spawn_enemy(type: String, position: Vector3) -> void:
    var enemy := ENEMY_SCENES[type].instantiate()
    enemy.position = position
    add_child(enemy)

# 服务器调用：
func _on_enemy_spawn_request(type: String, pos: Vector3) -> void:
    spawn_enemy.rpc(type, pos)

# 客户端调用服务器：
@rpc("any_peer", "call_local", "reliable")
func request_shoot(weapon_id: int) -> void:
    if not multiplayer.is_server():
        return
    _process_shoot(weapon_id)
```

## MultiplayerSpawner / MultiplayerSynchronizer

自动生成/同步机制。

| 方法 | 用途 |
|--------|---------|
| `MultiplayerSpawner.spawn(path)` | 在所有客户端上实例化场景 |
| `MultiplayerSpawner.spawn_function` | 自定义生成函数 |
| `MultiplayerSynchronizer` | 自动同步节点属性 |

## 权威模型

- **服务器权威** — 服务器处理逻辑，客户端发送输入（默认，安全）
- **客户端权威** — 客户端负责行为（仅限可信环境）

```gdscript
# 设置节点权威
$Player.set_multiplayer_authority(sender_id)

# 检查权威
func _process(delta: float) -> void:
    if is_multiplayer_authority():
        _handle_input()
```

## 常见模式

```gdscript
# 服务器设置
func host_game(port: int = 4567) -> void:
    var peer := ENetMultiplayerPeer.new()
    var err := peer.create_server(port, 4)
    if err != OK:
        return
    multiplayer.multiplayer_peer = peer
    multiplayer.peer_connected.connect(_on_peer_connected)

# 客户端设置
func join_game(address: String = "127.0.0.1", port: int = 4567) -> void:
    var peer := ENetMultiplayerPeer.new()
    var err := peer.create_client(address, port)
    if err != OK:
        return
    multiplayer.multiplayer_peer = peer
```
