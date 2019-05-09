#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "node.h"

/****** Constructor ******/
node_t *mknode(char *s)
{
	assert(s != NULL);
	node_t *newNode = (node_t *)malloc(sizeof(node_t));
	assert(newNode != NULL);
	newNode->name = strdup(s);
	newNode->next = NULL;
	return newNode;
}

/****** Helper Functions ******/
node_t *node_search(node_t *top, char *name)
{
	node_t *currNode = top;
	while(currNode != NULL){
		if(strcmp(currNode->name, name) == 0) return currNode;
		currNode = currNode->next;
	}
	return NULL;
}

node_t *node_insert(node_t *top, char *name)
{
	node_t *newTop = mknode(name);	
	newTop->next = top;
	return newTop;
}

void node_print(node_t *top)
{
	node_t *currNode = top;
	fprintf(stderr, "BEGIN LIST PRINT:\n");
	while(currNode != NULL){
		fprintf(stderr, "[%s]", currNode->name);
		currNode = currNode->next;
	}	
	fprintf(stderr, "\n");
	fprintf(stderr, "END LIST PRINT\n");
}
