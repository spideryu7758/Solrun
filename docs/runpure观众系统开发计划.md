# RunPure AI 观众系统 — 开发计划

> **实施进度（截至 2026-04-03）：Phase 1-6 全部完成。** 编译 0 error，`flutter analyze` 仅 3 个 info 级提示。
>
> **实际变更摘要：**
> - Phase 4：底部导航 `/ai` → `/audience`，观众席主页含金句墙/粉丝团/角色图鉴
> - Phase 5：赛后采访完整实现（InterviewScreen + InterviewNotifier + 流式 LLM），角色解锁检查器（UnlockChecker）集成到结果页
> - Phase 6：天气/节日/连续跑步/回归跑彩蛋注入 ShoutPromptBuilder；`ai_chat/` 和 `ai_coaching/` 目录已删除（ChatDao 迁至 `data/daos/`，ChatContextBuilder 迁至 `ai_summary/domain/`）；CLAUDE.md 已更新
> - 注意：解锁动画（unlock_animation.dart）尚未实现，当前仅在结果页静默检查并写入解锁记录
> - **Bug 修复：** `main.dart` 原先独立创建 `AppDatabase()` 导致多连接 SQLITE_BUSY 冲突，已改为复用 `databaseProvider` 单例；数据库新增 `beforeOpen` PRAGMA（busy_timeout + WAL 模式）纵深防御

## 总览

基于《AI 观众系统设计文档 V2》，将开发拆分为 **6 个阶段（Phase）**，共计约 **5-6 周**。每个阶段内部按任务粒度列出，标注依赖关系、验收标准和风险点。

**核心原则：**
- 每个阶段结束后都有可运行的中间产物，可以真机验证
- Phase 1-3 完成后即可跑通"跑步中听观众喊话"的最小闭环
- Phase 4-6 为体验完善和扩展功能

```
Phase 1  基础设施（数据库 + 枚举 + 数据预处理）     ██░░░░  ~4 天
Phase 2  核心引擎（Prompt 组装 + LLM 调用 + TTS）   ████░░  ~5 天
Phase 3  跑步集成（触发逻辑 + 弹幕 UI + 跑前选择）  ██████  ~5 天
─── 最小闭环完成，可真机体验 ───
Phase 4  观众席页面（金句墙 + 粉丝团 + 角色图鉴）   ████░░  ~5 天
Phase 5  赛后采访 + 角色解锁                        ███░░░  ~4 天
Phase 6  彩蛋系统 + 打磨 + 清理                     ███░░░  ~4 天
                                              合计  ~27 天（5-6 周）
```

---

## Phase 1：基础设施（~4 天）

**目标：** 数据层就绪，角色/人格/状态枚举定义完毕，跑者画像预处理可运行。

### 1.1 数据库升级（1 天）

**任务：**
- [ ] `database.dart` 新增 3 张表定义：`AudienceShout`、`AudienceFavorite`、`AudienceUnlock`
- [ ] `schemaVersion` 从 2 升至 3
- [ ] 编写 v2 → v3 迁移逻辑：建表 + 初始化 4 个默认解锁角色（SCREAMING_FAN / DATA_NERD / FAMILY_CREW / ZEN_VIEWER）
- [ ] 为 AudienceShout 建索引：`sessionId`、`isFavorite`、`audienceRole`
- [ ] 执行 `dart run build_runner build --delete-conflicting-outputs` 重新生成 drift 代码

**新增文件：**
```
lib/data/daos/
├── audience_shout_dao.dart       # CRUD + 按 sessionId 查询 + 按 isFavorite 查询
├── audience_favorite_dao.dart    # CRUD + 上限 2 条检查
└── audience_unlock_dao.dart      # CRUD + isUnlocked 查询 + 批量查已解锁列表
```

**验收标准：**
- `flutter test` 通过，drift 生成代码无报错
- 全新安装 App 自动建表 + 插入 4 条默认解锁记录
- 从 v2 升级的 App 自动迁移成功，现有数据不丢失

### 1.2 枚举与模型定义（0.5 天）

**新增文件：**
```
lib/features/audience/domain/
├── audience_roles.dart      # AudienceRole 枚举（7 值）+ 每个角色的 prompt 描述、emoji、名称、解锁阈值
├── personalities.dart       # Personality 枚举（5 值）+ 每个人格的 prompt 描述、名称
└── mood_states.dart         # MoodState 枚举（5 值）+ 图标、名称、角色权重表、人格权重表
```

