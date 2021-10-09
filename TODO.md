## META 1

- [x] fazer reallit e testar
- [x] fazer strlit e testar
- [x] tratar sequências de escape não especificadas no strlit
- [x] emitir um ; nas 4 regras previstas no enunciado. eu já o fiz para as ultimas 3 e para o INTLIT, falta para o REALLIT E STRLIT
- [x] fazer comments
- [x] fazer tratamento de erros
- [ ] colunas
- [ ] inserir valores das linhas e colunas nos erros
- [ ] passar pelos testes do Mooshak (momento de rezar)

## META 2

## NOTAS

^[^\n]*$   {yycolumnno += (strlen(yytext)); REJECT;}
