#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "scope.h"
#include "node.h"

/* compile with driver, scope, and node .c files */
int main()
{
	scope_t *top;
	node_t *tmp;	
	int choice;
	char name[32];

	top = NULL; /* Don't use mkscope(), start out empty */
	while(1){
		fprintf(stderr, "(0) push (1) pop (2) search (3) search_all (4) insert:\n");

		scanf("%d", &choice);
		switch(choice){
		case 0: /* Push */
			top = push_scope(top);
			break;
		case 1: /* Pop */
			top = pop_scope(top);
			break;
		case 2: /* Search */
			fprintf(stderr, "Name to search:\n");
			scanf("%s", name);
			tmp = scope_search(top, name);
			if(tmp != NULL){
				fprintf(stderr, "Found[%s]\n", tmp->name);
			} else {
				fprintf(stderr, "NotFound[%s]\n", name);
			}
			break;
		case 3: /* Search_all */
			fprintf(stderr, "Name to search:\n");
			scanf("%s", name);
			tmp = scope_search_all(top, name);
			if(tmp != NULL){
				fprintf(stderr, "Found[%s]\n", tmp->name);
			} else {
				fprintf(stderr, "NotFound[%s]\n", name);
			}
			break;
		case 4: /* Insert */
			scanf("%s", name);
			tmp = scope_insert(top, name);
			break;
		default:
			break;
		}
	}

	return 0;
}
