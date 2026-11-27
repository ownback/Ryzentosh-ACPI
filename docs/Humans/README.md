# Ryzentosh-ACPI for humans

ACPI tables (SSDTs) for the ASUS ROG STRIX B650E-I, one per purpose. OpenCore loads them from `EFI/OC/ACPI`; they are macOS-only (`_OSI ("Darwin")`), so Windows and Linux on the same machine see the firmware's tables unchanged.

| Table | Purpose | Justification |
|---|---|---|
| `SSDT-CPUR-B650EI` | 24 legacy `Processor ()` objects (the firmware has only `ACPI0007` devices; macOS stalls without them) | [SSDT-CPUR-B650EI.md](SSDT-CPUR-B650EI.md) |
| `SSDT-EC-USBX-B650EI` | Hide the real ASUS EC from macOS, add the `EC` device macOS expects, USB port power | [SSDT-EC-USBX-B650EI.md](SSDT-EC-USBX-B650EI.md) |

- Build and verify: [BUILD.md](BUILD.md).
- Install: don't copy files by hand. Ryzentosh-EFI carries the tables and is staged and boot-tested by the Orchestrator. These tables only match this board, BIOS 4005 and a 24-thread CPU.
- Remove: delete the entry from `ACPI/Add` and the file. Without the CPU table macOS stalls at boot.
- Known issues: `PblkAddress 0x810` origin unrecorded (open item in the CPUR page); the Linux side of the Darwin gate is untested.
- Candidates for more tables (none are written, each needs evidence first): [../LLMs/BACKLOG.md](../LLMs/BACKLOG.md).
