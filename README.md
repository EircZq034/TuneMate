# TuneMate | EircZ

吉他特调指弹助手 — 专为指弹吉他玩家设计的跨平台工具应用

## 功能特性

### 和弦走向

- 7 个调式可选 (C/D/E/F/G/A/B)
- 6 组流行和弦走向 (I-vi-IV-V / I-V-vi-IV / IV-V-iii-vi 等)
- 实时音阶显示
- Canvas 动态绘制和弦指法图，横向滚动

### 指板可视化

- 12/15/18/21 品可选
- 基于特调方案动态计算每品每弦音名
- 自然音与升降号音视觉区分
- 横屏自适应紧凑模式

### 特调管理

- 7 种内置特调 (Standard / Drop D / DADGAD / CGDGAD / Open D / Open G / Drop C)
- 自定义特调：输入目标音名，自动计算变调夹配置
- 等音转换 (Db/Eb/Gb/Ab/Bb 自动标准化)
- 重复检测 (名称 + 音名配置)
- 收藏系统，SQLite 持久化

### 设置

- 深色/浅色主题切换
- 中文/English 双语

## 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter / Dart |
| 状态管理 | Provider |
| 数据持久化 | sqflite (SQLite) |
| 本地缓存 | SharedPreferences |
| UI 绘制 | Canvas CustomPaint |
| 国际化 | flutter_localizations + intl |

## 安装使用

### 📱 Android 手机

直接从 [Releases](../../releases) 页面下载最新 `TuneMate-android.apk`，传到手机安装即可。

> 安装时需要允许"安装未知来源应用"。如果系统提示安全风险，选择"继续安装"或"信任此来源"。

**系统要求**：Android 5.0 (API 21) 及以上

### 💻 Windows 电脑

#### 方式一：下载预构建程序（推荐）

从 [Releases](../../releases) 页面下载最新的 `TuneMate-windows.zip`，解压后双击 `TuneMate.exe` 即可运行，无需安装任何开发环境。

> 系统要求：Windows 10 及以上，64 位

#### 方式二：从源码构建

需要安装 Flutter 开发环境：

- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (3.44.1+)
- [Visual Studio 2022](https://visualstudio.microsoft.com/zh-hans/)（勾选"使用 C++ 的桌面开发"）
- [Android Studio](https://developer.android.com/studio)（仅 Android 构建需要）

```bash
# Windows 桌面
flutter build windows --release
# 输出: build/windows/x64/runner/Release/TuneMate.exe

# Android APK
flutter build apk --release
# 输出: build/app/outputs/flutter-apk/app-release.apk（可重命名为 TuneMate-android.apk）
```

## 项目结构

```
lib/
├── main.dart                 # 入口
├── app.dart                  # MaterialApp 配置
├── models/                   # 数据模型 (Chord, StringTuning, TuningScheme)
├── data/                     # 内置数据 (和弦、走向、特调)
├── providers/                # 状态管理 (4 个 Provider)
├── screens/                  # 页面 (8 个)
├── widgets/                  # 可复用组件 (5 个)
├── services/                 # 数据服务 (SQLite / SharedPreferences)
├── utils/                    # 工具类 (常量 / 音名计算)
└── l10n/                     # 国际化 (中/英)
```

## 作者

[@EircZ](https://github.com/EircQH)

## 开发日期

2026-06-06 ~ 2026-06-07
