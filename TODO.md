## META 1

- [ ] str_bad_1 -> 

```
6c6
< Line 4, column 8: invalid escape sequence (\)
---
) Line 4, column 8: invalid escape sequence (\
```

**SUBMISSÕES**

- [ ] F Comments 10/15
- [ ] I Unterminated comments 0/10
- [ ] J Invalid or unterminated string literals 0/20

## META 2

## NOTAS

^[^\n]*$   {yycolumnno += (strlen(yytext)); REJECT;} <br>
./compile.sh deiGo.l gocompiler <br>
./gocompiler -l < lextests/text_1.dgo | colordiff --strip-trailing-cr lextests/text_2.out -
