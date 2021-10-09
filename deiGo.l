%{
int yycolumnno = 1;
%}
id      [a-zA-Z_][a-zA-Z_0-9]*
O       0[0-7]+
H       0x[0-9a-fA-F]+
d                           [0-9]*
D       [0-9]+
reserved                    (break|case|chan|const|continue|default|defer|fallthrough|go|goto|import|interface|map|range|select|struct|switch|type|"++"|"--")
ch                          [a-zA-Z]
exp                         [eE]
sig                         [-+]
esc                         (\f|\n|\r|\t|\\|\")* 
strlit                      ("carriage return"|"newline"|\"\")             
newline                     \r\n|\n
illegal_character         [^a-zA-Z0-9;,._=*<>!%&|\"-\"+{}()[\]\\] 
%%

 // tokens deiGo

 // STRLIT: seq carateres exceto "carriage return", "newline", "" E/OU sequencias de escape entre aspas duplas; apenas sequencias \f, \n, \r, \t, \\ e \ são da linguagem" 
 // REALLIT: 12. ; 12.5 ; 12.5e+13 ; 12.5e-13 ; 12.e+13 ; 12.e-13 ; 12e+13 ; 12e-13   -> e minúsculo ou E maiúsculo ; sinal opcional

" "                         {;}
{reserved}                  {printf("RESERVED\r\n");}

";"                         {printf("SEMICOLON\r\n");}
","                         {printf("COMMA\r\n");}
"_"                         {printf("BLANKID\r\n");}
"="                         {printf("ASSIGN\r\n");}
"*"                         {printf("STAR\r\n");}
"//"                        {printf("DIV\r\n");}
"-"                         {printf("MINUS\r\n");}
"+"                         {printf("PLUS\r\n");}
"=="                        {printf("EQ\r\n");}
">="                        {printf("GE\r\n");}
">"                         {printf("GT\r\n");}
"{"                         {printf("LBRACE\r\n");}
"<="                        {printf("LE\r\n");}
"("                         {printf("LPAR\r\n");}
"["                         {printf("LSQ\r\n");}
"<"                         {printf("LT\r\n");}
"%"                         {printf("MOD\r\n");}
"!="                        {printf("NE\r\n");}
"!"                         {printf("NOT\r\n");}
"&&"                        {printf("AND\r\n");}
"||"                        {printf("OR\r\n");}

"}"                         {printf("RBRACE\r\n");}
"}"{newline}                {printf("RBRACE\r\nSEMICOLON\r\n");}

")"                         {printf("RPAR\r\n");}
")"{newline}                {printf("RPAR\r\nSEMICOLON\r\n");}

"]"                         {printf("RSQ\r\n");}
"]"{newline}                {printf("RSQ\r\nSEMICOLON\r\n");}

"package"                   {printf("PACKAGE\r\n");}

"return"                    {printf("RETURN\r\n");}
"return"{newline}           {printf("RETURN\r\nSEMICOLON\r\n");}

"else"                      {printf("ELSE\r\n");}
"for"                       {printf("FOR\r\n");}
"if"                        {printf("IF\r\n");}
"var"                       {printf("VAR\r\n");}
"int"                       {printf("INT\r\n");}
"float32"                   {printf("FLOAT32\r\n");}
"bool"                      {printf("BOOL\r\n");}
"string"                    {printf("STRING\r\n");}
"fmt.Println"               {printf("PRINT\r\n");}
"strconv.Atoi"              {printf("PARSEINT\r\n");}
"func"                      {printf("FUNC\r\n");}
"os.Args"                   {printf("CMDARGS\r\n");}

{id}                        {printf("ID(%s)\r\n", yytext);}
{id}{newline}               {printf("ID(%s)\r\nSEMICOLON\r\n", yytext);}

{id}        {printf("ID(%s)\r\n", yytext);}
{id}{newline} {printf("ID(%s)\r\nSEMICOLON\r\n", yytext); yylineno++;}

\"[^{strlit}]*{esc}?\"      {printf("STRLIT(%s)\r\n", yytext);}
\"[^{strlit}]*{esc}?\"{newline}      {printf("STRLIT(%s)\r\n", yytext);}

{O}                         {printf("INTLIT(%s)\r\n", yytext);}
{O}{newline}                {printf("INTLIT(%s)\r\nSEMICOLON\r\n", yytext);}
{H}                         {printf("INTLIT(%s)\r\n", yytext);}
{H}{newline}                {printf("INTLIT(%s)\r\nSEMICOLON\r\n", yytext);}
{D}                         {printf("INTLIT(%s)\r\n", yytext);}
{D}{newline}                {printf("INTLIT(%s)\r\nSEMICOLON\r\n", yytext);}

(({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D} {
                            printf("REALLIT(%s)\r\n", yytext);
                            }
(({d}"."{D})|({D}+"."))({exp}{sig}?{D})?|{D}{exp}{sig}?{D}{newline} {
                            printf("REALLIT(%s)\r\nSEMICOLON\r\n", yytext);
                            }


{newline}    {yylineno++; yycolumnno=0;}

.   {printf("Line <%d>, column <%d>: illegal character (<%s>)\r\n", yylineno, yycolumnno, yytext);}

%%

int main()
{
yylex(); return 0;
}

int yywrap() {
return 1;
}