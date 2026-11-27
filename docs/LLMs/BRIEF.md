# BRIEF: Ryzentosh-ACPI

**Scope:** every SSDT that Ryzentosh-EFI loads, for the ASUS ROG STRIX B650E-I, one SSDT per purpose, with .dsl sources, iasl builds and per-table justification. Live: `SSDT-CPUR-B650EI`, `SSDT-EC-USBX-B650EI`. Planned (provisional names, each only with evidence that macOS needs it): `SSDT-SLEEP-B650EI` (wake sources), `SSDT-GPU-PM-B650EI` (dGPU power-down, ADR-0005 option B), `SSDT-SBUS-B650EI` (only if a consumer needs it); see `BACKLOG.md`. The target EFI tree: [EFI-END-STATE.md](https://github.com/ownback/Ryzentosh/blob/main/docs/Architecture/EFI-END-STATE.md).

**Release artifact:** SSDT-*.aml files that Ryzentosh-EFI pulls into EFI/OC/ACPI.

**Depends on:** [Ryzentosh-EFI]

**Parity targets:** see the rows for this project in the control plane's COMPATIBILITY_MATRIX.md.

**Out of scope:** anything another Ryzentosh repo owns (see projects.yaml). One repo ships one kext (CPU, PLATFORM, WIRELESS, GPU = dGPU + iGPU); kext code never lives here.
