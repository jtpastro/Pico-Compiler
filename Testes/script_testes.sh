#!/bin/bash

cd ../src/
make clean
make
cd ../Testes

for (( i=0; i<=16; i=i+1 ));
do
    ../src/pico -o output.tac test$i.pico
    python tac2x86.py output.tac >> /dev/null
    as output.s -o output.o >> /dev/null
    ld -dynamic-linker /lib/ld-linux.so.2 -o output -lc output.o >> /dev/null
    ./output
    echo
    rm -f output.tac output.s output.o output
done
