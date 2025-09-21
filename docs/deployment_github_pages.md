# GitHub Pages 배포 가이드

이 프로젝트는 Flutter Web 빌드 산출물을 GitHub Pages에 올려 배포할 수 있도록 준비되었습니다. 아래 순서대로 설정하면 자동으로 `gh-pages` 브랜치에 웹 정적 파일을 배포합니다.

## 사전 준비

1. GitHub 저장소 **Settings → Pages**에서 빌드 소스를 `Deploy from a branch`로, 브랜치를 `gh-pages`, 폴더를 `/`로 설정합니다.
2. 기본 브랜치가 `main`이라고 가정합니다. 다른 브랜치를 쓰고 있다면 워크플로우 트리거를 수정하세요.

## 수동 배포 (옵션)

```bash
flutter pub get
flutter build web \
  --release \
  --web-renderer canvaskit \
  --base-href /<your-repo-name>/

# gh-pages 브랜치에 산출물을 올리고 싶다면
cd build/web
# 파일을 gh-pages 브랜치에 커밋/푸시하거나, GitHub Pages 설정에서 build/web을 사용하세요.
```

- `--base-href` 값은 Pages에서 제공하는 경로(`/username.github.io/<your-repo-name>/`)에 맞춰 `/프로젝트이름/`으로 변경해야 자산이 올바르게 로드됩니다.
- `HashUrlStrategy`가 적용되어 있어, GitHub Pages에서도 라우팅이 404 없이 동작합니다.

## GitHub Actions 자동 배포

`.github/workflows/deploy-web.yml` 워크플로우는 다음과 같이 동작합니다.

1. `main` 브랜치에 푸시되거나 `workflow_dispatch`로 수동 실행하면 시작됩니다.
2. Flutter SDK(안정 채널)를 설치한 뒤 `flutter pub get`을 실행합니다.
3. `flutter build web --release --base-href /<repo>/ --web-renderer canvaskit`으로 웹 번들을 생성합니다.
4. [`peaceiris/actions-gh-pages`](https://github.com/peaceiris/actions-gh-pages)가 `build/web` 폴더를 `gh-pages` 브랜치로 배포합니다.

필요 시 워크플로우 파일에서 브랜치, 빌드 옵션, 렌더러 등을 조정하세요.
