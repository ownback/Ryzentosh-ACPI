#!/bin/bash
# SPDX-License-Identifier: MIT
# Build the pinned iasl (ACPICA 20260930) from the upstream source tarball into build/iasl/.
# Needs: curl, make, a C compiler, GNU bison (>= 3), flex and GNU m4 (gm4 on macOS).
# MacPorts users can instead `sudo port install acpica @20260930` (same source, same sha256).
set -euo pipefail
VERSION=20260930
SHA256=feddab0f42f1e01afa3b8ec04f3aaef5e61e891225b8dc8776953ca9f3df1449
URL="https://github.com/acpica/acpica/archive/refs/tags/${VERSION}.tar.gz"

root=$(cd "$(dirname "$0")/.." && pwd)
dest="$root/build/iasl"
if [ -x "$dest/bin/iasl" ] && "$dest/bin/iasl" -v 2>&1 | grep -q "version $VERSION"; then
  echo "$dest/bin/iasl"; exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fsSL -o "$work/acpica.tar.gz" "$URL"
echo "$SHA256  $work/acpica.tar.gz" | shasum -a 256 -c - >&2
tar -xzf "$work/acpica.tar.gz" -C "$work"
src=$(echo "$work"/acpica-*)

m4=$(command -v gm4 || command -v m4)
# Apple Silicon needs this (https://github.com/acpica/acpica/issues/781); MacPorts does the same.
cflags=""
[ "$(uname -s)" = Darwin ] && [ "$(uname -m)" = arm64 ] && cflags="-DACPI_PACKED_POINTERS_NOT_SUPPORTED"
make -C "$src/generate/unix" iasl MACROPROC="$m4" OPT_CFLAGS="$cflags" >&2

mkdir -p "$dest/bin"
cp "$src/generate/unix/bin/iasl" "$dest/bin/iasl"
"$dest/bin/iasl" -v 2>&1 | grep -q "version $VERSION" || { echo "built iasl is not $VERSION" >&2; exit 1; }
echo "$dest/bin/iasl"
