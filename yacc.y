%{
#include <stdio.h>
#include "lib.h"

void yyerror(char *s);
int success = 1;

Node* head;
%}

%union {
    Node *node;
};

%token <node> AUTO REGISTER STATIC EXTERN TYPEDEF
%token <node> TYPE_SPECIFIER TYPE_QUALIFIER STRUCT_OR_UNION
%token <node> IDENTIFIER
%token <node> INT_CONST CHAR_CONST FLOAT_CONST STRING

%token <node> IFDEF IFNDEF ELIF ENDIF INCLUDE DEFINE UNDEF LINE ERROR PRAGMA HSEQ 
%token <node> RETURN IF ELSE WHILE FOR SWITCH CASE DEFAULT BREAK CONTINUE GOTO ENUM DO INLINE
%token <node> ELLIPSIS
%token <node> '[' ']' '(' ')' '{' '}' '#' ';'

%left <node> ','
%right <node> AND_EQ OR_EQ XOR_EQ
%right <node> LEFT_EQ RIGHT_EQ
%right <node> MULT_EQ DIV_EQ MOD_EQ
%right <node> ADD_EQ SUB_EQ
%right <node> '='
%right <node> '?' ':'
%left <node> OR_OP
%left <node> AND_OP
%left <node> '|'
%left <node> '^'
%left <node> '&'
%left <node> EQ_OP NE_OP
%left <node> '<' '>' LE_OP GE_OP
%left <node> LEFT_SHIFT RIGHT_SHIFT
%left <node> '+' '-'
%left <node> '*' '/' '%'
%right <node> SIZEOF
%right <node> '!' '~'
%right <node> INC_OP DEC_OP
%left <node> ARROW
%left <node> '.'

%type <node> program constant enum_const primary_expression postfix_expression argument_expression_list 
%type <node> unary_expression unary_operator cast_expression multiplicative_expression additive_expression 
%type <node> shift_expression relational_expression equality_expression and_expression exclusive_or_expression 
%type <node> inclusive_or_expression logical_and_expression logical_or_expression conditional_expression
%type <node> assignment_expression assigment_operator expression constant_expression
%type <node> declaration declaration_specifiers init_declarator_list init_declarator storage_class_specifier
%type <node> type_specifier struct_or_union_specifier struct_declaration_list struct_declaration specifier_qualifier_list
%type <node> struct_declarator_list struct_declarator enum_specifier enumerator_list enumerator function_specifier declarator
%type <node> direct_declarator pointer type_qualifier_list parameter_type_list parameter_list parameter_declaration
%type <node> identifier_list type_name abstract_declarator direct_abstract_declarator typedef_name initializer initializer_list
%type <node> designation designator_list designator statement labeled_statement compound_statement block_item_list block_item
%type <node> expression_statement selection_statement iteration_statement jump_statement translation_unit external_declaration
%type <node> function_definition declaration_list
%type <node> preprocessing group group_part if_section if_group elif_groups elif_group
%type <node> else_group endif_line control_line replacement_list pp_tokens preprocessing_token punctuator

%%
program: 
          translation_unit                      { $$ = newNode("program", 1, $1); head = $$; }
        | preprocessing translation_unit        { $$ = newNode("program", 2, $1, $2); head = $$; }
        ;

constant: 
          INT_CONST                             { $$ = newNode("constant", 1, $1); }
        | CHAR_CONST                            { $$ = newNode("constant", 1, $1); }
        | FLOAT_CONST                           { $$ = newNode("constant", 1, $1); }
        | enum_const                            { $$ = newNode("constant", 1, $1); }
        ;

enum_const: 
        IDENTIFIER                              { $$ = newNode("enumeration-constant", 1, $1); }
        ;

/* EXPRESSIONS */

primary_expression: 
          IDENTIFIER                            { $$ = newNode("primary-expression", 1, $1); }
        | constant                              { $$ = newNode("primary-expression", 1, $1); }
        | STRING                                { $$ = newNode("primary-expression", 1, $1); }
        | '(' expression ')'                    { $$ = newNode("primary-expression", 3, $1, $2, $3); }
        ;

