#include "thor.hpp"

gb_internal void thor_check_global_variable_access(CheckerContext *ctx, Ast *expr, Entity *entity) {
	if (ctx == nullptr || entity == nullptr) {
		return;
	}
	if (!ctx->in_pure_func) {
		return;
	}
	if (entity->Variable.is_global || (entity->flags & EntityFlag_Static) != 0) {
		error(expr, "Cannot access mutable global variable '%.*s' inside a pure function", LIT(entity->token.string));
	}
}

gb_internal void thor_check_call_purity(CheckerContext *ctx, Ast *call, Ast *proc_expr, Type *proc_type) {
	if (ctx == nullptr || proc_type == nullptr) {
		return;
	}
	if (!ctx->in_pure_func) {
		return;
	}
	if (proc_type->kind == Type_Proc && !proc_type->Proc.is_pure) {
		gbString proc_str = expr_to_string(proc_expr);
		error(call, "Cannot call impure procedure '%s' inside a pure function", proc_str);
		gb_string_free(proc_str);
	}
}

gb_internal bool thor_check_context_access(CheckerContext *ctx, Ast *node) {
	if (ctx == nullptr) {
		return false;
	}
	if (!ctx->in_pure_func) {
		return false;
	}
	error(node, "Cannot access 'context' inside a pure function");
	return true;
}

gb_internal bool thor_check_assignment_purity(CheckerContext *ctx, Ast *node, Operand *lhs) {
	if (ctx == nullptr || lhs == nullptr) {
		return true;
	}
	if (!ctx->in_pure_func) {
		return true;
	}

	Ast *lhs_expr = unparen_expr(lhs->expr);
	if (lhs_expr->kind == Ast_DerefExpr) {
		error(lhs->expr, "Cannot mutate memory through raw pointer inside a pure function (only slices may be mutated)");
		return false;
	} else if (lhs_expr->kind == Ast_IndexExpr) {
		Type *indexed_type = base_type(type_of_expr(lhs_expr->IndexExpr.expr));
		if (indexed_type != nullptr && (is_type_pointer(indexed_type) || is_type_multi_pointer(indexed_type))) {
			error(lhs->expr, "Cannot mutate memory through raw pointer inside a pure function (only slices may be mutated)");
			return false;
		}
	}

	Entity *var_e = entity_from_expr(lhs->expr);
	if (var_e == nullptr && node != nullptr && node->kind == Ast_Ident) {
		var_e = scope_lookup(ctx->scope, node->Ident.interned, node->Ident.hash);
	}
	if (var_e != nullptr && var_e->kind == Entity_Variable && (var_e->flags & EntityFlag_Field) == 0) {
		if (var_e->Variable.is_global || (var_e->flags & EntityFlag_Static) != 0) {
			error(lhs->expr, "Cannot mutate global variable '%.*s' inside a pure function", LIT(var_e->token.string));
			return false;
		}
	}

	return true;
}

gb_internal void thor_check_param_type_purity(CheckerContext *ctx, bool is_pure, Entity *param) {
	if (param == nullptr) {
		return;
	}
	if (is_pure && is_type_dynamic_array(param->type)) {
		error(param->token, "Dynamic array types are forbidden in 'func' signatures; use slice '[]T' instead");
	}
}

gb_internal void thor_check_result_type_purity(CheckerContext *ctx, bool is_pure, Entity *result) {
	if (result == nullptr) {
		return;
	}
	if (is_pure && is_type_dynamic_array(result->type)) {
		error(result->token, "Dynamic array types are forbidden in 'func' signatures; use slice '[]T' instead");
	}
}
