# Editor Feature

Flutter 기반 레트로 필름 사진 편집 기능

## 파일 구조

```
lib/features/editor/
├── editor_screen_new.dart         # 메인 에디터 화면 (editor_screen.dart로 이름 변경 필요)
├── controllers/
│   └── editor_state.dart          # Riverpod 상태 관리
└── widgets/
    ├── blur_control.dart          # 블러 조절 패널
    ├── filter_selector.dart       # 필터 선택 패널
    ├── grain_control.dart         # 그레인 조절 패널
    └── resize_control.dart        # 리사이즈 패널
```

## 사용 방법

### 1. 에디터 화면 호출

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photoedit/features/editor/editor_screen_new.dart';

// 이미지 파일과 함께 에디터 화면 열기
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditorScreen(
      imageFile: File('path/to/image.jpg'),
    ),
  ),
);

if (result != null) {
  // 저장된 이미지 파일 경로
  final savedImageFile = result as File;
}
```

### 2. 상태 관리 (Riverpod)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photoedit/features/editor/controllers/editor_state.dart';

// Consumer 위젯에서 사용
Consumer(
  builder: (context, ref, child) {
    final editorState = ref.watch(editorStateProvider);

    return Text('블러 강도: ${editorState.blurIntensity}');
  },
)

// 상태 변경
ref.read(editorStateProvider.notifier).setBlurIntensity(0.5);
ref.read(editorStateProvider.notifier).selectFilter('vintage');
```

## 주요 기능

### 1. 블러 효과
- 강도 조절: 0~100%
- 프리셋: 없음, 약함, 중간, 강함
- 레트로 필름의 얕은 심도 표현

### 2. 필름 필터
- 5가지 필터: 빈티지, 흑백, 세피아, 쿨톤, 웜톤
- 필터 강도 조절: 0~100%
- 가로 스크롤 썸네일 선택

### 3. 그레인 효과
- 강도 조절: 0~100%
- 프리셋: 없음, 미세, 적당, 강함
- 필름 카메라 입자감 재현

### 4. 리사이즈
- 종횡비: 자유, 1:1, 4:3, 16:9
- 해상도: 원본, 2K, 1080p, 720p

### 5. 프리셋 저장
- 현재 편집 설정을 프리셋으로 저장
- 블러, 필터, 그레인 값 포함
- SharedPreferences를 통한 영구 저장 (TODO)

## UI 구조

```
┌─────────────────────────────────────┐
│  ←                        💾 저장   │  <- AppBar
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │       이미지 미리보기         │    │  <- 3/5 화면
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌──────┬──────┬──────┬──────┐     │  <- 탭 버튼
│  │ 블러 │ 필터 │그레인│리사이즈│     │
│  └──────┴──────┴──────┴──────┘     │
│                                     │
│  [조절 패널 - 선택된 탭에 따라 변경]  │  <- 2/5 화면
│                                     │
│  [초기화] [프리셋저장💾]              │  <- 하단 액션
└─────────────────────────────────────┘
```

## 상태 모델

### EditorState

```dart
class EditorState {
  final File? imageFile;          // 편집 중인 이미지
  final double blurIntensity;     // 블러 강도 (0.0 ~ 1.0)
  final String? selectedFilter;   // 선택된 필터 ID
  final double filterIntensity;   // 필터 강도 (0.0 ~ 1.0)
  final double grainIntensity;    // 그레인 강도 (0.0 ~ 1.0)
  final String aspectRatio;       // 종횡비 ('free', '1:1', '4:3', '16:9')
  final String resolution;        // 해상도 ('original', '2k', '1080p', '720p')
  final bool isProcessing;        // 처리 중 여부
  final String? errorMessage;     // 에러 메시지
}
```

## TODO

- [ ] 실제 이미지 처리 로직 구현 (image 패키지 사용)
- [ ] 프리셋 저장/불러오기 구현 (SharedPreferences)
- [ ] 실시간 미리보기 최적화
- [ ] 이미지 저장 기능 구현 (파일 시스템)
- [ ] 공유 기능 추가 (share_plus)
- [ ] 실행 취소/다시 실행 기능
- [ ] 커스텀 필터 추가 기능

## 파일명 변경 필요

`editor_screen_new.dart`를 `editor_screen.dart`로 변경해야 합니다:

```bash
mv lib/features/editor/editor_screen_new.dart lib/features/editor/editor_screen.dart
```

## 의존성

이미 pubspec.yaml에 포함됨:
- flutter_riverpod: ^2.6.1
- image: ^4.3.0
- shared_preferences: ^2.3.4
- image_picker: ^1.1.2
