package thor_interop

import "core:fmt"
import "thor:math"

// Verify that 'func' is still usable as a normal variable name in .odin files
calculate :: proc(func: int) -> int {
	return square(func) + cube(func)
}

main :: proc() {
	res := calculate(3)
	fmt.printfln("Local package square + cube: %d", res)
	assert(res == 9 + 27)

	fact := math.factorial(5)
	fmt.printfln("thor:math factorial(5): %d", fact)
	assert(fact == 120)

	fib := math.fibonacci(8)
	fmt.printfln("thor:math fibonacci(8): %d", fib)
	assert(fib == 21)

	fmt.println("All Thor-Odin interoperability assertions passed!")
}
