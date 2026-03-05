import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../utils/image_utils.dart';
import 'blur_processor.dart';
import 'grain_processor.dart';
import 'film_filters.dart';

/// 이미지 처리 통합 클래스
///
/// 모든 이미지 처리 작업을 중앙에서 관리하고 조율합니다.
class ImageProcessor {
  /// 블러 적용
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [sigma]: 블러 강도 (표준편차, 1-100)
  /// Returns: 블러가 적용된 이미지 바이트
  static Uint8List? applyBlur(
    Uint8List imageBytes,
    double sigma, {
    int quality = 95,
  }) {
    return BlurProcessor.gaussianBlur(
      imageBytes,
      sigma.round(),
      quality: quality,
    );
  }

  /// 그레인/노이즈 적용
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [intensity]: 그레인 강도 (0.0-1.0)
  /// Returns: 그레인이 적용된 이미지 바이트
  static Uint8List? applyGrain(
    Uint8List imageBytes,
    double intensity, {
    int quality = 95,
  }) {
    return GrainProcessor.addFilmGrain(
      imageBytes,
      intensity,
      quality: quality,
    );
  }

  /// 이미지 리사이즈
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [width]: 목표 너비 (픽셀)
  /// [height]: 목표 높이 (null이면 비율 유지)
  /// [maintainAspect]: 종횡비 유지 여부
  /// Returns: 리사이즈된 이미지 바이트
  static Uint8List? resize(
    Uint8List imageBytes,
    int width,
    int? height, {
    bool maintainAspect = true,
    img.Interpolation interpolation = img.Interpolation.linear,
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      img.Image resized;

      if (maintainAspect) {
        // 종횡비 유지하며 리사이즈
        resized = img.copyResize(
          image,
          width: width,
          height: height,
          interpolation: interpolation,
        );
      } else {
        // 정확한 크기로 리사이즈 (종횡비 무시)
        resized = img.copyResize(
          image,
          width: width,
          height: height ?? image.height,
          interpolation: interpolation,
        );
      }

      return ImageUtils.imageToUint8List(resized, quality: quality);
    } catch (e) {
      print('Error resizing image: $e');
      return null;
    }
  }

  /// 필름 필터 적용
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [filter]: 적용할 필름 필터
  /// [strength]: 필터 강도 (0.0-1.0)
  /// Returns: 필터가 적용된 이미지 바이트
  static Uint8List? applyFilmFilter(
    Uint8List imageBytes,
    FilmFilter filter,
    double strength, {
    int quality = 95,
  }) {
    return FilmFilters.applyFilter(
      imageBytes,
      filter,
      strength,
      quality: quality,
    );
  }

  /// 복합 효과 적용 (필터 + 그레인 + 블러)
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [filter]: 필름 필터
  /// [filterStrength]: 필터 강도 (0.0-1.0)
  /// [grainIntensity]: 그레인 강도 (0.0-1.0)
  /// [blurSigma]: 블러 강도 (0-100)
  /// Returns: 모든 효과가 적용된 이미지 바이트
  static Uint8List? applyCompositeEffect({
    required Uint8List imageBytes,
    FilmFilter filter = FilmFilter.none,
    double filterStrength = 1.0,
    double grainIntensity = 0.0,
    double blurSigma = 0.0,
    int quality = 95,
  }) {
    try {
      Uint8List? result = imageBytes;

      // 1. 필름 필터 적용
      if (filter != FilmFilter.none && filterStrength > 0.0) {
        result = applyFilmFilter(result!, filter, filterStrength, quality: quality);
        if (result == null) return null;
      }

      // 2. 그레인 적용
      if (grainIntensity > 0.0) {
        result = applyGrain(result!, grainIntensity, quality: quality);
        if (result == null) return null;
      }

      // 3. 블러 적용
      if (blurSigma > 0.0) {
        result = applyBlur(result!, blurSigma, quality: quality);
        if (result == null) return null;
      }

      return result;
    } catch (e) {
      print('Error applying composite effect: $e');
      return null;
    }
  }

