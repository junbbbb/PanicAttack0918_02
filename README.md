# PanicAttack0918_02

Riverpod과 go_router 기반의 Flutter Feature-first 템플릿입니다. `docs/architecture.md`에서 전체 구조와 설계 의도를 자세히 설명합니다.

## 핵심 특징
- 4개의 하단 탭(`Home / Todos / Profile / Settings`)을 `StatefulShellRoute.indexedStack`으로 구성하여 탭별 독립 네비게이션 스택과 딥링크(`/home`, `/todos`, `/todos/:id`, `/profile`, `/settings`)를 지원합니다.
- Riverpod + 코드 제너레이션(`riverpod_annotation` / `riverpod_generator`)으로 상태를 관리하며, `ProviderScope`에서 SharedPreferences 기반 스토리지를 override하도록 부트스트랩합니다.
- 네트워크 계층은 `dio` Provider로 추상화되어 있으며, Todos 샘플 Feature가 API 클라이언트/Repository/Controller/Presentation 레이어를 모두 포함해 Light Clean Architecture 흐름을 보여줍니다.

## 패키지 구성
| 영역 | 패키지 | 비고 |
| --- | --- | --- |
| 상태 관리 | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` | Provider + 코드젠 |
| 라우팅 | `go_router` | `StatefulShellRoute.indexedStack` 적용 |
| 네트워크 | `dio` | 공용 Provider에서 옵션/인터셉터 정의 |
| 로컬 저장소 | `shared_preferences` | `KeyValueStore` 인터페이스로 추상화 |

## 디렉터리 개요
```
lib/
  app/                # MaterialApp.router, Shell scaffold, Router 정의
  core/               # 네트워크/스토리지 공통 모듈
  features/           # Feature-first 구조 (Todos 예시 포함)
  bootstrap.dart      # ProviderScope + SharedPreferences 주입
  main.dart           # bootstrap() 호출
```

자세한 설명과 확장 방법은 `docs/architecture.md`를 참고하세요.

## 개발 플로우
1. 패키지 설치
   ```bash
   flutter pub get
   ```
2. Riverpod 코드 생성
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. 포맷 & 린트
   ```bash
   dart format lib
   flutter analyze
   ```
4. 실행
   ```bash
   flutter run
   ```

> 현재 저장소는 예시로 생성된 `.g.dart` 파일을 포함합니다. 의존성 혹은 Provider 선언을 수정한 뒤에는 `build_runner`를 재실행해 최신 상태를 유지하세요.

## 다음 작업 아이디어
1. 실제 API 엔드포인트를 연결하고 `TodosApiClient`/`TodosRepository`에 에러 처리와 동기화 로직을 보강하세요.
2. Feature별 테스트 코드(Controller 단위 테스트, Widget 테스트)를 추가해 회귀를 방지하세요.
3. Profile/Settings Feature에 필요한 도메인/데이터 계층을 추가해 Skeleton 화면을 확장하세요.
