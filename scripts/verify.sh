#!/usr/bin/env bash
# 린트·포맷·타입·시험·빌드. CI와 같은 순서다.
set -euo pipefail
cd "$(dirname "$0")/.."
uv sync --all-packages
uv run ruff check .
uv run ruff format --check .
shopt -s nullglob
packages=(packages/*/pyproject.toml)
if (( ${#packages[@]} == 0 )); then
  echo "packages/에 패키지가 없어 타입 검사·시험·빌드를 건너뜁니다."
  exit 0
fi
uv run mypy packages
uv run pytest
# 빌드만 확인한다. 발행용 dist/와 섞이지 않게 임시 폴더에 만들고 지운다.
out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT
uv build --all-packages --out-dir "$out"
