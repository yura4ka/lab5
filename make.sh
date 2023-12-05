yacc -d --debug --verbose yacc.y
lex lex.l
gcc lex.yy.c y.tab.c lib.c -o main