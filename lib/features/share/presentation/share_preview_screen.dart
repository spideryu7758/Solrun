import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/share_card_config.dart';
import '../domain/share_card_data.dart';
import '../providers.dart';
import 'share_card_notifier.dart';
import 'templates/classic_template.dart';
import 'templates/heatmap_template.dart';
import 'templates/map_photo_template.dart';
import 'templates/minimal_template.dart';
import 'widgets/aspect_ratio_selector.dart';
import 'widgets/customization_toggles.dart';
import 'widgets/template_selector.dart';

/// 分享预览页 — 实时预览 + 自定义 + 截图 + 分享
class SharePreviewScreen extends ConsumerStatefulWidget {
  final int sessionId;
  const SharePreviewScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends ConsumerState<SharePreviewScreen> {
  final _cardKey = GlobalKey();
  bool _saving = false;
  bool _customExpanded = false;

  // 卡片基础宽度
  static const double _baseWidth = 360;

  double _cardHeight(CardAspectRatio ratio) => _baseWidth / ratio.ratio;

  /// 根据模板类型构建对应卡片
  Widget _buildTemplate(ShareCardData data, ShareCardConfig config) {
    final h = _cardHeight(config.aspectRatio);
    return switch (config.template) {
      CardTemplate.classic => ClassicTemplate(
        data: data,
        config: config,
        cardWidth: _baseWidth,
        cardHeight: h,
      ),
      CardTemplate.heatmap => HeatmapTemplate(
        data: data,
        config: config,
        cardWidth: _baseWidth,
        cardHeight: h,
      ),
      CardTemplate.mapPhoto => MapPhotoTemplate(
        data: data,
        config: config,
        cardWidth: _baseWidth,
        cardHeight: h,
      ),
      CardTemplate.minimal => MinimalTemplate(
        data: data,
        config: config,
        cardWidth: _baseWidth,
        cardHeight: h,
      ),
    };
  }

  /// 观众语录选择器（水平 chip 列表）
  Widget _buildShoutSelector(
    ShareCardConfig config,
    ShareCardNotifier notifier,
  ) {
    final shoutsAsync = ref.watch(sessionShoutsProvider(widget.sessionId));
    return shoutsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (shouts) {
        if (shouts.isEmpty) return const SizedBox.shrink();
        final s = S.of(context)!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.share_audienceQuote,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final shout in shouts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: GestureDetector(
                            onTap: () {
                              if (config.shoutText == shout.content) {
                                notifier.setShout(null, null);
                              } else {
                                notifier.setShout(
                                  shout.content,
                                  shout.audienceRole,
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: config.shoutText == shout.content
                                    ? SolrunColors.accent.withValues(
                                        alpha: 0.15,
                                      )
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: config.shoutText == shout.content
                                      ? SolrunColors.accent.withValues(
                                          alpha: 0.5,
                                        )
                                      : Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Text(
                                '"${shout.content}"',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: config.shoutText == shout.content
                                      ? SolrunColors.accent
                                      : Colors.white.withValues(alpha: 0.9),
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
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
      },
    );
  }

  // ── 截图/保存/分享 ──

  Future<Uint8List?> _captureImage() async {
    try {
      // 等待渲染完成（地图瓦片需要额外时间）
      await Future.delayed(const Duration(milliseconds: 500));

      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture failed: $e');
      return null;
    }
  }

  Future<File?> _saveToFile(Uint8List bytes, int sessionId) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/solrun_share_$sessionId.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _downloadToGallery(ShareCardData data) async {
    final s = S.of(context)!;
    setState(() => _saving = true);
    try {
      final bytes = await _captureImage();
      if (bytes == null) return;

      final tempDir = await getTemporaryDirectory();
      final t = data.session.startTime;
      final ds =
          '${t.year}${t.month.toString().padLeft(2, '0')}${t.day.toString().padLeft(2, '0')}';
      final tempFile = File(
        '${tempDir.path}/Solrun_${ds}_${data.session.id}.png',
      );
      await tempFile.writeAsBytes(bytes);

      const channel = MethodChannel('com.runpure.run_pure/media_store');
      try {
        await channel.invokeMethod('saveToGallery', {
          'path': tempFile.path,
          'name': 'Solrun_${ds}_${data.session.id}.png',
        });
      } catch (_) {
        final dir = Directory('/storage/emulated/0/Pictures/Solrun');
        if (!await dir.exists()) await dir.create(recursive: true);
        final file = File('${dir.path}/Solrun_${ds}_${data.session.id}.png');
        await tempFile.copy(file.path);
        const scanChannel = MethodChannel('com.runpure.run_pure/media_scanner');
        try {
          await scanChannel.invokeMethod('scan', {'path': file.path});
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(s.share_savedToGallery)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.share_saveFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _shareImage(ShareCardData data) async {
    final bytes = await _captureImage();
    if (bytes == null) return;
    final file = await _saveToFile(bytes, data.session.id);
    if (file == null) return;
    final s = S.of(context)!;
    await Share.shareXFiles([XFile(file.path)], text: s.share_runRecord);
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(shareCardDataProvider(widget.sessionId));
    final config = ref.watch(shareCardConfigProvider);
    final notifier = ref.read(shareCardConfigProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          S.of(context)!.share_title,
          style: const TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: dataAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: SolrunColors.accent),
        ),
        error: (e, _) => Center(
          child: Text(
            S.of(context)!.share_loadFailed(e.toString()),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (data) => Column(
          children: [
            // 卡片预览
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: _buildTemplate(data, config),
                  ),
                ),
              ),
            ),

            // 自定义控制区
            Container(
              color: const Color(0xFF111111),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 模板选择
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TemplateSelector(
                      selected: config.template,
                      onChanged: notifier.setTemplate,
                    ),
                  ),

                  // 比例选择 + 自定义按钮（同一行）
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: AspectRatioSelector(
                            selected: config.aspectRatio,
                            onChanged: notifier.setAspectRatio,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 自定义开关（可折叠）
                        GestureDetector(
                          onTap: () => setState(
                            () => _customExpanded = !_customExpanded,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _customExpanded
                                  ? SolrunColors.accent.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _customExpanded
                                    ? SolrunColors.accent.withValues(alpha: 0.4)
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  S.of(context)!.share_customize,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _customExpanded
                                        ? SolrunColors.accent
                                        : Colors.white54,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  _customExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 14,
                                  color: _customExpanded
                                      ? SolrunColors.accent
                                      : Colors.white38,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_customExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: CustomizationToggles(
                        config: config,
                        onToggleHeatmap: notifier.toggleHeatmap,
                        onToggleMapTiles: notifier.toggleMapTiles,
                        onTogglePaceChart: notifier.togglePaceChart,
                        onToggleElevation: notifier.toggleElevationProfile,
                        onToggleDataGrid: notifier.toggleDataGrid,
                        onToggleHeader: notifier.toggleHeader,
                        onToggleDataEntertainment:
                            notifier.toggleDataEntertainment,
                      ),
                    ),
                    // 观众语录选择器
                    _buildShoutSelector(config, notifier),
                  ],
                ],
              ),
            ),

            // 底部操作栏
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              color: Colors.black,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving
                          ? null
                          : () => _downloadToGallery(data),
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download, size: 18),
                      label: Text(S.of(context)!.share_saveToGallery),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareImage(data),
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(S.of(context)!.share_share),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SolrunColors.accent,
                        foregroundColor: const Color(0xFF0A0A0F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
