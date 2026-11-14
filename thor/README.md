# Thor Standard Library Collection (`thor:`)

The `thor:` library collection provides standard packages and pure functional algorithms for the **Thor** programming language dialect.

## Architecture

Packages in this collection are written using the Thor language (`.thor` files) and take advantage of Thor's compile-time guarantees, such as:
- Guaranteed side-effect-free execution for pure functions declared with `func`.
- Strict calling convention defaults (`contextless`).
- Zero mutable global state access.

## Available Packages

- `thor:math`: Pure mathematical algorithms (factorials, Fibonacci, GCD, LCM, matrix transformations, sorting).
- `thor:types`: Core type definitions and traits for Thor programs.

## Usage

In any `.thor` or `.odin` file:
```thor
package my_package

import "thor:math"
import "core:fmt"

main :: proc() {
    val := math.factorial(5)
    fmt.printfln("5! = %d", val)
}
```
