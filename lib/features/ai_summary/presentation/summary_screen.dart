import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/services/llm/llm_riverpod.dart';
import '../domain/summary_prompt.dart';
import '../providers.dart';

/// AI 总结展示页面（底部弹出 sheet）
class SummarySheet extends ConsumerStatefulWidget {
  final int? sessionId;
  final SummaryType? summaryType;

  const SummarySheet({
    super.key,
    this.sessionId,
    this.summaryType,
  });

  /// 显示单次跑步总结
  static Future<void> showRunSummary(BuildContext context, WidgetRef ref, int sessionId) async {
    final aiAvailable = ref.read(aiAvailableProvider);
    if (!aiAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.summary_notConfigured)),
      );
      return;
    }
    ref.read(summaryProvider.notifier).generateRunSummary(sessionId);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SummarySheet(sessionId: sessionId),
    );
  }

  /// 显示周期性总结
  static Future<void> showPeriodSummary(BuildContext context, WidgetRef ref, SummaryType type) async {
    final aiAvailable = ref.read(aiAvailableProvider);
    if (!aiAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.summary_notConfigured)),
      );
      return;
    }
    ref.read(summaryProvider.notifier).generatePeriodSummary(type);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SummarySheet(summaryType: type),
    );
  }

  @override
  ConsumerState<SummarySheet> createState() => _SummarySheetState();
}

class _SummarySheetState extends ConsumerState<SummarySheet> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(summaryProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
      decoration: BoxDecoration(
        color: context.rpBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: context.rpBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.rpMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: context.rpAccent),
                const SizedBox(width: 8),
                Text(_title, style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: context.rpText,
                )),
                const Spacer(),
                if (state.isStreaming)
                  IconButton(
                    icon: Icon(Icons.stop_circle_outlined, size: 20, color: context.rpDanger),
                    onPressed: () => ref.read(summaryProvider.notifier).stop(),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 内容区
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.rpDanger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 16, color: context.rpDanger),
                          const SizedBox(width: 8),
                          Expanded(child: Text(state.error!,
                            style: TextStyle(fontSize: 13, color: context.rpDanger))),
                        ],
                      ),
                    ),

                  if (state.content.isNotEmpty)
                    SelectableText(
                      state.content,
                      style: TextStyle(
                        fontSize: 14, color: context.rpText, height: 1.6,
                      ),
                    ),

                  if (state.isStreaming && state.content.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: context.rpAccent, strokeWidth: 2),
                            const SizedBox(height: 12),
                            Text(S.of(context)!.summary_generating, style: TextStyle(
                              fontSize: 13, color: context.rpMuted,
                            )),
                          ],
                        ),
                      ),
                    ),

                  if (state.isStreaming && state.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 12, height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: context.rpAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _title {
    if (widget.sessionId != null) return S.of(context)!.summary_runAnalysis;
    switch (widget.summaryType) {
      case SummaryType.weekly:
        return S.of(context)!.summary_weeklyTitle;
      case SummaryType.monthly:
        return S.of(context)!.summary_monthlyTitle;
      case SummaryType.yearly:
        return S.of(context)!.summary_yearlyTitle;
      default:
        return S.of(context)!.summary_title;
    }
  }
}
