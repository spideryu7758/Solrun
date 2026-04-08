// AI 总结 Prompt 模板

/// 总结类型
enum SummaryType {
  perRun,   // 单次跑步
  weekly,   // 周总结
  monthly,  // 月总结
  yearly,   // 年总结
}

class SummaryPrompt {
  SummaryPrompt._();

  /// 单次跑步总结 system prompt
  static String perRunSystem({bool isEn = false}) {
    if (isEn) {
      return 'You are a professional running coach. Analyze the user\'s run data and provide a summary. '
          'Include: overall performance assessment, pace analysis (even splits / positive-negative splits), '
          'actionable improvement suggestions, and encouragement. '
          'Keep your reply under 200 words. Be professional yet friendly.';
    }
    return '你是专业的跑步教练。根据用户这次跑步的数据，给出分析总结。'
        '包括：整体表现评价、配速分析（是否均匀、是否有正/负分段）、'
        '改进建议（具体可执行的）、鼓励语。'
        '回复不超过 300 字，用中文，语气专业但友好。';
  }

  /// 周/月/年总结 system prompt
  static String periodSystem({bool isEn = false}) {
    if (isEn) {
      return 'You are a professional running coach. Analyze the user\'s aggregated running data and provide periodic insights. '
          'Include: training volume assessment, trend analysis (compared to general recommendations), '
          'intensity distribution advice, and training suggestions for the next period. '
          'Keep your reply under 250 words. Be professional yet friendly.';
    }
    return '你是专业的跑步教练。根据用户提供的跑步汇总数据，给出周期性分析。'
        '包括：训练量评估、趋势分析（与通常建议的对比）、'
        '强度分布建议、下一周期的训练建议。'
        '回复不超过 400 字，用中文，语气专业但友好。';
  }

  /// 单次跑步的用户消息
  static String perRunUser(String runContext, {bool isEn = false}) {
    if (isEn) return 'Please analyze my run:\n\n$runContext';
    return '请分析我这次跑步：\n\n$runContext';
  }

  /// 周期性总结的用户消息
  static String periodUser(String periodContext, String periodLabel, {bool isEn = false}) {
    if (isEn) return 'Please analyze my $periodLabel running data:\n\n$periodContext';
    return '请分析我$periodLabel的跑步数据：\n\n$periodContext';
  }
}
