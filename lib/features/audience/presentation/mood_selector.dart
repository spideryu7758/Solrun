import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/mood_states.dart';

/// 跑前状态选择器
/// 5 个状态卡片横向排列，选中高亮，恢复上次选择或默认"激励我"
class MoodSelector extends StatefulWidget {
  final ValueChanged<MoodState> onSelected;

  const MoodSelector({super.key, required this.onSelected});

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  static const _prefKey = 'last_mood_index';

  MoodState _selected = MoodState.motivate; // 默认选中

  @override
  void initState() {
    super.initState();
    _restoreLastMood();
  }

  /// 从 SharedPreferences 恢复上次选择的心情
  Future<void> _restoreLastMood() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_prefKey);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < MoodState.values.length &&
        mounted) {
      setState(() => _selected = MoodState.values[savedIndex]);
    }
  }

  /// 持久化心情选择
  Future<void> _saveMood(MoodState mood) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, mood.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.rpBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // 标题
              Text(
                S.of(context)!.audience_moodTitle,
                style: TextStyle(
                  fontSize: 14,
                  color: context.rpMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              // 状态卡片列表
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: MoodState.values.map((mood) {
                  final isSelected = mood == _selected;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _MoodCard(
                        mood: mood,
                        isSelected: isSelected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = mood);
                          _saveMood(mood);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // 确认按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onSelected(_selected);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SolrunColors.accent,
                    foregroundColor: const Color(0xFF0A0A0F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    S.of(context)!.audience_moodConfirm,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final MoodState mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final local = S.of(context)!;
    // 获取国际化名称
    final displayName = switch (mood) {
      MoodState.motivate => local.audience_mood_motivate,
      MoodState.comfort => local.audience_mood_comfort,
      MoodState.provoke => local.audience_mood_provoke,
      MoodState.amuse => local.audience_mood_amuse,
      MoodState.focus => local.audience_mood_focus,
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? context.rpAccent.withValues(alpha: 0.15)
              : context.rpCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? context.rpAccent
                : context.rpBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? context.rpAccent : context.rpMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
