# TESTPLAN: Ryzentosh-ACPI

| Parity target | Test | Host or device | Status |
|---|---|---|---|
| Tables are what the sources compile to | `tools/ci.sh`: rebuilt = committed `.aml` except bytes 9 and 32–35 (iasl 20260930) | Host and CI | **pass** (2026-11-27) |
| Committed bytes = live bytes | sha256 of `aml/*.aml` equals Ryzentosh-EFI `main`, the USB known-good and the internal ESP's backups | Host | **pass** (2026-11-27; the internal ESP itself is read by the Orchestrator at the next staging) |
| All 24 threads are CPUs (a Mac Pro sees every thread) | `ioreg -p IOACPIPlane -w0 \| grep -cE '\+-o PR[0-9A-F]{2}@'` = 24; `sysctl machdep.cpu.thread_count` = 24; login window reached | Device | **pass** on the live boot of 2026-11-27 (internal ESP, OpenCore REL-108) |
| EC and USB power like a Mac | ioreg shows `EC` and `USBX`, no `EC0`; `kUSBSleepPowerSupply` = 5100 | Device | **pass** on the same boot |
| USB ports keep power across sleep/wake ×3 | `pmset sleepnow`, check an attached device | Device | not run here (needs the sleep test row; Ryzentosh-PLATFORM) |
| Other OSes unaffected | Omarchy: `PNP0C09:00` (EC0) present and the 24 `ACPI0007` CPUs present | Device (Linux boot) | not run here: needs a bridge task and the owner |
| A table change is a boot test | Any change to `src/*.dsl` or `aml/*.aml` goes to the Orchestrator as a candidate | Device | rule |
