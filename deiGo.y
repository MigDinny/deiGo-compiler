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
    char *letters;
    node_t *node;
}

%token COMMA BLANKID ASSIGN STAR DIV MINUS PLUS EQ GE GT LBRACE LE LPAR LSQ LT MOD NE NOT AND OR PACKAGE ELSE FOR IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC CMDARGS RBRACE RPAR RSQ RETURN 
%token <letters> ID RESERVED INTLIT REALLIT STRLIT

%left COMMA
%right ASSIGN 
%left OR
%left AND
%left EQ NE LT LE GT GE     
%left PLUS MINUS
%left MUL DIV MOD
%right NOT

%nonassoc UNARY
%nonassoc LPAR RPAR


%type <node> Program
%type <node> Declarations
%type <node> VarDeclaration
%type <node> VarSpec
%type <node> Type
%type <node> FuncDeclaration
%type <node> Parameters
%type <node> FuncBody
%type <node> VarsAndStatements
%type <node> Statement
%type <node> ParseArgs
%type <node> FuncInvocation
%type <node> Expr


%%

Program: PACKAGE ID SEMICOLON Declarations      {$$ = myprogram = create_node("Program"); add_child($$, $4);}
        ;

Declarations:   /* empty */                        {$$ = NULL;}
        | VarDeclaration SEMICOLON Declarations    {$$ = $1; add_next($$, $3);}
        | FuncDeclaration SEMICOLON Declarations   {$$ = $1; add_next($$, $3);}
        ;

VarDeclaration: VAR VarSpec                     {$$ = create_node("VarDeclaration"); add_child($$, $2);}
        | VAR LPAR VarSpec SEMICOLON RPAR       {$$ = create_node("VarDeclaration"); add_child($$, $3);}
        ;

VarSpec: ID { COMMA ID } Type                   {;}
        ;

Type:   INT                                     {;}
        | FLOAT32                               {;}
        | BOOL                                  {;}
        | STRING                                {;}
        ;


FuncDeclaration: FUNC ID LPAR [Parameters] RPAR [Type] FuncBody {;}
        ;


Parameters: ID Type {COMMA ID Type}                             {;}
        ;


FuncBody: LBRACE VarsAndStatements RBRACE           {;}
        ;


VarsAndStatements: VarsAndStatements [VarDeclaration | Statement] SEMICOLON | VAZIO     {;}
        ;
    
Statement: ID ASSIGN Expr   {;}
        | LBRACE {Statement SEMICOLON} RBRACE   {;}
        | IF Expr LBRACE {Statement SEMICOLON} RBRACE [ELSE LBRACE {Statement SEMICOLON} RBRACE]        {;}
        | FOR [Expr] LBRACE {Statement SEMICOLON} RBRACE        {;}
        | RETURN [Expr]     {;}
        | FuncInvocation | ParseArgs        {;}
        | PRINT LPAR (Expr | STRLIT) RPAR       {;}
        ;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR      {;}
        ;

FuncInvocation: ID LPAR [Expr {COMMA Expr}] RPAR                                {;}
        ;

Expr: Expr (OR | AND) Expr                                                      {;}
        | Expr (LT | GT | EQ | NE | LE | GE) Expr                               {;}
        | Expr (PLUS | MINUS | STAR | DIV | MOD) Expr                           {;}
        | (NOT | MINUS | PLUS) Expr                                             {;}
        ;

Expr: INTLIT | REALLIT | ID | FuncInvocation | LPAR Expr RPAR                 {;}
        ;

%%

void yyerror(char *msg) {
    printf("%s", msg);
}

