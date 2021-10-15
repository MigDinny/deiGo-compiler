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
    int initialLine, initialColumn = 1;
    int flagL, flagError, flagEOF, flagEOF_strlit, strlit_buffer_pos = 0;
    char left_bracket = '(';
    int yycolumnno = 1;
    char *strlit_buffer;
    int strlit_buffer_alloc_size = 100;

%}

%X SINGLECOMM DOUBLECOMM STRLIT
%%

" "                                 {yycolumnno += yyleng;}
" "*"//"                            { BEGIN SINGLECOMM; initialLine = yylineno; yycolumnno += yyleng; initialColumn = yycolumnno - 2;}
" "*"/*"                            { BEGIN DOUBLECOMM; initialLine = yylineno; yycolumnno += yyleng; initialColumn = yycolumnno - 2;}            
";"                                 {if (flagL) printf("SEMICOLON\n"); yycolumnno += yyleng; flagEOF = 0;}

<SINGLECOMM>.                       {yycolumnno += yyleng;}
<SINGLECOMM>{newline}               {if (flagEOF == 1 && flagL) { printf("SEMICOLON\n"); flagEOF = 0;} BEGIN 0; yylineno++;  yycolumnno = 1;}

<DOUBLECOMM><<EOF>>                 {if (flagEOF == 1 && flagL) { printf("SEMICOLON\n"); flagEOF = 0;} printf("Line %d, column %d: unterminated comment\n", initialLine, initialColumn); yyterminate();}
<DOUBLECOMM>"*/"                    {yycolumnno += yyleng; BEGIN 0;}
<DOUBLECOMM>{newline}               {if (flagEOF == 1 && flagL) { printf("SEMICOLON\n"); flagEOF = 0;} yylineno++; yycolumnno = 1;}
<DOUBLECOMM>.                       {yycolumnno += yyleng;}

{reserved}                          {if (flagL) printf("RESERVED(%s)\n", yytext); yycolumnno += yyleng; flagEOF = 0;}
","                                 {if (flagL) printf("COMMA\n"); yycolumnno += yyleng; flagEOF = 0;}
"_"                                 {if (flagL) printf("BLANKID\n"); yycolumnno += yyleng; flagEOF = 0;}
"="                                 {if (flagL) printf("ASSIGN\n"); yycolumnno += yyleng; flagEOF = 0;}
"*"                                 {if (flagL) printf("STAR\n"); yycolumnno += yyleng; flagEOF = 0;}
"/"                                 {if (flagL) printf("DIV\n"); yycolumnno += yyleng; flagEOF = 0;}
"-"                                 {if (flagL) printf("MINUS\n"); yycolumnno += yyleng; flagEOF = 0;}
"+"                                 {if (flagL) printf("PLUS\n"); yycolumnno += yyleng; flagEOF = 0;}
"=="                                {if (flagL) printf("EQ\n"); yycolumnno += yyleng; flagEOF = 0;}
">="                                {if (flagL) printf("GE\n"); yycolumnno += yyleng; flagEOF = 0;}
">"                                 {if (flagL) printf("GT\n"); yycolumnno += yyleng; flagEOF = 0;}
"{"                                 {if (flagL) printf("LBRACE\n"); yycolumnno += yyleng; flagEOF = 0;}
"<="                                {if (flagL) printf("LE\n"); yycolumnno += yyleng; flagEOF = 0;}
"("                                 {if (flagL) printf("LPAR\n"); yycolumnno += yyleng; flagEOF = 0;}
"["                                 {if (flagL) printf("LSQ\n"); yycolumnno += yyleng; flagEOF = 0;}
"<"                                 {if (flagL) printf("LT\n"); yycolumnno += yyleng; flagEOF = 0;}
"%"                                 {if (flagL) printf("MOD\n"); yycolumnno += yyleng; flagEOF = 0;}
"!="                                {if (flagL) printf("NE\n"); yycolumnno += yyleng; flagEOF = 0;}
"!"                                 {if (flagL) printf("NOT\n"); yycolumnno += yyleng; flagEOF = 0;}
"&&"                                {if (flagL) printf("AND\n"); yycolumnno += yyleng; flagEOF = 0;}
"||"                                {if (flagL) printf("OR\n"); yycolumnno += yyleng; flagEOF = 0;}
"package"                           {if (flagL) printf("PACKAGE\n"); yycolumnno += yyleng; flagEOF = 0;}
"else"                              {if (flagL) printf("ELSE\n"); yycolumnno += yyleng; flagEOF = 0;}
"for"                               {if (flagL) printf("FOR\n"); yycolumnno += yyleng; flagEOF = 0;}
"if"                                {if (flagL) printf("IF\n"); yycolumnno += yyleng; flagEOF = 0;}
"var"                               {if (flagL) printf("VAR\n"); yycolumnno += yyleng; flagEOF = 0;}
"int"                               {if (flagL) printf("INT\n"); yycolumnno += yyleng; flagEOF = 0;}
"float32"                           {if (flagL) printf("FLOAT32\n"); yycolumnno += yyleng; flagEOF = 0;}
"bool"                              {if (flagL) printf("BOOL\n"); yycolumnno += yyleng; flagEOF = 0;}
"string"                            {if (flagL) printf("STRING\n"); yycolumnno += yyleng; flagEOF = 0;}
"fmt.Println"                       {if (flagL) printf("PRINT\n"); yycolumnno += yyleng; flagEOF = 0;}
"strconv.Atoi"                      {if (flagL) printf("PARSEINT\n"); yycolumnno += yyleng; flagEOF = 0;}
"func"                              {if (flagL) printf("FUNC\n"); yycolumnno += yyleng; flagEOF = 0;}
"os.Args"                           {if (flagL) printf("CMDARGS\n"); yycolumnno += yyleng; flagEOF = 0;}

