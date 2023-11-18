%{
#include "y.tab.h"
%}

DIGIT [0-9]
HEX_DIGIT [0-9a-fA-F]

%%
"auto"|"register"|"static"|"extern"|"typedef" { return STORAGE_CLASS_SPECIFIER; }
"void"|"char"|"short"|"int"|"long"|"float"|"double"|"signed"|"unsigned" { return TYPE_SPECIFIER; }
"const"|"volatile" { return TYPE_QUALIFIER; }
"struct"|"union" { return STRUCT_OR_UNION; }
"return" { return RETURN; }
"if" { return IF; }
"else" { return ELSE; }
"while" { return WHILE; }
"for" { return FOR; }
"switch" { return SWITCH; }
"case" { return CASE; }
"default" { return DEFAULT; }
"break" { return BREAK; }
"continue" { return CONTINUE; }
"goto" { return GOTO; }
"sizeof" { return SIZEOF; }
"enum" { return ENUM; }
"{" { return '{'; }
"}" { return '}'; }
"(" { return '('; }
")" { return ')'; }
"[" { return '['; }
"]" { return ']'; }
";" { return ';'; }
"," { return ','; }
"+" { return '+'; }
"-" { return '-'; }
"*" { return '*'; }
"/" { return '/'; }
"%" { return '%'; }
"<" { return '<'; }
">" { return '>'; }
"&" { return '&'; }
"^" { return '^'; }
"|" { return '|'; }
"!" { return '!'; }
"~" { return '~'; }
"?" { return '?'; }
":" { return ':'; }
"." { return '.'; }
"++" { return INC_OP; }
"--" { return DEC_OP; }
"==" { return EQ_OP; }
"!=" { return NE_OP; }
"<=" { return LE_OP; }
">=" { return GE_OP; }
"<<" { return LEFT_SHIFT; }
">>" { return RIGHT_SHIFT; }
"&&" { return AND_OP; }
"||" { return OR_OP; }
"..." { return ELLIPSIS; }
"->" { return ARROW; }
"." { return DOT; }
"<<" { return LEFT_OP; }
">>" { return RIGHT_OP; }
"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|=" { return ASSIGN_OPERATOR; }

[a-zA-Z_]+[a-zA-Z0-9_]* { printf("id: %s\n", yytext); }
(((({DIGIT}*\.{DIGIT}+|{DIGIT}+\.)([eE]([+-]?{DIGIT}+)?)?)|([1-9]{DIGIT}*[eE][+-]?\d+))([fFlL]?))|(0[xX]((({HEX_DIGIT}*\.{HEX_DIGIT}+|{HEX_DIGIT}+\.)|({HEX_DIGIT}+))[pP][+-]?{DIGIT}+[flFL]?)) { return FLOAT_CONST; }
((0[xX]{HEX_DIGIT}+)|([1-9]{DIGIT}*)|(0[0-7]*))([uU](ll|LL)|(ll|LL)[uU]?|[uU][lL]?|[lL][uU]?)? { return INT_CONST; }
\'([^'\\]|\\['"?\\abfnrtv])\' { return CHAR_CONST; }
\"([^"\\]|\\['"?\\abfnrtv])*\" { return STRING; }
[ \t\n] ;
%%

int yywrap(void) {
  return 1;
}