**要点：**
- 所有 prompt 文本作为枚举属性直接内联（不外置文件），方便 Claude Code 修改和迭代
- 权重表用 `Map<AudienceRole, double>` 和 `Map<Personality, double>` 表示
- 国际化：角色名称和状态名称加入 ARB 文件（中/英），prompt 描述本身保持中文（发给 LLM 用）

### 1.3 跑者画像预处理（1.5 天）

**新增文件：**
```
lib/features/audience/data/
└── runner_profile_builder.dart   # RunnerProfileBuilder
```

**任务：**
- [ ] 定义 `RunnerProfile` 数据类（含设计文档第 4.1 节全部字段）
- [ ] 实现 `Future<RunnerProfile> build()` 方法：
  - 从 `RunSessionDao` 查询总跑步次数、累计距离、累计时长
  - 计算连续跑步天数（streak）和距上次跑步天数
  - 从 `SplitPaceDao` 查询历史最佳/最差配速
  - 查询最近 4 周各周跑量和跑步次数（按 `startTime` 分组）
  - 计算近 4 周均配速和配速趋势（IMPROVING / STABLE / DECLINING）
  - 计算本月统计
  - 分析跑步时间段偏好和距离偏好
  - 查询 5K/10K 最佳成绩（筛选距离在 4.8-5.2km / 9.8-10.2km 范围的记录）
- [ ] 实现 `String formatForPrompt(RunnerProfile profile)` 方法：输出设计文档第 6.5 节格式的文本

**验收标准：**
- 有 10+ 条历史跑步记录时，`RunnerProfile` 各字段正确填充
- 无历史记录时，优雅降级（显示"新跑者"相关信息）
- `formatForPrompt` 输出可直接粘贴到 LLM 测试

### 1.4 触发上下文构建（1 天）

**新增文件：**
```
lib/features/audience/data/
└── trigger_context_builder.dart  # TriggerContextBuilder
```

**任务：**
- [ ] 定义 `TriggerType` 枚举：START / SPLIT_KM / SPLIT_5KM / PACE_ALERT / FINISH
- [ ] 定义 `TriggerContext` 数据类（含设计文档第 4.3 节全部字段）
- [ ] 实现各触发类型的 context 构建方法：
  - `buildStartContext(RunnerProfile)` — 开跑时
  - `buildSplitKmContext(int km, List<SplitPace> splits, RunnerProfile)` — 公里分割
  - `buildPaceAlertContext(String currentPace, String avgPace, RunnerProfile)` — 配速异常
  - `buildFinishContext(RunSession, List<SplitPace>, RunnerProfile)` — 跑步结束
- [ ] 对比数据预计算（vs 上一公里、vs 历史均值、vs 历史最佳）
- [ ] 实现 `String formatForPrompt(TriggerContext context)` 方法

**验收标准：**
- 各方法输入模拟数据后输出正确的格式化文本
- 无历史数据时对比字段标注"暂无"而非报错

---

## Phase 2：核心引擎（~5 天）

**目标：** Prompt 组装 → LLM 调用 → 获取喊话文本 → TTS 播报的完整链路可运行。

### 2.1 角色组合随机算法（1 天）

**新增文件：**
```
lib/features/audience/domain/
└── voice_picker.dart   # VoicePicker
```

**任务：**
- [ ] 实现加权随机抽取算法 `pickRandomVoice(mood, unlockedRoles, fanTeam)`
- [ ] 实现防重复队列（最近 5 次不重复）
- [ ] 未解锁角色自动排除
- [ ] 固定粉丝团加权 ×1.5
- [ ] 边界处理：可用组合数 ≤ 5 时放宽防重复限制

**验收标准：**
- 单元测试：1000 次抽取的分布符合权重比例（±10% 容差）
- 防重复：连续 5 次无重复组合
- 仅初始 4 角色解锁时正常工作

### 2.2 Prompt 组装（1.5 天）

**新增文件：**
```
lib/features/audience/domain/
├── shout_prompt_builder.dart       # 跑步中喊话 Prompt 组装
└── interview_prompt_builder.dart   # 赛后采访 Prompt 组装（Phase 5 使用，此阶段先建骨架）
```

