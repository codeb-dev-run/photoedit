import 'package:photoedit/core/filters/film_filter.dart';
import 'package:photoedit/core/presets/preset_model.dart';

/// 기본 제공 프리셋 목록 - 25개 확장
class DefaultPresets {
  /// 모든 기본 프리셋 가져오기
  static List<EditPreset> getAll() {
    final now = DateTime.now();

    return [
      // ═══════════════════════════════════════════
      // PORTRAIT / 인물 프리셋
      // ═══════════════════════════════════════════
      EditPreset(
        id: 'default_kodak_summer',
        name: 'Kodak Summer',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.portra400,
        filterStrength: 0.80,
        grainIntensity: 0.25,
        blurStrength: 0.0,
      ),

      EditPreset(
        id: 'default_soft_portrait',
        name: 'Soft Portrait',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.portra160,
        filterStrength: 0.70,
        grainIntensity: 0.15,
        blurStrength: 0.05,
      ),

      EditPreset(
        id: 'default_wedding_classic',
        name: 'Wedding Classic',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.pro400h,
        filterStrength: 0.75,
        grainIntensity: 0.20,
        blurStrength: 0.0,
      ),

      EditPreset(
        id: 'default_studio_light',
        name: 'Studio Light',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.fuji160c,
        filterStrength: 0.65,
        grainIntensity: 0.10,
        blurStrength: 0.0,
      ),

      // ═══════════════════════════════════════════
      // LANDSCAPE / 풍경 프리셋
      // ═══════════════════════════════════════════
      EditPreset(
        id: 'default_fuji_landscape',
        name: 'Fuji Landscape',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.velvia50,
        filterStrength: 0.90,
        grainIntensity: 0.15,
        blurStrength: 0.0,
        aspectRatio: '16:9',
      ),

      EditPreset(
        id: 'default_vivid_nature',
        name: 'Vivid Nature',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.velvia100,
        filterStrength: 0.85,
        grainIntensity: 0.10,
        blurStrength: 0.0,
      ),

      EditPreset(
        id: 'default_natural_colors',
        name: 'Natural Colors',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.provia100f,
        filterStrength: 0.70,
        grainIntensity: 0.12,
        blurStrength: 0.0,
      ),

      EditPreset(
        id: 'default_sharp_ektar',
        name: 'Sharp Ektar',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.ektar100,
        filterStrength: 0.80,
        grainIntensity: 0.08,
        blurStrength: 0.0,
      ),

      // ═══════════════════════════════════════════
      // VINTAGE / 빈티지 프리셋
      // ═══════════════════════════════════════════
      EditPreset(
        id: 'default_lofi_vintage',
        name: 'Lo-Fi Vintage',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.gold200,
        filterStrength: 0.70,
        grainIntensity: 0.50,
        blurStrength: 0.0,
        aspectRatio: '4:3',
      ),

      EditPreset(
        id: 'default_90s_japan',
        name: '90s Japan',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.superia400,
        filterStrength: 0.75,
        grainIntensity: 0.45,
        blurStrength: 0.0,
        aspectRatio: '4:3',
      ),

      EditPreset(
        id: 'default_70s_warm',
        name: '70s Warm',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.kodachrome64,
        filterStrength: 0.85,
        grainIntensity: 0.40,
        blurStrength: 0.0,
      ),

      EditPreset(
        id: 'default_faded_memory',
        name: 'Faded Memory',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.vintageFade,
        filterStrength: 0.60,
        grainIntensity: 0.35,
        blurStrength: 0.08,
      ),

      EditPreset(
        id: 'default_expired_film',
        name: 'Expired Film',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.timeZero,
        filterStrength: 0.70,
        grainIntensity: 0.55,
        blurStrength: 0.05,
      ),

      // ═══════════════════════════════════════════
      // B&W / 흑백 프리셋
      // ═══════════════════════════════════════════
      EditPreset(
        id: 'default_bw_classic',
        name: 'B&W Classic',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.triX400,
        filterStrength: 1.0,
        grainIntensity: 0.40,
        blurStrength: 0.0,
      ),

      EditPreset(
        id: 'default_bw_fine',
        name: 'B&W Fine Art',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.delta100,
        filterStrength: 0.95,
        grainIntensity: 0.15,
        blurStrength: 0.0,
      ),

      EditPreset(
        id: 'default_bw_street',
        name: 'B&W Street',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.hp5plus,
        filterStrength: 1.0,
        grainIntensity: 0.50,
        blurStrength: 0.0,
      ),

      EditPreset(
        id: 'default_bw_moody',
        name: 'B&W Moody',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.delta3200,
        filterStrength: 0.90,
        grainIntensity: 0.60,
        blurStrength: 0.0,
      ),

      // ═══════════════════════════════════════════
      // INSTANT / 인스턴트 프리셋
      // ═══════════════════════════════════════════
      EditPreset(
        id: 'default_instant_memory',
        name: 'Instant Memory',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.polaroid,
        filterStrength: 0.85,
        grainIntensity: 0.30,
        blurStrength: 0.10,
        aspectRatio: '1:1',
      ),

      EditPreset(
        id: 'default_instax_cute',
        name: 'Instax Cute',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.instax,
        filterStrength: 0.75,
        grainIntensity: 0.20,
        blurStrength: 0.05,
        aspectRatio: '1:1',
      ),

      // ═══════════════════════════════════════════
      // CINEMA / 시네마틱 프리셋
      // ═══════════════════════════════════════════
      EditPreset(
        id: 'default_cinema_night',
        name: 'Cinema Night',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.cinestill800t,
        filterStrength: 0.80,
        grainIntensity: 0.35,
        blurStrength: 0.0,
        aspectRatio: '16:9',
      ),

      EditPreset(
        id: 'default_cinema_day',
        name: 'Cinema Day',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.cinestill50d,
        filterStrength: 0.75,
        grainIntensity: 0.20,
        blurStrength: 0.0,
        aspectRatio: '16:9',
      ),

      EditPreset(
        id: 'default_hollywood',
        name: 'Hollywood',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.tealOrange,
        filterStrength: 0.70,
        grainIntensity: 0.15,
        blurStrength: 0.0,
        aspectRatio: '16:9',
      ),

      EditPreset(
        id: 'default_blockbuster',
        name: 'Blockbuster',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.bleachBypass,
        filterStrength: 0.65,
        grainIntensity: 0.25,
        blurStrength: 0.0,
        aspectRatio: '16:9',
      ),

      // ═══════════════════════════════════════════
      // LOMO / 로모 프리셋
      // ═══════════════════════════════════════════
      EditPreset(
        id: 'default_lomo_vibrant',
        name: 'Lomo Vibrant',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.lomoColor400,
        filterStrength: 0.80,
        grainIntensity: 0.40,
        blurStrength: 0.0,
      ),

      EditPreset(
        id: 'default_xpro_slide',
        name: 'X-Pro Slide',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.lomoXpro,
        filterStrength: 0.75,
        grainIntensity: 0.35,
        blurStrength: 0.0,
      ),

      EditPreset(
        id: 'default_redscale',
        name: 'Redscale',
        createdAt: now,
        isDefault: true,
        filmFilter: FilmFilter.lomoRedscale,
        filterStrength: 0.70,
        grainIntensity: 0.45,
        blurStrength: 0.0,
      ),
    ];
  }

