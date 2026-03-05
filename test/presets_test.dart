import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:photoedit/core/presets/presets.dart';
import 'package:photoedit/core/filters/film_filter.dart';

void main() {
  late PresetRepository repository;

  setUp(() async {
    // SharedPreferences 모킹
    SharedPreferences.setMockInitialValues({});
    repository = await PresetRepository.create();
  });

  group('EditPreset 모델 테스트', () {
    test('JSON 직렬화/역직렬화', () {
      final preset = EditPreset(
        id: 'test-id',
        name: 'Test Preset',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        isDefault: false,
        filmFilter: FilmFilter.portra400,
        filterStrength: 0.8,
        grainIntensity: 0.25,
        blurStrength: 0.0,
        aspectRatio: '1:1',
        outputWidth: 1080,
      );

      final json = preset.toJson();
      final restored = EditPreset.fromJson(json);

      expect(restored.id, preset.id);
      expect(restored.name, preset.name);
      expect(restored.filmFilter, preset.filmFilter);
      expect(restored.filterStrength, preset.filterStrength);
      expect(restored.grainIntensity, preset.grainIntensity);
      expect(restored.aspectRatio, preset.aspectRatio);
      expect(restored.outputWidth, preset.outputWidth);
    });

    test('copyWith 메서드', () {
      final preset = EditPreset(
        id: 'test-id',
        name: 'Original',
        createdAt: DateTime.now(),
        filterStrength: 0.5,
      );

      final updated = preset.copyWith(
        name: 'Updated',
        filterStrength: 0.8,
      );

      expect(updated.id, preset.id);
      expect(updated.name, 'Updated');
      expect(updated.filterStrength, 0.8);
    });

    test('isEmpty 확인', () {
      final emptyPreset = EditPreset(
        id: 'test-id',
        name: 'Empty',
        createdAt: DateTime.now(),
      );

      final nonEmptyPreset = EditPreset(
        id: 'test-id',
        name: 'Non-Empty',
        createdAt: DateTime.now(),
        filmFilter: FilmFilter.portra400,
        filterStrength: 0.5,
      );

      expect(emptyPreset.isEmpty, true);
      expect(nonEmptyPreset.isEmpty, false);
    });
  });

  group('기본 프리셋 테스트', () {
    test('7개의 기본 프리셋이 존재', () {
      final presets = DefaultPresets.getAll();
      expect(presets.length, 7);
    });

    test('모든 기본 프리셋은 isDefault=true', () {
      final presets = DefaultPresets.getAll();

      for (final preset in presets) {
        expect(preset.isDefault, true);
      }
    });

    test('ID로 기본 프리셋 찾기', () {
      final preset = DefaultPresets.getById('default_kodak_summer');

      expect(preset, isNotNull);
      expect(preset!.name, 'Kodak Summer');
      expect(preset.filmFilter, FilmFilter.portra400);
      expect(preset.filterStrength, 0.80);
      expect(preset.grainIntensity, 0.25);
    });

    test('존재하지 않는 ID는 null 반환', () {
      final preset = DefaultPresets.getById('invalid-id');
      expect(preset, isNull);
    });

    test('프리셋 설명 가져오기', () {
      final description =
          DefaultPresets.getDescription('default_kodak_summer');

      expect(description, isNotEmpty);
      expect(description.contains('여름'), true);
    });
  });

  group('PresetRepository 테스트', () {
    test('초기 상태: 기본 프리셋만 존재', () async {
      final presets = await repository.getAllPresets();

      expect(presets.length, 7);
      expect(presets.every((p) => p.isDefault), true);
    });

    test('사용자 프리셋 저장', () async {
      final customPreset = EditPreset(
        id: const Uuid().v4(),
        name: 'My Preset',
        createdAt: DateTime.now(),
        filmFilter: FilmFilter.gold200,
        filterStrength: 0.7,
        grainIntensity: 0.5,
      );

      await repository.savePreset(customPreset);

      final allPresets = await repository.getAllPresets();
      expect(allPresets.length, 8); // 7 기본 + 1 사용자

      final userPresets = await repository.getUserPresets();
      expect(userPresets.length, 1);
      expect(userPresets.first.name, 'My Preset');
    });

    test('프리셋 업데이트', () async {
      final preset = EditPreset(
        id: 'update-test',
        name: 'Original',
        createdAt: DateTime.now(),
        filterStrength: 0.5,
      );

      await repository.savePreset(preset);

      final updated = preset.copyWith(
        name: 'Updated',
        filterStrength: 0.8,
      );

      await repository.savePreset(updated);

      final loaded = await repository.getPresetById('update-test');
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Updated');
      expect(loaded.filterStrength, 0.8);

      final userPresets = await repository.getUserPresets();
      expect(userPresets.length, 1); // 중복 저장 안됨
    });

    test('프리셋 삭제', () async {
      final preset = EditPreset(
        id: 'delete-test',
        name: 'To Delete',
        createdAt: DateTime.now(),
      );

      await repository.savePreset(preset);
      expect((await repository.getUserPresets()).length, 1);

      await repository.deletePreset('delete-test');
      expect((await repository.getUserPresets()).length, 0);
    });

    test('기본 프리셋 삭제 시도 시 예외 발생', () async {
      expect(
        () => repository.deletePreset('default_kodak_summer'),
        throwsException,
      );
    });

    test('기본 프리셋 수정 시도 시 예외 발생', () async {
      final defaultPreset = DefaultPresets.getById('default_kodak_summer')!;

      expect(
        () => repository.savePreset(defaultPreset),
        throwsException,
      );
    });

    test('프리셋 검색', () async {
      final preset1 = EditPreset(
        id: const Uuid().v4(),
        name: 'Summer Vibes',
        createdAt: DateTime.now(),
      );

      final preset2 = EditPreset(
        id: const Uuid().v4(),
        name: 'Winter Blues',
        createdAt: DateTime.now(),
      );

      await repository.savePreset(preset1);
      await repository.savePreset(preset2);

      final results = await repository.searchPresetsByName('summer');
      expect(results.length, greaterThanOrEqualTo(1));
      expect(
        results.any((p) => p.name.toLowerCase().contains('summer')),
        true,
      );
    });

    test('프리셋 통계', () async {
      expect(await repository.getUserPresetCount(), 0);
      expect(await repository.getTotalPresetCount(), 7);

      final preset = EditPreset(
        id: const Uuid().v4(),
        name: 'Test',
        createdAt: DateTime.now(),
      );

      await repository.savePreset(preset);

      expect(await repository.getUserPresetCount(), 1);
      expect(await repository.getTotalPresetCount(), 8);
    });

    test('사용자 프리셋 전체 삭제', () async {
      final preset1 = EditPreset(
        id: const Uuid().v4(),
        name: 'Preset 1',
        createdAt: DateTime.now(),
      );

      final preset2 = EditPreset(
        id: const Uuid().v4(),
        name: 'Preset 2',
        createdAt: DateTime.now(),
      );

      await repository.savePreset(preset1);
      await repository.savePreset(preset2);

      expect(await repository.getUserPresetCount(), 2);

      await repository.clearUserPresets();

      expect(await repository.getUserPresetCount(), 0);
      expect(await repository.getTotalPresetCount(), 7); // 기본 프리셋은 유지
    });
  });

  group('Extension 테스트', () {
    test('summary 생성', () {
      final preset = EditPreset(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        filmFilter: FilmFilter.portra400,
        filterStrength: 0.8,
        grainIntensity: 0.25,
        blurStrength: 0.1,
        aspectRatio: '1:1',
      );

      final summary = preset.summary;

      expect(summary.contains('Portra 400'), true);
      expect(summary.contains('80%'), true);
      expect(summary.contains('Grain'), true);
      expect(summary.contains('25%'), true);
      expect(summary.contains('Blur'), true);
      expect(summary.contains('10%'), true);
      expect(summary.contains('Ratio 1:1'), true);
    });

    test('intensityLevel 계산', () {
      final light = EditPreset(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        filterStrength: 0.2,
      );

      final medium = EditPreset(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        filterStrength: 0.5,
      );

      final strong = EditPreset(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        filterStrength: 0.9,
      );

      expect(light.intensityLevel, 1);
      expect(light.intensityText, 'Light');

      expect(medium.intensityLevel, 2);
      expect(medium.intensityText, 'Medium');

      expect(strong.intensityLevel, 3);
      expect(strong.intensityText, 'Strong');
    });

    test('List<EditPreset> 필터링', () async {
      final preset1 = EditPreset(
        id: const Uuid().v4(),
        name: 'User 1',
        createdAt: DateTime.now(),
        isDefault: false,
        filmFilter: FilmFilter.portra400,
      );

      final preset2 = EditPreset(
        id: const Uuid().v4(),
        name: 'User 2',
        createdAt: DateTime.now(),
        isDefault: false,
        filmFilter: FilmFilter.gold200,
        aspectRatio: '1:1',
      );

      await repository.savePreset(preset1);
      await repository.savePreset(preset2);

      final allPresets = await repository.getAllPresets();

      // 기본/사용자 필터링
      expect(allPresets.defaultPresets.length, 7);
      expect(allPresets.userPresets.length, 2);

      // 필터별 필터링
      final portraPresets = allPresets.withFilter(FilmFilter.portra400);
      expect(portraPresets.length, greaterThanOrEqualTo(1));

      // 종횡비별 필터링
      final squarePresets = allPresets.withAspectRatio('1:1');
      expect(squarePresets.length, greaterThanOrEqualTo(1));
    });
  });
}
