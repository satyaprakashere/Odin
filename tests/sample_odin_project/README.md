# Sample Odin Project

This project demonstrates and tests compiling a standard Odin project using the **Thor** compiler driver (`thor build .`).

## Features Tested
- Building a pure Odin project containing only `.odin` files with `thor build .`.
- Resolving the entry point `main :: proc()`.
- Verifying that standard identifiers named `func` (e.g. `compute :: proc(func: int) -> int`) compile cleanly without keyword conflict.

## Usage
From this directory:
```sh
thor build .
./sample_odin_project
```
Or:
```sh
thor run .
```
