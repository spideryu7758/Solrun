# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目简介

Solrun 是一款基于 Flutter 的纯本地、零广告跑步记录 App（Android / iOS 双端）。核心理念：数据只属于跑者自己，界面只服务于跑步本身。参考项目 [RunFlutterRun](https://github.com/BenjaminCanape/RunFlutterRun)（MIT License）。品牌已从 RunPure 重命名为 Solrun，代码中类名使用 SolrunColors/SolrunTheme/SolrunThemeColors（包名 com.runpure.run_pure 保持不变）。

**明确不做的事：** 心率/蓝牙接入（永不纳入）、后端服务、社交功能、广告/分析 SDK。

## 技术栈

- **框架：** Flutter 3.22+（Dart）
- **状态管理：** flutter_riverpod ^2.x
- **路由：** go_router ^12.x
- **GPS：** Android 原生 Kotlin ForegroundService（FusedLocationProviderClient + LocationManager 双栈）+ geolocator ^13.x（iOS AppleSettings）+ flutter_foreground_task ^8.x（电池优化请求）
- **地图：** flutter_map ^6.x + latlong2（深色用 CartoDB Dark Matter，浅色用 OSM 标准 tile）
- **本地数据库：** drift（SQLite ORM），无后端依赖
- **图表：** fl_chart ^0.6x
- **语音播报：** flutter_tts ^3.x
- **图片选取：** image_picker（头像选择）
- **AI 集成：** 通用 LLM Provider 层（支持 Claude/OpenAI/通义千问/智谱/MiniMax/OpenClaw/自定义）
- **安全存储：** flutter_secure_storage（API Key 加密）
- **国际化：** flutter_localizations + intl（ARB 文件 + gen-l10n 自动生成，支持中/英双语）
- **城市识别：** GeocodingService（高德 Web 服务 API 优先 → Nominatim 兜底，10 分钟缓存）
- **其他：** shared_preferences, wakelock_plus, uuid

## 常用命令

```bash
flutter pub get          # 安装依赖
flutter run              # 运行到模拟器/真机
flutter test             # 运行全部测试
flutter test test/path/to/test.dart  # 运行单个测试文件
flutter analyze          # 静态分析/Lint
flutter build apk        # 构建 Android APK
flutter build ios        # 构建 iOS

# drift 代码生成（修改数据库表结构后必须执行）
dart run build_runner build --delete-conflicting-outputs

# 国际化代码生成（修改 ARB 文件后必须执行）
flutter gen-l10n
```

## 架构设计

采用 **Feature-First 分层架构**，每个功能模块内部分 data / domain / presentation 三层：

```
lib/
├── main.dart                          # 入口，ProviderScope 挂载
├── app/
│   ├── router.dart                    # go_router 全局路由表（路由定义）
│   ├── shell/
│   │   ├── main_shell.dart            # ShellRoute 底部导航壳（ScaffoldWithNavBar）
│   │   └── home_page.dart             # 首页（本周汇总 + 快速开始按钮）
│   ├── theme.dart                     # 深色/浅色主题（设计 token 定义）
│   ├── theme_provider.dart            # 主题状态管理（Riverpod provider）
│   └── locale_provider.dart           # 语言状态管理（中文/英文/跟随系统）
├── features/
│   ├── tracking/                      # 运动记录
│   │   ├── data/
│   │   │   ├── location_service.dart        # GPS 流封装（Android 原生服务 / iOS geolocator）
│   │   │   ├── foreground_task_service.dart  # 电池优化请求（flutter_foreground_task）
│   │   │   ├── checkpoint_service.dart      # 异常恢复检查点
│   │   │   └── tracking_persistence.dart    # 跑步数据持久化（轨迹点批量落库、分公里配速写入）
│   │   ├── domain/
│   │   │   ├── pace_calculator.dart          # 配速算法（实时 + 分公里）
│   │   │   ├── auto_pause_detector.dart      # 自动暂停检测
│   │   │   ├── elevation_calculator.dart     # 海拔计算（中位数滤波 + 阈值去噪）
│   │   │   ├── achievement_checker.dart      # 成就检测
│   │   │   └── run_finalizer.dart            # 跑步结束逻辑（城市识别、成就检测、数据保存，从 tracking_notifier 拆出）
│   │   ├── presentation/
│   │   │   ├── tracking_screen.dart
│   │   │   ├── tracking_notifier.dart       # 含暂停/继续语音提示（endRun 逻辑已拆至 run_finalizer）
│   │   │   ├── tracking_state.dart          # 已移除 isScreenLocked 字段
│   │   │   └── result_screen.dart
│   │   └── providers.dart
│   ├── history/                       # 历史记录（按月可折叠列表、详情、轨迹回放）
│   │   └── presentation/
│   │       ├── history_list_screen.dart
│   │       └── history_detail_screen.dart
│   ├── stats/                         # 统计图表（本月卡片、月柱状图、年月选择器）
│   │   └── presentation/
│   │       ├── stats_screen.dart            # 统计主页
│   │       └── widgets/
│   │           ├── stats_chart_utils.dart    # 图表共享工具（轴样式、格式化）
│   │           ├── month_bar_chart.dart      # 月度柱状图
│   │           ├── year_monthly_chart.dart   # 年度月统计图
│   │           └── all_years_chart.dart      # 全年度对比图
│   ├── training/                      # 训练计划（预设模板、自定义间歇）
│   │   └── presentation/
│   │       ├── training_list_screen.dart
│   │       └── training_detail_screen.dart
│   ├── share/                         # 分享卡片（多模板、热力轨迹、地图底图、自定义编辑器）
│   │   ├── domain/
│   │   │   ├── share_card_data.dart         # 不可变数据模型（预计算速度/颜色/海拔/降采样 + city/weather）
│   │   │   └── share_card_config.dart       # 模板枚举 + 比例枚举 + 开关配置 + shoutText/shoutRole 字段
│   │   ├── presentation/
│   │   │   ├── share_preview_screen.dart    # 主预览页（实时预览 + 自定义 + 截图/分享）
│   │   │   ├── share_card_notifier.dart     # 配置状态管理（Riverpod Notifier）
│   │   │   ├── painters/
│   │   │   │   └── heatmap_route_painter.dart  # 配速热力 Canvas（合并 glow 优化）
│   │   │   ├── widgets/
│   │   │   │   ├── split_pace_chart.dart     # 分公里配速柱状图（fl_chart）
│   │   │   │   ├── elevation_profile.dart    # 海拔剖面面积图（Canvas）
│   │   │   │   ├── template_selector.dart    # 模板选择器
│   │   │   │   ├── aspect_ratio_selector.dart # 比例选择器
│   │   │   │   ├── customization_toggles.dart # 自定义开关
│   │   │   │   ├── watermark_footer.dart      # 公用水印组件（城市天气 + 观众喊话 + Slogan）
│   │   │   │   └── map_trajectory_view.dart   # 地图轨迹视图（FlutterMap 非交互嵌入）
│   │   │   └── templates/
│   │   │       ├── classic_template.dart      # 经典模板
│   │   │       ├── heatmap_template.dart      # 热力模板
│   │   │       ├── map_photo_template.dart    # 地图底图模板（FlutterMap + 浮层）
│   │   │       └── minimal_template.dart      # 极简模板
│   │   └── providers.dart                   # 含 sessionShoutsProvider
│   ├── settings/                      # 设置（单位、语音、主题、语言、AI、个人信息）
│   │   └── presentation/
│   │       ├── settings_screen.dart          # 设置主页（组装各 section）
│   │       └── sections/
│   │           ├── appearance_section.dart    # 外观设置（主题、语言）
│   │           ├── run_settings_section.dart  # 跑步设置（单位、语音、自动暂停）
│   │           ├── map_settings_section.dart  # 地图设置（瓦片源、API Key）
│   │           ├── personal_info_section.dart # 个人信息（昵称、体重、头像）
│   │           └── data_management_section.dart # 数据管理（导入导出、清空）
│   ├── export/                        # 数据导入导出（GPX/CSV/Garmin/ZIP）
│   │   ├── gpx_exporter.dart
│   │   ├── csv_exporter.dart
│   │   ├── gpx_importer.dart          # GPX 导入（支持 ZIP 批量解压）
│   │   └── garmin_importer.dart       # Garmin Connect JSON 导入
│   ├── ai_settings/                   # AI 服务配置（厂商选择、API Key、测试连接）
│   │   ├── data/
│   │   │   └── ai_preferences.dart
│   │   └── presentation/
│   │       └── ai_settings_screen.dart
│   ├── ai_chat/                       # AI 按需问答（已移除，ChatDao 迁移至 data/daos/）
│   ├── ai_summary/                    # AI 总结（单次/周/月/年）
│   │   ├── domain/
│   │   │   ├── chat_context_builder.dart   # 跑步数据格式化（从 ai_chat 迁入）
│   │   │   └── summary_prompt.dart
│   │   ├── presentation/
│   │   │   ├── summary_screen.dart
│   │   │   └── summary_notifier.dart
│   │   └── providers.dart
│   ├── audience/                      # AI 观众系统（虚拟观众 + 赛后采访）
│   │   ├── data/
│   │   │   ├── audience_engine.dart        # 观众引擎核心（DAO 注入 + 诊断日志 + LLM 异步加载容错）
│   │   │   ├── runner_profile_builder.dart # 跑者画像构建（拆分为 _calcOverview/_calcBestRecords/_calcWeeklyTrend/_calcMonthlyStats/_calcHabits + 通用 _categorizeMax 分桶）
│   │   │   └── trigger_context_builder.dart # 触发上下文（通用 _compareWithHistoryAvg/_formatPaceDiff 对比方法）
│   │   ├── domain/
│   │   │   ├── audience_constants.dart     # 集中常量定义（LLM 超时/字数限制/冷却间隔/配速阈值/日志标签）
│   │   │   ├── audience_roles.dart         # 7 种观众角色枚举（含 prompt 描述）
│   │   │   ├── personalities.dart          # 5 种人格风格枚举
│   │   │   ├── mood_states.dart            # 跑前心情状态
│   │   │   ├── voice_picker.dart           # 角色×人格组合抽取（7×5=35 种）
│   │   │   ├── shout_prompt_builder.dart   # 喊话 Prompt 组装（含彩蛋注入）
│   │   │   ├── interview_prompt_builder.dart # 赛后采访 Prompt 组装
│   │   │   ├── unlock_checker.dart         # 角色解锁纯函数（不依赖 DAO，由调用方负责持久化）
│   │   │   ├── weather_detector.dart       # 天气/环境彩蛋检测
│   │   │   └── holiday_detector.dart       # 节日彩蛋检测（公历+农历）
│   │   ├── presentation/
│   │   │   ├── audience_home_screen.dart   # 观众席主页（金句墙+粉丝团+图鉴）
│   │   │   ├── audience_home_notifier.dart # 观众席主页状态管理
│   │   │   ├── quote_wall_section.dart     # 金句墙区域（3条一页轮播，左滑取消收藏）
│   │   │   ├── fan_team_section.dart       # 固定粉丝团区域（2 卡位）
│   │   │   ├── role_gallery_section.dart   # 角色图鉴网格
│   │   │   ├── role_detail_sheet.dart      # 角色详情 BottomSheet（历史语录点击复制 + ❤️收藏到金句墙）
│   │   │   ├── interview_screen.dart       # 赛后采访页面骨架（气泡/输入栏已提取到 widgets/）
│   │   │   ├── interview_notifier.dart     # 赛后采访状态管理（流式 LLM + 超时保护）
│   │   │   ├── interview_state.dart        # 赛后采访状态模型
│   │   │   ├── mood_selector.dart          # 跑前心情选择器
│   │   │   ├── shout_overlay.dart          # 跑步中弹幕浮层
│   │   │   ├── audience_shout_notifier.dart # 喊话 Notifier（async/await + 诊断日志）
│   │   │   └── widgets/
│   │   │       ├── interview_message_bubble.dart # 采访消息气泡 + 打字指示器
│   │   │       └── interview_input_bar.dart      # 采访输入栏
│   │   └── providers.dart
├── shared/
│   ├── widgets/
│   │   ├── run_map.dart               # 通用地图组件（缓存瓦片 + 热力轨迹 + 起终点标记）
│   │   ├── share_card.dart            # 分享入口（ShareCardHelper → SharePreviewScreen）
│   │   ├── rp_components.dart         # 共享 UI 组件（RpCard/RpMetric/RpSectionHeader/RpDialog/RpEmptyState/RpSnackBar）
│   │   ├── rp_animations.dart         # 共享动画组件（RpTapScale/RpFadeSlideIn/RpPulse）
│   │   └── rp_skeleton.dart           # 骨架屏加载组件（RpSkeleton/RpCardSkeleton/RpSessionTileSkeleton）
│   ├── utils/
│   │   ├── polyline_simplifier.dart   # Douglas-Peucker 轨迹降采样（含带速度简化）
│   │   ├── pace_color_mapper.dart     # 配速→颜色映射（HSL 插值，16 级量化）
│   │   ├── coord_converter.dart      # WGS-84 ↔ GCJ-02 坐标转换（高德地图用）
│   │   ├── autostart_helper.dart      # 国产 ROM 自启动引导（华为/小米/OPPO/vivo 等）
│   │   └── debug_log.dart             # 轻量文件日志（release 模式可用，同步写入防丢失）
│   └── services/
│       ├── tts_service.dart           # 语音播报（中英自动切换 + awaitSpeakCompletion + announcePause + _currentLang/setLanguageTag）
│       ├── weather_service.dart       # 实时天气服务（Open-Meteo 免费 API，GPS 定位获取）
│       ├── geocoding_service.dart     # 城市识别（高德优先 → Nominatim IPv4 兜底，10 分钟缓存，从 tracking/data/ 迁入共享层）
│       ├── tile_cache_service.dart    # 瓦片文件缓存（LRU 200MB + 离线回退 + 并发预缓存每批 6 个）
│       ├── map_preferences.dart       # 地图偏好设置（瓦片源选择 + 自定义 URL）
│       └── llm/                       # 通用 LLM Provider 层
│           ├── llm_provider.dart      # 抽象接口
│           ├── llm_models.dart        # 数据模型（ChatMessage, LlmConfig 等）
│           ├── llm_http_client.dart   # HTTP + SSE 流式客户端
│           ├── llm_registry.dart      # 厂商预设 + 工厂
│           ├── llm_riverpod.dart      # Riverpod providers
│           └── providers/
│               ├── openai_compatible.dart   # OpenAI 兼容协议（覆盖 6 家厂商）
│               └── anthropic_provider.dart  # Claude 原生 Messages API
├── l10n/
│   ├── app_zh.arb                     # 中文翻译（模板语言，145+ key）
│   ├── app_en.arb                     # 英文翻译
│   ├── app_localizations.dart         # gen-l10n 自动生成（输出类名 S）
│   ├── app_localizations_zh.dart      # 自动生成
│   └── app_localizations_en.dart      # 自动生成
└── data/
    ├── database.dart                  # drift DB 定义（所有表）
    ├── database.g.dart                # drift 生成代码
    ├── providers.dart                 # 数据层 Riverpod providers（含所有 DAO Provider 集中管理，audience DAO 不再散落在 feature 层）
    └── daos/                          # 数据访问对象
        ├── run_session_dao.dart
        ├── route_point_dao.dart
        ├── split_pace_dao.dart
        ├── achievement_dao.dart
        ├── training_dao.dart
        ├── chat_dao.dart              # AI 对话消息 DAO（从 ai_chat 迁入）
        ├── audience_shout_dao.dart    # 观众喊话 DAO
        ├── audience_favorite_dao.dart # 粉丝团收藏 DAO
        └── audience_unlock_dao.dart   # 角色解锁记录 DAO
```

## 数据库表结构

4 张核心表 + 2 张训练相关表 + 1 张 AI 对话表 + 3 张观众系统表：

- **RunSession** — 跑步记录主表（含 status: completed/incomplete、autoName 自动命名、city nullable、weather nullable）
- **RoutePoint** — 轨迹点独立表（FK → RunSession），含经纬度、海拔、精度、速度、时间戳
- **SplitPace** — 分公里配速表（FK → RunSession），跑步结束时一次性持久化写入
- **Achievement** — 成就记录表（FK → RunSession）
- **TrainingPlan / TrainingDay** — 训练计划及每日训练定义
- **ChatMessages** — AI 对话消息表（conversationId 分组，支持关联 sessionId 和 summaryType）
- **AudienceShouts** — 观众喊话表（FK → RunSession），含角色、人格、内容、触发上下文、收藏标记
- **AudienceFavorites** — 粉丝团固定成员表（最多 2 条），含角色+人格组合
- **AudienceUnlocks** — 角色解锁记录表，含解锁时间、跑步次数、动画播放状态

> RoutePoint 独立成表（而非 JSON 字段）：支持索引查询、分页加载、流式 GPX 导出，避免大 JSON 反序列化内存峰值。
> 数据库 schemaVersion = 4（v2 新增 ChatMessages 表；v3 新增 AudienceShouts/AudienceFavorites/AudienceUnlocks 三表及索引 + 种子数据；v4 RunSessions 表新增 city 和 weather 字段）。
> 数据库连接配置：`beforeOpen` 设置 `PRAGMA busy_timeout = 5000` + `PRAGMA journal_mode = WAL` + `PRAGMA foreign_keys = ON`，防止并发连接导致 SQLITE_BUSY，并启用外键约束。
> 外键级联删除：RoutePoint/SplitPace/Achievement/AudienceShouts 等子表对 RunSession 设置 `CASCADE DELETE`，删除跑步记录时自动清理关联数据。
> **重要：** AppDatabase 实例由 Riverpod `databaseProvider` 单例管理，禁止在 main.dart 或其他位置创建独立实例（否则会导致 database is locked）。

## 关键设计决策

- GPS 精度过滤：仅接受 accuracy < 15m 的点位
- 配速计算使用 30 秒滑动窗口平均，避免瞬时跳变
- GPS 采样：运动状态 3 秒/次，暂停状态降频至 10 秒/次
- 自动暂停：速度 < 1.0 km/h 持续 5 秒触发，> 1.5 km/h 恢复（可选功能）
- 异常恢复：元数据每 30 秒覆写 meta.json + 轨迹点追加写入 points.log，崩溃后可恢复或保存为"未完成记录"
- 分批落库：轨迹点每 500 条批量 INSERT 到 RoutePoint 表后从内存释放，支持 24h+ 超长跑步
- 地图 Polyline 降采样：Douglas-Peucker 算法，自适应 ε（根据 bounding box 和 zoom level），保证 ≥30fps
- **后台保活（Android）：** 原生 Kotlin `RunLocationService`（独立于 Flutter 引擎的 ForegroundService），FusedLocationProviderClient + 原生 LocationManager 双栈定位，通过 EventChannel 将 GPS 数据传回 Flutter；通知栏常驻显示跑步时长和距离；首次跑步请求电池优化白名单
- **后台保活（iOS）：** geolocator AppleSettings（activityType: fitness, allowBackgroundLocationUpdates: true），Info.plist 声明 UIBackgroundModes: [location]
- **国产 ROM 自启动引导：** 检测华为/荣耀/小米/OPPO/vivo/三星/一加/魅族等厂商，首次跑步弹窗引导用户开启自启动白名单，通过 MethodChannel 跳转到厂商系统管理页面
- **App 生命周期监听：** WidgetsBindingObserver 监听 App 回到前台，检查 GPS 流是否中断并自动重连恢复
- **GPS 心跳监测：** 每秒 _onTick 检查最后一次 GPS 点时间，运动中超过 15 秒无数据自动重启定位流，后台断流的最后防线
- **通知栏操作按钮：** 前台服务通知含"暂停/继续"和"结束"按钮，息屏/锁屏时可直接控制跑步，TaskHandler 通过 sendDataToMain 转发事件
- **GPS 断点容错：** PaceCalculator 检测相邻两点时间间隔 > 10 秒时跳过该段距离累计，清空滑动窗口重新计算配速，避免流中断恢复后距离虚高
- **暂停/继续语音提示：** pauseRun/resumeRun 调用 TtsService.announcePause()，中英文自动切换
- **Wakelock 始终开启：** 跑步中屏幕常亮，已移除息屏/亮屏切换按钮（tracking_screen 不再有 toggleScreenOff）
- 分公里配速采用持久化方案（跑步结束时计算一次并存入 SplitPace 表）
- 卡路里公式：体重(kg) × 距离(km) × 1.036
- 轨迹点采集海拔字段，为 GPX 导出预留
- 海拔累计爬升计算：中位数滤波（窗口 5 点）平滑原始海拔 → 2m 阈值过滤微小噪声 → 趋势确认（连续 3 点上升才计入），避免 GPS 海拔漂移导致虚高
- **分享卡片系统：** 4 种模板（经典/热力/地图底图/极简）× 3 种比例（9:16/1:1/3:4）× 6 个自定义开关（热力轨迹/地图底图/配速图表/海拔剖面/数据网格/头部信息）；所有模板统一 Slogan "No Ads · Just Miles"；轨迹点降采样（上限 500 点）避免 GPU 爆炸；HeatmapRoutePainter 合并 glow 为单次路径绘制；地图模板内嵌 FlutterMap（非交互）+ CachedTileProvider + GCJ-02 坐标转换；分享数据从轨迹点实时重新计算海拔爬升（修复历史记录 0 值问题）；RepaintBoundary 3x pixelRatio 截图 → MediaStore 保存到相册；卡片最外层无圆角（避免社交媒体分享时圆角外白边）；**水印增强：** 支持观众喊话水印（只显示引号内容，不显示角色出处）+ 城市天气水印；分享预览页新增观众语录选择器（竖向完整内容列表）
- 跑步开始前 3 秒倒计时，给用户准备时间
- **城市识别：** GeocodingService 双链路策略 — 高德 Web 服务 API（国内稳定，用户在设置页配置 Key，flutter_secure_storage 加密存储）优先，失败后 fallback Nominatim（强制 IPv4 DNS 解析 + connectionFactory，解决国产 ROM IPv6 不可达问题）；endRun 时根据起始 GPS 坐标获取城市名，10 分钟缓存避免重复请求；城市信息存入 RunSession.city 字段
- **autoName 国际化：** _generateAutoName 支持 city 前缀 + 中英文时段名（"城市 · 清晨跑" / "City · Dawn Run"），根据当前 locale 自动切换
- **跑步记录重命名：** 历史详情页标题可点击，弹出重命名对话框，保存后刷新列表
- **TTS 语言设置：** TtsService 新增 _currentLang 字段和 setLanguageTag() 方法，在 _loadSettings 中根据 locale 设置语言
- **AI 集成架构：** ���用 LLM Provider 抽象层，OpenAI 兼容协议覆盖 6 家厂商（OpenAI/千问/智谱/MiniMax/OpenClaw/自定义），Claude 单独适配 Messages API
- **AI 教练零侵入：** 通过 ref.listen(trackingProvider) 解耦，不修改 TrackingNotifier 核心代码，异步调 LLM 后 TTS 播报
- **API Key 安全：** flutter_secure_storage 按厂商独立加密存储（ai_api_key_{preset}），切换厂商不互相覆盖
- **AI 会话管理：** 按 conversationId 分组存储，支持会话列表浏览、切换、左滑单条删除、批量清空，显示存储空间占用
- **AI 功能离线降级：** 未配置或无网络时，AI 入口显示友好提示，核心跑步功能完全不受影响
- **SSE 流式响应：** dart:io HttpClient 原生支持，无额外 HTTP 依赖；30s 无数据超时保护（自动取消 stream 并保留已接收内容）；对话上下文滑动窗口限制最近 20 条防超 context window
- **瓦片缓存：** 自定义 CachedTileProvider 继承 flutter_map TileProvider，文件缓存到 applicationSupportDirectory/tiles/，LRU 淘汰上限 200MB，过期 30 天，离线时返回过期缓存或透明 tile；预缓存改为并发下载（每批 6 个瓦片并行请求）
- **瓦片源配置：** MapPreferences 存储用户选择（auto/osm/cartoDark/cartoVoyager/cyclosm/amap/custom），auto 模式跟随主题自动切换；高德地图适配中国大陆；选择高德时设置页显示 API Key 输入框（flutter_secure_storage 加密存储），用于反向地理编码
- **GCJ-02 坐标转换：** 高德瓦片使用火星坐标系，RunMap 渲染时自动 WGS84→GCJ02 转换（含中国境内判定），数据库始终存储 WGS-84 原始坐标不受影响
- **配速热力轨迹：** PaceColorMapper 按速度百分位（p10-p90）归一化，HSL 色相 0°(红/慢)→120°(绿/快) 插值，量化为 16 级合并相邻同色段减少 Polyline 数量
- **轨迹回放：** AnimationController 驱动，渐进绘制已播放轨迹（热力着色）+ 未播放轨迹（半透明），移动标记自动跟随，固定回放总时长 5s/10s/20s 三档可选（不论距离长短体验一致）
- **地图平滑跟随：** 跑步中 MapController.move 使用 500ms 节流 + 300ms Tween 插值动画，避免瞬移
- **国际化架构：** Flutter 原生 l10n（ARB + gen-l10n），模板语言中文（app_zh.arb），输出类名 `S`，通过 `S.of(context).keyName` 访问；locale_provider.dart 管理语言状态（中文/英文/跟随系统），SharedPreferences 持久化；设置页图标卡片式语言选择器
- **AI 观众系统：** 7 角色 × 5 人格 = 35 种观众组合；触发事件（开跑/距离播报同步/冲线/配速异常）调用 LLM 生成喊话；距离触发与系统语音播报间隔同步（读取 `tts_interval_km` 设置）；弹幕浮层展示；跑前可选心情影响喊话风格（MoodSelector 卡片 Expanded 自适应宽度，兼容窄屏）；角色详情页历史语录支持点击复制+❤️收藏到金句墙；金句墙每页 3 条轮播（6 秒间隔）、左滑取消收藏；粉丝团上限 2 个固定角色；AudienceConstants 集中管理 LLM 超时（60s）、字数限制（中文 50 字/英文 150 字符）、冷却间隔（30s）、配速异常阈值（20%）等参数
- **观众引擎流式调用：** 使用 SSE 流式 API（`completeStream`）代替同步 `complete`，实时剥离推理模型的 `<think>` 思考块，`</think>` 后的实际内容一出来就用；兼容 MiniMax/智谱/OpenAI 等各厂商；429 限频和 529 服务过载自动等 8 秒重试
- **观众引擎诊断：** DebugLog 文件日志（release 模式可用，同步写入防并发丢失）；全链路日志含状态变化、触发事件、LLM 请求/响应/超时/错误；日志文件路径 `applicationSupportDirectory/audience_debug.log`
- **实时天气集成：** Open-Meteo 免费 API（无需 API Key），开跑时根据 GPS 坐标获取温度/天气/风力；10 分钟缓存；WMO 天气代码中英文映射；天气信息注入喊话 prompt 的环境信息区
- **观众系统国际化：** Prompt 中英双版本（通过 `isEn`/`lang` 参数切换，系统 prompt/角色描述/人格描述/心情提示/彩蛋提示均支持）；UI 层角色名和人格名通过 `localizedName(S)` 方法走 ARB 国际化；TTS 根据内容自动切换中英文语音引擎
- **赛后采访：** 跑完后选择观众角色+人格，流式 LLM 对话，Prompt 包含跑者画像+本次数据+角色历史喊话；持久化到 ChatMessages 表（summaryType=interview）；流式超时 30s 后自动取消 stream 并保留已接收内容
- **角色解锁：** 初始 4 角色（screamingFan/dataNerd/familyCrew/zenViewer），gambler 10 次解锁、nitpicker 20 次、rivalFan 30 次；UnlockChecker 为纯 domain 函数（不依赖 DAO），由 TrackingNotifier 负责持久化写入
- **彩蛋系统：** WeatherDetector 检测深夜/凌晨/高温/寒冷/雨天；HolidayDetector 检测公历+农历节日（2025-2029 映射）；连续跑步≥7天/回归跑>14天；彩蛋提示注入 ShoutPromptBuilder 的附加信息区

## 设计系统

- **深色主题（默认）：** bg #0A0A0F, surface #12121A, card #1A1A26, accent #E8FF47, accent2 #47C8FF, muted #8888A8（WCAG AA）；类名 SolrunColors/SolrunTheme/SolrunThemeColors
- **App 图标：** logo_icon.png（纯彩色 S 图形 + 透明背景），Android adaptive icon 黑底
- **字体：** Bebas Neue（数据大字）、DM Sans（正文）、JetBrains Mono（等宽数值）
- **中文回退：** Android Noto Sans CJK SC, iOS PingFang SC
- **地图瓦片：** 可配置瓦片源（默认 auto：深色→CartoDB Dark，浅色→OSM），支持 CartoDB Voyager、CyclOSM、自定义 URL；文件缓存 + 离线回退
- **热力轨迹色谱：** 红 H=0°(慢) → 黄 H=60°(中) → 绿 H=120°(快)，S=0.85 L=0.55，深色底图醒目
- **起终点标记：** 起点绿色 #47FF47、终点 accent 黄色，14px 圆点 + 2px 白/暗边 + 发光阴影
- **UI 组件体系：** RpCard 三级视觉层次（tier1 背景级 / tier2 标准级+微阴影 / tier3 强调级+accent色条+渐变），RpTapScale 点击缩放（0.95x, 100ms），RpFadeSlideIn 入场动画，RpPulse 循环脉冲
- **骨架屏加载：** shimmer 渐变动画替代 CircularProgressIndicator（RpSkeleton + 组合骨架），覆盖所有主要页面
- **自定义底部导航：** 选中标签上方 3px accent 指示条 + AnimatedContainer 过渡，触觉反馈
- **页面过渡：** 250ms SlideTransition（easeOutCubic），比默认 300ms 更敏捷

## 路由结构

底部导航 Tab（5个）：

| 路由 | 页面 |
|---|---|
| /home | 首页（本周汇总 + 快速开始按钮） |
| /history | 历史列表（按月分组） |
| /stats | 统计图表 |
| /ai | 观众席（金句墙 + 粉丝团 + 角色图鉴） |
| /settings | 设置 |

独立全屏页（无底部导航）：

| 路由 | 页面 | 流转 |
|---|---|---|
| /tracking | 运动中 | 首页开始按钮进入 → 结束后跳完成页 |
| /tracking/result | 跑步完成 | 保存后跳转历史详情页 |
| /history/:id | 跑步详情 | 历史列表点击进入 |
| /training/:id | 训练计划详情 | 训练列表进入 |
| /ai-settings | AI 服务配置 | 设置页进入 |
| /audience/interview | 赛后采访 | 结果页进入（角色+人格选择后） |

## 平台兼容性

- Android：minSdkVersion 26（Android 8.0+）
- iOS：Deployment Target iOS 13.0+

## 平台差异注意事项

- **后台 GPS（Android）：** 原生 Kotlin `RunLocationService` 继承 `Service`，`startForeground()` 启动前台服务（`foregroundServiceType="location"`），`FusedLocationProviderClient` + 原生 `LocationManager` 双栈定位，通过 `EventChannel` 传回 Flutter；独立于 Flutter 引擎生命周期，荣耀/华为设备息屏不被杀
- **后台 GPS（iOS）：** Info.plist 声明 UIBackgroundModes: [location]，geolocator AppleSettings 启用 allowBackgroundLocationUpdates，"When In Use" 权限即可后台定位（蓝色顶栏提示），24h+ 场景需真机验证
- **检查点存储：** applicationSupportDirectory（不会被系统清理）
- **数据库索引：** RoutePoint(sessionId)、SplitPace(sessionId)、Achievement(sessionId) 必须建索引
- **数据库单例：** AppDatabase 只通过 `databaseProvider` 创建唯一实例，`main.dart` 使用 `ref.read(databaseProvider)` 获取，不得 `AppDatabase()` 独立创建
