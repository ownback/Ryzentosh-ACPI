#!/bin/bash
# SPDX-License-Identifier: MIT
# tools/verify.sh must pass on the repo as it is (after tools/build.sh) and FAIL on each kind of tampering below.
set -uo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
t=CPUR; n=SSDT-CPUR-B650EI
rc=0
fresh() { rm -rf "$tmp/r"; mkdir -p "$tmp/r"; cp -R "$root/src" "$root/aml" "$root/build" "$tmp/r/"; }
resum() { (cd "$tmp/r/aml" && shasum -a 256 *.aml > SHA256SUMS); }
poke() { printf "$2" | dd of="$tmp/r/aml/$n.aml" bs=1 seek="$1" conv=notrunc 2>/dev/null; }
expect() { # name, expected (pass|fail)
  VERIFY_ROOT="$tmp/r" "$root/tools/verify.sh" >/dev/null 2>&1; got=$?
  if { [ "$2" = pass ] && [ $got = 0 ]; } || { [ "$2" = fail ] && [ $got != 0 ]; }; then echo "ok   verify-negative: $1 ($2)"
  else echo "FAIL verify-negative: $1 expected $2, rc=$got"; rc=1; fi
}
fresh; expect "untouched repo" pass
fresh; poke 100 '\x01'; resum; expect "flipped byte 100, sums regenerated" fail
fresh; poke 8 '\x07'; resum; expect "flipped revision byte 8" fail
fresh; poke 10 '\x07'; resum; expect "flipped OEM ID byte 10" fail
fresh; poke 100 '\x01'; expect "flipped byte 100, stale SHA256SUMS" fail
fresh; printf '\x00' >> "$tmp/r/aml/$n.aml"; resum; expect "appended byte" fail
fresh; cp "$tmp/r/aml/$n.aml" "$tmp/r/aml/SSDT-ORPHAN.aml"; resum; expect "orphan aml without source" fail
fresh; poke 9 "$(printf '\\x%02x' $(( ( $(od -An -tu1 -j9 -N1 "$tmp/r/aml/$n.aml") + 1 ) % 256 )))"; resum; expect "edited checksum byte 9 (checksum no longer valid)" fail
exit $rc
