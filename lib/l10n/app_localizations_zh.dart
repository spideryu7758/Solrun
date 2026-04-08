// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get nav_home => '首页';

  @override
  String get nav_history => '历史';

  @override
  String get nav_stats => '统计';

  @override
  String get nav_ai => 'AI';

  @override
  String get nav_settings => '设置';

  @override
  String get home_greetingNight => '夜深了';

  @override
  String get home_greetingMorning => '早上好';

  @override
  String get home_greetingAfternoon => '下午好';

  @override
  String get home_greetingEvening => '晚上好';

  @override
  String home_weekdays(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      '1': '周一',
      '2': '周二',
      '3': '周三',
      '4': '周四',
      '5': '周五',
      '6': '周六',
      '7': '周日',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String home_dateFormat(int month, int day, String weekday) {
    return '$month月$day日 $weekday';
  }

  @override
  String home_greetingWithName(String greeting, String name) {
    return '$greeting，$name';
  }

  @override
  String get home_trainingPlan => '训练计划';

  @override
  String get home_trainingPlanSubtitle => '选择或自定义跑步训练方案';

  @override
  String get home_thisWeek => '本周';

  @override
  String get home_unitKm => '公里';

  @override
  String get home_unitTimes => '次';

  @override
  String get home_avgPace => '均配';

  @override
  String get home_startRun => '开始跑步';

  @override
  String get stats_title => 'STATISTICS';

  @override
  String get stats_emptyTitle => '还没有跑步记录';

  @override
  String get stats_emptyAction => '开始跑步';

  @override
  String get stats_thisWeek => '本周';

  @override
  String get stats_thisMonth => '本月';

  @override
  String get stats_unitKm => '公里';

  @override
  String stats_timesAndPace(int count, String pace) {
    return '$count次 · 均配 $pace';
  }

  @override
  String get stats_aiSummaryLabel => 'AI 总结';

  @override
  String get stats_aiWeeklySummary => '周报';

  @override
  String get stats_aiMonthlySummary => '月报';

  @override
  String get stats_aiYearlySummary => '年报';

  @override
  String get stats_personalRecords => '个人记录';

  @override
  String get stats_longestDistance => '最长距离';

  @override
  String get stats_longestDuration => '最长时间';

  @override
  String get stats_fastestPace => '最快配速';

  @override
  String get stats_fastest5km => '5K 最佳';

  @override
  String stats_yearSuffix(int year) {
    return '$year年';
  }

  @override
  String stats_monthSuffix(int month) {
    return '$month月';
  }

  @override
  String get stats_selectYear => '选择年份';

  @override
  String get stats_selectMonth => '选择月份';

  @override
  String stats_tooltipDay(int day, String km) {
    return '第$day日 ${km}km';
  }

  @override
  String stats_yearMonthlyVolume(int year) {
    return '$year 年月跑量';
  }

  @override
  String get stats_allYearsVolume => '历年跑量';

  @override
  String stats_tooltipMonth(int month, String km) {
    return '$month月\n$km km';
  }

  @override
  String stats_tooltipYear(int year, String km) {
    return '$year\n$km km';
  }

  @override
  String get tracking_statusGpsWaiting => '等待 GPS';

  @override
  String get tracking_statusRunning => '运动中';

  @override
  String get tracking_statusPaused => '已暂停';

  @override
  String get tracking_statusAutoPaused => '自动暂停';

  @override
  String get tracking_unitKilometers => '公里';

  @override
  String get tracking_labelPace => '配速';

  @override
  String get tracking_labelDuration => '时长';

  @override
  String get tracking_labelCalories => '卡路里';

  @override
  String get tracking_stopTitle => '结束跑步';

  @override
  String get tracking_stopContent => '确定要结束本次跑步吗？';

  @override
  String get tracking_stopCancel => '继续跑';

  @override
  String get tracking_stopConfirm => '结束';

  @override
  String get history_title => '跑步记录';

  @override
  String get history_loadError => '加载失败';

  @override
  String get history_emptyTitle => '还没有跑步记录';

  @override
  String get history_emptySubtitle => '开始你的第一次跑步吧！';

  @override
  String get history_startRunning => '开始跑步';

  @override
  String history_monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': '一月',
      '2': '二月',
      '3': '三月',
      '4': '四月',
      '5': '五月',
      '6': '六月',
      '7': '七月',
      '8': '八月',
      '9': '九月',
      '10': '十月',
      '11': '十一月',
      '12': '十二月',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get history_unitKm => '公里';

  @override
  String history_monthSummary(int count, String hours) {
    return '累计$count次，共$hours小时';
  }

  @override
  String history_durationFormat(int min, String sec) {
    return '$min分$sec秒';
  }

  @override
  String get history_incomplete => '未完成';

  @override
  String get history_deleteConfirmTitle => '删除记录？';

  @override
  String history_deleteConfirmContent(String name) {
    return '确认删除「$name」？此操作不可撤销。';
  }

  @override
  String get history_deleteConfirmButton => '删除';

  @override
  String get history_today => '今天';

  @override
  String get history_yesterday => '昨天';

  @override
  String get historyDetail_title => '跑步详情';

  @override
  String get historyDetail_loadError => '加载失败';

  @override
  String get historyDetail_notFound => '记录不存在';

  @override
  String get historyDetail_trajectoryLoadError => '轨迹加载失败';

  @override
  String get historyDetail_noTrajectory => '无轨迹数据';

  @override
  String get historyDetail_splitPace => '分公里配速';

  @override
  String get historyDetail_distanceTooShort => '距离不足 1 公里';

  @override
  String get historyDetail_replay => '轨迹回放';

  @override
  String get historyDetail_share => '分享跑步记录';

  @override
  String get historyDetail_delete => '删除记录';

  @override
  String get historyDetail_distance => '距离';

  @override
  String get historyDetail_duration => '用时';

  @override
  String get historyDetail_pace => '均配速';

  @override
  String get historyDetail_bestPace => '最快配速';

  @override
  String get historyDetail_calories => '卡路里';

  @override
  String get historyDetail_elevation => '海拔爬升';

  @override
  String get historyDetail_rename => '修改名称';

  @override
  String get historyDetail_cancel => '取消';

  @override
  String get historyDetail_save => '保存';

  @override
  String get historyDetail_exportFailed => '导出失败';

  @override
  String get training_title => '训练计划';

  @override
  String get training_emptyTitle => '暂无训练计划';

  @override
  String training_weeks(int count) {
    return '$count 周';
  }

  @override
  String get trainingDetail_title => '计划详情';

  @override
  String get trainingDetail_notFound => '计划不存在';

  @override
  String trainingDetail_weeksPlan(int count) {
    return '$count 周计划';
  }

  @override
  String get trainingDetail_startTraining => '开始训练';

  @override
  String trainingDetail_week(int week) {
    return '第 $week 周';
  }

  @override
  String get trainingDetail_restWeek => '休息周';

  @override
  String trainingDetail_dayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': '周一',
      '2': '周二',
      '3': '周三',
      '4': '周四',
      '5': '周五',
      '6': '周六',
      '7': '周日',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String get trainingDetail_typeEasyRun => '轻松跑';

  @override
  String get trainingDetail_typeTempo => '节奏跑';

  @override
  String get trainingDetail_typeInterval => '间歇跑';

  @override
  String get trainingDetail_typeRest => '休息';

  @override
  String get trainingDetail_target => '目标';

  @override
  String get trainingDetail_intervalTraining => '间歇训练';

  @override
  String get chat_title => 'AI 助手';

  @override
  String get chat_historyTitle => '会话历史';

  @override
  String get chat_newConversation => '新建对话';

  @override
  String get chat_notConfigured => '请先在设置 → AI 服务配置中设置 AI 服务';

  @override
  String get chat_emptyTitle => '问我任何问题';

  @override
  String get chat_emptySubtitle => '跑步数据分析、训练建议、或其他话题';

  @override
  String get chat_suggestion1 => '分析我本周跑步表现';

  @override
  String get chat_suggestion2 => '给我一个训练建议';

  @override
  String get chat_suggestion3 => '解读我的配速变化';

  @override
  String get chat_suggestion4 => '如何提高耐力？';

  @override
  String get chat_generating => '生成中...';

  @override
  String get chat_inputHint => '输入消息...';

  @override
  String chat_historyCount(int count, String size) {
    return '$count 个 · $size';
  }

  @override
  String get chat_clearAllTitle => '清空所有会话？';

  @override
  String chat_clearAllContent(int count) {
    return '将删除全部 $count 个会话，此操作不可撤销。';
  }

  @override
  String get chat_clearAll => '清空';

  @override
  String get chat_noMessages => '暂无会话记录';

  @override
  String get chat_deleteTitle => '删除会话？';

  @override
  String get chat_deleteConfirm => '此操作不可撤销';

  @override
  String get chat_delete => '删除';

  @override
  String get chat_current => '当前';

  @override
  String get chat_justNow => '刚刚';

  @override
  String chat_minutesAgo(int minutes) {
    return '$minutes 分钟前';
  }

  @override
  String chat_hoursAgo(int hours) {
    return '$hours 小时前';
  }

  @override
  String chat_daysAgo(int days) {
    return '$days 天前';
  }

  @override
  String get aiSettings_title => 'AI 服务配置';

  @override
  String get aiSettings_saved => 'AI 配置已保存';

  @override
  String get aiSettings_cleared => 'AI 配置已清除';

  @override
  String get aiSettings_clearConfig => '清除配置';

  @override
  String get aiSettings_provider => '选择 AI 服务';

  @override
  String get aiSettings_baseUrl => '服务地址';

  @override
  String get aiSettings_model => '模型';

  @override
  String get aiSettings_modelHint => '留空使用默认模型';

  @override
  String get aiSettings_save => '保存配置';

  @override
  String get aiSettings_apiKeyHint => '输入 API Key';

  @override
  String get aiSettings_testing => '测试中...';

  @override
  String get aiSettings_testConnection => '测试连接';

  @override
  String get aiSettings_testSuccess => '连接成功';

  @override
  String get aiSettings_testFail => '连接失败';

  @override
  String get aiSettings_helpTitle => '说明';

  @override
  String get aiSettings_help1 => 'API Key 使用设备加密存储，不会上传至任何服务器';

  @override
  String get aiSettings_help2 => '跑步数据仅在你主动使用 AI 功能时才会发送至所选服务';

  @override
  String get aiSettings_help3 => 'OpenClaw 为本地自托管方案，数据不离开你的设备';

  @override
  String get aiSettings_help4 => '选择「自定义」可接入任何兼容 OpenAI 协议的服务';

  @override
  String get summary_notConfigured => '请先在设置中配置 AI 服务';

  @override
  String get summary_generating => '正在生成分析...';

  @override
  String get summary_runAnalysis => 'AI 跑步分析';

  @override
  String get summary_weeklyTitle => 'AI 周总结';

  @override
  String get summary_monthlyTitle => 'AI 月总结';

  @override
  String get summary_yearlyTitle => 'AI 年总结';

  @override
  String get summary_title => 'AI 分析';

  @override
  String get settings_title => '设置';

  @override
  String get settings_personalInfo => '个人信息';

  @override
  String get settings_runSettings => '跑步设置';

  @override
  String get settings_autoPause => '自动暂停';

  @override
  String get settings_autoPauseDesc => '速度 < 1.0 km/h 持续 5 秒自动暂停';

  @override
  String get settings_ttsSection => '语音播报';

  @override
  String get settings_tts => '语音播报';

  @override
  String get settings_ttsDesc => '跑步中播报距离和配速';

  @override
  String get settings_ttsInterval => '播报间隔';

  @override
  String settings_ttsEveryKm(int km) {
    return '每 $km km';
  }

  @override
  String get settings_aiSection => 'AI 助手';

  @override
  String get settings_aiConfig => 'AI 服务配置';

  @override
  String get settings_aiConfigured => '已配置';

  @override
  String get settings_aiNotConfigured => '未配置，点击设置';

  @override
  String get settings_aiCoach => '跑步中 AI 教练';

  @override
  String get settings_aiCoachDesc => '跑步时 AI 实时提供配速建议和鼓励';

  @override
  String get settings_chatHistory => '聊天记录';

  @override
  String settings_chatStorage(int count, String size) {
    return '$count 条消息，$size';
  }

  @override
  String get settings_loading => '加载中...';

  @override
  String get settings_appearance => '外观';

  @override
  String get settings_themeDark => '深色';

  @override
  String get settings_themeLight => '浅色';

  @override
  String get settings_themeSystem => '系统';

  @override
  String get settings_language => '语言';

  @override
  String get settings_langZh => '中文';

  @override
  String get settings_langEn => 'English';

  @override
  String get settings_langSystem => '系统';

  @override
  String get settings_mapSection => '地图设置';

  @override
  String get settings_mapSource => '瓦片源';

  @override
  String get settings_mapCache => '地图缓存';

  @override
  String get settings_amapApiKey => '高德 API Key';

  @override
  String get settings_amapApiKeyHint => '用于城市识别（可选）';

  @override
  String get settings_amapApiKeyDesc =>
      '在 lbs.amap.com 免费申请 Web 服务 Key，用于跑步结束时识别城市名称。不填则使用 OpenStreetMap（部分网络可能不可用）。';

  @override
  String get settings_amapApiKeyPlaceholder => '输入高德 Web 服务 API Key';

  @override
  String get settings_customTileUrl => '自定义瓦片 URL';

  @override
  String get settings_customTileUrlHint =>
      '例如: https://tile.example.com/z/x/y.png';

  @override
  String get settings_dataManagement => '数据管理';

  @override
  String get settings_importGarmin => '导入 Garmin 记录';

  @override
  String get settings_importGarminDesc => '从 Garmin Connect 导出的 JSON 导入';

  @override
  String get settings_importGpx => '导入 GPX';

  @override
  String get settings_importGpxDesc => '从其他跑步 App 导入记录';

  @override
  String get settings_exportAll => '导出全部记录';

  @override
  String get settings_exportAllDesc => '打包为 GPX + CSV';

  @override
  String get settings_clearAll => '清空全部记录';

  @override
  String get settings_irreversible => '此操作不可撤销';

  @override
  String get settings_nickname => '名称';

  @override
  String get settings_notSet => '未设置';

  @override
  String get settings_setNickname => '设置名称';

  @override
  String get settings_nicknameHint => '输入你的名称';

  @override
  String get settings_cancel => '取消';

  @override
  String get settings_confirm => '确认';

  @override
  String get settings_weight => '体重';

  @override
  String get settings_unit => '距离单位';

  @override
  String get settings_inputWeight => '输入体重';

  @override
  String get settings_clearMapCacheTitle => '清空地图缓存？';

  @override
  String settings_clearMapCacheContent(int sizeMb) {
    return '将删除 $sizeMb MB 的缓存瓦片。';
  }

  @override
  String get settings_clear => '清空';

  @override
  String get settings_mapCacheCleared => '地图缓存已清空';

  @override
  String get settings_parsingGarmin => '正在解析 Garmin 数据...';

  @override
  String get settings_importingRuns => '正在导入跑步记录...';

  @override
  String settings_importSuccess(int count) {
    return '成功导入 $count 条记录';
  }

  @override
  String settings_importSkipped(int count) {
    return '跳过 $count 条（已存在）';
  }

  @override
  String settings_importSkippedGpx(int count) {
    return '跳过 $count 条（已存在或无轨迹）';
  }

  @override
  String settings_importFailed(int count) {
    return '失败 $count 条：';
  }

  @override
  String settings_importMoreErrors(int count) {
    return '... 及其他 $count 条';
  }

  @override
  String get settings_garminImportDone => 'Garmin 导入完成';

  @override
  String get settings_importError => '导入失败';

  @override
  String get settings_preparingImport => '准备导入...';

  @override
  String settings_importingProgress(int current, int total) {
    return '正在导入 ($current/$total)';
  }

  @override
  String get settings_importDone => '导入完成';

  @override
  String settings_extracting(String filename) {
    return '正在解压 $filename...';
  }

  @override
  String get settings_noDataToExport => '没有跑步记录可导出';

  @override
  String get settings_preparingExport => '准备导出...';

  @override
  String settings_exportingProgress(int current, int total) {
    return '导出中 ($current/$total)';
  }

  @override
  String get settings_packingZip => '正在打包为 zip...';

  @override
  String settings_exportShareText(int count) {
    return 'Solrun 跑步记录导出（$count 条）';
  }

  @override
  String get settings_noChatHistory => '没有聊天记录';

  @override
  String get settings_clearChatTitle => '清空聊天记录？';

  @override
  String settings_clearChatContent(int count, String size) {
    return '将删除所有 AI 对话记录（$count 条消息，$size）。\n此操作不可撤销。';
  }

  @override
  String get settings_chatHistoryCleared => '聊天记录已清空';

  @override
  String get settings_clearAllTitle => '清空全部记录？';

  @override
  String get settings_clearAllContent => '此操作不可撤销，所有跑步记录将被永久删除。';

  @override
  String get settings_allDataCleared => '已清空全部记录';

  @override
  String get result_notFound => '记录不存在';

  @override
  String get result_title => '✦ 完成跑步';

  @override
  String get result_avgPace => '平均配速';

  @override
  String get result_calories => '卡路里';

  @override
  String get result_bestPace => '最快配速';

  @override
  String get result_elevation => '爬升';

  @override
  String get result_tapToExpand => '点击展开';

  @override
  String get result_aiAnalysis => 'AI 分析本次跑步';

  @override
  String get result_save => '完成';

  @override
  String get result_share => '分享';

  @override
  String get main_crashRecoveryTitle => '发现未完成的跑步';

  @override
  String main_crashRecoveryContent(String distance, String duration) {
    return '发现一条未完成的跑步记录（$distance km / $duration），是否恢复？';
  }

  @override
  String get main_discard => '放弃';

  @override
  String get main_recover => '恢复';

  @override
  String get nav_audience => '观众';

  @override
  String get audience_role_screamingFan => '尖叫粉';

  @override
  String get audience_role_dataNerd => '数据狂人';

  @override
  String get audience_role_familyCrew => '亲友后援会';

  @override
  String get audience_role_zenViewer => '佛系观赛组';

  @override
  String get audience_role_gambler => '赌徒';

  @override
  String get audience_role_nitpicker => '显微镜侠';

  @override
  String get audience_role_rivalFan => '影子对手团';

  @override
  String get audience_personality_savage => '毒舌损友';

  @override
  String get audience_personality_hypeCoach => '热血教练';

  @override
  String get audience_personality_poet => '诗意文青';

  @override
  String get audience_personality_clown => '逗逼老炮';

  @override
  String get audience_personality_commentator => '冷面解说';

  @override
  String get audience_moodTitle => '今天想让观众怎么喊？';

  @override
  String get audience_moodConfirm => '开始跑步';

  @override
  String get audience_mood_motivate => '激励我';

  @override
  String get audience_mood_comfort => '安慰我';

  @override
  String get audience_mood_provoke => '刺激我';

  @override
  String get audience_mood_amuse => '逗我笑';

  @override
  String get audience_mood_focus => '专注跑';

  @override
  String get audience_quoteWallTitle => '金句墙';

  @override
  String get audience_quoteWallEmpty => '还没有金句，跑起来就有了';

  @override
  String get audience_fanTeamTitle => '我的粉丝团';

  @override
  String get audience_fanTeamEmpty => '锁定你最喜欢的声音';

  @override
  String get audience_fanTeamLimit => '粉丝团已满，请先移除一个';

  @override
  String get audience_roleGalleryTitle => '角色图鉴';

  @override
  String audience_unlockAt(int count) {
    return '累计跑步 $count 次解锁';
  }

  @override
  String audience_runsToUnlock(int count) {
    return '再跑 $count 次解锁';
  }

  @override
  String get audience_joinFanTeam => '加入粉丝团';

  @override
  String get audience_removeFromFanTeam => '移出粉丝团';

  @override
  String get audience_shoutsTitle => '本场观众说了什么';

  @override
  String get audience_noShouts => '本场无观众喊话';

  @override
  String get audience_interviewTitle => '赛后采访';

  @override
  String get audience_selectRoleForInterview => '选择采访对象';

  @override
  String get audience_newRunner => '新跑者';

  @override
  String get audience_roleDesc_screamingFan => '情绪化狂热支持者，无条件应援';

  @override
  String get audience_roleDesc_dataNerd => '理性至极端，所有判断基于数据模型';

  @override
  String get audience_roleDesc_familyCrew => '家人朋友，情感优先';

  @override
  String get audience_roleDesc_zenViewer => '温和包容，关注跑步本身';

  @override
  String get audience_roleDesc_gambler => '押注跑者成绩，数据波动引发激烈情绪';

  @override
  String get audience_roleDesc_nitpicker => '专挖黑历史，放大最差数据';

  @override
  String get audience_roleDesc_rivalFan => '其他跑者的支持者，借数据贬低跑者';

  @override
  String audience_shoutCount(int count) {
    return '出场 $count 次';
  }

  @override
  String get audience_firstAppearance => '首次出场';

  @override
  String get audience_noShoutsYet => '暂无喊话记录';

  @override
  String get audience_selectPersonality => '选择人格风格';

  @override
  String get audience_selectRole => '选择角色';

  @override
  String get audience_confirmAdd => '确认加入';

  @override
  String get audience_replace => '替换';

  @override
  String get audience_remove => '移除';

  @override
  String get audience_fanTeamReplaceHint => '粉丝团已满，选择要替换的成员';

  @override
  String get audience_favoriteRemoved => '已取消收藏';

  @override
  String get audience_fanAdded => '已加入粉丝团';

  @override
  String get audience_fanReplaced => '已替换粉丝团成员';

  @override
  String get audience_fanRemoved => '已移出粉丝团';

  @override
  String get audience_quoteCopied => '已复制到剪贴板';

  @override
  String get audience_favoriteAdded => '已收藏到金句墙';

  @override
  String get audience_sceneStart => '开跑';

  @override
  String audience_sceneSplitKm(Object km) {
    return '第 $km 公里';
  }

  @override
  String get audience_sceneFinish => '冲线';

  @override
  String get audience_scenePaceAlert => '配速提醒';

  @override
  String get audience_interviewHint => '向观众提问...';

  @override
  String audience_interviewOpening(String role) {
    return '$role 想跟你聊聊这场比赛';
  }

  @override
  String get audience_interviewStreaming => '正在回复...';

  @override
  String get audience_interviewRoleDesc => '选择一个观众角色来采访你';

  @override
  String get share_pace => '配速';

  @override
  String get share_duration => '时长';

  @override
  String get share_calories => '卡路里';

  @override
  String get share_elevationGain => '累计爬升';

  @override
  String get share_distance => '距离';

  @override
  String get share_kilometer => '公里';

  @override
  String get share_noRouteData => '无轨迹数据';

  @override
  String get share_overflowWarning => '该比例图框较小，请减少数据展示项';

  @override
  String get share_customize => '自定义';

  @override
  String get share_saveToGallery => '保存到相册';

  @override
  String get share_share => '分享';

  @override
  String get share_savedToGallery => '已保存到相册';

  @override
  String share_saveFailed(String error) {
    return '保存失败: $error';
  }

  @override
  String get share_runRecord => 'Solrun 跑步记录';

  @override
  String get share_title => '分享跑步记录';

  @override
  String share_loadFailed(String error) {
    return '加载失败: $error';
  }

  @override
  String get share_templateClassic => '经典';

  @override
  String get share_templateHeatmap => '热力';

  @override
  String get share_templateMap => '地图';

  @override
  String get share_templateMinimal => '极简';

  @override
  String get share_toggleHeatmap => '热力轨迹';

  @override
  String get share_toggleMapTiles => '地图底图';

  @override
  String get share_togglePaceChart => '配速图表';

  @override
  String get share_toggleElevation => '海拔剖面';

  @override
  String get share_toggleDataGrid => '数据网格';

  @override
  String get share_toggleHeader => '头部信息';

  @override
  String share_optionNotSupported(String label, String template) {
    return '$label 无法在$template风格中展示';
  }

  @override
  String share_unsupportedTemplate(String template) {
    return '不支持$template风格';
  }

  @override
  String get share_audienceQuote => '观众语录';
}
