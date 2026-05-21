<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->

# Unity 6.3 — 物理模块参考

**最后验证时间：** 2026-02-13
**知识差距：** Unity 6 物理改进、求解器变更

---

## 概述

Unity 6.3 使用 **PhysX 5.1**（相比 2022 LTS 的 PhysX 4.x 有改进）：
- 更好的求解器稳定性
- 改进的性能
- 增强的碰撞检测

---

## 相对于 2022 LTS 的主要变更

### 默认求解器迭代次数增加
Unity 6 为提升稳定性增加了默认求解器迭代次数：

```csharp
// 默认从 6 次迭代改为 8 次迭代
Physics.defaultSolverIterations = 8; // 如依赖旧行为需检查
```

### 增强的碰撞检测

```csharp
// ✅ Unity 6：改进的连续碰撞检测（CCD）
rigidbody.collisionDetectionMode = CollisionDetectionMode.ContinuousDynamic;
// 对快速移动对象有更好的处理
```

---

## 核心物理组件

### Rigidbody

```csharp
// ✅ 最佳实践：使用 AddForce，不要直接写入速度
Rigidbody rb = GetComponent<Rigidbody>();
rb.AddForce(Vector3.forward * 10f, ForceMode.Impulse);

// ❌ 避免：直接赋值速度（可能导致不稳定）
rb.velocity = new Vector3(0, 10, 0); // 仅在必要时使用
```

### Colliders

```csharp
// 原始碰撞体：Box、Sphere、Capsule（开销最低）
// 网格碰撞体：开销大，仅用于静态几何体

// ✅ 复合碰撞体（多个原始碰撞体）> 单个网格碰撞体
```

---

## 射线检测

### 高效的射线检测（避免内存分配）

```csharp
// ✅ 无分配的射线检测
if (Physics.Raycast(origin, direction, out RaycastHit hit, maxDistance)) {
    Debug.Log($"命中：{hit.collider.name}");
}

// ✅ 多个命中（无分配）
RaycastHit[] results = new RaycastHit[10];
int hitCount = Physics.RaycastNonAlloc(origin, direction, results, maxDistance);
for (int i = 0; i < hitCount; i++) {
    Debug.Log($"命中 {i}：{results[i].collider.name}");
}

// ❌ 避免：RaycastAll（每次调用都会分配数组）
RaycastHit[] hits = Physics.RaycastAll(origin, direction); // GC 分配！
```

### LayerMask 用于选择性射线检测

```csharp
// ✅ 使用 LayerMask 过滤碰撞
int layerMask = 1 << LayerMask.NameToLayer("Enemy");
Physics.Raycast(origin, direction, out RaycastHit hit, maxDistance, layerMask);
```

---

## 物理查询

### OverlapSphere（检查附近物体）

```csharp
// ✅ 无分配版本
Collider[] results = new Collider[10];
int count = Physics.OverlapSphereNonAlloc(center, radius, results);
for (int i = 0; i < count; i++) {
    // 处理 results[i]
}
```

### SphereCast（加粗射线检测）

```csharp
// 适用于角色控制器
if (Physics.SphereCast(origin, radius, direction, out RaycastHit hit, maxDistance)) {
    // 用球形射线命中某物
}
```

---

## 碰撞事件

### OnCollisionEnter / Stay / Exit

```csharp
void OnCollisionEnter(Collision collision) {
    // 碰撞开始时触发
    Debug.Log($"与 {collision.gameObject.name} 碰撞");

    // 访问接触点
    foreach (ContactPoint contact in collision.contacts) {
        Debug.DrawRay(contact.point, contact.normal, Color.red, 2f);
    }
}
```

### OnTriggerEnter / Stay / Exit

```csharp
void OnTriggerEnter(Collider other) {
    // 触发器碰撞体（Is Trigger = true）
    if (other.CompareTag("Pickup")) {
        Destroy(other.gameObject);
    }
}
```

---

## 角色控制器

### CharacterController 组件

```csharp
CharacterController controller = GetComponent<CharacterController>();

// ✅ 带碰撞检测的移动
Vector3 move = transform.forward * speed * Time.deltaTime;
controller.Move(move);

// 手动应用重力
if (!controller.isGrounded) {
    velocity.y += Physics.gravity.y * Time.deltaTime;
}
controller.Move(velocity * Time.deltaTime);
```

---

## 物理材质

### 摩擦力与弹性

```csharp
// 创建：Assets > Create > Physic Material
// 分配到 Collider：Collider > Material

// PhysicMaterial 设置：
// - Dynamic Friction：0.6（滑动摩擦）
// - Static Friction：0.6（静摩擦）
// - Bounciness：0.0 - 1.0
// - Friction Combine：Average、Minimum、Maximum、Multiply
// - Bounce Combine：Average、Minimum、Maximum、Multiply
```

---

## 关节

### Fixed Joint（固定两个 Rigidbody）

```csharp
FixedJoint joint = gameObject.AddComponent<FixedJoint>();
joint.connectedBody = otherRigidbody;
```

### Hinge Joint（门、车轮）

```csharp
HingeJoint hinge = gameObject.AddComponent<HingeJoint>();
hinge.axis = Vector3.up; // 旋转轴
hinge.useLimits = true;
hinge.limits = new JointLimits { min = -90, max = 90 };
```

---

## 性能优化

### 物理层碰撞矩阵
`Edit > Project Settings > Physics > Layer Collision Matrix`
- 禁用层之间不必要的碰撞检查
- 性能提升显著

### 固定时间步长
`Edit > Project Settings > Time > Fixed Timestep`
- 默认：0.02（50 FPS 物理）
- 越低 = 精度越高，CPU 开销越大
- 尽可能匹配游戏目标帧率

### 简化碰撞几何体
- 使用原始碰撞体（Box、Sphere、Capsule）而非网格碰撞体
- 在构建时而非运行时烘焙网格碰撞体

---

## 常见模式

### 地面检测（角色控制器）

```csharp
bool IsGrounded() {
    float rayLength = 0.1f;
    return Physics.Raycast(transform.position, Vector3.down, rayLength);
}
```

### 施加爆炸力

```csharp
void ApplyExplosion(Vector3 explosionPos, float radius, float force) {
    Collider[] colliders = Physics.OverlapSphere(explosionPos, radius);
    foreach (Collider hit in colliders) {
        Rigidbody rb = hit.GetComponent<Rigidbody>();
        if (rb != null) {
            rb.AddExplosionForce(force, explosionPos, radius);
        }
    }
}
```

---

## 调试

### Physics Debugger（Unity 6+）
- `Window > Analysis > Physics Debugger`
- 可视化碰撞体、接触点、查询

### Gizmos

```csharp
void OnDrawGizmos() {
    Gizmos.color = Color.red;
    Gizmos.DrawWireSphere(transform.position, detectionRadius);
}
```

---

## 来源
- https://docs.unity3d.com/6000.0/Documentation/Manual/PhysicsOverview.html
- https://docs.unity3d.com/ScriptReference/Physics.html
