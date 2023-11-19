%{
#include <stdio.h>
#include "lib.h"

void yyerror(char *s);
int yydebug = 1;
int success = 1;
%}

%token IFDEF IFNDEF ELIF ENDIF INCLUDE DEFINE UNDEF LINE ERROR PRAGMA
%token HSEQ NEW_LINE

%token AUTO REGISTER STATIC EXTERN TYPEDEF
%token TYPE_SPECIFIER TYPE_QUALIFIER STRUCT_OR_UNION
%token IDENTIFIER
%token INT_CONST CHAR_CONST FLOAT_CONST STRING

%token RETURN IF ELSE WHILE FOR SWITCH CASE DEFAULT BREAK CONTINUE GOTO ENUM DO INLINE
%token ELLIPSIS

%left ','
%right AND_EQ OR_EQ XOR_EQ
%right LEFT_EQ RIGHT_EQ
%right MULT_EQ DIV_EQ MOD_EQ
%right ADD_EQ SUB_EQ
%right '='
%right '?' ':'
%left OR_OP
%left AND_OP
%left '|'
%left '^'
%left '&'
%left EQ_OP NE_OP
%left '<' '>' LE_OP GE_OP
%left LEFT_SHIFT RIGHT_SHIFT
%left '+' '-'
%left '*' '/' '%'
%right SIZEOF
%right '!' '~'
%right INC_OP DEC_OP
%left ARROW
%left '.'

%%
program: 
        preprocessing translation_unit 
        ;

constant: 
          INT_CONST
        | CHAR_CONST
        | FLOAT_CONST
        | enum_const
        ;

enum_const: 
        IDENTIFIER
        ;

/* EXPRESSIONS */

primary_expression: 
          IDENTIFIER
        | constant
        | STRING
        | '(' expression ')'
        ;

postfix_expression: 
          primary_expression
        | postfix_expression '[' expression ']'
        | postfix_expression '(' argument_expression_list ')'
        | postfix_expression '(' ')'
        | postfix_expression '.' IDENTIFIER
        | postfix_expression ARROW IDENTIFIER
        | postfix_expression INC_OP
        | postfix_expression DEC_OP
        | '(' type_name ')' '{' initializer_list '}'
        | '(' type_name ')' '{' initializer_list ',' '}'
        ;

argument_expression_list:
          assignment_expression
        | argument_expression_list ',' assignment_expression
        ;

unary_expression: 
          postfix_expression
        | INC_OP unary_expression
        | DEC_OP unary_expression
        | unary_operator cast_expression
        | SIZEOF unary_expression
        | SIZEOF '(' type_name ')'
        ;

unary_operator: 
        '&' | '*' | '+' | '-' | '~' | '!'
        ;

cast_expression: 
          unary_expression
        | '(' type_name ')' cast_expression
        ;

multiplicative_expression: 
          cast_expression
        | multiplicative_expression '*' cast_expression
        | multiplicative_expression '/' cast_expression
        | multiplicative_expression '%' cast_expression
        ;

additive_expression: 
          multiplicative_expression
        | additive_expression '+' multiplicative_expression
        | additive_expression '-' multiplicative_expression
        ;

shift_expression: 
          additive_expression
        | shift_expression LEFT_SHIFT additive_expression
        | shift_expression RIGHT_SHIFT additive_expression
        ;

relational_expression: 
          shift_expression
        | relational_expression '<' shift_expression
        | relational_expression '>' shift_expression
        | relational_expression LE_OP shift_expression
        | relational_expression GE_OP shift_expression
        ;

equality_expression: 
          relational_expression
        | equality_expression EQ_OP relational_expression
        | equality_expression NE_OP relational_expression
        ;

and_expression: 
          equality_expression
        | and_expression '&' equality_expression
        ;

exclusive_or_expression: 
          and_expression
        | exclusive_or_expression '^' and_expression
        ;

inclusive_or_expression: 
          exclusive_or_expression
        | inclusive_or_expression '|' exclusive_or_expression
        ;

logical_and_expression: 
          inclusive_or_expression
        | logical_and_expression AND_OP inclusive_or_expression
        ;

logical_or_expression: 
          logical_and_expression
        | logical_or_expression OR_OP logical_and_expression
        ;

conditional_expression: 
          logical_or_expression
        | logical_or_expression '?' expression ':' conditional_expression
        ;

assignment_expression: 
          conditional_expression
        | unary_expression assigment_operator assignment_expression
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
          assignment_expression
        | expression ',' assignment_expression
        ;

constant_expression: 
        conditional_expression
        ;

/* DECLARATIONS */

declaration: 
        declaration_specifiers init_declarator_list ';'
        declaration_specifiers ';'
        ;

