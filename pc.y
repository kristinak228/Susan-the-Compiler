%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <assert.h>
	#include <string.h>

	#include "tree.h"
	#include "scope.h"
	#include "node_types.h"
	#include "y.tab.h"	

	extern int yyerror(char*);
	extern int yylex();

	extern scope_t *top_scope, *tmp_scope;
	extern node_t *tmp;
	extern int line_number;

%}

%union {
	/* Scanner */
	int iVal; 			/* INUM */
	float rVal; 		/* RNUM */
	int opVal; 			/* RELOP ADDOP MULOP */
	char *sVal; 	/* ID */
	
	/* Semantics */
	tree_t *tVal;	
}

%token PROGRAM PROGRAM_ROOT PROGRAM_NODE
%token SUBPROGRAM SUBPROGRAM_ROOT SUBPROGRAM_NODE
%token BBEGIN END		
%token PROCEDURE FUNCTION		
%token IDENT
%token INTEGER REAL 
%token ARRAY OF
%token ASSIGNOP
%token RESULT
%token EQ NE LT LE GT GE
%token PLUS MINUS OR
%token STAR SLASH AND DIV MOD
%token NOT
%token DOTDOT
%token VAR

%token FOR TO
%token IF THEN ELSE 
%token WHILE DO
%token ARRAY_ACCESS
%token FUNCTION_CALL
%token PROCEDURE_CALL
%token COMMA
%token LINK	

%token <opVal> MULOP 
%token <opVal> RELOP
%token <opVal> ADDOP 

%token <sVal> ID
%token <iVal> INUM
%token <rVal> RNUM

%type <tVal> program
%type <tVal> identifier_list
%type <tVal> declarations
%type <tVal> type
%type <iVal> standard_type
%type <tVal> subprogram_declarations
%type <tVal> subprogram_declaration
%type <tVal> subprogram_head
%type <tVal> arguments
%type <tVal> parameter_list
%type <tVal> compound_statement
%type <tVal> optional_statements
%type <tVal> statement_list
%type <tVal> statement
%type <tVal> variable
%type <tVal> procedure_statement
%type <tVal> expression_list
%type <tVal> expression
%type <tVal> simple_expression
%type <tVal> term
%type <tVal> factor
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program 
	:
	{ fprintf(stderr, "BEGINING OF PROGRAM\n"); } 
	PROGRAM ID '(' identifier_list ')' ';'
	declarations
	subprogram_declarations
	compound_statement
	'.'
	{ fprintf(stderr, "END OF PROGRAM\n"); }
	;

identifier_list
	: ID
		{ 
			scope_redefinition(top_scope, $1);
			$$ = mkid(scope_insert(top_scope, $1));
		}
	| identifier_list ',' ID
		{ 
			scope_redefinition(top_scope, $3);
			$$ = mktree(COMMA, $1, mkid(scope_insert(top_scope, $3))); 
		}
	;

declarations
	: declarations VAR identifier_list ':' type ';'
		{  
			set_type($3, $5);
			$$ = $3;
		} 
	| /* empty */
		{ $$ = NULL; }
	; 

type 
	: standard_type
		{ $$ = mktree($1, NULL, NULL); }
	| ARRAY '[' INUM DOTDOT INUM ']' OF standard_type
		{ $$ = mktree($8, mkinum($3), mkinum($5)); }
	| ARRAY '[' INUM DOTDOT INUM ',' INUM DOTDOT INUM ']' OF standard_type
		{ 
			$$ = mktree($12, mktree(DOTDOT, mkinum($3), mkinum($5)), \
				mktree(DOTDOT, mkinum($7), mkinum($9))); 
		}
	;

standard_type
	: INTEGER 	{ $$ = INUM; }
	| REAL		{ $$ = RNUM; }
	;

subprogram_declarations
	: subprogram_declarations subprogram_declaration ';'
		{ /* Don't need to do anything here */ }
	| /* empty */
		{ $$ = NULL; }
	;

subprogram_declaration
	: subprogram_head declarations subprogram_declarations compound_statement
		{
			top_scope = pop_scope(top_scope);
		}
	;

subprogram_head 
	: FUNCTION ID 
		{	
			scope_redefinition(top_scope, $2);
			tmp = scope_insert(top_scope, $2); /* Quick copy to use below */
			mkid(tmp);
			tmp_scope = top_scope;  /* Quick copy to use below */
			top_scope = push_scope(top_scope);
		}
	arguments ':' standard_type ';'
		{ 
			set_func_return_type(tmp_scope, $2, $6);
			if($4 != NULL) add_args(tmp, $4);
			$$ = mktree(FUNCTION_CALL, mkid(scope_search_all(top_scope, $2)), $4);
		}
	| PROCEDURE ID 
		{
			scope_redefinition(top_scope, $2);
			tmp = scope_insert(top_scope, $2); /* Quick copy to use below */
			mkid(tmp);
			top_scope = push_scope(top_scope);
		}
	arguments ';' 
		{
			if($4 != NULL) add_args(tmp, $4);
			$$ = mktree(PROCEDURE_CALL, mkid(scope_search_all(top_scope, $2)), $4);
		}
	;

arguments
	: '(' parameter_list ')'
		{ $$ = $2; }
	| /* empty */
		{ $$ = NULL; }
	;

