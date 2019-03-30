%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <assert.h>
	#include <string.h>

	#include "tree.h"
	#include "scope.h"
	#include "y.tab.h"

	extern int yyerror(char*);
	extern int yylex();

	extern scope_t *top_scope;

	/*#define ECHO 1*/

%}

%union {
	int iVal; 		/* NUM */
	float rVal; 	/* RNUM */
	int opVal; 		/* RELOP ADDOP MULOP */
	char *sVal; 	/* ID */
	
	tree_t *tVal;	/* Symantics */
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
%type <tVal> standard_type
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
/*
If local objects hide non-local objects with the same name, don't I only need to 
check that it's not within the same scope? How do I ensure my program takes the 
most local object?
*/

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
		{ /*add_type_information($3, $5);*/ $$ = NULL; } 
	| /* empty */
		{ $$ = NULL; }
	; 

type
	: standard_type
		{ $$ = NULL; }
	| ARRAY '[' INUM DOTDOT INUM ']' OF standard_type
		{ $$ = NULL; }
	;

standard_type
	: INTEGER
		{ $$ = NULL; }
	| REAL
		{ $$ = NULL; }
	;

subprogram_declarations
	: subprogram_declarations subprogram_declaration ';'
	| /* empty */
		{ $$ = NULL; }
	;

subprogram_declaration
	: subprogram_head declarations subprogram_declarations compound_statement
		{ pop_scope(top_scope); }
	;

subprogram_head
	: FUNCTION ID arguments ':' standard_type ';'
		{ $$ = NULL; }
	| PROCEDURE ID arguments ';'
		{ $$ = NULL; }
	;

arguments
	: '(' parameter_list ')'
		{ $$ = NULL; }
	| /* empty */
		{ $$ = NULL; }
	;

parameter_list
	: identifier_list ':' type
		{ $$ = NULL; }
	| parameter_list ';' identifier_list ':' type
		{ $$ = NULL; }
	;

compound_statement
	: BBEGIN optional_statements END
		{
			$$ = $2;
			fprintf(stderr, "BEGIN TREE PRINT\n\n");
			tree_print($$);
			fprintf(stderr, "END TREE PRINT\n\n");
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
	: variable ASSIGNOP expression 
		{ $$ = mktree(ASSIGNOP, $1, $3); }
	| procedure_statement 
		{ $$ = $1; }
	| compound_statement  
		{ $$ = $1; }
	| IF expression THEN statement ELSE statement
		{ $$ = mktree(IF, $2, mktree(THEN, $4, $6)); }
	| IF expression THEN statement %prec LOWER_THAN_ELSE
		{ $$ = mktree(IF, $2, mktree(THEN, $4, NULL)); }
	| WHILE expression DO statement
		{ $$ = mktree(WHILE, $2, $4); }
	;

variable
	: ID 
		{
			$$ = mkid(scope_search_all(top_scope, $1)); 
		}
	| ID '[' expression ']'
		{ $$ = mktree(ARRAY_ACCESS, mkid(scope_search_all(top_scope, $1)), $3); }
	;

procedure_statement
	: ID { $$ = mkid(scope_search_all(top_scope, $1)); }
	| ID '(' expression_list ')'
		{ $$ = mktree(PROCEDURE_CALL, mkid(scope_search_all(top_scope, $1)), $3); }
	;

expression_list
	: expression { $$ = $1; }
	| expression_list ',' expression 
		{ $$ = mktree(COMMA,$1,$3); }
	;

expression
	: simple_expression { $$ = $1; }
	| simple_expression RELOP simple_expression 
		{ $$ = mkop(RELOP, $2, $1, $3); }
	;

simple_expression
	: term 							{ $$ = $1; }
	| ADDOP term					{ $$ = mkop(ADDOP,$1,$2,NULL); }
	| simple_expression ADDOP term 	{ $$ = mkop(ADDOP,$2,$1,$3);  }
	;

term
	: factor 			{ $$ = $1; }
	| term MULOP factor { $$ = mkop(MULOP,$2,$1,$3); } 
	;
	
factor
	: ID 							{ $$ = mkid(scope_search_all(top_scope, $1)); }
	| ID '(' expression_list ')'	{ $$ = mktree(FUNCTION_CALL,mkid(scope_search_all(top_scope, $1)),$3); }
	| ID '[' expression ']' 		{ $$ = mktree(ARRAY_ACCESS,mkid(scope_search_all(top_scope, $1)),$3); }
	| INUM						 	{ $$ = mkinum($1); }
	| RNUM 							{ $$ = mkrnum($1); }
	| '(' expression ')' 			{ $$ = $2; }
	| NOT factor 					{ $$ = mktree(NOT,$2,NULL); }
	;

%%

scope_t *top_scope;

int main()
{
	top_scope = mkscope();
	yyparse();
	return 0;
}





