package main

import "core:fmt"

main :: proc() {
	fmt.println("Building Odin project with Thor!")
}

compute :: proc(func: int) -> int {
	return func * 10
}
