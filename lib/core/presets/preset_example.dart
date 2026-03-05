/// 프리셋 시스템 사용 예제
///
/// 이 파일은 프리셋 시스템의 사용법을 보여주는 예제 코드입니다.
/// 실제 앱에서는 이 코드를 참고하여 구현하세요.

import 'package:uuid/uuid.dart';
import 'package:photoedit/core/presets/presets.dart';
import 'package:photoedit/core/filters/film_filter.dart';

/// 프리셋 시스템 사용 예제
class PresetExample {
  final PresetRepository repository;

  PresetExample(this.repository);

  // ========== 1. 모든 프리셋 가져오기 ==========

  Future<void> example1_getAllPresets() async {
    print('========== 모든 프리셋 가져오기 ==========');

    final presets = await repository.getAllPresets();

    print('전체 프리셋 개수: ${presets.length}');
    print('');

    for (final preset in presets) {
      print('${preset.isDefault ? "📌" : "✏️"} ${preset.name}');
      print('   ${preset.summary}');
      print('   강도: ${preset.intensityText}');
      print('');
    }
  }

  // ========== 2. 새 프리셋 만들기 ==========

  Future<void> example2_createCustomPreset() async {
    print('========== 새 프리셋 만들기 ==========');

    final customPreset = EditPreset(
      id: const Uuid().v4(),
      name: 'My Summer Vibes',
      createdAt: DateTime.now(),
      isDefault: false,
      filmFilter: FilmFilter.gold200,
      filterStrength: 0.65,
      grainIntensity: 0.40,
      blurStrength: 0.05,
      aspectRatio: '1:1',
      outputWidth: 1080,
    );

    await repository.savePreset(customPreset);

    print('✅ 프리셋 저장 완료: ${customPreset.name}');
    print('   ${customPreset.summary}');
  }

  // ========== 3. 프리셋 수정하기 ==========

  Future<void> example3_updatePreset() async {
    print('========== 프리셋 수정하기 ==========');

    // 기존 프리셋 찾기
    final presets = await repository.getUserPresets();
    if (presets.isEmpty) {
      print('❌ 사용자 프리셋이 없습니다');
      return;
    }

    final preset = presets.first;

    // copyWith로 값 수정
    final updatedPreset = preset.copyWith(
      name: '${preset.name} (Updated)',
      filterStrength: 0.90,
    );

    await repository.savePreset(updatedPreset);

    print('✅ 프리셋 수정 완료: ${updatedPreset.name}');
    print('   필터 강도: ${(updatedPreset.filterStrength * 100).toInt()}%');
  }

  // ========== 4. 프리셋 삭제하기 ==========

  Future<void> example4_deletePreset() async {
    print('========== 프리셋 삭제하기 ==========');

    // 사용자 프리셋 가져오기
    final userPresets = await repository.getUserPresets();
    if (userPresets.isEmpty) {
      print('❌ 삭제할 프리셋이 없습니다');
      return;
    }

    final presetToDelete = userPresets.first;

    await repository.deletePreset(presetToDelete.id);

    print('✅ 프리셋 삭제 완료: ${presetToDelete.name}');
  }

  // ========== 5. 프리셋 검색하기 ==========

  Future<void> example5_searchPresets() async {
    print('========== 프리셋 검색하기 ==========');

    final query = 'japan';
    final results = await repository.searchPresetsByName(query);

    print('검색어: "$query"');
    print('검색 결과: ${results.length}개');
    print('');

    for (final preset in results) {
      print('- ${preset.name}');
      print('  ${preset.summary}');
    }
  }

  // ========== 6. 기본 프리셋 사용하기 ==========

  Future<void> example6_useDefaultPreset() async {
    print('========== 기본 프리셋 사용하기 ==========');

    // Kodak Summer 프리셋 가져오기
    final preset = DefaultPresets.getById('default_kodak_summer');

    if (preset != null) {
      print('프리셋: ${preset.name}');
      print('설명: ${DefaultPresets.getDescription(preset.id)}');
      print('');
      print('설정:');
      print('  - 필터: ${preset.filmFilter?.displayName}');
      print('  - 필터 강도: ${(preset.filterStrength * 100).toInt()}%');
      print('  - 그레인: ${(preset.grainIntensity * 100).toInt()}%');
      print('  - 블러: ${(preset.blurStrength * 100).toInt()}%');
    }
  }

  // ========== 7. 프리셋 필터링하기 ==========

  Future<void> example7_filterPresets() async {
    print('========== 프리셋 필터링하기 ==========');

    final allPresets = await repository.getAllPresets();

    // 기본 프리셋만
    final defaults = allPresets.defaultPresets;
    print('기본 프리셋: ${defaults.length}개');

    // 사용자 프리셋만
    final users = allPresets.userPresets;
    print('사용자 프리셋: ${users.length}개');

    // Portra 400 필터 사용하는 프리셋
    final portraPresets = allPresets.withFilter(FilmFilter.portra400);
    print('Portra 400 프리셋: ${portraPresets.length}개');

    // 강도 높은 프리셋
    final strongPresets = allPresets.withIntensity(3);
    print('강도 높은 프리셋: ${strongPresets.length}개');

    // 1:1 비율 프리셋
    final squarePresets = allPresets.withAspectRatio('1:1');
    print('1:1 비율 프리셋: ${squarePresets.length}개');
  }

  // ========== 8. 프리셋 통계 ==========

  Future<void> example8_presetStats() async {
    print('========== 프리셋 통계 ==========');

    final userCount = await repository.getUserPresetCount();
    final totalCount = await repository.getTotalPresetCount();
    final defaultCount = DefaultPresets.getAll().length;

    print('전체 프리셋: $totalCount개');
    print('기본 프리셋: $defaultCount개');
    print('사용자 프리셋: $userCount개');
  }

  // ========== 9. 모든 예제 실행 ==========

  Future<void> runAllExamples() async {
    await example1_getAllPresets();
    print('\n');

    await example2_createCustomPreset();
    print('\n');

    await example3_updatePreset();
    print('\n');

    await example5_searchPresets();
    print('\n');

    await example6_useDefaultPreset();
    print('\n');

    await example7_filterPresets();
    print('\n');

    await example8_presetStats();
    print('\n');

    // 삭제는 마지막에 (옵션)
    // await example4_deletePreset();
  }
}

// ========== 실행 예제 (main.dart에서 호출) ==========
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   final repository = await PresetRepository.create();
//   final example = PresetExample(repository);
//
//   await example.runAllExamples();
// }
