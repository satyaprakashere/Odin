package thor_interop

import "core:fmt"

// Verify that 'func' is still usable as a normal variable name in .odin files
calculate :: proc(func: int) -> int {
	return square(func) + cube(func)
}

main :: proc() {
	res := calculate(3)
	fmt.printfln("Result: %d", res)
	assert(res == 9 + 27)
	fmt.println("Thor-Odin mixed package test passed!")
}
