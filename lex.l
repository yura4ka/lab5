%{
#include "lib.h"
#include "y.tab.h"
#include <stdio.h>
%}

DIGIT [0-9]
HEX_DIGIT [0-9a-fA-F]

%%
"void"|"char"|"short"|"int"|"long"|"float"|"double"|"signed"|"unsigned" { yylval.node = newNode(yytext, 0); return TYPE_SPECIFIER; }
"const"|"volatile"|"restrict" { yylval.node = newNodeLeaf("type-qualifier", yytext); return TYPE_QUALIFIER; }
"struct"|"union" { yylval.node = newNode(yytext, 0); return STRUCT_OR_UNION; }
"auto" { yylval.node = newNode(yytext, 0); return AUTO; }
"register" { yylval.node = newNode(yytext, 0); return REGISTER; }
"static" { yylval.node = newNode(yytext, 0); return STATIC; }
"extern" { yylval.node = newNode(yytext, 0); return EXTERN; }
"typedef" { yylval.node = newNode(yytext, 0); return TYPEDEF; }
"return" { yylval.node = newNode(yytext, 0); return RETURN; }
"if" { yylval.node = newNode(yytext, 0); return IF; }
"else" { yylval.node = newNode(yytext, 0); return ELSE; }
"while" { yylval.node = newNode(yytext, 0); return WHILE; }
"for" { yylval.node = newNode(yytext, 0); return FOR; }
"switch" { yylval.node = newNode(yytext, 0); return SWITCH; }
"case" { yylval.node = newNode(yytext, 0); return CASE; }
"default" { yylval.node = newNode(yytext, 0); return DEFAULT; }
"break" { yylval.node = newNode(yytext, 0); return BREAK; }
"continue" { yylval.node = newNode(yytext, 0); return CONTINUE; }
"goto" { yylval.node = newNode(yytext, 0); return GOTO; }
"sizeof" { yylval.node = newNode(yytext, 0); return SIZEOF; }
"enum" { yylval.node = newNode(yytext, 0); return ENUM; }
"inline" { yylval.node = newNode(yytext, 0); return INLINE; }
"ifdef" { yylval.node = newNode(yytext, 0); return IFDEF; }
"ifndef" { yylval.node = newNode(yytext, 0); return IFNDEF; }
"elif" { yylval.node = newNode(yytext, 0); return ELIF; }
"endif" { yylval.node = newNode(yytext, 0); return ENDIF; }
"include" { yylval.node = newNode(yytext, 0); return INCLUDE; }
"define" { yylval.node = newNode(yytext, 0); return DEFINE; }
"line" { yylval.node = newNode(yytext, 0); return LINE; }
"error" { yylval.node = newNode(yytext, 0); return ERROR; }
"pragma" { yylval.node = newNode(yytext, 0); return PRAGMA; }
"#"|"{"|"}"|"("|")"|"["|"]"|";"|","|"+"|"-"|"*"|"/"|"%"|"<"|">"|"&"|"^"|"|"|"!"|"~"|"?"|":"|"."|"=" { yylval.node = newNode(yytext, 0); return *yytext; }
"++" { yylval.node = newNode(yytext, 0); return INC_OP; }
"--" { yylval.node = newNode(yytext, 0); return DEC_OP; }
"==" { yylval.node = newNode(yytext, 0); return EQ_OP; }
"!=" { yylval.node = newNode(yytext, 0); return NE_OP; }
"<=" { yylval.node = newNode(yytext, 0); return LE_OP; }
">=" { yylval.node = newNode(yytext, 0); return GE_OP; }
"<<" { yylval.node = newNode(yytext, 0); return LEFT_SHIFT; }
">>" { yylval.node = newNode(yytext, 0); return RIGHT_SHIFT; }
"&&" { yylval.node = newNode(yytext, 0); return AND_OP; }
"||" { yylval.node = newNode(yytext, 0); return OR_OP; }
"..." { yylval.node = newNode(yytext, 0); return ELLIPSIS; }
"->" { yylval.node = newNode(yytext, 0); return ARROW; }
"*=" { yylval.node = newNode(yytext, 0); return MULT_EQ; }
"/=" { yylval.node = newNode(yytext, 0); return DIV_EQ; }
"%=" { yylval.node = newNode(yytext, 0); return MOD_EQ; }
"+=" { yylval.node = newNode(yytext, 0); return ADD_EQ; }
"-=" { yylval.node = newNode(yytext, 0); return SUB_EQ; }
"<<=" { yylval.node = newNode(yytext, 0); return LEFT_EQ; }
">>=" { yylval.node = newNode(yytext, 0); return RIGHT_EQ; }
"&=" { yylval.node = newNode(yytext, 0);  return AND_EQ; }
"^=" { yylval.node = newNode(yytext, 0); return XOR_EQ; }
"|=" { yylval.node = newNode(yytext, 0); return OR_EQ; }

"<"[^>\n]+">" { yylval.node = newNode(yytext, 0); return HSEQ; }
[a-zA-Z_]+[a-zA-Z0-9_]* { yylval.node = newNodeLeaf("identifier", yytext); return IDENTIFIER; }
(((({DIGIT}*\.{DIGIT}+|{DIGIT}+\.)([eE]([+-]?{DIGIT}+)?)?)|([1-9]{DIGIT}*[eE][+-]?\d+))([fFlL]?))|(0[xX]((({HEX_DIGIT}*\.{HEX_DIGIT}+|{HEX_DIGIT}+\.)|({HEX_DIGIT}+))[pP][+-]?{DIGIT}+[flFL]?)) { yylval.node = newNodeLeaf("float-constant", yytext); return FLOAT_CONST; }
((0[xX]{HEX_DIGIT}+)|([1-9]{DIGIT}*)|(0[0-7]*))([uU](ll|LL)|(ll|LL)[uU]?|[uU][lL]?|[lL][uU]?)? { yylval.node = newNodeLeaf("int-constant", yytext); return INT_CONST; }
\'([^'\\]|\\['"?\\abfnrtv])\' { yylval.node = newNodeLeaf("char-constant", yytext); return CHAR_CONST; }
\"([^"\\]|\\['"?\\abfnrtv])*\" { yylval.node = newNodeLeaf("string-literal", yytext); return STRING; }
[ \t\n] ;
%%

int yywrap(void) {
  return 1;
}