**任务：**
- [ ] 实现 `ShoutPromptBuilder.build()` 方法，拼接：
  1. 系统 prompt 模板（固定）
  2. 角色描述（从 `AudienceRole` 枚举取）
  3. 人格描述（从 `Personality` 枚举取）
  4. 跑者档案（`RunnerProfile.formatForPrompt()`）
  5. 当前实况（`TriggerContext.formatForPrompt()`）
  6. 今日状态倾向（从 `MoodState` 枚举取）
  7. 天气/节日附加信息（如有）
- [ ] 输出约束固定写死在模板中（15-40 字、必须引用数据等）
- [ ] `InterviewPromptBuilder` 先建空壳类，Phase 5 实现

**验收标准：**
- 不同角色组合 + 不同触发类型，输出的完整 prompt 可直接粘贴到 Claude/OpenAI playground 测试
- prompt 总长度控制在 1500 token 以内（含 RunnerProfile + TriggerContext）

### 2.3 观众引擎核心服务（1.5 天）

**新增文件：**
```
lib/features/audience/data/
└── audience_engine.dart   # AudienceEngine（Riverpod AsyncNotifier 或 Service 类）
```

**任务：**
- [ ] 实现 `Future<String?> generateShout(TriggerType, TriggerContext)` 核心方法：
  1. 调用 `VoicePicker` 抽取角色组合
  2. 调用 `ShoutPromptBuilder` 组装 prompt
  3. 通过现有 `LlmProvider` 调用 LLM API（非流式，`max_tokens: 80`，`temperature: 0.9`）
  4. 解析响应，提取纯文本
  5. 存入 `AudienceShout` 表
  6. 返回喊话文本 + 角色组合信息
- [ ] 超时处理：8 秒超时返回 null
- [ ] 失败静默：网络错误、API 错误均返回 null，不抛异常
- [ ] 并发互斥：上一次请求未完成时跳过新触发
- [ ] AI 未配置时直接返回 null（复用现有 `ai_preferences` 检查逻辑）

**验收标准：**
- 手动调用 `generateShout()` 传入模拟数据，返回符合角色特征的中文喊话
- 断网时返回 null，不崩溃
- 连续快速调用时正确跳过重复请求

### 2.4 TTS 集成（1 天）

**修改文件：** `shared/services/tts_service.dart`

**任务：**
- [ ] 新增 `Future<void> speakShout(String text)` 方法：
  - 如果当前有配速/距离的常规 TTS 在播报，排队等待（不打断）
  - 喊话内容优先级低于系统播报（配速提醒、公里分割提醒）
  - 息屏状态下也能正常播报
- [ ] 考虑播报速率：观众喊话可以稍快于正常播报速度（speechRate +0.1）
- [ ] 队列管理：如果积压了 2 条以上喊话，丢弃最旧的，只播最新的

**验收标准：**
- 喊话 TTS 不打断正在播报的配速提醒
- 息屏状态下喊话正常播出
- 快速触发 3 次，只播报最新 1 条

---

## Phase 3：跑步集成（~5 天）

**目标：** 跑步全流程（跑前状态选择 → 跑步中弹幕+TTS → 跑后喊话回顾）可真机体验。

### 3.1 跑前状态选择器（1 天）

**新增文件：**
```
lib/features/audience/presentation/
└── mood_selector.dart   # MoodSelector Widget
```

**任务：**
- [ ] 在倒计时页面（或倒计时前新增一步）显示 5 个状态卡片
  - 每个卡片：emoji 图标 + 状态名称（国际化）
  - 横向排列，一秒可选，选中高亮（accent 边框）
  - 默认选中「激励我」
- [ ] 选中的状态传入 `TrackingNotifier` 或通过 Riverpod provider 共享
- [ ] 如果用户不想选直接跳过 → 使用默认状态

**修改文件：**
- `features/tracking/presentation/tracking_screen.dart` — 倒计时前插入状态选择步骤
- `features/tracking/presentation/tracking_notifier.dart` — 新增 `moodState` 字段
- `features/tracking/presentation/tracking_state.dart` — 新增 `moodState` 字段

**验收标准：**
- 点击状态卡片有触觉反馈 + 视觉高亮
- 选择后进入倒计时，状态值正确传递到 tracking 流程
- 跳过选择时默认值生效

### 3.2 触发逻辑集成（1.5 天）

