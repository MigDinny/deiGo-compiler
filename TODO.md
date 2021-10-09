- [x] fazer reallit e testar
- [ ] fazer strlit e testar
- [ ] tratar sequências de escape não especificadas no strlit
- [x] emitir um ; nas 4 regras previstas no enunciado. eu já o fiz para as ultimas 3 e para o INTLIT, falta para o REALLIT E STRLIT
- [x] fazer comments
- [ ] fazer tratamento de erros


para guardar

^[^\n]*$   {yycolumnno += (strlen(yytext)); REJECT;}
