import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/photo_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photoListProvider);
    final cameras =
        photos.map((p) => p.cameraModel).toSet().toList();
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
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.cloud_upload, color: Colors.white54),
                  title: const Text('データのバックアップ'),
                  subtitle: Text(
                    '撮影データをエクスポート',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white38),
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
