package thor_math

// factorial returns n! computed purely without side effects.
factorial :: func(n: int) -> int {
	if n <= 1 do return 1
	result := 1
	for i in 2..=n {
		result *= i
	}
	return result
}

// fibonacci returns the nth Fibonacci number.
fibonacci :: func(n: int) -> int {
	if n <= 0 do return 0
	if n == 1 do return 1
	a, b := 0, 1
	for i in 2..=n {
		a, b = b, a + b
	}
	return b
}

// gcd computes the greatest common divisor using Euclid's algorithm.
gcd :: func(a, b: int) -> int {
	x, y := a, b
	for y != 0 {
		x, y = y, x % y
	}
	return x < 0 ? -x : x
}

// square returns x * x.
square :: func(x: int) -> int {
	return x * x
}

// cube returns x * x * x.
cube :: func(x: int) -> int {
	return x * x * x
}
