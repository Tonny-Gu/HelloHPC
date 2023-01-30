#!/bin/bash

rm input*bin
gcc -O3 -Wall datagen.c -o datagen.exe
./datagen.exe