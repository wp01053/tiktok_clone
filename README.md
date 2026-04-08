# TikTok Clone

Flutter를 사용해 구현한 TikTok 스타일의 숏폼 영상 피드 과제입니다.

## 구현 항목

### 필수 요구사항

- 세로 스크롤 영상 피드
  - `PagedPageView` 기반 vertical swipe
  - 현재 정착된 페이지 기준 자동 재생
  - 화면을 벗어난 영상 자동 pause
- 영상 플레이어
  - `video_player` 사용
  - autoplay
  - 탭 pause / resume
  - buffering indicator
- Overlay UI
  - 오른쪽 `좋아요 / 댓글 / 공유`
  - 하단 `닉네임 / 캡션`
- 데이터
  - mock data 사용
  - public video URL 사용

### 가산점 항목

- 좋아요 toggle
- 더블탭 좋아요
- `infinite_scroll_pagination` 기반 infinite scroll
- `flutter_riverpod` 상태관리 적용
- 재생 로직과 UI를 분리한 확장 가능한 구조 적용

## 사용 패키지

- `flutter_riverpod`
- `video_player`
- `infinite_scroll_pagination`

## 실행 방법

```bash
flutter pub get
flutter run
```

## 프로젝트 구조

```text
lib/
  app/
    app.dart
    theme/
      app_theme.dart
  features/
    feed/
      data/
        data_sources/
          mock_feed_database.dart
        models/
          feed_video.dart
        repositories/
          feed_repository.dart
          mock_feed_repository.dart
      presentation/
        screens/
          feed_screen.dart
        services/
          feed_playback_coordinator.dart
        view_models/
          feed_state.dart
          feed_view_model.dart
        widgets/
          feed_video_loading_placeholder.dart
          feed_video_overlay.dart
          feed_video_preview_card.dart
  main.dart
```

## 구현 메모

- mock 영상 데이터는 public mp4 URL을 사용합니다.
- preload와 `thumbnailUrl` 기반 placeholder UI를 적용해 빠른 스와이프 시 검은 로딩 화면을 줄이도록 구성했습니다.
- `FeedPlaybackCoordinator`를 별도로 분리해 재생 컨트롤러 캐시와 preload 정책을 화면 레이어와 분리했습니다.

## Q1. (앱 구조 설계) 현재 프로젝트의 구조를 어떻게 설계했는지 설명해 주세요.

### 폴더 구조 설계 이유

`feed` 기능을 기준으로 `data / presentation` 레이어를 나누고, presentation 내부에서 다시 `screens / services / view_models / widgets`로 분리했습니다.  
과제 범위에서는 과도한 계층 분리를 피하면서도, 화면 조합, 상태 관리, 재생 로직, UI 위젯의 책임이 섞이지 않도록 구성하는 것을 목표로 했습니다.

- `data`
  - `models`: 피드 아이템 모델 정의
  - `repositories`: mock data / pagination / 좋아요 갱신 인터페이스 처리
- `presentation`
  - `screens`: 피드 화면 조합
  - `view_models`: Riverpod 기반 상태 관리
  - `services`: 영상 preload 및 playback lifecycle 관리
  - `widgets`: 비디오 카드, overlay, loading placeholder 등 UI 구성 요소

### 상태 관리 방식 선택 이유

상태 관리는 `flutter_riverpod`를 사용했습니다.  
선택 이유는 다음과 같습니다.

- repository 주입이 간단해 mock data와 실제 API 교체가 쉬움
- feed pagination 상태와 UI 상태를 분리해서 관리하기 좋음
- `FeedViewModel`에서 현재 인덱스, 좋아요 액션, paging controller를 한 곳에서 다룰 수 있음
- 테스트나 구조 확장 시 전역 singleton 없이 의존성을 명확하게 유지할 수 있음

### Video player lifecycle 처리 방식

영상 재생 lifecycle은 `FeedPlaybackCoordinator`에서 관리합니다.