**修改文件：**
- `features/tracking/presentation/tracking_notifier.dart`

**任务：**
- [ ] 在 `TrackingNotifier` 中注入 `AudienceEngine`（通过 ref.read）
- [ ] 新增触发判断逻辑（零侵入方式，参考现有 AI 教练的 `ref.listen` 模式）：
  - **开跑触发：** 倒计时结束、状态变为 running 时触发 `START`
  - **公里分割触发：** 监听已完成公里数变化，调用 `shouldTriggerSplit()` 判断
  - **配速异常触发：** 当前公里配速偏离均值 > 20% 时触发 `PACE_ALERT`（每次跑步最多触发 2 次，防骚扰）
  - **结束触发：** 用户按下结束按钮时触发 `FINISH`
- [ ] 每次触发：构建 TriggerContext → 调用 AudienceEngine → 收到响应后通知 UI 层
- [ ] 触发间隔保护：两次触发之间至少间隔 30 秒

**关键约束：**
- **不修改 `TrackingNotifier` 核心 GPS/配速/计时逻辑**
- 使用 `ref.listen` 或独立 Notifier 监听状态变化，解耦实现
- 任何观众引擎故障不影响跑步记录功能

**验收标准：**
- 跑 3 公里，收到开跑 + 3 次公里分割 + 结束共 5 次触发（如果 LLM 响应及时）
- 跑步中 AudienceEngine 抛异常时，跑步功能完全不受影响
- 两次触发间隔 < 30 秒时，后一次被跳过

### 3.3 跑步中弹幕浮层（1.5 天）

**新增文件：**
```
lib/features/audience/presentation/
└── shout_overlay.dart   # ShoutOverlay Widget
```

**任务：**
- [ ] 实现弹幕卡片 Widget：
  - 角色 emoji + 角色×人格名称（小字，半透明）
  - 喊话内容（主体文字，白色）
  - 右侧小心形收藏按钮
  - 半透明暗色背景，圆角，符合 RunPure 暗色主题
- [ ] 动画：从顶部滑入（200ms），停留 4 秒，淡出（300ms）
- [ ] 定位：屏幕顶部安全区域下方，不遮挡底部核心数据区
- [ ] 点击收藏按钮：更新 AudienceShout.isFavorite，心形变实心，轻触觉反馈
- [ ] 同时只显示 1 条弹幕，新弹幕立即替换旧弹幕

**修改文件：**
- `features/tracking/presentation/tracking_screen.dart` — 用 Stack 叠加 ShoutOverlay

**验收标准：**
- 弹幕出现/消失动画流畅，不卡 GPS 采集
- 不遮挡配速、距离、时间等核心数据
- 收藏操作不中断跑步

### 3.4 跑后喊话回顾（1 天）

**修改文件：**
- `features/tracking/presentation/result_screen.dart`

**任务：**
- [ ] 在结果页新增「本场观众」区域（在现有数据汇总下方）：
  - 展示本次跑步的所有观众喊话列表
  - 每条：角色 emoji + 名称 + 喊话内容 + 触发时机（如"第 3 公里"）
  - 右侧收藏按钮
- [ ] 如果本场无喊话（AI 未配置或全部超时），隐藏该区域
- [ ] 区域标题："本场观众说了什么"

**验收标准：**
- 跑完后正确展示本场所有喊话记录
- 收藏状态与跑步中的操作同步（跑步中收藏的，这里显示已收藏）

---

## ── 里程碑：最小闭环完成 ──

Phase 1-3 完成后，可以真机体验完整流程：
1. 开始跑步前选择今日状态
2. 跑步中每公里听到不同角色的观众喊话（TTS + 弹幕）
3. 跑步中可收藏喜欢的喊话
4. 跑完后在结果页回顾所有观众喊话

---

## Phase 4：观众席页面（~5 天）

**目标：** 替换原 AI 聊天 Tab，完整实现金句墙、粉丝团、角色图鉴三个区域。

### 4.1 路由与导航变更（0.5 天）

**修改文件：**
- `app/router.dart`

**任务：**
- [ ] 底部导航 Tab：`/ai` → `/audience`
- [ ] 新增路由：`/audience/interview`（赛后采访，Phase 5 实现页面）
- [ ] 底部导航图标和文案更新：原 AI 图标 → 观众席图标（可用 megaphone / stadium 类图标）
- [ ] 国际化：更新 ARB 文件中的 Tab 名称

