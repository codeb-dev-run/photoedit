import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/editor_state.dart';

/// 필터 선택 패널
class FilterSelector extends ConsumerWidget {
  const FilterSelector({super.key});

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
          // 헤더
          const Text(
            '필름 필터',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 필터 목록 (가로 스크롤)
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // 필터 없음
                _FilterThumbnail(
                  filterId: null,
                  filterName: '없음',
                  isSelected: editorState.selectedFilter == null,
                  onTap: () => notifier.selectFilter(null),
                ),
                const SizedBox(width: 12),
                // 필터 목록
                ...availableFilters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _FilterThumbnail(
                      filterId: filter['id'] as String,
                      filterName: filter['name'] as String,
                      isSelected: editorState.selectedFilter == filter['id'],
                      onTap: () => notifier.selectFilter(filter['id'] as String),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 필터 강도 조절 (필터가 선택된 경우에만 표시)
          if (editorState.selectedFilter != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '필터 강도',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${(editorState.filterIntensity * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: Theme.of(context).primaryColor,
                overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                trackHeight: 4,
              ),
              child: Slider(
                value: editorState.filterIntensity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                onChanged: (value) {
                  notifier.setFilterIntensity(value);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],

          // 설명 텍스트
          Text(
            editorState.selectedFilter == null
                ? '레트로 필름 느낌의 컬러 필터를 선택하세요.'
                : '필터 강도를 조절하여 원하는 분위기를 만드세요.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 필터 썸네일
class _FilterThumbnail extends StatelessWidget {
  final String? filterId;
  final String filterName;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterThumbnail({
    required this.filterId,
    required this.filterName,
    required this.isSelected,
    required this.onTap,
  });

  Color _getFilterColor() {
    switch (filterId) {
      case 'vintage':
        return Colors.orange.shade200;
      case 'blackwhite':
        return Colors.grey.shade400;
      case 'sepia':
        return Colors.brown.shade200;
      case 'cool':
        return Colors.blue.shade200;
      case 'warm':
        return Colors.amber.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  IconData _getFilterIcon() {
    switch (filterId) {
      case 'vintage':
        return Icons.camera_alt;
      case 'blackwhite':
        return Icons.filter_b_and_w;
      case 'sepia':
        return Icons.wb_sunny_outlined;
      case 'cool':
        return Icons.ac_unit;
      case 'warm':
        return Icons.wb_incandescent;
      default:
        return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _getFilterColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              _getFilterIcon(),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filterName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
