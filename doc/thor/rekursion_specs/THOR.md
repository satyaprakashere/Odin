# Thor Language Specification

Thor is a high-performance systems programming language frontend designed to compile to WebAssembly (WASM) and Native machine code via the Rekursion engine. It provides an Odin-inspired syntax for hardware-level control, zero-cost abstractions, and data-oriented programming. It should be more memory safe, more expressive and faster than rust lang.

It's syntax should evolve from odin with focus on immtability, advanced type system(inductive types) and memory safety like rust.

## Design Philosophy

- **Recursive Theory Model**: Based on Kurt Gödel's model of computation.
- **Inductive types**: should support advanced type system like inductive types and laws
- **Immutability by Default**: State changes are handled through transformations; mutation is an optimization.
- **No General Recursion**: Use explicit `recur` for tail-recursive iterations.
- **Target Execution**: Compiles to WebAssembly (WASM) and Native machine code.
- **Data-Oriented Programming (DOP)**: Prioritizes arrays and contiguous memory layouts (Mike Acton) over linked lists.
- **Performance**: Aimed at being faster than LuaJIT in interpreter mode and faster than rust lang in native run. Achieved via recursive theory model and hardware-aware compilation.
- **Memory Safety**: Achieved via advanced type theory(like borrow checker, linear types, region based mutation) and also by learning from the 50 years of memory allocation strategy used by C and C++ projects.
- **Fast compilation**: The compiler should be able to compile a million lines of code within 1 sec.

## Syntax Overview

### Variable Bindings

Thor uses `=` or `let` / `const` for value declarations. Variables are statically typed (or type inferred) and immutable by default.

```odin
x : i32
x = 20

z :: "hello" // inferred type
w = fibonacci 987
z :: "hello" // inferred type
w := fibonacci 987

```

### Records and Data Layout (DOP)

Thor uses Odin-inspired syntax for `record`, emphasizing stack-allocated, high-performance data layouts.

```odin

Point :: record {
    x, y: f32
}

// Arrays of records are contiguous in memory
points : [Point]
points = [{x: 0.0, y: 0.0}, {x: 1.0, y: 1.0}]
```

### Functions and Procedures

Thor distinguishes between static pure functions and effectful procedures.

#### Static Pure Functions

Used for low-level, statically-typed, hardware-optimized, and **pure** code. Use the `func` keyword.

```odin
add : (i32, i32) -> i32
add = func a b {
    a + b
}

```

#### Static Procedures with Side Effects

Used for low-level, statically-typed, hardware-optimized code that involves **side effects**. Use the `proc` keyword.

```odin
print_add : (i32, i32) -> () | IO.Write
print_add : proc a b {
    res = a + b
    printf("Result: %d\n", res)
}

print_add :: proc(a i32, b i32){
    res = a + b
    printf("Result: %d\n", res)
}

```

### Control Flow: If-Else

`if` statements are expressions and return a value. Parentheses around the condition are optional.

```odin
result = if n < 1 {
    a
} else {
    b
}
```

For single line:

```odin
result = if n < 1 then a else b
```

### Recursion and Iteration

To adhere to the recursive theory model, standard recursion is replaced by the `recur` primitive for tail-call optimization.

```odin
fib : (i32, i32, i32) -> i32
fib = func a b n {
    if n < 1 then a
    else recur(b, a + b, n - 1)
}

fib :: func(a, b, n i32) i32 {
    recur(b, a + b, n - 1) unless
    case n < 1 then a 
}

fib a b n = recur(b, a + b, n - 1) unless {
    case n < 1 then a 
}

```

### Pipe Operator

Thor includes a pipe operator `|>` for fluent composition:

```odin
value = data |> process(x, y, z) |> finalize(z);
```

### Atoms and Collections

- **Atoms**: Prefixed identifiers (e.g., `:symbol`) that evaluate to themselves.
- **Arrays**: Array literals `[...]`.
- **Tuples**: Tuple literals `(a, b)`.
- **Maps**: Map literals `{key: value}`.
- **Sets**: Set literals `#{1, 2, 3}`.

```odin
my_array := [1, 2, 3]
my_atom  := :ok
my_tuple := (1, 2)
my_set   := #{1, 2, 3}
my_map   := {key: value, key2: value2}
```

## Compiler Integration

Thor is implemented in Odin within the `lang/thor` directory.

- **Lexer**: `thor.odin` (WASM-specific tokens).
- **Parser**: `parser.odin` (Recursive descent).
- **AST**: `ast.odin` (Abstract Syntax Tree nodes).
- **Codegen**: Compiles to WASM or Native code via the Rekursion VM.

## Reference Rules

1. Use `_` only in function or variable names.
2. Data types should use PascalCase without underscores (e.g., `PairIndex`).
3. Immutability is the default; use mutation only as an optimization.
4. Forbid general recursion; use `recur` for tail-calls.
5. Prioritize Arrays (DOP) over Lists where performance is critical.
6. Use `Point :: record { ... }` (Odin-style) for cache-friendly data structures.
7. Use `func` for static, pure, hardware-optimized functions.
8. Use `proc` for static, hardware-optimized code with side effects.
