CC      = gcc
LDFLAGS = -g

all: etapa2 

etapa2: pico

doc: Doxyfile $(HEAD1)
	doxygen Doxyfile

pico: lex.yy.c y.tab.c tokens.h node.o main-pico.c
	$(CC) $(LDFLAGS) -o pico lex.yy.c y.tab.c main-pico.c node.o -lfl

lex.yy.c: scanner.l tokens.h
	flex scanner.l;

tokens.h: y.tab.c

y.tab.c: pico.y
	yacc -d pico.y ; mv y.tab.h tokens.h

node.o: node.c node.h
	$(CC) $(LDFLAGS) -c node.c

clean:
	rm -f *.o lex.yy.? y.tab.? tokens.h pico
