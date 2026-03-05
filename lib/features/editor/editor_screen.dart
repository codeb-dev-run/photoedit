import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_theme.dart';
import 'controllers/editor_state.dart';

/// 블러 색상 옵션
const blurColorOptions = [
  {'name': '없음', 'color': Color(0x00000000)},
  {'name': '검정', 'color': Color(0x80000000)},
  {'name': '흰색', 'color': Color(0x80FFFFFF)},
  {'name': '빨강', 'color': Color(0x80FF0000)},
  {'name': '파랑', 'color': Color(0x800000FF)},
  {'name': '노랑', 'color': Color(0x80FFFF00)},
  {'name': '초록', 'color': Color(0x8000FF00)},
  {'name': '보라', 'color': Color(0x80800080)},
];

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final GlobalKey _imageKey = GlobalKey();
  Size? _imageDisplaySize;

  @override
  Widget build(BuildContext context) {
    final imagePath = GoRouterState.of(context).extra as String?;

    if (imagePath == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text('편집')),
        body: const Center(child: Text('이미지가 선택되지 않았습니다.')),
      );
    }

    final imageFile = File(imagePath);
    final editorState = ref.watch(editorStateProvider);
    final selectedTab = ref.watch(selectedTabProvider);

    if (editorState.imageFile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(editorStateProvider.notifier).loadImage(imageFile);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref, editorState),
            Expanded(
              child: _buildImagePreview(context, ref, editorState, selectedTab),
            ),
            _buildBottomPanel(context, ref, selectedTab, editorState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, EditorState editorState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LumeraIconButton(
            icon: Icons.arrow_back,
            onTap: () => context.pop(),
          ),
          const Text(
            '사진 편집',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          _LumeraIconButton(
            icon: Icons.check,
            filled: true,
            onTap: editorState.isProcessing ? null : () => _showExportDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(
    BuildContext context,
    WidgetRef ref,
    EditorState editorState,
    EditorTab selectedTab,
  ) {
    final colorFilter = getColorFilterMatrix(
      editorState.selectedFilter,
      editorState.filterIntensity,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            key: _imageKey,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 이미지 + 필터 적용
                  if (editorState.imageFile != null)
                    ColorFiltered(
                      colorFilter: colorFilter ?? const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.dst,
                      ),
                      child: Image.file(
                        editorState.imageFile!,
                        fit: BoxFit.contain,
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (frame != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _updateImageSize();
                            });
                          }
                          return child;
                        },
                      ),
                    )
                  else
                    Container(
                      color: AppTheme.surfaceColor,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryColor),
                      ),
                    ),

                  // 그레인 오버레이
                  if (editorState.grainIntensity > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: GrainPainter(
                            intensity: editorState.grainIntensity,
                          ),
                        ),
                      ),
                    ),

                  // 블러 영역 오버레이 (블러 탭에서만)
                  if (selectedTab == EditorTab.blur && editorState.isBlurEnabled)
                    _buildBlurOverlay(context, ref, editorState, constraints),

                  // 필터 이름 오버레이
                  if (editorState.selectedFilter != null)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            availableFilters.firstWhere(
                              (f) => f['id'] == editorState.selectedFilter,
                              orElse: () => {'name': ''},
                            )['name'] as String,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateImageSize() {
    final renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _imageDisplaySize = renderBox.size;
      });
    }
  }

  Widget _buildBlurOverlay(
    BuildContext context,
    WidgetRef ref,
    EditorState editorState,
    BoxConstraints constraints,
  ) {
    final containerSize = Size(constraints.maxWidth, constraints.maxHeight);
    final region = editorState.blurRegion;
    final rect = region.toRect(containerSize);
    final isCircle = region.shape == BlurShape.circle;
    final blurSigma = editorState.blurIntensity * 25; // 0~25 sigma
    final feather = region.opacity; // opacity를 페더(퍼짐) 정도로 사용

    return Stack(
      children: [
        // 바깥쪽 블러 영역 (원형 안쪽은 제외)
        Positioned.fill(
          child: ClipPath(
            clipper: _InvertedShapeClipper(
              rect: rect,
              isCircle: isCircle,
              feather: feather,
            ),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: Container(
                color: region.color.alpha > 0
                    ? region.color.withOpacity(0.3)
                    : Colors.white.withOpacity(0.0),
              ),
            ),
          ),
        ),

        // 페더(퍼짐) 효과 - 그라데이션 마스크
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _BlurFeatherPainter(
                rect: rect,
                isCircle: isCircle,
                feather: feather,
                color: region.color.alpha > 0 ? region.color : Colors.white,
                blurIntensity: editorState.blurIntensity,
              ),
            ),
          ),
        ),

        // 선명 영역 테두리 + 드래그
        Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: GestureDetector(
            onPanUpdate: (details) {
              ref.read(editorStateProvider.notifier).moveBlurRegion(
                details.delta,
                containerSize,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isCircle ? null : BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),

        // 리사이즈 핸들들
        ..._buildResizeHandles(ref, rect, containerSize, isCircle),
      ],
    );
  }

  List<Widget> _buildResizeHandles(
    WidgetRef ref,
    Rect rect,
    Size containerSize,
    bool isCircle,
  ) {
    const handleSize = 28.0;

    if (isCircle) {
      // 원형: 4방향 핸들
      final positions = [
        Offset(rect.center.dx - handleSize / 2, rect.top - handleSize / 2), // top
        Offset(rect.right - handleSize / 2, rect.center.dy - handleSize / 2), // right
        Offset(rect.center.dx - handleSize / 2, rect.bottom - handleSize / 2), // bottom
        Offset(rect.left - handleSize / 2, rect.center.dy - handleSize / 2), // left
      ];

      return List.generate(4, (index) {
        return Positioned(
          left: positions[index].dx,
          top: positions[index].dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              _handleCircleResize(ref, details.delta, containerSize, index);
            },
            child: _buildHandleWidget(handleSize),
          ),
        );
      });
    } else {
      // 사각형: 4 코너 핸들
      return _buildCornerHandles(ref, rect, containerSize);
    }
  }

  void _handleCircleResize(
    WidgetRef ref,
    Offset delta,
    Size containerSize,
    int handleIndex,
  ) {
    final editorState = ref.read(editorStateProvider);
    final current = editorState.blurRegion;

    double deltaSize = 0;
    switch (handleIndex) {
      case 0: // top
        deltaSize = -delta.dy / containerSize.height;
        break;
      case 1: // right
        deltaSize = delta.dx / containerSize.width;
        break;
      case 2: // bottom
        deltaSize = delta.dy / containerSize.height;
        break;
      case 3: // left
        deltaSize = -delta.dx / containerSize.width;
        break;
    }

    final newSize = (current.size.width + deltaSize).clamp(0.08, 0.8);
    ref.read(editorStateProvider.notifier).setBlurRegion(
      current.copyWith(size: Size(newSize, newSize)),
    );
  }

  Widget _buildHandleWidget(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.open_with,
        size: 14,
        color: AppTheme.primaryColor,
      ),
    );
  }

  List<Widget> _buildCornerHandles(WidgetRef ref, Rect rect, Size containerSize) {
    const handleSize = 28.0;
    final positions = [
      Offset(rect.left - handleSize / 2, rect.top - handleSize / 2), // top-left
      Offset(rect.right - handleSize / 2, rect.top - handleSize / 2), // top-right
      Offset(rect.right - handleSize / 2, rect.bottom - handleSize / 2), // bottom-right
      Offset(rect.left - handleSize / 2, rect.bottom - handleSize / 2), // bottom-left
    ];

    return List.generate(4, (index) {
      return Positioned(
        left: positions[index].dx,
        top: positions[index].dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            ref.read(editorStateProvider.notifier).resizeBlurRegion(
              details.delta,
              containerSize,
              index,
            );
          },
          child: _buildHandleWidget(handleSize),
        ),
      );
    });
  }

  Widget _buildBottomPanel(
    BuildContext context,
    WidgetRef ref,
    EditorTab selectedTab,
    EditorState editorState,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabs(ref, selectedTab),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: _buildControlPanel(context, ref, selectedTab, editorState),
          ),
          const SizedBox(height: 24),
          _buildActionButtons(context, ref, editorState),
        ],
      ),
    );
  }

  Widget _buildTabs(WidgetRef ref, EditorTab selectedTab) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab(ref, '블러', EditorTab.blur, selectedTab == EditorTab.blur),
          _buildTab(ref, '필터', EditorTab.filter, selectedTab == EditorTab.filter),
          _buildTab(ref, '그레인', EditorTab.grain, selectedTab == EditorTab.grain),
        ],
      ),
    );
  }

  Widget _buildTab(WidgetRef ref, String label, EditorTab tab, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(selectedTabProvider.notifier).state = tab,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(
    BuildContext context,
    WidgetRef ref,
    EditorTab selectedTab,
    EditorState editorState,
  ) {
    switch (selectedTab) {
      case EditorTab.blur:
        return _buildBlurPanel(ref, editorState);
      case EditorTab.filter:
        return _buildFilterPanel(ref, editorState);
      case EditorTab.grain:
        return _buildGrainPanel(ref, editorState);
      case EditorTab.resize:
        return _buildResizePanel(ref, editorState);
    }
  }

  Widget _buildBlurPanel(WidgetRef ref, EditorState editorState) {
    final region = editorState.blurRegion;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 활성화 토글 + 모양 선택
          Row(
            children: [
              // 활성화 토글
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      '블러 스티커',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: editorState.isBlurEnabled,
                      onChanged: (value) {
                        ref.read(editorStateProvider.notifier).toggleBlur(value);
                      },
                      activeColor: AppTheme.primaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              // 모양 선택
              _buildShapeToggle(ref, region.shape),
            ],
          ),
          const SizedBox(height: 12),

          // 블러 강도 슬라이더
          _LumeraSlider(
            label: '블러 강도',
            value: editorState.blurIntensity,
            onChanged: editorState.isBlurEnabled
                ? (value) {
                    ref.read(editorStateProvider.notifier).setBlurIntensity(value);
                  }
                : null,
          ),
          const SizedBox(height: 8),

          // 퍼짐(페더) 슬라이더
          _LumeraSlider(
            label: '경계 퍼짐',
            value: region.opacity,
            onChanged: editorState.isBlurEnabled
                ? (value) {
                    ref.read(editorStateProvider.notifier).setBlurOpacity(value);
                  }
                : null,
          ),
          const SizedBox(height: 8),

          // 색상 선택
          _buildColorSelector(ref, region.color, editorState.isBlurEnabled),
        ],
      ),
    );
  }

  Widget _buildShapeToggle(WidgetRef ref, BlurShape currentShape) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShapeButton(
            ref,
            Icons.circle_outlined,
            BlurShape.circle,
            currentShape == BlurShape.circle,
          ),
          const SizedBox(width: 4),
          _buildShapeButton(
            ref,
            Icons.rectangle_outlined,
            BlurShape.rectangle,
            currentShape == BlurShape.rectangle,
          ),
        ],
      ),
    );
  }

  Widget _buildShapeButton(
    WidgetRef ref,
    IconData icon,
    BlurShape shape,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => ref.read(editorStateProvider.notifier).setBlurShape(shape),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppTheme.textMuted,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildColorSelector(WidgetRef ref, Color currentColor, bool enabled) {
    return Row(
      children: [
        const Text(
          '색상',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: blurColorOptions.map((option) {
                final color = option['color'] as Color;
                final isSelected = currentColor.value == color.value;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: enabled
                        ? () => ref.read(editorStateProvider.notifier).setBlurColor(color)
                        : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.alpha == 0 ? Colors.white : color.withOpacity(1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: color.alpha == 0
                          ? const Icon(Icons.block, size: 16, color: Colors.grey)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPanel(WidgetRef ref, EditorState editorState) {
    return Column(
      children: [
        SizedBox(
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(ref, editorState, null, 'None'),
              ...availableFilters.map((filter) {
                return _buildFilterChip(
                  ref,
                  editorState,
                  filter['id'] as String,
                  filter['name'] as String,
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _LumeraSlider(
          label: '필터 강도',
          value: editorState.filterIntensity,
          onChanged: editorState.selectedFilter != null
              ? (value) {
                  ref.read(editorStateProvider.notifier).setFilterIntensity(value);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    EditorState editorState,
    String? filterId,
    String filterName,
  ) {
    final isSelected = editorState.selectedFilter == filterId;
    final colorFilter = getColorFilterMatrix(filterId, 1.0);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          ref.read(editorStateProvider.notifier).selectFilter(filterId);
        },
        child: Container(
          width: 64,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ColorFiltered(
                    colorFilter: colorFilter ?? const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.dst,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[200]!, Colors.blue[200]!],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                filterName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrainPanel(WidgetRef ref, EditorState editorState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LumeraSlider(
          label: '그레인 강도',
          value: editorState.grainIntensity,
          onChanged: (value) {
            ref.read(editorStateProvider.notifier).setGrainIntensity(value);
          },
        ),
        const SizedBox(height: 12),
        Text(
          '그레인 효과로 필름 같은 질감을 추가합니다.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppTheme.textMuted.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildResizePanel(WidgetRef ref, EditorState editorState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '비율 선택',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: aspectRatioOptions.map((option) {
              final id = option['id'] as String;
              final name = option['name'] as String;
              final isSelected = editorState.aspectRatio == id;

              return ChoiceChip(
                label: Text(name),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(editorStateProvider.notifier).setAspectRatio(id);
                  }
                },
                selectedColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.backgroundColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                  fontFamily: 'Inter',
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    EditorState editorState,
  ) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: editorState.isProcessing
                ? null
                : () => ref.read(editorStateProvider.notifier).reset(),
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: editorState.isProcessing ? null : () => _savePreset(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.bookmark_outline, size: 20),
              label: const Text(
                '프리셋 저장',
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: editorState.isProcessing ? null : () => _showExportDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceColor,
                foregroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.backgroundColor),
                ),
              ),
              icon: const Icon(Icons.download_outlined, size: 20),
              label: const Text(
                '내보내기',
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _savePreset(BuildContext context, WidgetRef ref) {
    final editorState = ref.read(editorStateProvider);

    if (!editorState.hasEdits) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장할 편집 내용이 없습니다.'), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('프리셋 저장'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: '프리셋 이름',
              hintText: '예: 빈티지 따뜻한 톤',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('프리셋 이름을 입력하세요.'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('프리셋 "${controller.text}"이 저장되었습니다.'),
                    backgroundColor: Colors.green,
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

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '내보내기',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            _ExportButton(
              label: '갤러리에 저장',
              icon: Icons.photo_library_outlined,
              filled: true,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이미지가 저장되었습니다.'), backgroundColor: Colors.green),
                );
              },
            ),
            const SizedBox(height: 12),
            _ExportButton(
              label: '공유하기',
              icon: Icons.share_outlined,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Lumera 아이콘 버튼
class _LumeraIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  const _LumeraIconButton({required this.icon, this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: filled ? Colors.white : AppTheme.primaryColor, size: 20),
      ),
    );
  }
}

/// Lumera 슬라이더
class _LumeraSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double>? onChanged;

  const _LumeraSlider({required this.label, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.backgroundColor,
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withOpacity(0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(value: value, min: 0, max: 1, onChanged: onChanged),
        ),
      ],
    );
  }
}

/// 내보내기 버튼
class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _ExportButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? AppTheme.primaryColor : AppTheme.backgroundColor,
          foregroundColor: filled ? Colors.white : AppTheme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// 반전된 모양 클리퍼 (바깥쪽만 남김)
class _InvertedShapeClipper extends CustomClipper<Path> {
  final Rect rect;
  final bool isCircle;
  final double feather;

  _InvertedShapeClipper({
    required this.rect,
    required this.isCircle,
    required this.feather,
  });

  @override
  Path getClip(Size size) {
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 페더 효과를 위해 약간 축소된 내부 영역
    final shrinkAmount = feather * 20; // 퍼짐 정도
    final innerRect = Rect.fromCenter(
      center: rect.center,
      width: math.max(0, rect.width - shrinkAmount),
      height: math.max(0, rect.height - shrinkAmount),
    );

    final innerPath = Path();
    if (isCircle) {
      innerPath.addOval(innerRect);
    } else {
      innerPath.addRRect(RRect.fromRectAndRadius(innerRect, const Radius.circular(8)));
    }

    return Path.combine(PathOperation.difference, outerPath, innerPath);
  }

  @override
  bool shouldReclip(covariant _InvertedShapeClipper oldClipper) {
    return oldClipper.rect != rect ||
           oldClipper.isCircle != isCircle ||
           oldClipper.feather != feather;
  }
}

/// 블러 페더(퍼짐) 효과 페인터
class _BlurFeatherPainter extends CustomPainter {
  final Rect rect;
  final bool isCircle;
  final double feather;
  final Color color;
  final double blurIntensity;

  _BlurFeatherPainter({
    required this.rect,
    required this.isCircle,
    required this.feather,
    required this.color,
    required this.blurIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (blurIntensity <= 0) return;

    final center = rect.center;
    final radiusX = rect.width / 2;
    final radiusY = rect.height / 2;
    final featherWidth = feather * 50 + 10; // 퍼짐 폭

    // 그라데이션으로 부드러운 경계 표현
    final gradient = RadialGradient(
      center: Alignment(
        (center.dx - size.width / 2) / (size.width / 2),
        (center.dy - size.height / 2) / (size.height / 2),
      ),
      radius: (radiusX + featherWidth) / size.width,
      colors: [
        Colors.transparent,
        Colors.transparent,
        color.withOpacity(blurIntensity * 0.15),
        color.withOpacity(blurIntensity * 0.3),
      ],
      stops: [
        0.0,
        math.max(0, (radiusX - featherWidth) / (radiusX + featherWidth)),
        radiusX / (radiusX + featherWidth),
        1.0,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // 선명 영역 바깥에만 그라데이션 적용
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final innerPath = Path();

    if (isCircle) {
      innerPath.addOval(rect);
    } else {
      innerPath.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));
    }

    canvas.save();
    canvas.clipPath(Path.combine(PathOperation.difference, outerPath, innerPath));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BlurFeatherPainter oldDelegate) {
    return oldDelegate.rect != rect ||
           oldDelegate.isCircle != isCircle ||
           oldDelegate.feather != feather ||
           oldDelegate.color != color ||
           oldDelegate.blurIntensity != blurIntensity;
  }
}

/// 그레인 효과 페인터
class GrainPainter extends CustomPainter {
  final double intensity;

  GrainPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(intensity * 0.15)
      ..style = PaintingStyle.fill;

    // 간단한 노이즈 패턴 (실제로는 shader 사용이 더 효율적)
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < (size.width * size.height * intensity * 0.001).toInt(); i++) {
      final x = ((random * (i + 1) * 31) % size.width.toInt()).toDouble();
      final y = ((random * (i + 1) * 37) % size.height.toInt()).toDouble();
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GrainPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}