"}"                                 {if (flagL) printf("RBRACE\n"); yycolumnno += yyleng; flagEOF = 1;}
")"                                 {if (flagL) printf("RPAR\n"); yycolumnno += yyleng; flagEOF = 1;}
"]"                                 {if (flagL) printf("RSQ\n"); yycolumnno += yyleng; flagEOF = 1;}
"return"                            {if (flagL) printf("RETURN\n"); yycolumnno += yyleng; flagEOF = 1;}

{id}                                {if (flagL) printf("ID(%s)\n", yytext); yycolumnno += yyleng; flagEOF = 1;}
{int_lit}                           {if (flagL) printf("INTLIT(%s)\n", yytext); yycolumnno += yyleng; flagEOF = 1;}
{real_lit}                          {if (flagL) printf("REALLIT(%s)\n", yytext); yycolumnno += yyleng; flagEOF = 1;}

0([0-7]*[89]+[0-7]*)+               {printf("Line %d, column %d: invalid octal constant (%s)\n", yylineno, yycolumnno, yytext); yycolumnno += yyleng; flagEOF = 0;}

\"                                  {BEGIN STRLIT; flagError = 0; flagEOF = 0;  initialLine = yylineno; initialColumn = yycolumnno; yycolumnno += yyleng;}

<STRLIT>\"                          {BEGIN 0; if (flagL && !flagError) printf("STRLIT(\"%s\")\n", strlit_buffer); strlit_buffer[0] = 0; strlit_buffer_pos = 0; yycolumnno += yyleng; flagEOF = 1;}
<STRLIT>[^\\]|{escape_sequence}     {
                                    if (strlit_buffer_pos == strlit_buffer_alloc_size - 1) {
                                        strlit_buffer_alloc_size += 100;
                                        strlit_buffer = (char *) realloc(strlit_buffer, strlit_buffer_alloc_size);
                                    }
                                    strcat(strlit_buffer, yytext);
                                    strlit_buffer_pos++;
                                    yycolumnno += yyleng; 
                                    }
<STRLIT>\\[^\n\r]?                  {printf("Line %d, column %d: invalid escape sequence (%s)\n", yylineno, yycolumnno, yytext); flagError = 1; yycolumnno += yyleng; }
<STRLIT>{newline}                   {BEGIN 0; printf("Line %d, column %d: unterminated string literal\n", initialLine, initialColumn); strlit_buffer[0] = 0; strlit_buffer_pos = 0; yylineno++; yycolumnno = 1; }
<STRLIT><<EOF>>                     {BEGIN 0; printf("Line %d, column %d: unterminated string literal\n", initialLine, initialColumn); yycolumnno += yyleng;}   

{newline}                           {if (flagEOF == 1 && flagL && !flagError) printf("SEMICOLON\n"); yylineno++; yycolumnno = 1; flagEOF = 0;}
\t                                  {yycolumnno += yyleng;}
.                                   {printf("Line %d, column %d: illegal character (%s)\n", yylineno, yycolumnno, yytext); yycolumnno += yyleng; flagEOF = 0;}

<<EOF>>                             {if (flagEOF == 1) printf("SEMICOLON\n"); yyterminate();}                                

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
