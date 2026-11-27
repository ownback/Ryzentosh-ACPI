# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/). Release stages: research → alpha → beta → stable.

## [Unreleased]

## [0.1.0] - 2026-11-27 (research)
- Repository created from the Ryzentosh skeleton (2026-11-27).
- Import the two live SSDTs from Ryzentosh-EFI `main` @ 7bd8f7b, byte-identical to what boots: `SSDT-CPUR-B650EI` and `SSDT-EC-USBX-B650EI` (sources in `src/`, bytes in `aml/`) (#1).
- Reproducible build: iasl 20260930 pinned by the upstream tarball's sha256, `tools/ci.sh` and CI compare rebuild vs committed bytes, ignoring offsets 9 and 32–35 (#1).
- `tests/verify-negative.sh`: the verify step is itself tested against tampering (#1).
- One justification per table (`docs/Humans/`), the firmware evidence (`docs/LLMs/re/`) and a backlog of candidate tables (`docs/LLMs/BACKLOG.md`) (#1).
