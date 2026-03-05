# 프리셋 시스템 (Preset System)

레트로 필름 사진 편집 앱의 프리셋 저장/로드 시스템

## 개요

사용자가 필터, 블러, 그레인, 리사이즈 설정을 프리셋으로 저장하고 재사용할 수 있는 시스템입니다.

### 주요 기능

- **7개 기본 프리셋** (삭제 불가)
- **무제한 사용자 커스텀 프리셋**
- **SharedPreferences 기반 영구 저장**
- **JSON 직렬화/역직렬화**
- **검색 및 필터링**

## 파일 구조

```
lib/core/presets/
├── preset_model.dart         # 프리셋 데이터 모델
├── preset_repository.dart    # 저장소 (CRUD)
├── default_presets.dart      # 7개 기본 프리셋
├── preset_extensions.dart    # 확장 메서드
├── preset_example.dart       # 사용 예제
├── presets.dart             # Export 파일
└── README.md                # 이 문서

lib/core/filters/
└── film_filter.dart         # 필름 필터 enum
```

## 빠른 시작

### 1. Import

```dart
import 'package:photoedit/core/presets/presets.dart';
```

### 2. Repository 초기화

```dart
final repository = await PresetRepository.create();
```

### 3. 모든 프리셋 가져오기

```dart
final presets = await repository.getAllPresets();

for (final preset in presets) {
  print('${preset.name}: ${preset.summary}');
}
```

### 4. 새 프리셋 저장

```dart
import 'package:uuid/uuid.dart';

final customPreset = EditPreset(
  id: const Uuid().v4(),
  name: 'My Summer Vibes',
  createdAt: DateTime.now(),
  filmFilter: FilmFilter.portra400,
  filterStrength: 0.80,
  grainIntensity: 0.25,
  aspectRatio: '1:1',
);

await repository.savePreset(customPreset);
```

### 5. 프리셋 적용 (예시)

```dart
final preset = await repository.getPresetById('default_kodak_summer');

if (preset != null) {
  // 이미지 프로세서에 설정 적용
  await imageProcessor.applyFilter(preset.filmFilter, preset.filterStrength);
  await imageProcessor.applyGrain(preset.grainIntensity);
  await imageProcessor.applyBlur(preset.blurStrength);

  if (preset.aspectRatio != null) {
    await imageProcessor.resize(preset.aspectRatio);
  }
}
```

## 프리셋 모델 (EditPreset)

### 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | String | UUID (고유 ID) |
| `name` | String | 프리셋 이름 |
| `createdAt` | DateTime | 생성 시간 |
| `isDefault` | bool | 기본 프리셋 여부 |
| `filmFilter` | FilmFilter? | 필름 필터 |
| `filterStrength` | double | 필터 강도 (0.0 ~ 1.0) |
| `blurStrength` | double | 블러 강도 (0.0 ~ 1.0) |
| `grainIntensity` | double | 그레인 강도 (0.0 ~ 1.0) |
| `aspectRatio` | String? | 종횡비 ("1:1", "4:3", "16:9") |
| `outputWidth` | int? | 출력 너비 (픽셀) |

### 메서드

```dart
// JSON 변환
final json = preset.toJson();
final preset = EditPreset.fromJson(json);

// 값 복사
final updated = preset.copyWith(name: 'New Name', filterStrength: 0.9);

// 빈 프리셋 확인
if (preset.isEmpty) {
  print('설정이 없습니다');
}
```

## 7개 기본 프리셋

| ID | 이름 | 필터 | 강도 | 그레인 | 블러 | 비율 |
|----|------|------|------|--------|------|------|
| `default_kodak_summer` | Kodak Summer | Portra 400 | 80% | 25% | 0% | - |
| `default_fuji_landscape` | Fuji Landscape | Velvia 50 | 90% | 15% | 0% | 16:9 |
| `default_lofi_vintage` | Lo-Fi Vintage | Gold 200 | 70% | 50% | 0% | 4:3 |
| `default_bw_classic` | B&W Classic | Tri-X 400 | 100% | 40% | 0% | - |
| `default_instant_memory` | Instant Memory | Polaroid | 85% | 30% | 10% | 1:1 |
| `default_90s_japan` | 90s Japan | Superia 400 | 75% | 45% | 0% | 4:3 |
| `default_cinema_night` | Cinema Night | Cinestill 800T | 80% | 35% | 0% | 16:9 |

### 사용 예시

```dart
// ID로 가져오기
final preset = DefaultPresets.getById('default_kodak_summer');

// 설명 가져오기
final description = DefaultPresets.getDescription('default_kodak_summer');
// "따뜻하고 부드러운 여름 인물 사진"

// 모든 기본 프리셋
final defaults = DefaultPresets.getAll();
```

## PresetRepository API

### 조회

```dart
// 모든 프리셋 (기본 + 사용자)
final all = await repository.getAllPresets();

// 기본 프리셋만
final defaults = repository.getDefaultPresets();

// 사용자 프리셋만
final users = await repository.getUserPresets();

// ID로 찾기
final preset = await repository.getPresetById('preset_id');

// 이름으로 검색
final results = await repository.searchPresetsByName('summer');
```

### 저장/삭제

