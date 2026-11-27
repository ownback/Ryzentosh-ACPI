# SSDT-CPUR-B650EI

Legacy `Processor ()` objects for the 24 CPU threads of the Ryzen 9 7900X3D. macOS only (`_OSI ("Darwin")`).

| | |
|---|---|
| Source | [`src/SSDT-CPUR-B650EI.dsl`](../../src/SSDT-CPUR-B650EI.dsl) |
| Live bytes | [`aml/SSDT-CPUR-B650EI.aml`](../../aml/SSDT-CPUR-B650EI.aml), 1028 bytes, sha256 `da5bf6ea53b8ecc23ec20f102d217ebd2f4a1c4e095ed01ff658f7268df92db4` |
| Table header | `SSDT` rev 2, OEM ID `VRMLN`, OEM table ID `CPUR`, OEM revision `0x00001000` |
| Firmware | ASUS ROG STRIX B650E-I, BIOS 4005 |
| Evidence | [`docs/LLMs/re/firmware-tables-bios4005.md`](../LLMs/re/firmware-tables-bios4005.md) |

## What the firmware lacks

The firmware describes the CPUs only as ACPI Processor Device objects, `ACPI0007`:

- The table `SSDT` "CPUSSDT" (OEM table ID, 777 bytes) declares `\_SB.PLTF` (`ACPI0010`, Processor Container) with 24 children `C000`..`C017`. Each has only `_HID` and `_UID` (0..23).
- No table in the 4005 dump (DSDT plus 15 SSDTs) contains a `Processor ()` object.
- The MADT lists 32 Local APIC entries. 24 are enabled: ACPI Processor IDs `0x00, 0x02 … 0x16` (cores, even), then `0x01, 0x03 … 0x17` (SMT siblings, odd), in that table order. The last 8 (`0x18`..`0x1F`) are disabled.

## What the macOS consumer needs

macOS discovers CPUs from `Processor ()` objects in the ACPI namespace; the live ioreg shows each as an `IOACPIPlatformDevice` with an `AppleACPICPU` on it (not confirmed from Apple's binaries yet). With only `ACPI0007` devices, no CPU object exists for it to match. The Vermilion work on this machine saw the boot stall after "CoreAnalyticsHub start completed" without this table (Dortania's guide requires the same SSDT-CPUR for the same firmware style on B550/A520).

So the table adds one `Processor ()` per **enabled** MADT entry:

- `ProcessorId` = the MADT's ACPI Processor ID, in MADT order (`PR00`..`PR0B` = `0x00`..`0x16` even, `PR0C`..`PR17` = `0x01`..`0x17` odd).
- None for the 8 disabled entries: phantom CPUs make macOS stall too (Vermilion finding, 2026-11-19).
- `PblkAddress = 0x00000810`, `PblkLength = 6`, identical for all 24. **Open:** nothing in the firmware tables defines or consumes this block (the FADT has no P_BLK field by design, and `0x810` appears as a constant in none of the 16 AML tables). The value is reportedly the one Dortania's SSDT-CPUR uses on every entry (reviewer's recollection, not rechecked here), which would explain it. It is kept unchanged because the table boots. A follow-up should confirm from Apple's `AppleACPIPlatform` that AMD ignores it (REA), then decide whether `0` is cleaner. That would be a byte change to a booting table and needs its own boot test.

Live evidence (ioreg `IOACPIPlane`, booted from the internal ESP with OpenCore 1.0.8, 2026-11-27): 24 `PRxx` `IOACPIPlatformDevice` nodes (`PR00@0` … `PR17@1B`), 24 `AppleACPICPU` instances, `machdep.cpu.thread_count` 24.

## Darwin-only `_STA`

Every `PRxx` has `_STA`: `Return (0x0F)` when `_OSI ("Darwin")` is true, otherwise `Return (Zero)`. Another OS is therefore expected to see no processor objects and keep using the `ACPI0007` devices (untested; see below). What decides this is how the booted OS answers `_OSI ("Darwin")`, not the DSDT's contents (the DSDT only tests `Windows …` strings and `_OS`). macOS answers true; Linux's `_OSI` answers are expected to be false for "Darwin" (its interface list has no such string), but that is **not verified** here, nor is whether the Linux boot goes through OpenCore at all.

## Limits

- Valid for **24 threads** only. A different CPU (or SMT off in the BIOS) changes the MADT; the table must be rebuilt from that MADT. Do not add or drop entries by hand.
- `iasl` warns 24 times "Legacy Processor() keyword detected" (code 3168). That is intentional: legacy `Processor ()` is exactly what macOS needs.

## How to test

1. Host: `tools/ci.sh` (rebuild equals the committed bytes, ignoring the checksum and compiler revision).
2. Device, after the Orchestrator stages a candidate that contains the table: `ioreg -p IOACPIPlane -w0 | grep -cE '\+-o PR[0-9A-F]{2}@'` prints 24; `sysctl machdep.cpu.thread_count` prints 24; the boot reaches the login window.
3. Linux (Omarchy, bridge task, not run here): the 24 `ACPI0007` CPUs are present and `dmesg` shows no duplicate-processor-ID complaints (the `PRxx` IDs 0–23 equal the `ACPI0007` `_UID`s; whether Linux could confuse them is unchecked).
4. Removing the table must reproduce the stall (not retested here: it needs a candidate boot and is the Orchestrator's call).
