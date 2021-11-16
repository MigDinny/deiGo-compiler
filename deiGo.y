%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "functions.h"
#include "structures.h"
#include "y.tab.h"

int yylex (void);
void yyerror (const char *s);

node_t *myprogram; // root node
node_t *temp; // temp node to use as an aux
int error = 0; // error status flag

extern char *yytext;

%}

%union {
    char *letters;
    node_t *node;
}

%token EOP SEMICOLON COMMA BLANKID ASSIGN STAR DIV MINUS PLUS EQ GE GT LBRACE LE LPAR LSQ LT MOD NE NOT AND OR PACKAGE ELSE FOR IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC CMDARGS RBRACE RPAR RSQ RETURN 
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
%type <node> Intlit
%type <node> Reallit
%type <node> Strlit2
%type <node> Assign

%%

Program: PACKAGE Id SEMICOLON Declarations EOP      {$$ = myprogram = create_node("Program"); add_child($$, $4); if (!error) print_tree(myprogram, 0);}
        ;

Declarations: VarDeclaration SEMICOLON Declarations                                             {$$ = $1; add_next($$, $3);}
        | FuncDeclaration SEMICOLON Declarations                                                {$$ = $1; add_next($$, $3);}
        | /* empty */                                                                           {$$ = NULL;}
        ;

VarDeclaration: VAR VarSpec                                                                     {$$ = $2;}
        | VAR LPAR VarSpec SEMICOLON RPAR                                                       {$$ = $3;}
        ;

VarSpec: Id VarSpec2 Type               {
                                        	$$ = create_node("VarDecl"); add_child($$, $3); add_child($$, $1); temp = $2; // temp is first ID of possible list
											for (; temp != NULL;)
											{
												node_t * vardecl = create_node("VarDecl"); 
												add_next($$, vardecl); // add vardecl to brother
												add_child(vardecl, create_node($3->token->symbol));

												add_child(vardecl, temp); // add id as a child of vardecl

												node_t *temp2 = temp;

												temp = temp->next; // iterate next original brother

												temp2->next = NULL; // de-reference brother
											}
                                        }
        ;

VarSpec2: COMMA Id VarSpec2                                     {$$ = $2; add_next($$, $3); }
        | /* empty */                                                                                           {$$ = NULL;}
        ;

Type:   INT                                                                                                     {$$ = create_node("Int");}
        | FLOAT32                                                                                               {$$ = create_node("Float32");}
        | BOOL                                                                                                  {$$ = create_node("Bool");}
        | STRING                                                                                                {$$ = create_node("String");}
        ;

FuncDeclaration: FuncHeader FuncBody                                                     {$$ = create_node("FuncDecl"); add_child($$, $1); add_child($$, $2);}
        ;

FuncHeader: FUNC Id LPAR Parameters RPAR Type                                   {$$ = create_node("FuncHeader"); add_child($$, $2); add_child($$, $6); add_child($$, $4); }
        | FUNC Id LPAR Parameters RPAR                                          {$$ = create_node("FuncHeader"); add_child($$, $2); add_child($$, $4);}
        | FUNC Id LPAR RPAR Type                                                {$$ = create_node("FuncHeader"); add_child($$, $2); add_child($$, create_node("FuncParams")); add_child($$, $5);}
        | FUNC Id LPAR RPAR                                                     {$$ = create_node("FuncHeader"); add_child($$, $2); add_child($$, create_node("FuncParams"));}
        ;

Parameters: Id Type ParametersDecl                                                                              {$$ = create_node("FuncParams"); temp = create_node("ParamDecl"); add_child(temp, $2); add_child(temp, $1); add_child($$, temp); temp = NULL; add_child($$, $3); }
        ;

ParametersDecl: COMMA Id Type ParametersDecl                                                                    {$$ = create_node("ParamDecl"); add_child($$, $3); add_child($$, $2); add_next($$, $4); }
        | /* empty */                                                                                           {$$ = NULL;}
        ;


FuncBody: LBRACE VarsAndStatements RBRACE      {$$ = create_node("FuncBody"); add_child($$, $2); }
        ;

VarsAndStatements:  VarDeclaration SEMICOLON       VarsAndStatements       {$$ = $1; add_next($$, $3);}
        |  Statement SEMICOLON             VarsAndStatements   { if ($1 != NULL) {$$ = $1; add_next($$, $3);} else $$ = $3;} 
        |  SEMICOLON                     VarsAndStatements   {$$ = $2; }
        | /* epsilon */                                                                                         {$$ = NULL;}
        ;
    

