%{
%}

%%
";"		                    return "semi_colon";
"-"?[0-9]+                  {yylval.ival = atoi(yytext) ; return "integer_val";}
"-"?[0-9]+.[0-9]+           {yylval.fval = atof(yytext) ; return "float_val";}
"true"|"false"              return "boolean";
"=="|"!="|">"|">="|"<"|"<=" return "relop";
"&&"|"||"                   return "boolop";
"+"|"-"                     return "addop";
"*"|"/"|"%"                 return "mulop";
"&"|"|"                     return "bitop";
"="                         return "assignment";
"(" 			            return "left_brace";
")" 			            return "right_brace";
"{" 			            return "left_brace_curly";
"}" 			            return "right_brace_curly";
"["                         return "left_brace_square";
"]"                         return "right_brace_square";
"if"			            return "if";
"else"			            return "else";
"while"			            return "while";
"for"			            return "for";
"int"			            return "int";
"float"			            return "float";
"boolean" 		            return "boolean";
[a-zA-Z][a-zA-Z0-9]*		{yylval.sval = strdup(yytext); return "id";}
.                           ;

%%

int yywrap(void)
{
	return 1 ;
}