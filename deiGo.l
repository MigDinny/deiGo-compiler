id                                  [a-zA-Z_][a-zA-Z_0-9]*
O                                   [0-7]
H                                   [0-9A-Fa-f]
D                                   [0-9]

decimal_lit                         [1-9](("_")?{D})*
octal_lit                           0(("_")?{O})*
hex_lit                             0[xX](("_")?{H})+
int_lit                             {decimal_lit}|{octal_lit}|{hex_lit}
decimals                            {D}(("_")?{D})*
exp                                 [eE][+-]?{decimals}    
real_lit                            {decimals}"."{decimals}?{exp}?|{decimals}{exp}|"."{decimals}{exp}? 

reserved                            (break|case|chan|const|continue|default|defer|fallthrough|go|goto|import|interface|map|range|select|struct|switch|type|"++"|"--")
ch                                  [a-zA-Z]
esc                                 (\f|\n|\r|\t|\\|\")* 
strlit                              ("carriage return"|"newline"|\"\")             
newline                             \r\n|\n|\r
reallit                             (({d}"."{D})|({D}+"."))({exp}{sig}?{D}("_")?)?|{D}{exp}{sig}?{D}("_")?
escape_sequence                     \\n|\\f|\\r|\\t|\\\"|(\\\\)

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "structures.h"
    #include "y.tab.h"
    #include "functions.h"
    
    int initialLine, initialColumn = 1;
    int flagL, flagT, flagError, flagEOF, flagEOFaux, flagEOF_strlit, flagUseAux, strlit_buffer_pos = 0;
    char left_bracket = '(';
    int yycolumnno = 1;
    int yycolumnno_aux = 1;
    int yylineno_aux = 0;
    char *strlit_buffer;
    int strlit_buffer_alloc_size = 100;

    extern node_t *myprogram;
    extern symtab_t *global;
    int error2;
%}

%X SINGLECOMM DOUBLECOMM STRLIT REALLYEND
%%

.                                   {flagUseAux = 0; REJECT;}

" "                                 {yycolumnno += yyleng;}
" "*"//"                            { BEGIN SINGLECOMM; initialLine = yylineno; yycolumnno += yyleng; initialColumn = yycolumnno - 2;}
" "*"/*"                            { BEGIN DOUBLECOMM; initialLine = yylineno; yycolumnno += yyleng; initialColumn = yycolumnno - 2;}            
";"                                 {if (flagL) printf("SEMICOLON\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return SEMICOLON;}

<SINGLECOMM>.                       {yycolumnno += yyleng;}
<SINGLECOMM>{newline}               {if (flagEOF == 1 && flagL) { printf("SEMICOLON\n"); flagEOF = 0; flagEOFaux = 1;} BEGIN 0; yylineno++;  yycolumnno = 1;  if (flagEOFaux == 1 && !flagL) { flagEOFaux = 0; return SEMICOLON; }}

<DOUBLECOMM><<EOF>>                 {if (flagEOF == 1 && flagL) { printf("SEMICOLON\n"); flagEOF = 0;} printf("Line %d, column %d: unterminated comment\n", initialLine, initialColumn); yyterminate();}
<DOUBLECOMM>"*/"                    {yycolumnno += yyleng; BEGIN 0;}
<DOUBLECOMM>{newline}               {if (flagEOF == 1 && flagL) { printf("SEMICOLON\n"); flagEOF = 0; flagEOFaux = 1;} yylineno++; yycolumnno = 1; if (flagEOFaux == 1 && !flagL) { flagEOFaux = 0; return SEMICOLON; }}
<DOUBLECOMM>.                       {yycolumnno += yyleng;}

","                                 {if (flagL) printf("COMMA\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return COMMA;}
"_"                                 {if (flagL) printf("BLANKID\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return BLANKID;}
"{"                                 {if (flagL) printf("LBRACE\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return LBRACE;}
"("                                 {if (flagL) printf("LPAR\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return LPAR;}
"["                                 {if (flagL) printf("LSQ\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return LSQ;}
"package"                           {if (flagL) printf("PACKAGE\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return PACKAGE;}
"else"                              {if (flagL) printf("ELSE\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return ELSE;}
"for"                               {if (flagL) printf("FOR\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return FOR;}
"var"                               {if (flagL) printf("VAR\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return VAR;}
"int"                               {if (flagL) printf("INT\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return INT;}
"float32"                           {if (flagL) printf("FLOAT32\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return FLOAT32;}
"bool"                              {if (flagL) printf("BOOL\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return BOOL;}
"func"                              {if (flagL) printf("FUNC\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return FUNC;}
"os.Args"                           {if (flagL) printf("CMDARGS\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return CMDARGS;}

"}"                                 {if (flagL) printf("RBRACE\n"); yycolumnno += yyleng; flagEOF = 1; if (!flagL) return RBRACE;}
")"                                 {if (flagL) printf("RPAR\n"); yycolumnno += yyleng; flagEOF = 1; if (!flagL) return RPAR;}
"]"                                 {if (flagL) printf("RSQ\n"); yycolumnno += yyleng; flagEOF = 1; if (!flagL) return RSQ;}

"="                                 {if (flagL) printf("ASSIGN\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Assign", NULL, yylineno, initialColumn); return ASSIGN;}}
"*"                                 {if (flagL) printf("STAR\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Mul", NULL, yylineno, initialColumn); return STAR;}}
"/"                                 {if (flagL) printf("DIV\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Div", NULL, yylineno, initialColumn); return DIV;}}
"-"                                 {if (flagL) printf("MINUS\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Sub", NULL, yylineno, initialColumn); return MINUS;}}
"+"                                 {if (flagL) printf("PLUS\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Add", NULL, yylineno, initialColumn); return PLUS;}}
"=="                                {if (flagL) printf("EQ\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Eq", NULL, yylineno, initialColumn); return EQ;}}
">="                                {if (flagL) printf("GE\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Ge", NULL, yylineno, initialColumn); return GE;}}
">"                                 {if (flagL) printf("GT\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Gt", NULL, yylineno, initialColumn); return GT;}}
"<="                                {if (flagL) printf("LE\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Le", NULL, yylineno, initialColumn); return LE;}}
"<"                                 {if (flagL) printf("LT\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Lt", NULL, yylineno, initialColumn); return LT;}}
"%"                                 {if (flagL) printf("MOD\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Mod", NULL, yylineno, initialColumn); return MOD;}}
"!="                                {if (flagL) printf("NE\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Ne", NULL, yylineno, initialColumn); return NE;}}
"!"                                 {if (flagL) printf("NOT\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Not", NULL, yylineno, initialColumn); return NOT;}}
"&&"                                {if (flagL) printf("AND\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("And", NULL, yylineno, initialColumn); return AND;}}
"||"                                {if (flagL) printf("OR\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Or", NULL, yylineno, initialColumn); return OR;}}
"if"                                {if (flagL) printf("IF\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("If", NULL, yylineno, initialColumn); return IF;}}
"string"                            {if (flagL) printf("STRING\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("String", NULL, yylineno, initialColumn); return STRING;}}
"fmt.Println"                       {if (flagL) printf("PRINT\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Print", NULL, yylineno, initialColumn); return PRINT;}}
"strconv.Atoi"                      {if (flagL) printf("PARSEINT\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 0; if (!flagL) {yylval.value = create_token("Atoi", NULL, yylineno, initialColumn); return PARSEINT;}}
"return"                            {if (flagL) printf("RETURN\n"); initialColumn = yycolumnno; yycolumnno += yyleng; flagEOF = 1; if (!flagL) {yylval.value = create_token("Return", NULL, yylineno, initialColumn); return RETURN;}}

{id}                                {if (flagL) printf("ID(%s)\n", yytext); yylval.value = create_token("Id", strdup(yytext), yylineno, yycolumnno); yycolumnno += yyleng; flagEOF = 1;  if (!flagL) return ID;}
{int_lit}                           {if (flagL) printf("INTLIT(%s)\n", yytext); yylval.value = create_token("IntLit", strdup(yytext), yylineno, yycolumnno); yycolumnno += yyleng; flagEOF = 1;  if (!flagL) return INTLIT;}
{real_lit}                          {if (flagL) printf("REALLIT(%s)\n", yytext); yylval.value = create_token("RealLit", strdup(yytext), yylineno, yycolumnno); yycolumnno += yyleng; flagEOF = 1;  if (!flagL) return REALLIT;}
{reserved}                          {if (flagL) printf("RESERVED(%s)\n", yytext); yylval.value = create_token("Reserved", strdup(yytext), yylineno, yycolumnno); yycolumnno += yyleng; flagEOF = 0;  if (!flagL) return RESERVED;}

0([0-7]*[89]+[0-7]*)+               {printf("Line %d, column %d: invalid octal constant (%s)\n", yylineno, yycolumnno, yytext); yycolumnno += yyleng; flagEOF = 0;}

\"                                  {BEGIN STRLIT; flagError = 0; flagEOF = 0;  initialLine = yylineno; initialColumn = yycolumnno; yycolumnno += yyleng;}

<STRLIT>\"                          {BEGIN 0; if (flagL && !flagError) printf("STRLIT(\"%s\")\n", strlit_buffer); yylval.value = create_token("Strlit", strdup(yytext), initialLine, initialColumn); yycolumnno += yyleng; if (flagError == 0) flagEOF = 1;  strlit_buffer[0] = 0; strlit_buffer_pos = 0; if (!flagL && !flagError) { flagError = 0; return STRLIT2; } else flagError = 0;}
<STRLIT>[^\\\n\r]|{escape_sequence}     {
                                    if (strlit_buffer_pos == strlit_buffer_alloc_size - 1) {
                                        strlit_buffer_alloc_size += 100;
                                        strlit_buffer = (char *) realloc(strlit_buffer, strlit_buffer_alloc_size);
                                    }
                                    strcat(strlit_buffer, yytext);
                                    strlit_buffer_pos++;
                                    yycolumnno += yyleng; 
                                    }
<STRLIT>\\[^\n\r]?                  {printf("Line %d, column %d: invalid escape sequence (%s)\n", yylineno, yycolumnno, yytext); flagError = 1; yycolumnno += yyleng; }
<STRLIT>{newline}                   {printf("Line %d, column %d: unterminated string literal\n", initialLine, initialColumn); strlit_buffer[0] = 0; strlit_buffer_pos = 0; yylineno++; yycolumnno = 1; BEGIN 0; }
<STRLIT><<EOF>>                     {printf("Line %d, column %d: unterminated string literal\n", initialLine, initialColumn); yyterminate();}   

{newline}                           {if (flagEOF == 1 && flagL && !flagError) {printf("SEMICOLON\n"); flagEOFaux = 1; flagEOF = 0; } yylineno_aux = yylineno; yycolumnno_aux = yycolumnno; yylineno++; yycolumnno = 1; if ((flagEOFaux == 1 || flagEOF == 1) && !flagL && !flagError) { flagEOFaux = 0; flagEOF = 0; flagUseAux = 1; return SEMICOLON; }}
\t                                  {yycolumnno += yyleng;}
.                                   {flagEOF = 0; printf("Line %d, column %d: illegal character (%s)\n", yylineno, yycolumnno, yytext); yycolumnno += yyleng;}

<REALLYEND><<EOF>>                  { yyterminate();  }

<<EOF>>                             {flagUseAux = 0; if (flagEOF == 1 && flagL) printf("SEMICOLON\n"); if (!flagL && flagEOF == 1) { flagEOF = 0; return SEMICOLON; } else { BEGIN(REALLYEND); return EOP; }}                                


%%

int main(int argc, char *argv[ ])
{

    strlit_buffer = (char*) malloc(100);
    
    if (argc > 1) {
        if (strcmp(argv[1], "-l") == 0) {
            // análise lexical only
            flagL = 1;
            yylex();
        } else if (strcmp(argv[1], "-t") == 0) {
            flagT = 1;
            // análise lexical, análise sintatica e PRINT TREE
            yyparse();
        } else if (strcmp(argv[1], "-s") == 0) {
            // análise lexical, análise sintática e semantica. print tabelas + arvore anotada
            yyparse();
            
            if (error2 == 0) {
                // ler árvore + popular tabela
                global = create_global_table();

                traverseAndPopulateTable(global, myprogram);
                printTables(global);

                // check arvore + inserir tipos nos nós + consultar tabela

                traverseAndCheckTree(myprogram, NULL, global);
                printNotedTree(myprogram, 0, global);
            }
        }
    } else {
        /*
        deverá levar o analisador a proceder à análise lexical e sintática do programa, e apenas caso
este seja válido, proceder à análise semântica. No caso em que não é passada qualquer opção, o
analisador deve apenas escrever no stdout as mensagens de erro.
         */

    }

   
    
    free(strlit_buffer);
    free(myprogram);
    return 0;
}

int yywrap() {
    return 1;
}

void yyerror (const char *s) {
    error2 += 1;
    if (strcmp(yytext, "\"") == 0) {
        // syntax error: "
        printf ("Line %d, column %d: %s: \"%s\"\n", yylineno, yycolumnno - (int) strlen(yylval.value->value) - 2, s, yylval.value->value);
    } else { 
        if (flagUseAux) {
            printf ("Line %d, column %d: %s: %s\n", yylineno_aux, yycolumnno_aux, s, yytext);
            flagUseAux = 0;
        } else printf ("Line %d, column %d: %s: %s\n", yylineno, yycolumnno - (int) strlen(yytext), s, yytext);
    } 
}
