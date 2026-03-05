import 'package:flutter/material.dart';

/// 이미지 편집 프리셋
class Preset {
  final String id;
  final String name;
  final String? description;
  final bool isDefault;
  final PresetSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Preset({
    required this.id,
    required this.name,
    this.description,
    required this.isDefault,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  Preset copyWith({
    String? id,
    String? name,
    String? description,
    bool? isDefault,
    PresetSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isDefault': isDefault,
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Preset.fromJson(Map<String, dynamic> json) {
    return Preset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      settings: PresetSettings.fromJson(json['settings'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// 프리셋 설정
class PresetSettings {
  final double brightness;
  final double contrast;
  final double saturation;
  final double blur;
  final double grain;
  final FilmFilter filmFilter;
  final Color? tintColor;
  final double tintOpacity;

  const PresetSettings({
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.blur = 0.0,
    this.grain = 0.0,
    this.filmFilter = FilmFilter.none,
    this.tintColor,
    this.tintOpacity = 0.0,
  });

  PresetSettings copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? blur,
    double? grain,
    FilmFilter? filmFilter,
    Color? tintColor,
    double? tintOpacity,
  }) {
    return PresetSettings(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      blur: blur ?? this.blur,
      grain: grain ?? this.grain,
      filmFilter: filmFilter ?? this.filmFilter,
      tintColor: tintColor ?? this.tintColor,
      tintOpacity: tintOpacity ?? this.tintOpacity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness,
      'contrast': contrast,
      'saturation': saturation,
      'blur': blur,
      'grain': grain,
      'filmFilter': filmFilter.name,
      'tintColor': tintColor?.value,
      'tintOpacity': tintOpacity,
    };
  }

  factory PresetSettings.fromJson(Map<String, dynamic> json) {
    return PresetSettings(
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 0.0,
      saturation: (json['saturation'] as num?)?.toDouble() ?? 0.0,
      blur: (json['blur'] as num?)?.toDouble() ?? 0.0,
      grain: (json['grain'] as num?)?.toDouble() ?? 0.0,
      filmFilter: FilmFilter.values.firstWhere(
        (f) => f.name == json['filmFilter'],
        orElse: () => FilmFilter.none,
      ),
      tintColor: json['tintColor'] != null
          ? Color(json['tintColor'] as int)
          : null,
      tintOpacity: (json['tintOpacity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 필름 필터
enum FilmFilter {
  none('없음'),
  kodakSummer('Kodak Summer'),
  fujiLandscape('Fuji Landscape'),
  lofiVintage('Lo-Fi Vintage'),
  portra400('Portra 400'),
  cinestill800T('Cinestill 800T');

  final String displayName;
  const FilmFilter(this.displayName);
}

/// 기본 프리셋
class DefaultPresets {
  static final List<Preset> presets = [
    Preset(
      id: 'kodak-summer',
      name: 'Kodak Summer',
      description: '따뜻한 여름 느낌',
      isDefault: true,
      settings: const PresetSettings(
        brightness: 0.1,
        contrast: 0.15,
        saturation: 0.2,
        filmFilter: FilmFilter.kodakSummer,
        tintColor: Color(0xFFFFD700),
        tintOpacity: 0.1,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Preset(
      id: 'fuji-landscape',
      name: 'Fuji Landscape',
      description: '자연스러운 풍경',
      isDefault: true,
      settings: const PresetSettings(
        brightness: 0.05,
        contrast: 0.2,
        saturation: 0.15,
        filmFilter: FilmFilter.fujiLandscape,
        tintColor: Color(0xFF4169E1),
        tintOpacity: 0.05,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Preset(
      id: 'lofi-vintage',
      name: 'Lo-Fi Vintage',
      description: '빈티지 분위기',
      isDefault: true,
      settings: const PresetSettings(
        brightness: -0.1,
        contrast: 0.25,
        saturation: -0.2,
        blur: 0.3,
        grain: 0.4,
        filmFilter: FilmFilter.lofiVintage,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Preset(
      id: 'portra-400',
      name: 'Portra 400',
      description: '부드러운 인물',
      isDefault: true,
      settings: const PresetSettings(
        brightness: 0.15,
        contrast: 0.1,
        saturation: 0.1,
        filmFilter: FilmFilter.portra400,
        tintColor: Color(0xFFFFC0CB),
        tintOpacity: 0.08,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Preset(
      id: 'cinestill-800t',
      name: 'Cinestill 800T',
      description: '시네마틱 야경',
      isDefault: true,
      settings: const PresetSettings(
        brightness: 0.2,
        contrast: 0.3,
        saturation: 0.25,
        grain: 0.2,
        filmFilter: FilmFilter.cinestill800T,
        tintColor: Color(0xFF1E90FF),
        tintOpacity: 0.12,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // ═══════════════════════════════════════════
    // 노이즈/그레인 프리셋
    // ═══════════════════════════════════════════
    Preset(
      id: 'noise-light',
      name: '노이즈 약함',
      description: '미세한 필름 그레인 효과',
      isDefault: true,
      settings: const PresetSettings(
        grain: 0.15,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Preset(
      id: 'noise-medium',
      name: '노이즈 중간',
      description: '자연스러운 필름 입자감',
      isDefault: true,
      settings: const PresetSettings(
        grain: 0.35,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Preset(
      id: 'noise-heavy',
      name: '노이즈 강함',
      description: '거친 빈티지 필름 느낌',
      isDefault: true,
      settings: const PresetSettings(
        grain: 0.55,
        contrast: 0.1,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Preset(
      id: 'noise-extreme',
      name: '노이즈 극대화',
      description: '강렬한 아날로그 질감',
      isDefault: true,
      settings: const PresetSettings(
        grain: 0.75,
        contrast: 0.15,
        saturation: -0.1,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Preset(
      id: 'vintage-grain',
      name: '빈티지 그레인',
      description: '따뜻한 빈티지 노이즈',
      isDefault: true,
      settings: const PresetSettings(
        grain: 0.4,
        brightness: 0.05,
        contrast: 0.2,
        saturation: -0.15,
        tintColor: Color(0xFFDAA520),
        tintOpacity: 0.08,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Preset(
      id: 'bw-grain',
      name: '흑백 그레인',
      description: '클래식 흑백 필름 노이즈',
      isDefault: true,
      settings: const PresetSettings(
        grain: 0.45,
        contrast: 0.25,
        saturation: -1.0,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}