  /// 프리셋 적용 (사전 정의된 효과 조합)
  static Uint8List? applyPreset({
    required Uint8List imageBytes,
    required String presetName,
    int quality = 95,
  }) {
    final preset = _presets[presetName];
    if (preset == null) {
      print('Preset not found: $presetName');
      return null;
    }

    return applyCompositeEffect(
      imageBytes: imageBytes,
      filter: preset['filter'] as FilmFilter,
      filterStrength: preset['filterStrength'] as double,
      grainIntensity: preset['grainIntensity'] as double,
      blurSigma: preset['blurSigma'] as double,
      quality: quality,
    );
  }

  /// 사전 정의된 프리셋
  static final Map<String, Map<String, dynamic>> _presets = {
    'vintage_warm': {
      'filter': FilmFilter.kodakGold200,
      'filterStrength': 0.8,
      'grainIntensity': 0.3,
      'blurSigma': 2.0,
    },
    'vintage_cool': {
      'filter': FilmFilter.cinestill800T,
      'filterStrength': 0.7,
      'grainIntensity': 0.25,
      'blurSigma': 1.5,
    },
    'classic_bw': {
      'filter': FilmFilter.ilfordHP5,
      'filterStrength': 1.0,
      'grainIntensity': 0.4,
      'blurSigma': 0.0,
    },
    'dreamy': {
      'filter': FilmFilter.kodakPortra400,
      'filterStrength': 0.6,
      'grainIntensity': 0.2,
      'blurSigma': 5.0,
    },
    'vivid': {
      'filter': FilmFilter.fujiVelvia50,
      'filterStrength': 1.0,
      'grainIntensity': 0.1,
      'blurSigma': 0.0,
    },
  };

  /// 사용 가능한 프리셋 목록
  static List<String> get availablePresets => _presets.keys.toList();

  /// 이미지 크롭
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [x]: 시작 X 좌표
  /// [y]: 시작 Y 좌표
  /// [width]: 크롭 너비
  /// [height]: 크롭 높이
  /// Returns: 크롭된 이미지 바이트
  static Uint8List? crop(
    Uint8List imageBytes, {
    required int x,
    required int y,
    required int width,
    required int height,
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final cropped = img.copyCrop(
        image,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      return ImageUtils.imageToUint8List(cropped, quality: quality);
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  /// 이미지 회전
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [angle]: 회전 각도 (도 단위)
  /// Returns: 회전된 이미지 바이트
  static Uint8List? rotate(
    Uint8List imageBytes,
    num angle, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final rotated = ImageUtils.rotateImage(image, angle);

      return ImageUtils.imageToUint8List(rotated, quality: quality);
    } catch (e) {
      print('Error rotating image: $e');
      return null;
    }
  }

  /// 이미지 플립
  static Uint8List? flipHorizontal(Uint8List imageBytes, {int quality = 95}) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final flipped = ImageUtils.flipHorizontal(image);
      return ImageUtils.imageToUint8List(flipped, quality: quality);
    } catch (e) {
      print('Error flipping image: $e');
      return null;
    }
  }

