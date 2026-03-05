import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 블러 모양 타입
enum BlurShape { circle, rectangle }

/// 블러 영역 모델 (스티커/모자이크 개념)
class BlurRegion {
  final Offset position; // 중심 위치 (비율 0~1)
  final Size size; // 크기 (비율 0~1)
  final BlurShape shape; // 모양
  final Color color; // 블러 색상 틴트
  final double opacity; // 투명도

  const BlurRegion({
    this.position = const Offset(0.5, 0.5),
    this.size = const Size(0.25, 0.25),
    this.shape = BlurShape.circle,
    this.color = const Color(0x00000000), // 투명 (무색)
    this.opacity = 1.0,
  });

  BlurRegion copyWith({
    Offset? position,
    Size? size,
    BlurShape? shape,
    Color? color,
    double? opacity,
  }) {
    return BlurRegion(
      position: position ?? this.position,
      size: size ?? this.size,
      shape: shape ?? this.shape,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
    );
  }

  /// 실제 픽셀 좌표로 변환
  Rect toRect(Size imageSize) {
    final centerX = position.dx * imageSize.width;
    final centerY = position.dy * imageSize.height;
    final width = size.width * imageSize.width;
    final height = size.height * imageSize.height;
    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width,
      height: height,
    );
  }
}

/// 에디터 상태 모델
class EditorState {
  final File? imageFile;
  final ui.Image? decodedImage; // 디코딩된 이미지
  final double blurIntensity; // 0.0 ~ 1.0
  final BlurRegion blurRegion; // 블러 영역
  final bool isBlurEnabled; // 블러 활성화 여부
  final String? selectedFilter;
  final double filterIntensity; // 0.0 ~ 1.0
  final double grainIntensity; // 0.0 ~ 1.0
  final String aspectRatio;
  final String resolution;
  final bool isProcessing;
  final String? errorMessage;

  EditorState({
    this.imageFile,
    this.decodedImage,
    this.blurIntensity = 0.5,
    this.blurRegion = const BlurRegion(),
    this.isBlurEnabled = false,
    this.selectedFilter,
    this.filterIntensity = 1.0,
    this.grainIntensity = 0.0,
    this.aspectRatio = 'free',
    this.resolution = 'original',
    this.isProcessing = false,
    this.errorMessage,
  });

