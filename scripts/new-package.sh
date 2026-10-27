#!/usr/bin/env bash
# 새 패키지를 templates/package에서 만든다.
# 사용: scripts/new-package.sh <이름> "<한 줄 설명>"
#   이름은 소문자·숫자·하이픈. 배포 이름은 sch0718-<이름>, import 이름은 sch0718_<이름(하이픈→밑줄)>.
set -euo pipefail
name="${1:?이름을 주세요(예: http-utils)}"
desc="${2:?한 줄 설명을 주세요}"
[[ "$name" =~ ^[a-z][a-z0-9-]*$ ]] || { echo "이름은 소문자로 시작하는 소문자·숫자·하이픈이어야 합니다: $name" >&2; exit 1; }
module="${name//-/_}"
root="$(cd "$(dirname "$0")/.." && pwd)"
dest="$root/packages/$name"
[[ -e "$dest" ]] && { echo "이미 있습니다: $dest" >&2; exit 1; }
cp -R "$root/templates/package" "$dest"
mv "$dest/src/sch0718___NAME__" "$dest/src/sch0718_$module"
mv "$dest/tests/test___NAME__.py" "$dest/tests/test_$module.py"
# 설명에 sed 특수 문자가 있어도 깨지지 않게 Python으로 치환한다.
python3 - "$dest" "$name" "$module" "$desc" <<'PY'
import pathlib, sys
dest, dist, module, desc = sys.argv[1:]
for path in pathlib.Path(dest).rglob("*"):
    if path.is_file() and path.suffix in {".toml", ".md", ".py"}:
        text = path.read_text(encoding="utf-8")
        text = text.replace("__DIST__", dist).replace("__NAME__", module).replace("__DESCRIPTION__", desc)
        path.write_text(text, encoding="utf-8")
PY
cp "$root/LICENSE" "$dest/LICENSE"
echo "만들었습니다: packages/$name (import sch0718_$module)"
echo "다음: uv sync --all-packages && scripts/verify.sh"
