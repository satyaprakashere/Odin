package rekursion_sync

import "core:fmt"

// Data types and signatures matching the output of rekursion/lang/thor/c_ingest.odin
BUFFER_SIZE :: 4096

Status :: enum {
	STATUS_OK  = 0,
	STATUS_ERR = 1,
}

CPoint :: struct {
	x: i32,
	y: i32,
}

// C-ingested pure function prototype
c_add :: func(a: i32, b: i32) -> i32 {
	return a + b
}

// C-ingested procedure prototype with pointer/buffer manipulation
process_buffer :: proc(name: string, out_val: ^i32) {
	if out_val != nil {
		out_val^ = i32(len(name))
	}
}

main :: proc() {
	fmt.println("=== Rekursion C-Ingest Compatibility Test ===")

	assert(BUFFER_SIZE == 4096)
	fmt.println("[PASS] Constant BUFFER_SIZE:", BUFFER_SIZE)

	s := Status.STATUS_OK
	assert(s == .STATUS_OK)
	fmt.println("[PASS] Enum Status:", s)

	pt := CPoint{x = 10, y = 20}
	assert(pt.x == 10 && pt.y == 20)
	fmt.println("[PASS] CPoint struct:", pt)

	sum := c_add(pt.x, pt.y)
	assert(sum == 30)
	fmt.println("[PASS] c_add pure func:", sum)

	val: i32 = 0
	process_buffer("test_name", &val)
	assert(val == 9)
	fmt.println("[PASS] process_buffer out_val:", val)

	fmt.println("All C-Ingest compatibility tests passed!")
}
