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

{reserved}                          {if (flagL) printf("RESERVED\r\n");}

";"                                 {if (flagL) printf("SEMICOLON\r\n");}
","                                 {if (flagL) printf("COMMA\r\n");}
"_"                                 {if (flagL) printf("BLANKID\r\n");}
"="                                 {if (flagL) printf("ASSIGN\r\n");}
"*"                                 {if (flagL) printf("STAR\r\n");}
"/"                                 {if (flagL) printf("DIV\r\n");}
"-"                                 {if (flagL) printf("MINUS\r\n");}
"+"                                 {if (flagL) printf("PLUS\r\n");}
"=="                                {if (flagL) printf("EQ\r\n");}
">="                                {if (flagL) printf("GE\r\n");}
">"                                 {if (flagL) printf("GT\r\n");}
"{"                                 {if (flagL) printf("LBRACE\r\n");}
"<="                                {if (flagL) printf("LE\r\n");}
"("                                 {if (flagL) printf("LPAR\r\n");}
"["                                 {if (flagL) printf("LSQ\r\n");}
"<"                                 {if (flagL) printf("LT\r\n");}
"%"                                 {if (flagL) printf("MOD\r\n");}
"!="                                {if (flagL) printf("NE\r\n");}
"!"                                 {if (flagL) printf("NOT\r\n");}
"&&"                                {if (flagL) printf("AND\r\n");}
"||"                                {if (flagL) printf("OR\r\n");}

"}"                                 {if (flagL) printf("RBRACE\r\n");}
"}"{newline}                        {if (flagL) printf("RBRACE\r\nSEMICOLON\r\n"); yylineno++;}

")"                                 {if (flagL) printf("RPAR\r\n");}
")"{newline}                        {if (flagL) printf("RPAR\r\nSEMICOLON\r\n"); yylineno++;}

"]"                                 {if (flagL) printf("RSQ\r\n");}
"]"{newline}                        {if (flagL) printf("RSQ\r\nSEMICOLON\r\n"); yylineno++;}

"package"                           {if (flagL) printf("PACKAGE\r\n");}

"return"                            {if (flagL) printf("RETURN\r\n");}
"return"{newline}                   {if (flagL) printf("RETURN\r\nSEMICOLON\r\n"); yylineno++;}

"else"                              {if (flagL) printf("ELSE\r\n");}
"for"                               {if (flagL) printf("FOR\r\n");}
"if"                                {if (flagL) printf("IF\r\n");}
"var"                               {if (flagL) printf("VAR\r\n");}
"int"                               {if (flagL) printf("INT\r\n");}
"float32"                           {if (flagL) printf("FLOAT32\r\n");}
"bool"                              {if (flagL) printf("BOOL\r\n");}
"string"                            {if (flagL) printf("STRING\r\n");}
"fmt.Println"                       {if (flagL) printf("PRINT\r\n");}
"strconv.Atoi"                      {if (flagL) printf("PARSEINT\r\n");}
"func"                              {if (flagL) printf("FUNC\r\n");}
"os.Args"                           {if (flagL) printf("CMDARGS\r\n");}

{id}                                {if (flagL) printf("ID(%s)\r\n", yytext);}
{id}\r\n                            {if (flagL) printf("ID(%.*s)\r\nSEMICOLON\r\n", (int) strlen(yytext) - 2, yytext); yylineno++;}
{id}\n                              {if (flagL) printf("ID(%.*s)\r\nSEMICOLON\r\n", (int) strlen(yytext) - 1, yytext); yylineno++;}

\"                                  {if (flagL) printf("STRLIT%c", left_bracket); BEGIN STRLIT;}

<STRLIT>\n|\r\n                     {if (flagL) printf("%s", yytext);}
<STRLIT>\\n|\\f|\\r|\\t|\\\"|\\\    {if (flagL) printf("%s", yytext);}
<STRLIT>\"                          {if (flagL) printf(")\n"); BEGIN 0;}
<STRLIT>\\.                         {printf("Line <>, column <>: invalid escape sequence (<%s>)\n", yytext);}
<STRLIT>.                           {if (flagL) printf("%s", yytext);}
<STRLIT><<EOF>>                     {printf("Line <%d>, column <%d>: unterminated string literal\r\n", yylineno, yycolumnno); BEGIN 0;}   

{O}                                 {if (flagL) printf("INTLIT(%s)\r\n", yytext);}
{O}\r\n                             {if (flagL) printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", (int) strlen(yytext) - 2, yytext); yylineno++;}
{O}\n                               {if (flagL) printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", (int) strlen(yytext) - 1, yytext); yylineno++;}

{H}                                 {if (flagL) printf("INTLIT(%s)\r\n", yytext);}
{H}\r\n                             {if (flagL) printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", (int) strlen(yytext) - 2, yytext); yylineno++;}
{H}\n                               {if (flagL) printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", (int) strlen(yytext) - 1, yytext); yylineno++;}

0([0-7]*[89a-zA-Z]+[0-7]*)+         {printf("Line <%d>, column <%d>: invalid octal constant (%s)\n", yylineno, yycolumnno, yytext);}

{D}                                 {if (flagL) printf("INTLIT(%s)\r\n", yytext);}
{D}\r\n                             {if (flagL) printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", (int) strlen(yytext) - 2, yytext); yylineno++;}
{D}\n                               {if (flagL) printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", (int) strlen(yytext) - 1, yytext); yylineno++;}         

(({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D}              {if (flagL) printf("REALLIT(%s)\r\n", yytext);}
((({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D})\r\n        {if (flagL) printf("REALLIT(%.*s)\r\nSEMICOLON\r\n", (int) strlen(yytext) - 2, yytext); yylineno++;}
((({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D})\n          {if (flagL) printf("REALLIT(%.*s)\r\nSEMICOLON\r\n", (int) strlen(yytext) - 1, yytext); yylineno++;}  

"//"                                {BEGIN SINGLECOMM;}
"/*"                                {BEGIN DOUBLECOMM;}

<SINGLECOMM>.                       ;
<SINGLECOMM>{newline}               {BEGIN 0; yylineno++;}

<DOUBLECOMM>.                       ;
<DOUBLECOMM>{newline}               {yylineno++;}
<DOUBLECOMM>"*/"                    {BEGIN 0;}
<DOUBLECOMM><<EOF>>                 {printf("Line <%d>, column <%d>: unterminated comment\r\n", yylineno, yycolumnno); BEGIN 0;}

{newline}                           {yylineno++; yycolumnno=0;}
.                                   {printf("Line <%d>, column <%d>: illegal character (<%s>)\r\n", yylineno, yycolumnno, yytext);}

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