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
%type <node> Parameters2
%type <node> FuncBody
%type <node> VarsAndStatements
%type <node> Statement
%type <node> Statement2
%type <node> ParseArgs
%type <node> FuncInvocation
%type <node> FuncInvocation2
%type <node> Expr


%%

Program: PACKAGE ID SEMICOLON Declarations      {$$ = myprogram = create_node("Program"); add_child($$, $4);}
        ;

Declarations: VarDeclaration SEMICOLON Declarations                                     {$$ = $1; add_next($$, $3);}
        | FuncDeclaration SEMICOLON Declarations                                        {$$ = $1; add_next($$, $3);}
        | /* empty */                                                                   {$$ = NULL;}
        ;

VarDeclaration: VAR VarSpec                     {$$ = create_node("VarDecl"); add_child($$, $2);}
        | VAR LPAR VarSpec SEMICOLON RPAR       {$$ = create_node("VarDecl"); add_child($$, $3);}
        ;

VarSpec: ID VarSpec2 Type                                                                                       {;}
        ;

VarSpec2: COMMA ID VarSpec2                                                                                     {;}
        | /* empty */                                                                                           {;}
        ;

Type:   INT                                                                                                     {;}
        | FLOAT32                                                                                               {;}
        | BOOL                                                                                                  {;}
        | STRING                                                                                                {;}
        ;

FuncDeclaration: FuncHeader FuncBody                                                     {$$ = create_node("FuncDecl"); /*add_child($$, $4); add_child($$, $6); add_child($$, $7);*/};

FuncHeader: FUNC ID LPAR Parameters RPAR Type                                   {;}
        | FUNC ID LPAR Parameters RPAR                                          {;}
        | FUNC ID LPAR RPAR Type                                                {;}
        | FUNC ID LPAR RPAR                                                     {;}
        ;

Parameters: ID Type Parameters2                                                                                 {$$ = create_node("FuncParams"); add_child($$, $2); add_child($$, $3);}
        ;

Parameters2: COMMA ID Type Parameters2                                                                          {;}
        | /* empty */                                                                                           {$$ = NULL;}
        ;

FuncBody: LBRACE VarsAndStatements RBRACE                                                                       {;}
        ;

VarsAndStatements: VarsAndStatements VarDeclaration SEMICOLON                                                   {;}
        | VarsAndStatements Statement SEMICOLON                                                                 {;} 
        | VarsAndStatements SEMICOLON                                                                           {;}
        | /* epsilon */                                                                                         {;}
        ;
    
Statement: ID ASSIGN Expr                                                                                       {;}
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

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR                                      {;}
        ;

FuncInvocation: ID LPAR Expr FuncInvocation2 RPAR                                                               {;}
        |       ID LPAR                      RPAR                                                                                          {;}
        ;

FuncInvocation2: COMMA Expr FuncInvocation2                                                                     {;}
        | /* empty */                                                                                           {;}
        ;

Expr: Expr OR Expr                                                                                              {;}      
        | Expr AND Expr                                                                                         {;}
        | Expr LT Expr                                                                                          {;}
        | Expr GT Expr                                                                                          {;}
        | Expr EQ Expr                                                                                          {;}
        | Expr NE Expr                                                                                          {;}
        | Expr LE Expr                                                                                          {;}
        | Expr GE Expr                                                                                          {;}
        | Expr PLUS Expr                                                                                        {;}
        | Expr MINUS Expr                                                                                       {;}
        | Expr STAR Expr                                                                                        {;}
        | Expr DIV Expr                                                                                         {;}
        | Expr MOD Expr                                                                                         {;}
        | NOT Expr                                                                                              {;}
        | MINUS Expr                                                                                            {;}
        | PLUS Expr                                                                                             {;}
        | INTLIT                                                                                                {;}
        | REALLIT                                                                                               {;}
        | ID                                                                                                    {;}
        | FuncInvocation                                                                                        {;}
        | LPAR Expr RPAR                                                                                        {;}
        ;

%%

void yyerror(char *msg) {
    printf("%s", msg);
}
