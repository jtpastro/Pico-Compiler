CC      = gcc
LDFLAGS = -g

all: etapa2 

etapa2: pico

doc: Doxyfile $(HEAD1)
	doxygen Doxyfile

pico: lex.yy.c y.tab.c tokens.h node.o symbol_table.o lista.o main-pico.c
	$(CC) $(LDFLAGS) -o pico lex.yy.c y.tab.c main-pico.c node.o symbol_table.o lista.o -lfl

lex.yy.c: scanner.l tokens.h
	flex scanner.l;

tokens.h: y.tab.c

y.tab.c: pico.y
	yacc -d pico.y -W; mv y.tab.h tokens.h

node.o: node.c node.h
	$(CC) $(LDFLAGS) -c node.c

symbol_table.o: symbol_table.c symbol_table.h
	$(CC) $(LDFLAGS) -c symbol_table.c

lista.o: lista.c lista.h
	$(CC) $(LDFLAGS) -c lista.c

clean:
	rm -f *.o lex.yy.? y.tab.? tokens.h pico
