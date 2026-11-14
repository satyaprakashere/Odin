# Thor Programming Language Extension for Odin

**Thor** is a superset/dialect of the Odin programming language designed to provide advanced language semantics—such as pure functions (`func`), enhanced type safety, and formal effect tracking—without breaking compatibility with upstream Odin (`odin-lang/Odin`).

## Architecture & Design Principles

### 1. Dialect Isolation
- **`.thor` Files**: Thor language features are automatically enabled for files with the `.thor` extension. In `.thor` files, `func` is a keyword denoting pure procedures.
- **`.odin` Files**: Vanilla Odin syntax is strictly maintained for files with the `.odin` extension. Standard Odin identifiers named `func` (e.g. in `core:c/libc`) remain valid identifiers without any syntax collision.
- **Command-line Flag**: `-dialect:odin` or `-dialect:thor` can configure the default dialect for non-standard files.
- **Binary Identity**: Invoking the compiler binary as `thor` (e.g. via symlink `thor -> odin`) automatically defaults the language dialect to Thor.

### 2. Zero Upstream Diff Invariant
To ensure seamless merging and rebasing against upstream `odin-lang/Odin`:
- The standard library directories `core/` and `vendor/` remain 100% untouched and identical to upstream.
- All dialect differentiation occurs in the frontend (tokenizer, parser, and semantic checker), preventing any requirement to patch upstream libraries.

### 3. Pure Functions (`func`)
Thor introduces `func` for declaring pure functions:
```thor
add :: func(a, b: int) -> int {
    return a + b
}
```
- Pure functions default to the `contextless` calling convention (`ProcCC_Contextless`).
- Pure functions are barred from accessing or mutating global state.
- Calling an impure `proc` from a pure `func` is disallowed.

## Build and Run

To build the compiler:
```sh
./build_odin.sh debug
```

To create the `thor` command alias:
```sh
ln -sf odin thor
```

To compile or run a Thor package or file:
```sh
./thor run tests/internal/test_pure_func.thor -file
./thor run tests/thor_interop
```
