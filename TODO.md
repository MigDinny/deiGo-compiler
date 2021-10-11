## META 1

ALEXY

- [x] blank_1
- [x] comments_1
- [x] comments_2
- [x] comments_bad_1
- [x] comments_bad_2
- [x] empty_1
- [x] factorial
- [x] ids_keywords1
- [x] ids_keywords2
- [x] ids_keywords3
- [ ] semicolons_1 > existe um erro com INT e ID(int)
- [ ] semicolons_2

MIGUEL

- [ ] resto
- [ ] colunas
- [ ] inserir valores das linhas e colunas nos erros
- [ ] passar pelos testes do Mooshak (momento de rezar)

## META 2

## NOTAS

^[^\n]*$   {yycolumnno += (strlen(yytext)); REJECT;} <br>
./compile.sh deiGo.l gocompiler <br>
./gocompiler -l < lextests/text_1.dgo | colordiff --strip-trailing-cr lextests/text_2.out -
