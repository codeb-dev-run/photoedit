import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/batch_progress.dart';
import '../../core/models/preset.dart';
import '../../core/services/preset_service.dart';
import 'batch_processor.dart';

/// 일괄 처리 상태 Provider
final batchStateProvider = StateNotifierProvider<BatchStateNotifier, BatchState>((ref) {
  return BatchStateNotifier();
});

class BatchState {
  final List<String> selectedImages;
  final String? selectedPresetId;
  final BatchProgress? progress;
  final BatchResult? result;
  final bool isProcessing;

  const BatchState({
    this.selectedImages = const [],
    this.selectedPresetId,
    this.progress,
    this.result,
    this.isProcessing = false,
  });

  BatchState copyWith({
    List<String>? selectedImages,
    String? selectedPresetId,
    BatchProgress? progress,
    BatchResult? result,
    bool? isProcessing,
  }) {
    return BatchState(
      selectedImages: selectedImages ?? this.selectedImages,
      selectedPresetId: selectedPresetId ?? this.selectedPresetId,
      progress: progress ?? this.progress,
      result: result ?? this.result,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class BatchStateNotifier extends StateNotifier<BatchState> {
  BatchStateNotifier() : super(const BatchState());

  BatchProcessor? _processor;

  void setSelectedImages(List<String> images) {
    state = state.copyWith(selectedImages: images);
  }

  void setSelectedPreset(String? presetId) {
    state = state.copyWith(selectedPresetId: presetId);
  }

  void removeImage(String path) {
    final images = List<String>.from(state.selectedImages);
    images.remove(path);
    state = state.copyWith(selectedImages: images);
  }

  void clearImages() {
    state = state.copyWith(selectedImages: []);
  }

  Future<void> startProcessing(PresetSettings settings) async {
    if (state.selectedImages.isEmpty) return;

    _processor = BatchProcessor(
      imagePaths: state.selectedImages,
      settings: settings,
    );

    state = state.copyWith(isProcessing: true);

    _processor!.progressStream.listen((progress) {
      state = state.copyWith(progress: progress);
    });

    final result = await _processor!.process();
    state = state.copyWith(
      result: result,
      isProcessing: false,
    );
  }

  void cancelProcessing() {
    _processor?.cancel();
    state = state.copyWith(isProcessing: false);
  }

  void reset() {
    state = const BatchState();
  }
}

/// 일괄 처리 화면
class BatchScreen extends ConsumerWidget {
  const BatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchStateProvider);
    final presetsAsync = ref.watch(presetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('일괄 처리'),
        actions: [
          if (state.selectedImages.isNotEmpty && !state.isProcessing)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                ref.read(batchStateProvider.notifier).clearImages();
              },
              tooltip: '전체 삭제',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: presetsAsync.when(
              data: (presets) => _PresetSelector(
                presets: presets,
                selectedId: state.selectedPresetId,
                onSelected: (presetId) {
                  ref.read(batchStateProvider.notifier).setSelectedPreset(presetId);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('에러: $error'),
            ),
          ),
          const Divider(),
          Expanded(
            child: state.selectedImages.isEmpty
                ? _EmptyState(
                    onSelectImages: () => _pickImages(context, ref),
                  )
                : _ImageGrid(
                    images: state.selectedImages,
                    onRemove: (path) {
                      ref.read(batchStateProvider.notifier).removeImage(path);
                    },
                  ),
          ),
          if (state.progress != null && state.isProcessing)
            _ProgressIndicator(progress: state.progress!),
          if (state.result != null && !state.isProcessing)
            _ResultCard(result: state.result!),
          _BottomActions(
            hasImages: state.selectedImages.isNotEmpty,
            hasPreset: state.selectedPresetId != null,
            isProcessing: state.isProcessing,
            onSelectImages: () => _pickImages(context, ref),
            onStart: () => _startProcessing(context, ref),
            onCancel: () {
              ref.read(batchStateProvider.notifier).cancelProcessing();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      ref.read(batchStateProvider.notifier).setSelectedImages(
            images.map((img) => img.path).toList(),
          );
    }
  }

  Future<void> _startProcessing(BuildContext context, WidgetRef ref) async {
    final state = ref.read(batchStateProvider);
    if (state.selectedPresetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프리셋을 선택해주세요')),
      );
      return;
    }
    final presetService = ref.read(presetServiceProvider);
    final preset = await presetService.getPresetById(state.selectedPresetId!);
    if (preset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프리셋을 찾을 수 없습니다')),
      );
      return;
    }
    await ref.read(batchStateProvider.notifier).startProcessing(preset.settings);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일괄 처리가 완료되었습니다')),
      );
    }
  }
}

class _PresetSelector extends StatelessWidget {
  final List<Preset> presets;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const _PresetSelector({
    required this.presets,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          hint: const Text('프리셋 선택'),
          isExpanded: true,
          items: presets.map((preset) {
            return DropdownMenuItem<String>(
              value: preset.id,
              child: Row(
                children: [
                  Icon(
                    preset.isDefault ? Icons.photo_filter : Icons.favorite,
                    size: 20,
                    color: preset.isDefault ? Colors.blue : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(preset.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (preset.description != null)
                          Text(preset.description!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onSelected,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onSelectImages;
  const _EmptyState({required this.onSelectImages});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('이미지를 선택해주세요', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onSelectImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('이미지 선택'),
          ),
        ],
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final List<String> images;
  final ValueChanged<String> onRemove;
  const _ImageGrid({required this.images, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('선택된 이미지: ${images.length}장', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imagePath = images[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(imagePath), fit: BoxFit.cover)),
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(imagePath),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  const Positioned(bottom: 4, right: 4, child: Icon(Icons.check_circle, color: Colors.green, size: 20)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final BatchProgress progress;
  const _ProgressIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.shade50, border: Border(top: BorderSide(color: Colors.grey.shade300))),
      child: Column(
        children: [
          LinearProgressIndicator(value: progress.progress, minHeight: 8),
          const SizedBox(height: 8),
          Text('처리 중: ${progress.completed}/${progress.total}', style: const TextStyle(fontWeight: FontWeight.bold)),
          if (progress.currentFileName != null)
            Text(progress.currentFileName!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final BatchResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.hasErrors ? Colors.orange.shade50 : Colors.green.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ResultItem(icon: Icons.check_circle, label: '성공', value: result.successCount.toString(), color: Colors.green),
          _ResultItem(icon: Icons.error, label: '실패', value: result.failedCount.toString(), color: Colors.red),
          _ResultItem(icon: Icons.timer, label: '소요 시간', value: '${result.duration.inSeconds}초', color: Colors.blue),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _ResultItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool hasImages;
  final bool hasPreset;
  final bool isProcessing;
  final VoidCallback onSelectImages;
  final VoidCallback onStart;
  final VoidCallback onCancel;

  const _BottomActions({
    required this.hasImages,
    required this.hasPreset,
    required this.isProcessing,
    required this.onSelectImages,
    required this.onStart,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (!hasImages)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onSelectImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('이미지 선택'),
              ),
            )
          else if (isProcessing)
            Expanded(child: OutlinedButton(onPressed: onCancel, child: const Text('취소')))
          else ...[
            Expanded(child: OutlinedButton.icon(onPressed: onSelectImages, icon: const Icon(Icons.add), label: const Text('이미지 추가'))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: ElevatedButton(onPressed: hasPreset ? onStart : null, child: const Text('일괄 처리 시작'))),
          ],
        ],
      ),
    );
  }
}
