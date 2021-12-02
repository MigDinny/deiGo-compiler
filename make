flex deiGo.l && yacc -d deiGo.y && clang-7 -Wunused-variable -g -o gocompiler lex.yy.c y.tab.c functions.c
