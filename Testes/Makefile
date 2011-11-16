all: testeNode

testeNode: node.h node.o testeNode.c
	gcc -lcunit testeNode.c node.o -o testeNode -Wall

node.o: node.c node.h testeUtils.h
	gcc -c node.c -o node.o -Wall

node.h: testeUtils.h ../src/node.h
	cat testeUtils.h ../src/node.h > node.h

node.c: ../src/node.c
	cp ../src/node.c .

clean:
	rm testeNode node.?
