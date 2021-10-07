reserved                    ["break", "case", "chan", "const", "continue", "default", "defer", fallthrough", "func", "go", "goto", "import", "interface", "map"]
reserved2                   ["range", "select", "struct", "switch", "type", "var", "++", "--"]
letter                      [a-zA-Z]
digit                       [0-9]
%%

 // tokens deiGo

 // STRLIT: seq carateres exceto "carriage return", "newline", "" E/OU sequencias de escape entre aspas duplas; apenas sequencias \f, \n, \r, \t, \\ e \ são da linguagem" 
 // REALLIT: 12. ; 12.5 ; 12.5e+13 ; 12.5e-13 ; 12.e+13 ; 12.e-13 ; 12e+13 ; 12e-13   -> e minúsculo ou E maiúsculo ; sinal opcional

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

 // reserved Go

({reserved}|{reserved2})    {printf("RESERVED\n");}

%%
int main()
{
yylex(); return 0;
}
int yywrap() {
return 1;
}