package thor_types

// PureResult represents a pure computation result with a success flag.
PureResult :: struct($T: typeid) {
	value: T,
	ok: bool,
}

// make_result creates a successful PureResult.
make_result :: func(val: $T) -> PureResult(T) {
	return PureResult(T){value = val, ok = true}
}

// make_error creates an unsuccessful PureResult.
make_error :: func($T: typeid) -> PureResult(T) {
	return PureResult(T){ok = false}
}
