# STATE: Ryzentosh-ACPI

Updated: 2026-11-27 by the Project Lead for issue #1 (claude-sonnet-5-5 / high).

## Phase
Research. First release `v0.1.0` published (pre-release).

## Done
- Issue #1 closed: #2 squash-merged (3a32487), release [v0.1.0](https://github.com/ownback/Ryzentosh-ACPI/releases/tag/v0.1.0) with `SSDT-CPUR-B650EI.aml`, `SSDT-EC-USBX-B650EI.aml` and `SHA256SUMS`.
- `.aml` sha256 identical to Ryzentosh-EFI `main`, the USB known-good and the live internal ESP (Orchestrator, 2026-11-27): CPUR `da5bf6ea…2db4`, EC-USBX `f651e3f7…2d96`.
- Reproducible build (iasl 20260930, sha256-pinned tarball), CI rebuild-vs-committed check plus tamper tests, per-table justification, firmware evidence (BIOS 4005), backlog of candidate tables (`docs/LLMs/BACKLOG.md`, none written).
- Owner/Orchestrator decision: EC hide + `EC` + `USBX` stay in one table.

## In flight
Nothing.

## Next step
- Orchestrator: Ryzentosh-EFI PR that switches its provenance to this repo (release `v0.1.0`).
- Follow-up issues: #3 `PblkAddress 0x810` origin, #4 consumer of the fake `EC`, #5 Linux check of the Darwin-only gate (bridge task, Orchestrator schedules).
- New tables only with evidence (BACKLOG.md): sleep/wake `_PRW`, dGPU power-down (after ADR-0005), Mac devices (SBUS).

## Blockers
None.
