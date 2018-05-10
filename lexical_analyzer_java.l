%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "parser_java.tab.h"
%}

%%
";"		                    return semi_colon;
"-"?[0-9]+                  {yylval.ival = atoi(yytext) ; return integer_val;}
"-"?[0-9]+.[0-9]+           {yylval.fval = atof(yytext) ; return float_val;}
"true"|"false"              {yylval.sval = strdup(yytext); boolean;}
"=="|"!="|">"|">="|"<"|"<=" {yylval.sval = strdup(yytext);return relop;}
"&&"|"||"                   {yylval.sval = strdup(yytext);return boolop;}
"+"|"-"                     {yylval.sval = strdup(yytext);return addop;}
"*"|"/"|"%"                 {yylval.sval = strdup(yytext);return mulop;}
"&"|"|"                     {yylval.sval = strdup(yytext);return bitop;}
"="                         return assignment;
"(" 			            return left_brace;
")" 			            return right_brace;
"{" 			            return left_brace_curly;
"}" 			            return right_brace_curly;
"["                         return left_brace_square;
"]"                         return right_brace_square;
"if"			            return if_s;
"else"			            return else_s;
"while"			            return while_s;
"for"			            return for_s;
"int"			            return int_s;
"float"			            return float_s;
"boolean" 		            return boolean_s;
[a-zA-Z][a-zA-Z0-9]*		{yylval.sval = strdup(yytext); return id;}
.                           ;

%%

int yywrap(void)
{
	return 1 ;
}