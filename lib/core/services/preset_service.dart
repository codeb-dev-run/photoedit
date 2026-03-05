import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/preset.dart';

/// 프리셋 서비스
class PresetService {
  static const String _presetsKey = 'user_presets';
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  PresetService(this._prefs);

  /// 모든 프리셋 가져오기 (기본 + 사용자)
  Future<List<Preset>> getAllPresets() async {
    final userPresets = await getUserPresets();
    return [...DefaultPresets.presets, ...userPresets];
  }

  /// 사용자 프리셋 가져오기
  Future<List<Preset>> getUserPresets() async {
    final String? presetsJson = _prefs.getString(_presetsKey);
    if (presetsJson == null) return [];

    try {
      final List<dynamic> presetsList = jsonDecode(presetsJson);
      return presetsList
          .map((json) => Preset.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 프리셋 저장
  Future<Preset> savePreset({
    required String name,
    String? description,
    required PresetSettings settings,
  }) async {
    final preset = Preset(
      id: _uuid.v4(),
      name: name,
      description: description,
      isDefault: false,
      settings: settings,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final presets = await getUserPresets();
    presets.add(preset);
    await _saveUserPresets(presets);

    return preset;
  }

  /// 프리셋 업데이트
  Future<Preset> updatePreset(String id, {
    String? name,
    String? description,
    PresetSettings? settings,
  }) async {
    final presets = await getUserPresets();
    final index = presets.indexWhere((p) => p.id == id);

    if (index == -1) {
      throw Exception('Preset not found');
    }

    final updatedPreset = presets[index].copyWith(
      name: name,
      description: description,
      settings: settings,
      updatedAt: DateTime.now(),
    );

    presets[index] = updatedPreset;
    await _saveUserPresets(presets);

    return updatedPreset;
  }

  /// 프리셋 삭제
  Future<void> deletePreset(String id) async {
    final presets = await getUserPresets();
    presets.removeWhere((p) => p.id == id);
    await _saveUserPresets(presets);
  }

  /// ID로 프리셋 찾기
  Future<Preset?> getPresetById(String id) async {
    final allPresets = await getAllPresets();
    try {
      return allPresets.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 프리셋 복제
  Future<Preset> duplicatePreset(String id) async {
    final preset = await getPresetById(id);
    if (preset == null) {
      throw Exception('Preset not found');
    }

    return savePreset(
      name: '${preset.name} (복사본)',
      description: preset.description,
      settings: preset.settings,
    );
  }

  /// 프리셋 내보내기
  String exportPreset(Preset preset) {
    return jsonEncode(preset.toJson());
  }

  /// 프리셋 가져오기
  Future<Preset> importPreset(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final preset = Preset.fromJson(json);

      return savePreset(
        name: preset.name,
        description: preset.description,
        settings: preset.settings,
      );
    } catch (e) {
      throw Exception('Invalid preset format');
    }
  }

  /// 사용자 프리셋 저장 (내부)
  Future<void> _saveUserPresets(List<Preset> presets) async {
    final presetsJson = jsonEncode(
      presets.map((p) => p.toJson()).toList(),
    );
    await _prefs.setString(_presetsKey, presetsJson);
  }
}

/// 프리셋 서비스 Provider
final presetServiceProvider = Provider<PresetService>((ref) {
  throw UnimplementedError('PresetService must be overridden');
});

/// 모든 프리셋 Provider
final presetsProvider = FutureProvider<List<Preset>>((ref) async {
  final service = ref.watch(presetServiceProvider);
  return service.getAllPresets();
});

/// 사용자 프리셋 Provider
final userPresetsProvider = FutureProvider<List<Preset>>((ref) async {
  final service = ref.watch(presetServiceProvider);
  return service.getUserPresets();
});

/// 기본 프리셋 Provider
final defaultPresetsProvider = Provider<List<Preset>>((ref) {
  return DefaultPresets.presets;
});
