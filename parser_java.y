%{

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <map>
#include <set>
#include <string>
#include <utility>
#include <vector>
#include <string.h>
#include <algorithm>
#include <iterator>

using namespace std;

extern int yylex();
extern int yyparse();
extern FILE* yyin;

// Declarations of used data-structures
typedef enum {INT_T, FLOAT_T} Type;
typedef enum {AND, OR, NOT} BOOL_OPER;
typedef enum {PLUS, MINUS, MUL, DIV, MOD, BIT_AND, BIT_OR} Operators;
typedef enum {EQ, NE, GT, GTE, LT, LTE} Log_operators;

ofstream out("output.class");
std::map<std::string, std::pair<int, int> > variables;
std::set<std::pair<int, std::string> > output_byte_code;
int var_count = 0;
int pc = 0;

std::vector<int> *make_list(int curr_pc);
std::vector<int> *merge_list(std::vector<int> *true_l, std::vector<int> *false_l);
void back_patch(std::vector<int> *list, int curr_location);


void yyerror(const char* s);
%}

%code requires {
	#include <vector>
	using namespace std;
}

%start METHOD_BODY

%union {
	int ival;
	float fval;
	char* sval;
    struct
        {
            vector<int> *true_list, *false_list;
        } b_expr;
    struct
        {
            vector<int> *next_list;
        } stmt_;

	int type;
}

%token<ival>    integer_val
%token<fval>    float_val
%token<sval>    id relop boolop addop mulop bitop boolean
%token          semi_colon assignment left_brace right_brace
%token          left_brace_curly right_brace_curly left_brace_square right_brace_square if_s else_s
%token          while_s for_s int_s float_s boolean_s
%left           relop
%left           boolop
%left           bitop
%left           addop
%left           mulop



%type<type> EXPRESSION
%type<type> PRIMITIVE_TYPE
%type<type> INFIX_OPERATOR
%type<type> LOGICAL_INFIX_OPERATOR
%type<b_expr> BOOLEAN_EXPRESSION
%type<type> MARKER
%type<stmt_> STATEMENT_LIST
%type<stmt_> STATEMENT
%type<stmt_> NEXT_MARKER
%type<stmt_> DECLARATION
%type<stmt_> IF
%type<stmt_> ASSIGNMENT
%type<stmt_> WHILE
%type<type> BOOL_OPERATOR
%type<stmt_> FOR



%%

METHOD_BODY:
	    STATEMENT_LIST
	    MARKER
	    {
	        back_patch($1.next_list, $2);
	    };

STATEMENT_LIST:
        STATEMENT
        {
            $$.next_list =  $1.next_list;
        }
      | STATEMENT_LIST MARKER STATEMENT
        {
            back_patch($1.next_list, $2);
            $$.next_list =  $3.next_list;
        };

STATEMENT :
        DECLARATION
        {
            vector<int> * tmp = new vector<int>();
            $$.next_list = tmp;
        }
      | IF
        {
            $$.next_list = $1.next_list;
        }
      | WHILE
        {
            $$.next_list = $1.next_list;
        }
      | FOR
        {
            $$.next_list = $1.next_list;
        }
      | ASSIGNMENT
        {
            vector<int> * tmp = new vector<int>();
            $$.next_list = tmp;
        };

DECLARATION :
        PRIMITIVE_TYPE id semi_colon
        {
            variables[$2] = std::make_pair($1, var_count++);
        };

PRIMITIVE_TYPE :
        int_s
        {
            $$ = INT_T;
        }
      | float_s
        {
            $$ = FLOAT_T;
        };

ASSIGNMENT :
        id  assignment  EXPRESSION semi_colon
        {
            std::pair<int, int> current_var = variables[$1];

            if (current_var.first == INT_T)
            {
                output_byte_code.insert({pc, ": istore " + std::to_string(current_var.second)});
                pc += 2;
            }
            else
            {
                output_byte_code.insert({pc, ": fstore " + std::to_string(current_var.second)});
                pc += 2;
            }
        };

