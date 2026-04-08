import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/rp_components.dart';
import '../../../../shared/widgets/rp_animations.dart';

/// 个人信息区域：头像卡片 + 昵称 / 体重 / 单位
class PersonalInfoSection extends ConsumerStatefulWidget {
  const PersonalInfoSection({super.key});

  @override
  ConsumerState<PersonalInfoSection> createState() =>
      _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends ConsumerState<PersonalInfoSection> {
  String _nickname = '';
  String? _avatarPath;
  double _weightKg = 70;
  bool _useKm = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname') ?? '';
      _avatarPath = prefs.getString('avatar_path');
      _weightKg = prefs.getDouble('weight_kg') ?? 70;
      _useKm = prefs.getBool('use_km') ?? true;
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 个人资料卡
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: RpTapScale(
            onTap: _pickAvatar,
            child: RpCard(
              tier: RpCardTier.tier3,
              child: Row(
                children: [
                  // 头像（accent 边框环）
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.rpAccent, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: context.rpBorder,
                      backgroundImage: _avatarPath != null
                          ? FileImage(File(_avatarPath!))
                          : null,
                      child: _avatarPath == null
                          ? Icon(Icons.person,
                              size: 32, color: context.rpMuted)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nickname.isEmpty ? 'Runner' : _nickname,
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 24,
                            color: _nickname.isEmpty
                                ? context.rpMuted
                                : context.rpText,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_weightKg.toStringAsFixed(1)} kg · ${_useKm ? 'km' : 'mi'}',
                          style: TextStyle(
                              fontSize: 12, color: context.rpMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: context.rpMuted, size: 20),
                ],
              ),
            ),
          ),
        ),

        // 个人信息（独立设置项）
        RpSectionHeader(S.of(context)!.settings_personalInfo),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RpCard(
            tier: RpCardTier.tier1,
            padding: EdgeInsets.zero,
            child: Column(children: [
              _buildNicknameTile(),
              _buildWeightTile(),
              _buildUnitTile(),
            ]),
          ),
        ),
      ],
    );
  }

  // --------------- 头像选择 ---------------

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (image == null) return;

    // 拷贝到 app 私有目录持久化
    final appDir = await getApplicationSupportDirectory();
    final avatarFile = File(p.join(appDir.path, 'avatar.jpg'));
    await File(image.path).copy(avatarFile.path);

    setState(() => _avatarPath = avatarFile.path);
    _savePref('avatar_path', avatarFile.path);
  }

  // --------------- 昵称 ---------------

  Widget _buildNicknameTile() {
    return ListTile(
      title: Text(S.of(context)!.settings_nickname),
      subtitle: Text(
          _nickname.isEmpty
              ? S.of(context)!.settings_notSet
              : _nickname,
          style: TextStyle(fontSize: 12, color: context.rpMuted)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () async {
        final result = await _showNicknameDialog();
        if (result != null) {
          setState(() => _nickname = result);
          _savePref('nickname', result);
        }
      },
    );
  }

  Future<String?> _showNicknameDialog() async {
    final controller = TextEditingController(text: _nickname);
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.rpCard,
          title: Text(S.of(context)!.settings_setNickname,
              style: TextStyle(color: context.rpText)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
                hintText: S.of(context)!.settings_nicknameHint),
            autofocus: true,
            maxLength: 20,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(S.of(context)!.settings_cancel,
                  style: TextStyle(color: context.rpMuted)),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(controller.text.trim()),
              child: Text(S.of(context)!.settings_confirm,
                  style: TextStyle(color: context.rpAccent)),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  // --------------- 体重 ---------------

  Widget _buildWeightTile() {
    return ListTile(
      title: Text(S.of(context)!.settings_weight),
      subtitle: Text('${_weightKg.toStringAsFixed(1)} kg'),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () async {
        final result = await _showWeightDialog();
        if (result != null) {
          setState(() => _weightKg = result);
          _savePref('weight_kg', result);
        }
      },
    );
  }

  Future<double?> _showWeightDialog() async {
    final controller =
        TextEditingController(text: _weightKg.toStringAsFixed(1));
    try {
      return await showDialog<double>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.rpCard,
          title: Text(S.of(context)!.settings_inputWeight),
          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(suffixText: 'kg'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(S.of(context)!.settings_cancel,
                  style: TextStyle(color: context.rpMuted)),
            ),
            TextButton(
              onPressed: () {
                final v = double.tryParse(controller.text);
                if (v != null && v > 0 && v < 500) {
                  Navigator.of(ctx).pop(v);
                }
              },
              child: Text(S.of(context)!.settings_confirm,
                  style: TextStyle(color: context.rpAccent)),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  // --------------- 单位 ---------------

  Widget _buildUnitTile() {
    return ListTile(
      title: Text(S.of(context)!.settings_unit),
      trailing: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: true, label: Text('km')),
          ButtonSegment(value: false, label: Text('mi')),
        ],
        selected: {_useKm},
        onSelectionChanged: (v) {
          setState(() => _useKm = v.first);
          _savePref('use_km', v.first);
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? SolrunColors.accent
                : context.rpCard;
          }),
        ),
      ),
    );
  }
}
