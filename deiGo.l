id                                  [a-zA-Z_][a-zA-Z_0-9]*
O                                   0[0-7]+
H                                   0x[0-9a-fA-F]+
d                                   [0-9]*
D                                   [0-9]+
reserved                            (break|case|chan|const|continue|default|defer|fallthrough|go|goto|import|interface|map|range|select|struct|switch|type|"++"|"--")
ch                                  [a-zA-Z]
exp                                 [eE]
sig                                 [-+]
esc                                 (\f|\n|\r|\t|\\|\")* 
strlit                              ("carriage return"|"newline"|\"\")             
newline                             \r\n|\n
illegal_character                   [^a-zA-Z0-9;,._=*<>!%&|\"-\"+{}()[\]\\] 

%{
    #include <stdio.h>
    #include <stdlib.h>
    int initialLine, initialColumn = 1;
    int flagL, flagError, strlit_buffer_pos = 0;
    char left_bracket = '(';
    int yycolumnno = 1;
    char *strlit_buffer;
    int strlit_buffer_alloc_size = 100;
%}

%X SINGLECOMM DOUBLECOMM STRLIT
%%

" "                                 {yycolumnno += yyleng; }                          

{reserved}                          {if (flagL) printf("RESERVED(%s)\n", yytext); yycolumnno += yyleng; }

";"                                 {if (flagL) printf("SEMICOLON\n"); yycolumnno += yyleng; }
","                                 {if (flagL) printf("COMMA\n"); yycolumnno += yyleng; }
"_"                                 {if (flagL) printf("BLANKID\n"); yycolumnno += yyleng; }
"="                                 {if (flagL) printf("ASSIGN\n"); yycolumnno += yyleng; }
"*"                                 {if (flagL) printf("STAR\n"); yycolumnno += yyleng; }
"/"                                 {if (flagL) printf("DIV\n"); yycolumnno += yyleng; }
"-"                                 {if (flagL) printf("MINUS\n"); yycolumnno += yyleng; }
"+"                                 {if (flagL) printf("PLUS\n"); yycolumnno += yyleng; }
"=="                                {if (flagL) printf("EQ\n"); yycolumnno += yyleng; }
">="                                {if (flagL) printf("GE\n"); yycolumnno += yyleng; }
">"                                 {if (flagL) printf("GT\n"); yycolumnno += yyleng; }
"{"                                 {if (flagL) printf("LBRACE\n"); yycolumnno += yyleng; }
"<="                                {if (flagL) printf("LE\n"); yycolumnno += yyleng; }
"("                                 {if (flagL) printf("LPAR\n"); yycolumnno += yyleng; }
"["                                 {if (flagL) printf("LSQ\n"); yycolumnno += yyleng; }
"<"                                 {if (flagL) printf("LT\n"); yycolumnno += yyleng; }
"%"                                 {if (flagL) printf("MOD\n"); yycolumnno += yyleng; }
"!="                                {if (flagL) printf("NE\n"); yycolumnno += yyleng; }
"!"                                 {if (flagL) printf("NOT\n"); yycolumnno += yyleng; }
"&&"                                {if (flagL) printf("AND\n"); yycolumnno += yyleng; }
"||"                                {if (flagL) printf("OR\n"); yycolumnno += yyleng; }

"}"                                 {if (flagL) printf("RBRACE\n"); yycolumnno += yyleng; }
"}"{newline}                        {if (flagL) printf("RBRACE\nSEMICOLON\n"); yylineno++; yycolumnno += yyleng; }

")"                                 {if (flagL) printf("RPAR\n"); yycolumnno += yyleng; }
")"{newline}                        {if (flagL) printf("RPAR\nSEMICOLON\n"); yylineno++; yycolumnno += yyleng; }

"]"                                 {if (flagL) printf("RSQ\n"); yycolumnno += yyleng;  }
"]"{newline}                        {if (flagL) printf("RSQ\r\nSEMICOLON\n"); yylineno++; yycolumnno += yyleng; }

"package"                           {if (flagL) printf("PACKAGE\n"); yycolumnno += yyleng; }

"return"                            {if (flagL) printf("RETURN\n"); yycolumnno += yyleng; }
"return"{newline}                   {if (flagL) printf("RETURN\nSEMICOLON\n"); yylineno++; yycolumnno += yyleng; }

"else"                              {if (flagL) printf("ELSE\n"); yycolumnno += yyleng; }
"for"                               {if (flagL) printf("FOR\n"); yycolumnno += yyleng; }
"if"                                {if (flagL) printf("IF\n"); yycolumnno += yyleng; }
"var"                               {if (flagL) printf("VAR\n"); yycolumnno += yyleng; }

"int"                               {if (flagL) printf("INT\n"); yycolumnno += yyleng; }
"int"\n|"int"\r\n                   {if (flagL) printf("INT\n"); yylineno++; yycolumnno = 1; }

"float32"                           {if (flagL) printf("FLOAT32\n"); yycolumnno += yyleng; }
"bool"                              {if (flagL) printf("BOOL\n"); yycolumnno += yyleng; }
"string"                            {if (flagL) printf("STRING\n"); yycolumnno += yyleng; }
"fmt.Println"                       {if (flagL) printf("PRINT\n"); yycolumnno += yyleng; }
"strconv.Atoi"                      {if (flagL) printf("PARSEINT\n"); yycolumnno += yyleng; }
"func"                              {if (flagL) printf("FUNC\n"); yycolumnno += yyleng; }
"os.Args"                           {if (flagL) printf("CMDARGS\n"); yycolumnno += yyleng; }

{id}                                {if (flagL) printf("ID(%s)\n", yytext); yycolumnno += yyleng; }
{id}\r\n                            {if (flagL) printf("ID(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 2, yytext); yylineno++; yycolumnno = 1; }
{id}\n                              {if (flagL) printf("ID(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 1, yytext); yylineno++; yycolumnno = 1;}

\"                                  {BEGIN STRLIT; yycolumnno += yyleng; }

<STRLIT>\n|\r\n                     {printf("Line %d, column %d: unterminated string literal\n", yylineno, yycolumnno - 1); BEGIN 0; yylineno++; yycolumnno = 1; }
<STRLIT>\\n|\\f|\\r|\\t|\\\"|\\\    {if (flagL) printf("%s", yytext); yycolumnno += yyleng; }
<STRLIT>\"" "|\"\n|\"\r\n           {if (flagL && !flagError) printf("STRLIT(\"%s\")\nSEMICOLON\n", strlit_buffer); BEGIN 0; yylineno++; yycolumnno = 1; } 
<STRLIT>\"                          {if (flagL && !flagError) printf("STRLIT(\"%s\")\n", strlit_buffer); BEGIN 0; yycolumnno += yyleng; }
<STRLIT>\\.                         {printf("Line %d, column %d: invalid escape sequence (%s)\n", yylineno, yycolumnno, yytext); flagError = 1; yycolumnno += yyleng; }
<STRLIT>.                           {
                                    if (strlit_buffer_pos == strlit_buffer_alloc_size - 1) {
                                        strlit_buffer_alloc_size += 100;
                                        strlit_buffer = (char *) realloc(strlit_buffer, strlit_buffer_alloc_size);
                                    }
                                    strcat(strlit_buffer, yytext);
                                    strlit_buffer_pos++;
                                    yycolumnno += yyleng; 
                                    }
<STRLIT><<EOF>>                     {printf("Line %d, column %d: unterminated string literal\n", yylineno, yycolumnno); BEGIN 0; yycolumnno += yyleng; }   

{O}                                 {if (flagL) printf("INTLIT(%s)\n", yytext); yycolumnno += yyleng; }
{O}\r\n                             {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 2, yytext); yylineno++;  yycolumnno = 1; }
{O}\n                               {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 1, yytext); yylineno++;  yycolumnno = 1; }

{H}                                 {if (flagL) printf("INTLIT(%s)\n", yytext); yycolumnno += yyleng; }
{H}\r\n                             {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 2, yytext); yylineno++;  yycolumnno = 1; }
{H}\n                               {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 1, yytext); yylineno++;  yycolumnno = 1; }

0([0-7]*[89a-zA-Z]+[0-7]*)+         {printf("Line %d, column %d: invalid octal constant (%s)\n", yylineno, yycolumnno, yytext); yycolumnno += yyleng; }

{D}                                 {if (flagL) printf("INTLIT(%s)\n", yytext); yycolumnno += yyleng; }
{D}\r\n                             {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 2, yytext); yylineno++;  yycolumnno = 1; }
{D}\n                               {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 1, yytext); yylineno++;  yycolumnno = 1; }         

