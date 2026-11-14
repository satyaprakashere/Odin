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

// Forward declarations for Odin compiler types used in Thor semantic checking
struct CheckerContext;
struct Ast;
struct Entity;
struct Type;
struct Operand;

// Thor semantic purity validations
gb_internal void thor_check_global_variable_access(CheckerContext *ctx, Ast *expr, Entity *entity);
gb_internal void thor_check_call_purity(CheckerContext *ctx, Ast *call, Ast *proc_expr, Type *proc_type);
gb_internal bool thor_check_context_access(CheckerContext *ctx, Ast *node);
gb_internal bool thor_check_assignment_purity(CheckerContext *ctx, Ast *node, Operand *lhs);
gb_internal void thor_check_param_type_purity(CheckerContext *ctx, bool is_pure, Entity *param);
gb_internal void thor_check_result_type_purity(CheckerContext *ctx, bool is_pure, Entity *result);

#endif // THOR_HPP
