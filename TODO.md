## META 3

Questions:

1 - Se houver erros, printa-se a árvore? Enunciado diz que sim, errors.out diz que não

Todo:

Erros

[ ] - Rodar sem flag e ver se há análise semantica se houver erros sintaticos e lex
[x] - logical_operators.dgo >> basicamente, criar um booleano para saber se a variável já foi declarada. ver do segfault ..   (not-yet-declared branch)
[x] - add support to ParseArgs, Minus, Plus, etc nodes... (logical_operators) and noted type on Assign, ParseArgs, operations, Minus Plus ....

Testing errors:
[x] - Adicionar os casos do ParseArgs e Print no "traverseAndCheckTree";
[x] - Na árvore, falta meter o tipo à frente do Assign. Exemplo: "Assign - int"
[ ] - Na árvore, retirar o tipo "none" aos Call. Fica "Call" em vez de "Call - none"
[ ] - No print de erro "Cannot find symbols x(..., ...,)", não pode haver espaço dentro dos parêntesis, tem que ficar x(...,...). Alguns têm espaço, outros não.
[ ] - Erros a mais em "variable_func_assign_errors" (corrige o ponto seguinte em princípio)
[x] - Erros a mais em "errors.out"
[x] - segfault em "logical_operators"
[ ] - segfault em "statements_expressions"

[ ] - Tirar (!flagS) no final

**FICHEIROS FUNCIONAIS**
-- erros --

[x] errors_nonefunccalls
[ ] errors_parseargs
[x] errors
[ ] factorial
[x] logical_operators
[x] statements_expressions
[ ] valid_program
[ ] variable_func_assign_errors

-- tabelas e árvore
