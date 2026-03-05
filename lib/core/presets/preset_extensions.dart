import 'package:photoedit/core/presets/preset_model.dart';
import 'package:photoedit/core/filters/film_filter.dart';

/// EditPreset 확장 메서드
extension EditPresetExtensions on EditPreset {
  /// 프리셋 요약 정보 생성
  ///
  /// 예: "Portra 400 (80%) + Grain (25%)"
  String get summary {
    final parts = <String>[];

    // 필터 정보
    if (filmFilter != null && filterStrength > 0) {
      final percentage = (filterStrength * 100).toInt();
      parts.add('${filmFilter!.displayName} ($percentage%)');
    }

    // 그레인 정보
    if (grainIntensity > 0) {
      final percentage = (grainIntensity * 100).toInt();
      parts.add('Grain ($percentage%)');
    }

    // 블러 정보
    if (blurStrength > 0) {
      final percentage = (blurStrength * 100).toInt();
      parts.add('Blur ($percentage%)');
    }

    // 종횡비 정보
    if (aspectRatio != null) {
      parts.add('Ratio $aspectRatio');
    }

    return parts.isEmpty ? 'No effects' : parts.join(' + ');
  }

  /// 필터가 적용되어 있는지 확인
  bool get hasFilter => filmFilter != null && filterStrength > 0;

  /// 그레인이 적용되어 있는지 확인
  bool get hasGrain => grainIntensity > 0;

  /// 블러가 적용되어 있는지 확인
  bool get hasBlur => blurStrength > 0;

  /// 리사이즈 설정이 있는지 확인
  bool get hasResize => aspectRatio != null || outputWidth != null;

  /// 어떤 효과라도 적용되어 있는지 확인
  bool get hasAnyEffect => !isEmpty;

  /// 프리셋의 강도 레벨 (0 = 없음, 1 = 약함, 2 = 중간, 3 = 강함)
  int get intensityLevel {
    final avgIntensity = (filterStrength + grainIntensity + blurStrength) / 3;

    if (avgIntensity == 0) return 0;
    if (avgIntensity < 0.3) return 1;
    if (avgIntensity < 0.6) return 2;
    return 3;
  }

  /// 강도 레벨 텍스트
  String get intensityText {
    switch (intensityLevel) {
      case 0:
        return 'None';
      case 1:
        return 'Light';
      case 2:
        return 'Medium';
      case 3:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }
}

/// List<EditPreset> 확장 메서드
extension EditPresetListExtensions on List<EditPreset> {
  /// 기본 프리셋만 필터링
  List<EditPreset> get defaultPresets =>
      where((preset) => preset.isDefault).toList();

  /// 사용자 프리셋만 필터링
  List<EditPreset> get userPresets =>
      where((preset) => !preset.isDefault).toList();

  /// 특정 필터를 사용하는 프리셋 필터링
  List<EditPreset> withFilter(FilmFilter filter) =>
      where((preset) => preset.filmFilter == filter).toList();

  /// 강도별 필터링
  List<EditPreset> withIntensity(int level) =>
      where((preset) => preset.intensityLevel == level).toList();

  /// 종횡비별 필터링
  List<EditPreset> withAspectRatio(String ratio) =>
      where((preset) => preset.aspectRatio == ratio).toList();
}
