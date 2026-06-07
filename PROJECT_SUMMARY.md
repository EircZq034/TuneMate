# TuneMate — 吉他特调指弹助手

## 项目简介

面向指弹吉他玩家的跨平台工具应用，支持特调弦方案管理、可视化指板、和弦查询与流行和弦走向展示。用户只需输入各弦目标音名，系统自动计算变调夹配置。使用 Flutter 构建，同时支持 Android 和 Windows。

**作者**：@EircZ
**版本**：v1.0.0
**开发日期**：2026-06-06 ~ 2026-06-07

---

## 技术栈

| 层级 | 技术选型 |
|------|---------|
| 框架 | Flutter 3.44.1 / Dart 3.12.1 |
| 状态管理 | Provider (ChangeNotifier + Consumer) |
| 数据持久化 | sqflite (SQLite) |
| 本地缓存 | SharedPreferences |
| 国际化 | flutter_localizations + intl (中/英) |
| UI 绘制 | Canvas CustomPaint (和弦图/指板) |
| 唯一 ID | uuid v4 |

---

## 项目结构

```
TuneMate/
├── lib/
│   ├── main.dart                          # 入口 (runApp)
│   ├── app.dart                           # MaterialApp 配置、MultiProvider、主题、路由、国际化
│   │
│   ├── models/                            # 数据模型
│   │   ├── chord.dart                     # 和弦模型 (id, key, type, name, frets[6], fingers[6], baseFret)
│   │   ├── string_tuning.dart             # 单弦调音 (stringNumber, capoFret, referenceString)
│   │   └── tuning_scheme.dart             # 特调方案 (id, nameZh/En, descZh/En, isBuiltIn, isFavorite, strings)
│   │
│   ├── data/                              # 内置数据
│   │   ├── built_in_tunings.dart          # 7 种经典特调 (Standard, Drop D, DADGAD, CGDGAD, Open D, Open G, Drop C)
│   │   ├── built_in_chords.dart           # 49 个和弦指法 (7 调 × 7 类型 + 7 补充和弦)
│   │   └── chord_progressions.dart        # 6 组流行和弦走向 (含示例曲目)
│   │
│   ├── providers/                         # 状态管理
│   │   ├── tuning_provider.dart           # 特调 CRUD + 收藏 + 内置/自定义分类
│   │   ├── chord_provider.dart            # 和弦查询 + 调式选择
│   │   ├── fretboard_provider.dart        # 指板音名网格 + 品数 + 特调联动
│   │   └── settings_provider.dart         # 深色/浅色主题 + 中/英文语言
│   │
│   ├── screens/                           # 页面
│   │   ├── home_screen.dart               # 底部导航 (3 Tab: 和弦/指板/特调) + 设置入口
│   │   ├── chord_screen.dart              # 和弦走向展示 (7 调式 × 6 走向，横向滚动和弦图)
│   │   ├── chord_detail_screen.dart       # 和弦详情 (大尺寸指法图)
│   │   ├── fretboard_screen.dart          # 指板可视化 (12/15/18/21 品，横屏自适应)
│   │   ├── tuning_screen.dart             # 特调列表 (交错入场动画，收藏/选中状态)
│   │   ├── tuning_detail_screen.dart      # 特调详情 (6 弦调音指示，收藏/删除)
│   │   ├── tuning_form_screen.dart        # 自定义特调表单 (音名输入→自动计算变调夹)
│   │   └── settings_screen.dart           # 设置 (主题/语言/关于/开发者鸣谢)
│   │
│   ├── widgets/                           # 可复用组件
│   │   ├── chord_diagram.dart             # Canvas 和弦指法图 (动态 4/5 品格，2:3 比例)
│   │   ├── chord_grid_item.dart           # 和弦网格卡片
│   │   ├── fretboard_grid.dart            # Canvas 指板网格 (横滚+鼠标滚轮，紧凑模式)
│   │   ├── string_instruction.dart        # 单弦调音指示器 (入场动画，绿/橙色状态)
│   │   └── tuning_card.dart               # 特调方案卡片 (选中边框，收藏星标)
│   │
│   ├── services/                          # 服务层
│   │   ├── database_service.dart          # SQLite 单例 (custom_tunings 表 CRUD)
│   │   └── shared_prefs_service.dart      # SharedPreferences (主题/语言/收藏)
│   │
│   ├── utils/                             # 工具类
│   │   ├── constants.dart                 # 常量 (标准调弦、12 音名、自然音)
│   │   └── note_utils.dart                # 音名计算 (品格推算、指板音名网格、特调空弦音)
│   │
│   └── l10n/                              # 国际化
│       ├── app_localizations.dart          # 抽象类
│       ├── app_localizations_zh.dart       # 中文
│       └── app_localizations_en.dart       # 英文
│
├── android/app/src/main/AndroidManifest.xml  # Android 配置 (app label: TuneMate)
├── windows/                               # Windows 平台配置
├── pubspec.yaml                           # 依赖配置
└── l10n.yaml                              # 国际化配置
```

