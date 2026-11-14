package rekursion_sync

// Synced reference from rekursion/lang/thor/source.thor
// Validates Thor language constructs in the native compiler frontend

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

FileFlag :: enum {
	Read,
	Write,
}

FileFlags :: bit_set[FileFlag]

UserId :: distinct i32

// Pure function definition with func keyword
add_two :: func(a, b: int) -> int {
	return a + b
}

// Pure math computation
calculate_area :: func(shape: Shape) -> f32 {
	switch s in shape {
	case Circle:
		return 3.14159 * s.radius * s.radius
	case Rectangle:
		return s.width * s.height
	}
	return 0.0
}

// Side-effectful procedure definition with proc
cleanup_draw :: proc() {
}

draw_shapes :: proc() {
	defer cleanup_draw()
	arr := [4]int{10, 20, 30, 40}
	val := arr[0]
	_ = val
}
