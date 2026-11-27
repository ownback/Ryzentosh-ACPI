#!/bin/bash
# SPDX-License-Identifier: MIT
# CI entry point (.github/workflows/ci.yml runs it): get the pinned iasl, rebuild the tables, compare with aml/,
# then prove that the comparison itself still catches tampering.
# Set IASL=/path/to/iasl (must be 20260930) to skip the source build, e.g. the MacPorts one.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "${IASL:-}" ]; then
  IASL=$("$root/tools/install-iasl.sh")   # assigned first so a failure stops the script
  export IASL
fi
"$root/tools/build.sh"
"$root/tools/verify.sh"
"$root/tests/verify-negative.sh"
