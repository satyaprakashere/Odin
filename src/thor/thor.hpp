#ifndef THOR_HPP
#define THOR_HPP

// Language dialect definitions
enum LanguageDialect : u8 {
	Dialect_Odin = 0,
	Dialect_Thor = 1,
};

gb_global LanguageDialect global_default_dialect = Dialect_Odin;

gb_internal bool is_thor_keyword(TokenKind kind);
gb_internal bool path_is_thor_dialect(String const &fullpath);

#endif // THOR_HPP
