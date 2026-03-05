import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/preset.dart';

/// 프리셋 관리자
class PresetManager {
  static const String _presetsKey = 'user_presets';
  final SharedPreferences _prefs;

  PresetManager(this._prefs);

  /// 프리셋 관리자 초기화
  static Future<PresetManager> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PresetManager(prefs);
  }

  /// 모든 프리셋 가져오기 (기본 + 사용자)
  Future<List<Preset>> getAllPresets() async {
    final userPresets = await getUserPresets();
    return [...DefaultPresets.presets, ...userPresets];
  }

  /// 사용자 프리셋 가져오기
  Future<List<Preset>> getUserPresets() async {
    final presetsJson = _prefs.getStringList(_presetsKey) ?? [];
    return presetsJson
        .map((json) => Preset.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  /// 프리셋 저장
  Future<void> savePreset(Preset preset) async {
    final presets = await getUserPresets();

    // 기존 프리셋 업데이트 또는 새로 추가
    final index = presets.indexWhere((p) => p.id == preset.id);
    if (index != -1) {
      presets[index] = preset;
    } else {
      presets.add(preset);
    }

    final presetsJson = presets.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_presetsKey, presetsJson);
  }

  /// 프리셋 삭제
  Future<void> deletePreset(String id) async {
    final presets = await getUserPresets();
    presets.removeWhere((p) => p.id == id);

    final presetsJson = presets.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_presetsKey, presetsJson);
  }

  /// ID로 프리셋 가져오기
  Future<Preset?> getPresetById(String id) async {
    final allPresets = await getAllPresets();
    try {
      return allPresets.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
