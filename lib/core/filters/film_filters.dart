import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../utils/image_utils.dart';

/// 필름 필터 타입
enum FilmFilter {
  none,
  kodakPortra400,
  kodakGold200,
  fujiVelvia50,
  fujiSuperia400,
  ilfordHP5,
  kodakTriX400,
  kodakEktar100,
  fujiProvia100F,
  cinestill800T,
  kodakP3200,
}

/// 필름 필터 확장 메서드
extension FilmFilterExtension on FilmFilter {
  String get displayName {
    switch (this) {
      case FilmFilter.none:
        return 'None';
      case FilmFilter.kodakPortra400:
        return 'Kodak Portra 400';
      case FilmFilter.kodakGold200:
        return 'Kodak Gold 200';
      case FilmFilter.fujiVelvia50:
        return 'Fuji Velvia 50';
      case FilmFilter.fujiSuperia400:
        return 'Fuji Superia 400';
      case FilmFilter.ilfordHP5:
        return 'Ilford HP5';
      case FilmFilter.kodakTriX400:
        return 'Kodak Tri-X 400';
      case FilmFilter.kodakEktar100:
        return 'Kodak Ektar 100';
      case FilmFilter.fujiProvia100F:
        return 'Fuji Provia 100F';
      case FilmFilter.cinestill800T:
        return 'Cinestill 800T';
      case FilmFilter.kodakP3200:
        return 'Kodak P3200';
    }
  }

  String get description {
    switch (this) {
      case FilmFilter.none:
        return 'No filter applied';
      case FilmFilter.kodakPortra400:
        return 'Warm, natural skin tones';
      case FilmFilter.kodakGold200:
        return 'Warm, golden hues';
      case FilmFilter.fujiVelvia50:
        return 'Vivid, saturated colors';
      case FilmFilter.fujiSuperia400:
        return 'Balanced, versatile';
      case FilmFilter.ilfordHP5:
        return 'Classic black & white';
      case FilmFilter.kodakTriX400:
        return 'Contrasty black & white';
      case FilmFilter.kodakEktar100:
        return 'Ultra-fine grain, vivid';
      case FilmFilter.fujiProvia100F:
        return 'Neutral, accurate colors';
      case FilmFilter.cinestill800T:
        return 'Cinematic, tungsten balanced';
      case FilmFilter.kodakP3200:
        return 'High-speed black & white';
    }
  }

  bool get isBlackAndWhite {
    return this == FilmFilter.ilfordHP5 ||
        this == FilmFilter.kodakTriX400 ||
        this == FilmFilter.kodakP3200;
  }
}

/// 필름 필터 처리 클래스
class FilmFilters {
  /// 필름 필터 적용
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [filter]: 적용할 필름 필터
  /// [strength]: 필터 강도 (0.0-1.0, 1.0 = 100% 적용)
  /// Returns: 필터가 적용된 이미지 바이트
  static Uint8List? applyFilter(
    Uint8List imageBytes,
    FilmFilter filter,
    double strength, {
    int quality = 95,
  }) {
    try {
      if (filter == FilmFilter.none) {
        return imageBytes;
      }

      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final clampedStrength = strength.clamp(0.0, 1.0);

      img.Image filtered;

      switch (filter) {
        case FilmFilter.none:
          filtered = image;
          break;
        case FilmFilter.kodakPortra400:
          filtered = _applyKodakPortra400(image, clampedStrength);
          break;
        case FilmFilter.kodakGold200:
          filtered = _applyKodakGold200(image, clampedStrength);
          break;
        case FilmFilter.fujiVelvia50:
          filtered = _applyFujiVelvia50(image, clampedStrength);
          break;
        case FilmFilter.fujiSuperia400:
          filtered = _applyFujiSuperia400(image, clampedStrength);
          break;
        case FilmFilter.ilfordHP5:
          filtered = _applyIlfordHP5(image, clampedStrength);
          break;
        case FilmFilter.kodakTriX400:
          filtered = _applyKodakTriX400(image, clampedStrength);
          break;
        case FilmFilter.kodakEktar100:
          filtered = _applyKodakEktar100(image, clampedStrength);
          break;
        case FilmFilter.fujiProvia100F:
          filtered = _applyFujiProvia100F(image, clampedStrength);
          break;
        case FilmFilter.cinestill800T:
          filtered = _applyCinestill800T(image, clampedStrength);
          break;
        case FilmFilter.kodakP3200:
          filtered = _applyKodakP3200(image, clampedStrength);
          break;
      }

      return ImageUtils.imageToUint8List(filtered, quality: quality);
    } catch (e) {
      print('Error applying film filter: $e');
      return null;
    }
  }

  /// Kodak Portra 400 - 따뜻하고 자연스러운 피부톤
  static img.Image _applyKodakPortra400(img.Image image, double strength) {
    // 약간 따뜻한 톤 + 부드러운 대비 + 약간 감소된 채도
    final adjusted = img.adjustColor(
      image,
      brightness: 1.02 * strength,
      saturation: 1.0 - (0.1 * strength),
      contrast: 1.0 - (0.05 * strength),
    );

    // 따뜻한 색조 추가 (Red +5, Green +3, Blue -3)
    return _applyColorShift(adjusted, 5 * strength, 3 * strength, -3 * strength);
  }

  /// Kodak Gold 200 - 따뜻하고 황금빛 색조
  static img.Image _applyKodakGold200(img.Image image, double strength) {
    // 강한 따뜻한 톤 + 약간 증가된 채도
    final adjusted = img.adjustColor(
      image,
      brightness: 1.05 * strength,
      saturation: 1.0 + (0.15 * strength),
      contrast: 1.0 + (0.1 * strength),
    );

    // 황금빛 색조 (Red +10, Green +5, Blue -5)
    return _applyColorShift(adjusted, 10 * strength, 5 * strength, -5 * strength);
  }