EXPRESSION :
          integer_val
          {
               $$ = INT_T;
               output_byte_code.insert({pc, ": ldc " + std::to_string($1)});
               pc += 2;
          }
        | float_val
          {
               $$ = FLOAT_T;
               output_byte_code.insert({pc, ": ldc " + std::to_string($1)});
               pc += 2;

          }
        | EXPRESSION INFIX_OPERATOR EXPRESSION
          {
               switch ($2)
               {
                case PLUS:

                    if ($1 == FLOAT_T || $3 == FLOAT_T) // float case
                    {
                        output_byte_code.insert({pc, ": fadd"});
                        $$ = FLOAT_T;
                    }
                    else // int case
                    {
                        output_byte_code.insert({pc, ": iadd"});
                        $$ = INT_T;
                    }
                    break;
                case MINUS:
                    if ($1 == FLOAT_T || $3 == FLOAT_T) // float case
                    {
                        output_byte_code.insert({pc, ": fsub"});
                        $$ = FLOAT_T;
                    }
                    else // int case
                    {
                        output_byte_code.insert({pc, ": isub"});
                        $$ = INT_T;
                    }
                    break;
                case MUL:
                    if ($1 == FLOAT_T || $3 == FLOAT_T) // float case
                    {
                        output_byte_code.insert({pc, ": fmul"});
                        $$ = FLOAT_T;
                    }
                    else // int case
                    {
                        output_byte_code.insert({pc, ": imul"});
                        $$ = INT_T;
                    }
                    break;
                case DIV:
                    if ($1 == FLOAT_T || $3 == FLOAT_T) // float case
                    {
                        output_byte_code.insert({pc, ": fdiv"});
                        $$ = FLOAT_T;
                    }
                    else // int case
                    {
                        output_byte_code.insert({pc, ": idiv"});
                        $$ = INT_T;
                    }
                    break;
                case MOD:
                    if ($1 == FLOAT_T || $3 == FLOAT_T) // float case
                    {
                        output_byte_code.insert({pc, ": frem"});
                        $$ = FLOAT_T;
                    }
                    else
                    {
                        output_byte_code.insert({pc, ": irem"});
                        $$ = INT_T;
                    }
                    break;
                case BIT_AND:
                    if ($1 == INT_T && $3 == INT_T) // int case
                    {
                        output_byte_code.insert({pc, ": iand"});
                        $$ = INT_T;
                    }
                    else
                       	yyerror("Error in operands-type !");
                    break;
                case BIT_OR:
                    if ($1 == INT_T && $3 == INT_T) // int case
                    {
                        output_byte_code.insert({pc, ": ior"});
                        $$ = INT_T;
                    }
                    else
                       	yyerror("Error in operands-type !");
                    break;
               }
                    pc ++;
          }
        | id
          {
               if (variables[$1].first == INT_T)
               {
                   output_byte_code.insert({pc, ": iload " + to_string(variables[$1].second)});
                   $$ = INT_T;
               }
               else
               {
                   output_byte_code.insert({pc, ": fload " + to_string(variables[$1].second)});
                   $$ = FLOAT_T;
               }
               pc += 2;
          }
        | left_brace EXPRESSION right_brace
          {
              $$ = $2;
          };

INFIX_OPERATOR :
          addop
          {
               if (!strcmp($1, "+"))
                   $$ = PLUS;
               else
                   $$ = MINUS;
          }
        | mulop
          {
               if (!strcmp($1, "*"))
                   $$ = MUL;
               else if (!strcmp($1, "/"))
                   $$ = DIV;
               else
                   $$ = MOD;
          }
        | bitop
          {
               if (!strcmp($1, "&"))
                   $$ = BIT_AND;
               else
                   $$ = BIT_OR;
          };


IF :
         if_s left_brace BOOLEAN_EXPRESSION right_brace
         left_brace_curly MARKER STATEMENT NEXT_MARKER right_brace_curly
         else_s left_brace_curly MARKER STATEMENT right_brace_curly
         {
              back_patch ($3.true_list, $6);
              back_patch ($3.false_list, $12);
              auto temp = merge_list ($7.next_list, $8.next_list);
              $$.next_list = merge_list (temp, $13.next_list);
         };

MARKER :
         {
             $$ = pc;
         };

NEXT_MARKER :
         {
            $$.next_list = make_list(pc);
            output_byte_code.insert({pc, ": goto "});
            pc += 3;
         };

