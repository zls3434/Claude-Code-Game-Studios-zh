<!-- 翻译修改：2026-05-20, 修改人: zls3434 -->
# Unreal Engine 5.7 — CommonUI 插件

**最后验证：** 2026-02-13
**状态：** 生产就绪
**插件：** `CommonUI`（内置，在 Plugins 中启用）

---

## 概述

**CommonUI** 是一个跨平台 UI 框架，可以自动处理手柄、鼠标和触控的输入路由。
它专为需要在 PC、主机和移动端平台之间无缝运行、且平台特定代码最少的游戏而设计。

**适用于 CommonUI 的场景：**
- 多平台游戏（主机 + PC）
- 自动手柄/鼠标/触控输入路由
- 输入无关的 UI（同一 UI 适用于任何输入方式）
- Widget 焦点和导航
- 操作栏和输入提示

**不适合 CommonUI 的场景：**
- 仅限 PC、仅使用鼠标的 UI（标准 UMG 更简单）
- 无需导航的简单 UI

---

## 与标准 UMG 的主要区别

| 特性 | 标准 UMG | CommonUI |
|---------|--------------|----------|
| **输入处理** | 每个 Widget 手动处理 | 自动路由 |
| **焦点管理** | 基础 | 高级导航 |
| **平台切换** | 手动检测 | 自动 |
| **输入提示** | 硬编码图标 | 按平台动态切换 |
| **界面栈** | 手动管理 | 内置可激活 Widget |

---

## 设置

### 1. 启用插件

`Edit > Plugins > CommonUI > Enabled > Restart`

### 2. 配置项目设置

`Project Settings > Plugins > CommonUI`：
- **Default Input Type**：Gamepad（或自动检测）
- **Platform-Specific Settings**：按平台配置输入图标

### 3. 创建 Common Input Settings 资产

1. Content Browser > Input > Common Input Settings
2. 按平台配置输入数据：
   - Default Gamepad Data
   - Default Mouse & Keyboard Data
   - Default Touch Data

---

## 核心 Widget

### CommonActivatableWidget（界面管理）

可激活/停用的屏幕/菜单的基类。

```cpp
#include "CommonActivatableWidget.h"

UCLASS()
class UMyMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    virtual void NativeOnActivated() override {
        Super::NativeOnActivated();
        // 菜单现在可见且已获得焦点
        UE_LOG(LogTemp, Warning, TEXT("Menu activated"));
    }

    virtual void NativeOnDeactivated() override {
        Super::NativeOnDeactivated();
        // 菜单现在已隐藏
        UE_LOG(LogTemp, Warning, TEXT("Menu deactivated"));
    }

    virtual UWidget* NativeGetDesiredFocusTarget() const override {
        // 返回应获得焦点的 Widget（例如第一个按钮）
        return PlayButton;
    }

private:
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> PlayButton;
};
```

---

### CommonButtonBase（输入感知按钮）

替代标准 UMG Button。自动处理手柄/鼠标/键盘输入。

```cpp
#include "CommonButtonBase.h"

UCLASS()
class UMyMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> PlayButton;

    virtual void NativeConstruct() override {
        Super::NativeConstruct();

        // 绑定按钮点击（适用于任何输入方式）
        PlayButton->OnClicked().AddUObject(this, &UMyMenuWidget::OnPlayClicked);

        // 设置按钮文本
        PlayButton->SetButtonText(FText::FromString(TEXT("Play")));
    }

    void OnPlayClicked() {
        UE_LOG(LogTemp, Warning, TEXT("Play clicked"));
    }
};
```

---

### CommonTextBlock（带样式的文本）

支持 CommonUI 样式的文本控件。

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonTextBlock> TitleText;

TitleText->SetText(FText::FromString(TEXT("Main Menu")));
```

---

### CommonActionWidget（输入提示）

显示输入提示（例如"按 A 继续"，自动显示正确的按钮图标）。

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonActionWidget> ConfirmActionWidget;

// 绑定到输入操作
ConfirmActionWidget->SetInputAction(ConfirmInputActionData);
// 自动显示正确的图标（Xbox 上为 A，PlayStation 上为 Cross，PC 上为 Enter）
```

---

## Widget Stack（界面管理）

### CommonActivatableWidgetStack

管理界面栈（例如 主菜单 → 设置 → 操控）。

```cpp
#include "Widgets/CommonActivatableWidgetContainer.h"

UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonActivatableWidgetStack> WidgetStack;

// 将新界面压入栈中
void ShowSettingsMenu() {
    WidgetStack->AddWidget(USettingsMenuWidget::StaticClass());
}

// 弹出当前界面（返回）
void GoBack() {
    WidgetStack->DeactivateWidget();
}
```

---

## Input Actions（CommonUI 方式）

### 定义 Input Actions

创建 **Common Input Action Data Table**：
1. Content Browser > Miscellaneous > Data Table
2. 行结构：`CommonInputActionDataBase`
3. 为操作添加行（Confirm、Cancel、Navigate 等）

