import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 이미지 변환 및 파일 처리 유틸리티
class ImageUtils {
  /// Uint8List를 img.Image로 변환
  static img.Image? uint8ListToImage(Uint8List bytes) {
    try {
      return img.decodeImage(bytes);
    } catch (e) {
      print('Error decoding image: $e');
      return null;
    }
  }

  /// img.Image를 Uint8List로 변환 (JPEG)
  static Uint8List imageToUint8List(
    img.Image image, {
    int quality = 95,
    img.JpegEncoder? encoder,
  }) {
    final jpegEncoder = encoder ?? img.JpegEncoder(quality: quality);
    return Uint8List.fromList(jpegEncoder.encode(image));
  }

  /// img.Image를 Uint8List로 변환 (PNG)
  static Uint8List imageToUint8ListPng(
    img.Image image, {
    int level = 6,
  }) {
    final pngEncoder = img.PngEncoder(level: level);
    return Uint8List.fromList(pngEncoder.encode(image));
  }

  /// 파일에서 이미지 로드
  static Future<Uint8List?> loadImageFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('File does not exist: $filePath');
        return null;
      }
      return await file.readAsBytes();
    } catch (e) {
      print('Error loading image from file: $e');
      return null;
    }
  }

  /// 이미지를 임시 디렉토리에 저장
  static Future<String?> saveToTempDirectory(
    Uint8List imageBytes, {
    String? filename,
    String extension = 'jpg',
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = filename ?? 'temp_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = path.join(tempDir.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e) {
      print('Error saving to temp directory: $e');
      return null;
    }
  }

  /// 이미지를 갤러리에 저장 가능한 디렉토리에 저장
  static Future<String?> saveToGallery(
    Uint8List imageBytes, {
    String? filename,
    String extension = 'jpg',
  }) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/DCIM/PhotoEdit');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // 디렉토리가 없으면 생성
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = filename ?? 'photoedit_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = path.join(directory.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e) {
      print('Error saving to gallery: $e');
      return null;
    }
  }

  /// 이미지 메타데이터 추출
  static Map<String, dynamic> getImageMetadata(img.Image image) {
    return {
      'width': image.width,
      'height': image.height,
      'numChannels': image.numChannels,
      'hasPalette': image.hasPalette,
      'aspectRatio': image.width / image.height,
      'totalPixels': image.width * image.height,
    };
  }

  /// 이미지 크기 계산 (바이트)
  static int getImageSizeInBytes(Uint8List imageBytes) {
    return imageBytes.length;
  }

  /// 이미지 크기를 읽기 쉬운 형식으로 변환
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// 이미지 복사 (deep copy)
  static img.Image copyImage(img.Image source) {
    return img.Image.from(source);
  }

  /// 이미지 회전
  static img.Image rotateImage(img.Image image, num angle) {
    return img.copyRotate(image, angle: angle);
  }

  /// 이미지 플립
  static img.Image flipHorizontal(img.Image image) {
    return img.flipHorizontal(image);
  }

  static img.Image flipVertical(img.Image image) {
    return img.flipVertical(image);
  }

  /// EXIF 데이터를 기반으로 이미지 자동 회전
  static img.Image autoOrient(img.Image image) {
    // image 패키지가 자동으로 EXIF orientation을 처리합니다
    return image;
  }

  /// 이미지 밝기 조정
  static img.Image adjustBrightness(img.Image image, num brightness) {
    return img.adjustColor(image, brightness: brightness);
  }

  /// 이미지 대비 조정
  static img.Image adjustContrast(img.Image image, num contrast) {
    return img.adjustColor(image, contrast: contrast);
  }

  /// 이미지 채도 조정
  static img.Image adjustSaturation(img.Image image, num saturation) {
    return img.adjustColor(image, saturation: saturation);
  }

  /// 파일 확장자 가져오기
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceAll('.', '');
  }

  /// 지원되는 이미지 형식인지 확인
  static bool isSupportedImageFormat(String filePath) {
    final extension = getFileExtension(filePath);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff'].contains(extension);
  }
}
