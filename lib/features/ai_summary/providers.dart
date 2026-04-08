import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/summary_notifier.dart';

/// AI 总结 Provider
final summaryProvider = StateNotifierProvider<SummaryNotifier, SummaryState>((ref) {
  return SummaryNotifier(ref);
});
