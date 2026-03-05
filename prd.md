# PhotoEdit - 레트로 필름 사진 편집 앱 PRD

> **Version**: 1.0.0 (MVP)
> **Platform**: Android (Flutter 기반, iOS 확장 가능)
> **Target**: 오픈소스 라이브러리 기반 개발

---

## 1. 프로젝트 개요

### 1.1 목표
빈티지 필름 감성의 사진 편집 앱 개발. 블러 처리, 레트로 필름 필터(코닥/후지필름), 노이즈/그레인 효과, 리사이즈 기능 제공. **편집 프리셋 저장 및 일괄 처리 지원.**

### 1.2 핵심 가치
- **심플한 UX**: 복잡한 기능 없이 핵심 기능에 집중
- **필름 감성**: 코닥, 후지필름 등 실제 필름 색감 재현
- **빠른 처리**: GPU 가속 활용한 실시간 미리보기
- **프리셋 시스템**: 나만의 편집 스타일 저장 및 재사용
- **일괄 처리**: 여러 이미지에 동일 프리셋 한 번에 적용

---

## 2. 핵심 기능

### 2.1 블러 처리 (Blur)

| 항목 | 설명 |
|------|------|
| **기능** | 이미지 전체 또는 부분 가우시안 블러 |
| **조절 옵션** | 블러 강도 (0~100%), 블러 영역 크기 |
| **적용 방식** | 슬라이더로 실시간 조절 |

#### 오픈소스 라이브러리