- 현재 페이지를 기준으로 `이전 2개 / 현재 / 다음 2개` 범위의 컨트롤러만 유지
- 새 페이지에 접근하면 필요한 영상 컨트롤러를 미리 initialize
- 화면에서 멀어진 영상은 pause 후 dispose
- 썸네일은 `thumbnailUrl` 기반으로 precache
- 실제 카드 위젯은 전달받은 controller를 렌더링하고, 앱 lifecycle 변화와 탭 pause/resume만 처리

이 구조 덕분에 `FeedScreen`은 화면 조합에 집중하고, preload 정책 변경은 coordinator 한 곳에서 관리할 수 있도록 했습니다.

## Q2. (확장성 설계) 이 앱을 실제 TikTok 규모 서비스로 확장해야 한다면 어떤 부분을 변경하거나 개선해야 할까요?

### video preload 전략

현재는 단순한 `이전 2개 / 현재 / 다음 2개` 방식입니다.  
실서비스 규모로 확장한다면 다음이 필요합니다.

- 스크롤 방향과 속도 기반 preload 우선순위 조정
- 최근 본 영상 컨트롤러에 대한 LRU 캐시 전략
- 네트워크 상태에 따라 preload 범위를 동적으로 조절
- mp4 대신 HLS/DASH 기반 스트리밍 전략 검토

### 네트워크 처리

현재는 mock repository 기반입니다. 실제 서비스에서는 다음과 같이 바뀌어야 합니다.

- remote data source 분리
- 페이지네이션 API, retry, timeout, 에러 모델 표준화
- CDN / signed URL / adaptive bitrate streaming 적용
- 썸네일과 영상 메타데이터 캐시 정책 분리

### 상태 관리 구조

현재 구조는 과제 범위에 맞춘 단순화된 Riverpod 구조입니다.  
실서비스 확장 시에는 다음이 필요합니다.

- 피드 목록 상태, 재생 상태, 사용자 액션 상태를 더 세분화된 provider로 분리
- 인증, 사용자 프로필, 알림, 댓글 등 기능별 feature state 분리
- optimistic update와 에러 복구 흐름 정리

### 성능 최적화

실서비스 확장 시 가장 중요한 부분 중 하나입니다.

- 영상/이미지 캐시 정책 최적화
- 디코더/컨트롤러 재사용 전략 고도화
- frame drop 최소화를 위한 build 범위 축소
- analytics / logging / event tracking을 메인 스레드 부담이 적은 방식으로 분리
- 저사양 기기 대응을 위한 bitrate / preload 정책 차등 적용

## AI 사용 여부

- 사용함
- OpenAI Codex 기반 코드 에이전트와 협업해 구현을 진행했습니다.

## AI를 사용한 작업 범위

- 초기 Flutter 프로젝트 구조 정리
- infinite scroll, preload, thumbnail placeholder 구조 설계
- 코드검수 및 README 초안 정리

## 본인이 직접 작성한 부분

- 과제 요구사항 해석 및 기능 우선순위 결정
- UI/UX 피드백 반영 방향 결정
  - 아이콘 크기 및 배치
  - 하단 안전 영역 패딩
  - status bar 투명 처리
  - 페이지 정착 후 재생 정책
  - preload 범위 확장 여부
- public video URL / thumbnail 소스 선택과 동작 검수
- `flutter_riverpod`, `video_player`, `infinite_scroll_pagination` 적용 방향 결정 및 통합 검수
- 세로 영상 피드, autoplay, overlay UI, 좋아요 인터랙션 구현 
- 브랜치 전략, 커밋 메시지 검수, 최종 결과 확인

## Q3. (가장 어려웠던 문제) 구현 과정에서 가장 어려웠던 문제 하나를 설명해 주세요.

### 문제 상황

가장 어려웠던 문제는 Android 실기기에서 public video URL의 호환성과 빠른 스와이프 시 발생하는 로딩 UX였습니다. 일부 mp4는 브라우저에서는 재생되지만 앱에서는 인증서 체인 문제나 코덱 프로필 문제로 정상 재생되지 않았고, 재생 가능한 영상도 빠르게 스와이프하면 검은 화면이 보였습니다.