Statement: Id Assign Expr                                                                                       {$$ = $2; add_child($$, $1); add_child($$, $3); }
        | LBRACE Statement2 RBRACE                              {
																	if (count_children($2) >= 2) { // se houver >= 2 statements, criar block
																		temp = create_block_node();
																		add_child(temp, $2); // statements filhos do block
																		$$ = temp;	
																	} else $$ = $2;
																}
        | IF Expr LBRACE Statement2 RBRACE ELSE LBRACE Statement2 RBRACE                                        {$$ = create_node("If"); add_child($$, $2); temp = create_block_node(); add_child(temp, $4); add_child($$, temp); temp = create_block_node(); add_child(temp, $8); add_child($$, temp); temp = NULL; }
        | IF Expr LBRACE Statement2 RBRACE                                                                      {$$ = create_node("If"); add_child($$, $2); temp = create_block_node(); add_child(temp, $4); add_child($$, temp); add_child($$, create_block_node()); temp = NULL; }
        | FOR Expr LBRACE Statement2 RBRACE                                                                     {$$ = create_node("For"); add_child($$, $2); temp = create_block_node(); add_child(temp, $4); add_child($$, temp); temp = NULL;}
        | FOR      LBRACE Statement2 RBRACE                                                                     {$$ = create_node("For"); temp = create_block_node(); add_child(temp, $3); add_child($$, temp); temp = NULL;}
        | RETURN Expr                                                                                           {$$ = create_node("Return"); add_child($$, $2);}
        | RETURN                                                                                                {$$ = create_node("Return");}
        | FuncInvocation                                                                                        {$$ = create_node("Call"); add_child($$, $1);}
        | ParseArgs                                                                                             {$$ = $1;}
        | PRINT LPAR Expr RPAR                                                                                  {$$ = create_node("Print"); add_child($$, $3);}
        | PRINT LPAR Strlit2 RPAR                                                                               {$$ = create_node("Print"); add_child($$, $3);}
        | error																									{$$ = NULL; error = 1;}
		;

Statement2: Statement SEMICOLON Statement2                                                                      {if ($1 != NULL) { $$ = $1; add_next($$, $3); } else $$ = $3;}
        | /* empty */                                                                                           {$$ = NULL;}
        ;

ParseArgs: Id COMMA BLANKID Assign PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR                                      {$$ = create_node("ParseArgs"); add_child($$, $1); add_child($$, $9);}
        | Id COMMA BLANKID Assign PARSEINT LPAR error RPAR														{$$ = NULL; error = 1;}
		;

FuncInvocation: Id LPAR Expr FuncInvocation2 RPAR                                                               {$$ = $1; add_next($$, $3); add_next($3, $4);}
        |       Id LPAR                      RPAR                                                               {$$ = $1;}
        |		Id LPAR error RPAR 																				{$$ = NULL; error = 1;}		
		;

FuncInvocation2: COMMA Expr FuncInvocation2                                                                     {$$ = $2; add_next($$, $3);}
        | /* empty */                                                                                           {$$ = NULL;}
        ;

Expr: Expr OR Expr                                                                                              {$$ = create_node("Or"); add_child($$, $1); add_child($$, $3);}      
        | Expr AND Expr                                                                                         {$$ = create_node("And"); add_child($$, $1); add_child($$, $3);}  
        | Expr LT Expr                                                                                          {$$ = create_node("Lt"); add_child($$, $1); add_child($$, $3);}  
        | Expr GT Expr                                                                                          {$$ = create_node("Gt"); add_child($$, $1); add_child($$, $3);}  
        | Expr EQ Expr                                                                                          {$$ = create_node("Eq"); add_child($$, $1); add_child($$, $3);}  
        | Expr NE Expr                                                                                          {$$ = create_node("Ne"); add_child($$, $1); add_child($$, $3);}  
        | Expr LE Expr                                                                                          {$$ = create_node("Le"); add_child($$, $1); add_child($$, $3);}  
        | Expr GE Expr                                                                                          {$$ = create_node("Ge"); add_child($$, $1); add_child($$, $3);} 
        | Expr PLUS Expr                                                                                        {$$ = create_node("Add"); add_child($$, $1); add_child($$, $3);}  
        | Expr MINUS Expr                                                                                       {$$ = create_node("Sub"); add_child($$, $1); add_child($$, $3);}  
        | Expr STAR Expr                                                                                        {$$ = create_node("Mul"); add_child($$, $1); add_child($$, $3);}  
        | Expr DIV Expr                                                                                         {$$ = create_node("Div"); add_child($$, $1); add_child($$, $3);}  
        | Expr MOD Expr                                                                                         {$$ = create_node("Mod"); add_child($$, $1); add_child($$, $3);}  
        | NOT Expr                                                                                              {$$ = create_node("Not"); add_child($$, $2);} 
        | MINUS Expr                                                                                            {$$ = create_node("Minus"); add_child($$, $2);} 
        | PLUS Expr                                                                                             {$$ = create_node("Plus"); add_child($$, $2);} 
        | Intlit                                                                                                {$$ = $1;} 
        | Reallit                                                                                               {$$ = $1;} 
        | Id                                                                                                    {$$ = $1;}  
        | FuncInvocation                                                                                        {$$ = create_node("Call"); add_child($$, $1);} 
        | LPAR Expr RPAR                                                                                        {$$ = $2;} 
        | LPAR error RPAR																						{$$ = NULL; error = 1;}
		;






Id:     ID                                                                                                      {$$ = create_literal_node("Id", $1);}
        ;

Intlit: INTLIT                                                                                                  {$$ = create_literal_node("IntLit", $1);}
        ;

Reallit: REALLIT                                                                                                {$$ = create_literal_node("RealLit", $1);}
        ;

Strlit2: STRLIT2                                                                                                {$$ = create_literal_node("StrLit", $1);}
        ;

Assign: ASSIGN                                                                                                  {$$ = create_node("Assign");}
        ;


%%

