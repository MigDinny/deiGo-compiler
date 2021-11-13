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

%token INTEGER DOUBLE CHARACTER LET IN END WRITE UNARY
%token COMMA BLANKID ASSIGN STAR DIV MINUS PLUS EQ GE GT LBRACE LE LPAR LSQ LT MOD NE NOT AND OR PACKAGE ELSE FOR IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC CMDARGS RBRACE RPAR RSQ RETURN 
%token <id> ID RESERVED INTLIT REALLIT STRLIT

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

Program: PACKAGE ID SEMICOLON Declarations      {;}
        ;

Declarations:   /* empty */                        {;}
        | VarDeclaration SEMICOLON Declarations    {;}
        | FuncDeclaration SEMICOLON Declarations   {;}
        ;


VarDeclaration: VAR VarSpec                     {;}
        | VAR LPAR VarSpec SEMICOLON RPAR       {;}
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

