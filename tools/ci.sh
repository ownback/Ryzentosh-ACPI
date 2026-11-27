#!/bin/bash
# SPDX-License-Identifier: MIT
# CI entry point (.github/workflows/ci.yml runs it): get the pinned iasl, rebuild the tables, compare with aml/.
# Set IASL=/path/to/iasl (must be 20260930) to skip the source build, e.g. the MacPorts one.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
[ -n "${IASL:-}" ] || export IASL=$("$root/tools/install-iasl.sh")
"$root/tools/build.sh"
"$root/tools/verify.sh"
