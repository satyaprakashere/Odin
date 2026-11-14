# Thor Grammar Specification (EBNF)

This document defines the formal grammar of the Thor language using Extended Backus-Naur Form (EBNF).

## Program Structure

```ebnf
program    = { top_level_statement } ;

top_level_statement = import_stmt
                    | export_stmt
                    | statement ;
```

## Modules

```ebnf
import_stmt = "import" , ( identifier | "{" , identifier_list , "}" ) , "from" , string ;

export_stmt = "export" , ( declaration | variable_binding ) ;
```

## Declarations and Bindings

Thor enforces immutability by default (for bindings) and distinguishes between type signatures (using `:`), static definitions (using `::`), and dynamic bindings (using `=`).

```ebnf
declaration = type_signature
            | static_definition
            | variable_binding
            | function_decl
            | struct_decl
            | class_decl ;

(* Type signature *)
type_signature = identifier , ":" , type_expr ;

(* Static Odin-style definitions *)
static_definition = identifier , "::" , ( static_func | static_proc | struct_body | union_body | bit_set_body | distinct_body ) ;
static_func = "func" , "(" , [ parameter_list ] , ")" , [ "->" , type_expr ] , block ;
static_proc = "proc" , "(" , [ parameter_list ] , ")" , [ "->" , type_expr ] , block ;

(* Variable bindings and Definitions *)
variable_binding = [ "const" | "let" ] , binding_pattern , ( "=" | "<-" ) , expression ;

(* Note: "::" is the idiomatic Odin-style syntax for defining static func/proc/struct/union. *)
(* "=" is also supported for backwards compatibility: name = func(...) { ... }. *)
(* "<-" is used for awaiting JS promises and for calling static WASM functions. *)

binding_pattern = identifier
                | object_pattern
                | array_pattern
                | tuple_pattern ;

object_pattern  = "{" , [ rest_identifier_list ] , "}" ;
array_pattern   = "[" , [ rest_identifier_list ] , "]" ;
tuple_pattern   = "(" , identifier_list , ")" ;

rest_identifier_list = identifier { "," , identifier } [ "," , "..." , identifier ]
                     | "..." , identifier ;

(* Functions and Procedures *)
function_decl = [ "async" ] , "function" , identifier , "(" , [ parameter_list ] , ")" , block
              | identifier , ( "::" | "=" ) , [ "async" ] , ( "func" | "proc" ) , "(" , [ parameter_list ] , ")" , [ "->" , type_expr ] , block ;

(* Data Structures *)
struct_decl   = identifier , ( "::" | "=" ) , "struct" , "{" , { struct_field } , "}" ;

class_decl    = "class" , identifier , [ "extends" , identifier ] , "{" , { class_member } , "}" ;

class_member  = [ "async" ] , identifier , "(" , [ parameter_list ] , ")" , block ;

(* Go-style fields (no colons) *)
struct_field  = identifier_list , type_expr , [ "," ] ;

identifier_list = identifier { "," , identifier } ;

parameter_list = identifier { "," , identifier } ;
```

## Control Flow

```ebnf
if_stmt = "if" , expression , ( block | "then" , expression [ "else" , expression ] ) , [ "else" , block ] ;

return_stmt = "return" , expression ;

block = "{" , { statement } , "}" ;

statement = declaration
          | assignment
          | expression_stmt
          | if_stmt
          | block
          | return_stmt ;
```

## Expressions

```ebnf
expression = pipe_expr ;

pipe_expr = assignment_expr { ( "|>" | "|" ) , assignment_expr } ;

assignment_expr = logical_or_expr [ "=" , assignment_expr ] ;

logical_or_expr  = logical_and_expr { "||" , logical_and_expr } ;
logical_and_expr = nullish_coalescing_expr { "&&" , nullish_coalescing_expr } ;

nullish_coalescing_expr = bitwise_or_expr { "??" , bitwise_or_expr } ;

bitwise_or_expr  = bitwise_xor_expr { "|" , bitwise_xor_expr } ;
bitwise_xor_expr = bitwise_and_expr { "^" , bitwise_and_expr } ;
bitwise_and_expr = equality_expr { "&" , equality_expr } ;

equality_expr   = relational_expr { ( "==" | "!=" | "===" | "!==" ) , relational_expr } ;
relational_expr = shift_expr { ( "<" | ">" | "<=" | ">=" ) , shift_expr } ;
shift_expr      = additive_expr { ( "<<" | ">>" ) , additive_expr } ;

additive_expr       = multiplicative_expr { ( "+" | "-" ) , multiplicative_expr } ;
multiplicative_expr = prefix_expr { ( "*" | "/" ) , prefix_expr } ;

prefix_expr = { "!" | "~" | "-" | "await" | "<-" } , primary_expr ;

primary_expr = identifier
             | number
             | string
             | atom
             | "null"
             | "undefined"
             | "(" , expression , ")"
             | array_literal
             | tuple_literal
             | set_literal
             | map_literal
             | object_literal
             | template_literal
             | call_expr
             | optional_call_expr
             | member_access
             | optional_member_access
             | lambda_expr
             | func_literal
             | proc_literal
             | struct_literal
             | new_expr ;

new_expr = "new" , call_expr ;

call_expr = primary_expr , "(" , [ expression_list ] , ")" ;

optional_call_expr = primary_expr , "?." , "(" , [ expression_list ] , ")" ;

member_access = primary_expr , "." , identifier ;

optional_member_access = primary_expr , "?." , identifier ;

array_literal = "[" , [ spread_expression_list ] , "]" ;

tuple_literal = "(" , [ expression_list ] , ")" ;

set_literal   = "#" , "{" , [ expression_list ] , "}" 
              | "{" , [ expression_list ] , "}" ;

map_literal   = "{" , [ map_entry_list ] , "}" ;

map_entry_list = map_entry { "," , map_entry } ;
map_entry      = expression , expression
               | identifier , ":" , expression ;

func_literal = "func" , "(" , [ parameter_list ] , ")" , block ;
proc_literal = "proc" , "(" , [ parameter_list ] , ")" , block ;
struct_literal = "struct" , "{" , { struct_field } , "}" ;

object_literal = "{" , [ property_list ] , "}" ;

property_list = property { "," , property } ;
property      = identifier , ":" , expression
              | "..." , expression ;

spread_expression_list = spread_expression { "," , spread_expression } ;
spread_expression      = expression
                       | "..." , expression ;

template_literal = "`" , { string_part | "${" , expression , "}" } , "`" ;

lambda_expr = [ "async" ] , ( identifier | "(" , [ parameter_list ] , ")" ) , "=>" , ( block | expression ) ;

expression_list = expression { "," , expression } ;
```

## Types

```ebnf
type_expr = curried_type | uncurried_type ;

uncurried_type = "(" , [ type_list ] , ")" , "->" , basic_type ;

curried_type = basic_type { "->" , basic_type } ;

type_list = type_expr { "," , type_expr } ;

basic_type = identifier               (* Basic types like i32, f32 *)
           | "[" , type_expr , "]"    (* Array types *)
           | "^" , type_expr          (* Pointer types *)
           | "(" , type_expr , ")" ;
```

## Lexical Elements

```ebnf
identifier = ( letter | "_" ) , { letter | digit | "_" | "?" | "!" } ;

atom       = ":" , identifier ;

number     = digit { digit } [ "." , { digit } ] ;

string     = "\"" , { any_character_except_quote } , "\"" ;

letter     = "a" | ... | "z" | "A" | ... | "Z" ;
digit      = "0" | ... | "9" ;
```