  /// Fuji Velvia 50 - 매우 선명하고 채도 높은 색상
  static img.Image _applyFujiVelvia50(img.Image image, double strength) {
    // 높은 채도 + 강한 대비
    final adjusted = img.adjustColor(
      image,
      saturation: 1.0 + (0.4 * strength),
      contrast: 1.0 + (0.2 * strength),
    );

    // 약간 차가운 톤 (Red -3, Green +2, Blue +5)
    return _applyColorShift(adjusted, -3 * strength, 2 * strength, 5 * strength);
  }

  /// Fuji Superia 400 - 균형잡힌 범용 필름
  static img.Image _applyFujiSuperia400(img.Image image, double strength) {
    // 약간 증가된 채도 + 중간 대비
    return img.adjustColor(
      image,
      saturation: 1.0 + (0.1 * strength),
      contrast: 1.0 + (0.05 * strength),
      brightness: 1.02 * strength,
    );
  }

  /// Ilford HP5 - 클래식한 흑백 필름
  static img.Image _applyIlfordHP5(img.Image image, double strength) {
    final grayscale = img.grayscale(image);

    if (strength < 1.0) {
      // 원본과 흑백을 블렌딩
      return _blendImages(image, grayscale, strength);
    }

    // 약간 부드러운 대비
    return img.adjustColor(
      grayscale,
      contrast: 1.0 + (0.1 * strength),
    );
  }

  /// Kodak Tri-X 400 - 대비가 강한 흑백 필름
  static img.Image _applyKodakTriX400(img.Image image, double strength) {
    final grayscale = img.grayscale(image);

    if (strength < 1.0) {
      return _blendImages(image, grayscale, strength);
    }

    // 강한 대비 + 약간 어둡게
    return img.adjustColor(
      grayscale,
      contrast: 1.0 + (0.3 * strength),
      brightness: 1.0 - (0.05 * strength),
    );
  }

  /// Kodak Ektar 100 - 초미세입자, 선명한 색상
  static img.Image _applyKodakEktar100(img.Image image, double strength) {
    // 높은 채도 + 강한 선명도
    final adjusted = img.adjustColor(
      image,
      saturation: 1.0 + (0.3 * strength),
      contrast: 1.0 + (0.15 * strength),
    );

    return adjusted;
  }

  /// Fuji Provia 100F - 중립적이고 정확한 색상
  static img.Image _applyFujiProvia100F(img.Image image, double strength) {
    // 매우 약한 조정 - 자연스러운 색상
    return img.adjustColor(
      image,
      saturation: 1.0 + (0.05 * strength),
      contrast: 1.0 + (0.05 * strength),
    );
  }

  /// Cinestill 800T - 영화적이고 텅스텐 밸런스
  static img.Image _applyCinestill800T(img.Image image, double strength) {
    // 차가운 톤 + 약간 증가된 대비
    final adjusted = img.adjustColor(
      image,
      contrast: 1.0 + (0.15 * strength),
      saturation: 1.0 - (0.05 * strength),
    );

    // 시네마틱 블루 톤 (Red -5, Green +2, Blue +10)
    return _applyColorShift(adjusted, -5 * strength, 2 * strength, 10 * strength);
  }

  /// Kodak P3200 - 고감도 흑백 필름
  static img.Image _applyKodakP3200(img.Image image, double strength) {
    final grayscale = img.grayscale(image);

    if (strength < 1.0) {
      return _blendImages(image, grayscale, strength);
    }

    // 강한 대비 + 약간 밝게 (고감도 느낌)
    return img.adjustColor(
      grayscale,
      contrast: 1.0 + (0.25 * strength),
      brightness: 1.0 + (0.1 * strength),
    );
  }

  /// 색상 시프트 적용 (RGB 채널별 조정)
  static img.Image _applyColorShift(
    img.Image image,
    double redShift,
    double greenShift,
    double blueShift,
  ) {
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        final r = (pixel.r + redShift).clamp(0, 255).toInt();
        final g = (pixel.g + greenShift).clamp(0, 255).toInt();
        final b = (pixel.b + blueShift).clamp(0, 255).toInt();

        image.setPixelRgb(x, y, r, g, b);
      }
    }

    return image;
  }

  /// 두 이미지 블렌딩
  static img.Image _blendImages(img.Image original, img.Image target, double strength) {
    final result = ImageUtils.copyImage(original);

    for (var y = 0; y < result.height; y++) {
      for (var x = 0; x < result.width; x++) {
        final origPixel = original.getPixel(x, y);
        final targetPixel = target.getPixel(x, y);

        final r = (origPixel.r * (1 - strength) + targetPixel.r * strength).toInt();
        final g = (origPixel.g * (1 - strength) + targetPixel.g * strength).toInt();
        final b = (origPixel.b * (1 - strength) + targetPixel.b * strength).toInt();

        result.setPixelRgb(x, y, r, g, b);
      }
    }

    return result;
  }

  /// 필터 프리뷰 썸네일 생성 (작은 크기로 빠른 처리)
  static Uint8List? generatePreview(
    Uint8List imageBytes,
    FilmFilter filter, {
    int thumbnailSize = 200,
    int quality = 85,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      // 썸네일 크기로 축소
      final thumbnail = img.copyResize(
        image,
        width: thumbnailSize,
        interpolation: img.Interpolation.average,
      );

      // 필터 적용 (100% 강도)
      final filtered = applyFilter(
        ImageUtils.imageToUint8List(thumbnail, quality: quality),
        filter,
        1.0,
        quality: quality,
      );

      return filtered;
    } catch (e) {
      print('Error generating filter preview: $e');
      return null;
    }
  }
}
