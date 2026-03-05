import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:photoedit/core/presets/preset_model.dart';
import 'package:photoedit/core/presets/default_presets.dart';

/// 프리셋 저장소
///
/// SharedPreferences를 사용하여 사용자 커스텀 프리셋을 저장/로드
/// 기본 프리셋은 DefaultPresets에서 제공
class PresetRepository {
  static const String _keyUserPresets = 'user_presets';

  final SharedPreferences _prefs;

  PresetRepository(this._prefs);

  /// 싱글톤 인스턴스 생성
  static Future<PresetRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PresetRepository(prefs);
  }

  // ========== 모든 프리셋 가져오기 ==========

  /// 모든 프리셋 가져오기 (기본 + 사용자 커스텀)
  ///
  /// 반환 순서:
  /// 1. 기본 프리셋 (DefaultPresets)
  /// 2. 사용자 프리셋 (최신순)
  Future<List<EditPreset>> getAllPresets() async {
    final defaultPresets = DefaultPresets.getAll();
    final userPresets = await _getUserPresets();

    // 사용자 프리셋을 최신순으로 정렬
    userPresets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return [...defaultPresets, ...userPresets];
  }

  /// 기본 프리셋만 가져오기
  List<EditPreset> getDefaultPresets() {
    return DefaultPresets.getAll();
  }

  /// 사용자 프리셋만 가져오기
  Future<List<EditPreset>> getUserPresets() async {
    return _getUserPresets();
  }

  // ========== 프리셋 저장 ==========

  /// 프리셋 저장 (생성 또는 업데이트)
  ///
  /// [preset]이 기본 프리셋(isDefault=true)이면 예외 발생
  /// 같은 ID의 프리셋이 있으면 업데이트, 없으면 새로 생성
  Future<void> savePreset(EditPreset preset) async {
    if (preset.isDefault) {
      throw Exception('기본 프리셋은 수정할 수 없습니다');
    }

    final userPresets = await _getUserPresets();

    // 기존 프리셋 찾기
    final existingIndex = userPresets.indexWhere((p) => p.id == preset.id);

    if (existingIndex >= 0) {
      // 업데이트
      userPresets[existingIndex] = preset;
    } else {
      // 새로 추가
      userPresets.add(preset);
    }

    await _saveUserPresets(userPresets);
  }

  // ========== 프리셋 삭제 ==========

  /// 프리셋 삭제
  ///
  /// 기본 프리셋은 삭제할 수 없음 (예외 발생)
  Future<void> deletePreset(String id) async {
    // 기본 프리셋 삭제 방지
    if (DefaultPresets.ids.contains(id)) {
      throw Exception('기본 프리셋은 삭제할 수 없습니다');
    }

    final userPresets = await _getUserPresets();
    userPresets.removeWhere((preset) => preset.id == id);
    await _saveUserPresets(userPresets);
  }

  // ========== 프리셋 검색 ==========

  /// ID로 프리셋 찾기 (기본 + 사용자)
  Future<EditPreset?> getPresetById(String id) async {
    // 기본 프리셋에서 찾기
    final defaultPreset = DefaultPresets.getById(id);
    if (defaultPreset != null) {
      return defaultPreset;
    }

    // 사용자 프리셋에서 찾기
    final userPresets = await _getUserPresets();
    try {
      return userPresets.firstWhere((preset) => preset.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 이름으로 프리셋 검색
  Future<List<EditPreset>> searchPresetsByName(String query) async {
    final allPresets = await getAllPresets();
    final lowerQuery = query.toLowerCase();

    return allPresets
        .where((preset) => preset.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // ========== 프리셋 통계 ==========

  /// 사용자 프리셋 개수
  Future<int> getUserPresetCount() async {
    final userPresets = await _getUserPresets();
    return userPresets.length;
  }

  /// 전체 프리셋 개수 (기본 + 사용자)
  Future<int> getTotalPresetCount() async {
    final allPresets = await getAllPresets();
    return allPresets.length;
  }

  // ========== 프리셋 초기화 ==========

  /// 모든 사용자 프리셋 삭제 (기본 프리셋은 유지)
  Future<void> clearUserPresets() async {
    await _prefs.remove(_keyUserPresets);
  }

  // ========== Private 메서드 ==========

  /// SharedPreferences에서 사용자 프리셋 로드
  Future<List<EditPreset>> _getUserPresets() async {
    final jsonString = _prefs.getString(_keyUserPresets);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => EditPreset.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // JSON 파싱 실패 시 빈 리스트 반환
      return [];
    }
  }

  /// SharedPreferences에 사용자 프리셋 저장
  Future<void> _saveUserPresets(List<EditPreset> presets) async {
    final jsonList = presets.map((preset) => preset.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await _prefs.setString(_keyUserPresets, jsonString);
  }
}
