#!/bin/bash

cd ../src/
make clean
make
cd ../Testes
rm -f log.txt

for (( i=1; i<=16; i=i+1 ));
do
    ../src/pico -o output.tac nm_test$i.pico
    python tac2x86.py output.tac >> log.txt
    as output.s -o output.o >> log.txt
    ld -dynamic-linker /lib/ld-linux.so.2 -o output -lc output.o >> log.txt
    ./output
    rm -f output.tac output.s output.o output
done