postfix_expression: 
          primary_expression                                    { $$ = newNode("postfix-expression", 1, $1); }
        | postfix_expression '[' expression ']'                 { $$ = newNode("postfix-expression", 4, $1, $2, $3, $4); }
        | postfix_expression '(' argument_expression_list ')'   { $$ = newNode("postfix-expression", 4, $1, $2, $3, $4); }
        | postfix_expression '(' ')'                            { $$ = newNode("postfix-expression", 3, $1, $2, $3); }
        | postfix_expression '.' IDENTIFIER                     { $$ = newNode("postfix-expression", 3, $1, $2, $3); }
        | postfix_expression ARROW IDENTIFIER                   { $$ = newNode("postfix-expression", 3, $1, $2, $3); }
        | postfix_expression INC_OP                             { $$ = newNode("postfix-expression", 2, $1, $2); }
        | postfix_expression DEC_OP                             { $$ = newNode("postfix-expression", 2, $1, $2); }
        | '(' type_name ')' '{' initializer_list '}'            { $$ = newNode("postfix-expression", 6, $1, $2, $3, $4, $5, $6); }
        | '(' type_name ')' '{' initializer_list ',' '}'        { $$ = newNode("postfix-expression", 7, $1, $2, $3, $4, $5, $6, $7); }
        ;

argument_expression_list:
          assignment_expression                                 { $$ = newNode("argument-expression-list", 1, $1); }
        | argument_expression_list ',' assignment_expression    { $$ = newNode("argument-expression-list", 3, $1, $2, $3); }
        ;

unary_expression: 
          postfix_expression                    { $$ = newNode("unary-expression", 1, $1); }
        | INC_OP unary_expression               { $$ = newNode("unary-expression", 2, $1, $2); }
        | DEC_OP unary_expression               { $$ = newNode("unary-expression", 2, $1, $2); }
        | unary_operator cast_expression        { $$ = newNode("unary-expression", 2, $1, $2); }
        | SIZEOF unary_expression               { $$ = newNode("unary-expression", 2, $1, $2); }
        | SIZEOF '(' type_name ')'              { $$ = newNode("unary-expression", 4, $1, $2, $3, $4); }
        ;

unary_operator: 
        '&' | '*' | '+' | '-' | '~' | '!'
        ;

cast_expression: 
          unary_expression                      { $$ = newNode("case-expression", 1, $1); }
        | '(' type_name ')' cast_expression     { $$ = newNode("case-expression", 4, $1, $2, $3, $4); }
        ;

multiplicative_expression: 
          cast_expression                                       { $$ = newNode("multiplicative-expression", 1, $1); }
        | multiplicative_expression '*' cast_expression         { $$ = newNode("multiplicative-expression", 3, $1, $2, $3); }
        | multiplicative_expression '/' cast_expression         { $$ = newNode("multiplicative-expression", 3, $1, $2, $3); }
        | multiplicative_expression '%' cast_expression         { $$ = newNode("multiplicative-expression", 3, $1, $2, $3); }
        ;

additive_expression: 
          multiplicative_expression                             { $$ = newNode("additive-expression", 1, $1); }
        | additive_expression '+' multiplicative_expression     { $$ = newNode("additive-expression", 3, $1, $2, $3); }
        | additive_expression '-' multiplicative_expression     { $$ = newNode("additive-expression", 3, $1, $2, $3); }
        ;

shift_expression: 
          additive_expression                                   { $$ = newNode("shift-expression", 1, $1); }
        | shift_expression LEFT_SHIFT additive_expression       { $$ = newNode("shift-expression", 3, $1, $2, $3); }
        | shift_expression RIGHT_SHIFT additive_expression      { $$ = newNode("shift-expression", 3, $1, $2, $3); }
        ;

relational_expression: 
          shift_expression                                      { $$ = newNode("relational-expression", 1, $1); }
        | relational_expression '<' shift_expression            { $$ = newNode("relational-expression", 3, $1, $2, $3); }
        | relational_expression '>' shift_expression            { $$ = newNode("relational-expression", 3, $1, $2, $3); }
        | relational_expression LE_OP shift_expression          { $$ = newNode("relational-expression", 3, $1, $2, $3); }
        | relational_expression GE_OP shift_expression          { $$ = newNode("relational-expression", 3, $1, $2, $3); }
        ;

equality_expression: 
          relational_expression                                 { $$ = newNode("equality-expression", 1, $1); }
        | equality_expression EQ_OP relational_expression       { $$ = newNode("equality-expression", 3, $1, $2, $3); }
        | equality_expression NE_OP relational_expression       { $$ = newNode("equality-expression", 3, $1, $2, $3); }
        ;

and_expression: 
          equality_expression                                   { $$ = newNode("and-expression", 1, $1); }
        | and_expression '&' equality_expression                { $$ = newNode("and-expression", 3, $1, $2, $3); }
        ;

