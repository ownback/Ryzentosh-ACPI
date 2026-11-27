#!/bin/bash
# SPDX-License-Identifier: MIT
# Compile src/*.dsl with the pinned iasl into build/out/*.aml.
# iasl: $IASL, else build/iasl/bin/iasl (tools/install-iasl.sh), else the first iasl on PATH. Must be 20260930.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
iasl=${IASL:-}
[ -n "$iasl" ] || { [ -x "$root/build/iasl/bin/iasl" ] && iasl="$root/build/iasl/bin/iasl"; } || true
[ -n "$iasl" ] || iasl=$(command -v iasl || true)
[ -n "$iasl" ] || { echo "no iasl: run tools/install-iasl.sh or install MacPorts acpica @20260930" >&2; exit 1; }
"$iasl" -v 2>&1 | grep -q "version 20260930" || { echo "need iasl 20260930, found: $("$iasl" -v 2>&1 | grep version)" >&2; exit 1; }

out="$root/build/out"
rm -rf "$out"; mkdir -p "$out"
for dsl in "$root"/src/*.dsl; do
  "$iasl" -p "$out/$(basename "${dsl%.dsl}")" "$dsl" >"$out/$(basename "${dsl%.dsl}").log" 2>&1 \
    || { cat "$out/$(basename "${dsl%.dsl}").log" >&2; exit 1; }
done
echo "built: $(ls "$out"/*.aml | wc -l | tr -d ' ') tables in $out (iasl $iasl)"
