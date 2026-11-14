# Thor Automation & Synchronization Tooling

This directory contains automation utilities, build helpers, and synchronization tools for the Thor programming language and toolchain.

All automation scripts are written strictly in **Go** adhering to project development guidelines.

---

## Tool Catalog

### `sync_rekursion_thor.go`

Automated synchronization and verification engine between the Odin-based Thor compiler and the canonical **rekursion/thor** language variant located at `/Users/prakash/Documents/projects/rekursion/lang/thor/`.

#### Features:
1. **Provenance & Git Commit Tracking**: Inspects the `rekursion` repository, capturing the active commit hash, author date, and commit message for `lang/thor`.
2. **Authoritative Specification Mirroring**: Automatically copies `THOR.md` and `GRAMMAR.md` into `doc/thor/rekursion_specs/` with zero manual intervention.
3. **Upstream Invariant Verification**: Validates that `core/` and `odin.ebnf` remain 100% byte-for-byte identical (0 diff lines) to `upstream/master`.
4. **Compiler Parity Matrix**:
   - Compiles and typechecks `tests/rekursion_sync/source.thor`.
   - Executes `tests/rekursion_sync/test_rekursion_parity.thor` to test pure functions (`func`), DOP structs, and container types.
   - Executes `tests/rekursion_sync/test_c_ingest_compat.thor` to verify C header ingestion compatibility.
   - Executes `tests/thor_interop` to test mixed `.thor` / `.odin` package builds.
   - Executes upstream regression check on `core/c/libc`.

#### Usage:
```sh
# Standard run (uses default REKURSION_PATH or /Users/prakash/Documents/projects/rekursion)
go run scripts/sync_rekursion_thor.go

# Custom Rekursion path
go run scripts/sync_rekursion_thor.go -rekursion /path/to/rekursion

# Dry-run mode (preview without copying files)
go run scripts/sync_rekursion_thor.go -dry-run

# Verbose mode with command logs
go run scripts/sync_rekursion_thor.go -verbose
```