exclusive_or_expression: 
          and_expression                                        { $$ = newNode("exclusive-or-expression", 1, $1); }
        | exclusive_or_expression '^' and_expression            { $$ = newNode("exclusive-or-expression", 3, $1, $2, $3); }
        ;

inclusive_or_expression: 
          exclusive_or_expression                               { $$ = newNode("inclusive-or-expression", 1, $1); }
        | inclusive_or_expression '|' exclusive_or_expression   { $$ = newNode("inclusive-or-expression", 3, $1, $2, $3); }
        ;

logical_and_expression: 
          inclusive_or_expression                               { $$ = newNode("logical-and-expression", 1, $1); }
        | logical_and_expression AND_OP inclusive_or_expression { $$ = newNode("logical-and-expression", 3, $1, $2, $3); }
        ;

logical_or_expression: 
          logical_and_expression                                { $$ = newNode("logical-or-expression", 1, $1); }
        | logical_or_expression OR_OP logical_and_expression    { $$ = newNode("logical-or-expression", 3, $1, $2, $3); }
        ;

conditional_expression: 
          logical_or_expression                                 { $$ = newNode("conditional-expression", 1, $1); }
        | logical_or_expression '?' expression ':' conditional_expression
                                                                { $$ = newNode("conditional-expression", 5, $1, $2, $3, $4, $5); }
        ;

assignment_expression: 
          conditional_expression                                { $$ = newNode("assignment-expression", 1, $1); }
        | unary_expression assigment_operator assignment_expression
                                                                { $$ = newNode("assignment-expression", 3, $1, $2, $3); }
        ;

assigment_operator: 
          '=' 
        | MULT_EQ 
        | DIV_EQ 
        | MOD_EQ 
        | ADD_EQ 
        | SUB_EQ 
        | LEFT_EQ
        | RIGHT_EQ
        | AND_EQ
        | XOR_EQ
        | OR_EQ
        ;

expression: 
          assignment_expression                                 { $$ = newNode("expression", 1, $1); }
        | expression ',' assignment_expression                  { $$ = newNode("expression", 3, $1, $2, $3); }
        ;

constant_expression: 
        conditional_expression                                  { $$ = newNode("constant-expression", 1, $1); }
        ;

/* DECLARATIONS */

declaration: 
          declaration_specifiers ';'                            { $$ = newNode("declaration", 2, $1, $2); }
        | declaration_specifiers init_declarator_list ';'       { $$ = newNode("declaration", 3, $1, $2, $3); }
        ;

declaration_specifiers:
          storage_class_specifier                               { $$ = newNode("declaration-specifiers", 1, $1); }
        | type_specifier                                        { $$ = newNode("declaration-specifiers", 1, $1); }
        | TYPE_QUALIFIER                                        { $$ = newNode("declaration-specifiers", 1, $1); }
        | function_specifier                                    { $$ = newNode("declaration-specifiers", 1, $1); }
        | declaration_specifiers storage_class_specifier        { $$ = newNode("declaration-specifiers", 2, $1, $2); }
        | declaration_specifiers type_specifier                 { $$ = newNode("declaration-specifiers", 2, $1, $2); }
        | declaration_specifiers TYPE_QUALIFIER                 { $$ = newNode("declaration-specifiers", 2, $1, $2); }
        | declaration_specifiers function_specifier             { $$ = newNode("declaration-specifiers", 2, $1, $2); }
        ;

init_declarator_list:
          init_declarator                                       { $$ = newNode("init-declarator-list", 1, $1); }
        | init_declarator_list ',' init_declarator              { $$ = newNode("init-declarator-list", 3, $1, $2, $3); }
        ;

init_declarator: 
          declarator                                            { $$ = newNode("init-declarator", 1, $1); }
        | declarator '=' initializer                            { $$ = newNode("init-declarator", 3, $1, $2, $3); }
        ;

storage_class_specifier:
          AUTO                                                  { $$ = newNode("storage-class-specifier", 1, $1); }
        | REGISTER                                              { $$ = newNode("storage-class-specifier", 1, $1); }
        | STATIC                                                { $$ = newNode("storage-class-specifier", 1, $1); }
        | EXTERN                                                { $$ = newNode("storage-class-specifier", 1, $1); }
        | TYPEDEF                                               { $$ = newNode("storage-class-specifier", 1, $1); }
        ;

type_specifier: 
          TYPE_SPECIFIER                                        { $$ = newNode("type-specifier", 1, $1); }
        | struct_or_union_specifier                             { $$ = newNode("type-specifier", 1, $1); }
        | enum_specifier                                        { $$ = newNode("type-specifier", 1, $1); }
        | typedef_name                                          { $$ = newNode("type-specifier", 1, $1); }
        ;