**验收标准：**
- 底部导航第 4 个 Tab 显示"观众席"
- 点击跳转到新页面（此阶段先放空白骨架）

### 4.2 观众席主页骨架（0.5 天）

**新增文件：**
```
lib/features/audience/presentation/
├── audience_home_screen.dart      # 主页面（ScrollView 包裹三个 Section）
└── audience_home_notifier.dart    # 状态管理（加载金句、粉丝团、解锁状态）
```

**任务：**
- [ ] 页面结构：CustomScrollView + 3 个 SliverToBoxAdapter 区域
- [ ] 加载数据：金句列表、粉丝团列表、全部角色解锁状态
- [ ] 骨架屏：加载中显示 RpCardSkeleton

### 4.3 金句墙区域（1.5 天）

**新增文件：**
```
lib/features/audience/presentation/
└── quote_wall_section.dart   # QuoteWallSection Widget
```

**任务：**
- [ ] 查询所有 `isFavorite = true` 的 AudienceShout，按 createdAt 倒序
- [ ] 每条金句卡片（RpCard tier2）：
  - 角色 emoji + 角色名×人格名（如"📊 数据狂人·毒舌损友"）
  - 喊话内容（主体文字）
  - 跑步日期 + 触发场景（如"2025-06-15 · 第 3 公里 · 配速 5'18"）
  - 从 triggerContext JSON 解析场景信息
- [ ] 左滑删除（取消收藏）
- [ ] 空状态："还没有金句，跑起来就有了" + 跑鞋图标
- [ ] 金句数量角标显示在区域标题旁

**验收标准：**
- 金句按时间倒序正确展示
- 左滑取消收藏后列表实时更新
- 空状态友好显示

### 4.4 固定粉丝团区域（1 天）

**新增文件：**
```
lib/features/audience/presentation/
└── fan_team_section.dart   # FanTeamSection Widget
```

**任务：**
- [ ] 查询 AudienceFavorite 表（最多 2 条）
- [ ] 每个粉丝团成员卡片：
  - 角色 emoji + 角色名×人格名
  - 代表性金句（关联的 AudienceShout 内容）
  - 点击可替换或移除
- [ ] 两个卡位横向排列，未占用的卡位显示虚线"+"号
- [ ] 点击"+"号：弹出角色选择器（已解锁角色 → 选择人格 → 确认）
- [ ] 已满 2 个时点击"+"提示替换
- [ ] 空状态："锁定你最喜欢的声音"

**验收标准：**
- 添加/替换/移除粉丝团成员操作正确
- 上限 2 个的限制正确执行
- 粉丝团成员在下次跑步时权重 ×1.5 生效

### 4.5 角色图鉴区域（1.5 天）

**新增文件：**
```
lib/features/audience/presentation/
├── role_gallery_section.dart   # RoleGallerySection Widget
└── role_detail_sheet.dart      # 角色详情 BottomSheet
```

**任务：**
- [ ] 7 个角色卡片网格（2 列布局）
- [ ] **已解锁卡片：**
  - 彩色背景 + 角色 emoji（大号）
  - 角色名称 + 一句话描述
  - 出场次数统计（从 AudienceShout 表 count）
  - 点击打开详情 BottomSheet
- [ ] **未解锁卡片：**
  - 灰色/暗色背景 + 锁图标
  - "再跑 X 次解锁"
  - 进度条（当前跑步次数 / 解锁阈值）
  - 点击无反应或弹出简短提示
- [ ] **角色详情 BottomSheet：**
  - 角色完整描述
  - 本角色的历史喊话列表（最近 20 条）
  - "加入粉丝团"按钮（需同时选择人格）
  - 出场次数、首次出场时间

**验收标准：**
- 已解锁/未解锁状态正确显示
- 进度条准确反映解锁进度
- 详情页历史喊话列表正确加载
- 从详情页添加到粉丝团操作正确

---

## Phase 5：赛后采访 + 角色解锁（~4 天）

**目标：** 跑完后可选角色对话；角色解锁动画和流程完整。

### 5.1 赛后采访 Prompt（0.5 天）

**修改文件：**
```
lib/features/audience/domain/
└── interview_prompt_builder.dart   # 实现 Phase 2 建的骨架
```

