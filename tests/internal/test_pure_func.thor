package test_internal

import "core:fmt"
import "core:testing"

add :: func(a, b: int) -> int {
	return a + b
}

factorial :: func(n: int) -> int {
	result := 1
	for i in 1..=n {
		result *= i
	}
	return result
}

fibonacci :: func(n: int) -> int {
	if n <= 0 do return 0
	if n == 1 do return 1
	return fibonacci(n - 1) + fibonacci(n - 2)
}

bubble_sort :: func(items: []int) {
	n := len(items)
	for i in 0..<n {
		for j in 0..<n - i - 1 {
			if items[j] > items[j + 1] {
				items[j], items[j + 1] = items[j + 1], items[j]
			}
		}
	}
}

reverse_slice :: func(items: []$T) {
	i := 0
	j := len(items) - 1
	for i < j {
		items[i], items[j] = items[j], items[i]
		i += 1
		j -= 1
	}
}

read_ptr :: func(p: ^int) -> int {
	return p^
}

transform_pipeline :: func(s: []int) {
	bubble_sort(s)
	reverse_slice(s)
}

@(test)
test_pure_functions :: proc(t: ^testing.T) {
	testing.expect_value(t, add(10, 20), 30)
	testing.expect_value(t, factorial(5), 120)
	testing.expect_value(t, fibonacci(7), 13)

	val := 42
	testing.expect_value(t, read_ptr(&val), 42)

	data := [5]int{50, 20, 40, 10, 30}
	bubble_sort(data[:])
	testing.expect_value(t, data[0], 10)
	testing.expect_value(t, data[1], 20)
	testing.expect_value(t, data[2], 30)
	testing.expect_value(t, data[3], 40)
	testing.expect_value(t, data[4], 50)

	reverse_slice(data[:])
	testing.expect_value(t, data[0], 50)
	testing.expect_value(t, data[1], 40)
	testing.expect_value(t, data[2], 30)
	testing.expect_value(t, data[3], 20)
	testing.expect_value(t, data[4], 10)

	transform_pipeline(data[:])
	testing.expect_value(t, data[0], 50)
	testing.expect_value(t, data[1], 40)
	testing.expect_value(t, data[2], 30)
	testing.expect_value(t, data[3], 20)
	testing.expect_value(t, data[4], 10)
}

main :: proc() {
	fmt.println("Testing pure functions...")
	data := [5]int{50, 20, 40, 10, 30}
	bubble_sort(data[:])
	assert(data[0] == 10)
	assert(data[4] == 50)
	assert(add(15, 25) == 40)
	assert(factorial(6) == 720)
	assert(fibonacci(8) == 21)
	fmt.println("All pure function assertions passed!")
}