parameter_list
	: identifier_list ':' type
		{ 
			set_type($1, $3);
			$$ = $1; 
		}
	| parameter_list ';' identifier_list ':' type
		{
			set_type($3, $5);
			$$ = mktree(COMMA, $1, $3); 
		}
	;

compound_statement
	: BBEGIN optional_statements END
		{
			$$ = $2;
			fprintf(stderr, "\nBEGIN TREE PRINT\n\n");
			tree_print($$);
			fprintf(stderr, "\nEND TREE PRINT\n\n");	
		}
	;

optional_statements
	: statement_list { $$ = $1; }
	| /* empty */	 { $$ = NULL; }
	;

statement_list
	: statement { $$ = $1; }
	| statement_list ';' statement { $$ = mktree(COMMA, $1, $3); }
	;

statement
	/* Do I need to include 'ELSE' & 'DO' in my print tree? should I 
		add them to the mktree function calls here? */
	: variable ASSIGNOP expression 
		{
			compare_types($1, $3);
			$$ = mktree(ASSIGNOP, $1, $3); 
		}
	| procedure_statement 
		{ $$ = $1; }
	| compound_statement  
		{ $$ = $1; }
	| IF expression THEN statement ELSE statement
		{ $$ = mktree(IF, $2, mktree(THEN, $4, $6)); }
	| IF expression THEN statement %prec LOWER_THAN_ELSE
		{ $$ = mktree(IF, $2, mktree(THEN, $4, NULL)); }
	| FOR statement TO simple_expression DO statement
		{ $$ = mktree(FOR, $2, mktree(TO, $4, $6)); }
	| WHILE expression DO statement
		{ $$ = mktree(WHILE, $2, $4); }
	;

variable
	: ID 
		{
			if(!scope_is_defined(top_scope, $1)) 
				yyerror("object is not defined within scope\n");
			$$ = mkid(scope_search_all(top_scope, $1)); 
		}
	/* left-side of assignment operator */
	| ID '[' expression_list ']'
		{ 
			int i = 0;	
			if(!scope_is_defined(top_scope, $1)) 
				yyerror("object is not defined within scope\n");
			check_array_index(top_scope, $1, $3, &i);
			$$ = mktree(ARRAY_ACCESS, mkid(scope_search_all(top_scope, $1)), $3); 
		}
	;

procedure_statement
	: ID
		{ 
			int i = 1;
			if(!scope_is_defined(top_scope, $1)) 
				yyerror("object is not defined within scope\n");
			check_arguments(top_scope, $1, NULL, &i);
			$$ = mkid(scope_search_all(top_scope, $1)); 
		}
	| ID '(' expression_list ')'
		{
			int i = 1;
			if(!scope_is_defined(top_scope, $1)) 
				yyerror("object is not defined within scope\n");
			check_arguments(top_scope, $1, $3, &i);
			$$ = mktree(PROCEDURE_CALL, mkid(scope_search_all(top_scope, $1)), $3); 
		}
	;

/* Tree Building below, above uses expressions */

expression_list
	: expression { $$ = $1; }
	| expression_list ',' expression 
		{ $$ = mktree(COMMA,$1,$3); }
	;

expression
	: simple_expression 
		{ $$ = $1; }
	| simple_expression RELOP simple_expression 
		{ $$ = mkop(RELOP, $2, $1, $3);	}
	;

simple_expression
	: term 							
		{ $$ = $1; }
	| ADDOP term					
		{ $$ = mkop(ADDOP,$1,$2,NULL); }
	| simple_expression ADDOP term 	
		{ $$ = mkop(ADDOP,$2,$1,$3); }
	;

term 
	: factor 			
		{ $$ = $1; }
	| term MULOP factor 
		{ $$ = mkop(MULOP,$2,$1,$3); } 
	;

factor 
	: ID 							
		{
			if(!scope_is_defined(top_scope, $1)) 
				yyerror("object is not defined within scope\n");
			$$ = mkid(scope_search_all(top_scope, $1)); 
		}
	| ID '(' expression_list ')'	
		{ 
			int i = 1;
			if(!scope_is_defined(top_scope, $1)) 
				yyerror("object is not defined within scope\n");
			check_arguments(top_scope, $1, $3, &i);
			$$ = mktree(FUNCTION_CALL,mkid(scope_search_all(top_scope, $1)),$3); 
		}
	/* right-side of assignment operator */
	| ID '[' expression_list ']' 		
		{
			int i = 0;
			if(!scope_is_defined(top_scope, $1)) 
				yyerror("object is not defined within scope\n");
			check_array_index(top_scope, $1, $3, &i);
			$$ = mktree(ARRAY_ACCESS,mkid(scope_search_all(top_scope, $1)),$3); 
		}
	| INUM						 	{ $$ = mkinum($1); }
	| RNUM 							{ $$ = mkrnum($1); }
	| '(' expression ')' 			{ $$ = $2; }
	| NOT factor 					{ $$ = mktree(NOT,$2,NULL); }
	;

%%

scope_t *top_scope, *tmp_scope;
node_t *tmp;
int line_number = 0;

int main()
{
	top_scope = mkscope();
	tmp = NULL;
	yyparse();
	return 0;
}





