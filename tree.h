#ifndef TREE_H
#define TREE_H

#include "node.h"

/****** Tree type structure ******/
typedef struct tree_s 
{
	int type; 					/* token type: INUM RNUM ID RELOP ADDOP MULOP NOT.. */
	union {
		int iVal; 				/* INUM */
		float rVal;				/* RNUM */
		node_t *sVal; 			/* ID */
		int opVal;				/* RELOP ADDOP MULOP */
	} attribute;
	
	struct tree_s 	*left;
	struct tree_s 	*right;
} tree_t;

/****** Constructor ******/
tree_t *mktree( int type, tree_t *left, tree_t *right );

/****** Auxiliary ******/
void tree_eval(tree_t *); /* May not need anymore */
void tree_print(tree_t * );

/****** Specialized constructors ******/
tree_t *mkid( node_t *);
tree_t *mkinum( int );
tree_t *mkrnum( float );
tree_t *mkop(int type, int opVal, tree_t *left, tree_t *right);

#endif