struct_or_union_specifier: 
          STRUCT_OR_UNION '{' struct_declaration_list '}'       { $$ = newNode("struct-or-union-specifier", 4, $1, $2, $3, $4); }
        | STRUCT_OR_UNION IDENTIFIER                            { $$ = newNode("struct-or-union-specifier", 2, $1, $2); }
        | STRUCT_OR_UNION IDENTIFIER '{' struct_declaration_list '}'
                                                                { $$ = newNode("struct-or-union-specifier", 5, $1, $2, $3, $4, $5); }
        ;

struct_declaration_list: 
          struct_declaration                                    { $$ = newNode("struct-declaration-list", 1, $1); }
        | struct_declaration_list struct_declaration            { $$ = newNode("struct-declaration-list", 2, $1, $2); }
        ;

struct_declaration: 
        specifier_qualifier_list struct_declarator_list ';'     { $$ = newNode("struct-declaration", 3, $1, $2, $3); }
        ;

specifier_qualifier_list: 
          type_specifier                                        { $$ = newNode("specifier-qualifier-list", 1, $1); }
        | TYPE_QUALIFIER                                        { $$ = newNode("specifier-qualifier-list", 1, $1); }
        | type_specifier specifier_qualifier_list               { $$ = newNode("specifier-qualifier-list", 2, $1, $2); }
        | TYPE_QUALIFIER specifier_qualifier_list               { $$ = newNode("specifier-qualifier-list", 2, $1, $2); }
        ;

struct_declarator_list: 
          struct_declarator                                     { $$ = newNode("struct-declarator-list", 3, $1); }
        | struct_declarator_list ',' struct_declarator          { $$ = newNode("struct-declarator-list", 3, $1, $2, $3); }
        ;

struct_declarator: 
          declarator                                            { $$ = newNode("struct-declarator", 1, $1); }
        | ':' constant_expression                               { $$ = newNode("struct-declarator", 2, $1, $2); }
        | declarator ':' constant_expression                    { $$ = newNode("struct-declarator", 3, $1, $2, $3); }
        ;

enum_specifier: 
          ENUM IDENTIFIER '{' enumerator_list '}'               { $$ = newNode("enum-specifier", 5, $1, $2, $3, $4, $5); }
        | ENUM '{' enumerator_list '}'                          { $$ = newNode("enum-specifier", 4, $1, $2, $3, $4); }
        | ENUM IDENTIFIER '{' enumerator_list ',' '}'           { $$ = newNode("enum-specifier", 6, $1, $2, $3, $4, $5, $6); }
        | ENUM '{' enumerator_list ',' '}'                      { $$ = newNode("enum-specifier", 5, $1, $2, $3, $4, $5); }
        | ENUM IDENTIFIER                                       { $$ = newNode("enum-specifier", 2, $1, $2); }
        ;

enumerator_list: 
          enumerator                                            { $$ = newNode("enumerator-list", 1); }
        | enumerator_list ',' enumerator                        { $$ = newNode("enumerator-list", 3, $1, $2, $3); }
        ;

enumerator: 
          enum_const                                            { $$ = newNode("enumerator", 1, $1); }
        | enum_const '=' constant_expression                    { $$ = newNode("enumerator", 3, $1, $2, $3); }
        ;

function_specifier: 
        INLINE                                                  { $$ = newNode("function-specifier", 1, $1); }
        ;

declarator: 
          pointer direct_declarator                             { $$ = newNode("declarator", 2, $1, $2); }              
        | direct_declarator                                     { $$ = newNode("declarator", 1, $1); }
        ;

