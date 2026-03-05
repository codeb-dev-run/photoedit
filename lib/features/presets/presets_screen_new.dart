import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/preset.dart';
import '../../core/services/preset_service.dart';
import 'widgets/preset_card.dart';
import 'widgets/preset_editor_dialog.dart';

class PresetsScreen extends ConsumerWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultPresets = ref.watch(defaultPresetsProvider);
    final userPresetsAsync = ref.watch(userPresetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프리셋 관리'),
        actions: [
          // 프리셋 추가 버튼 (상단)
          TextButton.icon(
            onPressed: () => _showCreatePresetDialog(context, ref),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('추가', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () => _showHelp(context), tooltip: '도움말'),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(userPresetsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: '기본 프리셋', subtitle: '${defaultPresets.length}개', icon: Icons.photo_filter),
              _PresetGrid(
                presets: defaultPresets,
                onTap: (preset) => _showPresetDetails(context, preset),
                onLongPress: (preset) => _showPresetActions(context, ref, preset),
              ),
              const Divider(height: 32),
              _SectionHeader(
                title: '내 프리셋',
                subtitle: userPresetsAsync.maybeWhen(data: (presets) => '${presets.length}개', orElse: () => ''),
                icon: Icons.favorite,
              ),
              userPresetsAsync.when(
                data: (presets) {
                  if (presets.isEmpty) return const _EmptyUserPresets();
                  return _PresetGrid(
                    presets: presets,
                    showAddButton: true,
                    onTap: (preset) => _showPresetDetails(context, preset),
                    onLongPress: (preset) => _showPresetActions(context, ref, preset),
                    onAddPressed: () => _showCreatePresetDialog(context, ref),
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
                error: (error, stack) => Padding(padding: const EdgeInsets.all(16.0), child: Text('에러: $error')),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePresetDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('새 프리셋'),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리셋 사용 방법'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📱 탭: 프리셋 상세 보기', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('길게 눌러서 다음 작업을 할 수 있습니다:'),
              SizedBox(height: 8),
              Text('✏️ 편집: 프리셋 설정 수정'),
              Text('🗑️ 삭제: 프리셋 삭제 (사용자 프리셋만)'),
              Text('📤 공유: 프리셋을 친구와 공유'),
              Text('📋 복제: 프리셋 복사본 만들기'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
      ),
    );
  }

  void _showPresetDetails(BuildContext context, Preset preset) {
    showDialog(context: context, builder: (context) => _PresetDetailsDialog(preset: preset));
  }

  void _showPresetActions(BuildContext context, WidgetRef ref, Preset preset) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PresetActionsSheet(
        preset: preset,
        onEdit: preset.isDefault ? null : () {
          Navigator.pop(context);
          _showEditPresetDialog(context, ref, preset);
        },
        onDelete: preset.isDefault ? null : () async {
          Navigator.pop(context);
          await _deletePreset(context, ref, preset);
        },
        onShare: () {
          Navigator.pop(context);
          _sharePreset(context, ref, preset);
        },
        onDuplicate: () async {
          Navigator.pop(context);
          await _duplicatePreset(context, ref, preset);
        },
      ),
    );
  }

  void _showCreatePresetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => PresetEditorDialog(
        onSave: (name, description, settings) async {
          try {
            final service = ref.read(presetServiceProvider);
            await service.savePreset(name: name, description: description, settings: settings);
            ref.invalidate(userPresetsProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프리셋이 생성되었습니다')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러: $e')));
            }
          }
        },
      ),
    );
  }

  void _showEditPresetDialog(BuildContext context, WidgetRef ref, Preset preset) {
    showDialog(
      context: context,
      builder: (context) => PresetEditorDialog(
        preset: preset,
        onSave: (name, description, settings) async {
          try {
            final service = ref.read(presetServiceProvider);
            await service.updatePreset(preset.id, name: name, description: description, settings: settings);
            ref.invalidate(userPresetsProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프리셋이 수정되었습니다')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러: $e')));
            }
          }
        },
      ),
    );
  }

  Future<void> _deletePreset(BuildContext context, WidgetRef ref, Preset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리셋 삭제'),
        content: Text('${preset.name} 프리셋을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = ref.read(presetServiceProvider);
        await service.deletePreset(preset.id);
        ref.invalidate(userPresetsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프리셋이 삭제되었습니다')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러: $e')));
        }
      }
    }
  }

  void _sharePreset(BuildContext context, WidgetRef ref, Preset preset) {
    try {
      final service = ref.read(presetServiceProvider);
      final jsonString = service.exportPreset(preset);
      Share.share(jsonString, subject: '${preset.name} 프리셋');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러: $e')));
    }
  }

  Future<void> _duplicatePreset(BuildContext context, WidgetRef ref, Preset preset) async {
    try {
      final service = ref.read(presetServiceProvider);
      await service.duplicatePreset(preset.id);
      ref.invalidate(userPresetsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프리셋이 복제되었습니다')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러: $e')));
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _SectionHeader({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _PresetGrid extends StatelessWidget {
  final List<Preset> presets;
  final bool showAddButton;
  final ValueChanged<Preset>? onTap;
  final ValueChanged<Preset>? onLongPress;
  final VoidCallback? onAddPressed;

  const _PresetGrid({
    required this.presets,
    this.showAddButton = false,
    this.onTap,
    this.onLongPress,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = showAddButton ? presets.length + 1 : presets.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (showAddButton && index == presets.length) {
          return _AddPresetCard(onPressed: onAddPressed);
        }
        final preset = presets[index];
        return PresetCard(
          preset: preset,
          onTap: onTap != null ? () => onTap!(preset) : null,
          onLongPress: onLongPress != null ? () => onLongPress!(preset) : null,
        );
      },
    );
  }
}

class _EmptyUserPresets extends StatelessWidget {
  const _EmptyUserPresets();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('저장된 프리셋이 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('+ 버튼을 눌러 새 프리셋을 만들어보세요', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _AddPresetCard extends StatelessWidget {
  final VoidCallback? onPressed;
  const _AddPresetCard({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 48, color: Colors.blue.shade300),
            const SizedBox(height: 8),
            Text('새 프리셋', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
          ],
        ),
      ),
    );
  }
}