| 패키지 | 용도 | 링크 |
|--------|------|------|
| **Flutter 내장** | `ImageFilter.blur` | [Flutter API](https://api.flutter.dev/flutter/dart-ui/ImageFilter/ImageFilter.blur.html) |
| **blur** | 위젯 블러 래퍼 | [pub.dev/blur](https://pub.dev/packages/blur) |
| **progressive_blur** | 점진적 블러 | [GitHub](https://github.com/kekland/progressive_blur) |
| **image** | 픽셀 단위 블러 처리 | [pub.dev/image](https://pub.dev/packages/image) |

#### 구현 방식
```dart
// Flutter 내장 ImageFilter 활용
ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue)

// image 패키지 - 픽셀 단위 처리
import 'package:image/image.dart' as img;
img.gaussianBlur(image, radius: blurRadius);
```

---

### 2.2 레트로 필름 필터 (Film Filters)

| 항목 | 설명 |
|------|------|
| **기능** | 코닥, 후지필름 등 클래식 필름 색감 재현 |
| **필터 종류** | 10+ 프리셋 필터 |
| **조절 옵션** | 필터 강도 (0~100%) |

#### 지원 필름 프리셋

**Kodak 계열**
| 필터명 | 특징 |
|--------|------|
| Kodak Portra 400 | 따뜻한 스킨톤, 포트레이트용 |
| Kodak Ektar 100 | 선명한 색상, 풍경용 |
| Kodak Gold 200 | 따뜻한 톤, 일상 촬영용 |
| Kodak Tri-X 400 | 클래식 흑백 |

**Fujifilm 계열**
| 필터명 | 특징 |
|--------|------|
| Fuji Velvia 50 | 고채도, 풍경용 |
| Fuji Provia 100 | 자연스러운 색감 |
| Fuji Superia 400 | 빈티지 감성 |
| Fuji Pro 400H | 부드러운 파스텔톤 |

**기타**
| 필터명 | 특징 |
|--------|------|
| Polaroid | 즉석 카메라 감성 |
| Cinestill 800T | 시네마틱 룩 |

#### 오픈소스 라이브러리

| 패키지 | 용도 | 링크 |
|--------|------|------|
| **color_filter_extension** ⭐ | 90+ 프리셋, 코닥/후지 내장 | [pub.dev](https://pub.dev/packages/color_filter_extension) |
| **photofilters** | 커스텀 필터 생성 | [GitHub](https://github.com/skkallayath/photofilters) |
| **image_filter_pro** | 프리셋 + 수동 조절 | [pub.dev](https://pub.dev/packages/image_filter_pro) |

#### 구현 방식 (color_filter_extension)
```dart
import 'package:color_filter_extension/color_filter_extension.dart';

// Kodak Portra 400 적용
ColorFiltered(
  colorFilter: ColorFilterExt.preset(ColorFiltersPreset.kodakPortra400()),
  child: Image.file(imageFile),
)

// Fuji Velvia 50 적용
ColorFiltered(
  colorFilter: ColorFilterExt.preset(ColorFiltersPreset.fujiVelvia50()),
  child: Image.file(imageFile),
)

// 필터 강도 조절 (0.0 ~ 1.0)
ColorFilterExt.preset(ColorFiltersPreset.kodakGold200(), strength: 0.7)
```

---

### 2.3 노이즈/그레인 효과 (Film Grain)

| 항목 | 설명 |
|------|------|
| **기능** | 필름 그레인/노이즈 텍스처 추가 |
| **조절 옵션** | 그레인 강도, 그레인 크기 |
| **노이즈 타입** | Gaussian, Uniform, Salt & Pepper |

#### 오픈소스 라이브러리

| 패키지 | 용도 | 링크 |
|--------|------|------|
| **grain** ⭐ | 필름 그레인 위젯 | [pub.dev](https://pub.dev/packages/grain) |
| **image** | 노이즈 함수 내장 | [API Docs](https://pub.dev/documentation/image/latest/image/noise.html) |

#### 구현 방식
```dart
// grain 패키지 - 위젯 래퍼
import 'package:grain/grain.dart';

GrainWidget(
  grainIntensity: 0.5,  // 0.0 ~ 1.0
  child: Image.file(imageFile),
)

// image 패키지 - 픽셀 단위 노이즈
import 'package:image/image.dart' as img;

img.noise(image, sigma: 10, type: NoiseType.gaussian);
img.noise(image, sigma: 5, type: NoiseType.uniform);
```

---

### 2.4 리사이즈 (Resize)

| 항목 | 설명 |
|------|------|
| **기능** | 이미지 크기 조절 |
| **프리셋** | 1:1, 4:3, 16:9, 9:16, Custom |
| **해상도** | 원본, 2K, 1080p, 720p, Custom |

#### 오픈소스 라이브러리

| 패키지 | 용도 | 링크 |
|--------|------|------|
| **image** ⭐ | 리사이즈 핵심 | [pub.dev](https://pub.dev/packages/image) |
| **image_cropper** | 크롭 UI | [pub.dev](https://pub.dev/packages/image_cropper) |
| **flutter_image_compress** | 압축 + 리사이즈 | [pub.dev](https://pub.dev/packages/flutter_image_compress) |

#### 구현 방식
```dart
import 'package:image/image.dart' as img;

// 리사이즈 (비율 유지)
final resized = img.copyResize(image, width: 1920);

// 특정 크기로 리사이즈
final resized = img.copyResize(image, width: 1920, height: 1080);

// 크롭
final cropped = img.copyCrop(image, x: 0, y: 0, width: 500, height: 500);
```

---

### 2.5 편집 프리셋 시스템 (Edit Presets) ⭐ NEW

| 항목 | 설명 |
|------|------|
| **기능** | 현재 편집 설정을 프리셋으로 저장/불러오기 |
| **저장 항목** | 필터, 블러, 그레인, 리사이즈 모든 설정 |
| **내보내기** | JSON 형식으로 공유 가능 |

#### 프리셋 데이터 구조
```dart
class EditPreset {
  final String id;
  final String name;
  final String? thumbnail;  // Base64 썸네일
  final DateTime createdAt;

  // 필터 설정
  final String? filmFilter;      // 필름 필터 ID
  final double filterStrength;   // 필터 강도 (0.0 ~ 1.0)

  // 블러 설정
  final double blurStrength;     // 블러 강도 (0.0 ~ 1.0)
  final double blurRadius;       // 블러 반경

  // 그레인 설정
  final double grainIntensity;   // 그레인 강도 (0.0 ~ 1.0)
  final double grainSize;        // 그레인 크기

  // 리사이즈 설정
  final String? aspectRatio;     // "1:1", "4:3", "16:9", null=원본
  final int? outputWidth;        // 출력 너비 (null=원본)
  final int? outputHeight;       // 출력 높이 (null=원본)
}
```

#### JSON 스키마
```json
{
  "id": "preset_001",
  "name": "My Vintage Look",
  "createdAt": "2024-01-15T10:30:00Z",
  "filter": {
    "type": "kodakPortra400",
    "strength": 0.8
  },
  "blur": {
    "strength": 0.1,
    "radius": 5
  },
  "grain": {
    "intensity": 0.4,
    "size": 0.3
  },
  "resize": {
    "aspectRatio": "4:3",
    "width": 1920,
    "height": null
  }
}
```

#### 빈티지 효과 = 필름 + 그레인 조합 ⭐

> **핵심 인사이트**: 진짜 빈티지 느낌은 필름 색감 + 노이즈/그레인의 **조합**에서 나온다

```
┌─────────────────────────────────────────────────────────────┐
│                    빈티지 효과 레시피                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [필름 색감]  +  [그레인]  +  [추가 효과]  =  빈티지 감성     │
│                                                             │
│  예시:                                                       │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐                   │
│  │ Kodak   │ + │ 중간    │ + │ 약한   │ = 80년대 감성      │
│  │ Gold200 │   │ 그레인   │   │ 블러   │                   │
│  └─────────┘   └─────────┘   └─────────┘                   │
│                                                             │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐                   │
│  │ Fuji    │ + │ 강한    │ + │ 페이드 │ = 90년대 일본 감성  │
│  │Superia  │   │ 그레인   │   │        │                   │
│  └─────────┘   └─────────┘   └─────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

| 빈티지 스타일 | 필름 | 그레인 강도 | 특징 |
|--------------|------|------------|------|
| **70s Warm** | Kodak Gold 200 | 40% | 따뜻한 오렌지톤 + 거친 질감 |
| **80s Retro** | Kodak Portra 400 | 30% | 부드러운 스킨톤 + 중간 질감 |
| **90s Japan** | Fuji Superia 400 | 50% | 청록 그림자 + 강한 질감 |
| **Faded Memory** | Fuji Pro 400H | 25% | 파스텔톤 + 부드러운 질감 |
| **Cinema Look** | Cinestill 800T | 35% | 텅스텐 블루 + 영화 질감 |

#### 기본 제공 프리셋 (필름 + 그레인 조합)
| 프리셋명 | 필름 | 그레인 | 추가 효과 |
|----------|------|--------|----------|
| **Kodak Summer** | Portra 400 (80%) | 25% | 따뜻한 톤 |
| **Fuji Landscape** | Velvia 50 (90%) | 15% | 고채도 |
| **Lo-Fi Vintage** | Gold 200 (70%) | 50% | 페이드 |
| **B&W Classic** | Tri-X 400 (100%) | 40% | 높은 대비 |
| **Instant Memory** | Polaroid (85%) | 30% | 부드러운 블러 |
| **90s Japan** | Superia 400 (75%) | 45% | 청록 그림자 |
| **Cinema Night** | Cinestill 800T (80%) | 35% | 텅스텐 블루 |

#### 오픈소스 라이브러리 (저장)

| 패키지 | 용도 | 링크 |
|--------|------|------|
| **shared_preferences** | 간단한 프리셋 저장 | [pub.dev](https://pub.dev/packages/shared_preferences) |
| **hive** ⭐ | 빠른 NoSQL 저장 | [pub.dev](https://pub.dev/packages/hive) |
| **isar** | 고성능 DB | [pub.dev](https://pub.dev/packages/isar) |

---

### 2.6 일괄 처리 (Batch Processing) ⭐ NEW

| 항목 | 설명 |
|------|------|
| **기능** | 여러 이미지에 동일 프리셋 일괄 적용 |
| **선택** | 갤러리에서 다중 이미지 선택 (최대 50장) |
| **처리** | 백그라운드 처리 + 진행률 표시 |
| **출력** | 별도 폴더에 저장 또는 원본 대체 |

#### UI 흐름
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
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 📷  │ │ 📷  │ │ 📷  │ │ 📷  │   │
│  │  ✓  │ │  ✓  │ │  ✓  │ │  ✓  │   │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
│                                     │
│  출력 설정:                         │
│  ○ 새 폴더에 저장 (PhotoEdit_Batch) │
│  ○ 원본 대체                        │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━ 75%          │
│  처리 중: 9/12                       │
│                                     │
│  [취소]              [일괄 처리 시작]│
└─────────────────────────────────────┘
```

#### 구현 방식
```dart
class BatchProcessor {
  final EditPreset preset;
  final List<File> images;

  Stream<BatchProgress> process() async* {
    for (int i = 0; i < images.length; i++) {
      yield BatchProgress(
        current: i + 1,
        total: images.length,
        status: 'Processing ${images[i].path}',
      );

      // Isolate에서 이미지 처리 (UI 블로킹 방지)
      final processed = await compute(
        _processImage,
        ProcessParams(image: images[i], preset: preset),
      );

      await _saveImage(processed);
    }
  }
}
```

#### 백그라운드 처리 라이브러리

| 패키지 | 용도 | 링크 |
|--------|------|------|
| **flutter_isolate** | Isolate 헬퍼 | [pub.dev](https://pub.dev/packages/flutter_isolate) |
| **workmanager** | 백그라운드 작업 | [pub.dev](https://pub.dev/packages/workmanager) |
| **multi_image_picker** | 다중 이미지 선택 | [pub.dev](https://pub.dev/packages/multi_image_picker) |

---

## 3. 기술 스택

### 3.1 핵심 의존성

```yaml
# pubspec.yaml
name: photoedit
description: 레트로 필름 사진 편집 앱
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.16.0'

dependencies:
  flutter:
    sdk: flutter

  # 이미지 처리 핵심
  image: ^4.1.0                        # 블러, 리사이즈, 노이즈
  color_filter_extension: ^0.0.2       # 필름 필터 (90+ 프리셋)
  grain: ^1.0.0                        # 필름 그레인 효과

  # 이미지 I/O
  image_picker: ^1.0.0                 # 갤러리/카메라 접근
  image_cropper: ^5.0.0                # 크롭 UI
  flutter_image_compress: ^2.1.0       # 압축 + 리사이즈
  multi_image_picker_view: ^1.0.0      # 다중 이미지 선택 (일괄 처리)

  # 데이터 저장 (프리셋)
  hive: ^2.2.0                         # 프리셋 로컬 저장
  hive_flutter: ^1.1.0

  # 상태 관리
  flutter_riverpod: ^2.4.0             # 상태 관리
  riverpod_annotation: ^2.3.0

  # UI/UX
  go_router: ^13.0.0                   # 라우팅
  flutter_hooks: ^0.20.0               # Hook 위젯

  # 유틸리티
  path_provider: ^2.1.0                # 파일 경로
  share_plus: ^7.0.0                   # 공유 기능
  permission_handler: ^11.0.0          # 권한 관리
  uuid: ^4.2.0                         # 프리셋 ID 생성

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
```

### 3.2 프로젝트 구조

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
├── features/
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   ├── editor/
│   │   ├── editor_screen.dart
│   │   ├── widgets/
│   │   │   ├── blur_control.dart
│   │   │   ├── filter_selector.dart
│   │   │   ├── grain_control.dart
│   │   │   └── resize_control.dart
│   │   └── controllers/
│   │       └── editor_controller.dart
│   ├── presets/                        # NEW: 프리셋 관리
│   │   ├── presets_screen.dart
│   │   ├── preset_detail_screen.dart
│   │   └── widgets/
│   │       ├── preset_card.dart
│   │       └── preset_form.dart
│   ├── batch/                          # NEW: 일괄 처리
│   │   ├── batch_screen.dart
│   │   ├── batch_progress_screen.dart
│   │   └── widgets/
│   │       ├── image_grid_selector.dart
│   │       └── batch_settings.dart
│   └── export/
│       └── export_screen.dart
├── core/
│   ├── filters/
│   │   ├── film_filters.dart
│   │   ├── blur_processor.dart
│   │   ├── grain_processor.dart
│   │   └── resize_processor.dart
│   ├── presets/                        # NEW
│   │   ├── preset_model.dart
│   │   ├── preset_repository.dart
│   │   └── default_presets.dart
│   ├── batch/                          # NEW
│   │   ├── batch_processor.dart
│   │   └── batch_progress.dart
│   ├── utils/
│   │   ├── image_utils.dart
│   │   └── file_utils.dart
│   └── constants/
│       └── filter_presets.dart
└── shared/
    ├── widgets/
    └── theme/
```

---

## 4. UI/UX 설계

### 4.1 화면 구성

```
┌─────────────────────────────────────┐
│            홈 화면                   │
│  ┌─────────────────────────────┐    │
│  │     갤러리에서 선택          │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │     카메라로 촬영            │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │     일괄 처리 📦            │    │  ← NEW
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │     내 프리셋 관리 ⚙️        │    │  ← NEW
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────┐
│           에디터 화면                │
│  ┌─────────────────────────────┐    │
│  │       이미지 미리보기         │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌──────┬──────┬──────┬──────┐     │
│  │ 블러 │ 필터 │그레인│리사이즈│     │
│  └──────┴──────┴──────┴──────┘     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │     조절 패널 (슬라이더)      │    │
│  └─────────────────────────────┘    │
│                                     │
│  [취소] [프리셋저장💾]      [저장]   │  ← 프리셋 저장 버튼 추가
└─────────────────────────────────────┘
```

### 4.2 기능별 조절 패널

**블러 패널**
```
블러 강도: ●━━━━━━━━━━○ 50%
블러 크기: ●━━━━○━━━━━ 30px
```

**필터 패널**
```
┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐
│Portra│ │Ektar │ │Velvia│ │Superia│
│ 400  │ │ 100  │ │  50  │ │  400  │
└──────┘ └──────┘ └──────┘ └──────┘
필터 강도: ●━━━━━━━━○━ 80%
```

**그레인 패널**
```
그레인 강도: ●━━━━━○━━━━ 40%
그레인 크기: ●━━○━━━━━━━ 20%
```

**리사이즈 패널**
```
비율: [1:1] [4:3] [16:9] [자유]
해상도: [원본] [2K] [1080p] [720p]
```

### 4.3 프리셋 관리 화면

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
│  │  My  │ │ My   │ │  +   │        │
│  │Preset│ │Look  │ │ NEW  │        │
│  └──────┘ └──────┘ └──────┘        │
│                                     │
│  길게 눌러서: 편집 | 삭제 | 공유     │
└─────────────────────────────────────┘
```

---

## 5. 개발 일정 (MVP)

### Phase 1: 기초 설정 (1일)
- [ ] Flutter 프로젝트 초기화
- [ ] 의존성 설치 및 설정
- [ ] 기본 라우팅 구성
- [ ] Hive 데이터베이스 설정

### Phase 2: 이미지 I/O (1일)
- [ ] 갤러리/카메라 이미지 선택
- [ ] 다중 이미지 선택 (일괄 처리용)
- [ ] 이미지 로딩 및 표시
- [ ] 이미지 저장 기능

### Phase 3: 핵심 기능 구현 (3일)
- [ ] 블러 처리 구현
- [ ] 필름 필터 적용 (color_filter_extension)
- [ ] 그레인 효과 구현
- [ ] 리사이즈 기능 구현

### Phase 4: 프리셋 시스템 (2일) ⭐ NEW
- [ ] 프리셋 데이터 모델 구현
- [ ] 프리셋 저장/불러오기 (Hive)
- [ ] 기본 프리셋 5종 추가
- [ ] 프리셋 관리 UI

### Phase 5: 일괄 처리 (2일) ⭐ NEW
- [ ] 다중 이미지 선택 UI
- [ ] 일괄 처리 엔진 (Isolate)
- [ ] 진행률 표시 UI
- [ ] 결과 저장

### Phase 6: UI/UX (2일)
- [ ] 에디터 화면 UI
- [ ] 조절 패널 위젯
- [ ] 실시간 미리보기

### Phase 7: 마무리 (1일)
- [ ] 내보내기/공유 기능
- [ ] 버그 수정 및 최적화
- [ ] 테스트

**총 예상 기간: 12일 (약 2.5주)**

---

## 6. 참고 자료

### 오픈소스 패키지
- [color_filter_extension](https://pub.dev/packages/color_filter_extension) - 90+ 필름 프리셋
- [grain](https://pub.dev/packages/grain) - 필름 그레인 효과
- [image](https://pub.dev/packages/image) - 이미지 처리 핵심
- [photofilters](https://github.com/skkallayath/photofilters) - 커스텀 필터
- [pro_image_editor](https://github.com/hm21/pro_image_editor) - 종합 에디터 참고
- [hive](https://pub.dev/packages/hive) - 프리셋 저장

### 레퍼런스 앱
- [VSCO](https://www.vsco.co/features/film-filters) - 필름 필터 UI/UX 참고
- [Free Film Emulator](https://29a.ch/film-emulator/) - 필름 에뮬레이션 알고리즘

### Flutter 문서
- [ImageFilter.blur](https://api.flutter.dev/flutter/dart-ui/ImageFilter/ImageFilter.blur.html)
- [ColorFiltered Widget](https://api.flutter.dev/flutter/widgets/ColorFiltered-class.html)
- [Isolate - Background Processing](https://docs.flutter.dev/perf/isolates)

---

## 7. 향후 확장 계획 (v2.0)

- [ ] iOS 출시
- [ ] 부분 블러 (브러시 모드)
- [ ] 커스텀 필터 생성 (LUT 지원)
- [ ] 필터 레이어 중첩
- [ ] 비네팅 효과
- [ ] 라이트 리크 효과
- [ ] 히스토리/되돌리기
- [ ] 프리셋 클라우드 동기화
- [ ] 프리셋 마켓플레이스
