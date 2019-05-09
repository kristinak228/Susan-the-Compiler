#ifndef NODE_TYPES_H
#define NODE_TYPES_H

#include "scope.h"
#include "tree.h"

void set_func_return_type(scope_t *, char *, int);
void add_args(node_t *, tree_t *);
void set_type(tree_t *, tree_t *);
void compare_types(tree_t *, tree_t *);
void check_array_index(scope_t *, char *, tree_t *, int *);
void check_arguments(scope_t *, char *, tree_t *, int *);
void print_arg_tree(tree_t *);

#endif
