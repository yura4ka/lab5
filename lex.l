%{
#include "y.tab.h"
#include <stdio.h>
%}

DIGIT [0-9]
HEX_DIGIT [0-9a-fA-F]

%%
"ifdef" {printf("%s\n", yytext); return IFDEF; }
"ifndef" {printf("%s\n", yytext); return IFNDEF; }
"elif" {printf("%s\n", yytext); return ELIF; }
"endif" {printf("%s\n", yytext); return ENDIF; }
"include" {printf("%s\n", yytext); return INCLUDE; }
"define" {printf("%s\n", yytext); return DEFINE; }
"line" {printf("%s\n", yytext); return LINE; }
"error" {printf("%s\n", yytext); return ERROR; }
"pragma" {printf("%s\n", yytext); return PRAGMA; }

"void"|"char"|"short"|"int"|"long"|"float"|"double"|"signed"|"unsigned" {printf("%s\n", yytext); return TYPE_SPECIFIER; }
"const"|"volatile"|"restrict" {printf("%s\n", yytext); return TYPE_QUALIFIER; }
"struct"|"union" {printf("%s\n", yytext); return STRUCT_OR_UNION; }
"auto" {printf("%s\n", yytext); return AUTO; }
"register" {printf("%s\n", yytext); return REGISTER; }
"static" {printf("%s\n", yytext); return STATIC; }
"extern" {printf("%s\n", yytext); return EXTERN; }
"typedef" {printf("%s\n", yytext); return TYPEDEF; }
"return" {printf("%s\n", yytext); return RETURN; }
"if" {printf("%s\n", yytext); return IF; }
"else" {printf("%s\n", yytext); return ELSE; }
"while" {printf("%s\n", yytext); return WHILE; }
"for" {printf("%s\n", yytext); return FOR; }
"switch" {printf("%s\n", yytext); return SWITCH; }
"case" {printf("%s\n", yytext); return CASE; }
"default" {printf("%s\n", yytext); return DEFAULT; }
"break" {printf("%s\n", yytext); return BREAK; }
"continue" {printf("%s\n", yytext); return CONTINUE; }
"goto" {printf("%s\n", yytext); return GOTO; }
"sizeof" {printf("%s\n", yytext); return SIZEOF; }
"enum" {printf("%s\n", yytext); return ENUM; }
"inline" {printf("%s\n", yytext); return INLINE; }
"#" {printf("%s\n", yytext); return '#'; }
"{" {printf("%s\n", yytext); return '{'; }
"}" {printf("%s\n", yytext); return '}'; }
"(" {printf("%s\n", yytext); return '('; }
")" {printf("%s\n", yytext); return ')'; }
"[" {printf("%s\n", yytext); return '['; }
"]" {printf("%s\n", yytext); return ']'; }
";" {printf("%s\n", yytext); return ';'; }
"," {printf("%s\n", yytext); return ','; }
"+" {printf("%s\n", yytext); return '+'; }
"-" {printf("%s\n", yytext); return '-'; }
"*" {printf("%s\n", yytext); return '*'; }
"/" {printf("%s\n", yytext); return '/'; }
"%" {printf("%s\n", yytext); return '%'; }
"<" {printf("%s\n", yytext); return '<'; }
">" {printf("%s\n", yytext); return '>'; }
"&" {printf("%s\n", yytext); return '&'; }
"^" {printf("%s\n", yytext); return '^'; }
"|" {printf("%s\n", yytext); return '|'; }
"!" {printf("%s\n", yytext); return '!'; }
"~" {printf("%s\n", yytext); return '~'; }
"?" {printf("%s\n", yytext); return '?'; }
":" {printf("%s\n", yytext); return ':'; }
"." {printf("%s\n", yytext); return '.'; }
"=" {printf("%s\n", yytext); return '='; }
"++" {printf("%s\n", yytext); return INC_OP; }
"--" {printf("%s\n", yytext); return DEC_OP; }
"==" {printf("%s\n", yytext); return EQ_OP; }
"!=" {printf("%s\n", yytext); return NE_OP; }
"<=" {printf("%s\n", yytext); return LE_OP; }
">=" {printf("%s\n", yytext); return GE_OP; }
"<<" {printf("%s\n", yytext); return LEFT_SHIFT; }
">>" {printf("%s\n", yytext); return RIGHT_SHIFT; }
"&&" {printf("%s\n", yytext); return AND_OP; }
"||" {printf("%s\n", yytext); return OR_OP; }
"..." {printf("%s\n", yytext); return ELLIPSIS; }
"->" {printf("%s\n", yytext); return ARROW; }
"*=" {printf("%s\n", yytext); return MULT_EQ; }
"/=" {printf("%s\n", yytext); return DIV_EQ; }
"%=" {printf("%s\n", yytext); return MOD_EQ; }
"+=" {printf("%s\n", yytext); return ADD_EQ; }
"-=" {printf("%s\n", yytext); return SUB_EQ; }
"<<=" {printf("%s\n", yytext); return LEFT_EQ; }
">>=" {printf("%s\n", yytext); return RIGHT_EQ; }
"&=" { printf("%s\n", yytext); return AND_EQ; }
"^=" {printf("%s\n", yytext); return XOR_EQ; }
"|=" {printf("%s\n", yytext); return OR_EQ; }

"<"[^>\n]+">" {printf("hseq: %s\n", yytext); return HSEQ; }
[a-zA-Z_]+[a-zA-Z0-9_]* {printf("%s\n", yytext); return IDENTIFIER; }
(((({DIGIT}*\.{DIGIT}+|{DIGIT}+\.)([eE]([+-]?{DIGIT}+)?)?)|([1-9]{DIGIT}*[eE][+-]?\d+))([fFlL]?))|(0[xX]((({HEX_DIGIT}*\.{HEX_DIGIT}+|{HEX_DIGIT}+\.)|({HEX_DIGIT}+))[pP][+-]?{DIGIT}+[flFL]?)) {printf("%s\n", yytext); return FLOAT_CONST; }
((0[xX]{HEX_DIGIT}+)|([1-9]{DIGIT}*)|(0[0-7]*))([uU](ll|LL)|(ll|LL)[uU]?|[uU][lL]?|[lL][uU]?)? {printf("%s\n", yytext); return INT_CONST; }
\'([^'\\]|\\['"?\\abfnrtv])\' {printf("c: %s\n", yytext); return CHAR_CONST; }
\"([^"\\]|\\['"?\\abfnrtv])*\" {printf("str: %s\n", yytext); return STRING; }
[ \t\n] ;
%%

int yywrap(void) {
  return 1;
}