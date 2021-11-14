%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "functions.h"
#include "structures.h"
#include "y.tab.h"


int yylex (void);
void yyerror(char* s);

node_t* myprogram; // root node


%}

%union {
    char *letters;
    node_t *node;
}

%token SEMICOLON COMMA BLANKID ASSIGN STAR DIV MINUS PLUS EQ GE GT LBRACE LE LPAR LSQ LT MOD NE NOT AND OR PACKAGE ELSE FOR IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC CMDARGS RBRACE RPAR RSQ RETURN 
%token <letters> ID RESERVED INTLIT REALLIT STRLIT2

%left COMMA
%right ASSIGN 
%left OR
%left AND
%left EQ NE LT LE GT GE     
%left PLUS MINUS
%left STAR DIV MOD
%right NOT

%nonassoc UNARY
%nonassoc LPAR RPAR


%type <node> Program
%type <node> Declarations
%type <node> VarDeclaration
%type <node> VarSpec
%type <node> VarSpec2
%type <node> Type
%type <node> FuncDeclaration
%type <node> FuncHeader
%type <node> Parameters
%type <node> ParametersDecl
%type <node> FuncBody
%type <node> VarsAndStatements
%type <node> Statement
%type <node> Statement2
%type <node> ParseArgs
%type <node> FuncInvocation
%type <node> FuncInvocation2
%type <node> Expr
%type <node> Id


%%

Program: PACKAGE Id SEMICOLON Declarations      {$$ = myprogram = create_node("Program"); add_child($$, $4);}
        ;

Declarations: VarDeclaration SEMICOLON Declarations                                             {$$ = $1; add_next($$, $3);}
        | FuncDeclaration SEMICOLON Declarations                                                {$$ = $1; add_next($$, $3);}
        | /* empty */                                                                           {$$ = NULL;}
        ;

VarDeclaration: VAR VarSpec                                                                     {$$ = create_node("VarDecl"); add_child($$, $2);}
        | VAR LPAR VarSpec SEMICOLON RPAR                                                       {$$ = create_node("VarDecl"); add_child($$, $3);}
        ;

VarSpec: Id VarSpec2 Type                                                                                       {$$ = $1; add_next($$, $2); add_next($2, $3);}
        ;

VarSpec2: COMMA Id VarSpec2                                                                                     {$$ = $2; add_next($$, $3);}
        | /* empty */                                                                                           {$$ = NULL;}
        ;

Type:   INT                                                                                                     {$$ = create_node("Int");}
        | FLOAT32                                                                                               {$$ = create_node("Float32");}
        | BOOL                                                                                                  {$$ = create_node("Bool");}
        | STRING                                                                                                {$$ = create_node("String");}
        ;

FuncDeclaration: FuncHeader FuncBody                                                     {$$ = create_node("FuncDecl"); add_child($$, $1); add_child($$, $2);}
        ;

FuncHeader: FUNC Id LPAR Parameters RPAR Type                                   {$$ = create_node("FuncHeader"); add_child($$, $2); add_child($$, $4); add_child($$, $6);}
        | FUNC Id LPAR Parameters RPAR                                          {$$ = create_node("FuncHeader"); add_child($$, $2); add_child($$, $4);}
        | FUNC Id LPAR RPAR Type                                                {$$ = create_node("FuncHeader"); add_child($$, $2); add_child($$, $5);}
        | FUNC Id LPAR RPAR                                                     {$$ = create_node("FuncHeader"); add_child($$, $2);}
        ;

Parameters: Id Type ParametersDecl                                                                              {$$ = create_node("FuncParams"); add_child($$, $3); }
        ;

ParametersDecl: COMMA Id Type ParametersDecl                                                                    {$$ = create_node("ParamDecl"); add_child($$, $3); add_child($$, $2); add_next($$, $4); }
        | /* empty */                                                                                           {$$ = NULL;}
        ;

Id:     ID                                                                                                      {$$ = create_literal_node("Id", $1);}
        ;

FuncBody: LBRACE VarsAndStatements RBRACE                                                                       {$$ = create_node("FuncBody"); add_child($$, $2); }
        ;

VarsAndStatements: VarsAndStatements VarDeclaration SEMICOLON                                                   {$$ = $2; add_next($$, $1);}
        | VarsAndStatements Statement SEMICOLON                                                                 {$$ = $2; add_next($$, $1);} 
        | VarsAndStatements SEMICOLON                                                                           {$$ = $1; }
        | /* epsilon */                                                                                         {$$ = NULL;}
        ;
    
Statement: Id ASSIGN Expr                                                                                       {;}
        | LBRACE Statement2 RBRACE                                                                              {;}
        | IF Expr LBRACE Statement2 RBRACE ELSE LBRACE Statement2 RBRACE                                        {;}
        | IF Expr LBRACE Statement2 RBRACE                                                                      {;}
        | FOR Expr LBRACE Statement2 RBRACE                                                                     {;}
        | FOR      LBRACE Statement2 RBRACE                                                                         {;}
        | RETURN Expr                                                                                           {;}
        | RETURN                                                                                                {;}
        | FuncInvocation                                                                                        {;}
        | ParseArgs                                                                                             {;}
        | PRINT LPAR Expr RPAR                                                                                  {;}
        | PRINT LPAR STRLIT2 RPAR                                                                               {;}
        ;

Statement2: Statement SEMICOLON Statement2                                                                      {;}
        | /* empty */                                                                                           {;}
        ;

ParseArgs: Id COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR                                      {$$ = $1; add_child($$, $4); add_next($$, $9);}
        ;

FuncInvocation: Id LPAR Expr FuncInvocation2 RPAR                                                               {$$ = $1; add_next($$, $3); add_next($3, $4);}
        |       Id LPAR                      RPAR                                                               {$$ = $1;}
        ;

FuncInvocation2: COMMA Expr FuncInvocation2                                                                     {$$ = $2; add_next($$, $3)}
        | /* empty */                                                                                           {$$ = NULL;}
        ;

Expr: Expr OR Expr                                                                                              {$$ = $1; add_child($$, $2); add_next($$, $3);}      
        | Expr AND Expr                                                                                         {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr LT Expr                                                                                          {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr GT Expr                                                                                          {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr EQ Expr                                                                                          {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr NE Expr                                                                                          {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr LE Expr                                                                                          {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr GE Expr                                                                                          {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr PLUS Expr                                                                                        {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr MINUS Expr                                                                                       {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr STAR Expr                                                                                        {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr DIV Expr                                                                                         {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | Expr MOD Expr                                                                                         {$$ = $1; add_child($$, $2); add_next($$, $3);} 
        | NOT Expr                                                                                              {$$ = $1; add_next($$, $2);} 
        | MINUS Expr                                                                                            {$$ = $1; add_next($$, $2);} 
        | PLUS Expr                                                                                             {$$ = $1; add_next($$, $2);} 
        | INTLIT                                                                                                {$$ = $1;} 
        | REALLIT                                                                                               {$$ = $1;} 
        | Id                                                                                                    {$$ = $1;}  
        | FuncInvocation                                                                                        {$$ = $1;} 
        | LPAR Expr RPAR                                                                                        {$$ = $2;} 
        ;

%%

void yyerror(char *msg) {
    printf("%s", msg);
}
