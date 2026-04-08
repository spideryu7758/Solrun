import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../audience/domain/audience_roles.dart';
import '../../audience/domain/personalities.dart';

/// 赛后采访角色+人格选择器（BottomSheet 内容）
class InterviewRolePicker extends StatefulWidget {
  final int sessionId;
  final List<AudienceRole> unlockedRoles;

  const InterviewRolePicker({
    super.key,
    required this.sessionId,
    required this.unlockedRoles,
  });

  @override
  State<InterviewRolePicker> createState() => _InterviewRolePickerState();
}

class _InterviewRolePickerState extends State<InterviewRolePicker> {
  AudienceRole? _selectedRole;
  Personality? _selectedPersonality;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖拽把手
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              s.audience_interviewTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.rpText),
            ),
            const SizedBox(height: 4),
            Text(
              s.audience_interviewRoleDesc,
              style: TextStyle(fontSize: 12, color: context.rpMuted),
            ),
            const SizedBox(height: 16),

            // 角色网格
            Text(s.audience_selectRole, style: TextStyle(fontSize: 12, color: context.rpMuted, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.unlockedRoles.map((role) {
                final selected = _selectedRole == role;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedRole = role;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? context.rpAccent.withValues(alpha: 0.15) : context.rpCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? context.rpAccent : context.rpBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(role.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          role.localizedName(s),
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? context.rpAccent : context.rpText,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 人格选择
            if (_selectedRole != null) ...[
              Text(s.audience_selectPersonality, style: TextStyle(fontSize: 12, color: context.rpMuted, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Personality.values.map((p) {
                  final selected = _selectedPersonality == p;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPersonality = p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? context.rpAccent2.withValues(alpha: 0.15) : context.rpCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? context.rpAccent2 : context.rpBorder,
                        ),
                      ),
                      child: Text(
                        p.localizedName(s),
                        style: TextStyle(
                          fontSize: 12,
                          color: selected ? context.rpAccent2 : context.rpText,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // 确认按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedRole != null && _selectedPersonality != null)
                    ? () {
                        Navigator.of(context).pop();
                        context.push(
                          '/audience/interview'
                          '?sessionId=${widget.sessionId}'
                          '&role=${_selectedRole!.name}'
                          '&personality=${_selectedPersonality!.name}',
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.rpAccent,
                  foregroundColor: const Color(0xFF0A0A0F),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: context.rpCard,
                ),
                child: Text(s.audience_confirmAdd, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
