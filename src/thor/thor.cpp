#include "thor.hpp"

gb_internal bool is_thor_keyword(TokenKind kind) {
	switch (kind) {
	case Token_func:
		return true;
	default:
		return false;
	}
}

// Strict extension-based separation (like .c vs .cpp):
// .thor files are ALWAYS Thor language.
// .odin files are ALWAYS strict Odin language.
gb_internal bool path_is_thor_dialect(String const &fullpath) {
	if (string_ends_with(fullpath, str_lit(".thor"))) {
		return true;
	}
	return false;
}
