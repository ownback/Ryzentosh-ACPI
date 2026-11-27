# Provenance

Every file derived from third-party code gets one row. Study-only sources (Vermilion, NullMoth, nullarc, GPL amdgpu logic in non-GPL repos) are never copied.

| File | Source repo @ commit | Source path | License | What changed |
|---|---|---|---|---|
| `src/SSDT-CPUR-B650EI.dsl`, `aml/SSDT-CPUR-B650EI.aml` | ownback/Ryzentosh-EFI @ 7bd8f7b (`main`), which took it from ownback/vermilion-xtx @ 7b30f2b | `acpi/SSDT-CPUR-B650EI.dsl`, `EFI/OC/ACPI/SSDT-CPUR-B650EI.aml` (the `.aml` = the live table) | MIT (per-file SPDX; Vermilion's LICENSE table doesn't list `efi/`), Copyright (c) 2026 Vermilion contributors; text in `LICENSES/MIT-Vermilion.txt` | None: both files are byte-identical to the source |
| `src/SSDT-EC-USBX-B650EI.dsl`, `aml/SSDT-EC-USBX-B650EI.aml` | ownback/Ryzentosh-EFI @ 7bd8f7b (`main`), which took it from ownback/vermilion-xtx @ 7b30f2b | `acpi/SSDT-EC-USBX-B650EI.dsl`, `EFI/OC/ACPI/SSDT-EC-USBX-B650EI.aml` (the `.aml` = the live table) | MIT (per-file SPDX; Vermilion's LICENSE table doesn't list `efi/`), Copyright (c) 2026 Vermilion contributors; text in `LICENSES/MIT-Vermilion.txt` | None: both files are byte-identical to the source |
| `LICENSES/MIT-Vermilion.txt` | ownback/Ryzentosh-EFI @ 7bd8f7b | `LICENSES/MIT-Vermilion.txt` | MIT, Copyright (c) 2026 Vermilion contributors | None |
| `tools/install-iasl.sh` (builds, does not include) | ACPICA 20260930 tarball, sha256 `feddab0f…df1449` | n/a | ACPICA is dual-licensed (Intel/GPLv2/BSD); the compiler is built locally in CI and **not redistributed**. The SSDTs' own source is MIT | n/a |
