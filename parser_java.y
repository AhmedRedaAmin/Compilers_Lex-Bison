%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
%}

%union {
	int ival;
	float fval;
	char* sval;
}

%token<ival>    integer_val
%token<fval>    float_val
%token<sval>    id relop boolop addop mulop bitop
%token          semi_colon boolean assignment left_brace right_brace
%token          left_brace_curly right_brace_curly left_brace_square right_brace_square if_s else_s
%token          while_s for_s int_s float_s boolean_s
%left           relop
%left           boolop
%left           bitop
%left           addop
%left           mulop








%type<ival> expression
%type<fval> mixed_expression

%start calculation

%%

METHOD_BODY:
	   | STATEMENT_LIST
;

STATEMENT_LIST: STATEMENT
        | STATEMENT_LIST STATEMENT
;


STATMENT : DECLARATION
        | IF
        | WHILE
        | ASSIGNMENT
;

PRIMITIVE_TYPE : int_s
        | float_s
;


DECLARATION :
        |PRIMITIVE_TYPE id
;

IF :
        | if_s ( EXPRESSION ) { STATEMENT} else_s { STATEMENT }
;

WHILE :
        | while_s ( EXPRESSION ) { STATEMENT }
;

ASSIGNMENT :
        | id  assignment  EXPRESSION
;

EXPRESSION : integer_val
        | float_val
        | EXPRESSION INFIX_OPERATOR EXPRESSION
        | id
        | left_brace EXPRESSION right_brace
;

INFIX_OPERATOR : addop
        | mulop
        | relop
        | bitop
        | boolop



%%

int main() {
	yyin = stdin;

	do { 
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
