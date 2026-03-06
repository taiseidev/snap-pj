import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers/photo_provider.dart';
import 'gear_detail_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _showExportPreview(BuildContext context, WidgetRef ref) {
    final photos = ref.read(photoListProvider);
    final csvLines = <String>[
      'ID,撮影日時,カメラ,レンズ,焦点距離,F値,SS,ISO,レーティング,お気に入り',
    ];
    for (final p in photos) {
      csvLines.add(
        '${p.id},${DateFormat('yyyy/M/d HH:mm').format(p.shotAt)},'
        '${p.cameraModel},${p.lensModel},'
        '${p.focalLength.toInt()}mm,f/${p.aperture},${p.shutterSpeed},'
        '${p.iso},${p.rating},${p.isFavorite ? "Yes" : "No"}',
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('エクスポートプレビュー',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Text(
                    'CSV形式 - ${photos.length}件のデータ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: csvLines.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              csvLines[index],
                              style: TextStyle(
                                fontSize: 11,
                                color: index == 0
                                    ? Colors.white70
                                    : Colors.white54,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('データをエクスポートしました'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('エクスポート'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94560),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photoListProvider);
    final cameras = photos.map((p) => p.cameraModel).toSet().toList();
    final lenses = photos.map((p) => p.lensModel).toSet().toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Settings', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 20),

          // My Gear section
          Text('マイギア', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera, color: Colors.white54),
                  title: const Text('カメラ'),
                  subtitle: Text(
                    cameras.join(', '),
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GearDetailPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.lens, color: Colors.white54),
                  title: const Text('レンズ'),
                  subtitle: Text(
                    '${lenses.length}本登録済み',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GearDetailPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Data section
          Text('データ', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: Colors.white54),
                  title: const Text('写真をインポート'),
                  subtitle: Text(
                    'カメラロールから写真を取り込み',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('写真インポート機能は今後のアップデートで対応予定です'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading:
                      const Icon(Icons.cloud_upload, color: Colors.white54),
                  title: const Text('データのバックアップ'),
                  subtitle: Text(
                    '撮影データをエクスポート',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () => _showExportPreview(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // App section
          Text('アプリ', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.palette, color: Colors.white54),
                  title: const Text('テーマ'),
                  subtitle: Text(
                    'ダーク',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white38),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading:
                      const Icon(Icons.info_outline, color: Colors.white54),
                  title: const Text('バージョン'),
                  subtitle: Text(
                    '1.0.0',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
