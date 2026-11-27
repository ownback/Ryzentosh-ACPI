#!/bin/bash
# SPDX-License-Identifier: MIT
# Check that every committed aml/*.aml is what src/*.dsl compiles to, ignoring the two header fields a rebuild changes:
# the checksum (offset 9) and the compiler revision (offsets 32-35). Any other differing byte, or a size
# difference, fails. Also checks aml/SHA256SUMS. Run tools/build.sh first (tools/ci.sh does both).
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
fail=0
(cd aml && shasum -a 256 -c SHA256SUMS) || fail=1
for dsl in src/*.dsl; do
  n=$(basename "${dsl%.dsl}")
  live=aml/$n.aml; built=build/out/$n.aml
  [ -f "$live" ] && [ -f "$built" ] || { echo "FAIL $n: missing $live or $built"; fail=1; continue; }
  if [ "$(wc -c <"$live")" != "$(wc -c <"$built")" ]; then echo "FAIL $n: size differs"; fail=1; continue; fi
  # cmp -l prints 1-based offsets; the allowed ones are 0-based 9 and 32..35.
  bad=$( { cmp -l "$live" "$built" || true; } | awk '{o=$1-1} !(o==9 || (o>=32 && o<=35)) {print o}' | tr '\n' ' ')
  if [ -n "$bad" ]; then echo "FAIL $n: differing offsets outside 9, 32-35: $bad"; fail=1
  else echo "ok   $n ($(wc -c <"$live" | tr -d ' ') bytes; live $(shasum -a 256 "$live" | cut -c1-12)…, rebuilt $(shasum -a 256 "$built" | cut -c1-12)…)"; fi
done
exit $fail
