import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../data/providers.dart';
import '../../../../data/run_session_status.dart';
import '../../../../shared/widgets/rp_components.dart';
import '../../../export/csv_exporter.dart';
import '../../../export/gpx_exporter.dart';
import '../../../export/garmin_importer.dart';
import '../../../export/gpx_importer.dart';

/// 数据管理区域：导入导出（Garmin / GPX / ZIP）+ 清空数据
class DataManagementSection extends ConsumerStatefulWidget {
  const DataManagementSection({super.key});

  @override
  ConsumerState<DataManagementSection> createState() =>
      _DataManagementSectionState();
}

class _DataManagementSectionState
    extends ConsumerState<DataManagementSection> {
  double _weightKg = 70;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weightKg = prefs.getDouble('weight_kg') ?? 70;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RpSectionHeader(S.of(context)!.settings_dataManagement),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RpCard(
            tier: RpCardTier.tier1,
            padding: EdgeInsets.zero,
            child: Column(children: [
              _buildActionTile(
                S.of(context)!.settings_importGarmin,
                S.of(context)!.settings_importGarminDesc,
                Icons.watch,
                _importGarmin,
              ),
              _buildActionTile(
                S.of(context)!.settings_importGpx,
                S.of(context)!.settings_importGpxDesc,
                Icons.download,
                _importGpx,
              ),
              _buildActionTile(
                S.of(context)!.settings_exportAll,
                S.of(context)!.settings_exportAllDesc,
                Icons.upload_file,
                _exportAll,
              ),
            ]),
          ),
        ),
        // 危险区：清空全部记录
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: context.rpDanger.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildActionTile(
              S.of(context)!.settings_clearAll,
              S.of(context)!.settings_irreversible,
              Icons.delete_forever,
              _clearAllData,
              color: context.rpDanger,
            ),
          ),
        ),
      ],
    );
  }

  // --------------- 通用 ---------------

  Widget _buildActionTile(
      String title, String subtitle, IconData icon, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? context.rpText),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: context.rpMuted)),
      onTap: onTap,
    );
  }

  // --------------- Garmin 导入 ---------------

  Future<void> _importGarmin() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.first.path == null) {
      return;
    }

    final file = File(result.files.first.path!);
    if (!mounted) return;

    // 进度弹窗（保留原样，不替换为 RpDialog）
    final progressNotifier =
        ValueNotifier<String>(S.of(context)!.settings_parsingGarmin);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.rpCard,
        content: ValueListenableBuilder<String>(
          valueListenable: progressNotifier,
          builder: (_, progress, c) => Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(progress,
                      style: TextStyle(
                          color: context.rpText, fontSize: 13))),
            ],
          ),
        ),
      ),
    );

    try {
      final importer =
          GarminImporter(ref.read(runSessionDaoProvider));
      progressNotifier.value =
          S.of(context)!.settings_importingRuns;

      final importResult =
          await importer.importFile(file, weightKg: _weightKg);

      progressNotifier.dispose();
      if (!mounted) return;
      Navigator.of(context).pop();

      final msg = StringBuffer();
      msg.writeln(
          S.of(context)!.settings_importSuccess(importResult.success));
      if (importResult.skipped > 0) {
        msg.writeln(S
            .of(context)!
            .settings_importSkipped(importResult.skipped));
      }
      if (importResult.failed > 0) {
        msg.writeln(S
            .of(context)!
            .settings_importFailed(importResult.failed));
        for (final e in importResult.errors.take(10)) {
          msg.writeln('  \u00b7 $e');
        }
        if (importResult.errors.length > 10) {
          msg.writeln(S.of(context)!.settings_importMoreErrors(
              importResult.errors.length - 10));
        }
      }

      if (!mounted) return;
      await RpDialog.info(
        context,
        title: S.of(context)!.settings_garminImportDone,
        content: msg.toString(),
      );
    } catch (e) {
      progressNotifier.dispose();
      if (!mounted) return;
      Navigator.of(context).pop();

      if (!mounted) return;
      await RpDialog.info(
        context,
        title: S.of(context)!.settings_importError,
        content: '$e',
      );
    }
  }

  // --------------- GPX 导入 ---------------

  Future<void> _importGpx() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final pickedFiles = result.files
        .where((f) => f.path != null)
        .map((f) => File(f.path!))
        .toList();

    if (pickedFiles.isEmpty || !mounted) return;

    // 进度弹窗（保留原样，不替换为 RpDialog）
    final progressNotifier = ValueNotifier<String>(
        S.of(context)!.settings_preparingImport);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.rpCard,
        content: ValueListenableBuilder<String>(
          valueListenable: progressNotifier,
          builder: (_, progress, c) => Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(progress,
                      style: TextStyle(
                          color: context.rpText, fontSize: 13))),
            ],
          ),
        ),
      ),
    );

    final importer = GpxImporter(
      ref.read(runSessionDaoProvider),
      ref.read(routePointDaoProvider),
      ref.read(splitPaceDaoProvider),
    );

    int success = 0;
    int skipped = 0;
    int failed = 0;
    final errors = <String>[];

    // 从选中的文件中提取 GPX（zip 自动解压）
    final gpxFiles =
        await _extractGpxFiles(pickedFiles, progressNotifier);

    for (int i = 0; i < gpxFiles.length; i++) {
      final fileName = gpxFiles[i].path.split('/').last;
      progressNotifier.value =
          '${S.of(context)!.settings_importingProgress(i + 1, gpxFiles.length)}\n$fileName';
      try {
        final result = await importer.importFile(gpxFiles[i], weightKg: _weightKg);
        success += result.success;
        skipped += result.skipped;
        failed += result.failed;
        errors.addAll(result.errors);
      } catch (e) {
        failed++;
        errors.add('$fileName: $e');
      }
    }

    progressNotifier.dispose();
    if (!mounted) return;
    Navigator.of(context).pop();

    // 清理解压的临时文件
    final tempDir = Directory(
        p.join((await getTemporaryDirectory()).path, 'gpx_import'));
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }

    final msg = StringBuffer();
    msg.writeln(S.of(context)!.settings_importSuccess(success));
    if (skipped > 0) {
      msg.writeln(
          S.of(context)!.settings_importSkippedGpx(skipped));
    }
    if (failed > 0) {
      msg.writeln(S.of(context)!.settings_importFailed(failed));
      for (final e in errors.take(10)) {
        msg.writeln('  \u00b7 $e');
      }
      if (errors.length > 10) {
        msg.writeln(S.of(context)!
            .settings_importMoreErrors(errors.length - 10));
      }
    }

    if (!mounted) return;
    await RpDialog.info(
      context,
      title: S.of(context)!.settings_importDone,
      content: msg.toString(),
    );
  }

  /// 从文件列表中提取 GPX 文件（遇到 zip 自动解压）
  Future<List<File>> _extractGpxFiles(
    List<File> files,
    ValueNotifier<String> progressNotifier,
  ) async {
    final gpxFiles = <File>[];
    final tempDir = Directory(
        p.join((await getTemporaryDirectory()).path, 'gpx_import'));
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
    await tempDir.create(recursive: true);

    for (final file in files) {
      final ext = p.extension(file.path).toLowerCase();
      if (ext == '.gpx') {
        gpxFiles.add(file);
      } else if (ext == '.zip') {
        progressNotifier.value = S.of(context)!
            .settings_extracting(file.path.split('/').last);
        final bytes = await file.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final entry in archive) {
          if (entry.isFile &&
              entry.name.toLowerCase().endsWith('.gpx')) {
            final outFile = File(
                p.join(tempDir.path, p.basename(entry.name)));
            await outFile.writeAsBytes(entry.content);
            gpxFiles.add(outFile);
          }
        }
      }
    }

    return gpxFiles;
  }

  // --------------- 全量导出 ---------------

  Future<void> _exportAll() async {
    final sessionDao = ref.read(runSessionDaoProvider);
    final pointDao = ref.read(routePointDaoProvider);
    final splitDao = ref.read(splitPaceDaoProvider);

    final sessions = await sessionDao.getAllSessions();
    final completed = sessions
        .where((s) => s.status == RunSessionStatus.completed)
        .toList();
    if (completed.isEmpty) {
      if (mounted) {
        RpSnackBar.show(
            context, S.of(context)!.settings_noDataToExport);
      }
      return;
    }

    if (!mounted) return;

    // 进度弹窗（保留原样，不替换为 RpDialog）
    final progressNotifier = ValueNotifier<String>(
        S.of(context)!.settings_preparingExport);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.rpCard,
        content: ValueListenableBuilder<String>(
          valueListenable: progressNotifier,
          builder: (_, progress, c) => Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(progress,
                      style: TextStyle(
                          color: context.rpText, fontSize: 13))),
            ],
          ),
        ),
      ),
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final exportDir =
          Directory('${tempDir.path}/runpure_export');
      if (await exportDir.exists()) {
        await exportDir.delete(recursive: true);
      }
      await exportDir.create();

      // 逐条流式导出（每条独立查询轨迹点后立即释放）
      for (int i = 0; i < completed.length; i++) {
        final session = completed[i];
        progressNotifier.value =
            '${S.of(context)!.settings_exportingProgress(i + 1, completed.length)}\n${session.autoName}';

        final dateStr =
            '${session.startTime.year}${session.startTime.month.toString().padLeft(2, '0')}${session.startTime.day.toString().padLeft(2, '0')}';
        final baseName =
            '${session.autoName}_${dateStr}_${session.id}';

        // GPX — 查询轨迹点 -> 写入文件 -> 释放内存
        final points =
            await pointDao.getPointsBySession(session.id);
        final gpxContent = GpxExporter.export(session, points);
        final gpxFile =
            File('${exportDir.path}/$baseName.gpx');
        await gpxFile.writeAsString(gpxContent);

        // CSV
        final splits =
            await splitDao.getSplitsBySession(session.id);
        final csvContent = CsvExporter.export(session, splits);
        final csvFile =
            File('${exportDir.path}/$baseName.csv');
        await csvFile.writeAsString(csvContent);
      }

      // 打包为 zip（避免分享数千个文件导致崩溃）
      progressNotifier.value =
          S.of(context)!.settings_packingZip;
      final zipPath =
          '${tempDir.path}/Solrun_export_${completed.length}.zip';
      final zipFile = File(zipPath);
      if (await zipFile.exists()) await zipFile.delete();

      final archive = Archive();
      final exportFiles = await exportDir.list().toList();
      for (final entity in exportFiles) {
        if (entity is File) {
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile(
              p.basename(entity.path), bytes.length, bytes));
        }
      }
      final zipBytes = ZipEncoder().encode(archive);
      await zipFile.writeAsBytes(zipBytes);

      // 清理散文件目录
      await exportDir.delete(recursive: true);

      progressNotifier.dispose();
      if (!mounted) return;
      Navigator.of(context).pop();

      await Share.shareXFiles(
        [XFile(zipPath)],
        text: S.of(context)!
            .settings_exportShareText(completed.length),
      );
    } catch (e) {
      progressNotifier.dispose();
      if (!mounted) return;
      Navigator.of(context).pop();

      if (!mounted) return;
      // 导出写入失败提示用户
      RpSnackBar.show(context, '${S.of(context)!.settings_exportAll}: $e');
    }
  }

  // --------------- 清空数据 ---------------

  Future<void> _clearAllData() async {
    final confirmed = await RpDialog.confirm(
      context,
      title: S.of(context)!.settings_clearAllTitle,
      content: S.of(context)!.settings_clearAllContent,
      confirmText: S.of(context)!.settings_clear,
      confirmColor: context.rpDanger,
    );

    if (confirmed) {
      final db = ref.read(databaseProvider);
      // 按外键顺序删除
      await db.customStatement('DELETE FROM route_points');
      await db.customStatement('DELETE FROM split_paces');
      await db.customStatement('DELETE FROM achievements');
      await db.customStatement('DELETE FROM run_sessions');
      if (mounted) {
        RpSnackBar.show(
            context, S.of(context)!.settings_allDataCleared);
      }
    }
  }
}
