/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    SEMICOLON = 258,
    COMMA = 259,
    BLANKID = 260,
    ASSIGN = 261,
    STAR = 262,
    DIV = 263,
    MINUS = 264,
    PLUS = 265,
    EQ = 266,
    GE = 267,
    GT = 268,
    LBRACE = 269,
    LE = 270,
    LPAR = 271,
    LSQ = 272,
    LT = 273,
    MOD = 274,
    NE = 275,
    NOT = 276,
    AND = 277,
    OR = 278,
    PACKAGE = 279,
    ELSE = 280,
    FOR = 281,
    IF = 282,
    VAR = 283,
    INT = 284,
    FLOAT32 = 285,
    BOOL = 286,
    STRING = 287,
    PRINT = 288,
    PARSEINT = 289,
    FUNC = 290,
    CMDARGS = 291,
    RBRACE = 292,
    RPAR = 293,
    RSQ = 294,
    RETURN = 295,
    ID = 296,
    RESERVED = 297,
    INTLIT = 298,
    REALLIT = 299,
    STRLIT2 = 300,
    MUL = 301,
    UNARY = 302
  };
#endif
/* Tokens.  */
#define SEMICOLON 258
#define COMMA 259
#define BLANKID 260
#define ASSIGN 261
#define STAR 262
#define DIV 263
#define MINUS 264
#define PLUS 265
#define EQ 266
#define GE 267
#define GT 268
#define LBRACE 269
#define LE 270
#define LPAR 271
#define LSQ 272
#define LT 273
#define MOD 274
#define NE 275
#define NOT 276
#define AND 277
#define OR 278
#define PACKAGE 279
#define ELSE 280
#define FOR 281
#define IF 282
#define VAR 283
#define INT 284
#define FLOAT32 285
#define BOOL 286
#define STRING 287
#define PRINT 288
#define PARSEINT 289
#define FUNC 290
#define CMDARGS 291
#define RBRACE 292
#define RPAR 293
#define RSQ 294
#define RETURN 295
#define ID 296
#define RESERVED 297
#define INTLIT 298
#define REALLIT 299
#define STRLIT2 300
#define MUL 301
#define UNARY 302

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 18 "deiGo.y"

    char *letters;
    node_t *node;

#line 156 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
