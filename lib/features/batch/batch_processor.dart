import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../core/models/batch_progress.dart';
import '../../core/models/preset.dart';

/// 일괄 처리기
class BatchProcessor {
  final List<String> _imagePaths;
  final PresetSettings _settings;
  final StreamController<BatchProgress> _progressController;
  bool _cancelled = false;

  BatchProcessor({
    required List<String> imagePaths,
    required PresetSettings settings,
  })  : _imagePaths = imagePaths,
        _settings = settings,
        _progressController = StreamController<BatchProgress>.broadcast();

  Stream<BatchProgress> get progressStream => _progressController.stream;

  /// 일괄 처리 시작
  Future<BatchResult> process() async {
    final startTime = DateTime.now();
    final successPaths = <String>[];
    final failedPaths = <String>[];
    final errors = <String, String>{};

    _progressController.add(BatchProgress(
      total: _imagePaths.length,
      completed: 0,
      failed: 0,
      status: BatchStatus.processing,
    ));

    for (int i = 0; i < _imagePaths.length; i++) {
      if (_cancelled) {
        _progressController.add(BatchProgress(
          total: _imagePaths.length,
          completed: successPaths.length,
          failed: failedPaths.length,
          status: BatchStatus.cancelled,
        ));
        break;
      }

      final imagePath = _imagePaths[i];
      final fileName = path.basename(imagePath);

      _progressController.add(BatchProgress(
        total: _imagePaths.length,
        completed: successPaths.length,
        failed: failedPaths.length,
        currentFileName: fileName,
        status: BatchStatus.processing,
      ));

      try {
        final outputPath = await _processImage(imagePath, _settings);
        successPaths.add(outputPath);
      } catch (e) {
        failedPaths.add(imagePath);
        errors[imagePath] = e.toString();

        _progressController.add(BatchProgress(
          total: _imagePaths.length,
          completed: successPaths.length,
          failed: failedPaths.length,
          currentFileName: fileName,
          errorMessage: e.toString(),
          status: BatchStatus.processing,
        ));
      }
    }

    final duration = DateTime.now().difference(startTime);
    final result = BatchResult(
      successPaths: successPaths,
      failedPaths: failedPaths,
      errors: errors,
      duration: duration,
    );

    _progressController.add(BatchProgress(
      total: _imagePaths.length,
      completed: successPaths.length,
      failed: failedPaths.length,
      status: _cancelled ? BatchStatus.cancelled : BatchStatus.completed,
    ));

    await _progressController.close();

    return result;
  }

  /// 단일 이미지 처리
  Future<String> _processImage(String imagePath, PresetSettings settings) async {
    // Isolate를 사용한 백그라운드 처리
    return compute(_processImageIsolate, {
      'imagePath': imagePath,
      'settings': settings.toJson(),
    });
  }

  /// 처리 취소
  void cancel() {
    _cancelled = true;
  }
}

/// Isolate에서 실행되는 이미지 처리 함수
Future<String> _processImageIsolate(Map<String, dynamic> params) async {
  final imagePath = params['imagePath'] as String;
  final settingsJson = params['settings'] as Map<String, dynamic>;
  final settings = PresetSettings.fromJson(settingsJson);

  // 이미지 로드
  final bytes = await File(imagePath).readAsBytes();
  img.Image? image = img.decodeImage(bytes);

  if (image == null) {
    throw Exception('Failed to decode image');
  }

  // 밝기 조절
  if (settings.brightness != 0) {
    final brightness = (settings.brightness * 100).toInt();
    image = img.adjustColor(image, brightness: brightness);
  }

  // 대비 조절
  if (settings.contrast != 0) {
    final contrast = 1.0 + settings.contrast;
    image = img.adjustColor(image, contrast: contrast);
  }

  // 채도 조절
  if (settings.saturation != 0) {
    final saturation = 1.0 + settings.saturation;
    image = img.adjustColor(image, saturation: saturation);
  }

  // 블러 효과
  if (settings.blur > 0) {
    final blurAmount = (settings.blur * 10).toInt();
    image = img.gaussianBlur(image, radius: blurAmount);
  }

  // 그레인 효과
  if (settings.grain > 0) {
    image = _applyGrain(image, settings.grain);
  }

  // 필름 필터
  image = _applyFilmFilter(image, settings.filmFilter);

  // 틴트 컬러
  if (settings.tintColor != null && settings.tintOpacity > 0) {
    image = _applyTint(image, settings.tintColor!, settings.tintOpacity);
  }

  // 저장
  final directory = await getApplicationDocumentsDirectory();
  final outputDir = Directory('${directory.path}/processed');
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  final fileName = path.basename(imagePath);
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final outputPath = '${outputDir.path}/processed_${timestamp}_$fileName';

  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(img.encodeJpg(image, quality: 95));

  return outputPath;
}

/// 그레인 효과 적용
img.Image _applyGrain(img.Image image, double intensity) {
  final grain = img.Image(width: image.width, height: image.height);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final noise = ((x * y) % 255) / 255.0 * intensity;

      final r = (pixel.r + noise * 255).clamp(0, 255).toInt();
      final g = (pixel.g + noise * 255).clamp(0, 255).toInt();
      final b = (pixel.b + noise * 255).clamp(0, 255).toInt();

      grain.setPixelRgb(x, y, r, g, b);
    }
  }

  return grain;
}

/// 필름 필터 적용
img.Image _applyFilmFilter(img.Image image, FilmFilter filter) {
  switch (filter) {
    case FilmFilter.kodakSummer:
      // 따뜻한 톤
      return img.adjustColor(image,
        brightness: 10,
        contrast: 1.15,
        saturation: 1.2,
      );

    case FilmFilter.fujiLandscape:
      // 자연스러운 색감
      return img.adjustColor(image,
        brightness: 5,
        contrast: 1.2,
        saturation: 1.15,
      );

    case FilmFilter.lofiVintage:
      // 빈티지 느낌
      return img.adjustColor(image,
        brightness: -10,
        contrast: 1.25,
        saturation: 0.8,
      );

    case FilmFilter.portra400:
      // 부드러운 인물
      return img.adjustColor(image,
        brightness: 15,
        contrast: 1.1,
        saturation: 1.1,
      );

    case FilmFilter.cinestill800T:
      // 시네마틱
      return img.adjustColor(image,
        brightness: 20,
        contrast: 1.3,
        saturation: 1.25,
      );

    case FilmFilter.none:
      return image;
  }
}

/// 틴트 컬러 적용
img.Image _applyTint(img.Image image, Color tintColor, double opacity) {
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      final r = (pixel.r + (tintColor.red - pixel.r) * opacity).clamp(0, 255).toInt();
      final g = (pixel.g + (tintColor.green - pixel.g) * opacity).clamp(0, 255).toInt();
      final b = (pixel.b + (tintColor.blue - pixel.b) * opacity).clamp(0, 255).toInt();

      image.setPixelRgb(x, y, r, g, b);
    }
  }

  return image;
}
