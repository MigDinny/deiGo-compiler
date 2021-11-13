%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "functions.h"
#include "y.tab.h"

int yylex (void);
void yyerror(char* s);

node* myprogram; // root node

%}

%union {
    char *id;
    node_t *node;
}

%token INTEGER DOUBLE CHARACTER LET IN END WRITE // faltam os tokens restantes
%token <id> ID

%type <node> Program
%type <node> vardeclist
%type <node> vardec
%type <node> statementlist
%type <node> statement


%%

/*
Program −→ PACKAGE ID SEMICOLON Declarations
Declarations −→ {VarDeclaration SEMICOLON | FuncDeclaration SEMICOLON}
VarDeclaration −→ VAR VarSpec
VarDeclaration −→ VAR LPAR VarSpec SEMICOLON RPAR
VarSpec −→ ID {COMMA ID} Type
Type −→ INT | FLOAT32 | BOOL | STRING
FuncDeclaration −→ FUNC ID LPAR [Parameters] RPAR [Type] FuncBody
Parameters −→ ID Type {COMMA ID Type}
FuncBody −→ LBRACE VarsAndStatements RBRACE
VarsAndStatements −→ VarsAndStatements [VarDeclaration | Statement] SEMICOLON | 
Statement −→ ID ASSIGN Expr
Statement −→ LBRACE {Statement SEMICOLON} RBRACE
Statement −→ IF Expr LBRACE {Statement SEMICOLON} RBRACE [ELSE LBRACE {Statement
SEMICOLON} RBRACE]
Statement −→ FOR [Expr] LBRACE {Statement SEMICOLON} RBRACE
Statement −→ RETURN [Expr]
Statement −→ FuncInvocation | ParseArgs
Statement −→ PRINT LPAR (Expr | STRLIT) RPAR
ParseArgs −→ ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR
FuncInvocation −→ ID LPAR [Expr {COMMA Expr}] RPAR
Expr −→ Expr (OR | AND) Expr
Expr −→ Expr (LT | GT | EQ | NE | LE | GE) Expr
Expr −→ Expr (PLUS | MINUS | STAR | DIV | MOD) Expr
Expr −→ (NOT | MINUS | PLUS) Expr
Expr −→ INTLIT | REALLIT | ID | FuncInvocation | LPAR Expr RPAR
*/

program: LET vardeclist IN statementlist END
                                        {$$=myprogram=insert_program($2, $4);} 
    ;

vardeclist: /*empty*/                   {$$=NULL;}
    | vardeclist vardec                 {$$=insert_vardec_list($1, $2);}
    ;

vardec: INTEGER IDENTIFIER              {$$=insert_integer_dec($2);}
    | CHARACTER IDENTIFIER              {$$=insert_character_dec($2);}
    | DOUBLE IDENTIFIER                 {$$=insert_double_dec($2);}
    ;

statementlist: /*empty*/                {$$=NULL;}
    | statementlist statement           {$$=insert_statement_list($1, $2);}
    ;

statement: WRITE IDENTIFIER             {$$=insert_write_statement($2);}
    ;

%%

void yyerror(char *msg) {
    printf("%s", msg);
}

