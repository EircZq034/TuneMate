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

## 构建运行

```bash
# Windows 桌面
flutter run -d windows --release

# Android
flutter run -d android --release

# 构建 APK
flutter build apk --release
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
