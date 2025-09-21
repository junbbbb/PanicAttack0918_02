# PanicAttack0918_02 Architecture Guide

이 문서는 `PanicAttack0918_02` 템플릿의 구조와 핵심 개념을 정리해, 이후 작업자(사람 혹은 AI)가 빠르게 컨텍스트를 획득하고 이어서 개발할 수 있도록 돕습니다.

## Overview
- **Framework**: Flutter (stable channel, Dart 3)
- **State Management**: Riverpod 2 (`flutter_riverpod`, `riverpod_annotation` + code generation)
- **Routing**: `go_router` with `StatefulShellRoute.indexedStack`
- **Networking**: `dio` (추후 API 연동 시 인터셉터 및 에러 처리를 주입)
- **Storage**: `shared_preferences` → `KeyValueStore` 추상화로 감싸서 테스트/교체 용이
- **Architecture Style**: Feature-first 디렉터리 구조 + Light Clean Architecture (Presentation / Controller / Data / Domain 계층을 각 feature 폴더 내부에 배치)

## Directory Layout
```
lib/
  app/                      # 앱 루트, Router, Shell Scaffold
  core/
    network/                # dio Provider 정의
    storage/                # KeyValueStore 추상화 및 SharedPreferences 구현
  features/
    home/presentation/      # 홈 탭 UI (샘플 텍스트)
    todos/                  # Light Clean 구조 예시 Feature
      controllers/          # Riverpod AsyncNotifier 등 상태 로직
      data/                 # Repository, API client, 캐싱 연동
      domain/               # Entity 모델 (Todo)
      presentation/         # 페이지/위젯/UI
    profile/presentation/   # 프로필 탭 UI (Skeleton)
    settings/presentation/  # 설정 탭 UI (Skeleton)
  bootstrap.dart            # ProviderScope 초기화 및 SharedPreferences 주입
  main.dart                 # 앱 엔트리 → bootstrap 호출
```

## Core Structural Patterns
- **ProviderScope Override**: `lib/bootstrap.dart:15-20`에서 `keyValueStoreProvider`를 SharedPreferences 기반 구현으로 오버라이드하여 애플리케이션 전역에서 의존성을 주입합니다.
- **Generated Providers**: `riverpod_annotation`을 사용하여 `.g.dart` 파일이 생성됩니다. 현재는 예시로 직접 커밋된 상태이며, `build_runner` 재실행 시 재생성하세요.
- **Feature-first + Light Clean**: 공용 로직(`core/`)은 최소화하고, 각 Feature 폴더 내부에서 Data/Domain/Presentation을 최대한 완결되도록 유지합니다.

## Feature Modules
### Home/Profile/Settings
- 현재는 Skeleton UI만 존재하며, 독립 네비게이션 스택이 동작하는지 확인할 수 있는 간단한 화면입니다.
- 실제 기능을 붙일 때에는 각 feature 안에 `data/` `domain/` 등을 추가해 확장하세요.

### Todos Feature (샘플)
- **Domain**: `Todo` 엔티티 (`lib/features/todos/domain/todo.dart`)는 값 타입으로 정의되어 immutability를 보장합니다.
- **Data**:
  - `TodosApiClient` (`lib/features/todos/data/todos_api_client.dart`)는 `dio`로 `/todos` 엔드포인트 호출을 예시로 제공합니다. 현재는 실패 시 빈 리스트를 반환하며, 에러 처리 로직 확장 여지가 있습니다.
  - `TodosRepository` (`lib/features/todos/data/todos_repository.dart`)는 API → 캐시(`KeyValueStore`) → 시드 데이터의 3단계 로딩 전략을 보여줍니다.
- **Controllers**: `TodosController` (`lib/features/todos/controllers/todos_controller.dart`)는 `AsyncNotifier` 기반으로 목록 로딩, 추가, 토글, 파생 Selector(`completedTodoCount`, `todoById`)를 제공합니다.
- **Presentation**:
  - `TodosPage` (`lib/features/todos/presentation/todos_page.dart`)가 목록/추가/토글 UI를 담당합니다.
  - `AddTodoDialog` (`lib/features/todos/presentation/add_todo_dialog.dart`)는 새로운 Todo 생성 폼입니다.
  - `TodoDetailPage` (`lib/features/todos/presentation/todo_detail_page.dart`)는 `/todos/:id` 딥링크에 대응하며, 선택된 Todo 상태를 상세 표시하고 토글 기능을 제공합니다.