---

## 核心功能模块

### 1. 和弦走向 (首页 Tab 1)

- **7 个调式可选**：C / D / E / F / G / A / B，顶部水平 ChoiceChip 切换
- **6 组流行和弦走向**：
  - 1-6-4-5 经典流行 (Let It Be, 童话, 好久不见)
  - 1-5-6-4 万能走向 (Someone Like You, 平凡之路, 小幸运)
  - 4-5-3-6 卡农变体 (Canon in D, 征服, 匆匆那年)
  - 1-4-5-1 基础摇滚 (Twist and Shout)
  - 6-4-1-5 抒情走向 (夜曲, 说好的幸福, 蒲公英的约定)
  - 1-6-2-5 爵士经典 (Fly Me to the Moon, Autumn Leaves)
- **音阶显示**：所选调式的大调音阶音名 (全全半全全全半)
- **和弦图**：Canvas 动态绘制，横向滚动，点击进入详情大图
- **数据规模**：49 和弦 × 7 调式 × 6 走向 = 2058 种组合

### 2. 指板可视化 (首页 Tab 2)

- **品数可选**：12 / 15 / 18 / 21 品，PopupMenuButton 切换
- **动态音名计算**：基于当前特调方案，实时计算每品每弦的音名
- **视觉区分**：自然音（加粗 + 主色背景）、升降号音（灰色）
- **空弦标记**：灰色背景 + 橙色右边框
- **横屏自适应**：检测屏幕方向，自动切换紧凑布局（更小的格子和字体）
- **鼠标滚轮**：桌面端支持鼠标滚轮横向滚动指板
- **特调联动**：切换特调方案时指板自动更新

### 3. 特调管理 (首页 Tab 3)

- **7 种内置特调**：Standard, Drop D, DADGAD, CGDGAD (Low C), Open D, Open G, Drop C
- **交错入场动画**：每张卡片延迟递增 (300 + index × 50ms)，从下方滑入 + 淡入
- **收藏系统**：星标收藏，SharedPreferences 持久化
- **自定义特调**：点击 FAB (+号) 进入创建表单

#### 自定义特调表单

- **简化输入**：方案名 + 代表曲目 + 6 根弦的目标音名
- **智能默认**：未填写的弦自动使用标准调弦音 (E B G D A E)
- **等音转换**：支持 Db/Eb/Gb/Ab/Bb 等降号写法自动转为升号
- **变调夹自动计算**：优先自身弦+变调夹 (≤7品)，备选其他弦+变调夹
- **错误校验**：音名无效或超出变调夹范围时弹窗提示
- **重复检测**：名称重复（不区分大小写）或音名配置与已有特调一致时阻止保存
- **保存动画**：全屏半透明遮罩 + 转圈加载 + FadeTransition (1500ms)
- **成功弹窗**：显示方案名和各弦配置摘要 (含变调夹品数)

#### 特调详情页

- **6 弦调音指示**：每根弦独立显示目标音名、是否需要变调夹
- **入场动画**：TweenAnimationBuilder，400 + index × 100ms，easeOutBack 曲线
- **收藏切换**：AppBar 星标按钮
- **删除功能**：仅自定义特调显示红色删除按钮，弹窗确认后删除
- **内置保护**：前 7 个内置特调不显示删除按钮
- **数据安全**：Provider 层 assert 断言防护，禁止通过代码误删/误增内置特调；内置数据为 Dart 硬编码 const，与 SQLite 自定义数据物理隔离

### 4. 设置页面

- **深色模式**：默认深色，SwitchListTile 切换，动态图标
- **语言切换**：中文 (zh-CN) / English (en-US)，RadioListTile
- **关于**：作者 @EircZ、版本 v1.0.0、标语 "专为指弹玩家设计"
- **开发者鸣谢**：Copyright©2026，致谢 @EircZ @Claude Code @Xiaomi MiMo-V2.5-Pro @CC Switch @豆包

