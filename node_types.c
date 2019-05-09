#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "node_types.h"
#include "args.h"
#include "y.tab.h"

extern int yyerror(char *);
extern int hashpjw(char *s);

/* sets function return type 'rtype' using functions 'name' */
void set_func_return_type(scope_t *top, char *name, int rtype)
{
	node_t *n;

	assert(top != NULL);
	int index = hashpjw(name); 
	n = top->table[index]; 
	assert(n != NULL);
	n->num_of_args = 0; 
	if(rtype == INUM) n->return_type = INUM;
	else if(rtype == RNUM) n->return_type = RNUM;
	n->type = n->return_type;
}

/* Adds argument nodes to functions argument list */
void add_args(node_t *func_node, tree_t* args_list)
{
	node_t *currNode;
	tree_t *currArg;
	args_t *head;	
	
	assert(func_node != NULL);
	assert(args_list != NULL);
	currArg = args_list;
	assert(currArg != NULL);
	
	if(currArg->type == ID){
		currNode = currArg->attribute.sVal;
		assert(currNode != NULL);

		/* Non-Array */
		if(currNode->arr_size == -1){
			head = arg_insert(func_node->arg_list_head, currNode->name, \
						currNode->type);
		/* 2D Array */
		} else if(currNode->arr_size == -2){
			head = arg_insert_2darray(func_node->arg_list_head, currNode->name, \
					currNode->type, currNode->l_bound, currNode->u_bound, \
					currNode->l_bound2, currNode->u_bound2, currNode->row, \
					currNode->col);
		/* 1D Array */
		} else {
			head = arg_insert_array(func_node->arg_list_head, currNode->name, \
					currNode->type, currNode->l_bound, currNode->u_bound, \
					currNode->arr_size);
		}
		func_node->num_of_args++;
		func_node->arg_list_head = head;
	}

	/* recurse if neccessary */
	if(currArg->left != NULL) add_args(func_node, currArg->left);
	if(currArg->right != NULL) add_args(func_node, currArg->right);
}

/* Sets all the information for variables, arrays, and 2d arrays */
void set_type(tree_t *identifier_list, tree_t *arg_type)
{
	node_t *currNode;
	tree_t *currArg, *leftChild, *rightChild;

	assert(identifier_list != NULL); /* Check for first run through */
	assert(arg_type != NULL);
	currArg = identifier_list;
	assert(currArg != NULL); 

	if(currArg->type == ID){	
		currNode = currArg->attribute.sVal; 
		assert(currNode != NULL);
		/* Arrays */
		if(arg_type->left != NULL && arg_type->right != NULL){
			leftChild = arg_type->left;
			rightChild = arg_type->right;
			/* 2D Array */
			if(leftChild->left != NULL && leftChild->right != NULL && \
				rightChild->left != NULL && rightChild->right != NULL){
				currNode->l_bound = (leftChild->left)->attribute.iVal;
				currNode->u_bound = (leftChild->right)->attribute.iVal;
				currNode->l_bound2 = (rightChild->left)->attribute.iVal;
				currNode->u_bound2 = (rightChild->right)->attribute.iVal;
				currNode->row = (currNode->u_bound - currNode->l_bound);
				currNode->col = (currNode->u_bound2 - currNode->l_bound2);
				currNode->arr_size = -2; /* 2D array check */
			/* Normal Array */
			} else {
				currNode->l_bound = (arg_type->left)->attribute.iVal;
				currNode->u_bound = (arg_type->right)->attribute.iVal;
				currNode->arr_size = (currNode->u_bound - currNode->l_bound);
			}
		/* Non-Arrays */
		} else currNode->arr_size = -1; /* non-array check */

		/* set the type for node objects */
		currNode->type = arg_type->type;	
	}

	/* recurse if necessary */
	if(currArg->left != NULL) set_type(currArg->left, arg_type);
	if(currArg->right != NULL) set_type(currArg->right, arg_type);
}

