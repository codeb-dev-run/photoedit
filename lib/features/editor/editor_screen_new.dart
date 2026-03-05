import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'controllers/editor_state.dart';
import 'widgets/blur_control.dart';
import 'widgets/filter_selector.dart';
import 'widgets/grain_control.dart';
import 'widgets/resize_control.dart';

/// 에디터 메인 화면
class EditorScreen extends ConsumerStatefulWidget {
  final File imageFile;

  const EditorScreen({
    super.key,
    required this.imageFile,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  @override
  void initState() {
    super.initState();
    // 이미지 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editorStateProvider.notifier).loadImage(widget.imageFile);
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorStateProvider);
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _handleBack(context),
        ),
        title: const Text(
          '편집',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // 저장 버튼
          TextButton.icon(
            onPressed: editorState.isProcessing ? null : () => _handleSave(),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              '저장',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 이미지 미리보기 영역
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Center(
                child: _buildImagePreview(editorState),
              ),
            ),
          ),

          // 탭 버튼 영역
          Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton(
                  icon: Icons.blur_on,
                  label: '블러',
                  tab: EditorTab.blur,
                  isSelected: selectedTab == EditorTab.blur,
                ),
                _buildTabButton(
                  icon: Icons.filter,
                  label: '필터',
                  tab: EditorTab.filter,
                  isSelected: selectedTab == EditorTab.filter,
                ),
                _buildTabButton(
                  icon: Icons.grain,
                  label: '그레인',
                  tab: EditorTab.grain,
                  isSelected: selectedTab == EditorTab.grain,
                ),
                _buildTabButton(
                  icon: Icons.crop,
                  label: '리사이즈',
                  tab: EditorTab.resize,
                  isSelected: selectedTab == EditorTab.resize,
                ),
              ],
            ),
          ),

          // 조절 패널 영역
          Expanded(
            flex: 2,
            child: _buildControlPanel(selectedTab),
          ),

          // 하단 액션 버튼 영역
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: OutlinedButton(
                      onPressed: editorState.isProcessing
                          ? null
                          : () => _handleReset(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '초기화',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 프리셋 저장 버튼
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: editorState.isProcessing || !editorState.hasEdits
                          ? null
                          : () => _handleSavePreset(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Theme.of(context).primaryColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.bookmark, color: Colors.white),
                      label: const Text(
                        '프리셋 저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
  }

  /// 이미지 미리보기
  Widget _buildImagePreview(EditorState state) {
    if (state.imageFile == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      children: [
        // 이미지
        Center(
          child: Image.file(
            state.imageFile!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
              );
            },
          ),
        ),

        // 처리 중 오버레이
        if (state.isProcessing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // 편집 정보 표시
        if (state.hasEdits)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '편집됨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 탭 버튼
  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required EditorTab tab,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(selectedTabProvider.notifier).state = tab;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 조절 패널
  Widget _buildControlPanel(EditorTab tab) {
    switch (tab) {
      case EditorTab.blur:
        return const BlurControl();
      case EditorTab.filter:
        return const FilterSelector();
      case EditorTab.grain:
        return const GrainControl();
      case EditorTab.resize:
        return const ResizeControl();
    }
  }

  /// 뒤로가기 처리
  void _handleBack(BuildContext context) {
    final editorState = ref.read(editorStateProvider);

    if (editorState.hasEdits) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('편집 내용을 버리시겠습니까?'),
          content: const Text('저장하지 않은 변경사항은 사라집니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 에디터 화면 닫기
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('버리기'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  /// 저장 처리
  void _handleSave() {
    final editorState = ref.read(editorStateProvider);

    if (editorState.imageFile == null) return;

    // TODO: 실제 이미지 처리 및 저장 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('이미지를 저장했습니다.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // 잠시 후 화면 닫기
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context, editorState.imageFile);
      }
    });
  }

  /// 초기화 처리
  void _handleReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('편집 내용 초기화'),
        content: const Text('모든 편집 내용을 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(editorStateProvider.notifier).reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('편집 내용이 초기화되었습니다.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  /// 프리셋 저장 처리
  void _handleSavePreset() {
    final editorState = ref.read(editorStateProvider);

    showDialog(
      context: context,
      builder: (context) {
        String presetName = '';
        return AlertDialog(
          title: const Text('프리셋 저장'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('현재 편집 설정을 프리셋으로 저장합니다.'),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '프리셋 이름',
                  hintText: '예: 내 빈티지 스타일',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => presetName = value,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '저장될 설정:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 블러: ${(editorState.blurIntensity * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '• 필터: ${editorState.selectedFilter ?? "없음"}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (editorState.selectedFilter != null)
                      Text(
                        '  강도: ${(editorState.filterIntensity * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    Text(
                      '• 그레인: ${(editorState.grainIntensity * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (presetName.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('프리셋 이름을 입력해주세요.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // TODO: 실제 프리셋 저장 로직 구현
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('프리셋 "$presetName"이(가) 저장되었습니다.'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }
}
