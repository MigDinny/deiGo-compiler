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
    int flagL, flagError, flagEOF, flagEOFaux, flagEOF_strlit, strlit_buffer_pos = 0;
    char left_bracket = '(';
    int yycolumnno = 1;
    char *strlit_buffer;
    int strlit_buffer_alloc_size = 100;

    extern node_t *myprogram;

%}

%X SINGLECOMM DOUBLECOMM STRLIT
%%

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

{reserved}                          {if (flagL) printf("RESERVED(%s)\n", yytext); yycolumnno += yyleng; flagEOF = 0; yylval.letters = strdup(yytext); if (!flagL) return RESERVED;}
","                                 {if (flagL) printf("COMMA\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return COMMA;}
"_"                                 {if (flagL) printf("BLANKID\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return BLANKID;}
"="                                 {if (flagL) printf("ASSIGN\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return ASSIGN;}
"*"                                 {if (flagL) printf("STAR\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return STAR;}
"/"                                 {if (flagL) printf("DIV\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return DIV;}
"-"                                 {if (flagL) printf("MINUS\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return MINUS;}
"+"                                 {if (flagL) printf("PLUS\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return PLUS;}
"=="                                {if (flagL) printf("EQ\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return EQ;}
">="                                {if (flagL) printf("GE\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return GE;}
">"                                 {if (flagL) printf("GT\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return GT;}
"{"                                 {if (flagL) printf("LBRACE\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return LBRACE;}
"<="                                {if (flagL) printf("LE\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return LE;}
"("                                 {if (flagL) printf("LPAR\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return LPAR;}
"["                                 {if (flagL) printf("LSQ\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return LSQ;}
"<"                                 {if (flagL) printf("LT\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return LT;}
"%"                                 {if (flagL) printf("MOD\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return MOD;}
"!="                                {if (flagL) printf("NE\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return NE;}
"!"                                 {if (flagL) printf("NOT\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return NOT;}
"&&"                                {if (flagL) printf("AND\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return AND;}
"||"                                {if (flagL) printf("OR\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return OR;}
"package"                           {if (flagL) printf("PACKAGE\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return PACKAGE;}
"else"                              {if (flagL) printf("ELSE\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return ELSE;}
"for"                               {if (flagL) printf("FOR\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return FOR;}
"if"                                {if (flagL) printf("IF\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return IF;}
"var"                               {if (flagL) printf("VAR\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return VAR;}
"int"                               {if (flagL) printf("INT\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return INT;}
"float32"                           {if (flagL) printf("FLOAT32\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return FLOAT32;}
"bool"                              {if (flagL) printf("BOOL\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return BOOL;}
"string"                            {if (flagL) printf("STRING\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return STRING;}
"fmt.Println"                       {if (flagL) printf("PRINT\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return PRINT;}
"strconv.Atoi"                      {if (flagL) printf("PARSEINT\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return PARSEINT;}
"func"                              {if (flagL) printf("FUNC\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return FUNC;}
"os.Args"                           {if (flagL) printf("CMDARGS\n"); yycolumnno += yyleng; flagEOF = 0; if (!flagL) return CMDARGS;}

"}"                                 {if (flagL) printf("RBRACE\n"); yycolumnno += yyleng; flagEOF = 1; if (!flagL) return RBRACE;}
")"                                 {if (flagL) printf("RPAR\n"); yycolumnno += yyleng; flagEOF = 1; if (!flagL) return RPAR;}
"]"                                 {if (flagL) printf("RSQ\n"); yycolumnno += yyleng; flagEOF = 1; if (!flagL) return RSQ;}
"return"                            {if (flagL) printf("RETURN\n"); yycolumnno += yyleng; flagEOF = 1; if (!flagL) return RETURN;}

{id}                                {if (flagL) printf("ID(%s)\n", yytext); yycolumnno += yyleng; flagEOF = 1; yylval.letters = strdup(yytext); if (!flagL) return ID;}
{int_lit}                           {if (flagL) printf("INTLIT(%s)\n", yytext); yycolumnno += yyleng; flagEOF = 1; yylval.letters = strdup(yytext); if (!flagL) return INTLIT;}
{real_lit}                          {if (flagL) printf("REALLIT(%s)\n", yytext); yycolumnno += yyleng; flagEOF = 1; yylval.letters = strdup(yytext); if (!flagL) return REALLIT;}

0([0-7]*[89]+[0-7]*)+               {printf("Line %d, column %d: invalid octal constant (%s)\n", yylineno, yycolumnno, yytext); yycolumnno += yyleng; flagEOF = 0;}

\"                                  {BEGIN STRLIT; flagError = 0; flagEOF = 0;  initialLine = yylineno; initialColumn = yycolumnno; yycolumnno += yyleng;}

<STRLIT>\"                          {BEGIN 0; if (flagL && !flagError) printf("STRLIT(\"%s\")\n", strlit_buffer); yycolumnno += yyleng; if (flagError == 0) flagEOF = 1; flagError = 0; yylval.letters = strdup(strlit_buffer); strlit_buffer[0] = 0; strlit_buffer_pos = 0; if (!flagL) return STRLIT2;}
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

{newline}                           {if (flagEOF == 1 && flagL && !flagError) {printf("SEMICOLON\n"); flagEOFaux = 1; flagEOF = 0;} yylineno++; yycolumnno = 1; if ((flagEOFaux == 1 || flagEOF == 1) && !flagL && !flagError) { flagEOFaux = 0; flagEOF = 0; return SEMICOLON; }}
\t                                  {yycolumnno += yyleng;}
.                                   {flagEOF = 0; printf("Line %d, column %d: illegal character (%s)\n", yylineno, yycolumnno, yytext); yycolumnno += yyleng;}

<<EOF>>                             {if (flagEOF == 1 && flagL) printf("SEMICOLON\n"); if (!flagL && flagEOF == 1) return SEMICOLON; yyterminate();}                                

%%

int main(int argc, char *argv[ ])
{

    strlit_buffer = (char*) malloc(100);
    
    if (argc > 1) {
        if (strcmp(argv[1], "-l") == 0) {
            flagL = 1;
            yylex();
        } else if (strcmp(argv[1], "-t") == 0) {
            yyparse();
            //print_tree(myprogram, 0);
        } 
    } else yyparse();

   
    
    free(strlit_buffer);
    return 0;
}

int yywrap() {
    return 1;
}

void yyerror (const char *s) { 
    printf ("Line %d, column %d: %s: %s\n", yylineno, yycolumnno, s, yytext);
}
