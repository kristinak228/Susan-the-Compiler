#ifndef ARGS_H
#define ARGS_H

/* Need tree.h somehow */

/****** Linked List ******/
typedef struct args_s {
	char *name;
	int type; 		/* INUM RNUM */
	struct args_s *next;

	/* just for arrays */
	int l_bound;
	int u_bound;
	int arr_size;
	int l_bound2;
	int u_bound2;
	int row, col;

} args_t;

/****** Constructor ******/
args_t *mkarg(char *);

/****** Helpers ******/

args_t *arg_search(args_t *, char *);
args_t *arg_insert(args_t *, char *, int);
args_t *arg_insert_array(args_t *, char *, int, int, int, int);
args_t *arg_insert_2darray(args_t *, char *, int, int, int, int, int, int, int);
void print_list(args_t *);
args_t *get_func_arg(args_t *, int);

#endif
