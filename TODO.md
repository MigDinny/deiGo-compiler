## META 1

- [ ] str_bad_1 -> 

```
6c6
< Line 4, column 8: invalid escape sequence (\)
---
) Line 4, column 8: invalid escape sequence (\
```

**SUBMISSÕES**

- [ ] B Empty/blank files 2/5
- [ ] C Identifiers and keywords 16/20
- [x] D Operators, brackets and punctuation marks 10/10
- [x] E Plain text 10/10
- [x] F Comments 15/15
- [ ] G Numeric, char and real literals 25/30
- [ ] H Illegal characters 0/20
- [x] I Unterminated comments 10/10
- [ ] J Invalid or unterminated string literals 0/20
- [ ] K Automatic Insertion of Semicolons 16/20
- [ ] L Miscellaneous 16/25

## META 2

## NOTAS

^[^\n]*$   {yycolumnno += (strlen(yytext)); REJECT;} <br>
./compile.sh deiGo.l gocompiler <br>
./gocompiler -l < lextests/text_1.dgo | colordiff --strip-trailing-cr lextests/text_2.out -
