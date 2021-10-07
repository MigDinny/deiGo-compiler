id      [a-zA-Z_][a-zA-Z_0-9]*
O       0[0-7]+
H       0x[0-9a-fA-F]+
D       [0-9]+
reserved                    ["break", "case", "chan", "const", "continue", "default", "defer", fallthrough", "func", "go", "goto", "import", "interface", "map"]
reserved2                   ["range", "select", "struct", "switch", "type", "var", "++", "--"]
letter                      [a-zA-Z]
digit                       [0-9]
%%

 // tokens deiGo

 // STRLIT: seq carateres exceto "carriage return", "newline", "" E/OU sequencias de escape entre aspas duplas; apenas sequencias \f, \n, \r, \t, \\ e \ são da linguagem" 
 // REALLIT: 12. ; 12.5 ; 12.5e+13 ; 12.5e-13 ; 12.e+13 ; 12.e-13 ; 12e+13 ; 12e-13   -> e minúsculo ou E maiúsculo ; sinal opcional

";"           {printf("SEMICOLON\n");}
","           {printf("COMMA\n");}
"_"             {printf("BLANKID\n");}
"="           {printf("ASSIGN\n");}
"*"           {printf("STAR\n");}
"//"          {printf("DIV\n");}
"-"           {printf("MINUS\n");}
"+"         {printf("PLUS\n");}
"=="         {printf("EQ\n");}
">="         {printf("GE\n");}
">"         {printf("GT\n");}
"{"         {printf("LBRACE\n");}
"<="         {printf("LE\n");}
"("         {printf("LPAR\n");}
"["         {printf("LSQ\n");}
"<"         {printf("LT\n");}
"%"         {printf("MOD\n");}
"!="         {printf("NE\n");}
"!"           {printf("NOT\n");}
"&&"          {printf("AND\n");}
"||"          {printf("OR\n");}
"}"         {printf("RBRACE\n");}
")"         {printf("RPAR\n");}

"]"                         {printf("RSQ\n");}
"package"                   {printf("PACKAGE\n");}

"return"\n                  {printf("RETURN\nSEMICOLON\n");}
"return"                    {printf("RETURN\n");}

"else"                      {printf("ELSE\n");}
"for"                       {printf("FOR\n");}
"if"                        {printf("IF\n");}
"var"                       {printf("VAR\n");}
"int"                       {printf("INT\n");}
"float32"                   {printf("FLOAT32\n");}
"bool"                      {printf("BOOL"\n);}
"string"                    {printf("STRING\n");}
"fmt.Println"               {printf("PRINT\n");}
"strconv.Atoi"              {printf("PARSEINT\n");}
"func"                      {printf("FUNC\n");}
"os.Args"                   {printf("CMDARGS\n");}

{id}        {printf("ID(%s)\n", yytext);}
{O}         {printf("INTLIT(%s)\n", yytext);}
{H}         {printf("INTLIT(%s)\n", yytext);}
{D}         {printf("INTLIT(%s)\n", yytext);}

 // reserved Go

({reserved}|{reserved2})    {printf("RESERVED\n");}

" "     ;
"\n"    ;
.   {ECHO;}

%%
int main()
{
yylex(); return 0;
}
int yywrap() {
return 1;
}
