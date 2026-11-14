# Thor Language Implementation Walkthrough

This document outlines the step-by-step implementation and verification of extending the Odin programming language compiler with the **Thor** language dialect, preserving 100% upstream Odin compatibility.

---

## 1. Problem Overview & Invariant Restoration

### The Problem
Previously, introducing `func` directly as a global keyword into Odin's tokenizer broke standard Odin files that used `func` as an identifier—most notably in `core:c/libc` (`signal.odin`, `stdlib.odin`, `threads.odin`) and `core:sys/posix/signal_libc.odin` where C function signatures use `func: proc "c" ()`. As a workaround, these identifiers had been changed to `fn:`, which diverged from upstream `odin-lang/Odin` and blocked seamless rebasing.

### The Fix (Zero-Diff Invariant)
All changes to `core/` and `odin.ebnf` were reverted to match `upstream/master` exactly:
```sh
git checkout upstream/master -- core/ odin.ebnf
git diff upstream/master -- core/ odin.ebnf  # Returned 0 diff lines
```

---

## 2. Frontend Implementation Details

### 2.1 Dialect-Aware Tokenizer (`src/tokenizer.cpp`)
Instead of making `func` a global keyword, we introduced dialect awareness:
1. **Dialect Definition**:
   ```cpp
   enum LanguageDialect : u8 {
       Dialect_Odin = 0,
       Dialect_Thor = 1,
   };
   gb_global LanguageDialect global_default_dialect = Dialect_Odin;
   ```
2. **Dialect Path Detection**:
   ```cpp
   gb_internal bool path_is_thor_dialect(String const &fullpath) {
       if (string_ends_with(fullpath, str_lit(".thor"))) {
           return true;
       }
       if (global_default_dialect == Dialect_Thor) {
           bool is_core_or_vendor = string_contains_string(fullpath, str_lit("/core/")) ||
                                    string_contains_string(fullpath, str_lit("/vendor/")) ||
                                    string_contains_string(fullpath, str_lit("\\core\\")) ||
                                    string_contains_string(fullpath, str_lit("\\vendor\\"));
           if (!is_core_or_vendor) {
               return true;
           }
       }
       return false;
   }
   ```
3. **Keyword Filtering**:
   In `tokenizer_get_token`, when an identifier matches `Token_func`:
   ```cpp
   if (str_eq(entry->text, token->string)) {
       if (is_thor_keyword(entry->kind) && !t->is_thor) {
           token->kind = Token_Ident;  // Demoted to normal identifier for .odin files!
       } else {
           token->kind = entry->kind;  // Preserved as Token_func for .thor files!
           ...
       }
   }
   ```
   **Result**: In any `.odin` file (including `core:` and `vendor:`), `func` remains a plain identifier. In `.thor` files, `func` is a keyword.

---

### 2.2 Extension Parsing & Package Scanning (`src/parser.cpp`)
Updated `src/parser.cpp` to recognize `.thor` files alongside `.odin` files:
1. **File Validation**:
   ```cpp
   if (!string_ends_with(f->fullpath, str_lit(".odin")) && !string_ends_with(f->fullpath, str_lit(".thor"))) {
       return ParseFile_WrongExtension;
   }
   ```
2. **Directory & Package Scanning**:
   Updated `try_add_import_path` to scan and count both `.odin` and `.thor` files as valid source files for package parsing, reserving array capacity appropriately.
3. **Single File Handling**:
   Allowed building single `.thor` files (`-file`).

---

### 2.3 Build Settings & Output Naming (`src/build_settings.cpp`)
Updated `src/build_settings.cpp`:
1. **Executable Suffix Trimming**:
   Ensured output executable names strip both `.odin` and `.thor` extensions properly:
   ```cpp
   if ((path_extension(output_name) == ".odin" || path_extension(output_name) == ".thor") && !path_is_directory(output_name)) {
       output_name = remove_extension_from_path(output_name);
   }
   ```
2. **Collision Checks**:
   Updated binary collision checks when building single files with matching directory names.

---

### 2.4 Command Line & Executable Identity (`src/main.cpp`)
1. **CLI Flag `-dialect`**:
   - Added `BuildFlag_Dialect` (`-dialect:odin` or `-dialect:thor`).