direct_declarator: 
          IDENTIFIER                                            { $$ = newNode("direct-declarator", 1, $1); } 
        | '(' declarator ')'                                    { $$ = newNode("direct-declarator", 3, $1, $2, $3); } 
        | direct_declarator '[' ']'                             { $$ = newNode("direct-declarator", 3, $1, $2, $3); }
        | direct_declarator '[' type_qualifier_list assignment_expression ']'
                                                                { $$ = newNode("direct-declarator", 5, $1, $2, $3, $4, $5); }
        | direct_declarator '[' type_qualifier_list ']'         { $$ = newNode("direct-declarator", 4, $1, $2, $3, $4); }
        | direct_declarator '[' assignment_expression ']'       { $$ = newNode("direct-declarator", 4, $1, $2, $3, $4); }
        | direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
                                                                { $$ = newNode("direct-declarator", 6, $1, $2, $3, $4, $5, $6); }
        | direct_declarator '[' STATIC assignment_expression ']'
                                                                { $$ = newNode("direct-declarator", 5, $1, $2, $3, $4, $5); }
        | direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
                                                                { $$ = newNode("direct-declarator", 6, $1, $2, $3, $4, $5, $6); }
        | direct_declarator '[' type_qualifier_list '*' ']'
                                                                { $$ = newNode("direct-declarator", 5, $1, $2, $3, $4, $5); }
        | direct_declarator '[' '*' ']'                         { $$ = newNode("direct-declarator", 4, $1, $2, $3, $4); }
        | direct_declarator '(' parameter_type_list ')'         { $$ = newNode("direct-declarator", 4, $1, $2, $3, $4); }
        | direct_declarator '(' identifier_list ')'             { $$ = newNode("direct-declarator", 4, $1, $2, $3, $4); }
        | direct_declarator '(' ')'                             { $$ = newNode("direct-declarator", 3, $1, $2, $3); }
        ;

pointer: 
          '*'                                                   { $$ = newNode("pointer", 1, $1); }
        | '*' type_qualifier_list                               { $$ = newNode("pointer", 2, $1, $2); }
        | '*' pointer                                           { $$ = newNode("pointer", 1, $1); }
        | '*' type_qualifier_list pointer                       { $$ = newNode("pointer", 3, $1, $2, $3); }
        ;

type_qualifier_list: 
          TYPE_QUALIFIER                                        { $$ = newNode("type-qualifier-list", 1, $1); }
        | type_qualifier_list TYPE_QUALIFIER                    { $$ = newNode("type-qualifier-list", 2, $1, $2); }
        ;

parameter_type_list: 
          parameter_list                                        { $$ = newNode("parameter-type-list", 1, $1); }
        | parameter_list ',' ELLIPSIS                           { $$ = newNode("parameter-type-list", 3, $1, $2, $3); }
        ;

parameter_list: 
          parameter_declaration                                 { $$ = newNode("parameter-list", 1, $1); }
        | parameter_list ',' parameter_declaration              { $$ = newNode("parameter-list", 3, $1, $2, $3); }
        ;

parameter_declaration: 
          declaration_specifiers declarator                     { $$ = newNode("parameter-declaration", 2, $1, $2); }
        | declaration_specifiers abstract_declarator            { $$ = newNode("parameter-declaration", 2, $1, $2); }
        | declaration_specifiers                                { $$ = newNode("parameter-declaration", 1, $1); }
        ;

identifier_list: 
          IDENTIFIER                                            { $$ = newNode("identifier-list", 1, $1); }
        | identifier_list ',' IDENTIFIER                        { $$ = newNode("identifier-list", 3, $1, $2, $3); }
        ;

type_name: 
          specifier_qualifier_list                              { $$ = newNode("type-name", 1, $1); }
        | specifier_qualifier_list abstract_declarator          { $$ = newNode("type-name", 2, $1, $2); }
        ;

abstract_declarator: 
          pointer                                               { $$ = newNode("abstract-declarator", 1, $1); }
        | pointer direct_abstract_declarator                    { $$ = newNode("abstract-declarator", 2, $1, $2); }
        | direct_abstract_declarator                            { $$ = newNode("abstract-declarator", 1, $1); }
        ;

direct_abstract_declarator: 
          '(' abstract_declarator ')'                           { $$ = newNode("direct-abstract-declarator", 3, $1, $2, $3); }
        | direct_abstract_declarator '[' assignment_expression ']'
                                                                { $$ = newNode("direct-abstract-declarator", 4, $1, $2, $3, $4); }
        | '[' assignment_expression ']'                         { $$ = newNode("direct-abstract-declarator", 3, $1, $2, $3); }
        | direct_abstract_declarator '[' ']'                    { $$ = newNode("direct-abstract-declarator", 3, $1, $2, $3); }
        | '[' ']'                                               { $$ = newNode("direct-abstract-declarator", 2, $1, $2); }
        | direct_abstract_declarator '(' parameter_type_list ')'
                                                                { $$ = newNode("direct-abstract-declarator", 4, $1, $2, $4); }
        | '(' parameter_type_list ')'                           { $$ = newNode("direct-abstract-declarator", 3, $1, $2, $3); }
        | direct_abstract_declarator '(' ')'                    { $$ = newNode("direct-abstract-declarator", 3, $1, $2, $3); }
        | '(' ')'                                               { $$ = newNode("direct-abstract-declarator", 2, $1, $2); }
        | direct_abstract_declarator '[' '*' ']'                { $$ = newNode("direct-abstract-declarator", 4, $1, $2, $3, $4); }
        | '[' '*' ']'                                           { $$ = newNode("direct-abstract-declarator", 3, $1, $2, $3); }
        ;

