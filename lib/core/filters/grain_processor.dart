import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../utils/image_utils.dart';

/// 그레인/노이즈 효과 처리 클래스
class GrainProcessor {
  static final math.Random _random = math.Random();

  /// 가우시안 노이즈 추가
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [sigma]: 노이즈 표준편차 (0-100, 권장: 5-25)
  /// Returns: 노이즈가 추가된 이미지 바이트
  static Uint8List? addGaussianNoise(
    Uint8List imageBytes,
    double sigma, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      // sigma 범위 제한
      final clampedSigma = sigma.clamp(0.0, 100.0);

      // image 패키지의 noise 함수 사용
      final noisy = img.noise(image, clampedSigma, type: img.NoiseType.gaussian);

      return ImageUtils.imageToUint8List(noisy, quality: quality);
    } catch (e) {
      print('Error adding gaussian noise: $e');
      return null;
    }
  }

  /// 필름 그레인 효과 (사실적인 필름 느낌)
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [intensity]: 그레인 강도 (0.0-1.0)
  /// [size]: 그레인 크기 (1-5, 1=세밀, 5=거침)
  /// Returns: 필름 그레인이 추가된 이미지 바이트
  static Uint8List? addFilmGrain(
    Uint8List imageBytes,
    double intensity, {
    int size = 1,
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      // 강도 범위 제한
      final clampedIntensity = intensity.clamp(0.0, 1.0);
      final clampedSize = size.clamp(1, 5);

      // 가우시안 노이즈를 기반으로 필름 그레인 시뮬레이션
      // sigma 값을 강도에 비례하여 조정
      final sigma = clampedIntensity * 25.0 * clampedSize;

      final grainy = img.noise(image, sigma, type: img.NoiseType.gaussian);

      return ImageUtils.imageToUint8List(grainy, quality: quality);
    } catch (e) {
      print('Error adding film grain: $e');
      return null;
    }
  }

  /// 흑백 필름 그레인 (그레이스케일에 최적화)
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [intensity]: 그레인 강도 (0.0-1.0)
  /// Returns: 흑백 필름 그레인이 추가된 이미지 바이트
  static Uint8List? addMonochromeGrain(
    Uint8List imageBytes,
    double intensity, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      // 그레이스케일 변환
      final grayscale = img.grayscale(image);

      // 강도 범위 제한
      final clampedIntensity = intensity.clamp(0.0, 1.0);
      final sigma = clampedIntensity * 30.0;

      // 노이즈 추가
      final grainy = img.noise(grayscale, sigma, type: img.NoiseType.gaussian);

      return ImageUtils.imageToUint8List(grainy, quality: quality);
    } catch (e) {
      print('Error adding monochrome grain: $e');
      return null;
    }
  }

  /// 컬러 노이즈 (RGB 채널별로 독립적인 노이즈)
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [intensity]: 노이즈 강도 (0.0-1.0)
  /// Returns: 컬러 노이즈가 추가된 이미지 바이트
  static Uint8List? addColorNoise(
    Uint8List imageBytes,
    double intensity, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final clampedIntensity = intensity.clamp(0.0, 1.0);
      final noiseAmount = (clampedIntensity * 50).toInt();

      // 각 픽셀에 랜덤 노이즈 추가
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);

          // RGB 채널별로 독립적인 노이즈 생성
          final noiseR = _random.nextInt(noiseAmount * 2) - noiseAmount;
          final noiseG = _random.nextInt(noiseAmount * 2) - noiseAmount;
          final noiseB = _random.nextInt(noiseAmount * 2) - noiseAmount;

          final r = (pixel.r + noiseR).clamp(0, 255).toInt();
          final g = (pixel.g + noiseG).clamp(0, 255).toInt();
          final b = (pixel.b + noiseB).clamp(0, 255).toInt();

          image.setPixelRgb(x, y, r, g, b);
        }
      }

      return ImageUtils.imageToUint8List(image, quality: quality);
    } catch (e) {
      print('Error adding color noise: $e');
      return null;
    }
  }

  /// Salt and Pepper 노이즈
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [density]: 노이즈 밀도 (0.0-0.1, 권장: 0.01-0.05)
  /// Returns: Salt and Pepper 노이즈가 추가된 이미지 바이트
  static Uint8List? addSaltPepperNoise(
    Uint8List imageBytes,
    double density, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final clampedDensity = density.clamp(0.0, 0.1);

      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final rand = _random.nextDouble();

          if (rand < clampedDensity / 2) {
            // Salt (white)
            image.setPixelRgb(x, y, 255, 255, 255);
          } else if (rand < clampedDensity) {
            // Pepper (black)
            image.setPixelRgb(x, y, 0, 0, 0);
          }
        }
      }

      return ImageUtils.imageToUint8List(image, quality: quality);
    } catch (e) {
      print('Error adding salt and pepper noise: $e');
      return null;
    }
  }

  /// 빈티지 필름 그레인 (어두운 영역에 강조)
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [intensity]: 그레인 강도 (0.0-1.0)
  /// Returns: 빈티지 필름 그레인이 추가된 이미지 바이트
  static Uint8List? addVintageGrain(
    Uint8List imageBytes,
    double intensity, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final clampedIntensity = intensity.clamp(0.0, 1.0);

      // 어두운 영역에 더 강한 노이즈 적용
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);

          // 픽셀 밝기 계산 (0-255)
          final luminance = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).toInt();

          // 어두운 영역일수록 노이즈 강도 증가
          final noiseMultiplier = 1.0 - (luminance / 255.0);
          final noiseAmount = (clampedIntensity * 40 * noiseMultiplier).toInt();

          final noise = _random.nextInt(noiseAmount * 2) - noiseAmount;

          final r = (pixel.r + noise).clamp(0, 255).toInt();
          final g = (pixel.g + noise).clamp(0, 255).toInt();
          final b = (pixel.b + noise).clamp(0, 255).toInt();

          image.setPixelRgb(x, y, r, g, b);
        }
      }

      return ImageUtils.imageToUint8List(image, quality: quality);
    } catch (e) {
      print('Error adding vintage grain: $e');
      return null;
    }
  }

  /// 그레인 강도 프리셋
  static const double grainSubtle = 0.15;
  static const double grainLight = 0.3;
  static const double grainMedium = 0.5;
  static const double grainHeavy = 0.7;
  static const double grainExtreme = 0.9;

  /// 필름 종류별 권장 그레인 강도
  static double getRecommendedGrainForFilm(String filmType) {
    switch (filmType.toLowerCase()) {
      case 'kodakportra400':
      case 'fujivelvia50':
        return grainSubtle;
      case 'kodakgold200':
      case 'fujisuperia400':
        return grainLight;
      case 'ilfordhp5':
      case 'kodaktrix400':
        return grainMedium;
      case 'kodakp3200':
        return grainHeavy;
      default:
        return grainLight;
    }
  }
}
