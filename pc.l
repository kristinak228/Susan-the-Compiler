%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "tree.h"
#include "y.tab.h"

extern char yychar;
#define DEBUG 0

/* Scanner File, p. 746 Apendix A */

%}
whitespace  [ \t]+ 
number		[0-9]+
ident		[A-Za-z][A-Za-z0-9]*
comment1 	\{[^{]*\}
comment2	\(\*.*\*\) 

%%

{whitespace}	;
{comment1}	{ /* fprintf(stderr, "%s", yytext); */ }
{comment2}	{ /* fprintf(stderr, "%s", yytext); */ }


"program"	{ fprintf(stderr, "[PROGRAM]"); 	return PROGRAM; }
"var"		{ fprintf(stderr, "[VAR]"); 		return VAR; }
"array"		{ fprintf(stderr, "[ARRAY]"); 		return ARRAY; }
"of"		{ fprintf(stderr, "[OF]"); 			return OF; }
"procedure"	{ fprintf(stderr, "[PROCEDURE]"); 	return PROCEDURE; }
"function"	{ fprintf(stderr, "[FUNCTION]"); 	return FUNCTION; }
"begin"		{ fprintf(stderr, "[BEGIN]"); 		return BBEGIN; }
"end"		{ fprintf(stderr, "[END]"); 		return END; }
"integer"   { fprintf(stderr, "[INTEGER]"); 	return INTEGER; }
"real"   	{ fprintf(stderr, "[REAL]"); 		return REAL; }
"if"   		{ fprintf(stderr, "[IF]"); 			return IF; }
"then"   	{ fprintf(stderr, "[THEN]"); 		return THEN; }
"else"   	{ fprintf(stderr, "[ELSE]"); 		return ELSE; }
"while"   	{ fprintf(stderr, "[WHILE]"); 		return WHILE; }
"for"   	{ fprintf(stderr, "[FOR]"); 		return FOR; }
"do" 	  	{ fprintf(stderr, "[DO]"); 			return DO; }
"to" 	  	{ fprintf(stderr, "[TO]"); 			return TO; }

"result" 	{ fprintf(stderr, "[DO]"); 			return DO; }
".."		{ fprintf(stderr, "[DOTDOT]"); 		return DOTDOT; }
":="		{ fprintf(stderr, "[ASSIGNOP]"); 	return ASSIGNOP; }

"="			{ fprintf(stderr, "[RELOP:%d]", yylval.opVal = EQ); return RELOP; }
"<>"		{ fprintf(stderr, "[RELOP:%d]", yylval.opVal = NE); return RELOP; }
"<"			{ fprintf(stderr, "[RELOP:%d]", yylval.opVal = LT); return RELOP; }
"<="		{ fprintf(stderr, "[RELOP:%d]", yylval.opVal = LE); return RELOP; }
">"			{ fprintf(stderr, "[RELOP:%d]", yylval.opVal = GT); return RELOP; }
">="		{ fprintf(stderr, "[RELOP:%d]", yylval.opVal = GT); return RELOP; }

"+"			{ fprintf(stderr, "[ADDOP:%d]", yylval.opVal = PLUS); 	return ADDOP; }
"-"			{ fprintf(stderr, "[ADDOP:%d]", yylval.opVal = MINUS); 	return ADDOP; }
"or"		{ fprintf(stderr, "[ADDOP:%d]", yylval.opVal = OR); 	return ADDOP; }

"*"			{ fprintf(stderr, "[MULOP:%d]", yylval.opVal = STAR); 	return MULOP; }
"/"			{ fprintf(stderr, "[MULOP:%d]", yylval.opVal = SLASH); 	return MULOP; }
"and"		{ fprintf(stderr, "[MULOP:%d]", yylval.opVal = AND); 	return MULOP; }
"mod"		{ fprintf(stderr, "[MULOP:%d]", yylval.opVal = MOD); 	return MULOP; }
"div"		{ fprintf(stderr, "[MULOP:%d]", yylval.opVal = DIV); 	return MULOP; }

"not"		{ fprintf(stderr, "[NOT]"); return NOT; }

{number}				{ fprintf(stderr, "[INUM:%d]", yylval.iVal = atoi(yytext)); return INUM; }
{number}"."{number}		{ fprintf(stderr, "[RNUM:%f]", yylval.rVal = atof(yytext));	return RNUM; }
{ident}					{ fprintf(stderr, "[ID:%s]", yylval.sVal = strdup(yytext)); return ID; }

";" 		{ return yytext[0]; }
"\n" 		{ fprintf(stderr, "\n"); } /* add line counting here */
.			{ fprintf(stderr, "{%c}", yytext[0]); return yytext[0]; }

%%

int yyerror( char *msg )
{
	fprintf(stderr, "\nError: %s\n", msg);
	exit(1);
}
