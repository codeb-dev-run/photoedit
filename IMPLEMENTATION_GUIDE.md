# 일괄 처리와 프리셋 관리 구현 가이드

## 생성된 파일 목록

### 핵심 모델
1. `/Users/admin/new_project/photoedit/lib/core/models/preset.dart` ✓
   - Preset, PresetSettings, FilmFilter, DefaultPresets 정의

2. `/Users/admin/new_project/photoedit/lib/core/models/batch_progress.dart` ✓
   - BatchProgress, BatchStatus, BatchResult 정의

### 서비스
3. `/Users/admin/new_project/photoedit/lib/core/services/preset_service.dart` ✓
   - PresetService 및 Provider 정의
   - SharedPreferences 기반 CRUD 작업

### 일괄 처리
4. `/Users/admin/new_project/photoedit/lib/features/batch/batch_processor.dart` ✓
   - BatchProcessor (Isolate 기반 백그라운드 처리)
   - _processImageIsolate (compute() 함수)

5. `/Users/admin/new_project/photoedit/lib/features/batch/batch_screen_new.dart` ✓
   - BatchScreen, BatchStateNotifier
   - 다중 이미지 선택, 진행률 표시, 결과 카드

### 프리셋 관리
6. `/Users/admin/new_project/photoedit/lib/features/presets/presets_screen_new.dart` ✓
   - PresetsScreen
   - 기본/사용자 프리셋 그리드
   - 편집/삭제/공유/복제 기능

7. `/Users/admin/new_project/photoedit/lib/features/presets/widgets/preset_card.dart` ✓
   - PresetCard (커스텀 그라데이션 배경)
   - _PresetBackgroundPainter (설정 시각화)

8. `/Users/admin/new_project/photoedit/lib/features/presets/widgets/preset_editor_dialog.dart` ✓
   - PresetEditorDialog
   - 슬라이더 기반 설정 편집

## 파일 재배치 방법

파일 시스템 제약으로 `_new` 접미사가 붙은 파일들이 있습니다. 다음과 같이 재배치하세요:

```bash
cd /Users/admin/new_project/photoedit

# 일괄 처리 화면
mv lib/features/batch/batch_screen_new.dart lib/features/batch/batch_screen.dart

# 프리셋 관리 화면
mv lib/features/presets/presets_screen_new.dart lib/features/presets/presets_screen.dart
```

## main.dart 수정

