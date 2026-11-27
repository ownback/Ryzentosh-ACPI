# Building and checking the tables

## The pin

All tables are built with **iasl 20260930** (ACPICA release tag `20260930`). `tools/build.sh` refuses any other version.

Two ways to get it; both come from the same source:

1. **MacPorts** (what the owner's Mac uses): `sudo port install acpica @20260930`. The port builds `https://github.com/acpica/acpica/archive/refs/tags/20260930.tar.gz`, sha256 `feddab0f42f1e01afa3b8ec04f3aaef5e61e891225b8dc8776953ca9f3df1449`.
2. **From source, anywhere** (what CI does): `tools/install-iasl.sh` downloads that tarball, checks the sha256, builds `iasl` and puts it at `build/iasl/bin/iasl`. It needs `curl`, `make`, a C compiler, GNU bison ≥ 3, flex and GNU m4 (`gm4`). On macOS: `port install bison flex m4` or `brew install bison flex m4`, with bison's `bin` first on `PATH` (Apple's bison is 2.3).

The two builds produce byte-identical tables for both SSDTs (checked 2026-11-27: the MacPorts `iasl` and the source-built one, same output files).

## Build and check

```
tools/ci.sh        # install-iasl (if needed) → build → verify
tools/build.sh     # src/*.dsl → build/out/*.aml
tools/verify.sh    # aml/*.aml vs build/out/*.aml
```

`IASL=/opt/local/bin/iasl tools/ci.sh` skips the source build.

## What "identical" means

`aml/*.aml` are the bytes that boot (copied unchanged from Ryzentosh-EFI `main`). They were compiled with iasl 20251212. A rebuild with 20260930 differs in exactly the header bytes iasl writes itself:

- offset 9: the table checksum (it follows from the change below);
- offsets 32–35: the compiler revision.

`tools/verify.sh` fails if the sizes differ or any other byte differs, and checks `aml/SHA256SUMS`. Never "fix" a CI failure by replacing an `aml/` file: those bytes are what is installed on the machine. A table change is a new `.dsl` and a new `.aml` together, in a PR that goes through a boot test.

## Reading the iasl output

`SSDT-CPUR-B650EI` compiles with 24 warnings (code 3168, "Legacy Processor() keyword detected"). They are expected, see its justification. `SSDT-EC-USBX-B650EI` compiles with none.
