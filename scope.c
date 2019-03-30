#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "scope.h"

int hashpjw( char *s );

/****** Constructors/Destructors ******/
scope_t *mkscope()
{
	int i;
	scope_t *p = (scope_t *)malloc(sizeof(scope_t));
	assert(p != NULL);

	for(i = 0; i < HASH_SIZE; i++) p->table[i] = NULL;

	p->next = NULL;
	return p;
}

void free_scope( scope_t *top)
{
	int i;
	assert(top != NULL);
	for(i = 0; i < HASH_SIZE; i++) free(top->table[i]);
	free(top);
}

/****** Stack Routines ******/
scope_t *push_scope( scope_t *top )
{
	scope_t *p = mkscope();
	p->next = top;
	return p;
}

scope_t *pop_scope( scope_t *top )
{
	if(top == NULL) return NULL;
	scope_t *p;
	p = top->next;
	free_scope(top);
	return p;
}

/****** Helpers ******/
node_t *scope_search_all(scope_t *top, char *name)
{
	assert(top != NULL);
	scope_t *p = top;
	node_t *tmp;
	while(p != NULL){
		if( ( tmp = scope_search(p, name)) != NULL ) return tmp;
		p = p->next;
	}
	return NULL;
}

node_t *scope_search(scope_t *top, char *name)
{
	assert(top != NULL);
	int index = hashpjw(name);
	node_t *tmp = top->table[index];
	return node_search(tmp, name);
}

node_t *scope_insert(scope_t *top, char *name)
{
	assert(top != NULL);
	int index = hashpjw(name);
	node_t *tmp = top->table[index];
	top->table[index] = node_insert(tmp, name);	
	return top->table[index];
}

void scope_redefinition(scope_t *top, char *name)
{
	if(scope_search(top, name) != NULL) yyerror("redeclaraction of variable");
}

/****** Hashpjw Function ******/
int hashpjw( char *s )
{
	char *p;
	unsigned h = 0, g;

	for(p = s; *p != EOS; p++){
		h = (h << 4) + (*p);
		if(g = h & 0xf0000000)
		{
			h = h ^ (g >> 24);
			h = h ^ g;
		}
	}
	return h % HASH_SIZE;
}