**任务：**
- [ ] 实现 `build()` 方法，拼接：
  - 采访系统 prompt 模板
  - 角色描述 + 人格描述
  - 本场喊话记录（从 AudienceShout 查询）
  - 跑者画像 + 完整本次跑步数据
  - 对话规则约束（2-4 句、保持角色、不给训练计划）
- [ ] 对话历史管理：复用现有 ChatMessages 表，conversationId = `interview_{sessionId}_{timestamp}`

### 5.2 赛后采访角色选择（1 天）

**修改文件：**
- `features/tracking/presentation/result_screen.dart`

**任务：**
- [ ] 在结果页"本场观众"区域下方新增「赛后采访」按钮
- [ ] 点击按钮弹出角色选择面板：
  - 展示本场出现过的所有角色组合（去重）
  - 每个选项：角色 emoji + 名称 + 本场某句代表性喊话
  - 点击选择后跳转到采访界面
- [ ] 如果本场无喊话，隐藏采访按钮

### 5.3 赛后采访对话界面（1.5 天）

**新增文件：**
```
lib/features/audience/presentation/
├── interview_screen.dart      # 采访对话界面
└── interview_notifier.dart    # 对话状态管理
```

**任务：**
- [ ] 界面设计：
  - 顶部：角色 emoji + 角色名×人格名 + "赛后采访"标签
  - 消息列表：角色消息（左侧）+ 用户消息（右侧）
  - 底部：文本输入框 + 发送按钮（**这是唯一有输入框的地方**）
  - 风格与 RunPure 暗色主题一致
- [ ] 首条消息：角色以本场最后一句喊话作为开场白，自动发送
- [ ] 对话逻辑：
  - 用户发送消息 → 追加到 ChatMessages 表
  - 构建 prompt（含对话历史，上限最近 20 条）
  - 流式调用 LLM（采访对话适合流式，回复较长）
  - 流式显示角色回复
- [ ] 复用现有 `llm/` 层的 SSE 流式客户端

**验收标准：**
- 选择角色后进入对话，角色开场白正确
- 对话中角色始终保持选定的角色×人格设定
- 角色回复引用本场跑步数据和喊话记录
- 退出后重新进入，对话历史保留

### 5.4 角色解锁系统（1 天）

**新增文件：**
```
lib/features/audience/domain/
└── unlock_checker.dart   # UnlockChecker
```

**新增/修改文件：**
```
lib/features/audience/presentation/
└── unlock_animation.dart   # 解锁动画
```

**任务：**
- [ ] `UnlockChecker.check(int totalRunCount)` — 跑步完成保存后调用
  - 检查赌徒（10）、显微镜侠（20）、影子对手团（30）是否满足条件
  - 满足且未解锁 → 写入 AudienceUnlock 表（`hasSeenAnimation = false`）
  - 返回新解锁的角色列表
- [ ] 解锁时机：`result_screen.dart` 保存跑步记录后调用检查
- [ ] 如果有新解锁 → 在结果页弹出解锁动画
- [ ] 解锁动画：
  - 卡片从灰色翻转为彩色（3D flip animation）
  - 角色 emoji 放大弹入
  - 角色自我介绍文案弹窗（如"赌徒已加入观众席：我押你下次更快！"）
  - 动画播放后标记 `hasSeenAnimation = true`
- [ ] 进入观众席页面时，检查 `hasSeenAnimation = false` 的记录，触发补播（防止结果页跳过）

**验收标准：**
- 第 10/20/30 次跑步完成后正确触发对应角色解锁
- 解锁动画播放完整且只播放一次
- 解锁后该角色立即出现在角色图鉴和抽取池中

---

## Phase 6：彩蛋系统 + 打磨 + 清理（~4 天）

**目标：** 天气/节日彩蛋上线，旧 AI 模块清理，全面打磨。

### 6.1 天气检测（0.5 天）

**新增文件：**
```
lib/features/audience/domain/
└── weather_detector.dart   # WeatherDetector
```

**任务：**
- [ ] 读取设备天气信息（如有 API 可用）或读取 GPS 定位获取的温度信息
- [ ] 简化方案：不强依赖天气 API，仅利用跑步时间判断（深夜/凌晨），温度由用户在设置中手动输入当日温度（可选字段）
- [ ] 输出：`WeatherInfo?`（temperature、weather、isNight、isDawn）
- [ ] 无法获取时返回 null，prompt 中不引用天气

