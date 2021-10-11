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
    int flagL = 0;
    char left_bracket = '(';
    int yycolumnno = 1;
%}

%X SINGLECOMM DOUBLECOMM STRLIT
%%

" "                                 {;}                                

{reserved}                          {if (flagL) printf("RESERVED\n");}

";"                                 {if (flagL) printf("SEMICOLON\n");}
","                                 {if (flagL) printf("COMMA\n");}
"_"                                 {if (flagL) printf("BLANKID\n");}
"="                                 {if (flagL) printf("ASSIGN\n");}
"*"                                 {if (flagL) printf("STAR\n");}
"/"                                 {if (flagL) printf("DIV\n");}
"-"                                 {if (flagL) printf("MINUS\n");}
"+"                                 {if (flagL) printf("PLUS\n");}
"=="                                {if (flagL) printf("EQ\n");}
">="                                {if (flagL) printf("GE\n");}
">"                                 {if (flagL) printf("GT\n");}
"{"                                 {if (flagL) printf("LBRACE\n");}
"<="                                {if (flagL) printf("LE\n");}
"("                                 {if (flagL) printf("LPAR\n");}
"["                                 {if (flagL) printf("LSQ\n");}
"<"                                 {if (flagL) printf("LT\n");}
"%"                                 {if (flagL) printf("MOD\n");}
"!="                                {if (flagL) printf("NE\n");}
"!"                                 {if (flagL) printf("NOT\n");}
"&&"                                {if (flagL) printf("AND\n");}
"||"                                {if (flagL) printf("OR\n");}

"}"                                 {if (flagL) printf("RBRACE\n");}
"}"{newline}                        {if (flagL) printf("RBRACE\nSEMICOLON\n"); yylineno++;}

")"                                 {if (flagL) printf("RPAR\n");}
")"{newline}                        {if (flagL) printf("RPAR\nSEMICOLON\n"); yylineno++;}

"]"                                 {if (flagL) printf("RSQ\n");}
"]"{newline}                        {if (flagL) printf("RSQ\r\nSEMICOLON\n"); yylineno++;}

"package"                           {if (flagL) printf("PACKAGE\n");}

"return"                            {if (flagL) printf("RETURN\n");}
"return"{newline}                   {if (flagL) printf("RETURN\nSEMICOLON\n"); yylineno++;}

"else"                              {if (flagL) printf("ELSE\n");}
"for"                               {if (flagL) printf("FOR\n");}
"if"                                {if (flagL) printf("IF\n");}
"var"                               {if (flagL) printf("VAR\n");}
"int"                               {if (flagL) printf("INT\n");}
"float32"                           {if (flagL) printf("FLOAT32\n");}
"bool"                              {if (flagL) printf("BOOL\n");}
"string"                            {if (flagL) printf("STRING\n");}
"fmt.Println"                       {if (flagL) printf("PRINT\n");}
"strconv.Atoi"                      {if (flagL) printf("PARSEINT\n");}
"func"                              {if (flagL) printf("FUNC\n");}
"os.Args"                           {if (flagL) printf("CMDARGS\n");}

{id}                                {if (flagL) printf("ID(%s)\n", yytext);}
{id}\r\n                            {if (flagL) printf("ID(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 2, yytext); yylineno++;}
{id}\n                              {if (flagL) printf("ID(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 1, yytext); yylineno++;}

\"                                  {if (flagL) printf("STRLIT%c", left_bracket); BEGIN STRLIT;}

<STRLIT>\n|\r\n                     {if (flagL) printf("%s", yytext);}
<STRLIT>\\n|\\f|\\r|\\t|\\\"|\\\    {if (flagL) printf("%s", yytext);}
<STRLIT>\"                          {if (flagL) printf(")\n"); BEGIN 0;}
<STRLIT>\\.                         {printf("Line <>, column <>: invalid escape sequence (<%s>)\n", yytext);}
<STRLIT>.                           {if (flagL) printf("%s", yytext);}
<STRLIT><<EOF>>                     {printf("Line <%d>, column <%d>: unterminated string literal\n", yylineno, yycolumnno); BEGIN 0;}   

{O}                                 {if (flagL) printf("INTLIT(%s)\n", yytext);}
{O}\r\n                             {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 2, yytext); yylineno++;}
{O}\n                               {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 1, yytext); yylineno++;}

{H}                                 {if (flagL) printf("INTLIT(%s)\n", yytext);}
{H}\r\n                             {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 2, yytext); yylineno++;}
{H}\n                               {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 1, yytext); yylineno++;}

0([0-7]*[89a-zA-Z]+[0-7]*)+         {printf("Line <%d>, column <%d>: invalid octal constant (%s)\n", yylineno, yycolumnno, yytext);}

{D}                                 {if (flagL) printf("INTLIT(%s)\n", yytext);}
{D}\r\n                             {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 2, yytext); yylineno++;}
{D}\n                               {if (flagL) printf("INTLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 1, yytext); yylineno++;}         

(({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D}              {if (flagL) printf("REALLIT(%s)\n", yytext);}
((({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D})\r\n        {if (flagL) printf("REALLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 2, yytext); yylineno++;}
((({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D})\n          {if (flagL) printf("REALLIT(%.*s)\nSEMICOLON\n", (int) strlen(yytext) - 1, yytext); yylineno++;}  

"//"                                {BEGIN SINGLECOMM;}
"/*"                                {BEGIN DOUBLECOMM;}

<SINGLECOMM>.                       {;}
<SINGLECOMM>{newline}               {BEGIN 0; yylineno++;}

<DOUBLECOMM>.                       {;}
<DOUBLECOMM>{newline}               {yylineno++;}
<DOUBLECOMM>"*/"                    {BEGIN 0;}
<DOUBLECOMM><<EOF>>                 {printf("Line <%d>, column <%d>: unterminated comment\n", yylineno, yycolumnno); BEGIN 0;}

{newline}                           {yylineno++; yycolumnno=0;}
.                                   {printf("Line <%d>, column <%d>: illegal character (<%s>)\n", yylineno, yycolumnno, yytext);}

%%

int main(int argc, char *argv[ ])
{
    if (argc > 1) {
        if (strcmp(argv[1], "-l") == 0) {
            flagL = 1;
        }
    }

    yylex();
    return 0;
}

int yywrap() {
    return 1;
}