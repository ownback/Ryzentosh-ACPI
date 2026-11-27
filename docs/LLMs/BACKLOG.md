# BACKLOG: tables that may be added (none exist yet)

Rule (issue #1): **no table is added without evidence.** Each item lists the evidence that would justify it. Leads below are facts found in the BIOS 4005 DSDT (see `re/firmware-tables-bios4005.md`) or in the control plane; they justify an investigation, not a table. One SSDT per purpose (owner decision).

## 1. Sleep/wake sources: `SSDT-PRW-B650EI` (name provisional)

- **Purpose:** make macOS wake from the right devices and not from the wrong ones (real Macs: `_PRW` on `XHC`, the power button and LAN only, and `GPRW`/`UPRW`-style methods that return `0` for the rest).
- **Lead:** the DSDT has 74 `_PRW` methods (disassembly count), for example under `GPP3`/`D003`; the full per-device list is not inventoried yet (that is evidence item 0).
- **Evidence needed before any table:**
  0. A per-device `_PRW` inventory from the DSDT (device path, GPE or event bit, sleep state).
  1. Which wake sources fire in macOS today: `pmset -g log` / `pmset -g assertions` over sleep/wake ×3, and the `IOPMrootDomain` wake-reason strings after each wake.
  2. Whether macOS wakes the machine spontaneously or fails to wake. Without a failing symptom there is nothing to fix.
  3. REA of Apple's `IOPMrootDomain` / `AppleACPIPlatform` for how `_PRW` GPE numbers and the "instant wake" check are consumed (parity target stated as "a real Mac does X").
  4. The Linux ground truth: `/proc/acpi/wakeup` on Omarchy (bridge task).
- **Blocked by:** the sleep/wake test row in the control plane's COMPATIBILITY_MATRIX; Ryzentosh-PLATFORM owns sleep behaviour, so the Lead there must ask for it.

## 2. dGPU power-down: `SSDT-GPU-B650EI` (name provisional)

- **Purpose:** ADR-0005 option B/GPU M1.5: put the RX 7900 XTX into D3 / power it off when headless, with the AML power-resource methods a real Mac with a discrete GPU has (`_PS0`/`_PS3`, `_ON`/`_OFF` on a `PowerResource`, `_PR0`).
- **Leads:** the dGPU's firmware path is **not yet identified** (it sits behind a `GPPx` root port; match it against `lspci` from bridge task 0001). Note `\_SB.PCI0.GP17` (`_ADR 0x00080001`, child `VGA`) is the Raphael iGPU's bridge (the iGPU is disabled in the BIOS today), not the dGPU. The DSDT has several `_PS0`/`_PS3` pairs (from line 16230 of the disassembly, owners not yet identified).
- **Evidence needed before any table:**
  1. ADR-0005 accepted (it is "proposed, leaning to B"; needs bridge task 0004's idle-power numbers: the owner measured 30–50 W idle at 2560×1440@240 on Linux, to be verified).
  2. What the firmware already provides on the dGPU's slot: whether it has `_PR0`/`_PS3`/a power resource, or only `_PS0`/`_PS3` stubs (decode that part of the DSDT; SSDT `CPMCMN` / `CPMDFIG2` family also carry AMD CPM code to read).
  3. What the macOS consumer expects (`IOPCIDevice` PM, the AMD driver's runtime-suspend path): from the Ryzentosh-dGPU/GPU Lead's RE, never copied.
  4. A hardware test plan that cannot lose the display: the board's iGPU output must be proven first (RB-0005b).
- **Blocked by:** ADR-0005, Ryzentosh-GPU design. No table before that.

## 3. Mac devices: `SSDT-SBUS-B650EI` and friends (one table per device, only if needed)

- **Purpose:** devices that a real Mac exposes and that macOS drivers or `AppleSMC`-adjacent code look for: `SBUS`/`BUS0` with `DVL0` (SMBus, so `AppleSMBusController` attaches), `MCHC` (host bridge), `PMCR`, a `DMAC`/`PIC`/`TIMR`/`RTC` compat set, `ALS0`, `FWHD`.
- **Leads:** the FCH SMBus is `_ADR 0x00140000` under `\_SB.PCI0` (`Name (SMB0, 0x0B00)` at the root; its controller device is unnamed in the disassembly); the HPET table exists but `PNP0103` handling is not yet checked.
- **Evidence needed per device:** (a) the exact macOS consumer (class, matching property) from REA of the 25G241 binaries; (b) a real symptom today (log line, missing ioreg node, failing feature); (c) the DSDT evidence that the device is absent or wrong; (d) the Darwin-only `_STA` scoping. Candidates are rejected if no symptom exists. Several Intel-era entries from Dortania's lists (e.g. `PMCR`, `MCHC`, `DMAC`) are for Intel PCHs and are **not** assumed to apply to AMD.
- **Blocked by:** nothing technical, but each needs an owner-visible symptom first.

## Tracking

Open one GitHub issue per item when its first evidence item is gathered, labelled with the owning Lead's repo. This file is the index only.