declaration_specifiers:
          storage_class_specifier
        | type_specifier
        | TYPE_QUALIFIER
        | function_specifier
        | declaration_specifiers storage_class_specifier
        | declaration_specifiers type_specifier
        | declaration_specifiers TYPE_QUALIFIER
        | declaration_specifiers function_specifier
        ;

init_declarator_list:
          init_declarator
        | init_declarator_list ',' init_declarator
        ;

init_declarator: 
          declarator
        | declarator '=' initializer
        ;

storage_class_specifier:
          AUTO
        | REGISTER
        | STATIC
        | EXTERN
        | TYPEDEF
        ;

type_specifier: 
          TYPE_SPECIFIER 
        | struct_or_union_specifier
        | enum_specifier
        | typedef_name
        ;

struct_or_union_specifier: 
          STRUCT_OR_UNION '{' struct_declaration_list '}'
        | STRUCT_OR_UNION IDENTIFIER '{' struct_declaration_list '}'
        | STRUCT_OR_UNION IDENTIFIER
        ;

struct_declaration_list: 
          struct_declaration
        | struct_declaration_list struct_declaration
        ;

struct_declaration: 
        specifier_qualifier_list struct_declarator_list ';'
        ;

specifier_qualifier_list: 
          type_specifier
        | TYPE_QUALIFIER
        | type_specifier specifier_qualifier_list
        | TYPE_QUALIFIER specifier_qualifier_list
        ;

struct_declarator_list: 
          struct_declarator
        | struct_declarator_list ',' struct_declarator
        ;

struct_declarator: 
          declarator
        | ':' constant_expression
        | declarator ':' constant_expression
        ;

enum_specifier: 
        ENUM IDENTIFIER '{' enumerator_list '}'
        | ENUM '{' enumerator_list '}'
        | ENUM IDENTIFIER '{' enumerator_list ',' '}'
        | ENUM '{' enumerator_list ',' '}'
        | ENUM IDENTIFIER
        ;

enumerator_list: 
          enumerator
        | enumerator_list ',' enumerator
        ;

enumerator: 
          enum_const
        | enum_const '=' constant_expression
        ;

function_specifier: 
        INLINE 
        ;

declarator: 
          pointer direct_declarator
        | direct_declarator
        ;

direct_declarator: 
          IDENTIFIER
        | '(' declarator ')'
        | direct_declarator '[' ']'
        | direct_declarator '[' type_qualifier_list assignment_expression ']'
        | direct_declarator '[' type_qualifier_list ']'
        | direct_declarator '[' assignment_expression ']'
        | direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
        | direct_declarator '[' STATIC assignment_expression ']'
        | direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
        | direct_declarator '[' type_qualifier_list '*' ']'
        | direct_declarator '[' '*' ']'
        | direct_declarator '(' parameter_type_list ')'
        | direct_declarator '(' identifier_list ')'
        | direct_declarator '(' ')'
        ;

pointer: 
          '*'
        | '*' type_qualifier_list
        | '*' pointer
        | '*' type_qualifier_list pointer
        ;

type_qualifier_list: 
          TYPE_QUALIFIER
        | type_qualifier_list TYPE_QUALIFIER
        ;

parameter_type_list: 
          parameter_list
        | parameter_list ',' ELLIPSIS
        ;

parameter_list: 
          parameter_declaration
        | parameter_list ',' parameter_declaration
        ;

parameter_declaration: 
          declaration_specifiers declarator
        | declaration_specifiers abstract_declarator
        | declaration_specifiers
        ;

identifier_list: 
          IDENTIFIER
        | identifier_list ',' IDENTIFIER 
        ;

type_name: 
          specifier_qualifier_list
        | specifier_qualifier_list abstract_declarator
        ;

abstract_declarator: 
          pointer
        | pointer direct_abstract_declarator
        | direct_abstract_declarator
        ;

direct_abstract_declarator: 
          '(' abstract_declarator ')'
        | direct_abstract_declarator '[' assignment_expression ']'
        | '[' assignment_expression ']'
        | direct_abstract_declarator '[' ']'
        | '[' ']'
        | direct_abstract_declarator '(' parameter_type_list ')'
        | '(' parameter_type_list ')'
        | direct_abstract_declarator '(' ')'
        | '(' ')'
        | direct_abstract_declarator '[' '*' ']'
        | '[' '*' ']'
        ;

typedef_name: 
        IDENTIFIER
        ;

initializer: 
          assignment_expression
        | '{' initializer_list '}'
        | '{' initializer_list ',' '}'
        ;

initializer_list: 
          designation initializer
        | initializer
        | initializer_list ',' designation initializer
        | initializer_list ',' initializer
        ;

designation:
        designator_list '='
        ;