typedef_name: 
        IDENTIFIER                                              { $$ = newNode("typedef-name", 1, $1); }
        ;

initializer: 
          assignment_expression                                 { $$ = newNode("initializer", 1, $1); }
        | '{' initializer_list '}'                              { $$ = newNode("initializer", 3, $1, $2, $3); }
        | '{' initializer_list ',' '}'                          { $$ = newNode("initializer", 4, $1, $2, $3, $4); }
        ;

initializer_list: 
          designation initializer                               { $$ = newNode("initializer-list", 1, $1); }
        | initializer                                           { $$ = newNode("initializer-list", 1, $1); }
        | initializer_list ',' designation initializer          { $$ = newNode("initializer-list", 4, $1, $2, $3, $4); }
        | initializer_list ',' initializer                      { $$ = newNode("initializer-list", 3, $1, $2, $3); }
        ;

designation:
        designator_list '='                                     { $$ = newNode("designation", 2, $1, $2); }
        ;

designator_list: 
          designator                                            { $$ = newNode("designator-list", 1, $1); }
        | designator_list designator                            { $$ = newNode("designator-list", 2, $1, $2); }
        ;

designator:
          '[' constant_expression ']'                           { $$ = newNode("designator", 3, $1, $2, $3); }
        | '.' IDENTIFIER                                        { $$ = newNode("designator", 2, $1, $2); }
        ;

/* STATEMENTS */

statement: 
          labeled_statement                                     { $$ = newNode("statement", 1, $1); }
        | compound_statement                                    { $$ = newNode("statement", 1, $1); }
        | expression_statement                                  { $$ = newNode("statement", 1, $1); }
        | selection_statement                                   { $$ = newNode("statement", 1, $1); }
        | iteration_statement                                   { $$ = newNode("statement", 1, $1); }
        | jump_statement                                        { $$ = newNode("statement", 1, $1); }
        ;

labeled_statement: 
          IDENTIFIER ':' statement                              { $$ = newNode("labeled-statement", 3, $1, $2, $3); }
        | CASE constant_expression ':' statement                { $$ = newNode("labeled-statement", 4, $1, $2, $3, $4); }
        | DEFAULT ':' statement                                 { $$ = newNode("labeled-statement", 3, $1, $2, $3); }
        ;

compound_statement: 
          '{' block_item_list '}'                               { $$ = newNode("compound-statement", 3, $1, $2, $3); }
        | '{' '}'                                               { $$ = newNode("compound-statement", 2, $1, $2); }
        ;

block_item_list:
          block_item                                            { $$ = newNode("block-item-list", 1, $1); }
        | block_item_list block_item                            { $$ = newNode("block-item-list", 2, $1, $2); }
        ;

block_item: 
          declaration                                           { $$ = newNode("block-item", 1, $1); }
        | statement                                             { $$ = newNode("block-item", 1, $1); }
        ;

expression_statement: 
          ';'                                                   { $$ = newNode("expression-statement", 1, $1); }
        | expression ';'                                        { $$ = newNode("expression-statement", 2, $1, $2); }
        ;

selection_statement: 
          IF '(' expression ')' statement                       { $$ = newNode("selection-statement", 5, $1, $2, $3, $4, $5); }
        | IF '(' expression ')' statement ELSE statement        { $$ = newNode("selection-statement", 7, $1, $2, $3, $4, $5, $6, $7); }
        | SWITCH '(' expression ')' statement                   { $$ = newNode("selection-statement", 5, $1, $2, $3, $4, $5); }
        ;

