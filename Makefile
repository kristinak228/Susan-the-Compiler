CC = gcc
FLAGS = -g
YACC = yacc
LEX = flex

mypc: y.tab.o lex.yy.o tree.o scope.o node.o
	$(CC) $(FLAGS) -o mypc y.tab.o lex.yy.o tree.o scope.o node.o -ll -ly

tree.o: tree.c
	$(CC) $(FLAGS) -c tree.c

scope.o: scope.c
	$(CC) $(FLAGS) -c scope.c

node.o: node.c
	$(CC) $(FLAGS) -c node.c

y.tab.o: y.tab.c
	$(CC) $(FLAGS) -c y.tab.c

lex.yy.o: lex.yy.c
	$(CC) $(FLAGS) -c lex.yy.c

y.tab.c: pc.y
	$(YACC) -y -dv pc.y

lex.yy.c: pc.l
	$(LEX) -l pc.l

clean:
	rm -f mypc *.o y.tab.* tree.o lex.yy.*
