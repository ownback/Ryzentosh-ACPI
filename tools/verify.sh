#!/bin/bash
# SPDX-License-Identifier: MIT
# Check that every committed aml/*.aml is what src/*.dsl compiles to, ignoring the two header fields a rebuild changes:
# the checksum (offset 9) and the compiler revision (offsets 32-35). Any other differing byte, or a size
# difference, fails. Also: aml/, src/ and aml/SHA256SUMS must list the same tables, SHA256SUMS must match, and each
# committed table's bytes must sum to 0 mod 256 (a valid ACPI checksum, so offset 9 can't be edited unnoticed).
# Run tools/build.sh first (tools/ci.sh does both). VERIFY_ROOT overrides the repo root (used by the tests).
set -euo pipefail
root=${VERIFY_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
cd "$root"
fail=0

names() { for f in "$@"; do b=$(basename "$f"); echo "${b%.*}"; done | sort; }
src_set=$(names src/*.dsl); aml_set=$(names aml/*.aml)
sums_set=$(awk '{print $2}' aml/SHA256SUMS | sed 's/\.aml$//' | sort)
if [ "$src_set" != "$aml_set" ] || [ "$src_set" != "$sums_set" ]; then
  echo "FAIL table sets differ: src=[$(echo $src_set)] aml=[$(echo $aml_set)] SHA256SUMS=[$(echo $sums_set)]"; fail=1
fi
(cd aml && shasum -a 256 -c SHA256SUMS) || fail=1

for dsl in src/*.dsl; do
  n=$(basename "${dsl%.dsl}")
  live=aml/$n.aml; built=build/out/$n.aml
  [ -f "$live" ] && [ -f "$built" ] || { echo "FAIL $n: missing $live or $built"; fail=1; continue; }
  if [ "$(wc -c <"$live")" != "$(wc -c <"$built")" ]; then echo "FAIL $n: size differs"; fail=1; continue; fi
  sum=$(od -An -v -tu1 "$live" | awk '{for(i=1;i<=NF;i++) s+=$i} END{print s%256}')
  [ "$sum" = 0 ] || { echo "FAIL $n: ACPI checksum of $live is not valid (bytes sum to $sum mod 256)"; fail=1; }
  # cmp -l prints 1-based offsets; the allowed ones are 0-based 9 and 32..35.
  bad=$( { cmp -l "$live" "$built" || true; } | awk '{o=$1-1} !(o==9 || (o>=32 && o<=35)) {print o}' | tr '\n' ' ')
  if [ -n "$bad" ]; then echo "FAIL $n: differing offsets outside 9, 32-35: $bad"; fail=1
  else echo "ok   $n ($(wc -c <"$live" | tr -d ' ') bytes; live $(shasum -a 256 "$live" | cut -c1-12)…, rebuilt $(shasum -a 256 "$built" | cut -c1-12)…)"; fi
done
exit $fail