  EditorState copyWith({
    File? imageFile,
    ui.Image? decodedImage,
    double? blurIntensity,
    BlurRegion? blurRegion,
    bool? isBlurEnabled,
    String? selectedFilter,
    bool clearFilter = false,
    double? filterIntensity,
    double? grainIntensity,
    String? aspectRatio,
    String? resolution,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return EditorState(
      imageFile: imageFile ?? this.imageFile,
      decodedImage: decodedImage ?? this.decodedImage,
      blurIntensity: blurIntensity ?? this.blurIntensity,
      blurRegion: blurRegion ?? this.blurRegion,
      isBlurEnabled: isBlurEnabled ?? this.isBlurEnabled,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      filterIntensity: filterIntensity ?? this.filterIntensity,
      grainIntensity: grainIntensity ?? this.grainIntensity,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      resolution: resolution ?? this.resolution,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasEdits {
    return isBlurEnabled ||
        selectedFilter != null ||
        grainIntensity > 0.0 ||
        aspectRatio != 'free' ||
        resolution != 'original';
  }

  String get summary {
    final parts = <String>[];
    if (isBlurEnabled && blurIntensity > 0) {
      parts.add('블러 ${(blurIntensity * 100).toInt()}%');
    }
    if (selectedFilter != null) {
      final filterName = availableFilters
          .firstWhere((f) => f['id'] == selectedFilter, orElse: () => {})['name'] as String?;
      if (filterName != null) {
        parts.add('필터 $filterName ${(filterIntensity * 100).toInt()}%');
      }
    }
    if (grainIntensity > 0) {
      parts.add('그레인 ${(grainIntensity * 100).toInt()}%');
    }
    if (aspectRatio != 'free') {
      parts.add('비율 $aspectRatio');
    }
    if (resolution != 'original') {
      final resName = resolutionOptions
          .firstWhere((r) => r['id'] == resolution, orElse: () => {})['name'] as String?;
      if (resName != null) {
        parts.add('해상도 $resName');
      }
    }
    return parts.isEmpty ? '편집 없음' : parts.join(', ');
  }
}

/// 에디터 상태 Notifier
class EditorStateNotifier extends StateNotifier<EditorState> {
  EditorStateNotifier() : super(EditorState());

  void loadImage(File imageFile) {
    state = EditorState(imageFile: imageFile);
  }

  void setDecodedImage(ui.Image image) {
    state = state.copyWith(decodedImage: image);
  }

  void setBlurIntensity(double intensity) {
    state = state.copyWith(
      blurIntensity: intensity.clamp(0.0, 1.0),
      isBlurEnabled: intensity > 0,
    );
  }

  void setBlurRegion(BlurRegion region) {
    state = state.copyWith(blurRegion: region, isBlurEnabled: true);
  }

  void moveBlurRegion(Offset delta, Size containerSize) {
    final current = state.blurRegion;
    final newX = (current.position.dx + delta.dx / containerSize.width).clamp(0.1, 0.9);
    final newY = (current.position.dy + delta.dy / containerSize.height).clamp(0.1, 0.9);
    state = state.copyWith(
      blurRegion: current.copyWith(position: Offset(newX, newY)),
      isBlurEnabled: true,
    );
  }

  void resizeBlurRegion(Offset delta, Size containerSize, int corner) {
    final current = state.blurRegion;
    final dw = delta.dx / containerSize.width;
    final dh = delta.dy / containerSize.height;

    double newWidth = current.size.width;
    double newHeight = current.size.height;

    // corner: 0=topLeft, 1=topRight, 2=bottomRight, 3=bottomLeft
    switch (corner) {
      case 0: // top-left
        newWidth = (current.size.width - dw).clamp(0.1, 0.9);
        newHeight = (current.size.height - dh).clamp(0.1, 0.9);
        break;
      case 1: // top-right
        newWidth = (current.size.width + dw).clamp(0.1, 0.9);
        newHeight = (current.size.height - dh).clamp(0.1, 0.9);
        break;
      case 2: // bottom-right
        newWidth = (current.size.width + dw).clamp(0.1, 0.9);
        newHeight = (current.size.height + dh).clamp(0.1, 0.9);
        break;
      case 3: // bottom-left
        newWidth = (current.size.width - dw).clamp(0.1, 0.9);
        newHeight = (current.size.height + dh).clamp(0.1, 0.9);
        break;
    }

    state = state.copyWith(
      blurRegion: current.copyWith(size: Size(newWidth, newHeight)),
      isBlurEnabled: true,
    );
  }

  void toggleBlur(bool enabled) {
    state = state.copyWith(isBlurEnabled: enabled);
  }

  void setBlurShape(BlurShape shape) {
    state = state.copyWith(
      blurRegion: state.blurRegion.copyWith(shape: shape),
      isBlurEnabled: true,
    );
  }

  void setBlurColor(Color color) {
    state = state.copyWith(
      blurRegion: state.blurRegion.copyWith(color: color),
      isBlurEnabled: true,
    );
  }

  void setBlurOpacity(double opacity) {
    state = state.copyWith(
      blurRegion: state.blurRegion.copyWith(opacity: opacity.clamp(0.0, 1.0)),
      isBlurEnabled: true,
    );
  }

  void selectFilter(String? filter) {
    if (filter == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(selectedFilter: filter);
    }
  }

  void setFilterIntensity(double intensity) {
    state = state.copyWith(filterIntensity: intensity.clamp(0.0, 1.0));
  }

  void setGrainIntensity(double intensity) {
    state = state.copyWith(grainIntensity: intensity.clamp(0.0, 1.0));
  }

  void setAspectRatio(String ratio) {
    state = state.copyWith(aspectRatio: ratio);
  }

  void setResolution(String resolution) {
    state = state.copyWith(resolution: resolution);
  }

  void reset() {
    final imageFile = state.imageFile;
    final decodedImage = state.decodedImage;
    state = EditorState(imageFile: imageFile, decodedImage: decodedImage);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message, isProcessing: false);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }
}

/// 에디터 상태 Provider
final editorStateProvider =
    StateNotifierProvider<EditorStateNotifier, EditorState>((ref) {
  return EditorStateNotifier();
});

/// 현재 선택된 탭 Provider
enum EditorTab { blur, filter, grain, resize }

final selectedTabProvider = StateProvider<EditorTab>((ref) => EditorTab.blur);

/// 필터별 Color Matrix 정의 - 70+ 필름 필터
ColorFilter? getColorFilterMatrix(String? filterId, double intensity) {
  if (filterId == null || intensity <= 0) return null;

  final matrices = <String, List<double>>{
    // ═══════════════════════════════════════════
    // KODAK 컬러 네거티브
    // ═══════════════════════════════════════════
    'portra400': [
      1.1, 0.1, 0.0, 0, 10,
      0.0, 1.0, 0.1, 0, 5,
      0.0, 0.0, 0.9, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'portra160': [
      1.05, 0.08, 0.0, 0, 8,
      0.0, 1.02, 0.08, 0, 3,
      0.0, 0.0, 0.92, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'ektar100': [
      1.15, 0.0, 0.0, 0, 5,
      0.0, 1.1, 0.0, 0, 3,
      0.0, 0.0, 1.05, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'gold200': [
      1.2, 0.1, 0.0, 0, 20,
      0.1, 1.0, 0.0, 0, 10,
      0.0, 0.0, 0.8, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'colorplus200': [
      1.15, 0.08, 0.0, 0, 15,
      0.05, 1.0, 0.0, 0, 8,
      0.0, 0.0, 0.85, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'ultramax400': [
      1.25, 0.05, 0.0, 0, 10,
      0.0, 1.15, 0.0, 0, 5,
      0.0, 0.0, 1.1, 0, 0,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // KODAK 흑백
    // ═══════════════════════════════════════════
    'triX400': [
      0.35, 0.55, 0.1, 0, 5,
      0.35, 0.55, 0.1, 0, 5,
      0.35, 0.55, 0.1, 0, 5,
      0, 0, 0, 1, 0,
    ],
    'tmax100': [
      0.299, 0.587, 0.114, 0, 0,
      0.299, 0.587, 0.114, 0, 0,
      0.299, 0.587, 0.114, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'tmax400': [
      0.33, 0.56, 0.11, 0, 3,
      0.33, 0.56, 0.11, 0, 3,
      0.33, 0.56, 0.11, 0, 3,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // KODAK 슬라이드
    // ═══════════════════════════════════════════
    'kodachrome64': [
      1.2, 0.15, 0.0, 0, 15,
      0.1, 1.1, 0.0, 0, 8,
      0.0, 0.05, 0.95, 0, -5,
      0, 0, 0, 1, 0,
    ],
    'ektachrome100': [
      1.1, 0.0, 0.05, 0, 0,
      0.0, 1.15, 0.0, 0, 5,
      0.05, 0.0, 1.2, 0, 10,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // FUJI 컬러 네거티브
    // ═══════════════════════════════════════════
    'superia400': [
      1.05, 0.1, 0.0, 0, 5,
      0.05, 1.1, 0.05, 0, 8,
      0.0, 0.05, 0.95, 0, 5,
      0, 0, 0, 1, 0,
    ],
    'superia100': [
      1.0, 0.08, 0.0, 0, 3,
      0.03, 1.05, 0.03, 0, 5,
      0.0, 0.03, 0.97, 0, 3,
      0, 0, 0, 1, 0,
    ],
    'pro400h': [
      1.0, 0.05, 0.05, 0, 5,
      0.05, 1.0, 0.05, 0, 5,
      0.1, 0.1, 1.0, 0, 10,
      0, 0, 0, 1, 0,
    ],
    'fuji160c': [
      1.0, 0.03, 0.03, 0, 3,
      0.03, 1.0, 0.03, 0, 3,
      0.05, 0.05, 0.98, 0, 5,
      0, 0, 0, 1, 0,
    ],
    'reala100': [
      1.02, 0.02, 0.02, 0, 2,
      0.02, 1.02, 0.02, 0, 2,
      0.02, 0.02, 1.02, 0, 2,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // FUJI 슬라이드
    // ═══════════════════════════════════════════
    'velvia50': [
      1.3, 0.0, 0.0, 0, 0,
      0.0, 1.2, 0.0, 0, 0,
      0.0, 0.0, 1.3, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'velvia100': [
      1.25, 0.0, 0.0, 0, 0,
      0.0, 1.18, 0.0, 0, 0,
      0.0, 0.0, 1.25, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'provia100f': [
      1.1, 0.0, 0.0, 0, 0,
      0.0, 1.08, 0.0, 0, 0,
      0.0, 0.0, 1.1, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'astia100f': [
      1.05, 0.02, 0.02, 0, 3,
      0.02, 1.05, 0.02, 0, 3,
      0.02, 0.02, 1.05, 0, 3,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // FUJI 흑백
    // ═══════════════════════════════════════════
    'neopanAcros': [
      0.3, 0.59, 0.11, 0, 0,
      0.3, 0.59, 0.11, 0, 0,
      0.3, 0.59, 0.11, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'neopan400': [
      0.32, 0.57, 0.11, 0, 3,
      0.32, 0.57, 0.11, 0, 3,
      0.32, 0.57, 0.11, 0, 3,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // ILFORD 흑백
    // ═══════════════════════════════════════════
    'hp5plus': [
      0.35, 0.55, 0.1, 0, 8,
      0.35, 0.55, 0.1, 0, 8,
      0.35, 0.55, 0.1, 0, 8,
      0, 0, 0, 1, 0,
    ],
    'fp4plus': [
      0.299, 0.587, 0.114, 0, 2,
      0.299, 0.587, 0.114, 0, 2,
      0.299, 0.587, 0.114, 0, 2,
      0, 0, 0, 1, 0,
    ],
    'delta100': [
      0.28, 0.6, 0.12, 0, 0,
      0.28, 0.6, 0.12, 0, 0,
      0.28, 0.6, 0.12, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'delta400': [
      0.31, 0.58, 0.11, 0, 5,
      0.31, 0.58, 0.11, 0, 5,
      0.31, 0.58, 0.11, 0, 5,
      0, 0, 0, 1, 0,
    ],
    'delta3200': [
      0.36, 0.53, 0.11, 0, 10,
      0.36, 0.53, 0.11, 0, 10,
      0.36, 0.53, 0.11, 0, 10,
      0, 0, 0, 1, 0,
    ],
    'panF50': [
      0.27, 0.62, 0.11, 0, -2,
      0.27, 0.62, 0.11, 0, -2,
      0.27, 0.62, 0.11, 0, -2,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // POLAROID / INSTANT
    // ═══════════════════════════════════════════
    'polaroid': [
      1.1, 0.15, 0.0, 0, 15,
      0.1, 1.05, 0.1, 0, 10,
      0.0, 0.1, 0.9, 0, 15,
      0, 0, 0, 1, 0,
    ],
    'polaroid600': [
      1.08, 0.12, 0.0, 0, 12,
      0.08, 1.03, 0.08, 0, 8,
      0.0, 0.08, 0.88, 0, 12,
      0, 0, 0, 1, 0,
    ],
    'timeZero': [
      1.15, 0.2, 0.0, 0, 20,
      0.12, 1.0, 0.12, 0, 15,
      0.0, 0.15, 0.85, 0, 20,
      0, 0, 0, 1, 0,
    ],
    'instax': [
      1.05, 0.1, 0.05, 0, 12,
      0.05, 1.05, 0.1, 0, 10,
      0.05, 0.1, 1.0, 0, 15,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // AGFA
    // ═══════════════════════════════════════════
    'vistaPlus': [
      1.12, 0.08, 0.0, 0, 12,
      0.05, 1.02, 0.0, 0, 8,
      0.0, 0.0, 0.88, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'agfaUltra': [
      1.25, 0.0, 0.0, 0, 5,
      0.0, 1.2, 0.0, 0, 3,
      0.0, 0.0, 1.15, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'apx100': [
      0.29, 0.59, 0.12, 0, 0,
      0.29, 0.59, 0.12, 0, 0,
      0.29, 0.59, 0.12, 0, 0,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // LOMOGRAPHY
    // ═══════════════════════════════════════════
    'lomoColor400': [
      1.4, 0.0, 0.0, 0, -20,
      0.0, 1.2, 0.0, 0, 0,
      0.0, 0.0, 0.8, 0, 20,
      0, 0, 0, 1, 0,
    ],
    'lomoXpro': [
      1.3, 0.1, 0.0, 0, -15,
      0.0, 1.15, 0.1, 0, 5,
      0.1, 0.0, 1.2, 0, 15,
      0, 0, 0, 1, 0,
    ],
    'lomoPurple': [
      1.1, 0.0, 0.3, 0, 10,
      0.0, 0.9, 0.1, 0, 0,
      0.2, 0.0, 1.2, 0, 20,
      0, 0, 0, 1, 0,
    ],
    'lomoRedscale': [
      1.5, 0.2, 0.0, 0, 0,
      0.3, 0.9, 0.0, 0, -10,
      0.1, 0.1, 0.6, 0, -20,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // CINEMATIC / MOVIE
    // ═══════════════════════════════════════════
    'cinestill800t': [
      1.0, 0.0, 0.2, 0, -10,
      0.0, 1.0, 0.1, 0, 0,
      0.1, 0.1, 1.2, 0, 20,
      0, 0, 0, 1, 0,
    ],
    'cinestill50d': [
      1.05, 0.0, 0.05, 0, 0,
      0.0, 1.05, 0.05, 0, 0,
      0.05, 0.05, 1.1, 0, 5,
      0, 0, 0, 1, 0,
    ],
    'vision3_250d': [
      1.08, 0.0, 0.03, 0, 3,
      0.0, 1.05, 0.03, 0, 2,
      0.03, 0.03, 1.08, 0, 5,
      0, 0, 0, 1, 0,
    ],
    'vision3_500t': [
      0.98, 0.0, 0.15, 0, -8,
      0.0, 0.98, 0.08, 0, -3,
      0.08, 0.08, 1.15, 0, 15,
      0, 0, 0, 1, 0,
    ],
    // ═══════════════════════════════════════════
    // CREATIVE / SPECIAL
    // ═══════════════════════════════════════════
    'crossProcess': [
      1.3, 0.1, 0.0, 0, -15,
      0.0, 1.15, 0.1, 0, 5,
      0.1, 0.0, 1.2, 0, 15,
      0, 0, 0, 1, 0,
    ],
    'bleachBypass': [
      1.2, 0.1, 0.1, 0, -10,
      0.1, 1.1, 0.1, 0, -10,
      0.1, 0.1, 1.0, 0, -10,
      0, 0, 0, 1, 0,
    ],
    'vintageFade': [
      1.1, 0.2, 0.1, 0, 10,
      0.1, 1.0, 0.1, 0, 5,
      0.0, 0.1, 0.8, 0, 10,
      0, 0, 0, 1, 0,
    ],
    'sepiaClassic': [
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'cyanotype': [
      0.2, 0.3, 0.2, 0, 0,
      0.3, 0.5, 0.4, 0, 10,
      0.4, 0.5, 0.7, 0, 30,
      0, 0, 0, 1, 0,
    ],
    'duotoneBlue': [
      0.25, 0.35, 0.2, 0, 0,
      0.3, 0.45, 0.35, 0, 10,
      0.35, 0.5, 0.6, 0, 30,
      0, 0, 0, 1, 0,
    ],
    'duotoneOrange': [
      0.6, 0.4, 0.1, 0, 20,
      0.4, 0.35, 0.15, 0, 10,
      0.2, 0.2, 0.3, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'tealOrange': [
      1.1, 0.0, 0.0, 0, 10,
      0.0, 1.05, 0.1, 0, 0,
      0.1, 0.15, 1.1, 0, 15,
      0, 0, 0, 1, 0,
    ],
    'matteFilm': [
      1.0, 0.05, 0.05, 0, 15,
      0.05, 0.95, 0.05, 0, 15,
      0.05, 0.05, 0.9, 0, 20,
      0, 0, 0, 1, 0,
    ],
  };

  final matrix = matrices[filterId];
  if (matrix == null) return null;

  // intensity 적용: identity matrix와 blend
  final identity = [
    1.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];

  final blended = List<double>.generate(20, (i) {
    return identity[i] + (matrix[i] - identity[i]) * intensity;
  });

  return ColorFilter.matrix(blended);
}

/// 필터 카테고리
enum FilterDisplayCategory {
  kodakColor('Kodak 컬러'),
  kodakBW('Kodak 흑백'),
  kodakSlide('Kodak 슬라이드'),
  fujiColor('Fuji 컬러'),
  fujiSlide('Fuji 슬라이드'),
  fujiBW('Fuji 흑백'),
  ilford('Ilford'),
  polaroid('Polaroid'),
  agfa('Agfa'),
  lomo('Lomo'),
  cinema('Cinema'),
  creative('Creative');

  const FilterDisplayCategory(this.displayName);
  final String displayName;
}

/// 사용 가능한 필터 목록 - 50+ 필터
const availableFilters = [
  // ═══════════════════════════════════════════
  // KODAK 컬러 네거티브
  // ═══════════════════════════════════════════
  {'id': 'portra400', 'name': 'Portra 400', 'category': 'kodakColor'},
  {'id': 'portra160', 'name': 'Portra 160', 'category': 'kodakColor'},
  {'id': 'ektar100', 'name': 'Ektar 100', 'category': 'kodakColor'},
  {'id': 'gold200', 'name': 'Gold 200', 'category': 'kodakColor'},
  {'id': 'colorplus200', 'name': 'ColorPlus 200', 'category': 'kodakColor'},
  {'id': 'ultramax400', 'name': 'Ultramax 400', 'category': 'kodakColor'},
  // ═══════════════════════════════════════════
  // KODAK 흑백
  // ═══════════════════════════════════════════
  {'id': 'triX400', 'name': 'Tri-X 400', 'category': 'kodakBW'},
  {'id': 'tmax100', 'name': 'T-Max 100', 'category': 'kodakBW'},
  {'id': 'tmax400', 'name': 'T-Max 400', 'category': 'kodakBW'},
  // ═══════════════════════════════════════════
  // KODAK 슬라이드
  // ═══════════════════════════════════════════
  {'id': 'kodachrome64', 'name': 'Kodachrome 64', 'category': 'kodakSlide'},
  {'id': 'ektachrome100', 'name': 'Ektachrome 100', 'category': 'kodakSlide'},
  // ═══════════════════════════════════════════
  // FUJI 컬러 네거티브
  // ═══════════════════════════════════════════
  {'id': 'superia400', 'name': 'Superia 400', 'category': 'fujiColor'},
  {'id': 'superia100', 'name': 'Superia 100', 'category': 'fujiColor'},
  {'id': 'pro400h', 'name': 'Pro 400H', 'category': 'fujiColor'},
  {'id': 'fuji160c', 'name': '160C', 'category': 'fujiColor'},
  {'id': 'reala100', 'name': 'Reala 100', 'category': 'fujiColor'},
  // ═══════════════════════════════════════════
  // FUJI 슬라이드
  // ═══════════════════════════════════════════
  {'id': 'velvia50', 'name': 'Velvia 50', 'category': 'fujiSlide'},
  {'id': 'velvia100', 'name': 'Velvia 100', 'category': 'fujiSlide'},
  {'id': 'provia100f', 'name': 'Provia 100F', 'category': 'fujiSlide'},
  {'id': 'astia100f', 'name': 'Astia 100F', 'category': 'fujiSlide'},
  // ═══════════════════════════════════════════
  // FUJI 흑백
  // ═══════════════════════════════════════════
  {'id': 'neopanAcros', 'name': 'Neopan Acros', 'category': 'fujiBW'},
  {'id': 'neopan400', 'name': 'Neopan 400', 'category': 'fujiBW'},
  // ═══════════════════════════════════════════
  // ILFORD 흑백
  // ═══════════════════════════════════════════
  {'id': 'hp5plus', 'name': 'HP5 Plus', 'category': 'ilford'},
  {'id': 'fp4plus', 'name': 'FP4 Plus', 'category': 'ilford'},
  {'id': 'delta100', 'name': 'Delta 100', 'category': 'ilford'},
  {'id': 'delta400', 'name': 'Delta 400', 'category': 'ilford'},
  {'id': 'delta3200', 'name': 'Delta 3200', 'category': 'ilford'},
  {'id': 'panF50', 'name': 'Pan F 50', 'category': 'ilford'},
  // ═══════════════════════════════════════════
  // POLAROID / INSTANT
  // ═══════════════════════════════════════════
  {'id': 'polaroid', 'name': 'Polaroid SX-70', 'category': 'polaroid'},
  {'id': 'polaroid600', 'name': 'Polaroid 600', 'category': 'polaroid'},
  {'id': 'timeZero', 'name': 'Time Zero', 'category': 'polaroid'},
  {'id': 'instax', 'name': 'Instax', 'category': 'polaroid'},
  // ═══════════════════════════════════════════
  // AGFA
  // ═══════════════════════════════════════════
  {'id': 'vistaPlus', 'name': 'Vista 200', 'category': 'agfa'},
  {'id': 'agfaUltra', 'name': 'Ultra 100', 'category': 'agfa'},
  {'id': 'apx100', 'name': 'APX 100', 'category': 'agfa'},
  // ═══════════════════════════════════════════
  // LOMOGRAPHY
  // ═══════════════════════════════════════════
  {'id': 'lomoColor400', 'name': 'Color 400', 'category': 'lomo'},
  {'id': 'lomoXpro', 'name': 'X-Pro', 'category': 'lomo'},
  {'id': 'lomoPurple', 'name': 'Purple', 'category': 'lomo'},
  {'id': 'lomoRedscale', 'name': 'Redscale', 'category': 'lomo'},
  // ═══════════════════════════════════════════
  // CINEMATIC / MOVIE
  // ═══════════════════════════════════════════
  {'id': 'cinestill800t', 'name': 'Cinestill 800T', 'category': 'cinema'},
  {'id': 'cinestill50d', 'name': 'Cinestill 50D', 'category': 'cinema'},
  {'id': 'vision3_250d', 'name': 'Vision3 250D', 'category': 'cinema'},
  {'id': 'vision3_500t', 'name': 'Vision3 500T', 'category': 'cinema'},
  // ═══════════════════════════════════════════
  // CREATIVE / SPECIAL
  // ═══════════════════════════════════════════
  {'id': 'crossProcess', 'name': 'Cross Process', 'category': 'creative'},
  {'id': 'bleachBypass', 'name': 'Bleach Bypass', 'category': 'creative'},
  {'id': 'vintageFade', 'name': 'Vintage Fade', 'category': 'creative'},
  {'id': 'sepiaClassic', 'name': 'Sepia', 'category': 'creative'},
  {'id': 'cyanotype', 'name': 'Cyanotype', 'category': 'creative'},
  {'id': 'duotoneBlue', 'name': 'Duotone Blue', 'category': 'creative'},
  {'id': 'duotoneOrange', 'name': 'Duotone Orange', 'category': 'creative'},
  {'id': 'tealOrange', 'name': 'Teal & Orange', 'category': 'creative'},
  {'id': 'matteFilm', 'name': 'Matte Film', 'category': 'creative'},
];

/// 카테고리별 필터 가져오기
List<Map<String, String>> getFiltersByDisplayCategory(String category) {
  return availableFilters
      .where((f) => f['category'] == category)
      .toList();
}

/// 종횡비 옵션
const aspectRatioOptions = [
  {'id': 'free', 'name': '자유', 'ratio': null},
  {'id': '1:1', 'name': '1:1', 'ratio': 1.0},
  {'id': '4:3', 'name': '4:3', 'ratio': 4.0 / 3.0},
  {'id': '3:4', 'name': '3:4', 'ratio': 3.0 / 4.0},
  {'id': '16:9', 'name': '16:9', 'ratio': 16.0 / 9.0},
  {'id': '9:16', 'name': '9:16', 'ratio': 9.0 / 16.0},
];

/// 해상도 옵션
const resolutionOptions = [
  {'id': 'original', 'name': '원본', 'width': null},
  {'id': '4k', 'name': '4K (3840px)', 'width': 3840},
  {'id': '2k', 'name': '2K (2048px)', 'width': 2048},
  {'id': '1080p', 'name': 'Full HD (1920px)', 'width': 1920},
  {'id': '720p', 'name': 'HD (1280px)', 'width': 1280},
];