PresetService를 초기화하고 Provider에 주입해야 합니다:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/preset_service.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences 초기화
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // PresetService Provider 오버라이드
        presetServiceProvider.overrideWithValue(
          PresetService(prefs),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

## 라우팅 추가

go_router에 새 화면을 추가하세요:

```dart
import 'features/batch/batch_screen.dart';
import 'features/presets/presets_screen.dart';

final router = GoRouter(
  routes: [
    // ... 기존 라우트 ...

    GoRoute(
      path: '/batch',
      builder: (context, state) => const BatchScreen(),
    ),

    GoRoute(
      path: '/presets',
      builder: (context, state) => const PresetsScreen(),
    ),
  ],
);
```

## 홈 화면에 네비게이션 추가

홈 화면에 일괄 처리와 프리셋 관리 버튼을 추가하세요:

```dart
ElevatedButton.icon(
  onPressed: () => context.push('/batch'),
  icon: const Icon(Icons.collections),
  label: const Text('일괄 처리'),
),

ElevatedButton.icon(
  onPressed: () => context.push('/presets'),
  icon: const Icon(Icons.favorite),
  label: const Text('프리셋 관리'),
),
```

## 주요 기능

### 일괄 처리 (BatchScreen)
- ✓ 다중 이미지 선택 (image_picker multi)
- ✓ 프리셋 선택 드롭다운
- ✓ 실시간 진행률 표시
- ✓ Isolate 백그라운드 처리 (compute)
- ✓ 성공/실패/소요시간 결과 표시
- ✓ 처리 취소 기능
- ✓ 이미지 개별 제거

### 프리셋 관리 (PresetsScreen)
- ✓ 기본 프리셋 5개 (Kodak Summer, Fuji Landscape 등)
- ✓ 사용자 프리셋 CRUD
- ✓ 프리셋 카드 (커스텀 그라데이션 배경)
- ✓ 길게 눌러서 액션 시트 (편집/삭제/공유/복제)
- ✓ 프리셋 편집 다이얼로그 (슬라이더)
- ✓ 프리셋 공유 (Share Plus)
- ✓ 프리셋 JSON 내보내기/가져오기

### 프리셋 설정
- 밝기 (-1.0 ~ 1.0)
- 대비 (-1.0 ~ 1.0)
- 채도 (-1.0 ~ 1.0)
- 블러 (0.0 ~ 1.0)
- 그레인 (0.0 ~ 1.0)
- 필름 필터 (6가지)
- 틴트 컬러 및 불투명도

## UI 구조

### BatchScreen
```
┌─────────────────────────────────────┐
│         일괄 처리 화면               │
│                                     │
│  [프리셋 선택] ▼ My Vintage Look    │
│                                     │
│  선택된 이미지: 12장                 │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 📷  │ │ 📷  │ │ 📷  │ │ 📷  │   │
│  │  ✓  │ │  ✓  │ │  ✓  │ │  ✓  │   │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━ 75%          │
│  처리 중: 9/12                       │
│                                     │
│  [취소]              [일괄 처리 시작]│
└─────────────────────────────────────┘
```

### PresetsScreen
```
┌─────────────────────────────────────┐
│          내 프리셋 관리              │
│                                     │
│  [기본 프리셋]                       │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │Kodak │ │ Fuji │ │Lo-Fi │        │
│  │Summer│ │Lands │ │Vntge │        │
│  └──────┘ └──────┘ └──────┘        │
│                                     │
│  [내 프리셋]                         │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │  My  │ │  +   │                 │
│  │Preset│ │ NEW  │                 │
│  └──────┘ └──────┘                 │
│                                     │
│  길게 눌러서: 편집 | 삭제 | 공유     │
└─────────────────────────────────────┘
```

## 테스트 시나리오

### 일괄 처리
1. 이미지 선택 버튼 클릭
2. 갤러리에서 여러 이미지 선택
3. 프리셋 드롭다운에서 프리셋 선택
4. 일괄 처리 시작 버튼 클릭
5. 진행률 확인
6. 결과 확인 (성공/실패/소요시간)
7. 처리된 이미지는 Documents/processed/ 에 저장됨

### 프리셋 관리
1. 새 프리셋 버튼 클릭
2. 이름, 설명 입력
3. 슬라이더로 효과 조절
4. 필름 필터 선택
5. 틴트 컬러 선택 (옵션)
6. 저장 버튼 클릭
7. 생성된 프리셋 확인
8. 길게 눌러서 편집/삭제/공유/복제

## 성능 최적화

### Isolate 처리
- `compute()` 함수로 이미지 처리를 별도 Isolate에서 실행
- UI 스레드 블로킹 방지
- 대용량 이미지 처리 시 부드러운 UX

### Stream 기반 진행률
- `StreamController`로 실시간 진행률 전달
- UI 즉시 업데이트
- 취소 기능 지원

### SharedPreferences 캐싱
- 프리셋 JSON 직렬화/역직렬화
- 빠른 로드/저장
- 오프라인 지원

## 의존성 확인

pubspec.yaml에 다음 패키지가 포함되어 있는지 확인하세요:

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  image: ^4.3.0
  image_picker: ^1.1.2
  shared_preferences: ^2.3.4
  path_provider: ^2.1.5
  share_plus: ^10.1.4
  uuid: ^4.5.1
  path: ^1.9.1
```

## 다음 단계

1. 파일 재배치 완료
2. main.dart 수정 (PresetService 초기화)
3. 라우팅 추가
4. 홈 화면에 네비게이션 버튼 추가
5. flutter run으로 테스트
6. 실제 디바이스에서 이미지 선택 및 처리 테스트

## 문제 해결

### PresetService Provider 에러
```
UnimplementedError: PresetService must be overridden
```
→ main.dart에서 ProviderScope의 overrides에 PresetService 추가

### 이미지 처리 느림
- Isolate 처리 확인
- 이미지 크기 확인 (너무 큰 이미지는 리사이즈)
- 디버그 모드에서는 느릴 수 있음 (release 모드 테스트)

### 프리셋 저장 안됨
- SharedPreferences 초기화 확인
- JSON 직렬화/역직렬화 로그 확인
- Platform별 권한 확인
