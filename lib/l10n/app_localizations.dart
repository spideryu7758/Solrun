import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @nav_home.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get nav_home;

  /// No description provided for @nav_history.
  ///
  /// In zh, this message translates to:
  /// **'历史'**
  String get nav_history;

  /// No description provided for @nav_stats.
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get nav_stats;

  /// No description provided for @nav_ai.
  ///
  /// In zh, this message translates to:
  /// **'AI'**
  String get nav_ai;

  /// No description provided for @nav_settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get nav_settings;

  /// No description provided for @home_greetingNight.
  ///
  /// In zh, this message translates to:
  /// **'夜深了'**
  String get home_greetingNight;

  /// No description provided for @home_greetingMorning.
  ///
  /// In zh, this message translates to:
  /// **'早上好'**
  String get home_greetingMorning;

  /// No description provided for @home_greetingAfternoon.
  ///
  /// In zh, this message translates to:
  /// **'下午好'**
  String get home_greetingAfternoon;

  /// No description provided for @home_greetingEvening.
  ///
  /// In zh, this message translates to:
  /// **'晚上好'**
  String get home_greetingEvening;

  /// No description provided for @home_weekdays.
  ///
  /// In zh, this message translates to:
  /// **'{weekday, select, 1{周一} 2{周二} 3{周三} 4{周四} 5{周五} 6{周六} 7{周日} other{}}'**
  String home_weekdays(String weekday);

  /// No description provided for @home_dateFormat.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日 {weekday}'**
  String home_dateFormat(int month, int day, String weekday);

  /// No description provided for @home_greetingWithName.
  ///
  /// In zh, this message translates to:
  /// **'{greeting}，{name}'**
  String home_greetingWithName(String greeting, String name);

  /// No description provided for @home_trainingPlan.
  ///
  /// In zh, this message translates to:
  /// **'训练计划'**
  String get home_trainingPlan;

  /// No description provided for @home_trainingPlanSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'选择或自定义跑步训练方案'**
  String get home_trainingPlanSubtitle;

  /// No description provided for @home_thisWeek.
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get home_thisWeek;

  /// No description provided for @home_unitKm.
  ///
  /// In zh, this message translates to:
  /// **'公里'**
  String get home_unitKm;

  /// No description provided for @home_unitTimes.
  ///
  /// In zh, this message translates to:
  /// **'次'**
  String get home_unitTimes;

  /// No description provided for @home_avgPace.
  ///
  /// In zh, this message translates to:
  /// **'均配'**
  String get home_avgPace;

  /// No description provided for @home_startRun.
  ///
  /// In zh, this message translates to:
  /// **'开始跑步'**
  String get home_startRun;

  /// No description provided for @stats_title.
  ///
  /// In zh, this message translates to:
  /// **'STATISTICS'**
  String get stats_title;

  /// No description provided for @stats_emptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有跑步记录'**
  String get stats_emptyTitle;

  /// No description provided for @stats_emptyAction.
  ///
  /// In zh, this message translates to:
  /// **'开始跑步'**
  String get stats_emptyAction;

  /// No description provided for @stats_thisWeek.
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get stats_thisWeek;

  /// No description provided for @stats_thisMonth.
  ///
  /// In zh, this message translates to:
  /// **'本月'**
  String get stats_thisMonth;

  /// No description provided for @stats_unitKm.
  ///
  /// In zh, this message translates to:
  /// **'公里'**
  String get stats_unitKm;

  /// No description provided for @stats_timesAndPace.
  ///
  /// In zh, this message translates to:
  /// **'{count}次 · 均配 {pace}'**
  String stats_timesAndPace(int count, String pace);

  /// No description provided for @stats_aiSummaryLabel.
  ///
  /// In zh, this message translates to:
  /// **'AI 总结'**
  String get stats_aiSummaryLabel;

  /// No description provided for @stats_aiWeeklySummary.
  ///
  /// In zh, this message translates to:
  /// **'周报'**
  String get stats_aiWeeklySummary;

  /// No description provided for @stats_aiMonthlySummary.
  ///
  /// In zh, this message translates to:
  /// **'月报'**
  String get stats_aiMonthlySummary;

  /// No description provided for @stats_aiYearlySummary.
  ///
  /// In zh, this message translates to:
  /// **'年报'**
  String get stats_aiYearlySummary;

  /// No description provided for @stats_personalRecords.
  ///
  /// In zh, this message translates to:
  /// **'个人记录'**
  String get stats_personalRecords;

  /// No description provided for @stats_longestDistance.
  ///
  /// In zh, this message translates to:
  /// **'最长距离'**
  String get stats_longestDistance;

  /// No description provided for @stats_longestDuration.
  ///
  /// In zh, this message translates to:
  /// **'最长时间'**
  String get stats_longestDuration;

  /// No description provided for @stats_fastestPace.
  ///
  /// In zh, this message translates to:
  /// **'最快配速'**
  String get stats_fastestPace;

  /// No description provided for @stats_fastest5km.
  ///
  /// In zh, this message translates to:
  /// **'5K 最佳'**
  String get stats_fastest5km;

  /// No description provided for @stats_yearSuffix.
  ///
  /// In zh, this message translates to:
  /// **'{year}年'**
  String stats_yearSuffix(int year);

  /// No description provided for @stats_monthSuffix.
  ///
  /// In zh, this message translates to:
  /// **'{month}月'**
  String stats_monthSuffix(int month);

  /// No description provided for @stats_selectYear.
  ///
  /// In zh, this message translates to:
  /// **'选择年份'**
  String get stats_selectYear;

  /// No description provided for @stats_selectMonth.
  ///
  /// In zh, this message translates to:
  /// **'选择月份'**
  String get stats_selectMonth;

  /// No description provided for @stats_tooltipDay.
  ///
  /// In zh, this message translates to:
  /// **'第{day}日 {km}km'**
  String stats_tooltipDay(int day, String km);

  /// No description provided for @stats_yearMonthlyVolume.
  ///
  /// In zh, this message translates to:
  /// **'{year} 年月跑量'**
  String stats_yearMonthlyVolume(int year);

  /// No description provided for @stats_allYearsVolume.
  ///
  /// In zh, this message translates to:
  /// **'历年跑量'**
  String get stats_allYearsVolume;

  /// No description provided for @stats_tooltipMonth.
  ///
  /// In zh, this message translates to:
  /// **'{month}月\n{km} km'**
  String stats_tooltipMonth(int month, String km);

  /// No description provided for @stats_tooltipYear.
  ///
  /// In zh, this message translates to:
  /// **'{year}\n{km} km'**
  String stats_tooltipYear(int year, String km);

  /// No description provided for @tracking_statusGpsWaiting.
  ///
  /// In zh, this message translates to:
  /// **'等待 GPS'**
  String get tracking_statusGpsWaiting;

  /// No description provided for @tracking_statusRunning.
  ///
  /// In zh, this message translates to:
  /// **'运动中'**
  String get tracking_statusRunning;

  /// No description provided for @tracking_statusPaused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get tracking_statusPaused;

  /// No description provided for @tracking_statusAutoPaused.
  ///
  /// In zh, this message translates to:
  /// **'自动暂停'**
  String get tracking_statusAutoPaused;

  /// No description provided for @tracking_unitKilometers.
  ///
  /// In zh, this message translates to:
  /// **'公里'**
  String get tracking_unitKilometers;

  /// No description provided for @tracking_labelPace.
  ///
  /// In zh, this message translates to:
  /// **'配速'**
  String get tracking_labelPace;

  /// No description provided for @tracking_labelDuration.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get tracking_labelDuration;

  /// No description provided for @tracking_labelCalories.
  ///
  /// In zh, this message translates to:
  /// **'卡路里'**
  String get tracking_labelCalories;

  /// No description provided for @tracking_stopTitle.
  ///
  /// In zh, this message translates to:
  /// **'结束跑步'**
  String get tracking_stopTitle;

  /// No description provided for @tracking_stopContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要结束本次跑步吗？'**
  String get tracking_stopContent;

  /// No description provided for @tracking_stopCancel.
  ///
  /// In zh, this message translates to:
  /// **'继续跑'**
  String get tracking_stopCancel;

  /// No description provided for @tracking_stopConfirm.
  ///
  /// In zh, this message translates to:
  /// **'结束'**
  String get tracking_stopConfirm;

  /// No description provided for @history_title.
  ///
  /// In zh, this message translates to:
  /// **'跑步记录'**
  String get history_title;

  /// No description provided for @history_loadError.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get history_loadError;

  /// No description provided for @history_emptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有跑步记录'**
  String get history_emptyTitle;

  /// No description provided for @history_emptySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'开始你的第一次跑步吧！'**
  String get history_emptySubtitle;

  /// No description provided for @history_startRunning.
  ///
  /// In zh, this message translates to:
  /// **'开始跑步'**
  String get history_startRunning;

  /// No description provided for @history_monthName.
  ///
  /// In zh, this message translates to:
  /// **'{month, select, 1{一月} 2{二月} 3{三月} 4{四月} 5{五月} 6{六月} 7{七月} 8{八月} 9{九月} 10{十月} 11{十一月} 12{十二月} other{}}'**
  String history_monthName(String month);

  /// No description provided for @history_unitKm.
  ///
  /// In zh, this message translates to:
  /// **'公里'**
  String get history_unitKm;

  /// No description provided for @history_monthSummary.
  ///
  /// In zh, this message translates to:
  /// **'累计{count}次，共{hours}小时'**
  String history_monthSummary(int count, String hours);

  /// No description provided for @history_durationFormat.
  ///
  /// In zh, this message translates to:
  /// **'{min}分{sec}秒'**
  String history_durationFormat(int min, String sec);

  /// No description provided for @history_incomplete.
  ///
  /// In zh, this message translates to:
  /// **'未完成'**
  String get history_incomplete;

  /// No description provided for @history_deleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除记录？'**
  String get history_deleteConfirmTitle;

  /// No description provided for @history_deleteConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'确认删除「{name}」？此操作不可撤销。'**
  String history_deleteConfirmContent(String name);

  /// No description provided for @history_deleteConfirmButton.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get history_deleteConfirmButton;

  /// No description provided for @history_today.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get history_today;

  /// No description provided for @history_yesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get history_yesterday;

  /// No description provided for @historyDetail_title.
  ///
  /// In zh, this message translates to:
  /// **'跑步详情'**
  String get historyDetail_title;

  /// No description provided for @historyDetail_loadError.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get historyDetail_loadError;

  /// No description provided for @historyDetail_notFound.
  ///
  /// In zh, this message translates to:
  /// **'记录不存在'**
  String get historyDetail_notFound;

  /// No description provided for @historyDetail_trajectoryLoadError.
  ///
  /// In zh, this message translates to:
  /// **'轨迹加载失败'**
  String get historyDetail_trajectoryLoadError;

  /// No description provided for @historyDetail_noTrajectory.
  ///
  /// In zh, this message translates to:
  /// **'无轨迹数据'**
  String get historyDetail_noTrajectory;

  /// No description provided for @historyDetail_splitPace.
  ///
  /// In zh, this message translates to:
  /// **'分公里配速'**
  String get historyDetail_splitPace;

  /// No description provided for @historyDetail_distanceTooShort.
  ///
  /// In zh, this message translates to:
  /// **'距离不足 1 公里'**
  String get historyDetail_distanceTooShort;

  /// No description provided for @historyDetail_replay.
  ///
  /// In zh, this message translates to:
  /// **'轨迹回放'**
  String get historyDetail_replay;

  /// No description provided for @historyDetail_share.
  ///
  /// In zh, this message translates to:
  /// **'分享跑步记录'**
  String get historyDetail_share;

  /// No description provided for @historyDetail_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除记录'**
  String get historyDetail_delete;

  /// No description provided for @historyDetail_distance.
  ///
  /// In zh, this message translates to:
  /// **'距离'**
  String get historyDetail_distance;

  /// No description provided for @historyDetail_duration.
  ///
  /// In zh, this message translates to:
  /// **'用时'**
  String get historyDetail_duration;

  /// No description provided for @historyDetail_pace.
  ///
  /// In zh, this message translates to:
  /// **'均配速'**
  String get historyDetail_pace;

  /// No description provided for @historyDetail_bestPace.
  ///
  /// In zh, this message translates to:
  /// **'最快配速'**
  String get historyDetail_bestPace;

  /// No description provided for @historyDetail_calories.
  ///
  /// In zh, this message translates to:
  /// **'卡路里'**
  String get historyDetail_calories;

  /// No description provided for @historyDetail_elevation.
  ///
  /// In zh, this message translates to:
  /// **'海拔爬升'**
  String get historyDetail_elevation;

  /// No description provided for @historyDetail_rename.
  ///
  /// In zh, this message translates to:
  /// **'修改名称'**
  String get historyDetail_rename;

  /// No description provided for @historyDetail_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get historyDetail_cancel;

  /// No description provided for @historyDetail_save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get historyDetail_save;

  /// No description provided for @historyDetail_exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get historyDetail_exportFailed;

  /// No description provided for @training_title.
  ///
  /// In zh, this message translates to:
  /// **'训练计划'**
  String get training_title;

  /// No description provided for @training_emptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无训练计划'**
  String get training_emptyTitle;

  /// No description provided for @training_weeks.
  ///
  /// In zh, this message translates to:
  /// **'{count} 周'**
  String training_weeks(int count);

  /// No description provided for @trainingDetail_title.
  ///
  /// In zh, this message translates to:
  /// **'计划详情'**
  String get trainingDetail_title;

  /// No description provided for @trainingDetail_notFound.
  ///
  /// In zh, this message translates to:
  /// **'计划不存在'**
  String get trainingDetail_notFound;

  /// No description provided for @trainingDetail_weeksPlan.
  ///
  /// In zh, this message translates to:
  /// **'{count} 周计划'**
  String trainingDetail_weeksPlan(int count);

  /// No description provided for @trainingDetail_startTraining.
  ///
  /// In zh, this message translates to:
  /// **'开始训练'**
  String get trainingDetail_startTraining;

  /// No description provided for @trainingDetail_week.
  ///
  /// In zh, this message translates to:
  /// **'第 {week} 周'**
  String trainingDetail_week(int week);

  /// No description provided for @trainingDetail_restWeek.
  ///
  /// In zh, this message translates to:
  /// **'休息周'**
  String get trainingDetail_restWeek;

  /// No description provided for @trainingDetail_dayName.
  ///
  /// In zh, this message translates to:
  /// **'{day, select, 1{周一} 2{周二} 3{周三} 4{周四} 5{周五} 6{周六} 7{周日} other{?}}'**
  String trainingDetail_dayName(String day);

  /// No description provided for @trainingDetail_typeEasyRun.
  ///
  /// In zh, this message translates to:
  /// **'轻松跑'**
  String get trainingDetail_typeEasyRun;

  /// No description provided for @trainingDetail_typeTempo.
  ///
  /// In zh, this message translates to:
  /// **'节奏跑'**
  String get trainingDetail_typeTempo;

  /// No description provided for @trainingDetail_typeInterval.
  ///
  /// In zh, this message translates to:
  /// **'间歇跑'**
  String get trainingDetail_typeInterval;

  /// No description provided for @trainingDetail_typeRest.
  ///
  /// In zh, this message translates to:
  /// **'休息'**
  String get trainingDetail_typeRest;

  /// No description provided for @trainingDetail_target.
  ///
  /// In zh, this message translates to:
  /// **'目标'**
  String get trainingDetail_target;

  /// No description provided for @trainingDetail_intervalTraining.
  ///
  /// In zh, this message translates to:
  /// **'间歇训练'**
  String get trainingDetail_intervalTraining;

  /// No description provided for @chat_title.
  ///
  /// In zh, this message translates to:
  /// **'AI 助手'**
  String get chat_title;

  /// No description provided for @chat_historyTitle.
  ///
  /// In zh, this message translates to:
  /// **'会话历史'**
  String get chat_historyTitle;

  /// No description provided for @chat_newConversation.
  ///
  /// In zh, this message translates to:
  /// **'新建对话'**
  String get chat_newConversation;

  /// No description provided for @chat_notConfigured.
  ///
  /// In zh, this message translates to:
  /// **'请先在设置 → AI 服务配置中设置 AI 服务'**
  String get chat_notConfigured;

  /// No description provided for @chat_emptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'问我任何问题'**
  String get chat_emptyTitle;

  /// No description provided for @chat_emptySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'跑步数据分析、训练建议、或其他话题'**
  String get chat_emptySubtitle;

  /// No description provided for @chat_suggestion1.
  ///
  /// In zh, this message translates to:
  /// **'分析我本周跑步表现'**
  String get chat_suggestion1;

  /// No description provided for @chat_suggestion2.
  ///
  /// In zh, this message translates to:
  /// **'给我一个训练建议'**
  String get chat_suggestion2;

  /// No description provided for @chat_suggestion3.
  ///
  /// In zh, this message translates to:
  /// **'解读我的配速变化'**
  String get chat_suggestion3;

  /// No description provided for @chat_suggestion4.
  ///
  /// In zh, this message translates to:
  /// **'如何提高耐力？'**
  String get chat_suggestion4;

  /// No description provided for @chat_generating.
  ///
  /// In zh, this message translates to:
  /// **'生成中...'**
  String get chat_generating;

  /// No description provided for @chat_inputHint.
  ///
  /// In zh, this message translates to:
  /// **'输入消息...'**
  String get chat_inputHint;

  /// No description provided for @chat_historyCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个 · {size}'**
  String chat_historyCount(int count, String size);

  /// No description provided for @chat_clearAllTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空所有会话？'**
  String get chat_clearAllTitle;

  /// No description provided for @chat_clearAllContent.
  ///
  /// In zh, this message translates to:
  /// **'将删除全部 {count} 个会话，此操作不可撤销。'**
  String chat_clearAllContent(int count);

  /// No description provided for @chat_clearAll.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get chat_clearAll;

  /// No description provided for @chat_noMessages.
  ///
  /// In zh, this message translates to:
  /// **'暂无会话记录'**
  String get chat_noMessages;

  /// No description provided for @chat_deleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除会话？'**
  String get chat_deleteTitle;

  /// No description provided for @chat_deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'此操作不可撤销'**
  String get chat_deleteConfirm;

  /// No description provided for @chat_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get chat_delete;

  /// No description provided for @chat_current.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get chat_current;

  /// No description provided for @chat_justNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get chat_justNow;

  /// No description provided for @chat_minutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{minutes} 分钟前'**
  String chat_minutesAgo(int minutes);

  /// No description provided for @chat_hoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{hours} 小时前'**
  String chat_hoursAgo(int hours);

  /// No description provided for @chat_daysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天前'**
  String chat_daysAgo(int days);

  /// No description provided for @aiSettings_title.
  ///
  /// In zh, this message translates to:
  /// **'AI 服务配置'**
  String get aiSettings_title;

  /// No description provided for @aiSettings_saved.
  ///
  /// In zh, this message translates to:
  /// **'AI 配置已保存'**
  String get aiSettings_saved;

  /// No description provided for @aiSettings_cleared.
  ///
  /// In zh, this message translates to:
  /// **'AI 配置已清除'**
  String get aiSettings_cleared;

  /// No description provided for @aiSettings_clearConfig.
  ///
  /// In zh, this message translates to:
  /// **'清除配置'**
  String get aiSettings_clearConfig;

  /// No description provided for @aiSettings_provider.
  ///
  /// In zh, this message translates to:
  /// **'选择 AI 服务'**
  String get aiSettings_provider;

  /// No description provided for @aiSettings_baseUrl.
  ///
  /// In zh, this message translates to:
  /// **'服务地址'**
  String get aiSettings_baseUrl;

  /// No description provided for @aiSettings_model.
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get aiSettings_model;

  /// No description provided for @aiSettings_modelHint.
  ///
  /// In zh, this message translates to:
  /// **'留空使用默认模型'**
  String get aiSettings_modelHint;

  /// No description provided for @aiSettings_save.
  ///
  /// In zh, this message translates to:
  /// **'保存配置'**
  String get aiSettings_save;

  /// No description provided for @aiSettings_apiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'输入 API Key'**
  String get aiSettings_apiKeyHint;

  /// No description provided for @aiSettings_testing.
  ///
  /// In zh, this message translates to:
  /// **'测试中...'**
  String get aiSettings_testing;

  /// No description provided for @aiSettings_testConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get aiSettings_testConnection;

  /// No description provided for @aiSettings_testSuccess.
  ///
  /// In zh, this message translates to:
  /// **'连接成功'**
  String get aiSettings_testSuccess;

  /// No description provided for @aiSettings_testFail.
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get aiSettings_testFail;

  /// No description provided for @aiSettings_helpTitle.
  ///
  /// In zh, this message translates to:
  /// **'说明'**
  String get aiSettings_helpTitle;

  /// No description provided for @aiSettings_help1.
  ///
  /// In zh, this message translates to:
  /// **'API Key 使用设备加密存储，不会上传至任何服务器'**
  String get aiSettings_help1;

  /// No description provided for @aiSettings_help2.
  ///
  /// In zh, this message translates to:
  /// **'跑步数据仅在你主动使用 AI 功能时才会发送至所选服务'**
  String get aiSettings_help2;

  /// No description provided for @aiSettings_help3.
  ///
  /// In zh, this message translates to:
  /// **'OpenClaw 为本地自托管方案，数据不离开你的设备'**
  String get aiSettings_help3;

  /// No description provided for @aiSettings_help4.
  ///
  /// In zh, this message translates to:
  /// **'选择「自定义」可接入任何兼容 OpenAI 协议的服务'**
  String get aiSettings_help4;

  /// No description provided for @summary_notConfigured.
  ///
  /// In zh, this message translates to:
  /// **'请先在设置中配置 AI 服务'**
  String get summary_notConfigured;

  /// No description provided for @summary_generating.
  ///
  /// In zh, this message translates to:
  /// **'正在生成分析...'**
  String get summary_generating;

  /// No description provided for @summary_runAnalysis.
  ///
  /// In zh, this message translates to:
  /// **'AI 跑步分析'**
  String get summary_runAnalysis;

  /// No description provided for @summary_weeklyTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 周总结'**
  String get summary_weeklyTitle;

  /// No description provided for @summary_monthlyTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 月总结'**
  String get summary_monthlyTitle;

  /// No description provided for @summary_yearlyTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 年总结'**
  String get summary_yearlyTitle;

  /// No description provided for @summary_title.
  ///
  /// In zh, this message translates to:
  /// **'AI 分析'**
  String get summary_title;

  /// No description provided for @settings_title.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings_title;

  /// No description provided for @settings_personalInfo.
  ///
  /// In zh, this message translates to:
  /// **'个人信息'**
  String get settings_personalInfo;

  /// No description provided for @settings_runSettings.
  ///
  /// In zh, this message translates to:
  /// **'跑步设置'**
  String get settings_runSettings;

  /// No description provided for @settings_autoPause.
  ///
  /// In zh, this message translates to:
  /// **'自动暂停'**
  String get settings_autoPause;

  /// No description provided for @settings_autoPauseDesc.
  ///
  /// In zh, this message translates to:
  /// **'速度 < 1.0 km/h 持续 5 秒自动暂停'**
  String get settings_autoPauseDesc;

  /// No description provided for @settings_ttsSection.
  ///
  /// In zh, this message translates to:
  /// **'语音播报'**
  String get settings_ttsSection;

  /// No description provided for @settings_tts.
  ///
  /// In zh, this message translates to:
  /// **'语音播报'**
  String get settings_tts;

  /// No description provided for @settings_ttsDesc.
  ///
  /// In zh, this message translates to:
  /// **'跑步中播报距离和配速'**
  String get settings_ttsDesc;

  /// No description provided for @settings_ttsInterval.
  ///
  /// In zh, this message translates to:
  /// **'播报间隔'**
  String get settings_ttsInterval;

  /// No description provided for @settings_ttsEveryKm.
  ///
  /// In zh, this message translates to:
  /// **'每 {km} km'**
  String settings_ttsEveryKm(int km);

  /// No description provided for @settings_aiSection.
  ///
  /// In zh, this message translates to:
  /// **'AI 助手'**
  String get settings_aiSection;

  /// No description provided for @settings_aiConfig.
  ///
  /// In zh, this message translates to:
  /// **'AI 服务配置'**
  String get settings_aiConfig;

  /// No description provided for @settings_aiConfigured.
  ///
  /// In zh, this message translates to:
  /// **'已配置'**
  String get settings_aiConfigured;

  /// No description provided for @settings_aiNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'未配置，点击设置'**
  String get settings_aiNotConfigured;

  /// No description provided for @settings_aiCoach.
  ///
  /// In zh, this message translates to:
  /// **'跑步中 AI 教练'**
  String get settings_aiCoach;

  /// No description provided for @settings_aiCoachDesc.
  ///
  /// In zh, this message translates to:
  /// **'跑步时 AI 实时提供配速建议和鼓励'**
  String get settings_aiCoachDesc;

  /// No description provided for @settings_chatHistory.
  ///
  /// In zh, this message translates to:
  /// **'聊天记录'**
  String get settings_chatHistory;

  /// No description provided for @settings_chatStorage.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条消息，{size}'**
  String settings_chatStorage(int count, String size);

  /// No description provided for @settings_loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get settings_loading;

  /// No description provided for @settings_appearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get settings_appearance;

  /// No description provided for @settings_themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get settings_themeDark;

  /// No description provided for @settings_themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get settings_themeLight;

  /// No description provided for @settings_themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get settings_themeSystem;

  /// No description provided for @settings_language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settings_language;

  /// No description provided for @settings_langZh.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get settings_langZh;

  /// No description provided for @settings_langEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get settings_langEn;

  /// No description provided for @settings_langSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get settings_langSystem;

  /// No description provided for @settings_mapSection.
  ///
  /// In zh, this message translates to:
  /// **'地图设置'**
  String get settings_mapSection;

  /// No description provided for @settings_mapSource.
  ///
  /// In zh, this message translates to:
  /// **'瓦片源'**
  String get settings_mapSource;

  /// No description provided for @settings_mapCache.
  ///
  /// In zh, this message translates to:
  /// **'地图缓存'**
  String get settings_mapCache;

  /// No description provided for @settings_amapApiKey.
  ///
  /// In zh, this message translates to:
  /// **'高德 API Key'**
  String get settings_amapApiKey;

  /// No description provided for @settings_amapApiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'用于城市识别（可选）'**
  String get settings_amapApiKeyHint;

  /// No description provided for @settings_amapApiKeyDesc.
  ///
  /// In zh, this message translates to:
  /// **'在 lbs.amap.com 免费申请 Web 服务 Key，用于跑步结束时识别城市名称。不填则使用 OpenStreetMap（部分网络可能不可用）。'**
  String get settings_amapApiKeyDesc;

  /// No description provided for @settings_amapApiKeyPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'输入高德 Web 服务 API Key'**
  String get settings_amapApiKeyPlaceholder;

  /// No description provided for @settings_customTileUrl.
  ///
  /// In zh, this message translates to:
  /// **'自定义瓦片 URL'**
  String get settings_customTileUrl;

  /// No description provided for @settings_customTileUrlHint.
  ///
  /// In zh, this message translates to:
  /// **'例如: https://tile.example.com/z/x/y.png'**
  String get settings_customTileUrlHint;

  /// No description provided for @settings_dataManagement.
  ///
  /// In zh, this message translates to:
  /// **'数据管理'**
  String get settings_dataManagement;

  /// No description provided for @settings_importGarmin.
  ///
  /// In zh, this message translates to:
  /// **'导入 Garmin 记录'**
  String get settings_importGarmin;

  /// No description provided for @settings_importGarminDesc.
  ///
  /// In zh, this message translates to:
  /// **'从 Garmin Connect 导出的 JSON 导入'**
  String get settings_importGarminDesc;

  /// No description provided for @settings_importGpx.
  ///
  /// In zh, this message translates to:
  /// **'导入 GPX'**
  String get settings_importGpx;

  /// No description provided for @settings_importGpxDesc.
  ///
  /// In zh, this message translates to:
  /// **'从其他跑步 App 导入记录'**
  String get settings_importGpxDesc;

  /// No description provided for @settings_exportAll.
  ///
  /// In zh, this message translates to:
  /// **'导出全部记录'**
  String get settings_exportAll;

  /// No description provided for @settings_exportAllDesc.
  ///
  /// In zh, this message translates to:
  /// **'打包为 GPX + CSV'**
  String get settings_exportAllDesc;

  /// No description provided for @settings_clearAll.
  ///
  /// In zh, this message translates to:
  /// **'清空全部记录'**
  String get settings_clearAll;

  /// No description provided for @settings_irreversible.
  ///
  /// In zh, this message translates to:
  /// **'此操作不可撤销'**
  String get settings_irreversible;

  /// No description provided for @settings_nickname.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get settings_nickname;

  /// No description provided for @settings_notSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get settings_notSet;

  /// No description provided for @settings_setNickname.
  ///
  /// In zh, this message translates to:
  /// **'设置名称'**
  String get settings_setNickname;

  /// No description provided for @settings_nicknameHint.
  ///
  /// In zh, this message translates to:
  /// **'输入你的名称'**
  String get settings_nicknameHint;

  /// No description provided for @settings_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get settings_cancel;

  /// No description provided for @settings_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get settings_confirm;

  /// No description provided for @settings_weight.
  ///
  /// In zh, this message translates to:
  /// **'体重'**
  String get settings_weight;

  /// No description provided for @settings_unit.
  ///
  /// In zh, this message translates to:
  /// **'距离单位'**
  String get settings_unit;

  /// No description provided for @settings_inputWeight.
  ///
  /// In zh, this message translates to:
  /// **'输入体重'**
  String get settings_inputWeight;

  /// No description provided for @settings_clearMapCacheTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空地图缓存？'**
  String get settings_clearMapCacheTitle;

  /// No description provided for @settings_clearMapCacheContent.
  ///
  /// In zh, this message translates to:
  /// **'将删除 {sizeMb} MB 的缓存瓦片。'**
  String settings_clearMapCacheContent(int sizeMb);

  /// No description provided for @settings_clear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get settings_clear;

  /// No description provided for @settings_mapCacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'地图缓存已清空'**
  String get settings_mapCacheCleared;

  /// No description provided for @settings_parsingGarmin.
  ///
  /// In zh, this message translates to:
  /// **'正在解析 Garmin 数据...'**
  String get settings_parsingGarmin;

  /// No description provided for @settings_importingRuns.
  ///
  /// In zh, this message translates to:
  /// **'正在导入跑步记录...'**
  String get settings_importingRuns;

  /// No description provided for @settings_importSuccess.
  ///
  /// In zh, this message translates to:
  /// **'成功导入 {count} 条记录'**
  String settings_importSuccess(int count);

  /// No description provided for @settings_importSkipped.
  ///
  /// In zh, this message translates to:
  /// **'跳过 {count} 条（已存在）'**
  String settings_importSkipped(int count);

  /// No description provided for @settings_importSkippedGpx.
  ///
  /// In zh, this message translates to:
  /// **'跳过 {count} 条（已存在或无轨迹）'**
  String settings_importSkippedGpx(int count);

  /// No description provided for @settings_importFailed.
  ///
  /// In zh, this message translates to:
  /// **'失败 {count} 条：'**
  String settings_importFailed(int count);

  /// No description provided for @settings_importMoreErrors.
  ///
  /// In zh, this message translates to:
  /// **'... 及其他 {count} 条'**
  String settings_importMoreErrors(int count);

  /// No description provided for @settings_garminImportDone.
  ///
  /// In zh, this message translates to:
  /// **'Garmin 导入完成'**
  String get settings_garminImportDone;

  /// No description provided for @settings_importError.
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get settings_importError;

  /// No description provided for @settings_preparingImport.
  ///
  /// In zh, this message translates to:
  /// **'准备导入...'**
  String get settings_preparingImport;

  /// No description provided for @settings_importingProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在导入 ({current}/{total})'**
  String settings_importingProgress(int current, int total);

  /// No description provided for @settings_importDone.
  ///
  /// In zh, this message translates to:
  /// **'导入完成'**
  String get settings_importDone;

  /// No description provided for @settings_extracting.
  ///
  /// In zh, this message translates to:
  /// **'正在解压 {filename}...'**
  String settings_extracting(String filename);

  /// No description provided for @settings_noDataToExport.
  ///
  /// In zh, this message translates to:
  /// **'没有跑步记录可导出'**
  String get settings_noDataToExport;

  /// No description provided for @settings_preparingExport.
  ///
  /// In zh, this message translates to:
  /// **'准备导出...'**
  String get settings_preparingExport;

  /// No description provided for @settings_exportingProgress.
  ///
  /// In zh, this message translates to:
  /// **'导出中 ({current}/{total})'**
  String settings_exportingProgress(int current, int total);

  /// No description provided for @settings_packingZip.
  ///
  /// In zh, this message translates to:
  /// **'正在打包为 zip...'**
  String get settings_packingZip;

  /// No description provided for @settings_exportShareText.
  ///
  /// In zh, this message translates to:
  /// **'Solrun 跑步记录导出（{count} 条）'**
  String settings_exportShareText(int count);

  /// No description provided for @settings_noChatHistory.
  ///
  /// In zh, this message translates to:
  /// **'没有聊天记录'**
  String get settings_noChatHistory;

  /// No description provided for @settings_clearChatTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空聊天记录？'**
  String get settings_clearChatTitle;

  /// No description provided for @settings_clearChatContent.
  ///
  /// In zh, this message translates to:
  /// **'将删除所有 AI 对话记录（{count} 条消息，{size}）。\n此操作不可撤销。'**
  String settings_clearChatContent(int count, String size);

  /// No description provided for @settings_chatHistoryCleared.
  ///
  /// In zh, this message translates to:
  /// **'聊天记录已清空'**
  String get settings_chatHistoryCleared;

  /// No description provided for @settings_clearAllTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空全部记录？'**
  String get settings_clearAllTitle;

  /// No description provided for @settings_clearAllContent.
  ///
  /// In zh, this message translates to:
  /// **'此操作不可撤销，所有跑步记录将被永久删除。'**
  String get settings_clearAllContent;

  /// No description provided for @settings_allDataCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清空全部记录'**
  String get settings_allDataCleared;

  /// No description provided for @result_notFound.
  ///
  /// In zh, this message translates to:
  /// **'记录不存在'**
  String get result_notFound;

  /// No description provided for @result_title.
  ///
  /// In zh, this message translates to:
  /// **'✦ 完成跑步'**
  String get result_title;

  /// No description provided for @result_avgPace.
  ///
  /// In zh, this message translates to:
  /// **'平均配速'**
  String get result_avgPace;

  /// No description provided for @result_calories.
  ///
  /// In zh, this message translates to:
  /// **'卡路里'**
  String get result_calories;

  /// No description provided for @result_bestPace.
  ///
  /// In zh, this message translates to:
  /// **'最快配速'**
  String get result_bestPace;

  /// No description provided for @result_elevation.
  ///
  /// In zh, this message translates to:
  /// **'爬升'**
  String get result_elevation;

  /// No description provided for @result_tapToExpand.
  ///
  /// In zh, this message translates to:
  /// **'点击展开'**
  String get result_tapToExpand;

  /// No description provided for @result_aiAnalysis.
  ///
  /// In zh, this message translates to:
  /// **'AI 分析本次跑步'**
  String get result_aiAnalysis;

  /// No description provided for @result_save.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get result_save;

  /// No description provided for @result_share.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get result_share;

  /// No description provided for @main_crashRecoveryTitle.
  ///
  /// In zh, this message translates to:
  /// **'发现未完成的跑步'**
  String get main_crashRecoveryTitle;

  /// No description provided for @main_crashRecoveryContent.
  ///
  /// In zh, this message translates to:
  /// **'发现一条未完成的跑步记录（{distance} km / {duration}），是否恢复？'**
  String main_crashRecoveryContent(String distance, String duration);

  /// No description provided for @main_discard.
  ///
  /// In zh, this message translates to:
  /// **'放弃'**
  String get main_discard;

  /// No description provided for @main_recover.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get main_recover;

  /// No description provided for @nav_audience.
  ///
  /// In zh, this message translates to:
  /// **'观众'**
  String get nav_audience;

  /// No description provided for @audience_role_screamingFan.
  ///
  /// In zh, this message translates to:
  /// **'尖叫粉'**
  String get audience_role_screamingFan;

  /// No description provided for @audience_role_dataNerd.
  ///
  /// In zh, this message translates to:
  /// **'数据狂人'**
  String get audience_role_dataNerd;

  /// No description provided for @audience_role_familyCrew.
  ///
  /// In zh, this message translates to:
  /// **'亲友后援会'**
  String get audience_role_familyCrew;

  /// No description provided for @audience_role_zenViewer.
  ///
  /// In zh, this message translates to:
  /// **'佛系观赛组'**
  String get audience_role_zenViewer;

  /// No description provided for @audience_role_gambler.
  ///
  /// In zh, this message translates to:
  /// **'赌徒'**
  String get audience_role_gambler;

  /// No description provided for @audience_role_nitpicker.
  ///
  /// In zh, this message translates to:
  /// **'显微镜侠'**
  String get audience_role_nitpicker;

  /// No description provided for @audience_role_rivalFan.
  ///
  /// In zh, this message translates to:
  /// **'影子对手团'**
  String get audience_role_rivalFan;

  /// No description provided for @audience_personality_savage.
  ///
  /// In zh, this message translates to:
  /// **'毒舌损友'**
  String get audience_personality_savage;

  /// No description provided for @audience_personality_hypeCoach.
  ///
  /// In zh, this message translates to:
  /// **'热血教练'**
  String get audience_personality_hypeCoach;

  /// No description provided for @audience_personality_poet.
  ///
  /// In zh, this message translates to:
  /// **'诗意文青'**
  String get audience_personality_poet;

  /// No description provided for @audience_personality_clown.
  ///
  /// In zh, this message translates to:
  /// **'逗逼老炮'**
  String get audience_personality_clown;

  /// No description provided for @audience_personality_commentator.
  ///
  /// In zh, this message translates to:
  /// **'冷面解说'**
  String get audience_personality_commentator;

  /// No description provided for @audience_moodTitle.
  ///
  /// In zh, this message translates to:
  /// **'今天想让观众怎么喊？'**
  String get audience_moodTitle;

  /// No description provided for @audience_moodConfirm.
  ///
  /// In zh, this message translates to:
  /// **'开始跑步'**
  String get audience_moodConfirm;

  /// No description provided for @audience_mood_motivate.
  ///
  /// In zh, this message translates to:
  /// **'激励我'**
  String get audience_mood_motivate;

  /// No description provided for @audience_mood_comfort.
  ///
  /// In zh, this message translates to:
  /// **'安慰我'**
  String get audience_mood_comfort;

  /// No description provided for @audience_mood_provoke.
  ///
  /// In zh, this message translates to:
  /// **'刺激我'**
  String get audience_mood_provoke;

  /// No description provided for @audience_mood_amuse.
  ///
  /// In zh, this message translates to:
  /// **'逗我笑'**
  String get audience_mood_amuse;

  /// No description provided for @audience_mood_focus.
  ///
  /// In zh, this message translates to:
  /// **'专注跑'**
  String get audience_mood_focus;

  /// No description provided for @audience_quoteWallTitle.
  ///
  /// In zh, this message translates to:
  /// **'金句墙'**
  String get audience_quoteWallTitle;

  /// No description provided for @audience_quoteWallEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有金句，跑起来就有了'**
  String get audience_quoteWallEmpty;

  /// No description provided for @audience_fanTeamTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的粉丝团'**
  String get audience_fanTeamTitle;

  /// No description provided for @audience_fanTeamEmpty.
  ///
  /// In zh, this message translates to:
  /// **'锁定你最喜欢的声音'**
  String get audience_fanTeamEmpty;

  /// No description provided for @audience_fanTeamLimit.
  ///
  /// In zh, this message translates to:
  /// **'粉丝团已满，请先移除一个'**
  String get audience_fanTeamLimit;

  /// No description provided for @audience_roleGalleryTitle.
  ///
  /// In zh, this message translates to:
  /// **'角色图鉴'**
  String get audience_roleGalleryTitle;

  /// No description provided for @audience_unlockAt.
  ///
  /// In zh, this message translates to:
  /// **'累计跑步 {count} 次解锁'**
  String audience_unlockAt(int count);

  /// No description provided for @audience_runsToUnlock.
  ///
  /// In zh, this message translates to:
  /// **'再跑 {count} 次解锁'**
  String audience_runsToUnlock(int count);

  /// No description provided for @audience_joinFanTeam.
  ///
  /// In zh, this message translates to:
  /// **'加入粉丝团'**
  String get audience_joinFanTeam;

  /// No description provided for @audience_removeFromFanTeam.
  ///
  /// In zh, this message translates to:
  /// **'移出粉丝团'**
  String get audience_removeFromFanTeam;

  /// No description provided for @audience_shoutsTitle.
  ///
  /// In zh, this message translates to:
  /// **'本场观众说了什么'**
  String get audience_shoutsTitle;

  /// No description provided for @audience_noShouts.
  ///
  /// In zh, this message translates to:
  /// **'本场无观众喊话'**
  String get audience_noShouts;

  /// No description provided for @audience_interviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'赛后采访'**
  String get audience_interviewTitle;

  /// No description provided for @audience_selectRoleForInterview.
  ///
  /// In zh, this message translates to:
  /// **'选择采访对象'**
  String get audience_selectRoleForInterview;

  /// No description provided for @audience_newRunner.
  ///
  /// In zh, this message translates to:
  /// **'新跑者'**
  String get audience_newRunner;

  /// No description provided for @audience_roleDesc_screamingFan.
  ///
  /// In zh, this message translates to:
  /// **'情绪化狂热支持者，无条件应援'**
  String get audience_roleDesc_screamingFan;

  /// No description provided for @audience_roleDesc_dataNerd.
  ///
  /// In zh, this message translates to:
  /// **'理性至极端，所有判断基于数据模型'**
  String get audience_roleDesc_dataNerd;

  /// No description provided for @audience_roleDesc_familyCrew.
  ///
  /// In zh, this message translates to:
  /// **'家人朋友，情感优先'**
  String get audience_roleDesc_familyCrew;

  /// No description provided for @audience_roleDesc_zenViewer.
  ///
  /// In zh, this message translates to:
  /// **'温和包容，关注跑步本身'**
  String get audience_roleDesc_zenViewer;

  /// No description provided for @audience_roleDesc_gambler.
  ///
  /// In zh, this message translates to:
  /// **'押注跑者成绩，数据波动引发激烈情绪'**
  String get audience_roleDesc_gambler;

  /// No description provided for @audience_roleDesc_nitpicker.
  ///
  /// In zh, this message translates to:
  /// **'专挖黑历史，放大最差数据'**
  String get audience_roleDesc_nitpicker;

  /// No description provided for @audience_roleDesc_rivalFan.
  ///
  /// In zh, this message translates to:
  /// **'其他跑者的支持者，借数据贬低跑者'**
  String get audience_roleDesc_rivalFan;

  /// No description provided for @audience_shoutCount.
  ///
  /// In zh, this message translates to:
  /// **'出场 {count} 次'**
  String audience_shoutCount(int count);

  /// No description provided for @audience_firstAppearance.
  ///
  /// In zh, this message translates to:
  /// **'首次出场'**
  String get audience_firstAppearance;

  /// No description provided for @audience_noShoutsYet.
  ///
  /// In zh, this message translates to:
  /// **'暂无喊话记录'**
  String get audience_noShoutsYet;

  /// No description provided for @audience_selectPersonality.
  ///
  /// In zh, this message translates to:
  /// **'选择人格风格'**
  String get audience_selectPersonality;

  /// No description provided for @audience_selectRole.
  ///
  /// In zh, this message translates to:
  /// **'选择角色'**
  String get audience_selectRole;

  /// No description provided for @audience_confirmAdd.
  ///
  /// In zh, this message translates to:
  /// **'确认加入'**
  String get audience_confirmAdd;

  /// No description provided for @audience_replace.
  ///
  /// In zh, this message translates to:
  /// **'替换'**
  String get audience_replace;

  /// No description provided for @audience_remove.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get audience_remove;

  /// No description provided for @audience_fanTeamReplaceHint.
  ///
  /// In zh, this message translates to:
  /// **'粉丝团已满，选择要替换的成员'**
  String get audience_fanTeamReplaceHint;

  /// No description provided for @audience_favoriteRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已取消收藏'**
  String get audience_favoriteRemoved;

  /// No description provided for @audience_fanAdded.
  ///
  /// In zh, this message translates to:
  /// **'已加入粉丝团'**
  String get audience_fanAdded;

  /// No description provided for @audience_fanReplaced.
  ///
  /// In zh, this message translates to:
  /// **'已替换粉丝团成员'**
  String get audience_fanReplaced;

  /// No description provided for @audience_fanRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已移出粉丝团'**
  String get audience_fanRemoved;

  /// No description provided for @audience_quoteCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get audience_quoteCopied;

  /// No description provided for @audience_favoriteAdded.
  ///
  /// In zh, this message translates to:
  /// **'已收藏到金句墙'**
  String get audience_favoriteAdded;

  /// No description provided for @audience_sceneStart.
  ///
  /// In zh, this message translates to:
  /// **'开跑'**
  String get audience_sceneStart;

  /// No description provided for @audience_sceneSplitKm.
  ///
  /// In zh, this message translates to:
  /// **'第 {km} 公里'**
  String audience_sceneSplitKm(Object km);

  /// No description provided for @audience_sceneFinish.
  ///
  /// In zh, this message translates to:
  /// **'冲线'**
  String get audience_sceneFinish;

  /// No description provided for @audience_scenePaceAlert.
  ///
  /// In zh, this message translates to:
  /// **'配速提醒'**
  String get audience_scenePaceAlert;

  /// No description provided for @audience_interviewHint.
  ///
  /// In zh, this message translates to:
  /// **'向观众提问...'**
  String get audience_interviewHint;

  /// No description provided for @audience_interviewOpening.
  ///
  /// In zh, this message translates to:
  /// **'{role} 想跟你聊聊这场比赛'**
  String audience_interviewOpening(String role);

  /// No description provided for @audience_interviewStreaming.
  ///
  /// In zh, this message translates to:
  /// **'正在回复...'**
  String get audience_interviewStreaming;

  /// No description provided for @audience_interviewRoleDesc.
  ///
  /// In zh, this message translates to:
  /// **'选择一个观众角色来采访你'**
  String get audience_interviewRoleDesc;

  /// No description provided for @share_pace.
  ///
  /// In zh, this message translates to:
  /// **'配速'**
  String get share_pace;

  /// No description provided for @share_duration.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get share_duration;

  /// No description provided for @share_calories.
  ///
  /// In zh, this message translates to:
  /// **'卡路里'**
  String get share_calories;

  /// No description provided for @share_elevationGain.
  ///
  /// In zh, this message translates to:
  /// **'累计爬升'**
  String get share_elevationGain;

  /// No description provided for @share_distance.
  ///
  /// In zh, this message translates to:
  /// **'距离'**
  String get share_distance;

  /// No description provided for @share_kilometer.
  ///
  /// In zh, this message translates to:
  /// **'公里'**
  String get share_kilometer;

  /// No description provided for @share_noRouteData.
  ///
  /// In zh, this message translates to:
  /// **'无轨迹数据'**
  String get share_noRouteData;

  /// No description provided for @share_overflowWarning.
  ///
  /// In zh, this message translates to:
  /// **'该比例图框较小，请减少数据展示项'**
  String get share_overflowWarning;

  /// No description provided for @share_customize.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get share_customize;

  /// No description provided for @share_saveToGallery.
  ///
  /// In zh, this message translates to:
  /// **'保存到相册'**
  String get share_saveToGallery;

  /// No description provided for @share_share.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get share_share;

  /// No description provided for @share_savedToGallery.
  ///
  /// In zh, this message translates to:
  /// **'已保存到相册'**
  String get share_savedToGallery;

  /// No description provided for @share_saveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败: {error}'**
  String share_saveFailed(String error);

  /// No description provided for @share_runRecord.
  ///
  /// In zh, this message translates to:
  /// **'Solrun 跑步记录'**
  String get share_runRecord;

  /// No description provided for @share_title.
  ///
  /// In zh, this message translates to:
  /// **'分享跑步记录'**
  String get share_title;

  /// No description provided for @share_loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String share_loadFailed(String error);

  /// No description provided for @share_templateClassic.
  ///
  /// In zh, this message translates to:
  /// **'经典'**
  String get share_templateClassic;

  /// No description provided for @share_templateHeatmap.
  ///
  /// In zh, this message translates to:
  /// **'热力'**
  String get share_templateHeatmap;

  /// No description provided for @share_templateMap.
  ///
  /// In zh, this message translates to:
  /// **'地图'**
  String get share_templateMap;

  /// No description provided for @share_templateMinimal.
  ///
  /// In zh, this message translates to:
  /// **'极简'**
  String get share_templateMinimal;

  /// No description provided for @share_toggleHeatmap.
  ///
  /// In zh, this message translates to:
  /// **'热力轨迹'**
  String get share_toggleHeatmap;

  /// No description provided for @share_toggleMapTiles.
  ///
  /// In zh, this message translates to:
  /// **'地图底图'**
  String get share_toggleMapTiles;

  /// No description provided for @share_togglePaceChart.
  ///
  /// In zh, this message translates to:
  /// **'配速图表'**
  String get share_togglePaceChart;

  /// No description provided for @share_toggleElevation.
  ///
  /// In zh, this message translates to:
  /// **'海拔剖面'**
  String get share_toggleElevation;

  /// No description provided for @share_toggleDataGrid.
  ///
  /// In zh, this message translates to:
  /// **'数据网格'**
  String get share_toggleDataGrid;

  /// No description provided for @share_toggleHeader.
  ///
  /// In zh, this message translates to:
  /// **'头部信息'**
  String get share_toggleHeader;

  /// No description provided for @share_optionNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'{label} 无法在{template}风格中展示'**
  String share_optionNotSupported(String label, String template);

  /// No description provided for @share_unsupportedTemplate.
  ///
  /// In zh, this message translates to:
  /// **'不支持{template}风格'**
  String share_unsupportedTemplate(String template);

  /// No description provided for @share_audienceQuote.
  ///
  /// In zh, this message translates to:
  /// **'观众语录'**
  String get share_audienceQuote;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'zh':
      return SZh();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
