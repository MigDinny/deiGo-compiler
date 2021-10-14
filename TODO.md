## META 1

**SUBMISSÕES**

- [ ] F Comments 10/15
- [ ] I Unterminated comments 0/10
- [ ] J Invalid or unterminated string literals 0/20

## META 2

## NOTAS

^[^\n]*$   {yycolumnno += (strlen(yytext)); REJECT;} <br>
./compile.sh deiGo.l gocompiler <br>
./gocompiler -l < lextests/text_1.dgo | colordiff --strip-trailing-cr lextests/text_2.out -
