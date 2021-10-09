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
    char left_bracket = '(';
    int yycolumnno = 1;
%}

%X SINGLECOMM DOUBLECOMM STRLIT
%%

" "                                 {;}                                

{reserved}                          {printf("RESERVED\r\n");}

";"                                 {printf("SEMICOLON\r\n");}
","                                 {printf("COMMA\r\n");}
"_"                                 {printf("BLANKID\r\n");}
"="                                 {printf("ASSIGN\r\n");}
"*"                                 {printf("STAR\r\n");}
"/"                                 {printf("DIV\r\n");}
"-"                                 {printf("MINUS\r\n");}
"+"                                 {printf("PLUS\r\n");}
"=="                                {printf("EQ\r\n");}
">="                                {printf("GE\r\n");}
">"                                 {printf("GT\r\n");}
"{"                                 {printf("LBRACE\r\n");}
"<="                                {printf("LE\r\n");}
"("                                 {printf("LPAR\r\n");}
"["                                 {printf("LSQ\r\n");}
"<"                                 {printf("LT\r\n");}
"%"                                 {printf("MOD\r\n");}
"!="                                {printf("NE\r\n");}
"!"                                 {printf("NOT\r\n");}
"&&"                                {printf("AND\r\n");}
"||"                                {printf("OR\r\n");}

"}"                                 {printf("RBRACE\r\n");}
"}"{newline}                        {printf("RBRACE\r\nSEMICOLON\r\n"); yylineno++;}

")"                                 {printf("RPAR\r\n");}
")"{newline}                        {printf("RPAR\r\nSEMICOLON\r\n"); yylineno++;}

"]"                                 {printf("RSQ\r\n");}
"]"{newline}                        {printf("RSQ\r\nSEMICOLON\r\n"); yylineno++;}

"package"                           {printf("PACKAGE\r\n");}

"return"                            {printf("RETURN\r\n");}
"return"{newline}                   {printf("RETURN\r\nSEMICOLON\r\n"); yylineno++;}

"else"                              {printf("ELSE\r\n");}
"for"                               {printf("FOR\r\n");}
"if"                                {printf("IF\r\n");}
"var"                               {printf("VAR\r\n");}
"int"                               {printf("INT\r\n");}
"float32"                           {printf("FLOAT32\r\n");}
"bool"                              {printf("BOOL\r\n");}
"string"                            {printf("STRING\r\n");}
"fmt.Println"                       {printf("PRINT\r\n");}
"strconv.Atoi"                      {printf("PARSEINT\r\n");}
"func"                              {printf("FUNC\r\n");}
"os.Args"                           {printf("CMDARGS\r\n");}

{id}                                {printf("ID(%s)\r\n", yytext);}
{id}\r\n                            {printf("ID(%.*s)\r\nSEMICOLON\r\n", strlen(yytext) - 2, yytext); yylineno++;}
{id}\n                              {printf("ID(%.*s)\r\nSEMICOLON\r\n", strlen(yytext) - 1, yytext); yylineno++;}

\"                                  {printf("STRLIT%c\r\n", left_bracket); BEGIN STRLIT;}

<STRLIT>\n|\r\n                     {ECHO;}
<STRLIT>\\n|\\f|\\r|\\t|\\\"|\\\    {ECHO;}
<STRLIT>\"                          {printf(")"); BEGIN 0;}
<STRLIT>.                           {ECHO;}
<STRLIT><<EOF>>                     {printf("Line <%d>, column <%d>: unterminated string literal\r\n", yylineno, yycolumnno);}   

{O}                                 {printf("INTLIT(%s)\r\n", yytext);}
{O}\r\n                             {printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", strlen(yytext) - 2, yytext); yylineno++;}
{O}\n                               {printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", strlen(yytext) - 1, yytext); yylineno++;}

{H}                                 {printf("INTLIT(%s)\r\n", yytext);}
{H}\r\n                             {printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", strlen(yytext) - 2, yytext); yylineno++;}
{H}\n                               {printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", strlen(yytext) - 1, yytext); yylineno++;}

{D}                                 {printf("INTLIT(%s)\r\n", yytext);}
{D}\r\n                             {printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", strlen(yytext) - 2, yytext); yylineno++;}
{D}\n                               {printf("INTLIT(%.*s)\r\nSEMICOLON\r\n", strlen(yytext) - 1, yytext); yylineno++;}         

(({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D}              {printf("REALLIT(%s)\r\n", yytext);}
((({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D})\r\n        {printf("REALLIT(%.*s)\r\nSEMICOLON\r\n", strlen(yytext) - 2, yytext); yylineno++;}
((({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D})\n          {printf("REALLIT(%.*s)\r\nSEMICOLON\r\n", strlen(yytext) - 1, yytext); yylineno++;}  

"//"                                {BEGIN SINGLECOMM;}
"/*"                                {BEGIN DOUBLECOMM;}

<SINGLECOMM>.                       ;
<SINGLECOMM>{newline}               {BEGIN 0; yylineno++;}

<DOUBLECOMM>.                       ;
<DOUBLECOMM>{newline}               {yylineno++;}
<DOUBLECOMM>"*/"                    {BEGIN 0;}
<DOUBLECOMM><<EOF>>                 {printf("Line <%d>, column <%d>: unterminated comment\r\n", yylineno, yycolumnno);}

{newline}                           {yylineno++; yycolumnno=0;}
.                                   {printf("Line <%d>, column <%d>: illegal character (<%s>)\r\n", yylineno, yycolumnno, yytext);}

%%

int main()
{
yylex(); return 0;
}

int yywrap() {
return 1;
}