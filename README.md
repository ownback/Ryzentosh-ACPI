# Ryzentosh-ACPI

ACPI tables for the ASUS ROG STRIX B650E-I, one SSDT per purpose (CPU objects, EC + USBX, sleep/wake sources, GPU power-down, Mac devices such as SBUS), with .dsl sources, iasl builds and per-table justification.

Part of [Ryzentosh](https://github.com/ownback/Ryzentosh): macOS Tahoe on an AMD PC, built to behave like a Mac Apple designed and
supports. Written by AI agents. Apple is not involved in this project.

**Status:** research. Two tables are imported from the live EFI (`SSDT-CPUR-B650EI`, `SSDT-EC-USBX-B650EI`); CI proves the sources rebuild to the committed bytes. See [docs/Humans](docs/Humans/) and the
[compatibility matrix](https://github.com/ownback/Ryzentosh/blob/main/docs/Hardware/COMPATIBILITY_MATRIX.md).

**Releases:** SSDT-*.aml files that Ryzentosh-EFI pulls into EFI/OC/ACPI.

**Build:** `tools/ci.sh` (pinned iasl 20260930, see [docs/Humans/BUILD.md](docs/Humans/BUILD.md)).

## Reference hardware
AMD Ryzen 9 7900X3D · Radeon RX 7900 XTX (XFX) · ASUS ROG STRIX B650E-I · macOS 26.7.1 (25G241) · OpenCore 1.0.8.

## Contributing
See [CONTRIBUTING.md](https://github.com/ownback/Ryzentosh/blob/main/CONTRIBUTING.md). AI agents: read [AGENTS.md](AGENTS.md).

License: MIT. Third-party code and its origins are listed in [PROVENANCE.md](PROVENANCE.md).