示例行：
- **Action Name**：Confirm
- **Default Input**：Gamepad Face Button Bottom（A/Cross）
- **Alternate Inputs**：Enter（键盘）、Left Mouse Button

---

### 在 Widget 中绑定 Input Actions

```cpp
#include "Input/CommonUIActionRouterBase.h"

UCLASS()
class UMyWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    virtual void NativeOnActivated() override {
        Super::NativeOnActivated();

        // 绑定输入操作
        FBindUIActionArgs BindArgs(ConfirmInputAction, FSimpleDelegate::CreateUObject(this, &UMyWidget::OnConfirm));
        BindArgs.bDisplayInActionBar = true; // 在操作栏中显示
        RegisterUIActionBinding(BindArgs);
    }

    void OnConfirm() {
        UE_LOG(LogTemp, Warning, TEXT("Confirmed"));
    }

private:
    UPROPERTY(EditDefaultsOnly, Category = "Input")
    FDataTableRowHandle ConfirmInputAction;
};
```

---

## 焦点与导航

### 自动手柄导航

CommonUI 自动处理手柄导航（使用 D-Pad/摇杆在按钮之间移动）。

```cpp
// 在 Widget Blueprint 中：
// - 如果 Widget 继承自 CommonButton/CommonUserWidget，则自动支持导航
// - 焦点顺序由 Widget 层级结构和布局决定
```

### 自定义焦点导航

```cpp
// 覆盖焦点导航
virtual UWidget* NativeGetDesiredFocusTarget() const override {
    return FirstButton; // 返回应获得焦点的 Widget
}
```

---

## 输入模式（游戏 vs UI）

### 切换输入模式

```cpp
#include "CommonUIExtensions.h"

// 切换到仅 UI 模式（暂停游戏，显示光标）
UCommonUIExtensions::PushStreamedGameplayUIInputConfig(this, FrontendInputConfig);

// 返回游戏模式（隐藏光标，恢复游戏）
UCommonUIExtensions::PopInputConfig(this);
```

---

## 平台特定的输入图标

### 配置输入图标

1. 为每个平台创建 **Common Input Base Controller Data** 资产：
   - Gamepad（Xbox、PlayStation、Switch）
   - Mouse & Keyboard
   - Touch

2. 分配平台特定图标：
   - Gamepad Face Button Bottom：`A`（Xbox）、`Cross`（PlayStation）
   - Confirm Key：`Enter` 图标

3. 分配到 **Common Input Settings** 资产

### 自动显示正确的图标

```cpp
// CommonActionWidget 自动显示当前平台对应的正确图标
UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonActionWidget> JumpActionWidget;

JumpActionWidget->SetInputAction(JumpInputActionData);
// Xbox 上显示 "A"，PlayStation 上显示 "Cross"，PC 上显示 "Space"
```

---

## 常见模式

### 带导航的主菜单

```cpp
UCLASS()
class UMainMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> PlayButton;

    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> SettingsButton;

    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> QuitButton;

    virtual void NativeConstruct() override {
        Super::NativeConstruct();

        PlayButton->OnClicked().AddUObject(this, &UMainMenuWidget::OnPlayClicked);
        SettingsButton->OnClicked().AddUObject(this, &UMainMenuWidget::OnSettingsClicked);
        QuitButton->OnClicked().AddUObject(this, &UMainMenuWidget::OnQuitClicked);
    }

    virtual UWidget* NativeGetDesiredFocusTarget() const override {
        return PlayButton; // 菜单打开时聚焦 "Play" 按钮
    }

    void OnPlayClicked() { /* 开始游戏 */ }
    void OnSettingsClicked() { /* 打开设置 */ }
    void OnQuitClicked() { /* 退出游戏 */ }
};
```

---

### 带返回操作的暂停菜单

```cpp
UCLASS()
class UPauseMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    UPROPERTY(EditDefaultsOnly, Category = "Input")
    FDataTableRowHandle BackInputAction; // 在 Blueprint 中分配 "Cancel" 操作

    virtual void NativeOnActivated() override {
        Super::NativeOnActivated();

        // 绑定 "Back" 输入（B/Circle/Escape）
        FBindUIActionArgs BindArgs(BackInputAction, FSimpleDelegate::CreateUObject(this, &UPauseMenuWidget::OnBack));
        RegisterUIActionBinding(BindArgs);
    }

    void OnBack() {
        DeactivateWidget(); // 关闭暂停菜单
    }
};
```

---

## 性能提示

- 使用 **CommonActivatableWidgetStack** 进行界面管理（自动处理激活/停用）
- 避免每帧创建/销毁 Widget（复用 Widget）
- 复杂菜单使用 **Lazy Widgets**（仅在需要时创建）

---

## 调试

### CommonUI 调试命令

```cpp
// Console commands:
// CommonUI.DumpActivatableTree - 显示活跃 Widget 层级结构
// CommonUI.DumpActionBindings - 显示已注册的输入操作
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/commonui-plugin-for-advanced-user-interfaces-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/commonui-quickstart-guide-for-unreal-engine/