### 5. 通用 UI 特性

- **品牌标题栏**："TuneMate | EircZ"，| EircZ 为小字偏下显示 (9px, alpha 0.4)
- **底部导航**：3 Tab (和弦/指板/特调)，AnimatedSwitcher 300ms 切换动画
- **国际化**：中英文双语，全局 locale 检测
- **主题系统**：深色主题 (amber-400 + #1E1E2E) / 浅色主题 (amber-700 + grey-100)

---

## 数据模型

### Chord (和弦)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | 唯一标识 |
| key | String | 调式 (C/D/E/F/G/A/B) |
| type | String | 类型 (major/minor/7/maj7/min7/dim/aug) |
| name | String | 显示名 (如 "Cm7") |
| frets | List\<int\> | 6 弦品格位置 (-1=闷音, 0=空弦, 1+=品格) |
| fingers | List\<int\> | 6 弦按弦手指 (0=不用, 1-4=手指) |
| baseFret | int | 起始品格 (1=开放把位) |

**支持的 7 种和弦类型**：大三 (major)、小三 (minor)、属七 (7)、大七 (maj7)、小七 (min7)、减 (dim)、增 (aug)

### TuningScheme (特调方案)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | UUID v4 |
| nameZh / nameEn | String | 中/英文名称 |
| descriptionZh / descriptionEn | String | 中/英文描述 (代表曲目) |
| isBuiltIn | bool | 是否内置 (内置不可删除) |
| isFavorite | bool | 是否收藏 |
| strings | List\<StringTuning\> | 6 根弦的调音配置 |

### StringTuning (单弦调音)

| 字段 | 类型 | 说明 |
|------|------|------|
| stringNumber | int | 弦号 (1-6) |
| capoFret | int | 变调夹品位 (0=不用) |
| referenceString | int | 参考的标准弦号 (1-6) |

实际音名 = 标准调弦[referenceString - 1] + capoFret 个半音

---

## 内置数据

### 内置特调方案 (7 种)

| ID | 名称 | 代表曲目 | 说明 |
|----|------|---------|------|
| standard | Standard 标准调弦 | Romance de Amor | E B G D A E |
| drop-d | Drop D | Everlong | 6 弦降至 D |
| dadgad | DADGAD | Kashmir | 1/2/5/6 弦变调 |
| cgdgad | Low C | Like a Star | 1/2/5 弦夹 2 品, 6 弦夹 4 品 |
| open-d | Open D | Big Yellow Taxi | 1/2/6 弦夹 2 品, 3 弦夹 1 品 |
| open-g | Open G | Jumpin' Jack Flash | 1/5/6 弦夹 2 品 |
| drop-c | Drop C | Toxicity | 1-5 弦夹 2 品, 6 弦夹 4 品 |

### 内置和弦 (49 个)

- **7 个调式**：C, D, E, F, G, A, B
- **7 种类型**：大三, 小三, 属七, 大七, 小七, 减, 增
- **7 个补充和弦**：Bb, Eb, F#, C#m, D#m, F#m, G#m (覆盖走向所需的非常用调)

### 和弦走向 (6 组)

| 走向 | 中文名 | 级数 | 示例曲目 |
|------|--------|------|---------|
| 1-6-4-5 | 经典流行 | I-vi-IV-V | Let It Be, 童话, 好久不见 |
| 1-5-6-4 | 万能走向 | I-V-vi-IV | Someone Like You, 平凡之路, 小幸运 |
| 4-5-3-6 | 卡农变体 | IV-V-iii-vi | Canon in D, 征服, 匆匆那年 |
| 1-4-5-1 | 基础摇滚 | I-IV-V-I | Twist and Shout, Rock Around the Clock |
| 6-4-1-5 | 抒情走向 | vi-IV-I-V | 夜曲, 说好的幸福, 蒲公英的约定 |
| 1-6-2-5 | 爵士经典 | I-vi-ii-V | Fly Me to the Moon, Autumn Leaves |

---

## 动画系统

| 位置 | 动画类型 | 参数 |
|------|---------|------|
| 底部导航切换 | AnimatedSwitcher | 300ms |
| 特调列表入场 | TweenAnimationBuilder | 300 + index×50ms, easeOut, 从下方 20px 滑入 |
| 调音指示入场 | TweenAnimationBuilder | 400 + index×100ms, easeOutBack, 从右 30px 滑入 |
| 保存加载 | FadeTransition + AnimationController | 1500ms, easeInOut, 全屏遮罩 + 转圈 |

---

## 依赖清单 (pubspec.yaml)

```yaml
dependencies:
  flutter: sdk
  flutter_localizations: sdk
  provider: ^6.1.1              # 状态管理
  sqflite: ^2.3.0               # SQLite 数据库
  shared_preferences: ^2.2.2    # 键值缓存
  uuid: ^4.2.1                  # 唯一 ID 生成
  intl: ^0.20.2                 # 国际化支持

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^3.0.1
```

---

## 架构设计

### 分层架构

```
┌─────────────────────────────────────┐
│  Screens (UI 页面)                   │
│  home / chord / fretboard / tuning  │
├─────────────────────────────────────┤
│  Widgets (可复用组件)                 │
│  chord_diagram / fretboard_grid     │
├─────────────────────────────────────┤
│  Providers (状态管理)                │
│  ChangeNotifier + Consumer 模式     │
├─────────────────────────────────────┤
│  Services (数据服务)                 │
│  SQLite / SharedPreferences         │
├─────────────────────────────────────┤
│  Models + Data + Utils              │
│  数据模型 / 内置数据 / 工具类         │
└─────────────────────────────────────┘
```

### 状态管理

4 个 Provider 各司其职：
- **SettingsProvider**：主题 + 语言，SharedPreferences 持久化
- **TuningProvider**：特调列表 + 收藏 + CRUD，SQLite + SharedPreferences
- **ChordProvider**：和弦列表 + 调式选择，纯内存
- **FretboardProvider**：指板音名网格 + 品数，纯内存

### 数据持久化

- **SQLite** (`tunemate.db`)：自定义特调方案的增删改查
- **SharedPreferences**：主题模式、语言设置、收藏列表

---

## 构建与运行

```bash
# 设置 Java 环境 (Android 构建需要 JDK 17)
export JAVA_HOME="D:/Andriod-SDK/jdk-17.0.2"

# Windows 桌面
flutter run -d windows --release

# Android (需连接设备)
flutter run -d android --release

# 构建 APK
flutter build apk --release
# 输出: build/app/outputs/flutter-apk/app-release.apk

# 安装到手机
D:/Andriod-SDK/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk

# 检查环境
flutter doctor
```

---

## 已安装组件清单 (含路径，便于卸载)

### D 盘 — 核心工具链

| 组件 | 路径 | 大小 | 说明 |
|------|------|------|------|
| Flutter SDK | `D:\flutter\` | 3.1 GB | Flutter 3.44.1 + Dart 3.12.1 |
| 　└ bin/ | `D:\flutter\bin\` | 2.6 GB | Dart SDK、flutter 工具、缓存 |
| 　└ packages/ | `D:\flutter\packages\` | 83 MB | Flutter 内置包 |
| 　└ engine/ | `D:\flutter\engine\` | 68 MB | Flutter 引擎 |
| TuneMate 项目 | `D:\AI_Explore\TuneMate\` | ~800 MB | 含 build 缓存 |
| 　└ build/ | `D:\AI_Explore\TuneMate\build\` | ~310 MB | 构建产物 |
| 　└ .dart_tool/ | `D:\AI_Explore\TuneMate\.dart_tool\` | ~209 MB | Dart 工具缓存 |
| 　└ android/.gradle/ | `D:\AI_Explore\TuneMate\android\.gradle\` | ~5 MB | 项目级 Gradle 缓存 |

### D 盘 — Android SDK

| 组件 | 路径 | 大小 | 说明 |
|------|------|------|------|
| SDK 根目录 | `D:\Andriod-SDK\` | **3.9 GB** | |
| NDK 28.2 | `D:\Andriod-SDK\ndk\28.2.13676358\` | **2.2 GB** | Native Development Kit |
| JDK 17 | `D:\Andriod-SDK\jdk-17.0.2\` | 296 MB | OpenJDK 17.0.2 便携版 |
| build-tools | `D:\Andriod-SDK\build-tools\` | 274 MB | 34.0.0 + 36.0.0 |
| platforms | `D:\Andriod-SDK\platforms\` | 252 MB | android-34 + android-36 |
| cmdline-tools | `D:\Andriod-SDK\cmdline-tools\` | 147 MB | sdkmanager 等 |
| cmake 3.22.1 | `D:\Andriod-SDK\cmake\3.22.1\` | 44 MB | NDK 构建需要 |
| platform-tools | `D:\Andriod-SDK\platform-tools\` | 17 MB | adb v1.0.41 |
| licenses | `D:\Andriod-SDK\licenses\` | 11 KB | SDK 许可协议 |

### C 盘 — 构建缓存与包管理

| 组件 | 路径 | 大小 | 说明 |
|------|------|------|------|
| Gradle 总缓存 | `C:\Users\0304\.gradle\` | **2.6 GB** | Maven 依赖 + 构建缓存 + Gradle 发行包 |
| Pub 包缓存 | `C:\Users\0304\AppData\Local\Pub\Cache\` | 543 MB | pub.dev 依赖包 |
| Android Studio 缓存 | `C:\Users\0304\AppData\Local\Google\AndroidStudio2024.2\` | 330 MB | 索引/插件/日志 (可安全删除) |
| Android 配置 | `C:\Users\0304\.android\` | 6 MB | 签名密钥、AVD 缓存 |
| Claude Code 数据 | `C:\Users\0304\.claude\` | 97 MB | 会话记录、skills、projects |

### 环境变量

| 变量名 | 值 | 说明 |
|--------|------|------|
| `ANDROID_HOME` | `D:\Andriod-SDK` | Android SDK 路径 |
| `JAVA_HOME` | `D:\Andriod-SDK\jdk-17.0.2` | JDK 17 (Gradle 构建需要) |
| `PATH` | 包含 `D:\flutter\bin` | Flutter/Dart 命令行可用 |

### 磁盘占用汇总

| 位置 | 大小 |
|------|------|
| D 盘 (Flutter SDK + Android SDK + 项目) | ~7.8 GB |
| C 盘 (Gradle + Pub + AS 缓存 + 配置) | ~3.6 GB |
| **合计** | **~11.4 GB** |

---

## 卸载指南

不再使用时，按以下顺序清理（可释放 ~11.4 GB）：

### D 盘清理

```bash
rmdir /s /q D:\flutter                          # Flutter SDK (~3.1 GB)
rmdir /s /q D:\Andriod-SDK                      # Android SDK (~3.9 GB)
rmdir /s /q D:\AI_Explore\TuneMate              # 项目 (~800 MB)
```

### C 盘清理

```bash
rmdir /s /q C:\Users\0304\.gradle                           # Gradle 缓存 (~2.6 GB)
rmdir /s /q C:\Users\0304\AppData\Local\Pub\Cache           # Pub 包缓存 (~543 MB)
rmdir /s /q C:\Users\0304\AppData\Local\Google\AndroidStudio2024.2  # AS 缓存 (~330 MB)
rmdir /s /q C:\Users\0304\.android                          # Android 配置 (~6 MB)
rmdir /s /q C:\Users\0304\.claude                           # Claude Code (~97 MB)
```

### 环境变量清理

```
系统设置 → 高级系统设置 → 环境变量：
  - 删除 ANDROID_HOME
  - 删除 JAVA_HOME
  - 从 Path 中移除 D:\flutter\bin
```

---

## 项目亮点 (简历参考)

- **跨平台架构**：Flutter + Provider 状态管理，单代码库适配 Android / Windows 桌面
- **自定义 Canvas 渲染**：和弦指法图 (动态 4/5 品格自适应) 与指板网格均使用 CustomPaint 绘制
- **智能变调夹算法**：用户输入目标音名，系统自动推算最优变调夹配置 (优先自身弦，备选跨弦)
- **等音转换**：支持 Db/Eb/Gb/Ab/Bb 等降号写法自动标准化为升号
- **数据驱动设计**：49 和弦 × 7 调式 × 6 走向 = 2058 种查询组合，全部通过模型计算生成
- **响应式布局**：指板页面横屏自动切换紧凑模式，鼠标滚轮横向滚动
- **丰富动画**：列表交错入场、调音指示滑入、保存全屏加载、Tab 切换过渡
- **本地持久化**：SQLite 自定义特调 CRUD + SharedPreferences 设置/收藏
- **国际化支持**：中英文双语，基于 flutter_localizations 标准方案

---

## 开发日期

2026-06-06 ~ 2026-06-07