### 6.2 节日检测（0.5 天）

**新增文件：**
```
lib/features/audience/domain/
└── holiday_detector.dart   # HolidayDetector
```

**任务：**
- [ ] 本地维护公历节日表（元旦、情人节、劳动节、国庆节、圣诞节等）
- [ ] 本地维护农历节日表（春节、元宵、端午、中秋、除夕）— 使用农历换算库或内置未来 5 年农历日期映射表
- [ ] `String? detectHoliday(DateTime date)` — 命中返回节日名称，否则返回 null
- [ ] 特殊日期：周末标记、跑者生日（如设置页有填写）

### 6.3 彩蛋注入 Prompt（0.5 天）

**修改文件：**
- `features/audience/domain/shout_prompt_builder.dart`

**任务：**
- [ ] 在 `build()` 方法中，根据 `TriggerContext` 的 weather/holiday/streak/comeback 字段追加对应 prompt 片段
- [ ] 极端天气、节日、连续跑步 7 天+、回归跑等场景的 prompt 片段实现
- [ ] 多个条件同时命中时全部追加（如"春节 + 深夜"）

**验收标准：**
- 春节当天跑步，观众喊话中自然融入春节元素
- 雨天跑步，部分角色提及雨天
- 普通日子无彩蛋内容干扰

### 6.4 旧模块清理（1 天）

**任务：**
- [ ] 删除 `features/ai_chat/` 目录（被观众席替换）
- [ ] 删除 `features/ai_coaching/` 目录（被观众引擎替换）
- [ ] 检查 `features/ai_summary/` 入口：确保从设置页或历史详情页仍可进入
- [ ] 清理 `router.dart` 中已废弃的路由
- [ ] 清理 `providers.dart` 中已废弃的 provider
- [ ] 清理 ARB 文件中已废弃的国际化 key
- [ ] 运行 `flutter analyze` 确保无死代码警告
- [ ] ChatMessages 表保留（赛后采访复用），但旧的 AI 聊天记录可在设置中提供"清理旧数据"选项

### 6.5 全面打磨（1.5 天）

**任务：**
- [ ] **Prompt 调优：** 真机跑 5-10 次，收集实际输出，针对"套话""超长""不引用数据""出戏"等问题调整 prompt 措辞和约束
- [ ] **TTS 体验：** 调整语速、停顿，确保喊话自然不生硬；测试中英文混合场景（如配速数字）
- [ ] **弹幕动画：** 调整滑入/淡出时长、停留时间，确保不干扰跑步同时能看清内容
- [ ] **性能验证：** 长距离跑步（模拟 20km）时内存和 API 调用频次是否合理
- [ ] **离线降级：** 未配置 AI / 无网络时，所有观众相关 UI 优雅隐藏或显示友好提示，跑步核心功能无任何影响
- [ ] **国际化检查：** 切换到英文，所有观众席相关 UI 文案正确显示
- [ ] **深色/浅色主题：** 弹幕、观众席页面、采访界面在两种主题下视觉正确
- [ ] **CLAUDE.md 更新：** 将观众系统的架构、路由、数据库变更同步更新到 CLAUDE.md

---

## 文件变更总表

### 新增文件（21 个）

