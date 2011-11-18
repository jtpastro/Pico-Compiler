all: testeLista

testeLista: lista.o symbol_table.o testeLista.c
	gcc -o testeLista lista.o symbol_table.o testeLista.c -Wall

lista.o: symbol_table.o lista.c lista.h
	gcc -c lista.c -Wall

lista.c:
	cp ../../src/lista.[hc] .

symbol_table.o: symbol_table.c symbol_table.h
	gcc -c symbol_table.c

symbol_table.c:
	cp ../../src/symbol_table.[hc] .

clean:
	rm -f *.o lista.[hc] symbol_table.[hc] testeLista tac_teste.txt