/* Compares two tree node objects within an expression */
void compare_types(tree_t *t1, tree_t *t2)
{
	/* t1 will be a variable, t2 can be a variable, function call, INUM/RNUM */
	node_t *n1, *n2;
	assert(t1 != NULL);
	assert(t2 != NULL);

	/* Find t1 value */
	if(t1->type == ARRAY_ACCESS) t1 = t1->left; /* t1 is now an ID */
	if(t1->type == ID) n1 = t1->attribute.sVal; 

	/* Find t2 value and compare */
	if(t2->type == INUM || t2->type == RNUM){
		if(n1->type != t2->type) yyerror("objects are of different types");
	} else if (t2->type == ARRAY_ACCESS) t2 = t2->left; /* t2 is now an ID */
	if(t2->type == ID){
		n2 = t2->attribute.sVal;
		if(n1->type != n2->type) yyerror("objects are of different types");
	} 
	
	/* recurse if necessary */
	if(t2->left != NULL) compare_types(t1, t2->left);
	/* right goes to the functions expression list, don't need to check that */
	if(t2->type != FUNCTION_CALL) 
		if(t2->right != NULL) compare_types(t1, t2->right); 
}

/* Checks that array is indexed with an integer, also
checks whether it is correctly indexing for a 1d/2d array,
this is what the integer 'is_2d' is used for */
void check_array_index(scope_t *top, char *name, tree_t *t, int *is_2d)
{
	node_t *n, *tNode;

	assert(top != NULL);
	int index = hashpjw(name); 
	n = top->table[index]; 
	assert(n != NULL);

	if(t->type == RNUM)
		yyerror("attempting to index array with non-integer type");
	else if(t->type == ID){
		tNode = t->attribute.sVal; 
		if(tNode->type == RNUM) 
			yyerror("attempting to index array with non-integer type");
	} else if(t->type == COMMA){
		*is_2d = 1;
		if(n->arr_size != -2)
			yyerror("indexing 1D array as 2D array");
	} 

	if(t->left == NULL && t->right == NULL){
		if(n->arr_size == -2 && *is_2d != 1)
			yyerror("indexing 2D array as 1D array");
	}

	if(t->left != NULL) check_array_index(top, name, t->left, is_2d);
	if(t->right != NULL) check_array_index(top, name, t->right, is_2d);
}

/* 
Checks that a function/procedure call has the correct number, type, 
and order of arguments; int 'i' always comes in as 1 initially,
to index get_func_args()
*/
void check_arguments(scope_t *top, char *name, tree_t *expr_list, int *i)
{
	node_t *fnode;		/* function node */
	tree_t *tArg;		/* current argument node from tree */
	args_t *fArg;		/* current argument node from function */
	int n, index;

	/* grab function/procedure node */
	assert(top != NULL);
	index = hashpjw(name); 
	fnode = top->table[index]; 
	assert(fnode != NULL);

	/* expr_list is NULL but shouldn't be */
	if(expr_list == NULL && fnode->num_of_args != 0){
		yyerror("function/procedure call requires arguments");
	} /* expr_list is not NULL but should be */ 
	else if(expr_list != NULL){
		if(fnode->num_of_args == 0)
			yyerror("function/procedure call does not require arguments");	
		else { /* expr_list is not NULL and shouldn't be */
			if(expr_list->type == ID){
				tArg = expr_list;
				n = fnode->num_of_args; /* just looks cleaner */

				/* if 'i' is now greater than the number of func/proc args */
				if(*i > n) 
					yyerror("function/procedure call has too many arguments");
			
				fArg = get_func_arg(fnode->arg_list_head, (n-(*i)));
				assert(fArg != NULL);	
				*i += 1;

				/* check argument types */
				if(tArg->attribute.sVal->type != fArg->type)
					yyerror("arguments do not match function/procedure definition"); 
				
				/* check if 1d array, 2d array, or variable */
				if(fArg->arr_size == -1 && tArg->attribute.sVal->arr_size != -1)
					yyerror("function/procedure argument expected variable type");
				else if(fArg->arr_size == -2 && tArg->attribute.sVal->arr_size != -2)
					yyerror("function/procedure argument expected 2D array");
				else if(fArg->arr_size != tArg->attribute.sVal->arr_size)
					yyerror("function/procedure argument expected 1D array");
			}
				
			/* recurse but don't update i */ 
			if(expr_list->left != NULL)
				check_arguments(top, name, expr_list->left, i);
			if(expr_list->right != NULL)
				check_arguments(top, name, expr_list->right, i);
		}		
	}
}

/* used for testing */
void print_arg_tree(tree_t *t)
{
	printf("inside tree print\n");
	assert(t != NULL);
	if(t->type == ID){
		printf("\nID type: %d\n", t->attribute.type);
		printf("ID name: %s\n", t->attribute.name);
	}

	if(t->left != NULL){
		printf("going left\n");
		print_arg_tree(t->left);
	}
	if(t->right != NULL){
		printf("going right\n");
		print_arg_tree(t->right);
	}
}



