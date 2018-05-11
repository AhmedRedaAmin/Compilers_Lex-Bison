/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

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

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 41 "parser_java.y" /* yacc.c:1909  */

	#include <vector>
	using namespace std;

#line 49 "y.tab.h" /* yacc.c:1909  */

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    integer_val = 258,
    float_val = 259,
    id = 260,
    relop = 261,
    boolop = 262,
    addop = 263,
    mulop = 264,
    bitop = 265,
    semi_colon = 266,
    boolean = 267,
    assignment = 268,
    left_brace = 269,
    right_brace = 270,
    left_brace_curly = 271,
    right_brace_curly = 272,
    left_brace_square = 273,
    right_brace_square = 274,
    if_s = 275,
    else_s = 276,
    while_s = 277,
    for_s = 278,
    int_s = 279,
    float_s = 280,
    boolean_s = 281
  };
#endif
/* Tokens.  */
#define integer_val 258
#define float_val 259
#define id 260
#define relop 261
#define boolop 262
#define addop 263
#define mulop 264
#define bitop 265
#define semi_colon 266
#define boolean 267
#define assignment 268
#define left_brace 269
#define right_brace 270
#define left_brace_curly 271
#define right_brace_curly 272
#define left_brace_square 273
#define right_brace_square 274
#define if_s 275
#define else_s 276
#define while_s 277
#define for_s 278
#define int_s 279
#define float_s 280
#define boolean_s 281

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 48 "parser_java.y" /* yacc.c:1909  */

	int ival;
	float fval;
	char* sval;
	typedef struct
	{
	    vector<int> true_list, false_list;
	} boolean_expr;
	int type;

#line 124 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
