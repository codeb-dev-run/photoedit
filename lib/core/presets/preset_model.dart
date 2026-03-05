import 'package:photoedit/core/filters/film_filter.dart';

/// 편집 프리셋 모델
///
/// 사용자가 필터, 블러, 그레인, 리사이즈 설정을 저장하고
/// 재사용할 수 있도록 하는 프리셋 시스템
class EditPreset {
  /// 고유 ID (UUID)
  final String id;

  /// 프리셋 이름
  final String name;

  /// 생성 시간
  final DateTime createdAt;

  /// 기본 제공 프리셋 여부 (삭제 불가)
  final bool isDefault;

  // ========== 필터 설정 ==========

  /// 필름 필터 (null = 필터 없음)
  final FilmFilter? filmFilter;

  /// 필터 강도 (0.0 ~ 1.0)
  final double filterStrength;

  // ========== 블러 설정 ==========

  /// 블러 강도 (0.0 ~ 1.0)
  final double blurStrength;

  // ========== 그레인 설정 ==========

  /// 그레인 강도 (0.0 ~ 1.0)
  final double grainIntensity;

  // ========== 리사이즈 설정 ==========

  /// 종횡비 (예: "1:1", "4:3", "16:9", null)
  final String? aspectRatio;

  /// 출력 너비 (픽셀)
  final int? outputWidth;

  const EditPreset({
    required this.id,
    required this.name,
    required this.createdAt,
    this.isDefault = false,
    this.filmFilter,
    this.filterStrength = 0.0,
    this.blurStrength = 0.0,
    this.grainIntensity = 0.0,
    this.aspectRatio,
    this.outputWidth,
  });

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
      'filmFilter': filmFilter?.name,
      'filterStrength': filterStrength,
      'blurStrength': blurStrength,
      'grainIntensity': grainIntensity,
      'aspectRatio': aspectRatio,
      'outputWidth': outputWidth,
    };
  }

  /// JSON에서 역직렬화
  factory EditPreset.fromJson(Map<String, dynamic> json) {
    return EditPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
      filmFilter: json['filmFilter'] != null
          ? FilmFilter.values.firstWhere(
              (e) => e.name == json['filmFilter'],
              orElse: () => FilmFilter.portra400,
            )
          : null,
      filterStrength: (json['filterStrength'] as num?)?.toDouble() ?? 0.0,
      blurStrength: (json['blurStrength'] as num?)?.toDouble() ?? 0.0,
      grainIntensity: (json['grainIntensity'] as num?)?.toDouble() ?? 0.0,
      aspectRatio: json['aspectRatio'] as String?,
      outputWidth: json['outputWidth'] as int?,
    );
  }

  /// 값 복사 (불변 객체)
  EditPreset copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    bool? isDefault,
    FilmFilter? filmFilter,
    bool clearFilmFilter = false,
    double? filterStrength,
    double? blurStrength,
    double? grainIntensity,
    String? aspectRatio,
    bool clearAspectRatio = false,
    int? outputWidth,
    bool clearOutputWidth = false,
  }) {
    return EditPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
      filmFilter: clearFilmFilter ? null : (filmFilter ?? this.filmFilter),
      filterStrength: filterStrength ?? this.filterStrength,
      blurStrength: blurStrength ?? this.blurStrength,
      grainIntensity: grainIntensity ?? this.grainIntensity,
      aspectRatio:
          clearAspectRatio ? null : (aspectRatio ?? this.aspectRatio),
      outputWidth:
          clearOutputWidth ? null : (outputWidth ?? this.outputWidth),
    );
  }

  /// 프리셋이 비어있는지 확인 (모든 설정이 기본값)
  bool get isEmpty {
    return filmFilter == null &&
        filterStrength == 0.0 &&
        blurStrength == 0.0 &&
        grainIntensity == 0.0 &&
        aspectRatio == null &&
        outputWidth == null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EditPreset &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.isDefault == isDefault &&
        other.filmFilter == filmFilter &&
        other.filterStrength == filterStrength &&
        other.blurStrength == blurStrength &&
        other.grainIntensity == grainIntensity &&
        other.aspectRatio == aspectRatio &&
        other.outputWidth == outputWidth;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      createdAt,
      isDefault,
      filmFilter,
      filterStrength,
      blurStrength,
      grainIntensity,
      aspectRatio,
      outputWidth,
    );
  }

  @override
  String toString() {
    return 'EditPreset(id: $id, name: $name, isDefault: $isDefault)';
  }
}