## State Management with Riverpod
- **Provider 구성**: 모든 Provider는 `riverpod_annotation`의 `@Riverpod` 데코레이터로 선언되어 `.g.dart`에 실제 Provider 인스턴스를 생성합니다.
- **Async State**: TodosController는 `AsyncNotifier`를 확장하여 로딩(Spinner), 성공(목록), 오류(에러 뷰) 상태를 자연스럽게 표현합니다.
- **Select/Derived State**: `completedTodoCountProvider`, `todoByIdProvider`처럼 파생 상태를 별도 Provider로 분리하여 UI에서 개별적으로 구독할 수 있습니다.
- **DI & Override**: 앱 전체에서 필요한 싱글턴 의존성(Dio, KeyValueStore 등)은 ProviderScope에서 override하거나 `@Riverpod` keepAlive Provider로 노출합니다.

## Navigation with go_router
- **Shell**: `StatefulShellRoute.indexedStack` ( `lib/app/router.dart:28-83` )을 사용하여 하단 탭 별 독립 네비게이션 스택을 유지합니다.
- **Navigator Keys**: 각 탭에 고유한 `navigatorKey`를 부여 (`lib/app/router.dart:16-20`)해 상태 복원과 딥링크 시 정확한 스택을 대상으로 push합니다.
- **Routes**: 고정 패스(`/home`, `/todos`, `/profile`, `/settings`)와 중첩 라우트(`/todos/:id`)를 통해 딥링크를 지원합니다.
- **NavigationBar**: `AppShell` (`lib/app/shell_scaffold.dart`)에서 `NavigationBar`로 탭 전환을 처리하며, 동일 탭 재탭 시 루트로 pop 되도록 `initialLocation` 옵션을 전달합니다.

## Data Layer (Dio + KeyValueStore)
- **Dio Provider**: `lib/core/network/dio_client.dart`에서 전역 Dio 인스턴스를 생성하고 기본 옵션/로깅 인터셉터를 설정했습니다. 실제 API 연동 시 Base URL, 헤더, 에러 처리를 여기에서 확장하세요.
- **KeyValueStore 추상화**: `lib/core/storage/key_value_store.dart`는 키-값 저장에 대한 인터페이스를 정의합니다. 현재 구현체(`SharedPreferencesKeyValueStore`)는 SharedPreferences에 매핑됩니다.
- **Persistence Workflow**: TodosRepository가 캐시를 우선 읽고, 없을 경우 API 호출 → 시드 데이터 순으로 데이터를 준비합니다.

## Build & Tooling Workflow
1. 의존성 설치
   ```bash
   flutter pub get
   ```
2. 코드 생성 (Riverpod provider)
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

> 현재 저장소에는 예시용으로 생성된 `.g.dart` 파일을 포함했습니다. 의존성 버전을 변경하거나 Provider 시그니처를 수정한 뒤에는 반드시 `build_runner`를 재실행하세요.

## Extending the Template
- **새 Feature 추가**: `lib/features/<feature-name>/` 아래에 `data/`, `domain/`, `controllers/`, `presentation/` 디렉터리를 만들고 필요한 레이어를 배치하세요. 비즈니스 로직/상태는 Riverpod Notifier로 캡슐화합니다.
- **API 연동**: `core/network/dio_client.dart`에 인증 토큰, 공용 헤더, 에러 매핑 등을 추가하세요. Feature별 API 클라이언트는 `data/` 레이어에 위치시키고 Repository에서 조합합니다.
- **로컬 캐시 확장**: `KeyValueStore` 인터페이스를 유지한 채 Hive나 SQLite 등 다른 구현으로 교체할 수 있습니다. `bootstrap.dart`에서 Provider override만 변경하면 됩니다.
- **테스트 전략**: Provider override를 활용해 Fake Repository/Client를 주입하면 Widget 테스트 및 단위 테스트가 용이합니다.

## Testing Strategy (Future Work)
- 현재 샘플에는 테스트 코드가 없습니다. 추후 다음과 같은 테스트를 권장합니다.
  - TodosController 단위 테스트 (Repository를 Fake로 주입)
  - go_router navigation smoke test (`pumpWidget` + `MaterialApp.router`)
  - 위젯 테스트: `TodosPage`에서 추가/토글 동작 검증
- 테스트 시 SharedPreferences를 대체하기 위해 `keyValueStoreProvider`를 Fake 구현으로 override하세요.
