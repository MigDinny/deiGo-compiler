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
%type <node> VarSpec2
%type <node> Type
%type <node> FuncDeclaration
%type <node> Parameters
%type <node> Parameters2
%type <node> FuncBody
%type <node> VarsAndStatements
%type <node> Statement
%type <node> ParseArgs
%type <node> FuncInvocation
%type <node> Expr


%%

Program: PACKAGE ID SEMICOLON Declarations                                                                      {;}
        ;

Declarations: VarDeclaration SEMICOLON Declarations                                                             {;}
        | FuncDeclaration SEMICOLON Declarations                                                                {;}
        | /* empty */                                                                                           {;}
        ;

VarDeclaration: VAR VarSpec                                                                                     {;}
        | VAR LPAR VarSpec SEMICOLON RPAR                                                                       {;}
        ;

VarSpec: ID VarSpec2 Type                                                                                       {;}
        ;

VarSpec2: COMMA ID                                                                                              {;}
        | /* empty */                                                                                           {;}
        ;

Type:   INT                                                                                                     {;}
        | FLOAT32                                                                                               {;}
        | BOOL                                                                                                  {;}
        | STRING                                                                                                {;}
        ;

FuncDeclaration: FUNC ID LPAR Parameters RPAR Type FuncBody                                                     {;}
        | FUNC ID LPAR Parameters RPAR FuncBody                                                                 {;}
        | FUNC ID LPAR RPAR Type FuncBody                                                                       {;}
        | FUNC ID LPAR RPAR FuncBody                                                                            {;}
        ;

Parameters: ID Type Parameters2                                                                                 {;}
        ;

Parameters2: COMMA ID Type Parameters2                                                                          {;}
        | /* empty */                                                                                           {;}
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
        | IF Expr LBRACE Statement 2 RBRACE ELSE LBRACE Statement2 RBRACE                                       {;}
        | IF Expr LBRACE Statement 2 RBRACE                                                                     {;}
        | FOR Expr LBRACE Statement 2 RBRACE                                                                    {;}
        | FOR  LBRACE Statement 2 RBRACE                                                                        {;}
        | RETURN Expr                                                                                           {;}
        | RETURN                                                                                                {;}
        | FuncInvocation                                                                                        {;}
        | ParseArgs                                                                                             {;}
        | PRINT LPAR Expr RPAR                                                                                  {;}
        | PRINT LPAR STRLIT RPAR                                                                                {;}
        ;

Statement2: Statement SEMICOLON                                                                                 {;}
        | /* empty */                                                                                           {;}
        ;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR                                      {;}
        ;

FuncInvocation: ID LPAR Expr FuncInvocation2 RPAR                                                               {;}
        | ID LPAR RPAR                                                                                          {;}
        ;

FuncInvocation2: COMMA Expr                                                                                     {;}
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