class _PresetDetailsDialog extends StatelessWidget {
  final Preset preset;
  const _PresetDetailsDialog({required this.preset});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(preset.isDefault ? Icons.photo_filter : Icons.favorite, color: preset.isDefault ? Colors.blue : Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(preset.name)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (preset.description != null) ...[
              Text(preset.description!, style: TextStyle(color: Colors.grey.shade600)),
              const Divider(height: 24),
            ],
            _SettingItem(label: '밝기', value: preset.settings.brightness),
            _SettingItem(label: '대비', value: preset.settings.contrast),
            _SettingItem(label: '채도', value: preset.settings.saturation),
            _SettingItem(label: '블러', value: preset.settings.blur),
            _SettingItem(label: '그레인', value: preset.settings.grain),
            const SizedBox(height: 8),
            Text('필름 필터: ${preset.settings.filmFilter.displayName}'),
            if (preset.settings.tintColor != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('틴트 컬러: '),
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: preset.settings.tintColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(preset.settings.tintOpacity * 100).toInt()}%'),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기'))],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String label;
  final double value;
  const _SettingItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final displayValue = value >= 0 ? '+${(value * 100).toInt()}' : '${(value * 100).toInt()}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(displayValue, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PresetActionsSheet extends StatelessWidget {
  final Preset preset;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onDuplicate;

  const _PresetActionsSheet({required this.preset, this.onEdit, this.onDelete, this.onShare, this.onDuplicate});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(preset.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          if (onEdit != null) ListTile(leading: const Icon(Icons.edit), title: const Text('편집'), onTap: onEdit),
          if (onDelete != null)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: onDelete,
            ),
          if (onShare != null) ListTile(leading: const Icon(Icons.share), title: const Text('공유'), onTap: onShare),
          if (onDuplicate != null) ListTile(leading: const Icon(Icons.content_copy), title: const Text('복제'), onTap: onDuplicate),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
