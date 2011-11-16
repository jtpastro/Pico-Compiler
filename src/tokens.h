
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
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


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     INT = 258,
     DOUBLE = 259,
     REAL = 260,
     CHAR = 261,
     STRING = 262,
     QUOTE = 263,
     LE = 264,
     GE = 265,
     EQ = 266,
     NE = 267,
     AND = 268,
     OR = 269,
     NOT = 270,
     IF = 271,
     THEN = 272,
     ELSE = 273,
     FOR = 274,
     NEXT = 275,
     WHILE = 276,
     END = 277,
     TRUE = 278,
     FALSE = 279,
     IDF = 280,
     CONST = 281,
     STR_LIT = 282,
     INT_LIT = 283,
     F_LIT = 284
   };
#endif
/* Tokens.  */
#define INT 258
#define DOUBLE 259
#define REAL 260
#define CHAR 261
#define STRING 262
#define QUOTE 263
#define LE 264
#define GE 265
#define EQ 266
#define NE 267
#define AND 268
#define OR 269
#define NOT 270
#define IF 271
#define THEN 272
#define ELSE 273
#define FOR 274
#define NEXT 275
#define WHILE 276
#define END 277
#define TRUE 278
#define FALSE 279
#define IDF 280
#define CONST 281
#define STR_LIT 282
#define INT_LIT 283
#define F_LIT 284




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 13 "pico.y"

  char* cadeia;
  struct _node * no;



/* Line 1676 of yacc.c  */
#line 117 "y.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif

extern YYLTYPE yylloc;

