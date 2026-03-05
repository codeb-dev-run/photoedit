# PhotoEdit - 필름 사진 편집 앱

> Flutter 기반 필름 카메라 스타일 사진 편집 앱

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점
├── app/
│   ├── app.dart                       # 앱 설정
│   └── router.dart                    # 라우팅
├── core/
│   ├── filters/                       # 필터 엔진
│   │   ├── blur_processor.dart        # 블러 처리 (투명 블러 지원)
│   │   ├── grain_processor.dart       # 노이즈/그레인 처리
│   │   ├── filter_engine.dart         # 필터 엔진
│   │   └── film_filter.dart           # 필름 필터 정의
│   ├── models/
│   │   ├── preset.dart                # 프리셋 모델
│   │   └── batch_progress.dart        # 배치 처리 진행 상태
│   ├── presets/
│   │   ├── preset_model.dart          # 편집 프리셋 모델
│   │   ├── default_presets.dart       # 기본 프리셋 (25개)
│   │   └── preset_repository.dart     # 프리셋 저장소
│   ├── services/
│   │   └── preset_service.dart        # 프리셋 서비스
│   └── utils/
│       ├── image_utils.dart           # 이미지 유틸리티
│       └── file_helper.dart           # 파일 헬퍼
├── features/
│   ├── home/
│   │   └── home_screen.dart           # 홈 화면
│   ├── editor/
│   │   ├── editor_screen.dart         # 에디터 메인 화면
│   │   ├── controllers/
│   │   │   └── editor_state.dart      # 에디터 상태 관리
│   │   └── widgets/
│   │       ├── blur_control.dart      # 블러 조절 UI
│   │       ├── grain_control.dart     # 그레인 조절 UI
│   │       ├── filter_selector.dart   # 필터 선택 UI
│   │       └── resize_control.dart    # 리사이즈 UI
│   ├── presets/
│   │   ├── presets_screen_new.dart    # 프리셋 관리 화면
│   │   ├── preset_manager.dart        # 프리셋 매니저
│   │   └── widgets/
│   │       ├── preset_card.dart       # 프리셋 카드
│   │       └── preset_editor_dialog.dart  # 프리셋 편집 다이얼로그
│   └── batch/
│       ├── batch_screen_new.dart      # 일괄 처리 화면
│       └── batch_processor.dart       # 일괄 처리 로직
└── shared/
    ├── theme/
    │   └── app_theme.dart             # 앱 테마
    └── widgets/
        ├── loading_indicator.dart     # 로딩 인디케이터
        └── custom_button.dart         # 커스텀 버튼
```

## 주요 기능

### 1. 블러 효과 (투명 블러)
- **위치**: [blur_processor.dart](../lib/core/filters/blur_processor.dart)
- **특징**:
  - 원형 블러: 원 안쪽이 블러, 바깥은 선명
  - 투명도 조절: 블러의 투명함 정도 조절 가능
  - 블러 강도 조절: 가우시안 블러 세기 조절
  - 경계 부드러움(feather) 조절

```dart
BlurProcessor.selectiveBlur(
  imageBytes,
  centerX: 0.5,        // 중심점 X (0.0~1.0)
  centerY: 0.5,        // 중심점 Y (0.0~1.0)
  radius: 200.0,       // 블러 반경 (픽셀)
  blurStrength: 10,    // 블러 강도 (1~30)
  opacity: 0.8,        // 투명도 (0.0~1.0)
  feather: 0.3,        // 경계 부드러움 (0.0~1.0)
);
```

### 2. 노이즈/그레인 효과
- **위치**: [grain_processor.dart](../lib/core/filters/grain_processor.dart)
- **종류**:
  - 가우시안 노이즈 (`addGaussianNoise`)
  - 필름 그레인 (`addFilmGrain`)
  - 흑백 그레인 (`addMonochromeGrain`)
  - 컬러 노이즈 (`addColorNoise`)
  - 빈티지 그레인 (`addVintageGrain`)

### 3. 필름 필터 (70+ 종류)
- **위치**: [editor_state.dart](../lib/features/editor/controllers/editor_state.dart)
- **카테고리**:
  - Kodak (컬러/흑백/슬라이드)
  - Fuji (컬러/슬라이드/흑백)
  - Ilford (흑백)
  - Polaroid/Instant
  - Agfa
  - Lomography
  - Cinema
  - Creative/Special

### 4. 프리셋 시스템
- **기본 프리셋**: 11개 (노이즈 프리셋 6개 포함)
- **사용자 프리셋**: 생성/편집/삭제/복제/공유 가능
- **일괄 처리**: 여러 이미지에 프리셋 일괄 적용

## 상태 관리

Riverpod 기반 상태 관리:

```dart
// 에디터 상태
final editorStateProvider = StateNotifierProvider<EditorStateNotifier, EditorState>(...);

// 프리셋 서비스
final presetServiceProvider = Provider<PresetService>(...);

// 모든 프리셋 (기본 + 사용자)
final presetsProvider = FutureProvider<List<Preset>>(...);

// 사용자 프리셋만
final userPresetsProvider = FutureProvider<List<Preset>>(...);
```

## 빌드 및 실행

```bash
# 의존성 설치
flutter pub get

# 개발 실행
flutter run

# 릴리즈 빌드
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## 의존성

주요 패키지:
- `flutter_riverpod`: 상태 관리
- `image`: 이미지 처리
- `image_picker`: 이미지 선택
- `image_cropper`: 이미지 크롭
- `share_plus`: 공유
- `shared_preferences`: 로컬 저장
- `uuid`: UUID 생성

## 참고 자료

### 노이즈 효과 구현
웹 검색 결과 기반 (2024):
- [Canvas Noise Tutorial](https://code.tutsplus.com/tutorials/how-to-generate-noise-with-canvas--net-16556)
- [Film Grain Effect CodePen](https://codepen.io/zadvorsky/pen/PwyoMm)
- [Pixlated Web Components](https://pixlated.vercel.app/)
