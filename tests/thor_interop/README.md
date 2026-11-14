# Thor-Odin Interoperability Test

This test demonstrates the seamless co-existence and interoperability between the **Odin** programming language and the **Thor** language dialect within the same package.

## Key Features Tested

1. **Dialect-Gated Lexing**:
   - `math_thor.thor` uses the `func` keyword to define pure mathematical functions (`square`, `cube`).
   - `main_odin.odin` uses `func` as a normal procedure parameter name (`proc(func: int) -> int`), verifying that standard Odin files are not broken by Thor keywords.
2. **Package-Level Interoperability**:
   - Both `.odin` and `.thor` files reside in the same package `thor_interop`.
   - Odin procedures can call Thor pure functions with full type checking.
3. **Execution**:
   - Run via:
     ```sh
     ./odin run tests/thor_interop
     ```
   - Or when using the Thor alias:
     ```sh
     ./thor run tests/thor_interop
     ```