2. **Binary Invocation Detection**:
   - If the compiler is executed as `thor` (e.g. `./thor` or a symlink `thor -> odin`), `global_default_dialect` defaults to `Dialect_Thor`.
3. **Single-File Extension Validation**:
   - Updated CLI argument checks to accept either `.odin` or `.thor` with the `-file` flag.

---

## 3. Verification & Test Results

### 3.1 Upstream Library Compatibility
Tested type checking on pristine upstream `core:c/libc`:
```sh
./odin check core/c/libc -no-entry-point
# Exit Code: 0 (No syntax errors on parameter 'func: proc "c" ()')
```

### 3.2 Pure Function Testing (`tests/internal/test_pure_func.thor`)
Renamed and executed pure function unit tests under Thor:
```sh
./odin run tests/internal/test_pure_func.thor -file
# Output:
# Testing pure functions...
# All pure function assertions passed!

./odin test tests/internal/test_pure_func.thor -file
# Output:
# Finished 1 test in 53µs. The test was successful.
```

### 3.3 Mixed Thor-Odin Package Interoperability
Created `tests/thor_interop/`:
- `math_thor.thor`: Defines pure functions `square` and `cube` using `func`.
- `main_odin.odin`: Defines a procedure using `func` as a parameter name:
  ```odin
  calculate :: proc(func: int) -> int {
      return square(func) + cube(func)
  }
  ```
Tested execution of the package:
```sh
./odin run tests/thor_interop
# Output:
# Result: 36
# Thor-Odin mixed package test passed!
```

### 3.4 Full Compiler & Demo Regression Test
Ran the full demo with strict styling and vetting:
```sh
./odin run examples/demo -vet -strict-style -- Hellope World
# Exit Code: 0 (All features, threads, BigInt, reflection, and SIMD passed)
```

---

## 4. Git Commit Details

- **Commit SHA**: `7c2259e01`
- **Commit Message**: `Extend Odin with Thor language via non-breaking dialect gating and .thor support`
- **Files Modified / Added**:
  - `core/c/libc/signal.odin`, `stdlib.odin`, `threads.odin` (restored to upstream)
  - `core/sys/posix/signal_libc.odin` (restored to upstream)
  - `odin.ebnf` (restored to upstream)
  - `src/tokenizer.cpp` (dialect-aware lexer)
  - `src/parser.cpp` (`.thor` extension & package scanning)
  - `src/build_settings.cpp` (output name handling)
  - `src/main.cpp` (`-dialect` flag, `thor` executable dispatch)
  - `tests/internal/test_pure_func.thor` (renamed from `.odin`)
  - `tests/thor_interop/` (mixed package test)
  - `doc/thor/README.md` (Thor documentation)
  - `.gitignore` (added `thor` binary ignore)

---

## 5. Strict C/C++ Style Modular Separation (Final Phase)

### 5.1 Encapsulated Thor Subsystem (`src/thor/`)
All Thor-specific language logic is now fully isolated from Odin compiler internals:
- `src/thor/thor.hpp`: Declarations for dialect types, keyword identifiers, and semantic validation prototypes.
- `src/thor/thor.cpp`: Implements extension-based language resolution.
- `src/thor/thor_checker.cpp`: Encapsulates all pure function semantic checks:
  - `thor_check_global_variable_access`: Blocks access to mutable globals from pure functions.
  - `thor_check_call_purity`: Prevents calling impure procedures from `func`.
  - `thor_check_context_access`: Enforces prohibition of Odin implicit `context` in pure functions.
  - `thor_check_assignment_purity`: Validates that raw pointer dereferences, map insertions, and global assignments cannot occur within `func`.
  - `thor_check_param_type_purity` / `thor_check_result_type_purity`: Forbids dynamic arrays in `func` signatures.

### 5.2 Standard Library Root Collection (`thor:`)
- Registered `$ODIN_ROOT/thor` in `src/main.cpp` as the `thor:` package collection.
- Scaffolding:
  - `thor/README.md`: Library documentation and architecture.
  - `thor/math/math.thor`: Pure algorithms (`factorial`, `fibonacci`, `gcd`, `square`, `cube`).
  - `thor/types/types.thor`: Pure data container types (`PureResult`).

### 5.3 Upstream Purity Confirmed
- `git diff upstream/master -- core/ odin.ebnf`: Confirmed **0 lines changed**.
- All tests pass identically under `./odin` and `./bin/thor`.
