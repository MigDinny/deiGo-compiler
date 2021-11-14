## META 2

Questions:

[ ] - question page 9: what does FuncDecl(2) mean? should we ignore FuncDecl's with less than 2 children? should we throw a syntax error when children number requirements are not met?

Todo:

M [x] - create propper grammar based on given pseudo-grammar
A [x] - change lex file to return tokens (example: RETURN ID) for yacc to interpret
AM [x] - alter grammar so it is functional based on given requirements (page 7)
A [x] - sort the associativities (%left, %right, %nonassoc ...)
[x] - create structs and functions to handle AST
M [ ] - call create_node() and add_child() accordingly, in each grammar production
[ ] - handle redundancy (page 9)

[ ] - error handling + lines and columns + final adjustments of the output