(({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D}              {if (flagL) printf("REALLIT(%s)\n", yytext); yycolumnno += yyleng; }
((({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D})\r\n        {if (flagL) printf("REALLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 2, yytext); yylineno++; yycolumnno = 1; }
((({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D})\n          {if (flagL) printf("REALLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 1, yytext); yylineno++; yycolumnno = 1; }  

"//"                                {BEGIN SINGLECOMM; initialLine = yylineno; initialColumn = yycolumnno; yycolumnno += yyleng; }
"/*"                                {BEGIN DOUBLECOMM; initialLine = yylineno; initialColumn = yycolumnno; yycolumnno += yyleng; }

<SINGLECOMM>.                       {yycolumnno += yyleng; }
<SINGLECOMM>{newline}               {BEGIN 0; yylineno++;  yycolumnno = 1; }

<DOUBLECOMM>.                       {yycolumnno += yyleng; }
<DOUBLECOMM>{newline}               {yylineno++;  yycolumnno = 1; }
<DOUBLECOMM>"*/"                    {BEGIN 0; yycolumnno += yyleng; }
<DOUBLECOMM><<EOF>>                 {printf("Line %d, column %d: unterminated comment\n", initialLine, initialColumn); BEGIN 0; yycolumnno += yyleng; }

{newline}                           {yylineno++; yycolumnno = 1; }
.                                   {printf("Line %d, column %d: illegal character (%s)\n", yylineno, yycolumnno, yytext); yycolumnno += yyleng; }

%%

int main(int argc, char *argv[ ])
{
    if (argc > 1) {
        if (strcmp(argv[1], "-l") == 0) {
            flagL = 1;
        }
    }

    strlit_buffer = (char*) malloc(100);

    yylex();

    free(strlit_buffer);
    return 0;
}

int yywrap() {
    return 1;
}