iteration_statement: 
          WHILE '(' expression ')' statement
                                                { $$ = newNode("iteration-statement", 5, $1, $2, $3, $4, $5); }
        | DO statement WHILE '(' expression ')' ';'
                                                { $$ = newNode("iteration-statement", 7, $1, $2, $3, $4, $5, $6, $7); }
        | FOR '(' expression ';' expression ';' expression ')' statement
                                                { $$ = newNode("iteration-statement", 9, $1, $2, $3, $4, $5, $6, $7, $8, $9); }
        | FOR '(' expression ';' expression ';' ')' statement
                                                { $$ = newNode("iteration-statement", 8, $1, $2, $3, $4, $5, $6, $7, $8); }
        | FOR '(' expression ';' ';' expression ')' statement
                                                { $$ = newNode("iteration-statement", 8, $1, $2, $3, $4, $5, $6, $7, $8); }
        | FOR '(' ';' expression ';' expression ')' statement
                                                { $$ = newNode("iteration-statement", 8, $1, $2, $3, $4, $5, $6, $7, $8); }
        | FOR '(' expression ';' ';' ')' statement
                                                { $$ = newNode("iteration-statement", 7, $1, $2, $3, $4, $5, $6, $7); }
        | FOR '(' ';' ';' expression ')' statement
                                                { $$ = newNode("iteration-statement", 7, $1, $2, $3, $4, $5, $6, $7); }
        | FOR '(' ';' expression ';' ')' statement
                                                { $$ = newNode("iteration-statement", 7, $1, $2, $3, $4, $5, $6, $7); }
        | FOR '(' ';' ';' ')' statement
                                                { $$ = newNode("iteration-statement", 6, $1, $2, $3, $4, $5, $6); }
        | FOR '(' declaration expression ';' expression ')' statement
                                                { $$ = newNode("iteration-statement", 8, $1, $2, $3, $4, $5, $6, $7, $8); }
        | FOR '(' declaration expression ';' ')' statement
                                                { $$ = newNode("iteration-statement", 7, $1, $2, $3, $4, $5, $6, $7); }
        | FOR '(' declaration ';' expression ')' statement
                                                { $$ = newNode("iteration-statement", 7, $1, $2, $3, $4, $5, $6, $7); }
        | FOR '(' declaration ';' ')' statement
                                                { $$ = newNode("iteration-statement", 6, $1, $2, $3, $4, $5, $6); }
        ;

jump_statement: 
          GOTO IDENTIFIER ';'                                   { $$ = newNode("jump-statement", 3, $1, $2, $3); }
        | CONTINUE ';'                                          { $$ = newNode("jump-statement", 2, $1, $2); }
        | BREAK ';'                                             { $$ = newNode("jump-statement", 2, $1, $2); }
        | RETURN expression ';'                                 { $$ = newNode("jump-statement", 3, $1, $2, $3); }
        | RETURN ';'                                            { $$ = newNode("jump-statement", 2, $1, $2); }
        ;

/* EXTERNAL DEFINITIONS */

translation_unit: 
          external_declaration                                  { $$ = newNode("translation-unit", 1, $1); }
        | translation_unit external_declaration                 { $$ = newNode("translation-unit", 2, $1, $2); }
        ;

external_declaration: 
          function_definition                                   { $$ = newNode("external-declaration", 1, $1); }
        | declaration                                           { $$ = newNode("external-declaration", 1, $1); }
        ;

function_definition: 
          declaration_specifiers declarator declaration_list compound_statement
                                                                { $$ = newNode("function-definition", 4, $1, $2, $3, $4); }
        ;

declaration_list:
                                                                { $$ = newNode("declaration-list", 0); }
        | declaration_list declaration                          { $$ = newNode("declaration-list", 2, $1, $2); }
        ;

/* PREPROCESSING DIRECTIVES */

preprocessing: 
        group                                                   { $$ = newNode("preprocessing", 1, $1); }
        ;

group: 
          group_part                                            { $$ = newNode("group", 1, $1); }
        | group group_part                                      { $$ = newNode("group", 2, $1, $2); }
        ;

group_part: 
          if_section                                            { $$ = newNode("group-part", 1, $1); }
        | control_line                                          { $$ = newNode("group-part", 1, $1); }
        | pp_tokens                                             { $$ = newNode("group-part", 1, $1); }
        | '#' pp_tokens                                         { $$ = newNode("group-part", 2, $1, $2); }
        ;

if_section: 
          if_group elif_groups else_group endif_line            { $$ = newNode("if-section", 4, $1, $2, $3, $4); }
        | if_group elif_groups endif_line                       { $$ = newNode("if-section", 3, $1, $2, $3); }
        | if_group else_group endif_line                        { $$ = newNode("if-section", 3, $1, $2, $3); }
        | if_group endif_line                                   { $$ = newNode("if-section", 2, $1, $2); }
        ;

if_group: 
          '#' IF constant_expression group                      { $$ = newNode("if-group", 4, $1, $2, $3, $4); }
        | '#' IFDEF IDENTIFIER group                            { $$ = newNode("if-group", 4, $1, $2, $3, $4); }
        | '#' IFNDEF IDENTIFIER group                           { $$ = newNode("if-group", 4, $1, $2, $3, $4); }
        ;

