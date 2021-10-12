## META 1

**ALEXY**

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
- [ ] semicolons_1 > PROBLEMA: os tokens que precisam de SEMICOLON, se estivermos no EOF e não houver mais nada à frente, não existe nada para pôr um SEMICOLON à frente
- [ ] semicolons_2

**MIGUEL**

- [ ] resto dos testes

**SUBMISSÕES**

- [ ] B Empty/blank files 2/5
- [ ] C Identifiers and keywords 16/20
- [x] D Operators, brackets and punctuation marks 10/10
- [x] E Plain text 10/10
- [ ] F Comments 10/15
- [ ] G Numeric, char and real literals 20/30
- [ ] H Illegal characters 0/20
- [x] I Unterminated comments 10/10
- [ ] J Invalid or unterminated string literals 0/20
- [ ] K Automatic Insertion of Semicolons 12/20
- [ ] L Miscellaneous 16/25

## META 2

## NOTAS

^[^\n]*$   {yycolumnno += (strlen(yytext)); REJECT;} <br>
./compile.sh deiGo.l gocompiler <br>
./gocompiler -l < lextests/text_1.dgo | colordiff --strip-trailing-cr lextests/text_2.out -
