# Firmware tables, ASUS ROG STRIX B650E-I, BIOS 4005 (findings)

Evidence behind the two live SSDTs. **Findings only**: names, paths, offsets and hashes. The raw tables and their disassembly are firmware (ASUS/AMI/AMD) and are not committed (licensing rule 7); they stay in the control plane's private area, read-only.

## Source of the dump

- Dump taken 2026-11-19 from this machine, BIOS `4005` (file `bios-version`), 30 tables (plus two older `.dsl` files in the folder): `DSDT`, `SSDT1`..`SSDT15`, `APIC` (MADT), `FACP`, `FACS`, `FIDT`, `FPDT`, `HPET`, `IVRS`, `MCFG`, `BGRT`, `TPM2`, `VFCT`, `WDRT`, `WPBT`, `WSMT`. Disassembled for this issue with iasl 20260930 (`iasl -e SSDT*.aml -d DSDT.aml`).
- The EC0/DSDT and MADT facts below were taken from that dump. The macOS-side facts were read live from the running system (`ioreg`, `sysctl`) on 2026-11-27 while booted from the internal ESP (`booted_from: internal`, no flags, OpenCore REL-108).
- Not done here: a fresh dump from the current boot (macOS doesn't expose raw tables; OpenCore's SysReport isn't enabled) and an Omarchy re-dump via the bridge. The BIOS version is unchanged since 2026-11-19, so the dump is assumed current. If the BIOS is ever updated, repeat this document.

## Table hashes (sha256, BIOS 4005 dump)

| Table | Bytes | sha256 |
|---|---|---|
| DSDT (`ALASKA` / `A M I `, rev 2, OEM rev `0x01072009`) | 85282 | `04b1c5ede7d8c74078b17183850bab5d7550aee6629c3f45a665f93dfde1bfd0` |
| SSDT `CPUSSDT` (SSDT2) | 777 | `d73210178609d1f63f0bb1600344554ff7c13eef2af1713b0b4df2702f8a9d08` |
| APIC (MADT) | 350 | `98f50a329875e2f16d91b3b50884137105623180f08404973b491dce720df6d5` |
| FACP | 276 | `e9fce2c7fcf8a3ba855b93bffa7f7f62965ef927b85241d29eef062146560aa3` |

Other SSDTs (OEM table IDs): `Splinter`, `AMD CPU`, `AppCompD`, `ASUSPLDR`, `CPMDFIG2`, `CDFAAIG2`, `CPMDFDG2`, `CPMCMN`, `AOD`, `MEMTOOL0`, `CPMMSOSC`, `AMDWOV`, `CPMAPMFD`, `AmdTable`.

## CPU objects (SSDT-CPUR)

| Fact | Where | Value |
|---|---|---|
| CPUs are `ACPI0007` devices | SSDT `CPUSSDT`: `\_SB.PLTF` (`ACPI0010`, `_CID PNP0A05`, `_UID 1`) | children `C000`..`C017`, `_UID` 0..23, only `_HID` + `_UID` |
| No `Processor ()` object anywhere | grep over the disassembly of DSDT + 15 SSDTs | 0 matches |
| MADT Local APIC entries | APIC | 32 (type 0 "Processor Local APIC") |
| Enabled entries | APIC | 24: Processor IDs `0x00,02,…,16` then `0x01,03,…,17`; Local APIC IDs `0,2,4,6,8,0xA,0x10,0x12,…,0x1A` then `1,3,5,7,9,0xB,0x11,…,0x1B` |
| Disabled entries | APIC | 8: Processor IDs `0x18`..`0x1F`, flags 0 |
| FADT power blocks | FACP | PM1a event `0x800`, control `0x804`, timer `0x808`; no P_BLK (so the table's `0x810`/6 is not from firmware) |
| DSDT answers `_OSI ("Darwin")` | grep | no; `_OSI` is used for `Windows …` strings, `_OS` for `Linux`/`FreeBSD` |

The source's `ProcessorId` list equals the enabled MADT IDs in table order (checked by hand against the `.dsl`: `PR00`..`PR0B` = 0,2,…,0x16; `PR0C`..`PR17` = 1,3,…,0x17).

## EC (SSDT-EC-USBX)

| Fact | Where | Value |
|---|---|---|
| Real EC | DSDT `Scope (_SB.PCI0.SBRG)`, `Device (EC0)` (lines 6226–6288 of the disassembly) | `_HID PNP0C09`, IO `0x62`, `0x66`, `_GPE 0x04`, `_REG`, `_Qxx` → `\RMTW.AMWN (0xA00…)` |
| `_STA` | within that device | none (the only `_STA` after it, at line 6831, belongs to another device) |
| `SBRG` | DSDT `Device (SBRG)` under `\_SB.PCI0` (line 3597) | exists, so the SSDT's `External` is valid |
| An `EC` device | all 16 tables with AML bodies (DSDT + 15 SSDTs) | none |
| A `USBX` device | same 16 tables | none |
| Other `EC0` scopes | DSDT has a second `Scope (_SB.PCI0.SBRG.EC0)` (about 2200 lines, from line 9679); SSDT `CPMCMN` references `EC0.CCDP` | neither defines `_STA` (checked) |

## Live macOS-side facts (2026-11-27, internal ESP boot)

- `ioreg -p IOACPIPlane`: 24 `PRxx` nodes `PR00@0` … `PR17@1B` (`IOACPIPlatformDevice`, matched, active); `EC` present; `EC0` absent; `USBX@0` present (`!registered, !matched`: no driver binds it).
- `ioreg -c AppleACPICPU`: 24 `AppleACPICPU` instances. `sysctl machdep.cpu.thread_count` 24, `core_count` 12.
- IORegistry carries `kUSBSleepPowerSupply = 5100`, `kUSBWakePortCurrentLimit = 2100`.

## Live bytes vs rebuild

- Live tables were compiled with iasl `20251212` (compiler revision bytes at offset 32–35 are `12 12 25 20`, little-endian `0x20251212`). The pinned `20260930` writes a different revision and therefore a different checksum; all other bytes are identical (verified by `tools/verify.sh`; see `docs/Humans/BUILD.md`).
- The committed `.aml` files are identical (sha256) to the files on the USB known-good ESP and in Ryzentosh-EFI `main` (`7bd8f7b`), and to the copy of the internal ESP's `EFI/OC/ACPI` kept in the control plane's EFI backups of 2026-11-27 (see the PR).
