import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/editor_state.dart';

/// 리사이즈 패널
class ResizeControl extends ConsumerWidget {
  const ResizeControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorStateProvider);
    final notifier = ref.read(editorStateProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 종횡비 섹션
          const Text(
            '종횡비',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // 종횡비 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: aspectRatioOptions.map((option) {
              final id = option['id'] as String;
              final name = option['name'] as String;
              final isSelected = editorState.aspectRatio == id;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _AspectRatioButton(
                    label: name,
                    id: id,
                    isSelected: isSelected,
                    onTap: () => notifier.setAspectRatio(id),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 해상도 섹션
          const Text(
            '해상도',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // 해상도 버튼들
          Column(
            children: resolutionOptions.map((option) {
              final id = option['id'] as String;
              final name = option['name'] as String;
              final width = option['width'] as int?;
              final isSelected = editorState.resolution == id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ResolutionButton(
                  label: name,
                  width: width,
                  isSelected: isSelected,
                  onTap: () => notifier.setResolution(id),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // 설명 텍스트
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '종횡비와 해상도를 조절하여 용도에 맞게 최적화하세요.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 종횡비 버튼
class _AspectRatioButton extends StatelessWidget {
  final String label;
  final String id;
  final bool isSelected;
  final VoidCallback onTap;

  const _AspectRatioButton({
    required this.label,
    required this.id,
    required this.isSelected,
    required this.onTap,
  });

  Widget _buildRatioIcon() {
    switch (id) {
      case '1:1':
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.white : Colors.black87,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      case '4:3':
        return Container(
          width: 28,
          height: 21,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.white : Colors.black87,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      case '16:9':
        return Container(
          width: 32,
          height: 18,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.white : Colors.black87,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      default:
        return Icon(
          Icons.crop_free,
          color: isSelected ? Colors.white : Colors.black87,
          size: 24,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRatioIcon(),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 해상도 버튼
class _ResolutionButton extends StatelessWidget {
  final String label;
  final int? width;
  final bool isSelected;
  final VoidCallback onTap;

  const _ResolutionButton({
    required this.label,
    required this.width,
    required this.isSelected,
    required this.onTap,
  });

  String _getDescription() {
    if (width == null) return '원본 크기 유지';
    if (width! >= 2048) return '고해상도 (${width}px 너비)';
    if (width! >= 1920) return 'Full HD (${width}px 너비)';
    return 'HD (${width}px 너비)';
  }

  IconData _getIcon() {
    if (width == null) return Icons.photo_size_select_actual;
    if (width! >= 2048) return Icons.high_quality;
    if (width! >= 1920) return Icons.hd;
    return Icons.sd;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIcon(),
                color: isSelected ? Colors.white : Colors.black87,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getDescription(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
