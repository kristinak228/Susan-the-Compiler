#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "args.h"

/****** Constructor ******/
args_t *mkarg(char *s)
{
	assert(s != NULL);
	args_t *newArg = (args_t *)malloc(sizeof(args_t));
	assert(newArg != NULL);
	newArg->name = strdup(s);
	newArg->next = NULL;
	newArg->type = 0; 
	return newArg;
}

/****** Helper Functions ******/
args_t *arg_search(args_t *top, char *name)
{
	args_t *currArg = top;
	
	while(currArg != NULL){
		if(strcmp(currArg->name, name) == 0) return currArg;
		currArg = currArg->next;
	}
	return NULL;
}

void print_list(args_t *top)
{
	assert(top != NULL);
	printf("printing argument list...\n");
	while(top != NULL){
		printf("%s\n", top->name);
		top = top->next;
	}
}

/* Simple function to return an argument from a list at index n */
args_t *get_func_arg(args_t *head, int n)
{
	int i;
	for(i = 0; i < n; i++)
		head = head->next;
	return head;
}

/* Made three functions instead of passing the tree_t node
because including tree.h creates a circular dependency */
args_t *arg_insert(args_t *top, char *name, int type)
{
	args_t *newTop = mkarg(name);
	newTop->next = top;
	newTop->type = type;
	newTop->arr_size = -1;
	return newTop;
}

args_t *arg_insert_array(args_t *top, char *name, int type, int l, int u, int s)
{
	args_t *newTop = mkarg(name);
	newTop->next = top;
	newTop->type = type;
	newTop->l_bound = l; 
	newTop->u_bound = u;
	newTop->arr_size = s;
	return newTop;
}

args_t *arg_insert_2darray(args_t *top, char *name, int type, int l1, int u1, \
							int l2, int u2, int r, int c)
{
	args_t *newTop = mkarg(name);
	newTop->next = top;
	newTop->type = type;
	newTop->l_bound = l1; 
	newTop->u_bound = u1;
	newTop->l_bound2 = l2;
	newTop->u_bound2 = u2;
	newTop->row = r;
	newTop->col = c;
	newTop->arr_size = -2;
	return newTop;
}
