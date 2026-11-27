# SSDT-EC-USBX-B650EI

Hides the board's real embedded controller from macOS, adds the `EC` device macOS expects, and adds `USBX` (USB port power). macOS only (`_OSI ("Darwin")`).

| | |
|---|---|
| Source | [`src/SSDT-EC-USBX-B650EI.dsl`](../../src/SSDT-EC-USBX-B650EI.dsl) |
| Live bytes | [`aml/SSDT-EC-USBX-B650EI.aml`](../../aml/SSDT-EC-USBX-B650EI.aml), 377 bytes, sha256 `f651e3f745f2b6008ac57bbb565589b3828c6cc703c9eeed6d1c406c75897d96` |
| Table header | `SSDT` rev 2, OEM ID `VRMLN`, OEM table ID `ECUSBX`, OEM revision `0x00001000` |
| Firmware | ASUS ROG STRIX B650E-I, BIOS 4005 |
| Evidence | [`docs/LLMs/re/firmware-tables-bios4005.md`](../LLMs/re/firmware-tables-bios4005.md) |

The table has three parts. They are one table because they were always one change (Dortania's SSDT-EC-USBX method, adapted to this DSDT); the owner's rule is one SSDT per purpose, and "give macOS a usable EC/USB-power description" is one purpose.

## 1. Real EC hidden from macOS

**Firmware:** `\_SB.PCI0.SBRG.EC0` (DSDT, `Scope (_SB.PCI0.SBRG)`) is `PNP0C09`, I/O ports `0x62`/`0x66`, `_GPE 0x04`, with `_REG` and the `_Qxx` query methods that forward to `\RMTW.AMWN` (ASUS WMI notifications). It has **no `_STA`**, so every OS treats it as present.

**macOS consumer:** `AppleACPIEC` binds `PNP0C09` (its `Info.plist` match, read on this system). The EC here speaks an ASUS-specific protocol (its queries feed ASUS WMI), so macOS's EC driver must not drive it. Hiding it follows Dortania's method and is what the live system has run since 2026-11-18; no failure from letting `AppleACPIEC` bind it has been recorded here, so the exact failure is not independently reproduced. So `EC0` gets `_STA`: `Return (Zero)` under Darwin, `Return (0x0F)` otherwise.

**Other OS:** expected unchanged (`0x0F`, the same as an absent `_STA`), provided that OS does not answer `_OSI ("Darwin")` true. Not tested, see below.

## 2. Fake `EC` device

**macOS consumer:** Dortania's EC page says macOS (since Catalina) wants a device named `EC` and names `AppleBusPowerController` as the component that looks for it; Apple's Macs have one. **Open:** not confirmed from Apple's binaries. On this system `AppleBusPowerController` is matched on `IOResources`/`IORTC`, so the actual consumer of the `EC` name is unidentified (REA follow-up). The `EC` device is kept because it is part of the booting table.

The table adds `Device (EC)` under `\_SB.PCI0.SBRG` with `_HID "ACID0001"` (matches no driver: nothing is behind it) and `_STA` = `0x0F` under Darwin, `Zero` otherwise. Live ioreg (internal ESP boot, 2026-11-27) shows `EC` present as an `IOACPIPlatformDevice`, and `EC0` absent.

## 3. USBX

`Device (USBX)` under `\_SB` with `_ADR 0`, and a `_DSM` that answers `Arg2 == 0` with `Buffer {0x03}` and otherwise returns this package:

| Property | Value |
|---|---|
| `kUSBSleepPowerSupply` | `0x13EC` (5100 mA) |
| `kUSBSleepPortCurrentLimit` | `0x0834` (2100 mA) |
| `kUSBWakePowerSupply` | `0x13EC` (5100) |
| `kUSBWakePortCurrentLimit` | `0x0834` (2100) |

The values are those of Apple's desktop Macs (per the Vermilion/Dortania method; Dortania only says USBX supplies the USB power properties, and the effect of omitting them is not reproduced here). The live IORegistry shows `kUSBSleepPowerSupply = 5100` and `kUSBWakePortCurrentLimit = 2100`. `_STA` is Darwin-only as above. No table of the BIOS 4005 dump defines a `USBX` device (searched DSDT and all 15 SSDTs).

## Darwin-only scoping

All three `_STA` methods test `_OSI ("Darwin")` and invert for the real EC. For an OS whose `_OSI ("Darwin")` is false, the only visible difference should be that `EC0` has an `_STA` returning `0x0F`, i.e. what an absent `_STA` already meant. This is expected, not verified: the Linux check in the test section has not been run.

## How to test

1. Host: `tools/ci.sh`.
2. Device, in a candidate boot: `ioreg -p IOACPIPlane -w0 | grep -E '\+-o (EC|EC0|USBX)[ @]'` lists `EC` and `USBX` and not `EC0`; `ioreg -l -w0 | grep kUSBSleepPowerSupply` shows 5100; USB ports keep power across a sleep/wake (TESTPLAN.md).
3. Linux on the same machine: `EC0` must still enumerate (check `/sys/bus/acpi/devices/PNP0C09:00`), proving the Darwin gate. Needs an Omarchy boot (bridge task), not done in this issue.
