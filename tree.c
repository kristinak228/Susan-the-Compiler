#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "tree.h"
#include "y.tab.h"

extern int yyerror(char *);

/****** Prototype ******/
void aux_tree_print( tree_t *, int );

/****** Constructor ******/
tree_t *mktree( int type, tree_t *left, tree_t *right )
{
	tree_t *root = (tree_t *)malloc(sizeof(tree_t));
	assert( root != NULL );
	root->type = type;
	root->left = left;
	root->right = right;
	return root;
}

void tree_print( tree_t *root )
{
	aux_tree_print(root, 0);
}

/****** Specialized constructors ******/
tree_t *mkid( node_t *s )
{
	tree_t *p = mktree(ID, NULL, NULL);
	p->attribute.sVal = s; /* memory leak? */
	return p;
}

tree_t *mkinum(int iVal)
{
	tree_t *p = mktree(INUM, NULL, NULL);
	p->attribute.iVal = iVal;
	return p;
}

tree_t *mkrnum(float rVal)
{
	tree_t *p = mktree(RNUM, NULL, NULL);
	p->attribute.rVal = rVal;
	return p;
}

tree_t *mkop(int type, int opVal, tree_t *left, tree_t *right)
{
	tree_t *p = mktree(type, left, right);
	p->attribute.opVal = opVal;
	return p;
}

void aux_tree_print( tree_t *t, int spaces )
{
	int i;
	if(t == NULL) return;

	for(i = 0; i < spaces; i++) fprintf(stderr, " ");

	switch(t->type){
		case RELOP:		
			fprintf(stderr, "[RELOP:%d]\n", t->attribute.opVal);
			break;
		case ADDOP: 		
			fprintf(stderr, "[ADDOP:%d]\n", t->attribute.opVal);
			break;
		case MULOP:
			fprintf(stderr, "[MULOP:%d]\n", t->attribute.opVal);
			break;
		case ID:
			fprintf(stderr, "[ID:%s]\n", (t->attribute.sVal)->name);
			break;
		case INUM:
			fprintf(stderr, "[INUM:%d]\n", t->attribute.iVal);
			break;
		case RNUM:
			fprintf(stderr, "[RNUM:%f]\n", t->attribute.rVal);
			break;
		case NOT:
			fprintf(stderr, "[NOT]\n");
			break;
		case ARRAY_ACCESS:
			fprintf(stderr, "[ARRAY_ACCESS]\n");
			break;
		case FUNCTION_CALL:
			fprintf(stderr, "[FUNCTION_CALL]\n");
			break;
		case PROCEDURE_CALL:
			fprintf(stderr, "[PROCEDURE_CALL]\n");
			break;
		case COMMA:
			fprintf(stderr, "[COMMA]\n");
			break;
		case IF:
			fprintf(stderr, "[IF]\n");
			break;
		case THEN:
			fprintf(stderr, "[THEN]\n");
			break;
		case WHILE:
			fprintf(stderr, "[WHILE]\n");
			break;
		case ASSIGNOP:
			fprintf(stderr, "[ASSIGNOP]\n");
			break;
		default:		
			yyerror("Error in tree printing\n");
			break;
	}

	aux_tree_print(t->left, spaces+4);
	aux_tree_print(t->right, spaces+4);
}