| 文件路径 | Phase | 说明 |
|---------|-------|------|
| `data/daos/audience_shout_dao.dart` | 1 | 喊话记录 DAO |
| `data/daos/audience_favorite_dao.dart` | 1 | 固定粉丝团 DAO |
| `data/daos/audience_unlock_dao.dart` | 1 | 角色解锁 DAO |
| `features/audience/domain/audience_roles.dart` | 1 | 角色枚举 + prompt 描述 |
| `features/audience/domain/personalities.dart` | 1 | 人格枚举 + prompt 描述 |
| `features/audience/domain/mood_states.dart` | 1 | 状态枚举 + 权重表 |
| `features/audience/data/runner_profile_builder.dart` | 1 | 跑者画像预处理 |
| `features/audience/data/trigger_context_builder.dart` | 1 | 触发上下文构建 |
| `features/audience/domain/voice_picker.dart` | 2 | 角色组合随机算法 |
| `features/audience/domain/shout_prompt_builder.dart` | 2 | 喊话 Prompt 组装 |
| `features/audience/domain/interview_prompt_builder.dart` | 2+5 | 采访 Prompt 组装 |
| `features/audience/data/audience_engine.dart` | 2 | 核心引擎服务 |
| `features/audience/presentation/mood_selector.dart` | 3 | 跑前状态选择器 |
| `features/audience/presentation/shout_overlay.dart` | 3 | 跑步中弹幕浮层 |
| `features/audience/presentation/audience_home_screen.dart` | 4 | 观众席主页 |
| `features/audience/presentation/audience_home_notifier.dart` | 4 | 主页状态管理 |
| `features/audience/presentation/quote_wall_section.dart` | 4 | 金句墙区域 |
| `features/audience/presentation/fan_team_section.dart` | 4 | 固定粉丝团区域 |
| `features/audience/presentation/role_gallery_section.dart` | 4 | 角色图鉴区域 |
| `features/audience/presentation/role_detail_sheet.dart` | 4 | 角色详情弹窗 |
| `features/audience/presentation/interview_screen.dart` | 5 | 赛后采访对话界面 |
| `features/audience/presentation/interview_notifier.dart` | 5 | 采访对话状态管理 |
| `features/audience/presentation/unlock_animation.dart` | 5 | 解锁动画 |
| `features/audience/domain/unlock_checker.dart` | 5 | 解锁条件检查 |
| `features/audience/domain/weather_detector.dart` | 6 | 天气检测 |
| `features/audience/domain/holiday_detector.dart` | 6 | 节日检测 |
| `features/audience/providers.dart` | 1 | Riverpod providers |

### 修改文件（7 个）

| 文件路径 | Phase | 变更 |
|---------|-------|------|
| `data/database.dart` | 1 | 新增 3 张表，schemaVersion → 3，迁移逻辑 |
| `app/router.dart` | 4 | /ai → /audience，新增 /audience/interview |
| `features/tracking/presentation/tracking_screen.dart` | 3 | 弹幕浮层 + 跑前状态选择 |
| `features/tracking/presentation/tracking_notifier.dart` | 3 | 观众触发逻辑 + moodState 字段 |
| `features/tracking/presentation/tracking_state.dart` | 3 | moodState 字段 |
| `features/tracking/presentation/result_screen.dart` | 3+5 | 喊话回顾 + 赛后采访入口 + 解锁动画触发 |
| `shared/services/tts_service.dart` | 2 | 新增 speakShout 方法 + 队列管理 |

### 删除文件

| 目录 | Phase | 说明 |
|------|-------|------|
| `features/ai_chat/` | 6 | 整个目录删除（被观众席替换） |
| `features/ai_coaching/` | 6 | 整个目录删除（被观众引擎替换） |

---

## 风险与注意事项

### 技术风险

| 风险 | 影响 | 应对 |
|------|------|------|
| LLM 响应延迟 > 8s | 跑步中无喊话输出 | 超时跳过，不影响跑步；可考虑预生成机制（跑步开始时批量生成几条备用） |
| LLM 输出不符合约束（超长/不引用数据/出戏） | 体验下降 | Phase 6 集中 prompt 调优；增加后处理截断逻辑（> 50 字截断） |
| TTS 播报与 GPS 采集竞争资源 | GPS 延迟或 TTS 卡顿 | TTS 在独立 Isolate 或低优先级线程；GPS 采集优先级始终最高 |
| 农历日期计算复杂 | 节日彩蛋误判 | 使用内置映射表（未来 5 年），不引入复杂农历库 |
| 数据库迁移失败 | 用户数据丢失 | 迁移前备份；迁移失败 fallback 到重建表 |

### 设计注意

| 项目 | 注意事项 |
|------|----------|
| Prompt token 预算 | RunnerProfile + TriggerContext + 系统 prompt 合计控制在 1500 token 以内，避免不同 LLM 厂商 context 超限 |
| 角色 prompt 不外置 | 内联到枚举类属性中，便于 Claude Code 直接修改迭代，不需要管理外部文件 |
| 解锁阈值可调 | 阈值定义在 `audience_roles.dart` 枚举中，不硬编码在 checker 里，方便后续调整 |
| 国际化范围 | UI 文案全部国际化；角色/人格 prompt 描述保持中文（给 LLM 用）；角色在 UI 上的名称和介绍需中英双语 |
| 无障碍 | 弹幕有 Semantics label；收藏按钮有 tooltip；角色卡片有 contentDescription |
