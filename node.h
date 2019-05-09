#ifndef NODE_H
#define NODE_H

#include "args.h"

/****** Linked List ******/
typedef struct node_s {
	char *name;
	struct node_s *next;

	/* Variable */
	int type; 			/* INUM / RNUM */

	/* Array */
	int arr_size;
	int l_bound;
	int u_bound;
	/* 2D Array */
	int row, col;		/* row, col of 2D array */	
	int l_bound2;
	int u_bound2;

	/* Function / Procedure */
	int return_type;	/* Only used for functions */
	int num_of_args;
	args_t *arg_list_head; 

} node_t;

/****** Constructor ******/
node_t *mknode(char *);

/****** Helpers ******/
node_t *node_search(node_t *, char *);
node_t *node_insert(node_t *, char *);
void node_print(node_t *);

#endif
