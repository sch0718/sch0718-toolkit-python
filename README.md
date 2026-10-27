# sch0718-toolkit-python

여러 서비스의 Python 백엔드가 함께 쓰는 패키지 모음입니다. 패키지마다 PyPI에 따로 발행하고, 각 서비스는 정확한 버전을 골라 설치합니다.

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
| 패키지·가상환경·workspace·빌드 실행·발행 | [uv](https://github.com/astral-sh/uv) | 91.2k |
| 린트·포맷 | [Ruff](https://github.com/astral-sh/ruff) | 50.3k |
| 타입 검사 | [mypy](https://github.com/python/mypy) (strict) | 20.7k |
| 시험 | [pytest](https://github.com/pytest-dev/pytest) | 14.6k |
| 빌드 백엔드 | [Hatchling](https://github.com/pypa/hatch) (PyPA) | 7.2k |
| PyPI 발행 | [pypa/gh-action-pypi-publish](https://github.com/pypa/gh-action-pypi-publish) (PyPA 공식) | 1.2k |

- 지원 하한은 Python 3.12이고, CI는 3.12와 3.14에서 돕니다.
- 라이선스는 PEP 639 방식(`license = "PolyForm-Noncommercial-1.0.0"`, `license-files`)으로 메타데이터에 적습니다.

## 개발

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

## 릴리스

1. 패키지의 `pyproject.toml` `version`을 올리는 PR을 병합합니다. 예: `uv version --package sch0718-http-utils --bump minor`
2. main에서 태그 `<패키지 폴더 이름>-v<버전>`을 push합니다.

   ```bash
   git tag http-utils-v0.2.0 && git push origin http-utils-v0.2.0
   ```

3. [발행 워크플로](.github/workflows/publish.yml)가 태그와 `pyproject.toml` 버전을 대조합니다. 다음으로 검사·빌드를 거쳐 PyPI **trusted publishing**(OIDC)으로 발행합니다. PyPI 토큰은 저장소에 두지 않습니다.

이미 발행한 버전은 덮어쓸 수 없습니다. 문제가 있으면 고친 버전을 새로 내고 PyPI에서 그 버전을 yank합니다.

### 패키지별 첫 설정 (저장소 소유자가 직접)

PyPI는 프로젝트가 생기기 전에 "pending publisher"를 등록해 두면 첫 발행 때 프로젝트를 만듭니다. 다만 등록만으로 이름이 예약되지는 않습니다.

1. PyPI 계정과 2FA를 준비합니다.
2. PyPI 계정 메뉴 → Publishing에서 pending publisher를 추가합니다. 값은 PyPI 프로젝트 이름 `sch0718-<이름>`, 소유자 `sch0718`, 저장소 `sch0718-toolkit-python`, 워크플로 `publish.yml`, 환경 `pypi`입니다.
3. GitHub 저장소 Settings → Environments에 `pypi` 환경을 만듭니다. 태그 규칙이나 승인자를 걸어 두면 실수로 발행하는 것을 막을 수 있습니다.
4. 위 「릴리스」대로 태그를 push합니다.

출처: [Creating a PyPI project with a Trusted Publisher](https://docs.pypi.org/trusted-publishers/creating-a-project-through-oidc/) (2026-10-27 확인)

## 라이선스

[PolyForm Noncommercial 1.0.0](LICENSE). 랜드마크·가즈아와 같습니다. OSI가 인정하는 오픈소스 라이선스는 아닙니다.

- 개인 용도로 쓰고, 코드를 읽고 고쳐 보는 것은 자유롭게 할 수 있습니다. 상업적 이용은 별도로 문의해 주세요([GitHub 이슈](https://github.com/sch0718/sch0718-toolkit-python/issues)).
- 재배포할 때는 [LICENSE](LICENSE)의 `Required Notice:` 줄을 함께 전달해야 합니다.
- 이 저장소에 기여하면 그 기여를 같은 라이선스 조건으로 제공하는 데 동의한 것으로 봅니다.
