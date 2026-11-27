# ARCHITECTURE: Ryzentosh-ACPI

Maintained by repo-cartographer. Updated 2026-11-27 (issue #1).

## Components

| Path | What |
|---|---|
| `src/*.dsl` | One ASL source per SSDT, one SSDT per purpose. Header: SPDX + what the firmware lacks + the macOS consumer |
| `aml/*.aml` | The committed bytes that are installed on the machine (`aml/SHA256SUMS`). Never regenerated casually: see `docs/Humans/BUILD.md` |
| `tools/install-iasl.sh` | Builds the pinned iasl 20260930 from the sha256-checked upstream tarball into `build/iasl/` |
| `tools/build.sh` | `src/*.dsl` → `build/out/*.aml` with the pinned iasl (refuses other versions) |
| `tools/verify.sh` | `aml/` vs `build/out/`: sizes equal, only bytes 9 and 32–35 may differ; `src/`, `aml/` and `SHA256SUMS` list the same tables; each committed table's ACPI checksum is valid |
| `tests/verify-negative.sh` | Proves `verify.sh` fails on tampering (flipped bytes, stale sums, appended byte, orphan `.aml`, bad checksum); run by `tools/ci.sh` |
| `tools/ci.sh` | `install-iasl` → `build` → `verify` → `tests/verify-negative.sh`; run by `.github/workflows/ci.yml` (macos-15, iasl cached) |
| `LICENSES/MIT-Vermilion.txt` | License text referenced by the table headers |
| `docs/Humans/SSDT-*.md` | One justification per table |
| `docs/LLMs/re/firmware-tables-bios4005.md` | Firmware evidence (findings only, no table dumps) |
| `docs/LLMs/BACKLOG.md` | Candidate tables and the evidence each would need |

## Entry points

`tools/ci.sh` (CI and local). Release: the `aml/*.aml` files and their sha256 (`v0.1.0`).

## Build targets

Two tables: `SSDT-CPUR-B650EI` (24 `Processor ()` objects) and `SSDT-EC-USBX-B650EI` (EC0 hidden, fake `EC`, `USBX`). Both Darwin-only via `_OSI ("Darwin")`.
