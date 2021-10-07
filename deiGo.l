id      [a-zA-Z_][a-zA-Z_0-9]*
O       0[0-7]+
H       0x[0-9a-fA-F]+
D       [0-9]+


%%

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


{id}        {printf("ID(%s)\n", yytext);}
{O}         {printf("INTLIT(%s)\n", yytext);}
{H}         {printf("INTLIT(%s)\n", yytext);}
{D}         {printf("INTLIT(%s)\n", yytext);}


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