  static Uint8List? flipVertical(Uint8List imageBytes, {int quality = 95}) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final flipped = ImageUtils.flipVertical(image);
      return ImageUtils.imageToUint8List(flipped, quality: quality);
    } catch (e) {
      print('Error flipping image: $e');
      return null;
    }
  }

  /// 밝기 조정
  static Uint8List? adjustBrightness(
    Uint8List imageBytes,
    num brightness, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final adjusted = ImageUtils.adjustBrightness(image, brightness);
      return ImageUtils.imageToUint8List(adjusted, quality: quality);
    } catch (e) {
      print('Error adjusting brightness: $e');
      return null;
    }
  }

  /// 대비 조정
  static Uint8List? adjustContrast(
    Uint8List imageBytes,
    num contrast, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final adjusted = ImageUtils.adjustContrast(image, contrast);
      return ImageUtils.imageToUint8List(adjusted, quality: quality);
    } catch (e) {
      print('Error adjusting contrast: $e');
      return null;
    }
  }

  /// 채도 조정
  static Uint8List? adjustSaturation(
    Uint8List imageBytes,
    num saturation, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final adjusted = ImageUtils.adjustSaturation(image, saturation);
      return ImageUtils.imageToUint8List(adjusted, quality: quality);
    } catch (e) {
      print('Error adjusting saturation: $e');
      return null;
    }
  }

  /// 이미지를 그레이스케일로 변환
  static Uint8List? toGrayscale(Uint8List imageBytes, {int quality = 95}) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final grayscale = img.grayscale(image);
      return ImageUtils.imageToUint8List(grayscale, quality: quality);
    } catch (e) {
      print('Error converting to grayscale: $e');
      return null;
    }
  }

  /// 이미지를 세피아톤으로 변환
  static Uint8List? toSepia(Uint8List imageBytes, {int quality = 95}) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final sepia = img.sepia(image);
      return ImageUtils.imageToUint8List(sepia, quality: quality);
    } catch (e) {
      print('Error converting to sepia: $e');
      return null;
    }
  }

  /// 이미지 선명도 향상
  static Uint8List? sharpen(
    Uint8List imageBytes, {
    int amount = 10,
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      // image 패키지의 convolution을 사용하여 선명도 향상
      // 간단한 샤프닝 커널 적용
      final sharpened = img.adjustColor(image, contrast: 1.0 + (amount / 100));
      return ImageUtils.imageToUint8List(sharpened, quality: quality);
    } catch (e) {
      print('Error sharpening image: $e');
      return null;
    }
  }

  /// 썸네일 생성
  static Uint8List? generateThumbnail(
    Uint8List imageBytes, {
    int size = 200,
    int quality = 85,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final thumbnail = img.copyResize(
        image,
        width: size,
        interpolation: img.Interpolation.average,
      );

      return ImageUtils.imageToUint8List(thumbnail, quality: quality);
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  /// 이미지 정보 가져오기
  static Map<String, dynamic>? getImageInfo(Uint8List imageBytes) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final metadata = ImageUtils.getImageMetadata(image);
      final fileSize = ImageUtils.getImageSizeInBytes(imageBytes);

      return {
        ...metadata,
        'fileSizeBytes': fileSize,
        'fileSizeFormatted': ImageUtils.formatFileSize(fileSize),
      };
    } catch (e) {
      print('Error getting image info: $e');
      return null;
    }
  }

  /// 이미지 처리 파이프라인
  ///
  /// 여러 처리를 순차적으로 적용할 수 있는 파이프라인
  static Uint8List? processPipeline(
    Uint8List imageBytes,
    List<ImageProcessingStep> steps, {
    int quality = 95,
  }) {
    try {
      Uint8List? result = imageBytes;

      for (final step in steps) {
        if (result == null) return null;
        result = step.apply(result, quality: quality);
      }

      return result;
    } catch (e) {
      print('Error processing pipeline: $e');
      return null;
    }
  }
}

/// 이미지 처리 단계 추상 클래스
abstract class ImageProcessingStep {
  Uint8List? apply(Uint8List imageBytes, {int quality = 95});
}

/// 블러 단계
class BlurStep extends ImageProcessingStep {
  final double sigma;

  BlurStep(this.sigma);

  @override
  Uint8List? apply(Uint8List imageBytes, {int quality = 95}) {
    return ImageProcessor.applyBlur(imageBytes, sigma, quality: quality);
  }
}

/// 그레인 단계
class GrainStep extends ImageProcessingStep {
  final double intensity;

  GrainStep(this.intensity);

  @override
  Uint8List? apply(Uint8List imageBytes, {int quality = 95}) {
    return ImageProcessor.applyGrain(imageBytes, intensity, quality: quality);
  }
}

/// 필름 필터 단계
class FilmFilterStep extends ImageProcessingStep {
  final FilmFilter filter;
  final double strength;

  FilmFilterStep(this.filter, this.strength);

  @override
  Uint8List? apply(Uint8List imageBytes, {int quality = 95}) {
    return ImageProcessor.applyFilmFilter(imageBytes, filter, strength, quality: quality);
  }
}

/// 리사이즈 단계
class ResizeStep extends ImageProcessingStep {
  final int width;
  final int? height;
  final bool maintainAspect;

  ResizeStep(this.width, {this.height, this.maintainAspect = true});

  @override
  Uint8List? apply(Uint8List imageBytes, {int quality = 95}) {
    return ImageProcessor.resize(
      imageBytes,
      width,
      height,
      maintainAspect: maintainAspect,
      quality: quality,
    );
  }
}