  /// 특정 프리셋 ID로 가져오기
  static EditPreset? getById(String id) {
    try {
      return getAll().firstWhere((preset) => preset.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 기본 프리셋 설명
  static const descriptions = {
    'default_kodak_summer': '따뜻하고 부드러운 여름 인물 사진',
    'default_soft_portrait': '부드러운 스킨톤의 인물 사진',
    'default_wedding_classic': '웨딩 촬영에 적합한 우아한 색감',
    'default_studio_light': '스튜디오 조명에 최적화된 프리셋',
    'default_fuji_landscape': '선명하고 채도 높은 풍경 사진',
    'default_vivid_nature': '생동감 넘치는 자연 사진',
    'default_natural_colors': '자연스러운 색상의 균형 잡힌 사진',
    'default_sharp_ektar': '선명하고 정밀한 풍경/건축 사진',
    'default_lofi_vintage': '빈티지 로파이 감성의 일상 사진',
    'default_90s_japan': '90년대 일본 감성의 추억',
    'default_70s_warm': '70년대 따뜻한 복고풍',
    'default_faded_memory': '바래진 추억의 감성',
    'default_expired_film': '유효기간 지난 필름의 독특한 색감',
    'default_bw_classic': '클래식 흑백 필름 느낌',
    'default_bw_fine': '미세 입자의 고급스러운 흑백',
    'default_bw_street': '스트릿 사진용 강렬한 흑백',
    'default_bw_moody': '무디하고 분위기 있는 흑백',
    'default_instant_memory': '폴라로이드 인스턴트 필름 감성',
    'default_instax_cute': '밝고 귀여운 인스턴트 느낌',
    'default_cinema_night': '시네마틱 야간 촬영 분위기',
    'default_cinema_day': '시네마틱 주간 촬영 분위기',
    'default_hollywood': '할리우드 영화 색보정 스타일',
    'default_blockbuster': '블록버스터 영화 스타일',
    'default_lomo_vibrant': '생동감 넘치는 로모 스타일',
    'default_xpro_slide': '크로스 프로세스 슬라이드 효과',
    'default_redscale': '붉은색 강조 레드스케일 효과',
  };

  /// 프리셋 설명 가져오기
  static String getDescription(String id) {
    return descriptions[id] ?? '';
  }

  /// 카테고리별 프리셋 가져오기
  static List<EditPreset> getByCategory(String category) {
    final all = getAll();
    switch (category) {
      case 'portrait':
        return all.where((p) =>
          p.id.contains('portrait') ||
          p.id.contains('summer') ||
          p.id.contains('wedding') ||
          p.id.contains('studio')).toList();
      case 'landscape':
        return all.where((p) =>
          p.id.contains('landscape') ||
          p.id.contains('nature') ||
          p.id.contains('natural') ||
          p.id.contains('ektar')).toList();
      case 'vintage':
        return all.where((p) =>
          p.id.contains('vintage') ||
          p.id.contains('90s') ||
          p.id.contains('70s') ||
          p.id.contains('faded') ||
          p.id.contains('expired')).toList();
      case 'bw':
        return all.where((p) => p.id.contains('bw')).toList();
      case 'instant':
        return all.where((p) =>
          p.id.contains('instant') ||
          p.id.contains('instax')).toList();
      case 'cinema':
        return all.where((p) =>
          p.id.contains('cinema') ||
          p.id.contains('hollywood') ||
          p.id.contains('blockbuster')).toList();
      case 'lomo':
        return all.where((p) =>
          p.id.contains('lomo') ||
          p.id.contains('xpro') ||
          p.id.contains('redscale')).toList();
      default:
        return all;
    }
  }
}
