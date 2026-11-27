# BRIEF: Ryzentosh-ACPI

**Scope:** ACPI tables for the ASUS ROG STRIX B650E-I, one SSDT per purpose (CPU objects, EC + USBX, sleep/wake sources, GPU power-down, Mac devices such as SBUS), with .dsl sources, iasl builds and per-table justification.

**Release artifact:** SSDT-*.aml files that Ryzentosh-EFI pulls into EFI/OC/ACPI.

**Depends on:** [Ryzentosh-EFI]

**Parity targets:** see the rows for this project in the control plane's COMPATIBILITY_MATRIX.md.

**Out of scope:** anything another Ryzentosh repo owns (see projects.yaml).
