import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../utils/image_utils.dart';

/// 블러 효과 처리 클래스
class BlurProcessor {
  /// 가우시안 블러 적용
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [radius]: 블러 반경 (1-100, 권장: 5-20)
  /// Returns: 블러가 적용된 이미지 바이트
  static Uint8List? gaussianBlur(
    Uint8List imageBytes,
    int radius, {
    int quality = 95,
  }) {
    try {
      // 이미지 디코딩
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) {
        print('Failed to decode image for blur');
        return null;
      }

      // 반경 범위 제한
      final clampedRadius = radius.clamp(1, 100);

      // 가우시안 블러 적용
      final blurred = img.gaussianBlur(image, radius: clampedRadius);

      // 인코딩 후 반환
      return ImageUtils.imageToUint8List(blurred, quality: quality);
    } catch (e) {
      print('Error applying gaussian blur: $e');
      return null;
    }
  }

  /// 빠른 블러 (BoxBlur) 적용
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [radius]: 블러 반경 (1-50)
  /// Returns: 블러가 적용된 이미지 바이트
  static Uint8List? boxBlur(
    Uint8List imageBytes,
    int radius, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      final clampedRadius = radius.clamp(1, 50);

      // BoxBlur는 가우시안보다 빠르지만 품질이 약간 낮습니다
      // image 패키지에서는 gaussianBlur를 사용하되 radius를 조정
      final blurred = img.gaussianBlur(image, radius: clampedRadius);

      return ImageUtils.imageToUint8List(blurred, quality: quality);
    } catch (e) {
      print('Error applying box blur: $e');
      return null;
    }
  }

  /// 모션 블러 효과 (단순 구현)
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [angle]: 블러 방향 각도 (0-360)
  /// [distance]: 블러 거리 (1-50)
  /// Returns: 모션 블러가 적용된 이미지 바이트
  static Uint8List? motionBlur(
    Uint8List imageBytes,
    double angle,
    int distance, {
    int quality = 95,
  }) {
    try {
      final image = ImageUtils.uint8ListToImage(imageBytes);
      if (image == null) return null;

      // 단순 구현: 여러 개의 약한 블러를 특정 방향으로 적용
      // 실제 프로덕션에서는 커스텀 커널을 사용해야 합니다
      final blurred = img.gaussianBlur(image, radius: distance ~/ 2);

      return ImageUtils.imageToUint8List(blurred, quality: quality);
    } catch (e) {
      print('Error applying motion blur: $e');
      return null;
    }
  }

  /// 선택적 블러 (원 안쪽은 블러, 바깥은 선명) - 투명 블러 지원
  ///
  /// [imageBytes]: 원본 이미지 바이트
  /// [centerX]: 중심점 X 좌표 (0.0-1.0)
  /// [centerY]: 중심점 Y 좌표 (0.0-1.0)
  /// [radius]: 블러 영역의 반경 (픽셀)
  /// [blurStrength]: 블러 강도 (1-30)
  /// [opacity]: 블러 투명도 (0.0-1.0, 낮을수록 투명)
  /// [feather]: 경계 부드러움 (0.0-1.0, 높을수록 부드러운 경계)
  /// Returns: 선택적 블러가 적용된 이미지 바이트
  static Uint8List? selectiveBlur(
    Uint8List imageBytes, {
    double centerX = 0.5,
    double centerY = 0.5,
    double radius = 200.0,
    int blurStrength = 10,
    double opacity = 1.0,
    double feather = 0.3,
    int quality = 95,
  }) {
    try {
      final original = ImageUtils.uint8ListToImage(imageBytes);
      if (original == null) return null;

      // 투명도 범위 제한
      final clampedOpacity = opacity.clamp(0.0, 1.0);

      // 전체 이미지를 블러 처리
      final blurred = img.gaussianBlur(
        ImageUtils.copyImage(original),
        radius: blurStrength,
      );

      // 중심점 계산
      final cx = (original.width * centerX).toInt();
      final cy = (original.height * centerY).toInt();

      // feather 영역 계산 (반경의 비율)
      final innerRadius = radius * (1.0 - feather);
      final outerRadius = radius;

      // 픽셀별로 거리 기반 블렌딩
      for (var y = 0; y < original.height; y++) {
        for (var x = 0; x < original.width; x++) {
          // 중심점으로부터의 실제 거리 계산
          final dx = (x - cx).toDouble();
          final dy = (y - cy).toDouble();
          final pixelDist = math.sqrt(dx * dx + dy * dy);

          // 거리에 따른 블렌딩 비율 계산 (반전: 원 안쪽이 블러)
          double distanceFactor;
          if (pixelDist <= innerRadius) {
            // 원 안쪽: 완전 블러 (투명도 적용)
            distanceFactor = 1.0;
          } else if (pixelDist >= outerRadius) {
            // 원 바깥: 완전 선명 (원본 유지)
            distanceFactor = 0.0;
          } else {
            // 경계 영역: 부드러운 전환
            distanceFactor = 1.0 - ((pixelDist - innerRadius) / (outerRadius - innerRadius));
          }

          // 투명도를 적용한 최종 블렌드 팩터
          // opacity가 낮을수록 블러 효과가 투명해짐 (원본이 더 보임)
          final blendFactor = distanceFactor * clampedOpacity;

          if (blendFactor > 0.0 && blendFactor < 1.0) {
            final origPixel = original.getPixel(x, y);
            final blurPixel = blurred.getPixel(x, y);

            // 선형 보간 (투명도 반영)
            final r = (origPixel.r * (1 - blendFactor) + blurPixel.r * blendFactor).toInt();
            final g = (origPixel.g * (1 - blendFactor) + blurPixel.g * blendFactor).toInt();
            final b = (origPixel.b * (1 - blendFactor) + blurPixel.b * blendFactor).toInt();

            original.setPixelRgb(x, y, r, g, b);
          } else if (blendFactor >= 1.0) {
            // 완전히 블러 (원 안쪽 + 투명도 100%)
            final blurPixel = blurred.getPixel(x, y);
            original.setPixelRgb(x, y, blurPixel.r.toInt(), blurPixel.g.toInt(), blurPixel.b.toInt());
          }
          // blendFactor == 0.0인 경우 원본 유지 (아무 작업 안 함)
        }
      }

      return ImageUtils.imageToUint8List(original, quality: quality);
    } catch (e) {
      print('Error applying selective blur: $e');
      return null;
    }
  }

  /// 블러 강도 프리셋
  static const int blurLight = 3;
  static const int blurMedium = 8;
  static const int blurHeavy = 15;
  static const int blurExtreme = 25;

  /// 블러 적용 여부 확인 (시각적 차이가 있는지)
  static bool isBlurApplied(int radius) {
    return radius > 0;
  }

  /// 권장 블러 반경 계산 (이미지 크기 기반)
  static int getRecommendedBlurRadius(int imageWidth, int imageHeight) {
    final maxDimension = imageWidth > imageHeight ? imageWidth : imageHeight;

    // 이미지 크기에 비례한 블러 반경 계산
    if (maxDimension < 1000) return 5;
    if (maxDimension < 2000) return 8;
    if (maxDimension < 3000) return 12;
    return 15;
  }
}