elif_groups: 
          elif_group                                            { $$ = newNode("elif-groups", 1, $1); }
        | elif_groups elif_group                                { $$ = newNode("elif-groups", 2, $1, $2); }
        ;

elif_group: 
        '#' ELIF constant_expression group                      { $$ = newNode("elif-group", 4, $1, $2, $3, $4); }
        ;

else_group: 
        '#' ELSE group                                          { $$ = newNode("else-group", 3, $1, $2, $3); }
        ;

endif_line: 
        '#' ENDIF                                               { $$ = newNode("endif-group", 2, $1, $2); }
        ;

control_line: 
          '#' INCLUDE pp_tokens                                 { $$ = newNode("control-line", 3, $1, $2, $3); }
        | '#' DEFINE IDENTIFIER replacement_list                { $$ = newNode("control-line", 4, $1, $2, $3, $4); }
        | '#' DEFINE IDENTIFIER '(' identifier_list ')' replacement_list 
                                                                { $$ = newNode("control-line", 7, $1, $2, $3, $4, $5, $6, $7); }
        | '#' DEFINE IDENTIFIER '(' ')' replacement_list        { $$ = newNode("control-line", 6, $1, $2, $3, $4, $5, $6); }
        | '#' DEFINE IDENTIFIER '(' ELLIPSIS ')' replacement_list 
                                                                { $$ = newNode("control-line", 7, $1, $2, $3, $4, $5, $6, $7); }
        | '#' DEFINE IDENTIFIER '(' identifier_list ',' ELLIPSIS ')' replacement_list 
                                                                { $$ = newNode("control-line", 8, $1, $2, $3, $4, $5, $6, $7, $8); }
        | '#' UNDEF IDENTIFIER                                  { $$ = newNode("control-line", 3, $1, $2, $3); }
        | '#' LINE pp_tokens                                    { $$ = newNode("control-line", 3, $1, $2, $3); }
        | '#' ERROR pp_tokens                                   { $$ = newNode("control-line", 3, $1, $2, $3); }
        | '#' ERROR                                             { $$ = newNode("control-line", 2, $1, $2); }
        | '#' PRAGMA pp_tokens                                  { $$ = newNode("control-line", 3, $1, $2, $3); }
        | '#' PRAGMA                                            { $$ = newNode("control-line", 2, $1, $2); }
        | '#'                                                   { $$ = newNode("control-line", 1, $1); }
        ;

replacement_list: 
                                                                { $$ = newNode("replacement-list", 0); }
        | pp_tokens                                             { $$ = newNode("replacement-list", 1, $1); }
        ;

pp_tokens: 
          preprocessing_token                                   { $$ = newNode("pp-tokens", 1, $1); }
        | pp_tokens preprocessing_token                         { $$ = newNode("pp-tokens", 1, $1); }
        ;

preprocessing_token: 
          HSEQ                                                  { $$ = newNode("preprocessing-token", 1, $1); }
        | IDENTIFIER                                            { $$ = newNode("preprocessing-token", 1, $1); }
        | CHAR_CONST                                            { $$ = newNode("preprocessing-token", 1, $1); }
        | STRING                                                { $$ = newNode("preprocessing-token", 1, $1); }
        | punctuator                                            { $$ = newNode("preprocessing-token", 1, $1); }
        | INT_CONST                                             { $$ = newNode("preprocessing-token", 1, $1); }
        ;

punctuator: 
          '[' | ']' | '(' | ')' | '{' | '}' | '.' | ARROW
        | INC_OP | DEC_OP | '&' | '*' | '+' | '-' | '~' | '!'
        | '/' | '%' | LEFT_SHIFT | RIGHT_SHIFT | '^' | '|' | AND_OP | OR_OP
        | '<' | '>' | LE_OP | GE_OP | EQ_OP | NE_OP
        | '?' | ':' | ';' | ELLIPSIS 
        | '=' | MULT_EQ | DIV_EQ | MOD_EQ | ADD_EQ | SUB_EQ 
        | LEFT_EQ | RIGHT_EQ | AND_EQ | XOR_EQ | OR_EQ 
        | ',' | '#'
        ;

%%

void yyerror(char* s) {
    extern int yylineno;
    fprintf(stderr, "line %d: %s\n", yylineno, s);
    success = 0;
}

int main() {
    yyparse();
    if (!success) return 0;
    printf("Parsed successfully!\nCreating AST...\n");
    createTreeOutput(head);
    return 0;
}