```dart
// 저장 (생성 or 업데이트)
await repository.savePreset(preset);

// 삭제
await repository.deletePreset(presetId);

// 모든 사용자 프리셋 삭제
await repository.clearUserPresets();
```

### 통계

```dart
// 사용자 프리셋 개수
final userCount = await repository.getUserPresetCount();

// 전체 프리셋 개수
final totalCount = await repository.getTotalPresetCount();
```

## 확장 메서드 (Extensions)

### EditPreset 확장

```dart
// 요약 정보
print(preset.summary);
// "Portra 400 (80%) + Grain (25%)"

// 효과 확인
if (preset.hasFilter) print('필터 있음');
if (preset.hasGrain) print('그레인 있음');
if (preset.hasBlur) print('블러 있음');
if (preset.hasResize) print('리사이즈 있음');

// 강도 레벨 (0 ~ 3)
print(preset.intensityLevel);  // 2
print(preset.intensityText);   // "Medium"
```

### List<EditPreset> 확장

```dart
final presets = await repository.getAllPresets();

// 기본 프리셋만
final defaults = presets.defaultPresets;

// 사용자 프리셋만
final users = presets.userPresets;

// 특정 필터 사용하는 프리셋
final portraPresets = presets.withFilter(FilmFilter.portra400);

// 강도별 필터링
final strongPresets = presets.withIntensity(3);

// 종횡비별 필터링
final squarePresets = presets.withAspectRatio('1:1');
```

## 필름 필터 (FilmFilter)

```dart
enum FilmFilter {
  portra400,      // Kodak Portra 400 - 인물용
  velvia50,       // Fuji Velvia 50 - 풍경용
  gold200,        // Kodak Gold 200 - 빈티지
  triX400,        // Kodak Tri-X 400 - 흑백
  polaroid,       // Polaroid SX-70 - 인스턴트
  superia400,     // Fuji Superia 400 - 90년대
  cinestill800t,  // Cinestill 800T - 시네마틱
}

// 표시 이름
print(FilmFilter.portra400.displayName);  // "Portra 400"
```

## 사용 시나리오

### 1. 프리셋 선택 화면

```dart
class PresetListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EditPreset>>(
      future: repository.getAllPresets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final presets = snapshot.data!;

        return ListView.builder(
          itemCount: presets.length,
          itemBuilder: (context, index) {
            final preset = presets[index];

            return ListTile(
              leading: Icon(
                preset.isDefault ? Icons.star : Icons.bookmark,
              ),
              title: Text(preset.name),
              subtitle: Text(preset.summary),
              trailing: Text(preset.intensityText),
              onTap: () => _applyPreset(preset),
            );
          },
        );
      },
    );
  }
}
```

### 2. 프리셋 저장 다이얼로그

```dart
Future<void> _saveAsPreset(BuildContext context) async {
  final name = await showDialog<String>(
    context: context,
    builder: (context) => TextInputDialog(),
  );

  if (name != null) {
    final preset = EditPreset(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      filmFilter: _currentFilter,
      filterStrength: _filterStrength,
      grainIntensity: _grainIntensity,
      blurStrength: _blurStrength,
      aspectRatio: _aspectRatio,
    );

    await repository.savePreset(preset);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('프리셋 저장 완료: $name')),
    );
  }
}
```

### 3. 프리셋 적용

```dart
Future<void> _applyPreset(EditPreset preset) async {
  setState(() {
    _currentFilter = preset.filmFilter;
    _filterStrength = preset.filterStrength;
    _grainIntensity = preset.grainIntensity;
    _blurStrength = preset.blurStrength;
    _aspectRatio = preset.aspectRatio;
  });

  await _processImage();
}
```

## 데이터 저장 형식 (SharedPreferences)

```json
{
  "user_presets": [
    {
      "id": "uuid-1234-5678",
      "name": "My Summer Vibes",
      "createdAt": "2025-01-15T10:30:00.000Z",
      "isDefault": false,
      "filmFilter": "gold200",
      "filterStrength": 0.65,
      "blurStrength": 0.05,
      "grainIntensity": 0.40,
      "aspectRatio": "1:1",
      "outputWidth": 1080
    }
  ]
}
```

## 에러 처리

```dart
try {
  // 기본 프리셋 삭제 시도
  await repository.deletePreset('default_kodak_summer');
} catch (e) {
  print('오류: 기본 프리셋은 삭제할 수 없습니다');
}

try {
  // 기본 프리셋 수정 시도
  final preset = DefaultPresets.getById('default_kodak_summer')!;
  await repository.savePreset(preset.copyWith(name: 'Modified'));
} catch (e) {
  print('오류: 기본 프리셋은 수정할 수 없습니다');
}
```

## 테스트

```dart
// preset_example.dart 참고
final repository = await PresetRepository.create();
final example = PresetExample(repository);

await example.runAllExamples();
```

## 향후 확장 가능성

1. **프리셋 공유**: Export/Import JSON 파일
2. **클라우드 동기화**: Firebase 연동
3. **인기 프리셋**: 사용 횟수 추적
4. **프리셋 태그**: 카테고리 분류
5. **프리셋 미리보기**: 썸네일 이미지 저장

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.
