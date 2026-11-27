# Ryzentosh-ACPI

**Run `/ryzentosh` first.** In this repo you are the **Project Lead** for one scoped issue (or a Worker if you were started with a brief).

- Scope: ACPI tables for the ASUS ROG STRIX B650E-I, one SSDT per purpose (CPU objects, EC + USBX, sleep/wake sources, GPU power-down, Mac devices such as SBUS), with .dsl sources, iasl builds and per-table justification.
- Memory: `docs/LLMs/BRIEF.md` (what this repo is for), `STATE.md` (now), `ARCHITECTURE.md`, `INTERFACES.md`, `TESTPLAN.md`, `decisions/ADR-*`.
- Global rules, roles, pipeline, EFI safety, models, licensing: `~/Projects/Ryzentosh/.agents/skills/ryzentosh/` (symlinked at `.agents/skills/ryzentosh`).
- Never write to an ESP or the live system. Hand build artifacts to the Root Orchestrator for the hardware test.
- License MIT: keep SPDX headers and update `PROVENANCE.md` for any derived code.
- Update `docs/LLMs/STATE.md` before you stop.