designator_list: 
          designator
        | designator_list designator
        ;

designator:
          '[' constant_expression ']'
        | '.' IDENTIFIER
        ;

/* STATEMENTS */

statement: 
          labeled_statement
        | compound_statement
        | expression_statement
        | selection_statement
        | iteration_statement
        | jump_statement
        ;

labeled_statement: 
        IDENTIFIER ':' statement
        | CASE constant_expression ':' statement
        | DEFAULT ':' statement
        ;

compound_statement: 
          '{' block_item_list '}'
        | '{' '}'
        ;

block_item_list:
          block_item
        | block_item_list block_item
        ;

block_item: 
          declaration
        | statement
        ;

expression_statement: 
          ';'
        | expression ';'
        ;

selection_statement: 
          IF '(' expression ')' statement
        | IF '(' expression ')' statement ELSE statement
        | SWITCH '(' expression ')' statement
        ;

iteration_statement: 
          WHILE '(' expression ')' statement
        | DO statement WHILE '(' expression ')' ';'
        | FOR '(' expression ';' expression ';' expression ')' statement
        | FOR '(' expression ';' expression ';' ')' statement
        | FOR '(' expression ';' ';' expression ')' statement
        | FOR '(' ';' expression ';' expression ')' statement
        | FOR '(' expression ';' ';' ')' statement
        | FOR '(' ';' ';' expression ')' statement
        | FOR '(' ';' expression ';' ')' statement
        | FOR '(' ';' ';' ')' statement
        | FOR '(' declaration expression ';' expression ')' statement
        | FOR '(' declaration expression ';' ')' statement
        | FOR '(' declaration ';' expression ')' statement
        | FOR '(' declaration ';' ')' statement
        ;

jump_statement: 
          GOTO IDENTIFIER ';'
        | CONTINUE ';'
        | BREAK ';'
        | RETURN expression ';'
        | RETURN ';'
        ;

/* EXTERNAL DEFINITIONS */

translation_unit: 
          external_declaration
        | translation_unit external_declaration
        ;

external_declaration: 
          function_definition 
        | declaration
        ;

function_definition: 
          declaration_specifiers declarator declaration_list compound_statement 
        | declaration_specifiers declarator compound_statement 
        ;

declaration_list:
          declaration
        | declaration_list declaration
        ;

/* PREPROCESSING DIRECTIVES */

preprocessing: 
        | group
        ;

group: 
          group_part
        | group group_part
        ;

group_part: 
          if_section
        | control_line
        | text_line
        | '#' non_directive
        ;

if_section: 
        if_group elif_groups else_group endif_line 
        if_group elif_groups endif_line 
        if_group else_group endif_line 
        if_group endif_line 
        ;

if_group: 
          '#' IF constant_expression NEW_LINE group
        | '#' IFDEF IDENTIFIER NEW_LINE group
        | '#' IFNDEF IDENTIFIER NEW_LINE group
        ;

elif_groups: 
          elif_group
        | elif_groups elif_group
        ;

elif_group: 
        '#' ELIF constant_expression NEW_LINE group
        ;

else_group: 
        '#' ELSE NEW_LINE group 
        ;

endif_line: 
        '#' ENDIF NEW_LINE 
        ;

control_line: 
          '#' INCLUDE pp_tokens NEW_LINE
        | '#' DEFINE IDENTIFIER replacement_list NEW_LINE
        | '#' DEFINE IDENTIFIER '(' identifier_list ')' replacement_list NEW_LINE
        | '#' DEFINE IDENTIFIER '(' ')' replacement_list NEW_LINE
        | '#' DEFINE IDENTIFIER '(' ELLIPSIS ')' replacement_list NEW_LINE
        | '#' DEFINE IDENTIFIER '(' identifier_list ',' ELLIPSIS ')' replacement_list NEW_LINE
        | '#' UNDEF IDENTIFIER NEW_LINE
        | '#' LINE pp_tokens NEW_LINE
        | '#' ERROR pp_tokens NEW_LINE
        | '#' ERROR NEW_LINE
        | '#' PRAGMA pp_tokens NEW_LINE
        | '#' PRAGMA NEW_LINE
        | '#' NEW_LINE
        ;

text_line: 
          pp_tokens NEW_LINE 
        | NEW_LINE 
        ;

non_directive: 
        pp_tokens NEW_LINE 
        ;

replacement_list: 
        | pp_tokens 
        ;

pp_tokens: 
          preprocessing_token
        | pp_tokens preprocessing_token
        ;

preprocessing_token: 
          HSEQ 
        | IDENTIFIER 
        | CHAR_CONST 
        | STRING
        | punctuator
        | INT_CONST
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
    if (success) printf("Parsed successfully!\n");
    return 0;
}
