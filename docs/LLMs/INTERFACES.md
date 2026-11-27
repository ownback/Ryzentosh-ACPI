# INTERFACES: Ryzentosh-ACPI

External contracts: IOKit classes and properties, user-client selectors, plist keys, files installed, interfaces consumed from other Ryzentosh repos.

## Files published (release assets)

| File | Installed by | Where |
|---|---|---|
| `SSDT-CPUR-B650EI.aml` | Ryzentosh-EFI | `EFI/OC/ACPI/`, listed in `config.plist` `ACPI/Add` |
| `SSDT-EC-USBX-B650EI.aml` | Ryzentosh-EFI | `EFI/OC/ACPI/`, listed in `config.plist` `ACPI/Add` |

Each release carries `SHA256SUMS`. Ryzentosh-EFI pins those hashes (`EFI/BINARIES.sha256` / KEXTS.md) and switches its provenance to this repo in its own PR.

## ACPI namespace contract (what other components may rely on, macOS only)

| Object | Provided by | Consumer |
|---|---|---|
| `\_SB.PR00`..`PR17` `Processor ()`, ProcessorId = MADT IDs | SSDT-CPUR | `AppleACPIPlatform` / `AppleACPICPU` |
| `\_SB.PCI0.SBRG.EC` (`ACID0001`), `EC0` hidden | SSDT-EC-USBX | macOS EC lookup (Dortania: `AppleBusPowerController`; consumer unconfirmed); `AppleACPIEC` (matches `PNP0C09`) must not bind `EC0` |
| `\_SB.USBX` `_DSM` (5100 / 2100 mA) | SSDT-EC-USBX | `AppleUSBHost*` |

Expected under any other OS (untested): none of these objects is visible and `EC0` keeps its default status.

## Consumed

The firmware's `\_SB.PCI0.SBRG`, `\_SB.PCI0.SBRG.EC0` (declared `External`), the MADT's enabled processor list. A BIOS change that renames these invalidates the tables.
