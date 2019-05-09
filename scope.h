#ifndef SCOPE_H
#define SCOPE_H

#include <stdbool.h>

#include "node.h"

#define HASH_SIZE 	211
#define EOS 		'\0'

typedef struct scope_s {
	node_t *table[HASH_SIZE];
	struct scope_s *next;
} scope_t;

/****** Constructors/Deconstructors ******/
scope_t *mkscope();
void free_scope(scope_t *);

/****** Stack routines ******/
scope_t *push_scope( scope_t * );
scope_t *pop_scope( scope_t * );

/****** Helpers ******/
node_t *scope_search_all(scope_t *top, char *name);
node_t *scope_search(scope_t *top, char *name);
node_t *scope_insert(scope_t *top, char *name);
void scope_redefinition(scope_t *top, char *name);
bool scope_is_defined(scope_t *top, char *name);

#endif
