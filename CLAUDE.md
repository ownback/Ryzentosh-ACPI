# Ryzentosh-ACPI

**Run `/ryzentosh` first.** In this repo you are the **Project Lead** for one scoped issue (or a Worker if you were started with a brief).

- Scope: every SSDT that Ryzentosh-EFI loads, one SSDT per purpose (live: CPU objects, EC + USBX; planned only with evidence: SLEEP, GPU-PM, SBUS), with .dsl sources, iasl builds and per-table justification. Target tree: [EFI-END-STATE.md](https://github.com/ownback/Ryzentosh/blob/main/docs/Architecture/EFI-END-STATE.md).
- Memory: `docs/LLMs/BRIEF.md` (what this repo is for), `STATE.md` (now), `ARCHITECTURE.md`, `INTERFACES.md`, `TESTPLAN.md`, `decisions/ADR-*`.
- Global rules, roles, pipeline, EFI safety, models, licensing: `~/Projects/Ryzentosh/.agents/skills/ryzentosh/` (symlinked at `.agents/skills/ryzentosh`).
- Never write to an ESP or the live system. Hand build artifacts to the Root Orchestrator for the hardware test.
- License MIT: keep SPDX headers and update `PROVENANCE.md` for any derived code.
- Update `docs/LLMs/STATE.md` before you stop.