BOOLEAN_EXPRESSION:
         EXPRESSION LOGICAL_INFIX_OPERATOR MARKER EXPRESSION
         {
               $$.true_list = make_list(pc);
               $$.false_list = make_list(pc + 3);
               switch($2)
               {
                 case EQ:
                    output_byte_code.insert({pc, ": if_icmpeq "});
                    break;

                 case LT:
                    output_byte_code.insert({pc, ": if_icmplt "});
                    break;

                 case LTE:
                    output_byte_code.insert({pc, ": if_icmple "});
                    break;

                 case GT:
                    output_byte_code.insert({pc, ": if_icmpgt "});
                    break;

                 case GTE:
                    output_byte_code.insert({pc, ": if_icmpge "});
                    break;

                 case NE:
                    output_byte_code.insert({pc, ": if_icmpne "});
                    break;

                 default :
                    break;
               }
               pc += 3;
               output_byte_code.insert({pc, ": goto "});
               pc += 3;
         }
       | BOOLEAN_EXPRESSION BOOL_OPERATOR MARKER BOOLEAN_EXPRESSION
         {
            switch ($2)
            {
                case OR :
                    back_patch ($1.false_list, $3);
                    $$.true_list = merge_list ($1.true_list, $4.true_list);
                    $$.false_list = $4.false_list;
                    break;
                case AND :
                    back_patch($1.true_list, $3);
                    $$.false_list = merge_list($1.false_list, $4.false_list);
                    $$.true_list = $4.true_list;
                    break;
            }
         }
       | BOOL_OPERATOR BOOLEAN_EXPRESSION
         {
            $$.true_list = $2.false_list;
            $$.false_list = $2.true_list;
         }
       | left_brace BOOLEAN_EXPRESSION right_brace
         {
            $$.true_list = $2.true_list;
            $$.false_list = $2.false_list;
         }
       | boolean
         {
            if (!strcmp($1, "true"))
            {
                $$.false_list = new vector<int> ();
                $$.true_list = make_list(pc);
            }
            else
            {
                $$.true_list = new vector<int> ();
                $$.false_list = make_list(pc);
            }
           output_byte_code.insert({pc, ": goto "});
           pc += 3;
         };

BOOL_OPERATOR :
            boolop
            {
            if (!strcmp($1, "&&"))
                    $$ = AND;
            else if (!strcmp($1, "||"))
                    $$ = OR;
            else if (!strcmp($1, "!"))
                    $$ = NOT;
            };

LOGICAL_INFIX_OPERATOR:
         relop
         {
            if (!strcmp($1, "=="))
                    $$ = EQ;
            else if (!strcmp($1, "!="))
                    $$ = NE;
            else if (!strcmp($1, ">"))
                    $$ = GT;
            else if (!strcmp($1, ">="))
                    $$ = GTE;
            else if (!strcmp($1, "<"))
                    $$ = LT;
            else if (!strcmp($1, "<="))
                    $$ = LTE;
         };




WHILE :
         while_s left_brace MARKER BOOLEAN_EXPRESSION right_brace
         left_brace_curly MARKER STATEMENT right_brace_curly
         {
            back_patch ($8.next_list, $3);
            back_patch ($4.true_list, $7);
            $$.next_list = $4.false_list;
            output_byte_code.insert({pc, ": goto " + to_string($3)});
            pc += 3;
         };

FOR :
        for_s
        left_brace
        ASSIGNMENT
        MARKER
        BOOLEAN_EXPRESSION
        semi_colon
        MARKER
        ASSIGNMENT
        NEXT_MARKER
        right_brace
        left_brace_curly
        MARKER
        STATEMENT
        NEXT_MARKER
        right_brace_curly
        {
            back_patch($5.true_list,$12);
            back_patch($9.next_list,$4);
            back_patch($14.next_list,$7);
            back_patch($13.next_list,$7);
            $$.next_list = $5.false_list;
        };

%%

std::vector<int> *make_list(int curr_pc)
{
    std::vector<int> *made_list = new vector<int>({curr_pc});
    return made_list;
}

std::vector<int> *merge_list(std::vector<int> *true_l, std::vector<int> *false_l)
{
    std::vector <int> *merged_list = new vector<int> (*true_l);
    merged_list->insert(merged_list->end(), false_l->begin(), false_l->end());
    return merged_list;
}

void back_patch(std::vector<int> *list, int curr_location)
{
    for (auto curr : *list)
    {
        auto it = find_if(output_byte_code.begin(), output_byte_code.end(),
                      [&](const std::pair<int, std::string>& val) -> bool {
                          return val.first == curr;
                      });
        string instr = it->second;
        instr += std::to_string(curr_location);
        int pc_ = it->first;
        output_byte_code.erase(it);
        output_byte_code.insert(make_pair(pc_, instr));
    }
}

int main()
{
    FILE *input_file;
    input_file = fopen("sample_code.txt", "r");


	yyin = input_file;

	do { 
		yyparse();
	} while(!feof(yyin));

    for (auto it = output_byte_code.begin(); it != output_byte_code.end(); ++it)
    {
        out << it->first << it->second << std::endl;
    }
	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