### 시도한 해결 방법

- 여러 public mp4 URL을 검토하며 실제 기기 재생 가능 여부를 비교
- preload 없이 기본 autoplay 구조만 먼저 구현
- `current/next` 수준의 단순 preload 구조를 먼저 적용

### 최종 해결 방법

- Android 기기에서 안정적으로 재생 가능한 public mp4 URL pool로 교체
- `FeedPlaybackCoordinator`를 도입해 재생/preload 로직을 화면에서 분리
- preload 범위를 `이전 2개 / 현재 / 다음 2개`까지 확장
- `thumbnailUrl` 기반 placeholder UI를 추가해 영상 준비 전에는 썸네일을 먼저 표시

## AI 코드 에이전트와의 대화 기록

- 사용 도구: OpenAI Codex

### 1. 초기 Flutter 프로젝트 구조 정리

#### 사용자 프롬프트

```text
현재 워크스페이스의 Flutter 프로젝트를 먼저 초기 세팅 단계까지 정리해줘.

이번 단계에서는 구현을 끝까지 하지 말고, 아래 범위까지만 작업해줘.

목표:
- TikTok Clone 과제 구현을 시작할 수 있도록 프로젝트 구조를 먼저 잡아줘.
- flutter_riverpod, video_player, infinite_scroll_pagination 패키지를 추가해줘.
- 이후 단계에서 vertical feed, video playback, overlay UI, pagination을 붙이기 좋은 형태로 폴더 구조를 정리해줘.
```

#### AI 응답 / 수행 내용 요약

- Flutter 프로젝트 상태 확인
- `flutter_riverpod`, `video_player`, `infinite_scroll_pagination` 추가
- 앱 진입점, 테마, feed feature 구조, mock repository / view model 뼈대 구성

### 2. infinite scroll, preload, thumbnail placeholder 구조 설계

#### 사용자 프롬프트

```text
현재 구현된 피드 구조를 기준으로 infinite scroll이 동작하는 형태로 정리해줘.

이번 단계에서는 단순히 mock 데이터 몇 개를 반복하는 수준이 아니라,
제한된 public video URL pool을 사용하더라도 사용자가 계속 스크롤할 수 있는 구조로 만들어줘.

추가로 빠른 스와이프 시 검은 로딩 화면이 보이는 문제를 줄이기 위해 preload를 적용해줘.
그리고 확장성을 고려해서 thumbnail 필드를 모델에 두고,
내가 전달하는 public image URL을 사용해서 placeholder UI를 먼저 보여주는 방식으로 정리해줘.
```

#### AI 응답 / 수행 내용 요약

- 제한된 public video URL pool을 재활용하면서도 무한 피드처럼 동작하는 구조 제안
- `PagingController`, `PagingListener`, `PagedPageView` 기반 infinite scroll 적용
- `thumbnailUrl` 필드 추가 및 public image URL 기반 placeholder UI 적용
- `FeedPlaybackCoordinator` 분리와 preload 범위 확장 방향 제안

### 3. 코드검수 및 README 초안 정리

#### 사용자 프롬프트

```text
README를 제출용 문서로 바로 사용할 수 있게 정리해줘.

포함할 항목은 아래 기준으로 맞춰줘.

- AI 사용 여부
- AI를 사용한 작업 범위
- AI 코드 에이전트와의 대화 기록

그리고 현재 구현 상태를 기준으로 과제 필수 요구사항과 가산점 항목에서 빠진 부분이 있는지도 같이 검토해서 반영해줘.
```

#### AI 응답 / 수행 내용 요약

- 현재 구현 상태를 과제 요구사항 / 가산점 항목 기준으로 점검
- README 초안 구조 제안
- AI 사용 범위, 직접 작성한 부분, 어려웠던 문제와 해결 방식 문안 정리
