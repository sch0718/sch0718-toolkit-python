# sch0718-toolkit-python

여러 서비스의 Python 백엔드가 함께 쓰는 패키지 모음입니다. PyPI 없이 **GitHub만** 씁니다. 패키지마다 태그로 버전을 내고, 각 서비스는 그 태그를 git 의존성으로 설치합니다. 태그마다 GitHub Release에 wheel·sdist도 붙습니다.

같은 이름 규칙의 다른 저장소:

- [`sch0718-toolkit-web`](https://github.com/sch0718/sch0718-toolkit-web) — 브라우저·Node용 TypeScript
- `sch0718-toolkit-python` — 백엔드 Python (이 저장소)
- 다른 언어가 생기면 `sch0718-toolkit-<언어>`로 추가합니다.

## 패키지

아직 없습니다. 지금 있는 서비스(랜드마크, 가즈아)에는 Python 백엔드가 없어서, 두 곳 이상에서 쓰는 Python 코드가 생길 때 첫 패키지를 만듭니다. 이 저장소는 그때 바로 쓸 수 있게 도구·시험·발행 설정을 갖춰 둔 뼈대입니다.

## 넣는 기준

1. **쓰는 곳이 두 곳 이상**이거나, 새 서비스에서 곧 쓸 것이 분명합니다.
2. **도구는 넣고 값은 서비스에 둡니다.** 접속 주소·키·한도 수치는 서비스가 주입합니다.
3. **서비스의 데이터 형식·스키마·인증 정책은 넣지 않습니다.**
4. **웹 프레임워크에 묶지 않습니다.** FastAPI·Django 같은 프레임워크 전용 코드가 꼭 필요하면 `sch0718-<이름>-fastapi`처럼 별도 패키지로 두고, 그 프레임워크를 쓰는 서비스가 두 곳 생길 때 만듭니다.
5. **비밀값 금지.** 공개 저장소·공개 패키지입니다.
6. **이미 잘 만든 것이 있으면 가져다 씁니다.** 별이 많고 업계에서 널리 쓰는 라이브러리가 같은 일을 하면 직접 만들지 않습니다.

## 쓰는 도구

직접 만들지 않고 널리 쓰는 도구를 골랐습니다. 별 수는 2026-10-27 GitHub 기준입니다.

| 용도 | 도구 | 별 |
| --- | --- | ---: |
| 패키지·가상환경·workspace·빌드 실행·git 의존성 설치 | [uv](https://github.com/astral-sh/uv) | 91.2k |
| 린트·포맷 | [Ruff](https://github.com/astral-sh/ruff) | 50.3k |
| 타입 검사 | [mypy](https://github.com/python/mypy) (strict) | 20.7k |
| 시험 | [pytest](https://github.com/pytest-dev/pytest) | 14.6k |
| 빌드 백엔드 | [Hatchling](https://github.com/pypa/hatch) (PyPA) | 7.2k |
| 릴리스 | GitHub Releases + [GitHub CLI](https://github.com/cli/cli) `gh release` | 46.8k |

- 지원 하한은 Python 3.12이고, CI는 3.12와 3.14에서 돕니다.
- 라이선스는 PEP 639 방식(`license = "PolyForm-Noncommercial-1.0.0"`, `license-files`)으로 메타데이터에 적습니다.

## 개발

uv 0.13 이상이 필요합니다(`pyproject.toml`의 `required-version`). CI도 같은 버전으로 lockfile을 검사합니다.

```bash
uv sync --all-packages
scripts/verify.sh   # 린트·포맷·타입·시험·빌드 (패키지가 없으면 린트·포맷만)
```

루트 `pyproject.toml`은 발행하지 않는 가상 workspace 루트입니다. 개발 도구 버전(`[dependency-groups] dev`)과 Ruff·mypy·pytest 설정을 모든 패키지가 함께 씁니다.

**서비스와 같이 고칠 때.** 서비스에서 `uv add --editable ../sch0718-toolkit-python/packages/<이름>`처럼 로컬 경로로 잠시 설치해 확인합니다. 이 변경은 커밋하지 않습니다.

## 새 패키지 추가

```bash
scripts/new-package.sh http-utils "HTTP 요청 재시도·시간 제한 도우미"
uv sync --all-packages
scripts/verify.sh
```

- 배포 이름은 `sch0718-<이름>`, import 이름은 `sch0718_<이름>`(하이픈은 밑줄)입니다. 템플릿은 [`templates/package`](templates/package)에 있습니다.
- 패키지 폴더에 저장소 LICENSE 사본이 들어갑니다. 배포물(wheel·sdist)에 라이선스를 넣기 위해서입니다.

## 서비스에서 설치하기

GitHub Packages는 Python(PyPI) 레지스트리를 지원하지 않습니다(지원 목록: npm, RubyGems, Maven·Gradle, NuGet, 컨테이너. [Introduction to GitHub Packages](https://docs.github.com/en/packages/learn-github-packages/introduction-to-github-packages), 2026-10-27 확인). 그래서 **git 의존성**으로 설치합니다. 공개 저장소라 토큰이 필요 없습니다.

```bash
uv add "sch0718-http-utils @ git+https://github.com/sch0718/sch0718-toolkit-python@http-utils-v0.1.0#subdirectory=packages/http-utils"
```

- `@<태그>`로 버전을 고정하고, `#subdirectory=`로 저장소 안의 패키지 폴더를 가리킵니다. uv는 lockfile(`uv.lock`)에 그 태그의 커밋 SHA까지 적습니다.
- pip·`requirements.txt`도 같은 형식입니다: `sch0718-http-utils @ git+https://github.com/sch0718/sch0718-toolkit-python@http-utils-v0.1.0#subdirectory=packages/http-utils`
- 버전을 올릴 때는 태그 부분만 바꿉니다. 각 태그의 변경 내용은 [Releases](https://github.com/sch0718/sch0718-toolkit-python/releases)에 있습니다.
- git을 쓸 수 없는 빌드 환경이면 Release에 붙은 wheel URL로 설치할 수 있습니다: `uv add https://github.com/sch0718/sch0718-toolkit-python/releases/download/<태그>/<wheel 파일 이름>`

## 릴리스

1. 패키지의 `pyproject.toml` `version`을 올리는 PR을 병합합니다. 예: `uv version --package sch0718-http-utils --bump minor`
2. main에서 태그 `<패키지 폴더 이름>-v<버전>`을 push합니다.

   ```bash
   git tag http-utils-v0.2.0 && git push origin http-utils-v0.2.0
   ```

3. [릴리스 워크플로](.github/workflows/release.yml)가 다음을 차례로 합니다.
   - 태그 커밋이 main에 병합된 것인지, 태그와 `pyproject.toml` 버전이 같은지 확인합니다.
   - 검사를 거쳐 그 패키지 하나만 빌드합니다.
   - GitHub Release를 만들고 wheel·sdist를 붙입니다.
   - 서비스와 같은 방법(git 의존성)으로 그 태그를 설치해 import되는지 확인합니다.

서비스가 태그를 직접 가리키므로 **이미 낸 태그는 옮기거나 지우지 않습니다.** 저장소 Rulesets(`release-tags`)가 `*-v*` 태그의 생성·이동·삭제를 저장소 관리자만 하게 막습니다. 문제가 있으면 고친 버전을 새 태그로 냅니다.

## 라이선스

[PolyForm Noncommercial 1.0.0](LICENSE). 랜드마크·가즈아와 같습니다. OSI가 인정하는 오픈소스 라이선스는 아닙니다.

- 개인 용도로 쓰고, 코드를 읽고 고쳐 보는 것은 자유롭게 할 수 있습니다. 상업적 이용은 별도로 문의해 주세요([GitHub 이슈](https://github.com/sch0718/sch0718-toolkit-python/issues)).
- 재배포할 때는 [LICENSE](LICENSE)의 `Required Notice:` 줄을 함께 전달해야 합니다.
- 이 저장소에 기여하면 그 기여를 같은 라이선스 조건으로 제공하는 데 동의한 것으로 봅니다.
