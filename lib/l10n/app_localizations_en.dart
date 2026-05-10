// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get nav_home => 'Home';

  @override
  String get nav_history => 'History';

  @override
  String get nav_stats => 'Stats';

  @override
  String get nav_ai => 'AI';

  @override
  String get nav_settings => 'Settings';

  @override
  String get home_greetingNight => 'LATE NIGHT';

  @override
  String get home_greetingMorning => 'GOOD MORNING';

  @override
  String get home_greetingAfternoon => 'GOOD AFTERNOON';

  @override
  String get home_greetingEvening => 'GOOD EVENING';

  @override
  String home_weekdays(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      '1': 'Mon',
      '2': 'Tue',
      '3': 'Wed',
      '4': 'Thu',
      '5': 'Fri',
      '6': 'Sat',
      '7': 'Sun',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String home_dateFormat(int month, int day, String weekday) {
    return '$weekday, $month/$day';
  }

  @override
  String home_greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get home_trainingPlan => 'Training Plan';

  @override
  String get home_trainingPlanSubtitle => 'Choose or customize a running plan';

  @override
  String get home_thisWeek => 'THIS WEEK';

  @override
  String get home_unitKm => 'KM';

  @override
  String get home_unitTimes => 'RUNS';

  @override
  String get home_avgPace => 'AVG PACE';

  @override
  String get home_startRun => 'START RUN';

  @override
  String get stats_title => 'STATISTICS';

  @override
  String get stats_emptyTitle => 'No running records yet';

  @override
  String get stats_emptyAction => 'Start Running';

  @override
  String get stats_thisWeek => 'THIS WEEK';

  @override
  String get stats_thisMonth => 'THIS MONTH';

  @override
  String get stats_unitKm => 'KM';

  @override
  String stats_timesAndPace(int count, String pace) {
    return '$count runs · Avg $pace';
  }

  @override
  String get stats_aiSummaryLabel => 'AI SUMMARY';

  @override
  String get stats_aiWeeklySummary => 'Weekly';

  @override
  String get stats_aiMonthlySummary => 'Monthly';

  @override
  String get stats_aiYearlySummary => 'Yearly';

  @override
  String get stats_personalRecords => 'PERSONAL RECORDS';

  @override
  String get stats_longestDistance => 'Longest Distance';

  @override
  String get stats_longestDuration => 'Longest Duration';

  @override
  String get stats_fastestPace => 'Fastest Pace';

  @override
  String get stats_fastest5km => '5K Best';

  @override
  String stats_yearSuffix(int year) {
    return '$year';
  }

  @override
  String stats_monthSuffix(int month) {
    return 'Month $month';
  }

  @override
  String get stats_selectYear => 'Select Year';

  @override
  String get stats_selectMonth => 'Select Month';

  @override
  String stats_tooltipDay(int day, String km) {
    return 'Day $day: ${km}km';
  }

  @override
  String stats_yearMonthlyVolume(int year) {
    return '$year Monthly Volume';
  }

  @override
  String get stats_allYearsVolume => 'All Years Volume';

  @override
  String stats_tooltipMonth(int month, String km) {
    return 'Month $month\n$km km';
  }

  @override
  String stats_tooltipYear(int year, String km) {
    return '$year\n$km km';
  }

  @override
  String get tracking_statusGpsWaiting => 'GPS WAITING';

  @override
  String get tracking_statusRunning => 'RUNNING';

  @override
  String get tracking_statusPaused => 'PAUSED';

  @override
  String get tracking_statusAutoPaused => 'AUTO PAUSED';

  @override
  String get tracking_unitKilometers => 'KILOMETERS';

  @override
  String get tracking_labelPace => 'PACE';

  @override
  String get tracking_labelDuration => 'DURATION';

  @override
  String get tracking_labelCadence => 'CADENCE';

  @override
  String get tracking_labelCalories => 'CALORIES';

  @override
  String get tracking_stopTitle => 'End Run';

  @override
  String get tracking_stopContent => 'Are you sure you want to end this run?';

  @override
  String get tracking_stopCancel => 'Keep Going';

  @override
  String get tracking_stopConfirm => 'End';

  @override
  String get history_title => 'Run History';

  @override
  String get history_loadError => 'Load failed';

  @override
  String get history_emptyTitle => 'No running records yet';

  @override
  String get history_emptySubtitle => 'Start your first run!';

  @override
  String get history_startRunning => 'Start Running';

  @override
  String history_monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'January',
      '2': 'February',
      '3': 'March',
      '4': 'April',
      '5': 'May',
      '6': 'June',
      '7': 'July',
      '8': 'August',
      '9': 'September',
      '10': 'October',
      '11': 'November',
      '12': 'December',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get history_unitKm => 'km';

  @override
  String history_monthSummary(int count, String hours) {
    return '$count runs, $hours hrs';
  }

  @override
  String history_durationFormat(int min, String sec) {
    return '${min}m ${sec}s';
  }

  @override
  String get history_incomplete => 'Incomplete';

  @override
  String get history_deleteConfirmTitle => 'Delete record?';

  @override
  String history_deleteConfirmContent(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get history_deleteConfirmButton => 'Delete';

  @override
  String get history_today => 'Today';

  @override
  String get history_yesterday => 'Yesterday';

  @override
  String get historyDetail_title => 'Run Details';

  @override
  String get historyDetail_loadError => 'Load failed';

  @override
  String get historyDetail_notFound => 'Record not found';

  @override
  String get historyDetail_trajectoryLoadError => 'Trajectory load failed';

  @override
  String get historyDetail_noTrajectory => 'No trajectory data';

  @override
  String get historyDetail_splitPace => 'Split Pace';

  @override
  String get historyDetail_distanceTooShort => 'Distance less than 1 km';

  @override
  String get historyDetail_replay => 'Trajectory Replay';

  @override
  String get historyDetail_share => 'Share Run Record';

  @override
  String get historyDetail_delete => 'Delete Record';

  @override
  String get historyDetail_distance => 'Distance';

  @override
  String get historyDetail_duration => 'Duration';

  @override
  String get historyDetail_pace => 'Avg Pace';

  @override
  String get historyDetail_bestPace => 'Best Pace';

  @override
  String get historyDetail_calories => 'Calories';

  @override
  String get historyDetail_elevation => 'Elevation Gain';

  @override
  String get historyDetail_rename => 'Rename';

  @override
  String get historyDetail_cancel => 'Cancel';

  @override
  String get historyDetail_save => 'Save';

  @override
  String get historyDetail_exportFailed => 'export failed';

  @override
  String get training_title => 'Training Plans';

  @override
  String get training_emptyTitle => 'No training plans';

  @override
  String training_weeks(int count) {
    return '$count weeks';
  }

  @override
  String get trainingDetail_title => 'Plan Details';

  @override
  String get trainingDetail_notFound => 'Plan not found';

  @override
  String trainingDetail_weeksPlan(int count) {
    return '$count-week plan';
  }

  @override
  String get trainingDetail_startTraining => 'Start Training';

  @override
  String trainingDetail_week(int week) {
    return 'Week $week';
  }

  @override
  String get trainingDetail_restWeek => 'Rest Week';

  @override
  String trainingDetail_dayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'Mon',
      '2': 'Tue',
      '3': 'Wed',
      '4': 'Thu',
      '5': 'Fri',
      '6': 'Sat',
      '7': 'Sun',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String get trainingDetail_typeEasyRun => 'Easy Run';

  @override
  String get trainingDetail_typeTempo => 'Tempo Run';

  @override
  String get trainingDetail_typeInterval => 'Interval';

  @override
  String get trainingDetail_typeRest => 'Rest';

  @override
  String get trainingDetail_target => 'Target';

  @override
  String get trainingDetail_intervalTraining => 'Interval Training';

  @override
  String get chat_title => 'AI Assistant';

  @override
  String get chat_historyTitle => 'Chat History';

  @override
  String get chat_newConversation => 'New Chat';

  @override
  String get chat_notConfigured =>
      'Please configure AI service in Settings → AI Config';

  @override
  String get chat_emptyTitle => 'Ask me anything';

  @override
  String get chat_emptySubtitle =>
      'Running data analysis, training advice, or any topic';

  @override
  String get chat_suggestion1 => 'Analyze my running this week';

  @override
  String get chat_suggestion2 => 'Give me a training suggestion';

  @override
  String get chat_suggestion3 => 'Interpret my pace changes';

  @override
  String get chat_suggestion4 => 'How to improve endurance?';

  @override
  String get chat_generating => 'Generating...';

  @override
  String get chat_inputHint => 'Type a message...';

  @override
  String chat_historyCount(int count, String size) {
    return '$count chats · $size';
  }

  @override
  String get chat_clearAllTitle => 'Clear all chats?';

  @override
  String chat_clearAllContent(int count) {
    return 'This will delete all $count conversations. This cannot be undone.';
  }

  @override
  String get chat_clearAll => 'Clear';

  @override
  String get chat_noMessages => 'No chat history';

  @override
  String get chat_deleteTitle => 'Delete conversation?';

  @override
  String get chat_deleteConfirm => 'This cannot be undone';

  @override
  String get chat_delete => 'Delete';

  @override
  String get chat_current => 'Current';

  @override
  String get chat_justNow => 'Just now';

  @override
  String chat_minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String chat_hoursAgo(int hours) {
    return '$hours hr ago';
  }

  @override
  String chat_daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get aiSettings_title => 'AI Service Config';

  @override
  String get aiSettings_saved => 'AI config saved';

  @override
  String get aiSettings_cleared => 'AI config cleared';

  @override
  String get aiSettings_clearConfig => 'Clear Config';

  @override
  String get aiSettings_provider => 'Select AI Service';

  @override
  String get aiSettings_baseUrl => 'Base URL';

  @override
  String get aiSettings_model => 'Model';

  @override
  String get aiSettings_modelHint => 'Leave empty for default model';

  @override
  String get aiSettings_save => 'Save Config';

  @override
  String get aiSettings_apiKeyHint => 'Enter API Key';

  @override
  String get aiSettings_testing => 'Testing...';

  @override
  String get aiSettings_testConnection => 'Test Connection';

  @override
  String get aiSettings_testSuccess => 'Connection successful';

  @override
  String get aiSettings_testFail => 'Connection failed';

  @override
  String get aiSettings_helpTitle => 'Notes';

  @override
  String get aiSettings_help1 =>
      'API Key is stored with device encryption, never uploaded to any server';

  @override
  String get aiSettings_help2 =>
      'Running data is only sent when you actively use AI features';

  @override
  String get aiSettings_help3 =>
      'OpenClaw is a local self-hosted solution, data never leaves your device';

  @override
  String get aiSettings_help4 =>
      'Choose \"Custom\" to connect to any OpenAI-compatible service';

  @override
  String get summary_notConfigured =>
      'Please configure AI service in Settings first';

  @override
  String get summary_generating => 'Generating analysis...';

  @override
  String get summary_runAnalysis => 'AI Run Analysis';

  @override
  String get summary_weeklyTitle => 'AI Weekly Summary';

  @override
  String get summary_monthlyTitle => 'AI Monthly Summary';

  @override
  String get summary_yearlyTitle => 'AI Yearly Summary';

  @override
  String get summary_title => 'AI Analysis';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_personalInfo => 'PERSONAL INFO';

  @override
  String get settings_runSettings => 'RUN SETTINGS';

  @override
  String get settings_autoPause => 'Auto Pause';

  @override
  String get settings_autoPauseDesc =>
      'Pauses after 5 seconds stopped or moving slowly';

  @override
  String get settings_ttsSection => 'VOICE BROADCAST';

  @override
  String get settings_tts => 'Voice Broadcast';

  @override
  String get settings_ttsDesc => 'Announce distance and pace during runs';

  @override
  String get settings_ttsInterval => 'Interval';

  @override
  String settings_ttsEveryKm(int km) {
    return 'Every $km km';
  }

  @override
  String get settings_aiSection => 'AI ASSISTANT';

  @override
  String get settings_aiConfig => 'AI Service Config';

  @override
  String get settings_aiConfigured => 'Configured';

  @override
  String get settings_aiNotConfigured => 'Not configured, tap to set up';

  @override
  String get settings_aiCoach => 'AI Coach During Runs';

  @override
  String get settings_aiCoachDesc => 'Real-time pace advice and encouragement';

  @override
  String get settings_chatHistory => 'Chat History';

  @override
  String settings_chatStorage(int count, String size) {
    return '$count messages, $size';
  }

  @override
  String get settings_loading => 'Loading...';

  @override
  String get settings_appearance => 'APPEARANCE';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeSystem => 'System';

  @override
  String get settings_language => 'LANGUAGE';

  @override
  String get settings_langZh => '中文';

  @override
  String get settings_langEn => 'English';

  @override
  String get settings_langSystem => 'System';

  @override
  String get settings_mapSection => 'MAP SETTINGS';

  @override
  String get settings_mapSource => 'Tile Source';

  @override
  String get settings_mapCache => 'Map Cache';

  @override
  String get settings_amapApiKey => 'Gaode API Key';

  @override
  String get settings_amapApiKeyHint => 'For city identification (optional)';

  @override
  String get settings_amapApiKeyDesc =>
      'Get a free Web Service Key at lbs.amap.com for city identification after runs. Falls back to OpenStreetMap if not set.';

  @override
  String get settings_amapApiKeyPlaceholder =>
      'Enter Gaode Web Service API Key';

  @override
  String get settings_customTileUrl => 'Custom Tile URL';

  @override
  String get settings_customTileUrlHint =>
      'e.g. https://tile.example.com/z/x/y.png';

  @override
  String get settings_dataManagement => 'DATA MANAGEMENT';

  @override
  String get settings_importGarmin => 'Import Garmin Records';

  @override
  String get settings_importGarminDesc =>
      'Import from Garmin Connect JSON export';

  @override
  String get settings_importGpx => 'Import GPX';

  @override
  String get settings_importGpxDesc => 'Import records from other running apps';

  @override
  String get settings_exportAll => 'Export All Records';

  @override
  String get settings_exportAllDesc => 'Package as GPX + CSV';

  @override
  String get settings_clearAll => 'Clear All Records';

  @override
  String get settings_irreversible => 'This cannot be undone';

  @override
  String get settings_nickname => 'Name';

  @override
  String get settings_notSet => 'Not set';

  @override
  String get settings_setNickname => 'Set Name';

  @override
  String get settings_nicknameHint => 'Enter your name';

  @override
  String get settings_cancel => 'Cancel';

  @override
  String get settings_confirm => 'Confirm';

  @override
  String get settings_weight => 'Weight';

  @override
  String get settings_unit => 'Distance Unit';

  @override
  String get settings_inputWeight => 'Enter Weight';

  @override
  String get settings_clearMapCacheTitle => 'Clear map cache?';

  @override
  String settings_clearMapCacheContent(int sizeMb) {
    return 'This will delete $sizeMb MB of cached tiles.';
  }

  @override
  String get settings_clear => 'Clear';

  @override
  String get settings_mapCacheCleared => 'Map cache cleared';

  @override
  String get settings_parsingGarmin => 'Parsing Garmin data...';

  @override
  String get settings_importingRuns => 'Importing run records...';

  @override
  String settings_importSuccess(int count) {
    return 'Successfully imported $count records';
  }

  @override
  String settings_importSkipped(int count) {
    return 'Skipped $count (already exist)';
  }

  @override
  String settings_importSkippedGpx(int count) {
    return 'Skipped $count (exist or no trajectory)';
  }

  @override
  String settings_importFailed(int count) {
    return 'Failed $count:';
  }

  @override
  String settings_importMoreErrors(int count) {
    return '... and $count more';
  }

  @override
  String get settings_garminImportDone => 'Garmin Import Complete';

  @override
  String get settings_importError => 'Import Failed';

  @override
  String get settings_preparingImport => 'Preparing import...';

  @override
  String settings_importingProgress(int current, int total) {
    return 'Importing ($current/$total)';
  }

  @override
  String get settings_importDone => 'Import Complete';

  @override
  String settings_extracting(String filename) {
    return 'Extracting $filename...';
  }

  @override
  String get settings_noDataToExport => 'No records to export';

  @override
  String get settings_preparingExport => 'Preparing export...';

  @override
  String settings_exportingProgress(int current, int total) {
    return 'Exporting ($current/$total)';
  }

  @override
  String get settings_packingZip => 'Packing zip...';

  @override
  String settings_exportShareText(int count) {
    return 'Solrun run records export ($count records)';
  }

  @override
  String get settings_noChatHistory => 'No chat history';

  @override
  String get settings_clearChatTitle => 'Clear chat history?';

  @override
  String settings_clearChatContent(int count, String size) {
    return 'This will delete all AI conversations ($count messages, $size).\nThis cannot be undone.';
  }

  @override
  String get settings_chatHistoryCleared => 'Chat history cleared';

  @override
  String get settings_clearAllTitle => 'Clear all records?';

  @override
  String get settings_clearAllContent =>
      'This cannot be undone. All run records will be permanently deleted.';

  @override
  String get settings_allDataCleared => 'All records cleared';

  @override
  String get result_notFound => 'Record not found';

  @override
  String get result_title => '✦ RUN COMPLETE';

  @override
  String get result_avgPace => 'AVG PACE';

  @override
  String get result_calories => 'CALORIES';

  @override
  String get result_bestPace => 'BEST PACE';

  @override
  String get result_elevation => 'ELEVATION';

  @override
  String get result_tapToExpand => 'Tap to expand';

  @override
  String get result_aiAnalysis => 'AI Analyze This Run';

  @override
  String get result_save => 'Done';

  @override
  String get result_share => 'Share';

  @override
  String get main_crashRecoveryTitle => 'Incomplete Run Found';

  @override
  String main_crashRecoveryContent(String distance, String duration) {
    return 'An incomplete run was found ($distance km / $duration). Recover it?';
  }

  @override
  String get main_discard => 'Discard';

  @override
  String get main_recover => 'Recover';

  @override
  String get nav_audience => 'Audience';

  @override
  String get audience_role_screamingFan => 'Screaming Fan';

  @override
  String get audience_role_dataNerd => 'Data Nerd';

  @override
  String get audience_role_familyCrew => 'Family Crew';

  @override
  String get audience_role_zenViewer => 'Zen Viewer';

  @override
  String get audience_role_gambler => 'Gambler';

  @override
  String get audience_role_nitpicker => 'Nitpicker';

  @override
  String get audience_role_rivalFan => 'Rival Fan';

  @override
  String get audience_personality_savage => 'Savage';

  @override
  String get audience_personality_hypeCoach => 'Hype Coach';

  @override
  String get audience_personality_poet => 'Poet';

  @override
  String get audience_personality_clown => 'Clown';

  @override
  String get audience_personality_commentator => 'Commentator';

  @override
  String get audience_moodTitle => 'How should the audience cheer?';

  @override
  String get audience_moodConfirm => 'Start Running';

  @override
  String get audience_mood_motivate => 'Motivate Me';

  @override
  String get audience_mood_comfort => 'Comfort Me';

  @override
  String get audience_mood_provoke => 'Provoke Me';

  @override
  String get audience_mood_amuse => 'Make Me Laugh';

  @override
  String get audience_mood_focus => 'Stay Focused';

  @override
  String get audience_quoteWallTitle => 'Quote Wall';

  @override
  String get audience_quoteWallEmpty => 'No quotes yet, start running!';

  @override
  String get audience_fanTeamTitle => 'My Fan Team';

  @override
  String get audience_fanTeamEmpty => 'Lock in your favorite voices';

  @override
  String get audience_fanTeamLimit => 'Fan team is full, remove one first';

  @override
  String get audience_roleGalleryTitle => 'Role Gallery';

  @override
  String audience_unlockAt(int count) {
    return 'Unlocked at $count runs';
  }

  @override
  String audience_runsToUnlock(int count) {
    return '$count more runs to unlock';
  }

  @override
  String get audience_joinFanTeam => 'Join Fan Team';

  @override
  String get audience_removeFromFanTeam => 'Remove from Fan Team';

  @override
  String get audience_shoutsTitle => 'What the audience said';

  @override
  String get audience_noShouts => 'No audience shouts this run';

  @override
  String get audience_interviewTitle => 'Post-run Interview';

  @override
  String get audience_selectRoleForInterview => 'Select interviewee';

  @override
  String get audience_newRunner => 'New Runner';

  @override
  String get audience_roleDesc_screamingFan =>
      'Emotional die-hard fan, unconditional support';

  @override
  String get audience_roleDesc_dataNerd =>
      'Data-obsessed, judges everything by numbers';

  @override
  String get audience_roleDesc_familyCrew =>
      'Family and friends, emotions first';

  @override
  String get audience_roleDesc_zenViewer =>
      'Calm and accepting, focuses on the run itself';

  @override
  String get audience_roleDesc_gambler =>
      'Bets on runner\'s performance, data swings trigger intense emotions';

  @override
  String get audience_roleDesc_nitpicker =>
      'Digs up worst records, amplifies bad data';

  @override
  String get audience_roleDesc_rivalFan =>
      'Supports a rival runner, downplays with data';

  @override
  String audience_shoutCount(int count) {
    return '$count appearances';
  }

  @override
  String get audience_firstAppearance => 'First appearance';

  @override
  String get audience_noShoutsYet => 'No shouts yet';

  @override
  String get audience_selectPersonality => 'Select personality';

  @override
  String get audience_selectRole => 'Select role';

  @override
  String get audience_confirmAdd => 'Confirm';

  @override
  String get audience_replace => 'Replace';

  @override
  String get audience_remove => 'Remove';

  @override
  String get audience_fanTeamReplaceHint =>
      'Fan team is full, choose one to replace';

  @override
  String get audience_favoriteRemoved => 'Removed from favorites';

  @override
  String get audience_fanAdded => 'Added to fan team';

  @override
  String get audience_fanReplaced => 'Fan team member replaced';

  @override
  String get audience_fanRemoved => 'Removed from fan team';

  @override
  String get audience_quoteCopied => 'Copied to clipboard';

  @override
  String get audience_favoriteAdded => 'Added to quote wall';

  @override
  String get audience_sceneStart => 'Start';

  @override
  String audience_sceneSplitKm(Object km) {
    return 'Km $km';
  }

  @override
  String get audience_sceneFinish => 'Finish';

  @override
  String get audience_scenePaceAlert => 'Pace alert';

  @override
  String get audience_interviewHint => 'Ask the audience...';

  @override
  String audience_interviewOpening(String role) {
    return '$role wants to chat about this race';
  }

  @override
  String get audience_interviewStreaming => 'Responding...';

  @override
  String get audience_interviewRoleDesc =>
      'Select an audience role to interview you';

  @override
  String get share_pace => 'Pace';

  @override
  String get share_duration => 'Duration';

  @override
  String get share_calories => 'Calories';

  @override
  String get share_elevationGain => 'Elevation';

  @override
  String get share_distance => 'Distance';

  @override
  String get share_kilometer => 'km';

  @override
  String get share_noRouteData => 'No route data';

  @override
  String get share_overflowWarning => 'Frame too small, reduce data items';

  @override
  String get share_customize => 'Customize';

  @override
  String get share_saveToGallery => 'Save to Gallery';

  @override
  String get share_share => 'Share';

  @override
  String get share_savedToGallery => 'Saved to gallery';

  @override
  String share_saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get share_runRecord => 'Solrun Run Record';

  @override
  String get share_title => 'Share Run Record';

  @override
  String share_loadFailed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get share_templateClassic => 'Classic';

  @override
  String get share_templateHeatmap => 'Heatmap';

  @override
  String get share_templateMap => 'Map';

  @override
  String get share_templateMinimal => 'Minimal';

  @override
  String get share_toggleHeatmap => 'Heatmap Trail';

  @override
  String get share_toggleMapTiles => 'Map Tiles';

  @override
  String get share_togglePaceChart => 'Pace Chart';

  @override
  String get share_toggleElevation => 'Elevation Profile';

  @override
  String get share_toggleDataGrid => 'Data Grid';

  @override
  String get share_toggleHeader => 'Header';

  @override
  String get share_toggleDataEntertainment => 'Fun Data';

  @override
  String share_optionNotSupported(String label, String template) {
    return '$label is not available in $template style';
  }

  @override
  String share_unsupportedTemplate(String template) {
    return '$template style not supported';
  }

  @override
  String get share_audienceQuote => 'Audience Quote';

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateLater => 'Later';
}
