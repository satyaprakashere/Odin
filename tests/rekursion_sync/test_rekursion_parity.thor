package rekursion_sync

import "core:fmt"
import "thor:math"
import "thor:types"

Point :: struct {
	x, y: f32,
}

Circle :: struct {
	radius: f32,
}

Rectangle :: struct {
	width, height: f32,
}

Shape :: union {
	Circle,
	Rectangle,
}

// Pure function using func
add :: func(a, b: int) -> int {
	return a + b
}

// Pure calculation of shape area
area :: func(shape: Shape) -> f32 {
	switch s in shape {
	case Circle:
		return 3.14159265 * s.radius * s.radius
	case Rectangle:
		return s.width * s.height
	}
	return 0.0
}

// Pure point distance squared
distance_sq :: func(p1, p2: Point) -> f32 {
	dx := p1.x - p2.x
	dy := p1.y - p2.y
	return dx*dx + dy*dy
}

main :: proc() {
	fmt.println("=== Rekursion Thor Parity Test Suite ===")

	// 1. Pure addition test
	sum := add(10, 20)
	assert(sum == 30)
	fmt.println("[PASS] Pure func add:", sum)

	// 2. Thor standard library math algorithms
	fact5 := math.factorial(5)
	assert(fact5 == 120)
	fmt.println("[PASS] Pure math.factorial(5):", fact5)

	fib10 := math.fibonacci(10)
	assert(fib10 == 55)
	fmt.println("[PASS] Pure math.fibonacci(10):", fib10)

	// 3. DOP Struct layout & pure calculation
	p1 := Point{0.0, 0.0}
	p2 := Point{3.0, 4.0}
	d2 := distance_sq(p1, p2)
	assert(d2 == 25.0)
	fmt.println("[PASS] Pure distance_sq:", d2)

	// 4. Tagged union & shape area
	c := Shape(Circle{radius = 2.0})
	r := Shape(Rectangle{width = 4.0, height = 5.0})
	c_area := area(c)
	r_area := area(r)
	assert(r_area == 20.0)
	fmt.println("[PASS] Pure area Circle:", c_area)
	fmt.println("[PASS] Pure area Rectangle:", r_area)

	// 5. Container types from thor:
	res := types.make_result(sum)
	assert(res.ok == true)
	assert(res.value == 30)
	fmt.println("[PASS] PureResult container:", res.value)

	fmt.println("All Rekursion/Thor parity tests completed successfully!")
}
